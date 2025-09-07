import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notes_reminder_app/features/note/note.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NoteRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('getNotes returns empty list when no data', () async {
      final repo = NoteRepositoryImpl();
      final notes = await repo.getNotes();
      expect(notes, isEmpty);
    });

    test('saveNotes and getNotes persist data', () async {
      final repo = NoteRepositoryImpl();
      final id = const Uuid().v4();
      final note = Note(
        id: id,
        title: 't',
        content: 'c',
        summary: '',
        actionItems: const [],
        dates: const [],
        alarmTime: DateTime(2024, 1, 1),
        attachments: ['a'],
        locked: true,
        snoozeMinutes: 10,
      );
      await repo.saveNotes([note]);
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('notes_v1');
      final stored =
          (jsonDecode(raw!) as List).cast<Map<String, dynamic>>().first;
      expect(stored['iv'], isNotEmpty);
      expect(stored['content'], isNot('c'));
      final notes = await repo.getNotes();
      expect(notes.length, 1);
      expect(notes.first.title, 't');
      expect(notes.first.snoozeMinutes, 10);
      expect(notes.first.locked, true);
      expect(notes.first.attachments, ['a']);
      expect(notes.first.alarmTime, DateTime(2024, 1, 1));
    });

    test('updateNote persists changes', () async {
      final repo = NoteRepositoryImpl();
      final id = const Uuid().v4();
      final note = Note(
        id: id,
        title: 't',
        content: 'c',
        summary: '',
        actionItems: const [],
        dates: const [],
        attachments: ['a'],
        snoozeMinutes: 5,
      );
      await repo.saveNotes([note]);
      final updated = Note(
        id: id,
        title: 't2',
        content: 'c2',
        summary: '',
        actionItems: const [],
        dates: const [],
        attachments: ['b'],
        snoozeMinutes: 15,
      );
      await repo.updateNote(updated);
      final notes = await repo.getNotes();
      expect(notes.length, 1);
      expect(notes.first.title, 't2');
      expect(notes.first.content, 'c2');
      expect(notes.first.snoozeMinutes, 15);
      expect(notes.first.attachments, ['b']);
    });
  });
}
