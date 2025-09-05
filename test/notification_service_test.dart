import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui';
import 'package:notes_reminder_app/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dexterx.dev/flutter_local_notifications');
  final List<MethodCall> log = [];

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall call) async {
      log.add(call);
      return null;
    });
    log.clear();
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('init initializes plugin', () async {
    await NotificationService().init();
    expect(log.any((c) => c.method == 'initialize'), isTrue);
  });

  test('scheduleNotification schedules notification', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final service = NotificationService();
    await service.scheduleNotification(
      id: 1,
      title: 't',
      body: 'b',
      scheduledDate: DateTime.now().add(const Duration(minutes: 1)),
      l10n: l10n,
    );
    expect(log.any((c) => c.method == 'zonedSchedule'), isTrue);
  });

  test('scheduleDailyAtTime uses tz and localizations', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Detroit'));
    final service = NotificationService();
    await service.scheduleDailyAtTime(
      id: 2,
      title: 't',
      body: 'b',
      time: const Time(10, 0, 0),
      l10n: l10n,
    );
    final call = log.singleWhere((c) => c.method == 'zonedSchedule');
    final args = call.arguments as Map<dynamic, dynamic>;
    expect(args['timeZoneName'], 'America/Detroit');
    final androidDetails = args['androidDetails'] as Map<dynamic, dynamic>;
    expect(androidDetails['channelName'], l10n.daily);
    expect(androidDetails['channelDescription'], l10n.dailyDesc);
  });

  test('scheduleRecurring uses localizations', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final service = NotificationService();
    await service.scheduleRecurring(
      id: 3,
      title: 't',
      body: 'b',
      repeatInterval: RepeatInterval.daily,
      l10n: l10n,
    );
    final call = log.singleWhere((c) => c.method == 'periodicallyShow');
    final args = call.arguments as Map<dynamic, dynamic>;
    final androidDetails = args['androidDetails'] as Map<dynamic, dynamic>;
    expect(androidDetails['channelName'], l10n.recurring);
    expect(androidDetails['channelDescription'], l10n.recurringDesc);
  });
}
