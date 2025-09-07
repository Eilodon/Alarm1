import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Persists a list of [Note]s.
class SaveNotes {
  final NoteRepository repository;

  SaveNotes(this.repository);

  Future<void> call(List<Note> notes) {
    return repository.saveNotes(notes);
  }
}
