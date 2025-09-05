import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';

import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../services/db_service.dart';
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
  static const _platform = MethodChannel('notes_reminder_app/actions');

  String _mascotPath = 'assets/lottie/mascot.json';

  DateTime today = DateTime.now();
  final _db = DbService();


  @override
  void initState() {
    super.initState();
    _loadMascot();
    _loadNotes();

  }

  Future<void> _loadMascot() async {
    _mascotPath = await SettingsService().loadMascotPath();
    if (mounted) setState(() {});
  }

  Future<void> _loadNotes() async {
    notes = await _db.getNotes();
    setState(() {});
  }

  void _addNote() {
    final provider = context.read<NoteProvider>();
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController(text: provider.draft);
    DateTime? alarmTime;
    bool locked = false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addNoteReminder),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.titleLabel)),
              TextField(
                  controller: contentCtrl,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.contentLabel)),
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
                      firstDate: now,
                      lastDate: DateTime(now.year + 2),
                      initialDate: now,
                    );
                    if (picked != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),

                      );
                      if (!mounted) return;
                      if (time != null) {
                        alarmTime = DateTime(
                          picked.year, picked.month, picked.day,
                          time.hour, time.minute,
                        );
                      }
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
              child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () async {
              final nowId = DateTime.now().millisecondsSinceEpoch;
              final note = Note(
                id: nowId.toString(),
                title: titleCtrl.text,
                content: contentCtrl.text,
                alarmTime: alarmTime,
              );
              setState(() => notes.add(note));

              if (alarmTime != null) {
                await NotificationService().scheduleNotification(
                  id: nowId % 100000,
                  title: note.title,
                  body: note.content,
                  scheduledDate: alarmTime!,

                );
              }
              if (!mounted) return;
              Navigator.pop(context); // FIX Lỗi 1: auto đóng dialog
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],

      ),
    );
  }

  List<Note> notesForDay(DateTime day) {
    final notes = context.read<NoteProvider>().notes;
    return notes

        .where((n) =>
            n.alarmTime != null &&
            n.alarmTime!.year == day.year &&
            n.alarmTime!.month == day.month &&
            n.alarmTime!.day == day.day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = List.generate(7, (i) => today.add(Duration(days: i)));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
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
                      onFontScaleChanged: widget.onFontScaleChanged),
                ),
              );
              _loadMascot();
            },
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(width: 140, height: 140, child: Lottie.asset(_mascotPath)),
          const SizedBox(height: 8),
          // Lịch 7 ngày - Lỗi 3
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekDays.length,
              itemBuilder: (context, i) {
                final d = weekDays[i];
                final hasNotes = notesForDay(d).isNotEmpty;
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
                        Text(DateFormat('E').format(d)),
                        Text('${d.day}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildNotesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        tooltip: AppLocalizations.of(context)!.addNoteTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNotesList() {
    if (notes.isEmpty)
      return Center(child: Text(AppLocalizations.of(context)!.noNotes));

    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Card(
          child: ListTile(
            leading: note.locked ? const Icon(Icons.lock) : null,
            title: Text(note.title),

            subtitle: Text(note.alarmTime != null
                ? '${note.content}\n⏰ ${DateFormat('HH:mm dd/MM/yyyy').format(note.alarmTime!)}'
                : note.content),
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteDetailScreen(note: note),
                ),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              tooltip: AppLocalizations.of(context)!.delete,
              onPressed: () => setState(() => notes.removeAt(index)),

            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarTab() {
    final weekDays = List.generate(7, (i) => _today.add(Duration(days: i)));
    return Column(
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
              final hasNotes = _notesForDay(d).isNotEmpty;
              return GestureDetector(
                onTap: () {
                  final dayNotes = _notesForDay(d);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NoteListForDayScreen(date: d, notes: dayNotes),
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
                      Text(DateFormat('E').format(d)),
                      Text('${d.day}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Notes', 'Calendar', 'Settings'];
    final pages = [
      _buildNotesTab(),
      _buildCalendarTab(),
      SettingsScreen(onThemeChanged: widget.onThemeChanged),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(titles[_currentIndex])),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _addNote, child: const Icon(Icons.add))
          : null,
    );
  }
}

