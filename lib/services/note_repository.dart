import '../models/note.dart';
import 'db_service.dart';
import 'backup_service.dart';

class NoteRepository {
  final DbService _dbService;
  final BackupService _backupService;

  NoteRepository({DbService? dbService, BackupService? backupService})
      : _dbService = dbService ?? DbService(),
        _backupService = backupService ?? BackupService();

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



  Future<Note> decryptNote(Map<String, dynamic> data) {
    return _dbService.decryptNote(data);
  }

  Future<void> exportNotes() async {
    final notes = await _dbService.getNotes();
    await _backupService.exportNotes(notes);
  }

  Future<List<Note>> importNotes() async {
    final notes = await _backupService.importNotes();
    if (notes.isNotEmpty) {
      await _dbService.saveNotes(notes);
    }
    return notes;
  }

}
