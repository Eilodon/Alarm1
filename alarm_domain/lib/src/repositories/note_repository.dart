import '../entities/note.dart';

/// Contract for persisting and retrieving [Note]s.
abstract class NoteRepository {
  Future<List<Note>> getNotes({void Function(String noteId)? onDecryptFailure});
  Future<void> saveNotes(List<Note> notes);
  Future<void> updateNote(Note note);
  Future<Map<String, dynamic>> encryptNote(Note note, {String? password});
  Future<Note> decryptNote(Map<String, dynamic> data, {String? password});
  Future<bool> autoBackup();
}
