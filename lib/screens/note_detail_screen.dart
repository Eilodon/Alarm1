import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_plus/share_plus.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import '../services/tts_service.dart';
import '../widgets/tag_selector.dart';
import '../services/gemini_service.dart';
import '../widgets/attachment_section.dart';
import '../widgets/reminder_controls.dart';
import '../widgets/ai_suggestions_dialog.dart';
import 'chat_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  final TTSService ttsService;
  const NoteDetailScreen({
    super.key,
    required this.note,
    TTSService? ttsService,
  }) : ttsService = ttsService ?? TTSService();

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
  String? _titleSuggestion;
  List<String> _tagSuggestions = [];
  NoteAnalysis? _analysis;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ttsService = widget.ttsService;
    _titleCtrl = TextEditingController(text: widget.note.title);
    _contentCtrl = TextEditingController(text: widget.note.content);
    _contentCtrl.addListener(_onContentChanged);
    _alarmTime = widget.note.alarmTime;
    _repeat = widget.note.repeatInterval ??
        (widget.note.daily ? RepeatInterval.daily : null);
    _snoozeMinutes = widget.note.snoozeMinutes;
    _attachments = List.from(widget.note.attachments);
    _tags = List.from(widget.note.tags);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _contentCtrl.removeListener(_onContentChanged);
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _readNote() async {
    await _ttsService.speak(
      _contentCtrl.text,
      locale: Localizations.localeOf(context),
    );
  }

  void _onContentChanged() {
    _debounce?.cancel();
    if (_contentCtrl.text.trim().isEmpty) {
      setState(() {
        _analysis = null;
        _titleSuggestion = null;
        _tagSuggestions = [];
      });
      return;
    }
    _debounce = Timer(const Duration(seconds: 1), () async {
      final analysis = await GeminiService().analyzeNote(_contentCtrl.text);
      if (!mounted) return;
      setState(() {
        _analysis = analysis;
        _titleSuggestion = analysis?.suggestedTitle;
        _tagSuggestions = analysis?.suggestedTags
                .where((t) => !_tags.contains(t))
                .toList() ??
            [];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    final availableTags = provider.notes.expand((n) => n.tags).toSet().toList();
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: widget.note.id,
          child: Material(
            color: Colors.transparent,
            child: Text(widget.note.title),
          ),
        ),
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
            if (_titleSuggestion != null || _tagSuggestions.isNotEmpty)
              Wrap(
                spacing: 8,
                children: [
                  if (_titleSuggestion != null)
                    InputChip(
                      label: Text(_titleSuggestion!),
                      onPressed: () {
                        setState(() {
                          _titleCtrl.text = _titleSuggestion!;
                          _titleSuggestion = null;
                        });
                      },
                      onDeleted: () =>
                          setState(() => _titleSuggestion = null),
                    ),
                  ..._tagSuggestions.map(
                    (tag) => InputChip(
                      label: Text(tag),
                      onPressed: () {
                        setState(() {
                          if (!_tags.contains(tag)) {
                            _tags.add(tag);
                          }
                          _tagSuggestions.remove(tag);
                        });
                      },
                      onDeleted: () =>
                          setState(() => _tagSuggestions.remove(tag)),
                    ),
                  ),
                ],
              ),
            if (_titleSuggestion != null || _tagSuggestions.isNotEmpty)
              const SizedBox(height: 12),
            ReminderControls(
              alarmTime: _alarmTime,
              repeat: _repeat,
              snoozeMinutes: _snoozeMinutes,
              onAlarmTimeChanged: (v) => setState(() => _alarmTime = v),
              onRepeatChanged: (v) => setState(() => _repeat = v),
              onSnoozeChanged: (v) => setState(() => _snoozeMinutes = v),
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
            AttachmentSection(
              attachments: _attachments,
              onChanged: (v) => setState(() => _attachments = v),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) =>
                        ChatScreen(initialMessage: _contentCtrl.text),
                    transitionsBuilder: (_, animation, __, child) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
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

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;

    final analysis =
        _analysis ?? await GeminiService().analyzeNote(_contentCtrl.text);
    String summary = widget.note.summary;
    List<String> actionItems = List.from(widget.note.actionItems);
    List<DateTime> dates = List.from(widget.note.dates);
    var tags = List<String>.from(_tags);

    if (analysis != null) {
      final result = await showDialog<AISuggestionsResult>(
        context: context,
        builder: (context) =>
            AISuggestionsDialog(analysis: analysis, l10n: l10n),
      );
      if (result != null) {
        summary = result.summary;
        actionItems = result.actionItems;
        tags = result.tags;
        dates = result.dates;
      }
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
      summary: summary,
      actionItems: actionItems,
      dates: dates,
    );

    final ok = await context.read<NoteProvider>().saveNote(updated, l10n);

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveNoteFailed)),
      );
    }
  }
}
