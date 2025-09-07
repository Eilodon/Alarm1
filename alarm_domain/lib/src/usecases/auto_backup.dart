import '../repositories/note_repository.dart';

/// Triggers an automatic backup of notes via the repository.
class AutoBackup {
  final NoteRepository repository;

  AutoBackup(this.repository);

  Future<bool> call() {
    return repository.autoBackup();
  }
}
