import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../features/chat/domain/note_analysis.dart';

class AISuggestionsResult {
  final String summary;
  final List<String> actionItems;
  final List<String> tags;
  final List<DateTime> dates;

  AISuggestionsResult({
    required this.summary,
    required this.actionItems,
    required this.tags,
    required this.dates,
  });
}

class AISuggestionsDialog extends StatefulWidget {
  final NoteAnalysis analysis;
  final AppLocalizations l10n;
  const AISuggestionsDialog(
      {super.key, required this.analysis, required this.l10n});

  @override
  State<AISuggestionsDialog> createState() => _AISuggestionsDialogState();
}

class _AISuggestionsDialogState extends State<AISuggestionsDialog> {
  late TextEditingController _summaryCtrl;
  late TextEditingController _actionCtrl;
  late TextEditingController _tagsCtrl;
  late TextEditingController _datesCtrl;

  @override
  void initState() {
    super.initState();
    _summaryCtrl = TextEditingController(text: widget.analysis.summary);
    _actionCtrl =
        TextEditingController(text: widget.analysis.actionItems.join('\n'));
    _tagsCtrl =
        TextEditingController(text: widget.analysis.suggestedTags.join(', '));
    _datesCtrl = TextEditingController(
      text: widget.analysis.dates
          .map((d) => DateFormat('yyyy-MM-dd').format(d))
          .join(', '),
    );
  }

  @override
  void dispose() {
    _summaryCtrl.dispose();
    _actionCtrl.dispose();
    _tagsCtrl.dispose();
    _datesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.aiSuggestionsTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _summaryCtrl,
              decoration: InputDecoration(labelText: l10n.summaryLabel),
            ),
            TextField(
              controller: _actionCtrl,
              decoration: InputDecoration(labelText: l10n.actionItemsLabel),
              maxLines: null,
            ),
            TextField(
              controller: _tagsCtrl,
              decoration: InputDecoration(labelText: l10n.tagsLabel),
            ),
            TextField(
              controller: _datesCtrl,
              decoration: InputDecoration(labelText: l10n.datesLabel),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            final result = AISuggestionsResult(
              summary: _summaryCtrl.text,
              actionItems: _actionCtrl.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
              tags: _tagsCtrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
              dates: _datesCtrl.text
                  .split(',')
                  .map((e) => DateTime.tryParse(e.trim()))
                  .whereType<DateTime>()
                  .toList(),
            );
            Navigator.pop(context, result);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
