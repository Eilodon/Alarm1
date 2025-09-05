
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';
import '../services/note_repository.dart';
import '../services/calendar_service.dart';
import '../services/notification_service.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository;
  final CalendarService _calendarService;
  final NotificationService _notificationService;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Note> _notes = [];
  String _draft = '';

  NoteProvider({
    NoteRepository? repository,
    CalendarService? calendarService,
    NotificationService? notificationService,
  })  : _repository = repository ?? NoteRepository(),
        _calendarService = calendarService ?? CalendarService.instance,
        _notificationService = notificationService ?? NotificationService();

  List<Note> get notes => List.unmodifiable(_notes);
  String get draft => _draft;


  Future<bool> loadNotes() async {
    _notes = await _repository.getNotes();
    var success = true;
    if (Firebase.apps.isNotEmpty) {
      final originalNotes = List<Note>.from(_notes);
      try {
        final user = _auth.currentUser ?? await _auth.signInAnonymously();
        final snapshot = await _firestore
            .collection('notes')
            .where('userId', isEqualTo: user.uid)
            .get();
        final remoteIds = snapshot.docs.map((d) => d.id).toList();
        final remoteNotes = await Future.wait(
          snapshot.docs.map((d) => _repository.decryptNote(d.data())),
        );
        final map = {for (var n in _notes) n.id: n};
        for (final n in remoteNotes) {
          final local = map[n.id];
          if (local == null) {
            map[n.id] = n;
          } else {
            final localUpdated =
                local.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final remoteUpdated =
                n.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            if (remoteUpdated.isAfter(localUpdated)) {
              map[n.id] = n;
            }
          }
        }
        map.removeWhere((key, _) => !remoteIds.contains(key));
        _notes = map.values.toList();
        await _repository.saveNotes(_notes);
      } catch (e, st) {
        debugPrint('loadNotes error: $e\n$st');
        _notes = originalNotes;
        success = false;
      }
    }
    notifyListeners();
    return success;
  }

  Future<void> createNote({
    required String title,
    required String content,
    required AppLocalizations l10n,
    List<String> tags = const [],
    bool locked = false,
    DateTime? alarmTime,
  }) async {
    final noteId = const Uuid().v4();
    final notificationId =
        alarmTime != null ? DateTime.now().millisecondsSinceEpoch : null;

    final note = Note(
      id: noteId,
      title: title,
      content: content,
      summary: '',
      actionItems: const [],
      dates: const [],
      alarmTime: alarmTime,
      locked: locked,
      tags: tags,
      updatedAt: DateTime.now(),
      notificationId: notificationId,
    );

    final ok = await addNote(note);

    if (ok && alarmTime != null && notificationId != null) {
      await _notificationService.scheduleNotification(
        id: notificationId,
        title: title,
        body: content,
        scheduledDate: alarmTime,
        l10n: l10n,
      );
    }
  }
  
  Future<bool> addNote(Note note) async {
    try {
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
        final data = await _repository.encryptNote(toSave);
        data['userId'] = user.uid;
        await _firestore.collection('notes').doc(toSave.id).set(data);
      }
      return true;
    } catch (e, st) {
      debugPrint('addNote error: $e\n$st');
      return false;
    }
  }

  Future<bool> updateNote(Note note) async {
    try {
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index == -1) return false;
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
        final data = await _repository.encryptNote(updated);
        data['userId'] = user.uid;
        await _firestore.collection('notes').doc(updated.id).set(data);
      }
      return true;
    } catch (e, st) {
      debugPrint('updateNote error: $e\n$st');
      return false;
    }
  }

  Future<bool> removeNoteAt(int index) async {
    try {
      final note = _notes.removeAt(index);
      await _repository.saveNotes(_notes);
      notifyListeners();
      if (note.notificationId != null) {
        await _notificationService.cancel(note.notificationId!);
      }
      if (note.eventId != null) {
        await _calendarService.deleteEvent(note.eventId!);
      }
      if (Firebase.apps.isNotEmpty) {
        await _firestore.collection('notes').doc(note.id).delete();
      }
      return true;
    } catch (e, st) {
      debugPrint('removeNoteAt error: $e\n$st');
      return false;
    }
  }

  void setDraft(String value) {
    _draft = value;
    notifyListeners();
  }
}

