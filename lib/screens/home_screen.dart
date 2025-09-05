import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../widgets/tag_selector.dart';
import 'note_detail_screen.dart';
import 'note_list_for_day_screen.dart';
import 'note_search_delegate.dart';
import 'settings_screen.dart';
import 'voice_to_note_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(Color) onThemeChanged;
  final Function(double) onFontScaleChanged;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.onFontScaleChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _mascotPath = 'assets/lottie/mascot.json';
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMascot();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().loadNotes();
    });
  }

  Future<void> _loadMascot() async {
    _mascotPath = await SettingsService().loadMascotPath();
    if (mounted) setState(() {});
  }

  void _addNote() {
    final provider = context.read<NoteProvider>();
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController(text: provider.draft);
    DateTime? alarmTime;

    bool locked = false;
    var tags = <String>[];
    final availableTags = provider.notes.expand((n) => n.tags).toSet().toList();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.addNoteReminder),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.titleLabel,
                  ),
                ),
                TextField(
                  controller: contentCtrl,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.contentLabel,
                  ),
                ),
                TagSelector(
                  availableTags: availableTags,
                  selectedTags: tags,
                  allowCreate: true,
                  label: AppLocalizations.of(context)!.tagsLabel,
                  onChanged: (v) => setState(() => tags = v),
                ),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.lockNote),
                  value: locked,
                  onChanged: (value) => setState(() => locked = value),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: now,
                      lastDate: DateTime(now.year + 2),
                      initialDate: now,
                    );
                    if (picked != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        alarmTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          time.hour,
                          time.minute,
                        );
                      }
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.selectReminderTime),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final noteId = const Uuid().v4();
                final notificationId = alarmTime != null
                    ? DateTime.now().millisecondsSinceEpoch % 100000
                    : null;

                final note = Note(
                  id: noteId,
                  title: titleCtrl.text,
                  content: contentCtrl.text,
                  summary: '',
                  actionItems: const [],
                  dates: const [],
                  alarmTime: alarmTime,
                  locked: locked,
                  tags: tags,
                  updatedAt: DateTime.now(),
                  notificationId: notificationId,
                );
                await provider.addNote(note);
                provider.setDraft('');

                if (alarmTime != null) {
                  await NotificationService().scheduleNotification(
                    id: note.notificationId!,
                    title: note.title,
                    body: note.content,
                    scheduledDate: alarmTime!,
                    l10n: AppLocalizations.of(context)!,
                  );
                }
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      titleCtrl.dispose();
      contentCtrl.dispose();
    });
  }

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

  Widget _buildNotesList(List<Note> notes) {
    if (notes.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noNotes));
    }

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          child: ListTile(
            leading: note.locked ? const Icon(Icons.lock) : null,
            title: Text(note.title),
            subtitle: Text(
              note.alarmTime != null
                  ? '${note.content}\n⏰ ${DateFormat.yMd(
                          Localizations.localeOf(context).toString(),
                        )
                          .add_Hm()
                          .format(note.alarmTime!)}'
                  : note.content,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              tooltip: AppLocalizations.of(context)!.delete,
              onPressed: () => context.read<NoteProvider>().removeNoteAt(index),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NoteProvider>().notes;
    final weekDays = List.generate(7, (i) => _today.add(Duration(days: i)));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate:
                  NoteSearchDelegate(context.read<NoteProvider>().notes),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VoiceToNoteScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context)!.settingsTooltip,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    onThemeChanged: widget.onThemeChanged,
                    onFontScaleChanged: widget.onFontScaleChanged,
                  ),
                ),
              );
              _loadMascot();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(width: 140, height: 140, child: Lottie.asset(_mascotPath)),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekDays.length,
              itemBuilder: (context, i) {
                final d = weekDays[i];
                final hasNotes = _notesForDay(d, notes).isNotEmpty;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteListForDayScreen(date: d),
                      ),
                    );
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: hasNotes ? Colors.orange : Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat.E(Localizations.localeOf(context).toString()).format(d)),
                        Text('${d.day}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildNotesList(notes)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        tooltip: AppLocalizations.of(context)!.addNoteTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}
