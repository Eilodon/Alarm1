import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vosk_flutter/vosk_flutter.dart' as vosk;

import '../providers/note_provider.dart';
import '../services/gemini_service.dart';

class VoiceToNoteScreen extends StatefulWidget {
  const VoiceToNoteScreen({super.key});

  @override
  State<VoiceToNoteScreen> createState() => _VoiceToNoteScreenState();
}

class _VoiceToNoteScreenState extends State<VoiceToNoteScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final vosk.VoskFlutterPlugin _vosk = vosk.VoskFlutterPlugin();
  vosk.SpeechService? _voskService;
  vosk.Recognizer? _voskRecognizer;

  String _recognized = '';
  bool _isListening = false;
  bool _isProcessing = false;
  bool _offlineMode = false;

  Future<void> _startOffline() async {
    if (_voskRecognizer == null) {
      final model =
          await _vosk.createModel('assets/models/vosk-model-small-en-us-0.15');
      _voskRecognizer = await _vosk.createRecognizer(model: model);
      _voskService = await _vosk.initSpeechService(_voskRecognizer!);
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
      final available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (res) {
          setState(() => _recognized = res.recognizedWords);
        });
      }
    } else {
      await _speech.stop();
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
    _speech.stop();
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
