import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vosk_flutter/vosk_flutter.dart' as vosk;

import '../providers/note_provider.dart';
import '../services/gemini_service.dart';

class VoiceToNoteScreen extends StatefulWidget {
  final stt.SpeechToText speech;
  final vosk.VoskFlutterPlugin vosk;

  const VoiceToNoteScreen({
    super.key,
    stt.SpeechToText? speech,
    vosk.VoskFlutterPlugin? vosk,
  })  : speech = speech ?? stt.SpeechToText(),
        vosk = vosk ?? vosk.VoskFlutterPlugin();

  @override
  State<VoiceToNoteScreen> createState() => _VoiceToNoteScreenState();
}

class _VoiceToNoteScreenState extends State<VoiceToNoteScreen> {
  vosk.SpeechService? _voskService;
  vosk.Recognizer? _voskRecognizer;

  String _recognized = '';
  bool _isListening = false;
  bool _isProcessing = false;
  bool _offlineMode = false;

  Future<void> _startOffline() async {
    if (_voskRecognizer == null) {
      final locale = Localizations.localeOf(context);
      final code = {
            'vi': 'vi',
            'en': 'en',
          }[locale.languageCode] ??
          'en';
      final model = await widget.vosk
          .createModel('assets/models/vosk-model-small-$code');
      _voskRecognizer = await widget.vosk.createRecognizer(model: model);
      _voskService = await widget.vosk.initSpeechService(_voskRecognizer!);
      _voskService!.onResult().listen((event) {
        final data = jsonDecode(event) as Map<String, dynamic>;
        setState(() => _recognized = data['text'] ?? '');
      });
    }
    await _voskService!.start();
  }

  Future<void> _toggleListening() async {
    if (_offlineMode) {
      if (!_isListening) {
        await _startOffline();
        setState(() => _isListening = true);
      } else {
        await _voskService?.stop();
        setState(() => _isListening = false);
      }
      return;
    }

    if (!_isListening) {
      final available = await widget.speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        widget.speech.listen(onResult: (res) {
          setState(() => _recognized = res.recognizedWords);
        });
      } else {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.microphonePermissionMessage),
          ),
        );
      }
    } else {
      await widget.speech.stop();
      setState(() => _isListening = false);
    }
  }

  Future<void> _convertToNote() async {
    if (_recognized.isEmpty) return;
    setState(() => _isProcessing = true);
    final prompt = AppLocalizations.of(context)!
        .convertSpeechPrompt(_recognized);
    final l10n = AppLocalizations.of(context)!;
    final reply = await GeminiService().chat(prompt, l10n);
    if (!mounted) return;
    context.read<NoteProvider>().setDraft(reply);
    setState(() => _isProcessing = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    widget.speech.stop();
    _voskService?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.voiceToNote)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(child: Text(_recognized)),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.offlineMode),
              value: _offlineMode,
              onChanged: (v) => setState(() => _offlineMode = v),
            ),
            if (_isProcessing) const CircularProgressIndicator(),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _toggleListening,
                  child: Text(_isListening
                      ? AppLocalizations.of(context)!.stop
                      : AppLocalizations.of(context)!.speak),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _convertToNote,
                  child:
                      Text(AppLocalizations.of(context)!.convertToNote),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
