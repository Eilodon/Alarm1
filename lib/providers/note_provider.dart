
import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/note.dart';
import '../services/note_repository.dart';
import '../services/calendar_service.dart';
import '../services/notification_service.dart';
import '../services/home_widget_service.dart';
import '../services/note_sync_service.dart';


int _noteComparator(Note a, Note b) {
  if (a.pinned != b.pinned) {
    return a.pinned ? -1 : 1;
  }
  return (b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
      .compareTo(a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0));
}



class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository;

  final CalendarService _calendarService;
  final NotificationService _notificationService;
  final HomeWidgetService _homeWidgetService;
  final NoteSyncService _syncService;

  final SplayTreeSet<Note> _notes = SplayTreeSet<Note>(_noteComparator);
  String _draft = '';

  ValueNotifier<SyncStatus> get syncStatus => _syncService.syncStatus;
  Set<String> get unsyncedNoteIds => _syncService.unsyncedNoteIds;
  bool isSynced(String id) => _syncService.isSynced(id);

  NoteProvider({
    NoteRepository? repository,
    CalendarService? calendarService,
    NotificationService? notificationService,
    HomeWidgetService? homeWidgetService,
    NoteSyncService? syncService,
  })  : _repository = repository ?? NoteRepository(),
        _calendarService = calendarService ?? CalendarService.instance,
        _notificationService = notificationService ?? NotificationService(),
        _homeWidgetService = homeWidgetService ?? const HomeWidgetService(),
        _syncService = syncService ?? NoteSyncService(repository: repository) {
    unawaited(_init().catchError((e) { /* log or set error state */ }));
  }

  List<Note> get notes => List.unmodifiable(_notes);
  String get draft => _draft;

  Future<void> _init() async {
    await _syncService.init(_getNoteById);
  }

  Note? _getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _syncService.dispose();
    unawaited(_repository.autoBackup());
    super.dispose();
  }


  Future<bool> loadNotes() async {
    _syncService.syncStatus.value = SyncStatus.syncing;
    _notes..clear();
    _notes.addAll(await _repository.getNotes());
    final success = await _syncService.loadFromRemote(_notes);
    await _homeWidgetService.update(_notes.toList());
    notifyListeners();
    _syncService.syncStatus.value =
        success ? SyncStatus.idle : SyncStatus.error;
    return success;
  }

  Future<bool> backupNow() {
    return _repository.autoBackup();
  }

  Future<List<Note>> fetchNotesPage(DateTime? startAfter, int limit) async {
    if (_notes.isEmpty && startAfter == null) {
      _notes.addAll(await _repository.getNotes());
    }

    final result = <Note>[];
    for (final n in _notes) {
      if (startAfter != null) {
        final updated =
            n.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        if (!updated.isBefore(startAfter)) continue;
      }
      result.add(n);
      if (result.length == limit) break;
    }
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
            payload: id,
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
        color: color,
        pinned: pinned,
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
    await _syncService.syncNote(note);
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
            payload: note.id,
          );
        }
        updated = updated.copyWith(notificationId: nid, active: true);
      } else {
        updated = updated.copyWith(notificationId: null, active: false);
      }

      _notes.remove(old);
      _notes.add(updated);
      await _repository.saveNotes(_notes.toList());
      await _homeWidgetService.update(_notes.toList());
      notifyListeners();
      await _syncService.syncNote(updated);
      return true;
    } catch (e) {
      await _syncService.markUnsynced(note.id);
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
      payload: note.id,
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
    await _homeWidgetService.update(_notes.toList());
    notifyListeners();
    await _syncService.deleteNote(note.id);
  }

  void setDraft(String value) {
    _draft = value;
    notifyListeners();
  }
}

