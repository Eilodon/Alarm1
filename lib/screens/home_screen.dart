import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import 'note_detail_screen.dart';
import 'note_list_for_day_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(Color) onThemeChanged;
  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _mascotPath = 'assets/lottie/mascot.json';
  DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMascot();
  }

  Future<void> _loadMascot() async {
    _mascotPath = await SettingsService().loadMascotPath();
    setState(() {});
  }

  void _addNote() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    DateTime? alarmTime;
    RepeatInterval? repeat;
    int snoozeMinutes = 5;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                  onChanged: (val) => setState(() => repeat = val),
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
                          setState(() => snoozeMinutes = v ?? snoozeMinutes),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy')),
              ElevatedButton(
              onPressed: () async {
                final note = Note(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleCtrl.text,
                  content: contentCtrl.text,
                  alarmTime: alarmTime,
                  daily: repeat == RepeatInterval.daily,
                  active: true,
                  snoozeMinutes: snoozeMinutes,
                );
                await context.read<NoteProvider>().addNote(note);

                if (alarmTime != null) {
                  final id = DateTime.now().millisecondsSinceEpoch % 100000;
                  final service = NotificationService();
                  if (repeat == RepeatInterval.daily) {
                    await service.scheduleDailyAtTime(
                      id: id,
                      title: note.title,
                      body: note.content,
                      time: Time(alarmTime!.hour, alarmTime!.minute),
                    );
                  } else if (repeat != null) {
                    await service.scheduleRecurring(
                      id: id,
                      title: note.title,
                      body: note.content,
                      repeatInterval: repeat!,
                    );
                  } else {
                    await service.scheduleNotification(
                      id: id,
                      title: note.title,
                      body: note.content,
                      scheduledDate: alarmTime!,
                    );
                  }
                }
                if (!mounted) return;
                Navigator.pop(context); // FIX Lỗi 1: auto đóng dialog
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
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
    final notes = context.watch<NoteProvider>().notes;
    final weekDays = List.generate(7, (i) => today.add(Duration(days: i)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes & Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(onThemeChanged: widget.onThemeChanged),
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
                    final dayNotes = notesForDay(d);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteListForDayScreen(date: d, notes: dayNotes),
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
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNotesList() {
    final notes = context.watch<NoteProvider>().notes;
    if (notes.isEmpty) {
      return const Center(child: Text('Chưa có ghi chú nào'));
    }
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          child: ListTile(
            title: Text(note.title),
            subtitle: Text(
              note.alarmTime != null
                  ? '${note.content}\n⏰ ${note.alarmTime}'
                  : note.content,
            ),
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
              onPressed: () =>
                  context.read<NoteProvider>().removeNoteAt(index),
            ),
          ),
        );
      },
    );
  }
}
