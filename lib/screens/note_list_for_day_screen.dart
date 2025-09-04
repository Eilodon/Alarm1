import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
 codex/implement-note-repository-and-provider
import 'package:provider/provider.dart';
import 'note_detail_screen.dart';
import '../models/note.dart';
 codex/expand-note-model-with-new-fields


class NoteListForDayScreen extends StatelessWidget {
  final DateTime date;

  const NoteListForDayScreen({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NoteProvider>().notes.where((n) =>
        n.alarmTime != null &&
        n.alarmTime!.year == date.year &&
        n.alarmTime!.month == date.month &&
        n.alarmTime!.day == date.day).toList();
    final title = 'Lịch ngày ${DateFormat('dd/MM/yyyy').format(date)}';
    if (notes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Text('Không có ghi chú/nhắc lịch cho ngày này'),
        ),
      );
    }
 codex/implement-note-repository-and-provider
    final sorted = [...notes]..sort((a, b) {
      final at = a.alarmTime?.millisecondsSinceEpoch ?? 0;
      final bt = b.alarmTime?.millisecondsSinceEpoch ?? 0;
      return at.compareTo(bt);
    });

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final note = sorted[index];
          final timeStr = note.alarmTime != null
              ? DateFormat('HH:mm').format(note.alarmTime!)
              : null;
          return Card(
            child: ListTile(
              title: Text(note.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr != null
                        ? '${note.content}\n⏰ $timeStr'
                        : note.content,
                  ),
                  if (note.tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children:
                          note.tags.map((t) => Chip(label: Text(t))).toList(),
                    ),
                  ]
                ],
              ),
              isThreeLine: timeStr != null || note.tags.isNotEmpty,
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
