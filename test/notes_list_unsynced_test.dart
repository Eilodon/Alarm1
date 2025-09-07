import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:notes_reminder_app/generated/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:notes_reminder_app/features/note/presentation/note_provider.dart';
import 'package:notes_reminder_app/widgets/notes_list.dart';
import 'package:notes_reminder_app/features/note/note.dart';
import 'package:notes_reminder_app/features/note/data/calendar_service.dart';
import 'package:notes_reminder_app/features/note/data/notification_service.dart';
import 'package:notes_reminder_app/features/note/data/home_widget_service.dart';
import 'package:notes_reminder_app/features/backup/data/note_sync_service.dart';
import 'package:alarm_domain/alarm_domain.dart';

class MockRepo extends Mock implements NoteRepository {}
class MockCalendar extends Mock implements CalendarService {}
class MockNotification extends Mock implements NotificationService {}
class MockHomeWidget extends Mock implements HomeWidgetService {}
class MockSyncService extends Mock implements NoteSyncService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('displays sync problem icon for unsynced notes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = MockRepo();
    final calendar = MockCalendar();
    final notification = MockNotification();
    final homeWidget = MockHomeWidget();
    final sync = MockSyncService();
    when(() => repo.saveNotes(any())).thenAnswer((_) async {});
    when(() => sync.init(any())).thenAnswer((_) async {});
    final controller = StreamController<SyncStatus>.broadcast();
    when(() => sync.syncStatus).thenAnswer((_) => controller.stream);
    when(() => sync.setSyncStatus(any())).thenAnswer((invocation) {
      controller.add(invocation.positionalArguments.first as SyncStatus);
    });
    when(() => sync.loadFromRemote(any())).thenAnswer((_) async => true);
    when(() => homeWidget.update(any())).thenAnswer((_) async {});
    final provider = NoteProvider(
      getNotes: GetNotes(repo),
      saveNotes: SaveNotes(repo),
      updateNote: UpdateNote(repo),
      autoBackup: AutoBackup(repo),
      calendarService: calendar,
      notificationService: notification,
      homeWidgetService: homeWidget,
      syncService: sync,
    );
    await Future.delayed(Duration.zero);

    const note = Note(
      id: '1',
      title: 'title',
      content: 'content',
      summary: '',
      actionItems: [],
      dates: [],
    );
    await provider.addNote(note);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: NotesList(notes: provider.notes)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.sync_problem), findsOneWidget);
  });
}
