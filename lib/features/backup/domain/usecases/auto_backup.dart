import '../../data/backup_service.dart';
import '../../../note/domain/entities/note.dart';

class AutoBackup {
  final BackupService _service;
  AutoBackup({BackupService? service}) : _service = service ?? BackupService();

  Future<bool> call(List<Note> notes) {
    return _service.autoBackup(notes);
  }
}
