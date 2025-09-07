import '../entities/note.dart';
import '../repositories/note_repository.dart';
import '../services/note_sync_service.dart';

/// Persists a new [Note] and synchronizes it.
class CreateNote {
  final NoteRepository _repository;
  final NoteSyncService _syncService;

  CreateNote(
    NoteRepository repository,
    NoteSyncService syncService,
  )   : _repository = repository,
        _syncService = syncService;

  /// Saves the provided [notes] collection and syncs the [note].
  Future<void> call(Note note, List<Note> notes) async {
    await _repository.saveNotes(notes);
    await _syncService.syncNote(note);
  }
}
