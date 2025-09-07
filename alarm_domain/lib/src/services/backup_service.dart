import '../entities/note.dart';

enum BackupFormat { json, pdf, md }

abstract class BackupService {
  Future<bool> exportNotes(
    List<Note> notes,
    dynamic l10n, {
    String? password,
    BackupFormat format = BackupFormat.json,
  });

  Future<List<Note>> importNotes(
    dynamic l10n, {
    String? password,
    BackupFormat format = BackupFormat.json,
  });

  Future<bool> autoBackup(
    List<Note> notes, {
    String fileName = 'notes_autobackup.json',
  });
}
