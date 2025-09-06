
import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';
import '../services/note_repository.dart';
import '../services/calendar_service.dart';
import '../services/notification_service.dart';

int _noteComparator(Note a, Note b) {
  if (a.pinned != b.pinned) {
    return b.pinned ? 1 : -1;
  }
  if (a.done != b.done) {
    return a.done ? 1 : -1;
  }
  return (b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
      .compareTo(a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0));
}

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CalendarService _calendarService;
  final NotificationService _notificationService;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  SharedPreferences? _prefs;

  static const _unsyncedKey = 'unsyncedNoteIds';

  final SplayTreeSet<Note> _notes = SplayTreeSet<Note>(_noteComparator);
  String _draft = '';
  final Set<String> _unsyncedNoteIds = {};

  Set<String> get unsyncedNoteIds => Set.unmodifiable(_unsyncedNoteIds);
  bool isSynced(String id) => !_unsyncedNoteIds.contains(id);

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
    _prefs = await SharedPreferences.getInstance();
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
    _unsyncedNoteIds
        .addAll(_prefs!.getStringList(_unsyncedKey) ?? const <String>[]);
    notifyListeners();
  }

  Future<void> _saveUnsyncedNoteIds() async {
    await _prefs!.setStringList(_unsyncedKey, _unsyncedNoteIds.toList());
  }

  Future<void> _syncUnsyncedNotes() async {
    if (_unsyncedNoteIds.isEmpty || Firebase.apps.isEmpty) return;
    try {
      final user = _auth.currentUser ?? await _auth.signInAnonymously();
      final ids = List<String>.from(_unsyncedNoteIds);
      WriteBatch batch = _firestore.batch();
      for (final id in ids) {
        Note? note;
        try {
          note = _notes.firstWhere((n) => n.id == id);
        } catch (_) {
          note = null;
        }
        final docRef = _firestore.collection('notes').doc(id);
        if (note != null) {
          final data = await _repository.encryptNote(note);
          data['userId'] = user.uid;
          batch.set(docRef, data);
        } else {
          batch.delete(docRef);
        }
        _unsyncedNoteIds.remove(id);
      }
      await batch.commit();
      await _saveUnsyncedNoteIds();
      notifyListeners();
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
    _notes..clear();
    _notes.addAll(await _repository.getNotes());
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
        _notes..clear();
        _notes.addAll(map.values);
        await _repository.saveNotes(_notes.toList());
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
        _notes..clear();
        _notes.addAll(originalNotes);
        success = false;
      }
    }
    await _saveUnsyncedNoteIds();
    notifyListeners();
    return success;
  }

  Future<List<Note>> fetchNotesPage(DateTime? startAfter, int limit) async {
    if (_notes.isEmpty && startAfter == null) {
      _notes.addAll(await _repository.getNotes());
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
      try {
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
        _notes..clear();
        _notes.addAll(map.values);
        await _repository.saveNotes(_notes.toList());
      } catch (e, st) {
        debugPrint('fetchNotesPage error: $e\n$st');
        if (_notes.isEmpty) {
          return [];
        }
      }
    }

    final page = _notes
        .where((n) => startAfter == null
            ? true
            : (n.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                .isBefore(startAfter))
        .take(limit)
        .toList();
    notifyListeners();
    return page;
  }


  Future<bool> createNote({
    required String title,
    required String content,
    List<String> tags = const [],
    bool locked = false,
    DateTime? alarmTime,
    RepeatInterval? repeatInterval,
    bool daily = false,
    int snoozeMinutes = 0,
    required AppLocalizations l10n,
  }) async {
    try {
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      int? notificationId;
      String? eventId;
      if (alarmTime != null) {
        notificationId =
            DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
        if (repeatInterval != null) {
          await _notificationService.scheduleRecurring(
            id: notificationId,
            title: title,
            body: content,
            repeatInterval: repeatInterval,
            l10n: l10n,
          );
        } else if (daily) {
          await _notificationService.scheduleDailyAtTime(
            id: notificationId,
            title: title,
            body: content,
            time: Time(alarmTime.hour, alarmTime.minute, alarmTime.second),
            l10n: l10n,
          );
        } else {
          await _notificationService.scheduleNotification(
            id: notificationId,
            title: title,
            body: content,
            scheduledDate: alarmTime,
            l10n: l10n,
          );
        }
        eventId = await _calendarService.createEvent(
          title: title,
          description: content,
          start: alarmTime,
        );
      }

      final note = Note(
        id: id,
        title: title,
        content: content,
        tags: tags,
        locked: locked,
        alarmTime: alarmTime,
        repeatInterval: repeatInterval,
        daily: daily,
        snoozeMinutes: snoozeMinutes,
        active: alarmTime != null,
        notificationId: notificationId,
        eventId: eventId,
        updatedAt: DateTime.now(),
      );

      await addNote(note);
      return true;
    } catch (e) {
      return false;
    }
  }


  Future<void> addNote(Note note) async {
    _notes.add(note);
    await _repository.saveNotes(_notes.toList());
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
        notifyListeners();
      }
    } else {
      _unsyncedNoteIds.add(note.id);
      await _saveUnsyncedNoteIds();
      notifyListeners();
    }
  }

  Future<bool> updateNote(Note note, AppLocalizations l10n) async {
    try {
      Note old;
      try {
        old = _notes.firstWhere((n) => n.id == note.id);
      } catch (_) {
        return false;
      }
      var updated = note;

      // Handle calendar events
      if (old.eventId != null && note.alarmTime == null) {
        await _calendarService.deleteEvent(old.eventId!);
        updated = updated.copyWith(eventId: null);
      } else if (note.alarmTime != null) {
        if (old.eventId == null) {
          final eventId = await _calendarService.createEvent(
            title: note.title,
            description: note.content,
            start: note.alarmTime!,
          );
          updated = updated.copyWith(eventId: eventId);
        } else {
          await _calendarService.updateEvent(
            old.eventId!,
            title: note.title,
            description: note.content,
            start: note.alarmTime!,
          );
          updated = updated.copyWith(eventId: old.eventId);
        }
      }

      // Handle notifications
      if (old.notificationId != null &&
          (note.alarmTime == null || old.notificationId != note.notificationId)) {
        await _notificationService.cancel(old.notificationId!);
      }

      if (note.alarmTime != null) {
        final nid = note.notificationId ??
            DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
        if (note.repeatInterval != null) {
          await _notificationService.scheduleRecurring(
            id: nid,
            title: note.title,
            body: note.content,
            repeatInterval: note.repeatInterval!,
            l10n: l10n,
          );
        } else if (note.daily) {
          await _notificationService.scheduleDailyAtTime(
            id: nid,
            title: note.title,
            body: note.content,
            time: Time(
              note.alarmTime!.hour,
              note.alarmTime!.minute,
              note.alarmTime!.second,
            ),
            l10n: l10n,
          );
        } else {
          await _notificationService.scheduleNotification(
            id: nid,
            title: note.title,
            body: note.content,
            scheduledDate: note.alarmTime!,
            l10n: l10n,
          );
        }
        updated = updated.copyWith(notificationId: nid, active: true);
      } else {
        updated = updated.copyWith(notificationId: null, active: false);
      }

      _notes.remove(old);
      _notes.add(updated);
      await _repository.saveNotes(_notes.toList());
      notifyListeners();
      if (Firebase.apps.isNotEmpty) {
        try {
          final user = _auth.currentUser ?? await _auth.signInAnonymously();
          final data = await _repository.encryptNote(updated);
          data['userId'] = user.uid;
          await _firestore.collection('notes').doc(updated.id).set(data);
        } catch (e) {
          _unsyncedNoteIds.add(updated.id);
          notifyListeners();
        }
      } else {
        _unsyncedNoteIds.add(updated.id);
        notifyListeners();
      }
      await _saveUnsyncedNoteIds();
      return true;
    } catch (e) {
      _unsyncedNoteIds.add(note.id);
      await _saveUnsyncedNoteIds();
      notifyListeners();
      return false;
    }
  }

  Future<void> snoozeNote(Note note, AppLocalizations l10n) async {
    if (note.notificationId == null) return;
    await _notificationService.snoozeNotification(
      id: note.notificationId!,
      title: note.title,
      body: note.content,
      minutes: note.snoozeMinutes,
      l10n: l10n,
    );
  }

  Future<bool> saveNote(Note note, AppLocalizations l10n) {
    return updateNote(note, l10n);
  }

  Future<void> removeNoteAt(int index) async {
    final note = _notes.elementAt(index);
    _notes.remove(note);
    if (note.notificationId != null) {
      await _notificationService.cancel(note.notificationId!);
    }
    if (note.eventId != null) {
      await _calendarService.deleteEvent(note.eventId!);
    }
    await _repository.saveNotes(_notes.toList());
    notifyListeners();
    if (Firebase.apps.isNotEmpty) {
      try {
        await _firestore.collection('notes').doc(note.id).delete();
      } catch (e) {
        _unsyncedNoteIds.add(note.id);
        notifyListeners();
      }
    } else {
      _unsyncedNoteIds.add(note.id);
      notifyListeners();
    }
    await _saveUnsyncedNoteIds();
  }

  void setDraft(String value) {
    _draft = value;
    notifyListeners();
  }
}

