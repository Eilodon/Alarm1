import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vosk_flutter/vosk_flutter.dart' as vosk;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes_reminder_app/screens/voice_to_note_screen.dart';

class MockSpeechToText extends Mock implements stt.SpeechToText {}

class MockVosk extends Mock implements vosk.VoskFlutterPlugin {}

class MockSpeechService extends Mock implements vosk.SpeechService {}

class MockRecognizer extends Mock implements vosk.Recognizer {}

class MockModel extends Mock implements vosk.Model {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VoiceToNoteScreen STT', () {
    testWidgets('online mode uses SpeechToText', (tester) async {
      final speech = MockSpeechToText();
      when(() => speech.initialize()).thenAnswer((_) async => true);
      when(() => speech.listen(onResult: any(named: 'onResult'))).thenAnswer((
        invocation,
      ) {
        final callback =
            invocation.namedArguments[#onResult]
                as void Function(stt.SpeechRecognitionResult);
        callback(
          stt.SpeechRecognitionResult([
            stt.SpeechRecognitionWords('hello', null, 1.0),
          ], true),
        );
      });
      when(() => speech.stop()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: VoiceToNoteScreen(speech: speech),
        ),
      );

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(l10n.speak));
      await tester.pump();

      expect(find.text('hello'), findsOneWidget);
      verify(() => speech.listen(onResult: any(named: 'onResult'))).called(1);
    });

    testWidgets('offline mode uses Vosk', (tester) async {
      final speech = MockSpeechToText();
      when(() => speech.stop()).thenAnswer((_) async {});
      final voskPlugin = MockVosk();
      final service = MockSpeechService();
      final recognizer = MockRecognizer();
      final model = MockModel();
      when(() => voskPlugin.createModel(any())).thenAnswer((_) async => model);
      when(
        () => voskPlugin.createRecognizer(model: model),
      ).thenAnswer((_) async => recognizer);
      when(
        () => voskPlugin.initSpeechService(recognizer),
      ).thenAnswer((_) async => service);
      final controller = StreamController<String>();
      when(() => service.onResult()).thenAnswer((_) => controller.stream);
      when(() => service.start()).thenAnswer((_) async {});
      when(() => service.stop()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: VoiceToNoteScreen(speech: speech, vosk: voskPlugin),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(l10n.speak));
      await tester.pump();

      controller.add('{"text": "offline"}');
      await tester.pump();

      expect(find.text('offline'), findsOneWidget);
      verify(() => voskPlugin.createModel(any())).called(1);
      verify(() => voskPlugin.createRecognizer(model: model)).called(1);
      verify(() => voskPlugin.initSpeechService(recognizer)).called(1);
      verify(() => service.start()).called(1);
      await controller.close();
    });

    testWidgets('_startOffline initializes Vosk only once', (tester) async {
      final speech = MockSpeechToText();
      when(() => speech.stop()).thenAnswer((_) async {});
      final voskPlugin = MockVosk();
      final service = MockSpeechService();
      final recognizer = MockRecognizer();
      final model = MockModel();
      when(() => voskPlugin.createModel(any())).thenAnswer((_) async => model);
      when(
        () => voskPlugin.createRecognizer(model: model),
      ).thenAnswer((_) async => recognizer);
      when(
        () => voskPlugin.initSpeechService(recognizer),
      ).thenAnswer((_) async => service);
      when(() => service.onResult()).thenAnswer((_) => const Stream.empty());
      when(() => service.start()).thenAnswer((_) async {});
      when(() => service.stop()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: VoiceToNoteScreen(speech: speech, vosk: voskPlugin),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      // Start listening offline
      await tester.tap(find.text(l10n.speak));
      await tester.pump();

      // Stop listening
      await tester.tap(find.text(l10n.stop));
      await tester.pump();

      // Start again
      await tester.tap(find.text(l10n.speak));
      await tester.pump();

      verify(() => voskPlugin.createModel(any())).called(1);
      verify(() => voskPlugin.createRecognizer(model: model)).called(1);
      verify(() => voskPlugin.initSpeechService(recognizer)).called(1);
      verify(() => service.start()).called(2);
    });
  });
}
