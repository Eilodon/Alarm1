 codex/expand-note-model-with-new-fields
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/db_service.dart';

class NoteProvider extends ChangeNotifier {
  final DbService _db = DbService();
  List<Note> _notes = [];
  String _query = '';
  List<String> _filterTags = [];

  List<Note> get notes {
    return _notes.where((n) {
      final q = _query.toLowerCase();
      final matchQuery = q.isEmpty ||
          n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q) ||
          n.tags.any((t) => t.toLowerCase().contains(q));
      final matchTags = _filterTags.isEmpty ||
          _filterTags.every((t) => n.tags.contains(t));
      return matchQuery && matchTags;
    }).toList();
  }

  List<String> get allTags {
    final set = <String>{};
    for (final n in _notes) {
      set.addAll(n.tags);
    }
    return set.toList();
  }

  List<String> get filterTags => _filterTags;

  Future<void> load() async {
    _notes = await _db.getNotes();
    notifyListeners();
  }

  Future<void> save() async {
    await _db.saveNotes(_notes);
    notifyListeners();
  }

  void addNote(Note note) {
    _notes.add(note);
    save();
  }

  void updateNote(Note note) {
    final i = _notes.indexWhere((n) => n.id == note.id);
    if (i != -1) {
      _notes[i] = note;
      save();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    save();
  }

  void setSearchQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setFilterTags(List<String> tags) {
    _filterTags = tags;

    notifyListeners();
  }
}

 codex/expand-note-model-with-new-fields

