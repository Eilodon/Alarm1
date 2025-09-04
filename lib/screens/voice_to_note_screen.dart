import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../providers/note_provider.dart';
import '../services/gemini_service.dart';

class VoiceToNoteScreen extends StatefulWidget {
  const VoiceToNoteScreen({super.key});

  @override
  State<VoiceToNoteScreen> createState() => _VoiceToNoteScreenState();
}

class _VoiceToNoteScreenState extends State<VoiceToNoteScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _recognized = '';
  bool _isListening = false;
  bool _isProcessing = false;

  Future<void> _toggleListening() async {
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
    final reply = await GeminiService()
        .chat('Chuyển đoạn nói sau thành ghi chú: $_recognized');
    if (!mounted) return;
    context.read<NoteProvider>().setDraft(reply);
    setState(() => _isProcessing = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice To Note')),
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
                  child: Text(_isListening ? 'Dừng' : 'Nói'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _convertToNote,
                  child: const Text('Chuyển thành ghi chú'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
