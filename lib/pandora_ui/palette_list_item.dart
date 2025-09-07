import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';
import 'tokens.dart';

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
    final tokens = Theme.of(context).extension<Tokens>()!;
    final selected = state == 'selected';

    return ListTile(
      leading: Container(
        width: _iconSizeL,
        height: _iconSizeL,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(tokens.radii.s),
        ),
      ),
      title: Text(label),
      trailing: icon != null
          ? IconTheme.merge(
              data: IconThemeData(
                color: selected ? tokens.colors.primary : null,
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
        borderRadius: BorderRadius.circular(tokens.radii.m),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.m,
      ),
      minLeadingWidth: _touchTarget,
    );
  }
}

const _iconSizeL = 32.0;
const _touchTarget = 48.0;

