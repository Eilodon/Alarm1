import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../providers/note_provider.dart';
import '../services/gemini_service.dart';

class VoiceToNoteScreen extends StatefulWidget {
  final stt.SpeechToText speech;
  final bool autoStart;

  const VoiceToNoteScreen({
    super.key,
    stt.SpeechToText? speech,
    this.autoStart = false,
  }) : speech = speech ?? stt.SpeechToText();

  @override
  State<VoiceToNoteScreen> createState() => _VoiceToNoteScreenState();
}

class _VoiceToNoteScreenState extends State<VoiceToNoteScreen> {
  String _recognized = '';
  bool _isListening = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _toggleListening();
      });
    }
  }

  Future<void> _toggleListening() async {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.voiceToNote)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(child: Text(_recognized)),
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
                  child: Text(AppLocalizations.of(context)!.convertToNote),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
