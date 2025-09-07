
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:notes_reminder_app/generated/app_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

import '../domain/domain.dart';

class NotificationServiceImpl implements NotificationService {
  static final NotificationServiceImpl _instance =
      NotificationServiceImpl._internal();
  factory NotificationServiceImpl() => _instance;
  NotificationServiceImpl._internal();

  final fln.FlutterLocalNotificationsPlugin _fln =
      fln.FlutterLocalNotificationsPlugin();

  @override
  Future<void> init({
    Future<void> Function(dynamic response)? onDidReceiveNotificationResponse,
  }) async {
    tzdata.initializeTimeZones();
    final tzName = await FlutterTimezone.getLocalTimezone();
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
      onDidReceiveNotificationResponse:
          onDidReceiveNotificationResponse
              as Future<void> Function(fln.NotificationResponse)?,
    );

    final androidImpl =
        _fln
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

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required dynamic l10n,
    required String payload,
  }) async {
    final loc = l10n as AppLocalizations;
    if (scheduledDate.isBefore(DateTime.now())) {
      throw ArgumentError('scheduledDate must be in the future');
    }

    final androidDetails = fln.AndroidNotificationDetails(
      'scheduled_channel',
      loc.scheduled,
      channelDescription: loc.scheduledDesc,
      importance: fln.AndroidNotificationImportance.max,
      priority: fln.AndroidNotificationPriority.high,
      actions: [
        fln.AndroidNotificationAction(
          'done',
          loc.done,
          showsUserInterface: false,
          cancelNotification: true,
        ),
        fln.AndroidNotificationAction(
          'snooze',
          loc.snooze,
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
        matchDateTimeComponents: null,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  @override
  Future<void> scheduleRecurring({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    required dynamic l10n,
  }) async {
    final loc = l10n as AppLocalizations;
    final androidDetails = fln.AndroidNotificationDetails(
      'recurring_channel',
      loc.recurring,
      channelDescription: loc.recurringDesc,
      importance: fln.AndroidNotificationImportance.max,
      priority: fln.AndroidNotificationPriority.high,
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

  @override
  Future<void> scheduleDailyAtTime({
    required int id,
    required String title,
    required String body,
    required dynamic time,
    required dynamic l10n,
  }) async {
    final t = time as TimeOfDay;
    final loc = l10n as AppLocalizations;
    final androidDetails = fln.AndroidNotificationDetails(
      'daily_channel',
      loc.daily,
      channelDescription: loc.dailyDesc,
      importance: fln.AndroidNotificationImportance.max,
      priority: fln.AndroidNotificationPriority.high,
    );

    const iosDetails = fln.DarwinNotificationDetails();
    final details = fln.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = _nextInstanceOfTime(t);
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

  @override
  Future<void> cancel(int id) async {
    await _fln.cancel(id);
  }

  @override
  Future<void> snoozeNotification({
    required int id,
    required String title,
    required String body,
    required int minutes,
    required dynamic l10n,
    required String payload,
  }) async {
    final loc = l10n as AppLocalizations;
    final scheduledDate = DateTime.now().add(Duration(minutes: minutes));
    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      l10n: loc,
      payload: payload,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      0,
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
}
