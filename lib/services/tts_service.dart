import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text) async {
    await _tts.setLanguage("vi-VN");
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }
}
