import 'package:flutter/services.dart';
import 'package:pandora/features/note/domain/domain.dart';

/// Service to update the native home screen widget with the next upcoming note.
class HomeWidgetServiceImpl implements HomeWidgetService {
  const HomeWidgetServiceImpl();

  static const MethodChannel _channel = MethodChannel('pandora/actions');

  /// Compute the next upcoming note and ask the native layer to update the widget.
  @override
  Future<void> update(List<Note> notes) async {
    final upcoming = _nextNote(notes);
    final latestTitle = upcoming?.title ?? '';
    try {
      await _channel.invokeMethod('updateWidget', {
        'latestNote': latestTitle,
      });
    } catch (_) {
      // No-op on platforms without an implementation.
    }
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
