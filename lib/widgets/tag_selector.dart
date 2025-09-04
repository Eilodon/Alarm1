import 'package:flutter/material.dart';

class TagSelector extends StatefulWidget {
  final List<String> availableTags;
  final List<String> selectedTags;
  final ValueChanged<List<String>> onChanged;
  final bool allowCreate;
  final String? label;

  const TagSelector({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onChanged,
    this.allowCreate = false,
    this.label,
  });

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  final TextEditingController _ctrl = TextEditingController();

  void _addTag(String tag) {
    final t = tag.trim();
    if (t.isEmpty) return;
    final newSelected = [...widget.selectedTags];
    if (!newSelected.contains(t)) {
      newSelected.add(t);
    }
    widget.onChanged(newSelected);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chips = widget.availableTags.map((t) {
      final selected = widget.selectedTags.contains(t);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilterChip(
          label: Text(t),
          selected: selected,
          onSelected: (v) {
            final newSelected = [...widget.selectedTags];
            if (v) {
              newSelected.add(t);
            } else {
              newSelected.remove(t);
            }
            widget.onChanged(newSelected);
          },
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) Text(widget.label!),
        Wrap(children: chips),
        if (widget.allowCreate)
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(labelText: 'Thêm tag'),
            onSubmitted: _addTag,
          ),
      ],
    );
  }
}

