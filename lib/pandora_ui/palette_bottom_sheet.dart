import 'package:flutter/material.dart';
import 'package:fuse/fuse.dart';

import '../models/command.dart';

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
  late final Fuse<Command> _fuse;
  late List<Command> _results;

  @override
  void initState() {
    super.initState();
    _fuse = Fuse(widget.commands,
        options: FuseOptions(keys: ['title', 'description']));
    _results = widget.commands;
  }

  void _onQueryChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _results = widget.commands;
      } else {
        _results =
            _fuse.search(query).map((result) => result.item).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                decoration: const InputDecoration(
                  hintText: 'Type a command...',
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

