import 'package:flutter/foundation.dart';

import '../entities/note.dart';

/// Represents the current synchronization status.
enum SyncStatus { idle, syncing, error }

/// Function signature for retrieving a [Note] by its id.
typedef NoteGetter = Note? Function(String id);

/// Contract for synchronizing notes with a remote backend.
abstract class NoteSyncService {
  ValueNotifier<SyncStatus> get syncStatus;
  Set<String> get unsyncedNoteIds;
  bool isSynced(String id);

  Future<void> init(NoteGetter noteGetter);
  Future<void> dispose();

  Future<void> markUnsynced(String id);
  Future<void> syncNote(Note note);
  Future<void> deleteNote(String id);
  Future<void> syncUnsyncedNotes();
  Future<bool> loadFromRemote(Set<Note> notes);
}
