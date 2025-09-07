import 'package:alarm_domain/alarm_domain.dart';
import 'package:alarm_data/alarm_data.dart' as data;

class BackupServiceImpl implements BackupService {
  final data.BackupService _service;

  BackupServiceImpl({data.BackupService? service})
      : _service = service ?? data.BackupService();

  @override
  Future<bool> exportNotes(
    List<Note> notes,
    dynamic l10n, {
    String? password,
    BackupFormat format = BackupFormat.json,
  }) {
    return _service.exportNotes(
      notes,
      l10n,
      password: password,
      format: format,
    );
  }

  @override
  Future<List<Note>> importNotes(
    dynamic l10n, {
    String? password,
    BackupFormat format = BackupFormat.json,
  }) {
    return _service.importNotes(
      l10n,
      password: password,
      format: format,
    );
  }

  @override
  Future<bool> autoBackup(
    List<Note> notes, {
    String fileName = 'notes_autobackup.json',
  }) {
    return _service.autoBackup(notes, fileName: fileName);
  }
}
