import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
 codex/expand-note-model-with-new-fields
import 'package:lottie/lottie.dart';
 codex/enable-material-3-and-customize-theme
import 'package:quick_actions/quick_actions.dart';


import '../models/note.dart';
import '../providers/note_provider.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../widgets/tag_selector.dart';
import 'note_detail_screen.dart';
import 'note_list_for_day_screen.dart';
import 'note_search_delegate.dart';
import 'settings_screen.dart';


class HomeScreen extends StatefulWidget {
  final Function(Color) onThemeChanged;
  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _platform = MethodChannel('notes_reminder_app/actions');

  String _mascotPath = 'assets/lottie/mascot.json';
 codex/enable-material-3-and-customize-theme
  final List<Note> _notes = [];
  DateTime _today = DateTime.now();
  int _currentIndex = 0;


  @override
  void initState() {
    super.initState();
    _loadMascot();
 codex/enable-material-3-and-customize-theme
    _setupQuickActions();
    _platform.setMethodCallHandler((call) async {
      if (call.method == 'quick_add') {
        _addNote();
      }
    });
  }

  void _setupQuickActions() {
    const quickActions = QuickActions();
    quickActions.initialize((type) {
      if (type == 'action_add') {
        _addNote();
      } else if (type == 'action_search') {
        _startSearch();
      }
    });
    quickActions.setShortcutItems(const [
      ShortcutItem(type: 'action_add', localizedTitle: 'New Note'),
      ShortcutItem(type: 'action_search', localizedTitle: 'Search'),
    ]);

  }

  Future<void> _loadMascot() async {
    _mascotPath = await SettingsService().loadMascotPath();
    if (mounted) setState(() {});
  }

  void _addNote() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    DateTime? alarmTime;
    RepeatInterval? repeat;
    int snoozeMinutes = 5;

    showDialog(
      context: context,
 codex/expand-note-model-with-new-fields
      builder: (_) => AlertDialog(
        title: const Text('Thêm ghi chú / nhắc lịch'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Tiêu đề')),
              TextField(
                  controller: contentCtrl,
                  decoration: const InputDecoration(labelText: 'Nội dung')),
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
 codex/expand-note-model-with-new-fields
                    if (!mounted) return;
                    if (time != null) {
 codex/enable-material-3-and-customize-theme
                      alarmTime = DateTime(

                        picked.year,
                        picked.month,
                        picked.day,
                        time.hour,
                        time.minute,
 codex/enable-material-3-and-customize-theme

                      );
                      if (!mounted) return;
                      if (time != null) {
                        alarmTime = DateTime(
                          picked.year, picked.month, picked.day,
                          time.hour, time.minute,
                        );
                      }
                    }
                  },
                  child: const Text('Chọn thời gian nhắc'),
                ),
                const SizedBox(height: 12),
                DropdownButton<RepeatInterval?>(
                  value: repeat,
                  items: const [
                    DropdownMenuItem(
                        value: null, child: Text('Không lặp')),
                    DropdownMenuItem(
                        value: RepeatInterval.hourly, child: Text('Hằng giờ')),
                    DropdownMenuItem(
                        value: RepeatInterval.daily, child: Text('Hằng ngày')),
                  ],
                  onChanged: (val) => setInnerState(() => repeat = val),
                ),
                Row(
                  children: [
                    const Text('Snooze:'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: snoozeMinutes,
                      items: const [
                        DropdownMenuItem(value: 5, child: Text('5')),
                        DropdownMenuItem(value: 10, child: Text('10')),
                        DropdownMenuItem(value: 15, child: Text('15')),
                      ],
                      onChanged: (v) =>
                          setInnerState(() => snoozeMinutes = v ?? snoozeMinutes),
                    ),
                  ],
                ),
              ],
            ),
          ),
 codex/update-homescreenstate-to-manage-notes
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final note = Note(
 codex/expand-note-model-with-new-fields
                id: DateTime.now().millisecondsSinceEpoch.toString(),

                title: titleCtrl.text,
                content: contentCtrl.text,
                alarmTime: remindAt,
              );
 codex/enable-material-3-and-customize-theme
              setState(() => _notes.add(note));

              if (remindAt != null) {
                await NotificationService().scheduleNotification(
                  id: DateTime.now().millisecondsSinceEpoch % 100000,
                  title: note.title,
                  body: note.content,
                  scheduledDate: remindAt!,
                );
              }
 codex/enable-material-3-and-customize-theme
              _updateWidget(note);
              if (!mounted) return;

              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],

      ),
    );
  }

 codex/enable-material-3-and-customize-theme
  void _startSearch() {
    showSearch(context: context, delegate: NoteSearchDelegate(_notes));
  }

  void _updateWidget(Note note) {
    _platform.invokeMethod('updateWidget', {'latestNote': note.title});
  }

  List<Note> _notesForDay(DateTime day) {
    return _notes

        .where((n) =>
            n.alarmTime != null &&
            n.alarmTime!.year == day.year &&
            n.alarmTime!.month == day.month &&
            n.alarmTime!.day == day.day)
        .toList();
  }

 codex/enable-material-3-and-customize-theme
  Widget _buildNotesTab() {
    if (_notes.isEmpty) {
      return const Center(child: Text('Chưa có ghi chú nào'));
    }

    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Card(
          child: ListTile(
            title: Text(note.title),
 codex/expand-note-model-with-new-fields

            subtitle: Text(note.alarmTime != null
                ? '${note.content}\n⏰ ${note.alarmTime}'
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
 codex/enable-material-3-and-customize-theme
              onPressed: () => setState(() => _notes.removeAt(index)),

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

