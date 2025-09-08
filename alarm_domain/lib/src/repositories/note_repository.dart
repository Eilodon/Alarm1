import 'package:pandora/generated/app_localizations.dart';

import '../entities/note.dart';
import '../services/backup_service.dart';

/// Contract for persisting and retrieving [Note]s.
abstract class NoteRepository {
  Future<List<Note>> getNotes({void Function(String noteId)? onDecryptFailure});
  Future<void> saveNotes(List<Note> notes);
  Future<void> updateNote(Note note);
  Future<Map<String, dynamic>> encryptNote(Note note, {String? password});
  Future<Note> decryptNote(Map<String, dynamic> data, {String? password});
  Future<bool> autoBackup();
  Future<bool> exportNotes(
    AppLocalizations l10n, {
    String? password,
    BackupFormat format = BackupFormat.json,
  });

  Future<List<Note>> importNotes(
    AppLocalizations l10n, {
    String? password,
    BackupFormat format = BackupFormat.json,
  });
}
