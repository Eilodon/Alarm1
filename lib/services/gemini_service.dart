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

  Future<NoteAnalysis?> analyzeNote(String content) async {
    if (_apiKey.isEmpty) return null;

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
    );

    final prompt =
        'Summarize the following note and return a JSON object with keys "summary" (string), "actionItems" (array of strings), "suggestedTags" (array of strings), and "dates" (array of ISO8601 date strings).\n$content';

    final body = {
      "contents": [
        {"parts": [{"text": prompt}]}
      ]
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) return null;

    try {
      final data = jsonDecode(res.body);
      final text = (data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '').toString();
      final map = jsonDecode(text);
      final dates = (map['dates'] as List<dynamic>? ?? [])
          .map((e) => DateTime.tryParse(e as String))
          .whereType<DateTime>()
          .toList();
      return NoteAnalysis(
        summary: map['summary'] as String? ?? '',
        actionItems: (map['actionItems'] as List<dynamic>? ?? []).cast<String>(),
        suggestedTags:
            (map['suggestedTags'] as List<dynamic>? ?? []).cast<String>(),
        dates: dates,
      );
    } catch (_) {
      return null;
    }
  }
}

class NoteAnalysis {
  final String summary;
  final List<String> actionItems;
  final List<String> suggestedTags;
  final List<DateTime> dates;

  NoteAnalysis({
    required this.summary,
    required this.actionItems,
    required this.suggestedTags,
    required this.dates,
  });
}
