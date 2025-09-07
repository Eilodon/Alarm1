import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Retrieves all notes from the repository.
class GetNotes {
  final NoteRepository repository;

  GetNotes(this.repository);

  Future<List<Note>> call({void Function(String noteId)? onDecryptFailure}) {
    return repository.getNotes(onDecryptFailure: onDecryptFailure);
  }
}
