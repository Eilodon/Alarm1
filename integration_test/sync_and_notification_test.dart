import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:notes_reminder_app/features/note/presentation/note_provider.dart';
import 'package:notes_reminder_app/services/calendar_service.dart';
import 'package:alarm_data/alarm_data.dart';
import 'package:notes_reminder_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tzdata;

class MockRepo extends Mock implements NoteRepository {}

class MockCalendar extends Mock implements CalendarService {}

class MockNotification extends Mock implements NotificationService {}

class FakeConnectivityPlatform extends Fake implements ConnectivityPlatform {
  final _controller = StreamController<ConnectivityResult>.broadcast();
  @override
  Stream<ConnectivityResult> get onConnectivityChanged => _controller.stream;
  void emit(ConnectivityResult result) => _controller.add(result);
}

void setupFirebase() {
  const MethodChannel core = MethodChannel('plugins.flutter.io/firebase_core');
  const MethodChannel auth = MethodChannel('plugins.flutter.io/firebase_auth');
  const MethodChannel firestore = MethodChannel(
    'plugins.flutter.io/firebase_firestore',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(core, (call) async {
        if (call.method == 'Firebase#initializeCore') {
          return [
            {
              'name': call.arguments['appName'] ?? 'app',
              'options': call.arguments['options'] ?? {},
            },
          ];
        }
        if (call.method == 'Firebase#initializeApp') {
          return {
            'name': call.arguments['appName'] ?? 'app',
            'options': call.arguments['options'] ?? {},
          };
        }
        return null;
      });

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(auth, (call) async {
        if (call.method == 'signInAnonymously') {
          return {
            'user': {'uid': 'uid'},
          };
        }
        return null;
      });

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(firestore, (call) async {
        return null;
      });
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('syncUnsyncedNotes triggered when connectivity restored', (
    tester,
  ) async {
    setupFirebase();
    await Firebase.initializeApp();

    final connectivity = FakeConnectivityPlatform();
    ConnectivityPlatform.instance = connectivity;

    final repo = MockRepo();
    final calendar = MockCalendar();
    final notification = MockNotification();

    final note = const Note(
      id: '1',
      title: 't',
      content: 'c',
      summary: '',
      actionItems: [],
      dates: [],
    );

    when(() => repo.getNotes()).thenAnswer((_) async => [note]);
    when(() => repo.saveNotes(any())).thenAnswer((_) async {});
    when(
      () => repo.encryptNote(any()),
    ).thenAnswer((_) async => {'title': 't', 'content': 'c'});

    SharedPreferences.setMockInitialValues({
      'unsyncedNoteIds': ['1'],
    });

    final provider = NoteProvider(
      repository: repo,
      calendarService: calendar,
      notificationService: notification,
    );

    await provider.loadNotes();

    connectivity.emit(ConnectivityResult.none);
    await tester.pump();
    connectivity.emit(ConnectivityResult.wifi);
    await tester.pump();

    verify(() => repo.encryptNote(note)).called(1);
    expect(provider.unsyncedNoteIds, isEmpty);
  });

  testWidgets('schedule and snooze notifications', (tester) async {
    const channel = MethodChannel('dexterx.dev/flutter_local_notifications');
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    tzdata.initializeTimeZones();
    final service = NotificationService();
    final date = DateTime.now().add(const Duration(minutes: 1));

    await service.scheduleNotification(
      id: 1,
      title: 't',
      body: 'b',
      scheduledDate: date,
      l10n: l10n,
      payload: 'p',
    );

    await service.snoozeNotification(
      id: 1,
      title: 't',
      body: 'b',
      minutes: 5,
      l10n: l10n,
      payload: 'p',
    );

    expect(calls.any((c) => c.method == 'zonedSchedule'), isTrue);
    expect(calls.any((c) => c.method == 'cancel'), isTrue);
  });
}
