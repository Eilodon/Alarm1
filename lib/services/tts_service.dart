import 'dart:ui';

import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();

  String _ttsCodeForLocale(Locale locale) {
    const mapping = {
      'en': 'en-US',
      'vi': 'vi-VN',
    };
    return mapping[locale.languageCode] ?? locale.toLanguageTag();
  }

  Future<void> speak(String text, {Locale? locale}) async {
    final loc = locale ?? PlatformDispatcher.instance.locale;
    await _tts.setLanguage(_ttsCodeForLocale(loc));
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }
}
