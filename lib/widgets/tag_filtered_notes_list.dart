import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:alarm_domain/alarm_domain.dart';
import '../features/note/presentation/note_provider.dart';
import '../screens/note_list_for_day_screen.dart';
import 'notes_list.dart';
import 'tag_filter_menu.dart';
import 'route_transitions.dart';

class TagFilteredNotesList extends StatefulWidget {
  final int gridCount;

  const TagFilteredNotesList({super.key, this.gridCount = 1});

  @override
  State<TagFilteredNotesList> createState() => _TagFilteredNotesListState();
}

class _TagFilteredNotesListState extends State<TagFilteredNotesList> {
  String? _selectedTag;
  final DateTime _today = DateTime.now();

  List<Note> _notesForDay(DateTime day, List<Note> notes) {
    return notes
        .where(
          (n) =>
              n.alarmTime != null &&
              n.alarmTime!.year == day.year &&
              n.alarmTime!.month == day.month &&
              n.alarmTime!.day == day.day,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    final notes = provider.notes;
    final tags = notes.expand((n) => n.tags).toSet().toList();
    final filteredNotes = _selectedTag == null
        ? notes
        : notes.where((n) => n.tags.contains(_selectedTag!)).toList();
    final weekDays = List.generate(7, (i) => _today.add(Duration(days: i)));

    return Column(
      children: [
        TagFilterMenu(
          tags: tags,
          selectedTag: _selectedTag,
          onSelected: (value) {
            setState(() => _selectedTag = value);
          },
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weekDays.length,
            itemBuilder: (context, i) {
              final d = weekDays[i];
              final hasNotes = _notesForDay(d, filteredNotes).isNotEmpty;
              final theme = Theme.of(context);
              final textColor = hasNotes
                  ? theme.colorScheme.onSecondary
                  : theme.colorScheme.onSurface;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    buildSlideFadeRoute(NoteListForDayScreen(date: d)),
                  );
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: hasNotes
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.surface,
                    border: Border.all(color: textColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.E(
                          Localizations.localeOf(context).toString(),
                        ).format(d),
                        style: TextStyle(color: textColor),
                      ),
                      Text('${d.day}', style: TextStyle(color: textColor)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: NotesList(notes: filteredNotes, gridCount: widget.gridCount),
        ),
      ],
    );
  }
}
