import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:notes_reminder_app/features/note/note.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dexterx.dev/flutter_local_notifications');
  final List<MethodCall> log = [];
  final List<String?> debug = [];
  final debugPrintOriginal = debugPrint;

  setUp(() {
    debug.clear();
    debugPrint = (String? message, {int? wrapWidth}) {
      debug.add(message);
    };
    channel.setMockMethodCallHandler((MethodCall call) async {
      log.add(call);
      return null;
    });
    log.clear();
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
    debugPrint = debugPrintOriginal;
  });

  test('init initializes plugin', () async {
    await NotificationService().init();
    expect(log.any((c) => c.method == 'initialize'), isTrue);
  });

  test('scheduleNotification schedules notification with tz', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Detroit'));
    final service = NotificationService();
    await service.scheduleNotification(
      id: 1,
      title: 't',
      body: 'b',
      scheduledDate: DateTime.now().add(const Duration(minutes: 1)),
      l10n: l10n,
      payload: 'p',
    );
    final call = log.singleWhere((c) => c.method == 'zonedSchedule');
    final args = call.arguments as Map<dynamic, dynamic>;
    expect(args['timeZoneName'], 'America/Detroit');
  });

  test('scheduleNotification throws if scheduledDate in the past', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final service = NotificationService();
    expect(
      () => service.scheduleNotification(
        id: 10,
        title: 't',
        body: 'b',
        scheduledDate: DateTime.now().subtract(const Duration(minutes: 1)),
        l10n: l10n,
        payload: 'p',
      ),
      throwsArgumentError,
    );
  });

  test('scheduleNotification logs error when permission denied', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Detroit'));
    channel.setMockMethodCallHandler((MethodCall call) async {
      log.add(call);
      if (call.method == 'zonedSchedule') {
        throw PlatformException(code: 'denied');
      }
      return null;
    });
    await NotificationService().scheduleNotification(
      id: 11,
      title: 't',
      body: 'b',
      scheduledDate: DateTime.now().add(const Duration(minutes: 1)),
      l10n: l10n,
      payload: 'p',
    );
    final call = log.singleWhere((c) => c.method == 'zonedSchedule');
    final args = call.arguments as Map<dynamic, dynamic>;
    expect(args['timeZoneName'], 'America/Detroit');
    expect(
      debug.any((m) => m != null && m.contains('Error scheduling notification')),
      isTrue,
    );
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

  test('scheduleRecurring logs error when permission denied', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Detroit'));
    channel.setMockMethodCallHandler((MethodCall call) async {
      log.add(call);
      if (call.method == 'periodicallyShow') {
        throw PlatformException(code: 'denied');
      }
      return null;
    });
    await NotificationService().scheduleRecurring(
      id: 12,
      title: 't',
      body: 'b',
      repeatInterval: RepeatInterval.daily,
      l10n: l10n,
    );
    expect(
      debug.any((m) =>
          m != null && m.contains('Error scheduling recurring notification')),
      isTrue,
    );
  });

  test('scheduleRecurring logs duplicate id error', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    bool first = true;
    channel.setMockMethodCallHandler((MethodCall call) async {
      log.add(call);
      if (call.method == 'periodicallyShow' && !first) {
        throw PlatformException(code: 'duplicate');
      }
      first = false;
      return null;
    });
    final service = NotificationService();
    await service.scheduleRecurring(
      id: 13,
      title: 't',
      body: 'b',
      repeatInterval: RepeatInterval.daily,
      l10n: l10n,
    );
    await service.scheduleRecurring(
      id: 13,
      title: 't',
      body: 'b',
      repeatInterval: RepeatInterval.daily,
      l10n: l10n,
    );
    expect(
      debug.where((m) =>
              m != null && m.contains('Error scheduling recurring notification'))
          .length,
      1,
    );
  });

  test('snoozeNotification cancels and schedules with tz', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Detroit'));
    final service = NotificationService();
    await service.snoozeNotification(
      id: 14,
      title: 't',
      body: 'b',
      minutes: 5,
      l10n: l10n,
      payload: 'p',
    );
    expect(log.first.method, 'cancel');
    final scheduleCall =
        log.singleWhere((c) => c.method == 'zonedSchedule');
    final args = scheduleCall.arguments as Map<dynamic, dynamic>;
    expect(args['timeZoneName'], 'America/Detroit');
  });

  test('snoozeNotification throws when permission denied', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Detroit'));
    channel.setMockMethodCallHandler((MethodCall call) async {
      log.add(call);
      if (call.method == 'zonedSchedule') {
        throw PlatformException(code: 'denied');
      }
      return null;
    });
    final service = NotificationService();
    expect(
      () => service.snoozeNotification(
        id: 15,
        title: 't',
        body: 'b',
        minutes: 5,
        l10n: l10n,
        payload: 'p',
      ),
      throwsA(isA<PlatformException>()),
    );
    final call = log.singleWhere((c) => c.method == 'zonedSchedule');
    final args = call.arguments as Map<dynamic, dynamic>;
    expect(args['timeZoneName'], 'America/Detroit');
  });

  test('cancel propagates platform exceptions', () async {
    channel.setMockMethodCallHandler((MethodCall call) async {
      log.add(call);
      if (call.method == 'cancel') {
        throw PlatformException(code: 'denied');
      }
      return null;
    });
    expect(
      () => NotificationService().cancel(99),
      throwsA(isA<PlatformException>()),
    );
    expect(log.single.method, 'cancel');
  });
}
