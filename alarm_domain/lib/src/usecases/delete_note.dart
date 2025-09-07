import '../entities/note.dart';
import '../repositories/note_repository.dart';
import '../services/calendar_service.dart';
import '../services/home_widget_service.dart';
import '../services/note_sync_service.dart';
import '../services/notification_service.dart';

/// Removes a [Note] and performs related cleanup operations.
class DeleteNote {
  final NoteRepository _repository;
  final CalendarService _calendarService;
  final NotificationService _notificationService;
  final HomeWidgetService _homeWidgetService;
  final NoteSyncService _syncService;

  DeleteNote(
    NoteRepository repository,
    CalendarService calendarService,
    NotificationService notificationService,
    HomeWidgetService homeWidgetService,
    NoteSyncService syncService,
  )   : _repository = repository,
        _calendarService = calendarService,
        _notificationService = notificationService,
        _homeWidgetService = homeWidgetService,
        _syncService = syncService;

  /// Removes [note] from storage using the provided [remaining] list and
  /// clears any scheduled reminders.
  Future<void> call(Note note, List<Note> remaining) async {
    if (note.notificationId != null) {
      await _notificationService.cancel(note.notificationId!);
    }
    if (note.eventId != null) {
      await _calendarService.deleteEvent(note.eventId!);
    }
    await _repository.saveNotes(remaining);
    await _homeWidgetService.update(remaining);
    await _syncService.deleteNote(note.id);
  }
}
