
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';
import '../services/note_repository.dart';
import '../services/calendar_service.dart';
import '../services/notification_service.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final CalendarService _calendarService;
  final NotificationService _notificationService;

  List<Note> _notes = [];
  String _draft = '';
  final Set<String> _unsyncedNoteIds = {};

  Set<String> get unsyncedNoteIds => Set.unmodifiable(_unsyncedNoteIds);

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
    _unsyncedNoteIds.clear();
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
        for (final id in map.keys) {
          if (!remoteIds.contains(id)) {
            _unsyncedNoteIds.add(id);
          }
        }
        _notes = map.values.toList();
        await _repository.saveNotes(_notes);
        if (remoteIds.isEmpty && _notes.isNotEmpty) {
          for (final n in _notes) {
            final data = await _repository.encryptNote(n);
            data['userId'] = user.uid;
            await _firestore.collection('notes').doc(n.id).set(data);
          }
          _unsyncedNoteIds.clear();
        }
      } catch (e, st) {
        debugPrint('loadNotes error: $e\n$st');
        _notes = originalNotes;
        success = false;
      }
    }
    notifyListeners();
    return success;
  }

  Future<List<Note>> fetchNotesPage(DateTime? startAfter, int limit) async {
    if (_notes.isEmpty && startAfter == null) {
      _notes = await _repository.getNotes();
    }

    if (Firebase.apps.isNotEmpty) {
      final user = _auth.currentUser ?? await _auth.signInAnonymously();
      var query = _firestore
          .collection('notes')
          .where('userId', isEqualTo: user.uid)
          .orderBy('updatedAt', descending: true)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfter([startAfter.toIso8601String()]);
      }
      final snapshot = await query.get();
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
      _notes = map.values.toList()
        ..sort((a, b) => (b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
      await _repository.saveNotes(_notes);
    }

    final sorted = _notes.toList()
      ..sort((a, b) => (b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
    final page = sorted
        .where((n) => startAfter == null
            ? true
            : (n.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                .isBefore(startAfter))
        .take(limit)
        .toList();
    notifyListeners();
    return page;
  }


  Future<void> addNote(Note note) async {
    _notes.add(note);
    _notes.sort((a, b) => (b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
    await _repository.saveNotes(_notes);
    notifyListeners();
    if (Firebase.apps.isNotEmpty) {
      final user = _auth.currentUser ?? await _auth.signInAnonymously();
      final data = await _repository.encryptNote(note);
      data['userId'] = user.uid;
      await _firestore.collection('notes').doc(note.id).set(data);

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

        final data = await _repository.encryptNote(note);
        data['userId'] = user.uid;
        await _firestore.collection('notes').doc(note.id).set(data);
      }

    }
  }

  Future<bool> saveNote(Note note, AppLocalizations l10n) async {
    try {
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index == -1) return false;


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

