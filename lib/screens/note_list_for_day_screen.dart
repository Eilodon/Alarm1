import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import 'note_detail_screen.dart';

class NoteListForDayScreen extends StatelessWidget {
  final DateTime date;

  const NoteListForDayScreen({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NoteProvider>().notes;
    final dayNotes = notes
        .where((n) =>
            n.alarmTime != null &&
            n.alarmTime!.year == date.year &&
            n.alarmTime!.month == date.month &&
            n.alarmTime!.day == date.day)
        .toList()
      ..sort((a, b) {
        final at = a.alarmTime?.millisecondsSinceEpoch ?? 0;
        final bt = b.alarmTime?.millisecondsSinceEpoch ?? 0;
        return at.compareTo(bt);
      });
    final title = 'Lịch ngày ${DateFormat('dd/MM/yyyy').format(date)}';
    if (dayNotes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Text('Không có ghi chú/nhắc lịch cho ngày này'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: dayNotes.length,
        itemBuilder: (context, index) {
          final note = dayNotes[index];
          final timeStr = note.alarmTime != null
              ? DateFormat('HH:mm').format(note.alarmTime!)
              : null;
          return Card(
            child: ListTile(
              title: Text(note.title),
              subtitle: Text(
                timeStr != null
                    ? '${note.content}\n⏰ $timeStr'
                    : note.content,
              ),
              isThreeLine: timeStr != null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NoteDetailScreen(note: note),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
