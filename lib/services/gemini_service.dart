import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GeminiService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  final http.Client _client;
  final String _model;

  GeminiService({http.Client? client, String model = 'gemini-1.5-flash-latest'})
      : _client = client ?? http.Client(),
        _model = model;

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

    try {
      final res = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final text = (data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '').toString();
        return text.isEmpty ? l10n.noResponse : text;
      }

      if (res.statusCode == 401 || res.statusCode == 403) {
        debugPrint('Gemini chat invalid API key: ${res.statusCode} ${res.body}');
        return l10n.geminiError('Invalid API key');
      }

      debugPrint('Gemini chat HTTP ${res.statusCode}: ${res.body}');
      return l10n.geminiError('${res.statusCode} ${res.reasonPhrase ?? ''}');
    } on SocketException catch (e, st) {
      debugPrint('Gemini chat network error: $e\n$st');
      return l10n.noInternetConnection;
    } on TimeoutException catch (e, st) {
      debugPrint('Gemini chat timeout: $e\n$st');
      return l10n.networkError;
    } catch (e, st) {
      debugPrint('Gemini chat unknown error: $e\n$st');
      return l10n.networkError;
    }
  }

  Future<NoteAnalysis?> analyzeNote(String content) async {
    if (_apiKey.isEmpty) return null;

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
    );

    final prompt =
        'Summarize the following note and return a JSON object with keys "summary" (string), "actionItems" (array of strings), "suggestedTags" (array of strings), "suggestedTitle" (string), and "dates" (array of ISO8601 date strings).\n$content';

    final body = {
      "contents": [
        {"parts": [{"text": prompt}]}
      ]
    };

    http.Response res;
    try {
      res = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
    } on SocketException catch (e, st) {
      debugPrint('analyzeNote network error: $e\n$st');
      return null;
    } on TimeoutException catch (e, st) {
      debugPrint('analyzeNote timeout: $e\n$st');
      return null;
    } catch (e, st) {
      debugPrint('analyzeNote request error: $e\n$st');
      return null;
    }

    if (res.statusCode != 200) {
      if (res.statusCode == 401 || res.statusCode == 403) {
        debugPrint('analyzeNote invalid API key: ${res.statusCode} ${res.body}');
      } else {
        debugPrint('analyzeNote HTTP ${res.statusCode}: ${res.body}');
      }
      return null;
    }

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
          suggestedTitle: map['suggestedTitle'] as String?,
          dates: dates,
        );
    } catch (e, st) {
      debugPrint('analyzeNote parse error: $e\n$st');
      return null;
    }
  }
}

class NoteAnalysis {
  final String summary;
  final List<String> actionItems;
  final List<String> suggestedTags;
  final String? suggestedTitle;
  final List<DateTime> dates;

  NoteAnalysis({
    required this.summary,
    required this.actionItems,
    required this.suggestedTags,
    required this.dates,
    this.suggestedTitle,
  });
}
