import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  Future<Map<String, dynamic>> encryptNote(Note note, {String? password}) {
    return _dbService.encryptNote(note, password: password);
  }

  Future<Note> decryptNote(Map<String, dynamic> data, {String? password}) {
    return _dbService.decryptNote(data, password: password);
  }

  Future<bool> exportNotes(AppLocalizations l10n, {String? password}) async {
    final notes = await _dbService.getNotes();
    return _backupService.exportNotes(notes, l10n, password: password);
  }

  Future<List<Note>> importNotes(AppLocalizations l10n, {String? password}) async {
    final notes = await _backupService.importNotes(l10n, password: password);
    if (notes.isNotEmpty) {
      await _dbService.saveNotes(notes);
    }
    return notes;
  }

}
