import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes_reminder_app/features/note/presentation/screens/voice_to_note_screen.dart';

class MockSpeechToText extends Mock implements stt.SpeechToText {}


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

      final convertButtonBefore = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, l10n.convertToNote),
      );
      expect(convertButtonBefore.onPressed, isNull);

      await tester.tap(find.text(l10n.speak));
      await tester.pump();

      expect(find.text('hello'), findsOneWidget);

      final convertButtonAfter = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, l10n.convertToNote),
      );
      expect(convertButtonAfter.onPressed, isNotNull);

      verify(() => speech.listen(onResult: any(named: 'onResult'))).called(1);
    });

    testWidgets('shows snackbar when no speech recognized', (tester) async {
      final speech = MockSpeechToText();
      when(() => speech.initialize()).thenAnswer((_) async => true);
      when(() => speech.listen(onResult: any(named: 'onResult')))
          .thenAnswer((_) async {});
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
      await tester.tap(find.text(l10n.stop));
      await tester.pump();

      expect(find.text(l10n.speechNotRecognizedMessage), findsOneWidget);
    });

    testWidgets('shows snackbar when permission denied', (tester) async {
      final speech = MockSpeechToText();
      when(() => speech.initialize()).thenAnswer((_) async => false);

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

      expect(find.text(l10n.microphonePermissionMessage), findsOneWidget);
    });

  });
}
