import 'package:flutter/material.dart';

import 'tokens.dart';

/// Simple list item displaying a color swatch with a label.
class PaletteListItem extends StatelessWidget {
  const PaletteListItem({
    super.key,
    required this.color,
    required this.label,
    this.onTap,
  });

  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    final textColor = baseStyle?.color;
    return ListTile(
      leading: Container(
        width: PandoraTokens.iconL,
        height: PandoraTokens.iconL,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(PandoraTokens.radiusS),
        ),
      ),
      title: Text(label, style: baseStyle?.copyWith(color: textColor)),
      onTap: onTap,
    );
  }
}
