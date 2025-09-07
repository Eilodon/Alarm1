import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:alarm_domain/alarm_domain.dart';
import '../datasources/db_service.dart';
import '../datasources/backup_service.dart';

class NoteRepositoryImpl implements NoteRepository {
  final DbService _dbService;
  final BackupService _backupService;

  NoteRepositoryImpl({DbService? dbService, BackupService? backupService})
      : _dbService = dbService ?? DbService(),
        _backupService = backupService ?? BackupService();

  @override
  Future<List<Note>> getNotes({
    void Function(String noteId)? onDecryptFailure,
  }) {
    return _dbService.getNotes(onDecryptFailure: onDecryptFailure);
  }

  @override
  Future<void> saveNotes(List<Note> notes) {
    return _dbService.saveNotes(notes);
  }

  @override
  Future<void> updateNote(Note note) {
    return _dbService.updateNote(note);
  }

  @override
  Future<Map<String, dynamic>> encryptNote(Note note, {String? password}) {
    return _dbService.encryptNote(note, password: password);
  }

  @override
  Future<Note> decryptNote(Map<String, dynamic> data, {String? password}) {
    return _dbService.decryptNote(data, password: password);
  }

  Future<bool> exportNotes(
    AppLocalizations l10n, {
    String? password,
    BackupFormat format = BackupFormat.json,
  }) async {
    final notes = await _dbService.getNotes();
    return _backupService.exportNotes(
      notes,
      l10n,
      password: password,
      format: format,
    );
  }

  Future<List<Note>> importNotes(
    AppLocalizations l10n, {
    String? password,
    BackupFormat format = BackupFormat.json,
  }) async {
    final notes = await _backupService.importNotes(
      l10n,
      password: password,
      format: format,
    );
    if (notes.isNotEmpty) {
      await _dbService.saveNotes(notes);
    }
    return notes;
  }

  @override
  Future<bool> autoBackup() async {
    final notes = await _dbService.getNotes();
    return _backupService.autoBackup(notes);
  }
}
