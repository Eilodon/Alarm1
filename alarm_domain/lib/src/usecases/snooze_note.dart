import '../entities/note.dart';
import '../services/notification_service.dart';

/// Triggers a snooze on the note's notification.
class SnoozeNote {
  final NotificationService _notificationService;

  SnoozeNote(NotificationService notificationService)
      : _notificationService = notificationService;

  Future<void> call(Note note, dynamic l10n) async {
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
}
