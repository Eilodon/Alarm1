import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'note_detail_screen.dart';
import 'home_screen.dart';

class NoteListForDayScreen extends StatelessWidget {
  final DateTime date;
  final List<Note> notes;

  const NoteListForDayScreen({
    super.key,
    required this.date,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final title = 'Lịch ngày ${DateFormat('dd/MM/yyyy').format(date)}';
    if (notes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Text('Không có ghi chú/nhắc lịch cho ngày này'),
        ),
      );
    }
    final sorted = [...notes]..sort((a, b) {
      final at = a.remindAt?.millisecondsSinceEpoch ?? 0;
      final bt = b.remindAt?.millisecondsSinceEpoch ?? 0;
      return at.compareTo(bt);
    });
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final note = sorted[index];
          final timeStr = note.remindAt != null
              ? DateFormat('HH:mm').format(note.remindAt!)
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
