import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notes_reminder_app/services/note_repository.dart';
import 'package:notes_reminder_app/models/note.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NoteRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('getNotes returns empty list when no data', () async {
      final repo = NoteRepository();
      final notes = await repo.getNotes();
      expect(notes, isEmpty);
    });

    test('saveNotes and getNotes persist data', () async {
      final repo = NoteRepository();
      final note = Note(
        id: '1',
        title: 't',
        content: 'c',
        snoozeMinutes: 10,
      );
      await repo.saveNotes([note]);
      final notes = await repo.getNotes();
      expect(notes.length, 1);
      expect(notes.first.title, 't');
      expect(notes.first.snoozeMinutes, 10);
    });

    test('updateNote persists changes', () async {
      final repo = NoteRepository();
      final note = Note(
        id: '1',
        title: 't',
        content: 'c',
        snoozeMinutes: 5,
      );
      await repo.saveNotes([note]);
      final updated = Note(
        id: '1',
        title: 't2',
        content: 'c2',
        snoozeMinutes: 15,
      );
      await repo.updateNote(updated);
      final notes = await repo.getNotes();
      expect(notes.length, 1);
      expect(notes.first.title, 't2');
      expect(notes.first.content, 'c2');
      expect(notes.first.snoozeMinutes, 15);
    });
  });
}
