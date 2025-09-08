import 'package:flutter/material.dart';
import 'package:pandora/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:notes_reminder_app/features/note/presentation/note_provider.dart';
import 'package:notes_reminder_app/features/chat/data/gemini_service.dart';

class VoiceToNoteScreen extends StatefulWidget {
  final stt.SpeechToText speech;
  final bool autoStart;

  VoiceToNoteScreen({
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
  double _level = 0;
  double _maxLevel = 1;

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
        setState(() {
          _isListening = true;
          _level = 0;
          _maxLevel = 1;
        });
        widget.speech.listen(
          onResult: (res) {
            setState(() => _recognized = res.recognizedWords);
          },
          onSoundLevelChange: (level) {
            setState(() {
              _level = level;
              if (level > _maxLevel) _maxLevel = level;
            });
          },
        );
      } else {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.microphonePermissionMessage)),
        );
      }
    } else {
      await widget.speech.stop();
      setState(() {
        _isListening = false;
        _level = 0;
      });
      if (_recognized.isEmpty) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.speechNotRecognizedMessage)),
        );
      }
    }
  }

  Future<void> _convertToNote() async {
    if (_recognized.isEmpty) return;
    setState(() => _isProcessing = true);
    final prompt = AppLocalizations.of(
      context,
    )!.convertSpeechPrompt(_recognized);
    final l10n = AppLocalizations.of(context)!;
    final reply = await GeminiServiceImpl().chat(prompt, l10n);
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.voiceToNote)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(child: Text(_recognized))),
            if (_isProcessing) const CircularProgressIndicator(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleListening,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          key: ValueKey(_isListening),
                          color: _isListening
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                      ),
                      label: Text(
                        _isListening
                            ? AppLocalizations.of(context)!.stop
                            : AppLocalizations.of(context)!.speak,
                      ),
                    ),
                    if (_isListening)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          width: 120,
                          child: LinearProgressIndicator(
                            value: _maxLevel > 0 ? _level / _maxLevel : 0,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isProcessing || _recognized.isEmpty
                      ? null
                      : _convertToNote,
                  child: Text(AppLocalizations.of(context)!.convertToNote),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
