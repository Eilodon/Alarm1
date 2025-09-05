import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:notes_reminder_app/services/gemini_service.dart';

void main() {
  test('analyzeNote parses valid response', () async {
    final service = GeminiService();
    final analysisJson = {
      'summary': 'note summary',
      'actionItems': ['task1'],
      'suggestedTags': ['tag1', 'tag2'],
      'dates': ['2024-01-01T00:00:00Z']
    };
    final apiResponse = {
      'candidates': [
        {
          'content': {
            'parts': [
              {'text': jsonEncode(analysisJson)}
            ]
          }
        }
      ]
    };

    final client = MockClient((request) async {
      expect(request.method, 'POST');
      return http.Response(jsonEncode(apiResponse), 200,
          headers: {'content-type': 'application/json'});
    });

    final result = await http.runWithClient(
        () => service.analyzeNote('test note'), () => client);

    expect(result, isNotNull);
    expect(result!.summary, analysisJson['summary']);
    expect(result.actionItems, analysisJson['actionItems']);
    expect(result.suggestedTags, analysisJson['suggestedTags']);
    expect(result.dates.first, DateTime.parse(analysisJson['dates']![0]));
  });
}
