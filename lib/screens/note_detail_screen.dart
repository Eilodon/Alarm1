import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import '../services/notification_service.dart';

import '../services/tts_service.dart';
import '../services/gemini_service.dart';


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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _attachments.add(file.path));
    }
  }

  Future<void> _pickAudio() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (res != null && res.files.single.path != null) {
      setState(() => _attachments.add(res.files.single.path!));
    }
  }

  void _save() {
    widget.note
      ..title = _titleCtrl.text
      ..content = _contentCtrl.text
      ..tags = _tags
      ..attachments = _attachments
      ..updatedAt = DateTime.now();
    context.read<NoteProvider>().updateNote(widget.note);
    setState(() => _editing = false);

  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(note.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${AppLocalizations.of(context)!.contentLabel}: ${note.content}',
              style: const TextStyle(fontSize: 16)),
          if (note.alarmTime != null)
            Text('${AppLocalizations.of(context)!.timeLabel}: ${note.alarmTime}',
                style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => TTSService().speak(note.content),
            child: Text(AppLocalizations.of(context)!.readNote),
          ),

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

