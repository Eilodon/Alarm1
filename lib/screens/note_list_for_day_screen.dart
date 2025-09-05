import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        .toList();


    final title = AppLocalizations.of(context)!
        .scheduleForDate(DateFormat('dd/MM/yyyy').format(date));
    if (dayNotes.isEmpty) {

      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Text(AppLocalizations.of(context)!.noNotesForDay),
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
