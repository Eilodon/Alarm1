abstract class CalendarService {
  Future<String?> createEvent({
    required String title,
    required String description,
    required DateTime start,
    DateTime? end,
  });

  Future<void> updateEvent(
    String eventId, {
    required String title,
    required String description,
    required DateTime start,
    DateTime? end,
  });

  Future<void> deleteEvent(String eventId);
}
