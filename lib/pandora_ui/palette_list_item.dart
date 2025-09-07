import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

/// Simple list item displaying a color swatch with a label.
class PaletteListItem extends StatelessWidget {
  const PaletteListItem({
    super.key,
    required this.color,
    required this.label,
    this.icon,
    this.state = 'default',
    this.onTap,
  });

  final Color color;
  final String label;
  final Widget? icon;
  final String state;
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
      title: Text(label, style: baseStyle?.copyWith(color: textColor)),
      trailing: icon != null
          ? IconTheme.merge(
              data: IconThemeData(
                color: selected ? PandoraTokens.primary : null,
              ),
              child: icon!,
            )
          : null,
      onTap: onTap != null
          ? () {
              HapticFeedback.selectionClick();
              onTap!();
            }
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PandoraTokens.radiusM),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: PandoraTokens.spacingM,
      ),
      minLeadingWidth: PandoraTokens.touchTarget,
    );
  }
}

const _iconSizeL = 32.0;
