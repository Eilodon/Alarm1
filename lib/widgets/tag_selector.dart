import 'package:flutter/material.dart';
import 'package:pandora/generated/app_localizations.dart';
import 'package:pandora/theme/tokens.dart';

class TagSelector extends StatefulWidget {
  final List<String> availableTags;
  final List<String> selectedTags;
  final ValueChanged<List<String>> onChanged;
  final bool allowCreate;
  final String? label;
  final int selectedColor;
  final ValueChanged<int> onColorChanged;
  final String? colorLabel;

  const TagSelector({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onChanged,
    this.allowCreate = false,
    this.label,
    required this.selectedColor,
    required this.onColorChanged,
    this.colorLabel,
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
    final scheme = Theme.of(context).colorScheme;
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

    final tokens = Theme.of(context).extension<Tokens>()!;
    final colorOptions = <Color, String>{
      scheme.primary: AppLocalizations.of(context)!.primary,
      scheme.secondary: AppLocalizations.of(context)!.secondary,
      scheme.tertiary: 'Tertiary',
      scheme.error: 'Error',
      tokens.colors.warning: 'Warning',
      tokens.colors.info: 'Info',
      tokens.colors.neutral700: 'Neutral dark',
      tokens.colors.neutral300: 'Neutral light',
    };
    final colorChips = colorOptions.entries.map((entry) {
      final color = entry.key;
      final label = entry.value;
      final selected = widget.selectedColor == color.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Tooltip(
          message: label,
          child: Semantics(
            label: label,
            child: ChoiceChip(
              label: const SizedBox(width: 24, height: 24),
              selectedColor: color,
              backgroundColor: color,
              selected: selected,
              onSelected: (_) => widget.onColorChanged(color.value),
            ),
          ),
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
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.addTag,
            ),
            onSubmitted: _addTag,
          ),
        if (widget.colorLabel != null) ...[
          const SizedBox(height: 8),
          Text(widget.colorLabel!),
        ],
        Wrap(children: colorChips),
      ],
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

