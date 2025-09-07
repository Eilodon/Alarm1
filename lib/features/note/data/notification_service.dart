import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:alarm_domain/alarm_domain.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin _fln =
      fln.FlutterLocalNotificationsPlugin();

  Future<void> init({
    Future<void> Function(fln.NotificationResponse)?
        onDidReceiveNotificationResponse,
  }) async {
    tzdata.initializeTimeZones();
    final tzName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName));

    const androidSettings = fln.AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = fln.DarwinInitializationSettings();
    const settings = fln.InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _fln.initialize(
      settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    final androidImpl = _fln
        .resolvePlatformSpecificImplementation<
          fln.AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.requestNotificationsPermission();

    await _fln
        .resolvePlatformSpecificImplementation<
          fln.IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required AppLocalizations l10n,
    required String payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      throw ArgumentError('scheduledDate must be in the future');
    }

    final androidDetails = fln.AndroidNotificationDetails(
      'scheduled_channel',
      l10n.scheduled,
      channelDescription: l10n.scheduledDesc,
      importance: Importance.max,
      priority: Priority.high,
      actions: [
        fln.AndroidNotificationAction(
          'done',
          l10n.done,
          showsUserInterface: false,
          cancelNotification: true,
        ),
        fln.AndroidNotificationAction(
          'snooze',
          l10n.snooze,
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    final details = fln.NotificationDetails(android: androidDetails);

    try {
      await _fln.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:
            null, // Không còn dùng uiLocalNotificationDateInterpretation
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> scheduleRecurring({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    required AppLocalizations l10n,
  }) async {
    final androidDetails = fln.AndroidNotificationDetails(
      'recurring_channel',
      l10n.recurring,
      channelDescription: l10n.recurringDesc,
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = fln.DarwinNotificationDetails();
    final details = fln.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _fln.periodicallyShow(
        id,
        title,
        body,
        _mapRepeatInterval(repeatInterval),
        details,
        androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error scheduling recurring notification: $e');
    }
  }

  Future<void> scheduleDailyAtTime({
    required int id,
    required String title,
    required String body,
    required fln.Time time,
    required AppLocalizations l10n,
  }) async {
    final androidDetails = fln.AndroidNotificationDetails(
      'daily_channel',
      l10n.daily,
      channelDescription: l10n.dailyDesc,
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = fln.DarwinNotificationDetails();
    final details = fln.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = _nextInstanceOfTime(time);
    if (scheduledDate.isBefore(DateTime.now())) {
      throw ArgumentError('scheduledDate must be in the future');
    }

    try {
      await _fln.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: fln.DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling daily notification: $e');
    }
  }

  /// Finds the next instance of [time] in the local timezone.
  tz.TZDateTime _nextInstanceOfTime(fln.Time time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  fln.RepeatInterval _mapRepeatInterval(RepeatInterval interval) {
    switch (interval) {
      case RepeatInterval.everyMinute:
        return fln.RepeatInterval.everyMinute;
      case RepeatInterval.hourly:
        return fln.RepeatInterval.hourly;
      case RepeatInterval.daily:
        return fln.RepeatInterval.daily;
      case RepeatInterval.weekly:
        return fln.RepeatInterval.weekly;
    }
  }

  Future<void> snoozeNotification({
    required int id,
    required String title,
    required String body,
    required int minutes,
    required AppLocalizations l10n,
    required String payload,
  }) async {
    await _fln.cancel(id);

    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(minutes: minutes));

    final androidDetails = fln.AndroidNotificationDetails(
      'snooze_channel',
      l10n.snooze,
      channelDescription: l10n.snoozeDesc,
      importance: Importance.max,
      priority: Priority.high,
      actions: [
        fln.AndroidNotificationAction(
          'done',
          l10n.done,
          showsUserInterface: false,
          cancelNotification: true,
        ),
        fln.AndroidNotificationAction(
          'snooze',
          l10n.snooze,
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    final details = fln.NotificationDetails(android: androidDetails);

    await _fln.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
      payload: payload,
    );
  }

  Future<void> cancel(int id) {
    return _fln.cancel(id);
  }
}
