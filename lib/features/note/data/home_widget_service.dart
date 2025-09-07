import 'package:home_widget/home_widget.dart';

import 'package:notes_reminder_app/features/note/domain/domain.dart';

/// Service to update the native home screen widget with the next upcoming note.
class HomeWidgetServiceImpl implements HomeWidgetService {
  static const _noteKey = 'note';

  const HomeWidgetServiceImpl();

  /// Save note data and trigger a widget update.
  @override
  Future<void> update(List<Note> notes) async {
    final upcoming = _nextNote(notes);
    if (upcoming == null) {
      await HomeWidget.saveWidgetData<String>(_noteKey, '');
    } else {
      await HomeWidget.saveWidgetData<String>(_noteKey, upcoming.title);
    }
    await HomeWidget.updateWidget(name: 'WidgetProvider', iOSName: 'NotesReminderWidget');
  }

  Note? _nextNote(List<Note> notes) {
    final now = DateTime.now();
    final upcoming = notes
        .where((n) => n.alarmTime != null && n.alarmTime!.isAfter(now))
        .toList()
      ..sort((a, b) => a.alarmTime!.compareTo(b.alarmTime!));
    return upcoming.isEmpty ? null : upcoming.first;
  }
}
