import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import '../services/auth_service.dart';
import 'note_detail_screen.dart';
import '../pandora_ui/hint_chip.dart';
import '../pandora_ui/result_card.dart';

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


    final title = AppLocalizations.of(context)!.scheduleForDate(
      DateFormat.yMd(Localizations.localeOf(context).toString()).format(date),
    );
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
              ? DateFormat.Hm(Localizations.localeOf(context).toString())
                  .format(note.alarmTime!)
              : null;
          return ResultCard(
            child: ListTile(
              title: Hero(
                tag: note.id,
                child: Material(
                  color: Colors.transparent,
                  child: Text(note.title),
                ),
              ),
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
                      children: note.tags
                          .map(
                            (t) => HintChip(
                              label: t,
                              onPressed: () {},
                            ),
                          )
                          .toList(),
                    ),
                  ]
                ],
              ),
              isThreeLine: timeStr != null || note.tags.isNotEmpty,
              onTap: () async {
                if (note.locked) {
                  final ok = await AuthService()
                      .authenticate(AppLocalizations.of(context)!);
                  if (!ok) return;
                }
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => NoteDetailScreen(note: note),
                    transitionsBuilder: (_, animation, __, child) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
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
