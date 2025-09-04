import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../repositories/note_repository.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repo = NoteRepository();
  List<Note> _notes = [];
  List<Note> get notes => _notes;

  NoteProvider() {
    loadNotes();
  }

  Future<void> loadNotes() async {
    _notes = await _repo.getNotes();
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await _repo.addNote(note);
    _notes.add(note);
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    await _repo.updateNote(note);
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
    }
  }

  Future<void> removeNote(String id) async {
    await _repo.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}

