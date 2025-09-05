import '../models/note.dart';
import 'db_service.dart';

class NoteRepository {
  final DbService _dbService;

  NoteRepository({DbService? dbService}) : _dbService = dbService ?? DbService();

  Future<List<Note>> getNotes() {
    return _dbService.getNotes();
  }

  Future<void> saveNotes(List<Note> notes) {
    return _dbService.saveNotes(notes);
  }

  Future<void> updateNote(Note note) {
    return _dbService.updateNote(note);
  }

  Future<Map<String, dynamic>> encryptNote(Note note) {
    return _dbService.encryptNote(note);
  }
}
