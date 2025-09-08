import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:notes_reminder_app/generated/app_localizations.dart';

import 'package:alarm_domain/alarm_domain.dart';

/// Opens a command palette bottom sheet.
Future<void> showPaletteBottomSheet(
  BuildContext context, {
  required List<Command> commands,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _PaletteBottomSheet(commands: commands),
  );
}

class _PaletteBottomSheet extends StatefulWidget {
  final List<Command> commands;

  const _PaletteBottomSheet({required this.commands});

  @override
  State<_PaletteBottomSheet> createState() => _PaletteBottomSheetState();
}

class _PaletteBottomSheetState extends State<_PaletteBottomSheet> {
  late final Fuzzy<Command> _fuzzy;
  late List<Command> _results;

  @override
  void initState() {
    super.initState();
    _fuzzy = Fuzzy(
      widget.commands,
      options: FuzzyOptions(
        keys: [
          WeightedKey<Command>(
            name: 'title',
            getter: (c) => c.title,
            weight: 1,
          ),
          WeightedKey<Command>(
            name: 'description',
            getter: (c) => c.description ?? '',
            weight: 1,
          ),
        ],
      ),
    );
    _results = widget.commands;
  }

  void _onQueryChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _results = widget.commands;
      } else {
        _results =
            _fuzzy.search(query).map((result) => result.item).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                onChanged: _onQueryChanged,
                decoration: InputDecoration(
                  hintText: l10n.searchCommandHint,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final command = _results[index];
                  return ListTile(
                    title: Text(command.title),
                    subtitle: command.description != null
                        ? Text(command.description!)
                        : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      command.action();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

