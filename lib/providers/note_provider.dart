codex/verify-imports-and-clean-up-code
import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../services/note_repository.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository;
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  NoteProvider({NoteRepository? repository})
      : _repository = repository ?? NoteRepository();

  Future<void> loadNotes() async {
    _notes = await _repository.getNotes();
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    await _repository.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> removeNoteAt(int index) async {
    _notes.removeAt(index);
    await _repository.saveNotes(_notes);
    notifyListeners();
  }
}

