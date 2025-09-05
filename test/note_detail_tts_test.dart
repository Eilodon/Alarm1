import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes_reminder_app/models/note.dart';
import 'package:notes_reminder_app/providers/note_provider.dart';
import 'package:notes_reminder_app/screens/note_detail_screen.dart';
import 'package:notes_reminder_app/services/tts_service.dart';

class MockTTS extends Mock implements TTSService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const Locale('en'));
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
}
