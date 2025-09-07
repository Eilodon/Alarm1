import '../entities/note.dart';

abstract class HomeWidgetService {
  Future<void> update(List<Note> notes);
}
