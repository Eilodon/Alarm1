import '../entities/repeat_interval.dart';

abstract class NotificationService {
  Future<void> init({Future<void> Function(dynamic response)? onDidReceiveNotificationResponse});

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required dynamic l10n,
    required String payload,
  });

  Future<void> scheduleRecurring({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    required dynamic l10n,
  });

  Future<void> scheduleDailyAtTime({
    required int id,
    required String title,
    required String body,
    required dynamic time,
    required dynamic l10n,
  });

  Future<void> cancel(int id);

  Future<void> snoozeNotification({
    required int id,
    required String title,
    required String body,
    required int minutes,
    required dynamic l10n,
    required String payload,
  });
}
