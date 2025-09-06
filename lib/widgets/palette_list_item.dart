import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../pandora_ui/tokens.dart';

/// List item displaying a color swatch with an optional icon and label.
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
    final selected = state == 'selected';

    return ListTile(
      leading: Container(
        width: PandoraTokens.iconL,
        height: PandoraTokens.iconL,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(PandoraTokens.radiusS),
        ),
      ),
      title: Text(label),
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

