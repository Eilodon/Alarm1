import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show Time;

import '../domain/domain.dart';
import 'package:alarm_data/alarm_data.dart';
import '../data/calendar_service.dart';
import '../data/notification_service.dart';
import '../data/home_widget_service.dart';
import '../../backup/data/note_sync_service.dart';

int _noteComparator(Note a, Note b) {
  if (a.pinned != b.pinned) {
    return a.pinned ? -1 : 1;
  }
  final epoch = DateTime.fromMillisecondsSinceEpoch(0);
  final cmp = (b.updatedAt ?? epoch).compareTo(a.updatedAt ?? epoch);
  return cmp != 0 ? cmp : a.id.compareTo(b.id);
}

class NoteProvider extends ChangeNotifier {
  final GetNotes _getNotes;
  final SaveNotes _saveNotes;
  final UpdateNote _updateNote;
  final AutoBackup _autoBackup;
  final NoteRepository _repository;

  final CalendarService _calendarService;
  final NotificationService _notificationService;
  final HomeWidgetService _homeWidgetService;
  final NoteSyncService _syncService;
  final CreateNote _createNote;
  final DeleteNote _deleteNote;
  final SnoozeNote _snoozeNote;

  final SplayTreeSet<Note> _notes = SplayTreeSet<Note>(_noteComparator);
  String _draft = '';

  Stream<SyncStatus> get syncStatus => _syncService.syncStatus;
  Set<String> get unsyncedNoteIds => _syncService.unsyncedNoteIds;
  bool isSynced(String id) => _syncService.isSynced(id);

  NoteProvider._({
    required GetNotes getNotes,
    required SaveNotes saveNotes,
    required UpdateNote updateNote,
    required AutoBackup autoBackup,
    required CalendarService calendarService,
    required NotificationService notificationService,
    required HomeWidgetService homeWidgetService,
    required NoteSyncService syncService,
    required NoteRepository repository,

    CreateNote? createNote,
    DeleteNote? deleteNote,
    SnoozeNote? snoozeNote,
  })  : _getNotes = getNotes,
       _saveNotes = saveNotes,
       _updateNote = updateNote,
       _autoBackup = autoBackup,
       _repository = repository,
       _calendarService = calendarService,
       _notificationService = notificationService,
       _homeWidgetService = homeWidgetService,
       _syncService = syncService,
       _createNote = createNote ?? CreateNote(repository, syncService),
       _deleteNote =
           deleteNote ??
           DeleteNote(
             repository,
             calendarService,
             notificationService,
             homeWidgetService,
             syncService,
           ),
       _snoozeNote = snoozeNote ?? SnoozeNote(notificationService) {
    unawaited(
      _init().catchError((e) {
        /* log or set error state */
      }),
    );
  }

  factory NoteProvider({
    GetNotes? getNotes,
    SaveNotes? saveNotes,
    UpdateNote? updateNote,
    AutoBackup? autoBackup,
    CalendarService? calendarService,
    NotificationService? notificationService,
    HomeWidgetService? homeWidgetService,
    NoteSyncService? syncService,
  }) {
    if (getNotes != null &&
        saveNotes != null &&
        updateNote != null &&
        autoBackup != null &&
        calendarService != null &&
        notificationService != null &&
        homeWidgetService != null &&
        syncService != null) {
      return NoteProvider._(
        getNotes: getNotes,
        saveNotes: saveNotes,
        updateNote: updateNote,
        autoBackup: autoBackup,
        calendarService: calendarService,
        notificationService: notificationService,
        homeWidgetService: homeWidgetService,
        syncService: syncService,
        repository: getNotes.repository,
      );
    }
    final repo = NoteRepositoryImpl();
    return NoteProvider._(
      getNotes: getNotes ?? GetNotes(repo),
      saveNotes: saveNotes ?? SaveNotes(repo),
      updateNote: updateNote ?? UpdateNote(repo),
      autoBackup: autoBackup ?? AutoBackup(repo),
      calendarService: calendarService ?? CalendarServiceImpl.instance,
      notificationService: notificationService ?? NotificationServiceImpl(),
      homeWidgetService: homeWidgetService ?? const HomeWidgetServiceImpl(),
      syncService: syncService ?? NoteSyncServiceImpl(repository: repo),
      repository: repo,
    );
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
    unawaited(_autoBackup());
    super.dispose();
  }

  Future<bool> loadNotes() async {
    _syncService.setSyncStatus(SyncStatus.syncing);
    _notes..clear();
    _notes.addAll(await _getNotes());
    final success = await _syncService.loadFromRemote(_notes);
    await _homeWidgetService.update(_notes.toList());
    notifyListeners();
    _syncService.setSyncStatus(success ? SyncStatus.idle : SyncStatus.error);
    return success;
  }

  Future<bool> backupNow() {
    return _autoBackup();
  }

  Future<List<Note>> fetchNotesPage(DateTime? startAfter, int limit) async {
    if (_notes.isEmpty && startAfter == null) {
      _notes.addAll(await _getNotes());
    }

    final result = <Note>[];
    for (final n in _notes) {
      if (startAfter != null) {
        final updated = n.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
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
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    try {
      int? notificationId;
      String? eventId;
      if (alarmTime != null) {
        notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
          1 << 31,
        );
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
    } catch (e, st) {
      debugPrint('Failed to create note $id: $e\n$st');
      await _syncService.markUnsynced(id);
      notifyListeners();
      return false;
    }
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);

    await _createNote(note, _notes.toList());

    notifyListeners();
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
          (note.alarmTime == null ||
              old.notificationId != note.notificationId)) {
        await _notificationService.cancel(old.notificationId!);
      }

      if (note.alarmTime != null) {
        final nid =
            note.notificationId ??
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
      await _updateNote(updated);
      await _homeWidgetService.update(_notes.toList());
      notifyListeners();
      await _syncService.syncNote(updated);
      return true;
    } catch (e, st) {
      debugPrint('Failed to update note ${note.id}: $e\n$st');
      await _syncService.markUnsynced(note.id);
      notifyListeners();
      return false;
    }
  }

  Future<void> snoozeNote(Note note, AppLocalizations l10n) async {
    await _snoozeNote(note, l10n);
  }

  Future<bool> saveNote(Note note, AppLocalizations l10n) {
    return updateNote(note, l10n);
  }

  Future<void> removeNoteAt(int index) async {
    final note = _notes.elementAt(index);
    _notes.remove(note);

    await _deleteNote(note, _notes.toList());

    notifyListeners();
  }

  void setDraft(String value) {
    _draft = value;
    notifyListeners();
  }
}
