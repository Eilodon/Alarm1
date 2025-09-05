import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../services/notification_service.dart';
import '../services/tts_service.dart';
import '../services/gemini_service.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart';
import '../widgets/tag_selector.dart';


class NoteDetailScreen extends StatefulWidget {
  final Note note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late List<String> _attachments;
  DateTime? _alarmTime;
  RepeatInterval? _repeat;
  int _snoozeMinutes = 5;
  late List<String> _tags;


  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note.title);
    _contentCtrl = TextEditingController(text: widget.note.content);
    _alarmTime = widget.note.alarmTime;
    _repeat = widget.note.daily ? RepeatInterval.daily : null;
    _snoozeMinutes = widget.note.snoozeMinutes;
    _attachments = List.from(widget.note.attachments);
    _tags = List.from(widget.note.tags);
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    final availableTags =
        provider.notes.expand((n) => n.tags).toSet().toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.titleLabel,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.contentLabel,
              ),
              maxLines: null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickAlarmTime,
                  child: Text(
                      AppLocalizations.of(context)!.selectReminderTime),
                ),
                if (_alarmTime != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(DateFormat('HH:mm dd/MM/yyyy').format(_alarmTime!)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TagSelector(
              availableTags: availableTags,
              selectedTags: _tags,
              allowCreate: true,
              onChanged: (v) => setState(() => _tags = v),
              label: AppLocalizations.of(context)!.tagsLabel,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Image'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _pickAudio,
                  icon: const Icon(Icons.audiotrack),
                  label: const Text('Audio'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._attachments.map(
              (a) => ListTile(title: Text(a.split('/').last)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: ChatScreen(initialMessage: _contentCtrl.text),
            ),
          ],
        ),
      ),
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
    final updated = widget.note.copyWith(
      title: _titleCtrl.text,
      content: _contentCtrl.text,
      tags: _tags,
      attachments: _attachments,
      alarmTime: _alarmTime,
      daily: _repeat == RepeatInterval.daily,
      active: true,
      snoozeMinutes: _snoozeMinutes,
      updatedAt: DateTime.now(),
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

