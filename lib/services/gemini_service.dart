import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const _model = 'gemini-1.5-flash-latest';

  Future<String> chat(String userText) async {
    if (_apiKey.isEmpty) return 'Chưa cấu hình GEMINI_API_KEY';

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
    );
    final body = {
      "contents": [
        {"parts": [{"text": userText}]}
      ]
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final text = (data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '').toString();
      return text.isEmpty ? 'No response' : text;
    } else {
      return 'Gemini error: ${res.statusCode} ${res.body}';
    }
  }
}
