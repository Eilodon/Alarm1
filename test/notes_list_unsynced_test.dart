import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:notes_reminder_app/providers/note_provider.dart';
import 'package:notes_reminder_app/widgets/notes_list.dart';
import 'package:notes_reminder_app/models/note.dart';
import 'package:notes_reminder_app/services/note_repository.dart';

class MockRepo extends Mock implements NoteRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('displays sync problem icon for unsynced notes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = MockRepo();
    when(() => repo.saveNotes(any())).thenAnswer((_) async {});
    final provider = NoteProvider(repository: repo);
    await Future.delayed(Duration.zero);

    const note = Note(
      id: '1',
      title: 'title',
      content: 'content',
      summary: '',
      actionItems: [],
      dates: [],
    );
    await provider.addNote(note);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: NotesList(notes: provider.notes)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.sync_problem), findsOneWidget);
  });
}
