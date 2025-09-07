import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../features/note/note.dart';
import 'tag_selector.dart';
import '../l10n/localization_extensions.dart';

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  final _formKey = GlobalKey<FormState>();
  DateTime? _alarmTime;
  bool _locked = false;
  List<String> _tags = [];
  int _color = 0xFFFFFFFF;
  bool _pinned = false;
  bool _isValid = false;

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

  void _validate() {
    setState(() {
      _isValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<NoteProvider>();
    final availableTags = provider.notes.expand((n) => n.tags).toSet().toList();

    return AlertDialog(
      title: Text(l10n.addNoteReminder),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          onChanged: _validate,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: l10n.titleLabel,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.fieldRequired : null,
              ),
              TextFormField(
                controller: _contentCtrl,
                decoration: InputDecoration(
                  labelText: l10n.contentLabel,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.fieldRequired : null,
              ),
              TagSelector(
                availableTags: availableTags,
                selectedTags: _tags,
                allowCreate: true,
                label: l10n.tagsLabel,
                onChanged: (v) => setState(() => _tags = v),
                selectedColor: _color,
                onColorChanged: (c) => setState(() => _color = c),
                colorLabel: l10n.colorLabel,
              ),
              SwitchListTile(
                title: Text(l10n.lockNote),
                value: _locked,
                onChanged: (value) => setState(() => _locked = value),
              ),
              SwitchListTile(
                title: Text(l10n.pinNote),
                value: _pinned,
                onChanged: (v) => setState(() => _pinned = v),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isValid
              ? () async {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  final ok = await provider.createNote(
                    title: _titleCtrl.text,
                    content: _contentCtrl.text,
                    tags: _tags,
                    locked: _locked,
                    color: _color,
                    pinned: _pinned,
                    alarmTime: _alarmTime,
                    l10n: l10n,
                  );
                  if (!mounted) return;
                  if (ok) {
                    provider.setDraft('');
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.errorWithMessage(l10n.networkError),
                        ),
                      ),
                    );
                  }
                }
              : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

