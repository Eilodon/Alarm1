import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
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
}
