import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'backup_format.dart';
import 'note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes({void Function(String noteId)? onDecryptFailure});
  Future<void> saveNotes(List<Note> notes);
  Future<void> updateNote(Note note);
  Future<Map<String, dynamic>> encryptNote(Note note, {String? password});
  Future<Note> decryptNote(Map<String, dynamic> data, {String? password});
  Future<bool> exportNotes(AppLocalizations l10n, {String? password, BackupFormat format = BackupFormat.json});
  Future<List<Note>> importNotes(AppLocalizations l10n, {String? password, BackupFormat format = BackupFormat.json});
  Future<bool> autoBackup();
}
