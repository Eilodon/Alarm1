import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes_reminder_app/models/note.dart';
import 'package:notes_reminder_app/providers/note_provider.dart';
import 'package:notes_reminder_app/screens/note_detail_screen.dart';

void main() {

  testWidgets('display note details', (tester) async {
    final note = Note(id: '1', title: 'title', content: 'content');

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
}
