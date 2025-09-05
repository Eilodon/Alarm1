import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes_reminder_app/models/note.dart';
import 'package:notes_reminder_app/providers/note_provider.dart';
import 'package:notes_reminder_app/services/note_repository.dart';
import 'package:notes_reminder_app/services/calendar_service.dart';
import 'package:notes_reminder_app/services/notification_service.dart';

class MockRepo extends Mock implements NoteRepository {}
class MockCalendar extends Mock implements CalendarService {}
class MockNotification extends Mock implements NotificationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue<List<Note>>([]);
  });

  test('removeNoteAt cancels notification and deletes event', () async {
    final repo = MockRepo();
    final calendar = MockCalendar();
    final notification = MockNotification();
    when(() => repo.getNotes()).thenAnswer((_) async => [
          const Note(
            id: '1',
            title: 't',
            content: 'c',
            summary: '',
            actionItems: const [],
            dates: const [],
            notificationId: 123,
            eventId: 'e1',
          )
        ]);
    when(() => repo.saveNotes(any())).thenAnswer((_) async {});
    when(() => calendar.deleteEvent(any())).thenAnswer((_) async {});
    when(() => notification.cancel(any())).thenAnswer((_) async {});

    final provider = NoteProvider(
      repository: repo,
      calendarService: calendar,
      notificationService: notification,
    );

    await provider.loadNotes();
    await provider.removeNoteAt(0);

    verify(() => notification.cancel(123)).called(1);
    verify(() => calendar.deleteEvent('e1')).called(1);
    verify(() => repo.saveNotes([])).called(1);
  });
}
