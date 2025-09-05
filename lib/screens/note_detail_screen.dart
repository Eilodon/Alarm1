import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../services/notification_service.dart';
import '../services/tts_service.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart';
import '../widgets/tag_selector.dart';
import '../services/gemini_service.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  final TTSService ttsService;
  const NoteDetailScreen({super.key, required this.note, TTSService? ttsService})
      : ttsService = ttsService ?? TTSService();

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
  late final TTSService _ttsService;

  @override
  void initState() {
    super.initState();
    _ttsService = widget.ttsService;
    _titleCtrl = TextEditingController(text: widget.note.title);
    _contentCtrl = TextEditingController(text: widget.note.content);
    _alarmTime = widget.note.alarmTime;
    _repeat =
        widget.note.repeatInterval ??
        (widget.note.daily ? RepeatInterval.daily : null);
    _snoozeMinutes = widget.note.snoozeMinutes;
    _attachments = List.from(widget.note.attachments);
    _tags = List.from(widget.note.tags);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
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

  Future<void> _readNote() async {
    await _ttsService.speak(
      _contentCtrl.text,
      locale: Localizations.localeOf(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    final availableTags = provider.notes.expand((n) => n.tags).toSet().toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.title),
        actions: [
          TextButton(
            onPressed: _readNote,
            child: Text(AppLocalizations.of(context)!.readNote),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () =>
                Share.share('${_titleCtrl.text}\n${_contentCtrl.text}'),
          ),
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
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
                  child: Text(AppLocalizations.of(context)!.selectReminderTime),
                ),
                if (_alarmTime != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      DateFormat.yMd(Localizations.localeOf(context).toString())
                          .add_Hm()
                          .format(_alarmTime!),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(AppLocalizations.of(context)!.repeatLabel),
                const SizedBox(width: 8),
                DropdownButton<RepeatInterval?>(
                  value: _repeat,
                  onChanged: (value) => setState(() => _repeat = value),
                  items: [
                    DropdownMenuItem<RepeatInterval?>(
                      value: null,
                      child: Text(AppLocalizations.of(context)!.repeatNone),
                    ),
                    DropdownMenuItem<RepeatInterval?>(
                      value: RepeatInterval.everyMinute,
                      child: Text(
                        AppLocalizations.of(context)!.repeatEveryMinute,
                      ),
                    ),
                    DropdownMenuItem<RepeatInterval?>(
                      value: RepeatInterval.hourly,
                      child: Text(AppLocalizations.of(context)!.repeatHourly),
                    ),
                    DropdownMenuItem<RepeatInterval?>(
                      value: RepeatInterval.daily,
                      child: Text(AppLocalizations.of(context)!.repeatDaily),
                    ),
                    DropdownMenuItem<RepeatInterval?>(
                      value: RepeatInterval.weekly,
                      child: Text(AppLocalizations.of(context)!.repeatWeekly),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.snoozeLabel(_snoozeMinutes)),
            Slider(
              value: _snoozeMinutes.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              label: _snoozeMinutes.toString(),
              onChanged: (v) => setState(() => _snoozeMinutes = v.round()),
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
                  label: Text(AppLocalizations.of(context)!.imageLabel),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _pickAudio,
                  icon: const Icon(Icons.audiotrack),
                  label: Text(AppLocalizations.of(context)!.audioLabel),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._attachments.map(
              (a) => ListTile(title: Text(a.split('/').last)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatScreen(initialMessage: _contentCtrl.text),
                  ),
                );
              },
              icon: const Icon(Icons.chat),
              label: Text(AppLocalizations.of(context)!.chatAI),
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
        initialTime: _alarmTime != null
            ? TimeOfDay.fromDateTime(_alarmTime!)
            : TimeOfDay.now(),
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
    final l10n = AppLocalizations.of(context)!;

    final analysis = await GeminiService().analyzeNote(_contentCtrl.text);
    String summary = widget.note.summary;
    List<String> actionItems = List.from(widget.note.actionItems);
    List<DateTime> dates = List.from(widget.note.dates);
    var tags = List<String>.from(_tags);

    if (analysis != null) {
      final summaryCtrl = TextEditingController(text: analysis.summary);
      final actionCtrl =
          TextEditingController(text: analysis.actionItems.join('\n'));
      final tagsCtrl =
          TextEditingController(text: analysis.suggestedTags.join(', '));
      final datesCtrl = TextEditingController(
          text: analysis.dates
              .map((d) => DateFormat('yyyy-MM-dd').format(d))
              .join(', '));

      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.aiSuggestionsTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: summaryCtrl,
                  decoration: InputDecoration(labelText: l10n.summaryLabel),
                ),
                TextField(
                  controller: actionCtrl,
                  decoration:
                      InputDecoration(labelText: l10n.actionItemsLabel),
                  maxLines: null,
                ),
                TextField(
                  controller: tagsCtrl,
                  decoration: InputDecoration(labelText: l10n.tagsLabel),
                ),
                TextField(
                  controller: datesCtrl,
                  decoration: InputDecoration(labelText: l10n.datesLabel),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.save),
            ),
          ],
        ),
      );

      if (accepted == true) {
        summary = summaryCtrl.text;
        actionItems = actionCtrl.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        tags = tagsCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        dates = datesCtrl.text
            .split(',')
            .map((e) => DateTime.tryParse(e.trim()))
            .whereType<DateTime>()
            .toList();
      }
    }

    final service = NotificationService();
    final oldId = widget.note.notificationId;
    if (oldId != null) {
      await service.cancel(oldId);
    }

    int? newId;
    if (_alarmTime != null) {
      newId = Random().nextInt(1 << 31);
    }

    final updated = widget.note.copyWith(
      title: _titleCtrl.text,
      content: _contentCtrl.text,
      tags: tags,
      attachments: _attachments,
      alarmTime: _alarmTime,
      repeatInterval: _repeat,
      daily: _repeat == RepeatInterval.daily,
      active: true,
      snoozeMinutes: _snoozeMinutes,
      updatedAt: DateTime.now(),
      notificationId: newId,
      summary: summary,
      actionItems: actionItems,
      dates: dates,
    );
    await context.read<NoteProvider>().updateNote(updated);

    if (_alarmTime != null && newId != null) {
      if (_repeat == RepeatInterval.daily) {
        await service.scheduleDailyAtTime(
          id: newId,
          title: updated.title,
          body: updated.content,
          time: Time(_alarmTime!.hour, _alarmTime!.minute),
          l10n: l10n,
        );
      } else if (_repeat != null) {
        await service.scheduleRecurring(
          id: newId,
          title: updated.title,
          body: updated.content,
          repeatInterval: _repeat!,
          l10n: l10n,
        );
      } else {
        await service.scheduleNotification(
          id: newId,
          title: updated.title,
          body: updated.content,
          scheduledDate: _alarmTime!,
          l10n: l10n,
        );
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
  }
}
