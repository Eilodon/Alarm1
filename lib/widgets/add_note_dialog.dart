import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/note_provider.dart';
import 'tag_selector.dart';

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  DateTime? _alarmTime;
  bool _locked = false;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<NoteProvider>();
    _titleCtrl = TextEditingController();
    _contentCtrl = TextEditingController(text: provider.draft);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAlarmTime() async {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<NoteProvider>();
    final availableTags = provider.notes.expand((n) => n.tags).toSet().toList();

    return AlertDialog(
      title: Text(l10n.addNoteReminder),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: l10n.titleLabel,
              ),
            ),
            TextField(
              controller: _contentCtrl,
              decoration: InputDecoration(
                labelText: l10n.contentLabel,
              ),
            ),
            TagSelector(
              availableTags: availableTags,
              selectedTags: _tags,
              allowCreate: true,
              label: l10n.tagsLabel,
              onChanged: (v) => setState(() => _tags = v),
            ),
            SwitchListTile(
              title: Text(l10n.lockNote),
              value: _locked,
              onChanged: (value) => setState(() => _locked = value),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pickAlarmTime,
              child: Text(l10n.selectReminderTime),
            ),
            if (_alarmTime != null)
              Text(
                DateFormat.yMd(Localizations.localeOf(context).toString())
                    .add_Hm()
                    .format(_alarmTime!),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            await provider.createNote(
              title: _titleCtrl.text,
              content: _contentCtrl.text,
              tags: _tags,
              locked: _locked,
              alarmTime: _alarmTime,
              l10n: l10n,
            );
            provider.setDraft('');
            if (!mounted) return;
            Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

