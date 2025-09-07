import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:notes_reminder_app/providers/note_provider.dart';
import 'package:notes_reminder_app/screens/note_detail_screen.dart';

void main() {
  testWidgets('display note details', (tester) async {
    final note = Note(
      id: '1',
      title: 'title',
      content: 'content',
      summary: '',
      actionItems: const [],
      dates: const [],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => NoteProvider(),

        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NoteDetailScreen(note: note),
        ),
      ),
    );

    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('remove attachment updates UI and data', (tester) async {
    final provider = NoteProvider();
    const note = Note(
      id: '1',
      title: 'title',
      content: 'content',
      summary: '',
      actionItems: [],
      dates: [],
      attachments: ['a.txt'],
    );
    await provider.addNote(note);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NoteDetailScreen(note: note),
        ),
      ),
    );

    expect(find.text('a.txt'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete));

    while (find.text('a.txt').evaluate().isNotEmpty) {
      await tester.pumpAndSettle();
    }

    expect(find.text('a.txt'), findsNothing);

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(provider.notes.first.attachments, isEmpty);
  });
}
