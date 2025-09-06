import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TagFilterMenu extends StatelessWidget {
  final List<String> tags;
  final String? selectedTag;
  final ValueChanged<String?> onSelected;

  const TagFilterMenu({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      icon: const Icon(Icons.label),
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem<String?>(
          value: null,
          child: Text(AppLocalizations.of(context)!.allTags),
        ),
        ...tags.map((t) => PopupMenuItem<String?>(value: t, child: Text(t))),
      ],
    );
  }
}
