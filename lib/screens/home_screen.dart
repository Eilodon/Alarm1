import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/note.dart';
import '../services/db_service.dart';
import '../services/notification_service.dart';
import 'note_detail_screen.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DbService();
  final _notif = NotificationService();
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _db.getNotes();
    setState(() => _notes = data);
  }

  Future<void> _createNoteQuick() async {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    TimeOfDay? pickedTime;
    bool repeatDaily = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 16),
        child: StatefulBuilder(builder: (ctx, setStateBS) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 4, width: 40, margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề')),
                const SizedBox(height: 8),
                TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'Nội dung'), maxLines: 4),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final now = TimeOfDay.now();
                        final t = await showTimePicker(context: context, initialTime: now);
                        if (t != null) setStateBS(() => pickedTime = t);
                      },
                      child: Text(pickedTime == null ? 'Chọn giờ báo' : 'Giờ: ${pickedTime!.format(context)}')),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Switch(
                          value: repeatDaily,
                          onChanged: (v) => setStateBS(() => repeatDaily = v),
                        ),
                        const Text('Nhắc hằng ngày'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'title': titleCtrl.text.trim(),
                        'content': contentCtrl.text.trim(),
                        'time': pickedTime,
                        'daily': repeatDaily,
                      });
                    },
                    child: const Text('Tạo ghi chú'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        }),
      ),
    ).then((value) async {
      if (value == null) return;
      final id = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(999).toString();
      final title = value['title'] as String;
      final content = value['content'] as String;
      final t = value['time'] as TimeOfDay?;
      final daily = value['daily'] as bool;

      DateTime? alarm;
      if (t != null) {
        final now = DateTime.now();
        alarm = DateTime(now.year, now.month, now.day, t.hour, t.minute);
      }

      final n = Note(
        id: id,
        title: title.isEmpty ? 'No title' : title,
        content: content,
        alarmTime: alarm,
        daily: daily,
        active: t != null,
      );
      final list = [..._notes, n];
      await _db.saveNotes(list);
      setState(() => _notes = list);

      if (n.active && n.alarmTime != null) {
        if (n.daily) {
          await _notif.scheduleDaily(
            id: n.id.hashCode,
            title: n.title,
            body: 'Đến giờ: ${n.title}',
            hour: n.alarmTime!.hour,
            minute: n.alarmTime!.minute,
          );
        } else {
          await _notif.scheduleOnce(
            id: n.id.hashCode,
            title: n.title,
            body: 'Đến giờ: ${n.title}',
            whenLocal: n.alarmTime!,
          );
        }
      }
    });
  }

  Future<void> _toggleActive(Note n) async {
    final idx = _notes.indexWhere((e) => e.id == n.id);
    if (idx < 0) return;
    final updated = [..._notes];
    final cur = updated[idx];
    final newVal = !cur.active;
    updated[idx] = Note(
      id: cur.id,
      title: cur.title,
      content: cur.content,
      alarmTime: cur.alarmTime,
      daily: cur.daily,
      active: newVal,
    );
    await _db.saveNotes(updated);
    setState(() => _notes = updated);

    if (newVal) {
      if (cur.alarmTime != null) {
        if (cur.daily) {
          await NotificationService().scheduleDaily(
            id: cur.id.hashCode,
            title: cur.title,
            body: 'Đến giờ: ${cur.title}',
            hour: cur.alarmTime!.hour,
            minute: cur.alarmTime!.minute,
          );
        } else {
          await NotificationService().scheduleOnce(
            id: cur.id.hashCode,
            title: cur.title,
            body: 'Đến giờ: ${cur.title}',
            whenLocal: cur.alarmTime!,
          );
        }
      }
    } else {
      await NotificationService().cancel(cur.id.hashCode);
    }
  }

  Future<void> _delete(Note n) async {
    final list = _notes.where((e) => e.id != n.id).toList();
    await _db.saveNotes(list);
    setState(() => _notes = list);
    await NotificationService().cancel(n.id.hashCode);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm, dd/MM');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () => NotificationService().showNow(
              id: 9999,
              title: 'Test',
              body: 'Thông báo thử',
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNoteQuick,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Create your daily task',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Lottie.asset('assets/lottie/mascot.json', repeat: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('You have ${_notes.length} task${_notes.length != 1 ? 's' : ''} today',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          ..._notes.map((n) {
            final subtitle = n.alarmTime != null
                ? (n.daily
                    ? 'Hằng ngày • ${DateFormat('HH:mm').format(n.alarmTime!)}'
                    : 'Một lần • ${fmt.format(n.alarmTime!)}')
                : 'Không đặt báo';
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text(n.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(subtitle),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(value: n.active, onChanged: (_) => _toggleActive(n)),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(n)),
                  ],
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NoteDetailScreen(note: n)),
                  );
                  _load();
                },
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
