import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

import 'package:notes_reminder_app/services/tts_platform_stub.dart'
    if (dart.library.io) 'dart:io';

class TTSService {
  final FlutterTts _tts;
  final AudioPlayer _player;
  final http.Client _client;

  static const Map<String, String> _localeMapping = {
    'en': 'en-US',
    'vi': 'vi-VN',
  };

  TTSService({FlutterTts? tts, AudioPlayer? player, http.Client? client})
      : _tts = tts ?? FlutterTts(),
        _player = player ?? AudioPlayer(),
        _client = client ?? http.Client();

  String _ttsCodeForLocale(Locale locale) {
    return _localeMapping[locale.languageCode] ?? locale.toLanguageTag();
  }

  Future<void> speak(String text, {Locale? locale}) async {
    final loc = locale ?? PlatformDispatcher.instance.locale;
    await _tts.setLanguage(_ttsCodeForLocale(loc));
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  String _getApiKey() {
    const key = String.fromEnvironment('TTS_API_KEY');
    if (key.isNotEmpty) {
      return key;
    }
    if (!kIsWeb) {
      try {
        return Platform.environment['TTS_API_KEY'] ?? '';
      } catch (e, st) {
        debugPrint('Failed to read TTS_API_KEY from environment: $e\n$st');
      }
    }
    return '';
  }

  String _mapError(Object error) {
    if (error is SocketException) {
      return 'No internet connection';
    }
    if (error is TimeoutException) {
      return 'Request timed out';
    }
    return 'TTS API request failed';
  }

  String _voiceIdForLocale(Locale locale) {
    return _localeMapping[locale.languageCode] ?? 'en-US';
  }

  Future<void> speakWithApi(String text,
      {Locale? locale, String? voiceId}) async {
    final apiKey = _getApiKey();
    if (apiKey.isEmpty) {
      throw Exception('Missing TTS_API_KEY');
    }

    final loc = locale ?? PlatformDispatcher.instance.locale;
    final voice = voiceId ?? _voiceIdForLocale(loc);
    final url =
        Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voice');
    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'xi-api-key': apiKey,
            },
            body: jsonEncode({'text': text}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await _player.play(BytesSource(response.bodyBytes));
        return;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('TTS API invalid key: ${response.statusCode} ${response.body}');
        await speak(text);
        throw Exception('Invalid API key');
      }

      debugPrint('TTS API HTTP ${response.statusCode}: ${response.body}');
      await speak(text);
      throw Exception('TTS API error: ${response.statusCode}');
    } on Exception catch (e, st) {
      debugPrint('TTS API request failed: $e\n$st');
      await speak(text);
      throw Exception(_mapError(e));
    }
  }
}
