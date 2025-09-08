import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pandora/generated/app_localizations.dart';
import 'package:pandora/features/chat/data/gemini_service.dart';

class MockL10n extends Mock implements AppLocalizations {}

void main() {
  group('analyzeNote', () {
    test('parses valid response', () async {
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

      final service = GeminiServiceImpl(client: client, apiKey: 'test');
      final result = await service.analyzeNote('test note');

      expect(result, isNotNull);
      expect(result!.summary, analysisJson['summary']);
      expect(result.actionItems, analysisJson['actionItems']);
      expect(result.suggestedTags, analysisJson['suggestedTags']);
      expect(result.dates.first, DateTime.parse(analysisJson['dates']![0]));
    });

    test('returns null on http error', () async {
      final client = MockClient((_) async => http.Response('err', 500));
      final service = GeminiServiceImpl(client: client, apiKey: 'test');

      final result = await service.analyzeNote('note');
      expect(result, isNull);
    });

    test('returns null on network error', () async {
      final client = MockClient((_) async => throw SocketException('no net'));
      final service = GeminiServiceImpl(client: client, apiKey: 'test');

      final result = await service.analyzeNote('note');
      expect(result, isNull);
    });
  });

  group('chat', () {
    late MockL10n l10n;

    setUp(() {
      l10n = MockL10n();
      when(() => l10n.geminiApiKeyNotConfigured).thenReturn('no key');
      when(() => l10n.noResponse).thenReturn('no response');
      when(() => l10n.noInternetConnection).thenReturn('no internet');
      when(() => l10n.networkError).thenReturn('network error');
      when(() => l10n.geminiError(any())).thenAnswer(
          (invocation) => 'error: ${invocation.positionalArguments.first}');
    });

    test('returns error on invalid api key', () async {
      final client = MockClient((_) async => http.Response('denied', 401));
      final service = GeminiServiceImpl(client: client, apiKey: 'test');

      final result = await service.chat('hi', l10n);
      expect(result, 'error: Invalid API key');
    });

    test('returns error on server issue', () async {
      final client =
          MockClient((_) async => http.Response('boom', 500, reasonPhrase: 'ERR'));
      final service = GeminiServiceImpl(client: client, apiKey: 'test');

      final result = await service.chat('hi', l10n);
      expect(result, 'error: 500 ERR');
    });

    test('returns no internet on socket exception', () async {
      final client = MockClient((_) async => throw SocketException('x'));
      final service = GeminiServiceImpl(client: client, apiKey: 'test');

      final result = await service.chat('hi', l10n);
      expect(result, 'no internet');
    });
  });
}

