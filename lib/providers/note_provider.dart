import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../services/note_repository.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository;
  List<Note> _notes = [];

  NoteProvider({NoteRepository? repository})
      : _repository = repository ?? NoteRepository();

  List<Note> get notes => List.unmodifiable(_notes);


  Future<void> loadNotes() async {
    _notes = await _repository.getNotes();
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    await _repository.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      await _repository.saveNotes(_notes);
      notifyListeners();
    }
  }


  Future<void> removeNoteAt(int index) async {
    _notes.removeAt(index);
    await _repository.saveNotes(_notes);
    notifyListeners();
  }
}
