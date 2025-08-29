import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class TtsService {
  static const _apiKey = String.fromEnvironment('FPT_API_KEY', defaultValue: '');
  static const _endpoint = 'https://api.fpt.ai/hmi/tts/v5';
  final _player = AudioPlayer();

  Future<String?> synth(String text, {String voice = 'banmai'}) async {
    if (_apiKey.isEmpty) return 'Chưa cấu hình FPT_API_KEY';

    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'api-key': _apiKey,
        'voice': voice,
        'speed': '0',
        'Content-Type': 'text/plain; charset=utf-8',
      },
      body: text,
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final url = data['async']?.toString();
      if (url == null || url.isEmpty) return 'Không lấy được audio URL';
      await _player.stop();
      await _player.play(UrlSource(url));
      return null;
    } else {
      return 'FPT TTS error: ${res.statusCode} ${res.body}';
    }
  }

  Future<void> stop() async => _player.stop();
}
