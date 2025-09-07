import 'dart:collection';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../entities/note.dart';
import '../../data/note_repository.dart';
import '../../data/calendar_service.dart';
import '../../data/notification_service.dart';
import '../../data/home_widget_service.dart';
import '../../data/note_sync_service.dart';

class NoteUseCases {
  final NoteRepository repository;
  final CalendarService calendarService;
  final NotificationService notificationService;
  final HomeWidgetService homeWidgetService;
  final NoteSyncService syncService;

  NoteUseCases({
    required this.repository,
    required this.calendarService,
    required this.notificationService,
    required this.homeWidgetService,
    required this.syncService,
  });

  Future<bool> loadNotes(SplayTreeSet<Note> notes) async {
    syncService.syncStatus.value = SyncStatus.syncing;
    notes..clear();
    notes.addAll(await repository.getNotes());
    final success = await syncService.loadFromRemote(notes);
    await homeWidgetService.update(notes.toList());
    syncService.syncStatus.value = success ? SyncStatus.idle : SyncStatus.error;
    return success;
  }

  Future<bool> backupNow() {
    return repository.autoBackup();
  }

  Future<List<Note>> fetchNotesPage(
      SplayTreeSet<Note> notes, DateTime? startAfter, int limit) async {
    if (notes.isEmpty && startAfter == null) {
      notes.addAll(await repository.getNotes());
    }
    final result = <Note>[];
    for (final n in notes) {
      if (startAfter != null) {
        final updated = n.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        if (!updated.isBefore(startAfter)) continue;
      }
      result.add(n);
      if (result.length == limit) break;
    }
    return result;
  }

  Future<void> addNote(
      Note note, SplayTreeSet<Note> notes) async {
    notes.add(note);
    await repository.saveNotes(notes.toList());
    await syncService.syncNote(note);
  }

  Future<bool> createNote({
    required SplayTreeSet<Note> notes,
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
        notificationId = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
        if (repeatInterval != null) {
          await notificationService.scheduleRecurring(
            id: notificationId,
            title: title,
            body: content,
            repeatInterval: repeatInterval,
            l10n: l10n,
          );
        } else if (daily) {
          await notificationService.scheduleDailyAtTime(
            id: notificationId,
            title: title,
            body: content,
            time: Time(alarmTime.hour, alarmTime.minute, alarmTime.second),
            l10n: l10n,
          );
        } else {
          await notificationService.scheduleNotification(
            id: notificationId,
            title: title,
            body: content,
            scheduledDate: alarmTime,
            l10n: l10n,
            payload: id,
          );
        }
        eventId = await calendarService.createEvent(
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

      await addNote(note, notes);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateNote(
      Note note, SplayTreeSet<Note> notes, AppLocalizations l10n) async {
    try {
      Note old;
      try {
        old = notes.firstWhere((n) => n.id == note.id);
      } catch (_) {
        return false;
      }
      var updated = note;
      if (old.eventId != null && note.alarmTime == null) {
        await calendarService.deleteEvent(old.eventId!);
        updated = updated.copyWith(eventId: null);
      } else if (note.alarmTime != null) {
        if (old.eventId == null) {
          final eventId = await calendarService.createEvent(
            title: note.title,
            description: note.content,
            start: note.alarmTime!,
          );
          updated = updated.copyWith(eventId: eventId);
        } else {
          await calendarService.updateEvent(
            old.eventId!,
            title: note.title,
            description: note.content,
            start: note.alarmTime!,
          );
          updated = updated.copyWith(eventId: old.eventId);
        }
      }

      if (old.notificationId != null &&
          (note.alarmTime == null || old.notificationId != note.notificationId)) {
        await notificationService.cancel(old.notificationId!);
      }

      if (note.alarmTime != null) {
        final nid = note.notificationId ??
            DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
        if (note.repeatInterval != null) {
          await notificationService.scheduleRecurring(
            id: nid,
            title: note.title,
            body: note.content,
            repeatInterval: note.repeatInterval!,
            l10n: l10n,
          );
        } else if (note.daily) {
          await notificationService.scheduleDailyAtTime(
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
          await notificationService.scheduleNotification(
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

      notes..remove(old)..add(updated);
      await repository.saveNotes(notes.toList());
      await homeWidgetService.update(notes.toList());
      await syncService.syncNote(updated);
      return true;
    } catch (e) {
      await syncService.markUnsynced(note.id);
      return false;
    }
  }

  Future<void> removeNoteAt(int index, SplayTreeSet<Note> notes) async {
    final note = notes.elementAt(index);
    notes.remove(note);
    if (note.notificationId != null) {
      await notificationService.cancel(note.notificationId!);
    }
    if (note.eventId != null) {
      await calendarService.deleteEvent(note.eventId!);
    }
    await repository.saveNotes(notes.toList());
    await homeWidgetService.update(notes.toList());
    await syncService.deleteNote(note.id);
  }

  Future<void> snoozeNote(Note note, AppLocalizations l10n) async {
    if (note.notificationId == null) return;
    await notificationService.snoozeNotification(
      id: note.notificationId!,
      title: note.title,
      body: note.content,
      minutes: note.snoozeMinutes,
      l10n: l10n,
      payload: note.id,
    );
  }
}
