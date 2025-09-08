import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:notes_reminder_app/features/note/domain/domain.dart';
import 'package:alarm_data/alarm_data.dart';

class NoteSyncServiceImpl implements NoteSyncService {
  final NoteRepository _repository;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  SharedPreferences? _prefs;

  static const _unsyncedKey = 'unsyncedNoteIds';

  final Set<String> _unsyncedNoteIds = {};
  final _statusController = StreamController<SyncStatus>.broadcast();
  @override
  Stream<SyncStatus> get syncStatus => _statusController.stream;

  NoteGetter? _noteGetter;

  NoteSyncServiceImpl({
    NoteRepository? repository,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Connectivity? connectivity,
  })  : _repository = repository ?? NoteRepositoryImpl(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _connectivity = connectivity ?? Connectivity();

  @override
  Set<String> get unsyncedNoteIds => Set.unmodifiable(_unsyncedNoteIds);
  @override
  bool isSynced(String id) => !_unsyncedNoteIds.contains(id);

  @override
  void setSyncStatus(SyncStatus status) {
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  @override
  Future<void> init(NoteGetter noteGetter) async {
    _noteGetter = noteGetter;
    _prefs = await SharedPreferences.getInstance();
    _unsyncedNoteIds
        .addAll(_prefs!.getStringList(_unsyncedKey) ?? const <String>[]);
    if (Firebase.apps.isNotEmpty) {
      _firestore.settings = const Settings(persistenceEnabled: true);
    }
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        syncUnsyncedNotes();
      }
    });
  }

  @override
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _statusController.close();
  }

  Future<void> _saveUnsyncedNoteIds() async {
    await _prefs!.setStringList(_unsyncedKey, _unsyncedNoteIds.toList());
  }

  Future<User?> _getUser() async {
    User? user = _auth.currentUser;
    if (user != null) return user;
    try {
      return (await _auth.signInAnonymously()).user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> markUnsynced(String id) async {
    _unsyncedNoteIds.add(id);
    await _saveUnsyncedNoteIds();
  }

  @override
  Future<void> syncNote(Note note) async {
    if (Firebase.apps.isEmpty) {
      await markUnsynced(note.id);
      return;
    }
    try {
      final user = await _getUser();
      if (user == null) {
        await markUnsynced(note.id);
        setSyncStatus(SyncStatus.error);
        return;
      }
      final data = await _repository.encryptNote(note);
      data['userId'] = user.uid;
      await _firestore.collection('notes').doc(note.id).set(data);
      _unsyncedNoteIds.remove(note.id);
      await _saveUnsyncedNoteIds();
    } catch (e, st) {
      debugPrint('Failed to sync note ${note.id}: $e\n$st');
      await markUnsynced(note.id);
      setSyncStatus(SyncStatus.error);
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    if (Firebase.apps.isEmpty) {
      await markUnsynced(id);
      return;
    }
    try {
      await _firestore.collection('notes').doc(id).delete();
      _unsyncedNoteIds.remove(id);
      await _saveUnsyncedNoteIds();
    } catch (e, st) {
      debugPrint('Failed to delete note $id: $e\n$st');
      await markUnsynced(id);
      setSyncStatus(SyncStatus.error);
    }
  }

  @override
  Future<void> syncUnsyncedNotes() async {
    if (_unsyncedNoteIds.isEmpty || Firebase.apps.isEmpty) return;
    setSyncStatus(SyncStatus.syncing);
    try {
      final user = await _getUser();
      if (user == null) {
        setSyncStatus(SyncStatus.error);
        return;
      }
      final ids = List<String>.from(_unsyncedNoteIds);
      final batch = _firestore.batch();
      for (final id in ids) {
        final note = _noteGetter?.call(id);
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
      setSyncStatus(SyncStatus.idle);
    } catch (e, st) {
      debugPrint('Failed to sync unsynced notes: $e\n$st');
      setSyncStatus(SyncStatus.error);
    }
  }

  @override
  Future<bool> loadFromRemote(Set<Note> notes) async {
    final existingUnsynced = Set<String>.from(_unsyncedNoteIds);
    _unsyncedNoteIds.clear();
    var success = true;
    if (Firebase.apps.isNotEmpty) {
      final originalNotes = List<Note>.from(notes);
      try {
        final user = await _getUser();
        if (user == null) {
          throw Exception('No user available');
        }
        final snapshot = await _firestore
            .collection('notes')
            .where('userId', isEqualTo: user.uid)
            .get();
        final remoteIds = snapshot.docs.map((d) => d.id).toList();
        final remoteNotes = await Future.wait(
          snapshot.docs.map((d) => _repository.decryptNote(d.data())),
        );
        final map = {for (var n in notes) n.id: n};
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
        notes
          ..clear()
          ..addAll(map.values);
        await _repository.saveNotes(notes.toList());
        if (remoteIds.isEmpty && notes.isNotEmpty) {
          for (final n in notes) {
            final data = await _repository.encryptNote(n);
            data['userId'] = user.uid;
            await _firestore.collection('notes').doc(n.id).set(data);
          }
          _unsyncedNoteIds.clear();
        }
      } catch (e, st) {
        debugPrint('Failed to load notes from remote: $e\n$st');
        notes
          ..clear()
          ..addAll(originalNotes);
        success = false;
        setSyncStatus(SyncStatus.error);
      }
    } else {
      _unsyncedNoteIds.addAll(existingUnsynced);
    }
    await _saveUnsyncedNoteIds();
    return success;
  }
}
