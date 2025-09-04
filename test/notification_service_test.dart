import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes_reminder_app/services/notification_service.dart';

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
    final service = NotificationService();
    await service.scheduleNotification(
      id: 1,
      title: 't',
      body: 'b',
      scheduledDate: DateTime.now().add(const Duration(minutes: 1)),
    );
    expect(log.any((c) => c.method == 'zonedSchedule'), isTrue);
  });

  test('scheduleDailyAtTime schedules daily notification', () async {
    final service = NotificationService();
    await service.scheduleDailyAtTime(
      id: 2,
      title: 't',
      body: 'b',
      time: const Time(10, 0, 0),
    );
    expect(log.any((c) => c.method == 'zonedSchedule'), isTrue);
  });

  test('scheduleRecurring schedules recurring notification', () async {
    final service = NotificationService();
    await service.scheduleRecurring(
      id: 3,
      title: 't',
      body: 'b',
      repeatInterval: RepeatInterval.daily,
    );
    expect(log.any((c) => c.method == 'periodicallyShow'), isTrue);
  });
}
