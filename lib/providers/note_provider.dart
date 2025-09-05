
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  static const _unsyncedKey = 'unsyncedNoteIds';

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
        _notificationService = notificationService ?? NotificationService() {
    _init();
  }

  List<Note> get notes => List.unmodifiable(_notes);
  String get draft => _draft;

  Future<void> _init() async {
    await _loadUnsyncedNoteIds();
    // Enable Firestore offline persistence for better offline support.
    if (Firebase.apps.isNotEmpty) {
      _firestore.settings = const Settings(persistenceEnabled: true);
    }
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _syncUnsyncedNotes();
      }
    });
  }

  Future<void> _loadUnsyncedNoteIds() async {
    final prefs = await SharedPreferences.getInstance();
    _unsyncedNoteIds
        .addAll(prefs.getStringList(_unsyncedKey) ?? const <String>[]);
  }

  Future<void> _saveUnsyncedNoteIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_unsyncedKey, _unsyncedNoteIds.toList());
  }

  Future<void> _syncUnsyncedNotes() async {
    if (_unsyncedNoteIds.isEmpty || Firebase.apps.isEmpty) return;
    try {
      final user = _auth.currentUser ?? await _auth.signInAnonymously();
      final ids = List<String>.from(_unsyncedNoteIds);
      for (final id in ids) {
        Note? note;
        try {
          note = _notes.firstWhere((n) => n.id == id);
        } catch (_) {
          note = null;
        }
        if (note != null) {
          final data = await _repository.encryptNote(note);
          data['userId'] = user.uid;
          await _firestore.collection('notes').doc(id).set(data);
        } else {
          await _firestore.collection('notes').doc(id).delete();
        }
        _unsyncedNoteIds.remove(id);
      }
      await _saveUnsyncedNoteIds();
    } catch (e, st) {
      debugPrint('syncUnsyncedNotes error: $e\n$st');
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }


  Future<bool> loadNotes() async {
    _notes = await _repository.getNotes();
    await _loadUnsyncedNoteIds();
    final existingUnsynced = Set<String>.from(_unsyncedNoteIds);
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
        _unsyncedNoteIds.addAll(existingUnsynced);
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
    await _saveUnsyncedNoteIds();
    notifyListeners();
    return success;
  }


  Future<void> addNote(Note note) async {
    _notes.add(note);
    await _repository.saveNotes(_notes);
    notifyListeners();
    if (Firebase.apps.isNotEmpty) {
      try {
        final user = _auth.currentUser ?? await _auth.signInAnonymously();
        final data = await _repository.encryptNote(note);
        data['userId'] = user.uid;
        await _firestore.collection('notes').doc(note.id).set(data);
      } catch (e) {
        _unsyncedNoteIds.add(note.id);
        await _saveUnsyncedNoteIds();
      }
    } else {
      _unsyncedNoteIds.add(note.id);
      await _saveUnsyncedNoteIds();
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
        try {
          final user = _auth.currentUser ?? await _auth.signInAnonymously();
          final data = await _repository.encryptNote(updated);
          data['userId'] = user.uid;
          await _firestore.collection('notes').doc(updated.id).set(data);
        } catch (e) {
          _unsyncedNoteIds.add(updated.id);
        }
      } else {
        _unsyncedNoteIds.add(updated.id);
      }
      await _saveUnsyncedNoteIds();
      return true;
    } catch (e) {
      _unsyncedNoteIds.add(note.id);
      await _saveUnsyncedNoteIds();
      return false;
    }
  }

  Future<bool> saveNote(Note note, AppLocalizations l10n) async {
    try {
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index == -1) return false;
      _notes[index] = note;
      await _repository.saveNotes(_notes);
      notifyListeners();
      if (Firebase.apps.isNotEmpty) {
        try {
          final user = _auth.currentUser ?? await _auth.signInAnonymously();
          final data = await _repository.encryptNote(note);
          data['userId'] = user.uid;
          await _firestore.collection('notes').doc(note.id).set(data);
        } catch (e) {
          _unsyncedNoteIds.add(note.id);
        }
      } else {
        _unsyncedNoteIds.add(note.id);
      }
      await _saveUnsyncedNoteIds();
      return true;
    } catch (e) {
      _unsyncedNoteIds.add(note.id);
      await _saveUnsyncedNoteIds();
      return false;
    }
  }

  Future<void> removeNoteAt(int index) async {
    final note = _notes.removeAt(index);
    await _repository.saveNotes(_notes);
    notifyListeners();
    if (Firebase.apps.isNotEmpty) {
      try {
        await _firestore.collection('notes').doc(note.id).delete();
      } catch (e) {
        _unsyncedNoteIds.add(note.id);
      }
    } else {
      _unsyncedNoteIds.add(note.id);
    }
    await _saveUnsyncedNoteIds();
  }

  void setDraft(String value) {
    _draft = value;
    notifyListeners();
  }
}

