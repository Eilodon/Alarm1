import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/models/note.dart';
import 'package:notes_reminder_app/screens/note_search_delegate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  testWidgets('NoteSearchDelegate displays results', (tester) async {
    final notes = [
      const Note(
        id: '1',
        title: 'apple',
        content: 'fruit',
        summary: '',
        actionItems: const [],
        dates: const [],
      )
    ];

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () {
            showSearch(context: context, delegate: NoteSearchDelegate(notes));
          },
          child: const Text('search'),
        ),
      ),
    ));

    await tester.tap(find.text('search'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pumpAndSettle();

    expect(find.text('apple'), findsOneWidget);
  });
}
