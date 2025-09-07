import 'package:collection/collection.dart';

import 'package:notes_reminder_app/features/note/domain/domain.dart';

/// Retrieves a single [Note] by id using the [NoteRepository].
class GetNoteById {
  final GetNotes _getNotes;

  GetNoteById(NoteRepository repository)
      : _getNotes = GetNotes(repository);

  Future<Note?> call(String id) async {
    final notes = await _getNotes();
    return notes.firstWhereOrNull((n) => n.id == id);
  }
}
