
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../services/note_repository.dart';
import '../services/calendar_service.dart';
import '../services/notification_service.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Note> _notes = [];
  String _draft = '';

  NoteProvider({NoteRepository? repository, CalendarService? calendarService})
      : _repository = repository ?? NoteRepository(),
        _calendarService = calendarService ?? CalendarService.instance;

  List<Note> get notes => List.unmodifiable(_notes);
  String get draft => _draft;


  Future<void> loadNotes() async {
    _notes = await _repository.getNotes();
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    var toSave = note;
    if (note.alarmTime != null) {
      final eventId = await _calendarService.createEvent(
        title: note.title,
        description: note.content,
        start: note.alarmTime!,
      );
      toSave = note.copyWith(eventId: eventId);
    }
    _notes.add(toSave);
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
      var updated = note;
      final old = _notes[index];
      if (old.eventId != null && note.alarmTime == null) {
        await _calendarService.deleteEvent(old.eventId!);
        updated = note.copyWith(eventId: null);
      } else if (note.alarmTime != null) {
        if (old.eventId == null) {
          final eventId = await _calendarService.createEvent(
            title: note.title,
            description: note.content,
            start: note.alarmTime!,
          );
          updated = note.copyWith(eventId: eventId);
        } else {
          await _calendarService.updateEvent(
            old.eventId!,
            title: note.title,
            description: note.content,
            start: note.alarmTime!,
          );
          updated = note.copyWith(eventId: old.eventId);
        }
      }
      _notes[index] = updated;
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
    final note = _notes[index];

    if (note.notificationId != null) {
      await NotificationService().cancel(note.notificationId!);
    }
    if (note.eventId != null) {
      await _calendarService.deleteEvent(note.eventId!);
    }

    _notes.removeAt(index);

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

