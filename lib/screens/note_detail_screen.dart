import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import '../services/notification_service.dart';
import '../services/tts_service.dart';
import 'chat_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  final List<String> _attachments = [];
  DateTime? _alarmTime;
  RepeatInterval? _repeat;
  int _snoozeMinutes = 5;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note.title);
    _contentCtrl = TextEditingController(text: widget.note.content);
    _alarmTime = widget.note.alarmTime;
    _repeat = widget.note.daily ? RepeatInterval.daily : null;
    _snoozeMinutes = widget.note.snoozeMinutes;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.note.title)),
      body: _buildView(),
    );
  }

  Widget _buildView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(labelText: 'Tiêu đề'),
        ),
        TextField(
          controller: _contentCtrl,
          decoration: const InputDecoration(labelText: 'Nội dung'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _pickAlarmTime,
          child: Text(
              _alarmTime != null ? 'Thời gian: $_alarmTime' : 'Chọn thời gian nhắc'),
        ),
        const SizedBox(height: 12),
        DropdownButton<RepeatInterval?>(
          value: _repeat,
          items: const [
            DropdownMenuItem(value: null, child: Text('Không lặp')),
            DropdownMenuItem(
                value: RepeatInterval.hourly, child: Text('Hằng giờ')),
            DropdownMenuItem(
                value: RepeatInterval.daily, child: Text('Hằng ngày')),
          ],
          onChanged: (val) => setState(() => _repeat = val),
        ),
        Row(
          children: [
            const Text('Snooze:'),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: _snoozeMinutes,
              items: const [
                DropdownMenuItem(value: 5, child: Text('5')),
                DropdownMenuItem(value: 10, child: Text('10')),
                DropdownMenuItem(value: 15, child: Text('15')),
              ],
              onChanged: (v) =>
                  setState(() => _snoozeMinutes = v ?? _snoozeMinutes),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: _save, child: const Text('Lưu')),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => TTSService().speak(_contentCtrl.text),
          child: const Text('Đọc Note'),
        ),
        if (_attachments.isNotEmpty) ...[
          const Divider(),
          ..._attachments.map((a) => ListTile(title: Text(a.split('/').last))),
        ],
        const Divider(),
        Expanded(child: ChatScreen(initialMessage: _contentCtrl.text)),
      ],
    );
  }

  Future<void> _pickAlarmTime() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: _alarmTime ?? now,
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime:
            _alarmTime != null ? TimeOfDay.fromDateTime(_alarmTime!) : TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _alarmTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _save() async {
    final updated = Note(
      id: widget.note.id,
      title: _titleCtrl.text,
      content: _contentCtrl.text,
      alarmTime: _alarmTime,
      daily: _repeat == RepeatInterval.daily,
      active: true,
      snoozeMinutes: _snoozeMinutes,
    );
    await context.read<NoteProvider>().updateNote(updated);

    if (_alarmTime != null) {
      final id = int.tryParse(updated.id) ??
          DateTime.now().millisecondsSinceEpoch % 100000;
      final service = NotificationService();
      if (_repeat == RepeatInterval.daily) {
        await service.scheduleDailyAtTime(
          id: id,
          title: updated.title,
          body: updated.content,
          time: Time(_alarmTime!.hour, _alarmTime!.minute),
        );
      } else if (_repeat != null) {
        await service.scheduleRecurring(
          id: id,
          title: updated.title,
          body: updated.content,
          repeatInterval: _repeat!,
        );
      } else {
        await service.scheduleNotification(
          id: id,
          title: updated.title,
          body: updated.content,
          scheduledDate: _alarmTime!,
        );
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
  }
}
