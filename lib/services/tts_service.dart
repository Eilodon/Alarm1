import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class TTSService {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();

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

  Future<void> speakWithApi(String text) async {
    final apiKey =
        Platform.environment['TTS_API_KEY'] ?? const String.fromEnvironment('TTS_API_KEY');
    if (apiKey.isEmpty) {
      throw Exception('Missing TTS_API_KEY');
    }

    final url = Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/en-US');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'xi-api-key': apiKey,
      },
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode != 200) {
      throw Exception('TTS API error: ${response.statusCode}');
    }

    await _player.play(BytesSource(response.bodyBytes));
  }
}
