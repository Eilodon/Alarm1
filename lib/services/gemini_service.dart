import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GeminiService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const _model = 'gemini-1.5-flash-latest';

  Future<String> chat(String userText, AppLocalizations l10n) async {
    if (_apiKey.isEmpty) return l10n.geminiApiKeyNotConfigured;

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
      return text.isEmpty ? l10n.noResponse : text;
    } else {
      return l10n.geminiError('${res.statusCode} ${res.body}');
    }
  }
}
