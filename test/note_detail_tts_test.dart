import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:notes_reminder_app/features/note/note.dart';
import 'package:notes_reminder_app/services/tts_service.dart';

class MockTTS extends Mock implements TTSService {}
class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const Locale('en'));
    registerFallbackValue(BytesSource(Uint8List(0)));
  });

  testWidgets('read note triggers TTS', (tester) async {
    final tts = MockTTS();
    when(() => tts.speak(any(), locale: any(named: 'locale'))).thenAnswer((_) async {});

    final note = const Note(
      id: '1',
      title: 't',
      content: 'content',
      summary: '',
      actionItems: const [],
      dates: const [],
    );

    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => NoteProvider(),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: NoteDetailScreen(note: note, ttsService: tts),
      ),
    ));

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l10n.readNote));
    await tester.pump();

    verify(() => tts.speak('content', locale: any(named: 'locale'))).called(1);
  });

  test('speakWithApi uses provided voiceId', () async {
    final player = MockAudioPlayer();
    when(() => player.play(any())).thenAnswer((_) async {});

    Uri? requested;
    final client = MockClient((request) async {
      requested = request.url;
      return http.Response.bytes(Uint8List(0), 200);
    });

    final service = TTSService(player: player, client: client);
    await service.speakWithApi('hello', voiceId: 'test-voice');

    expect(requested!.pathSegments.last, 'test-voice');
    verify(() => player.play(any())).called(1);
  });

  test('speakWithApi maps locale to voice', () async {
    final player = MockAudioPlayer();
    when(() => player.play(any())).thenAnswer((_) async {});

    Uri? requested;
    final client = MockClient((request) async {
      requested = request.url;
      return http.Response.bytes(Uint8List(0), 200);
    });

    final service = TTSService(player: player, client: client);
    await service.speakWithApi('xin chao', locale: const Locale('vi'));

    expect(requested!.pathSegments.last, 'vi-VN');
  });
}
