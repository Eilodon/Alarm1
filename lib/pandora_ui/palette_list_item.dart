import 'package:flutter/material.dart';

import '../theme/tokens.dart';

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
    final tokens = Theme.of(context).extension<Tokens>()!;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return ListTile(
      leading: Container(
        width: _iconSizeL,
        height: _iconSizeL,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(tokens.radii.s),
        ),
      ),
      title: Text(label, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }
}

const _iconSizeL = 32.0;
