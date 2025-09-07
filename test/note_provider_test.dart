import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:notes_reminder_app/features/note/note.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MockRepo extends Mock implements NoteRepository {}

class MockCalendar extends Mock implements CalendarService {}

class MockNotification extends Mock implements NotificationService {}

class MockSyncService extends Mock implements NoteSyncService {}

class MockHomeWidget extends Mock implements HomeWidgetService {}

class FakeL10n extends Fake implements AppLocalizations {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue<List<Note>>([]);
    registerFallbackValue(DateTime(0));
    registerFallbackValue(<Note>{});
    registerFallbackValue(
      const Note(
        id: '0',
        title: '',
        content: '',
        summary: '',
        actionItems: [],
        dates: [],
      ),
    );
    registerFallbackValue<Note? Function(String)>((_) => null);
  });

  test('removeNoteAt cancels notification and deletes event', () async {
    final repo = MockRepo();
    final calendar = MockCalendar();
    final notification = MockNotification();
    final sync = MockSyncService();
    final homeWidget = MockHomeWidget();
    when(() => repo.getNotes()).thenAnswer(
      (_) async => [
        const Note(
          id: '1',
          title: 't',
          content: 'c',
          summary: '',
          actionItems: const [],
          dates: const [],
          notificationId: 123,
          eventId: 'e1',
        ),
      ],
    );
    when(() => repo.saveNotes(any())).thenAnswer((_) async {});
    when(() => calendar.deleteEvent(any())).thenAnswer((_) async {});
    when(() => notification.cancel(any())).thenAnswer((_) async {});
    when(() => sync.init(any())).thenAnswer((_) async {});
    when(() => sync.syncStatus).thenReturn(ValueNotifier(SyncStatus.idle));
    when(() => sync.loadFromRemote(any())).thenAnswer((_) async => true);
    when(() => sync.deleteNote(any())).thenAnswer((_) async {});
    when(() => homeWidget.update(any())).thenAnswer((_) async {});

    final provider = NoteProvider(
      getNotes: GetNotes(repo),
      saveNotes: SaveNotes(repo),
      updateNote: UpdateNote(repo),
      autoBackup: AutoBackup(repo),
      calendarService: calendar,
      notificationService: notification,
      syncService: sync,
      homeWidgetService: homeWidget,
    );

    await provider.loadNotes();
    await provider.removeNoteAt(0);

    verify(() => notification.cancel(123)).called(1);
    verify(() => calendar.deleteEvent('e1')).called(1);
    verify(() => repo.saveNotes([])).called(1);
  });

  test('createNote schedules notification', () async {
    final repo = MockRepo();
    final calendar = MockCalendar();
    final notification = MockNotification();
    final sync = MockSyncService();
    final homeWidget = MockHomeWidget();
    final l10n = FakeL10n();
    when(() => repo.saveNotes(any())).thenAnswer((_) async {});
    when(
      () => notification.scheduleNotification(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        l10n: l10n,
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => calendar.createEvent(
        title: any(named: 'title'),
        description: any(named: 'description'),
        start: any(named: 'start'),
      ),
    ).thenAnswer((_) async => 'e1');
    when(() => sync.init(any())).thenAnswer((_) async {});
    when(() => sync.syncStatus).thenReturn(ValueNotifier(SyncStatus.idle));
    when(() => sync.loadFromRemote(any())).thenAnswer((_) async => true);
    when(() => sync.syncNote(any())).thenAnswer((_) async {});
    when(() => homeWidget.update(any())).thenAnswer((_) async {});

    final provider = NoteProvider(
      getNotes: GetNotes(repo),
      saveNotes: SaveNotes(repo),
      updateNote: UpdateNote(repo),
      autoBackup: AutoBackup(repo),
      calendarService: calendar,
      notificationService: notification,
      syncService: sync,
      homeWidgetService: homeWidget,
    );

    final ok = await provider.createNote(
      title: 't',
      content: 'c',
      alarmTime: DateTime(2025, 1, 1),
      l10n: l10n,
    );

    expect(ok, isTrue);
    expect(provider.notes.length, 1);
    final note = provider.notes.first;
    expect(note.notificationId, isNotNull);
    expect(note.notificationId! > 0, isTrue);
    verify(() => repo.saveNotes(any())).called(1);
    final captured = verify(
      () => notification.scheduleNotification(
        id: captureAny(named: 'id'),
        title: 't',
        body: 'c',
        scheduledDate: any(named: 'scheduledDate'),
        l10n: l10n,
        payload: captureAny(named: 'payload'),
      ),
    ).captured;
    expect(captured.first, isA<int>());
    expect(captured.first > 0, isTrue);
  });

  test(
    'createNote with repeat interval schedules recurring notification',
    () async {
      final repo = MockRepo();
      final calendar = MockCalendar();
      final notification = MockNotification();
      final sync = MockSyncService();
      final l10n = FakeL10n();
      when(() => repo.saveNotes(any())).thenAnswer((_) async {});
      when(
        () => notification.scheduleRecurring(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          repeatInterval: any(named: 'repeatInterval'),
          l10n: l10n,
        ),
      ).thenAnswer((_) async {});
      when(
        () => calendar.createEvent(
          title: any(named: 'title'),
          description: any(named: 'description'),
          start: any(named: 'start'),
        ),
      ).thenAnswer((_) async => 'e1');
      when(() => sync.init(any())).thenAnswer((_) async {});
      when(() => sync.syncStatus).thenReturn(ValueNotifier(SyncStatus.idle));
      when(() => sync.loadFromRemote(any())).thenAnswer((_) async => true);
      when(() => sync.syncNote(any())).thenAnswer((_) async {});

      final provider = NoteProvider(
        getNotes: GetNotes(repo),
        saveNotes: SaveNotes(repo),
        updateNote: UpdateNote(repo),
        autoBackup: AutoBackup(repo),
        calendarService: calendar,
        notificationService: notification,
        syncService: sync,
      );

      await provider.createNote(
        title: 't',
        content: 'c',
        alarmTime: DateTime(2025, 1, 1),
        repeatInterval: RepeatInterval.daily,
        l10n: l10n,
      );

      verify(
        () => notification.scheduleRecurring(
          id: any(named: 'id'),
          title: 't',
          body: 'c',
          repeatInterval: RepeatInterval.daily,
          l10n: l10n,
        ),
      ).called(1);
    },
  );

  test('fetchNotesPage paginates using stored order', () async {
    final repo = MockRepo();
    final sync = MockSyncService();
    final homeWidget = MockHomeWidget();
    when(() => repo.getNotes()).thenAnswer(
      (_) async => [
        Note(
          id: '1',
          title: 'a',
          content: 'c',
          updatedAt: DateTime(2023, 1, 1),
        ),
        Note(
          id: '2',
          title: 'b',
          content: 'c',
          updatedAt: DateTime(2024, 1, 1),
        ),
        Note(
          id: '3',
          title: 'c',
          content: 'c',
          updatedAt: DateTime(2022, 1, 1),
        ),
      ],
    );
    when(() => repo.saveNotes(any())).thenAnswer((_) async {});
    when(() => sync.init(any())).thenAnswer((_) async {});
    when(() => sync.syncStatus).thenReturn(ValueNotifier(SyncStatus.idle));
    when(() => sync.loadFromRemote(any())).thenAnswer((_) async => true);
    when(() => homeWidget.update(any())).thenAnswer((_) async {});

    final provider = NoteProvider(
      getNotes: GetNotes(repo),
      saveNotes: SaveNotes(repo),
      updateNote: UpdateNote(repo),
      autoBackup: AutoBackup(repo),
      calendarService: MockCalendar(),
      notificationService: MockNotification(),
      syncService: sync,
      homeWidgetService: homeWidget,
    );

    final firstPage = await provider.fetchNotesPage(null, 2);
    expect(firstPage.map((n) => n.id), ['2', '1']);

    final secondPage = await provider.fetchNotesPage(
      firstPage.last.updatedAt,
      2,
    );
    expect(secondPage.map((n) => n.id), ['3']);
    verify(() => repo.getNotes()).called(1);
  });

  test('snoozeNote calls notification snooze', () async {
    final repo = MockRepo();
    final calendar = MockCalendar();
    final notification = MockNotification();
    final sync = MockSyncService();
    final homeWidget = MockHomeWidget();
    final l10n = FakeL10n();
    when(() => repo.getNotes()).thenAnswer(
      (_) async => [
        const Note(
          id: '1',
          title: 't',
          content: 'c',
          snoozeMinutes: 5,
          notificationId: 10,
          summary: '',
          actionItems: [],
          dates: [],
        ),
      ],
    );
    when(() => repo.saveNotes(any())).thenAnswer((_) async {});
    when(
      () => notification.snoozeNotification(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        minutes: any(named: 'minutes'),
        l10n: l10n,
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    when(() => sync.init(any())).thenAnswer((_) async {});
    when(() => sync.syncStatus).thenReturn(ValueNotifier(SyncStatus.idle));
    when(() => sync.loadFromRemote(any())).thenAnswer((_) async => true);
    when(() => homeWidget.update(any())).thenAnswer((_) async {});

    final provider = NoteProvider(
      getNotes: GetNotes(repo),
      saveNotes: SaveNotes(repo),
      updateNote: UpdateNote(repo),
      autoBackup: AutoBackup(repo),
      calendarService: calendar,
      notificationService: notification,
      syncService: sync,
      homeWidgetService: homeWidget,
    );

    await provider.loadNotes();
    final note = provider.notes.first;
    await provider.snoozeNote(note, l10n);

    verify(
      () => notification.snoozeNotification(
        id: 10,
        title: 't',
        body: 'c',
        minutes: 5,
        l10n: l10n,
        payload: note.id,
      ),
    ).called(1);
  });
}
