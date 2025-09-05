
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../services/note_repository.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Note> _notes = [];
  String _draft = '';

  NoteProvider({NoteRepository? repository})
      : _repository = repository ?? NoteRepository();

  List<Note> get notes => List.unmodifiable(_notes);
  String get draft => _draft;


  Future<void> loadNotes() async {
    _notes = await _repository.getNotes();
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    await _repository.saveNotes(_notes);
    notifyListeners();
    if (Firebase.apps.isNotEmpty) {
      final user = _auth.currentUser ?? await _auth.signInAnonymously();
      final data = await _repository.encryptNote(note);
      data['userId'] = user.uid;
      await _firestore.collection('notes').doc(note.id).set(data);
    }
  }

  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      await _repository.saveNotes(_notes);
      notifyListeners();
      if (Firebase.apps.isNotEmpty) {
        final user = _auth.currentUser ?? await _auth.signInAnonymously();
        final data = await _repository.encryptNote(note);
        data['userId'] = user.uid;
        await _firestore.collection('notes').doc(note.id).set(data);
      }
    }
  }


  Future<void> removeNoteAt(int index) async {
    final note = _notes.removeAt(index);
    await _repository.saveNotes(_notes);
    notifyListeners();
    if (Firebase.apps.isNotEmpty) {
      await _firestore.collection('notes').doc(note.id).delete();
    }
  }

  void setDraft(String value) {
    _draft = value;
    notifyListeners();
  }
}

