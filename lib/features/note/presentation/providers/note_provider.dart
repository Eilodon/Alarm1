import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/entities/note.dart';
import '../../domain/usecases/note_use_cases.dart';

int _noteComparator(Note a, Note b) {
  if (a.pinned != b.pinned) {
    return a.pinned ? -1 : 1;
  }
  return (b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
      .compareTo(a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0));
}

class NoteProvider extends ChangeNotifier {
  final NoteUseCases _useCases;
  final SplayTreeSet<Note> _notes = SplayTreeSet<Note>(_noteComparator);
  String _draft = '';

  ValueNotifier<SyncStatus> get syncStatus => _useCases.syncService.syncStatus;
  Set<String> get unsyncedNoteIds => _useCases.syncService.unsyncedNoteIds;
  bool isSynced(String id) => _useCases.syncService.isSynced(id);

  NoteProvider({NoteUseCases? useCases})
      : _useCases = useCases ?? NoteUseCases.defaultInstance() {
    unawaited(_useCases.syncService.init(_getNoteById));
  }

  List<Note> get notes => List.unmodifiable(_notes);
  String get draft => _draft;

  Note? _getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _useCases.syncService.dispose();
    unawaited(_useCases.backupNow());
    super.dispose();
  }

  Future<bool> loadNotes() async {
    final success = await _useCases.loadNotes(_notes);
    notifyListeners();
    return success;
  }

  Future<bool> backupNow() {
    return _useCases.backupNow();
  }

  Future<List<Note>> fetchNotesPage(DateTime? startAfter, int limit) async {
    final result = await _useCases.fetchNotesPage(_notes, startAfter, limit);
    notifyListeners();
    return result;
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
    int color = 0xFFFFFFFF,
    bool pinned = false,
    required AppLocalizations l10n,
  }) async {
    final result = await _useCases.createNote(
      notes: _notes,
      title: title,
      content: content,
      tags: tags,
      locked: locked,
      alarmTime: alarmTime,
      repeatInterval: repeatInterval,
      daily: daily,
      snoozeMinutes: snoozeMinutes,
      color: color,
      pinned: pinned,
      l10n: l10n,
    );
    notifyListeners();
    return result;
  }

  Future<void> addNote(Note note) async {
    await _useCases.addNote(note, _notes);
    notifyListeners();
  }

  Future<bool> updateNote(Note note, AppLocalizations l10n) async {
    final result = await _useCases.updateNote(note, _notes, l10n);
    notifyListeners();
    return result;
  }

  Future<void> snoozeNote(Note note, AppLocalizations l10n) async {
    await _useCases.snoozeNote(note, l10n);
  }

  Future<bool> saveNote(Note note, AppLocalizations l10n) {
    return updateNote(note, l10n);
  }

  Future<void> removeNoteAt(int index) async {
    await _useCases.removeNoteAt(index, _notes);
    notifyListeners();
  }

  void setDraft(String value) {
    _draft = value;
    notifyListeners();
  }
}
