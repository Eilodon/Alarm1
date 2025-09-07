import '../domain/domain.dart';

/// Retrieves a single [Note] by id using the [NoteRepository].
class GetNoteById {
  final GetNotes _getNotes;

  GetNoteById(NoteRepository repository)
      : _getNotes = GetNotes(repository);

  Future<Note?> call(String id) async {
    final notes = await _getNotes();
    try {
      return notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }
}
