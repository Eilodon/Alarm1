import '../domain/domain.dart';

/// Deletes a [Note] by id.
///
/// Uses [GetNotes] and [SaveNotes] from the repository to remove
/// the note and persist the updated collection.
class DeleteNote {
  final GetNotes _getNotes;
  final SaveNotes _saveNotes;

  DeleteNote(NoteRepository repository)
      : _getNotes = GetNotes(repository),
        _saveNotes = SaveNotes(repository);

  Future<void> call(String id) async {
    final notes = await _getNotes();
    notes.removeWhere((n) => n.id == id);
    await _saveNotes(notes);
  }
}
