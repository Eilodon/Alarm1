import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Updates a single [Note].
class UpdateNote {
  final NoteRepository repository;

  UpdateNote(this.repository);

  Future<void> call(Note note) {
    return repository.updateNote(note);
  }
}
