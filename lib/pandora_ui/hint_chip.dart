import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';


class _ChipStyle {
  final Color background;
  final Color text;
  final double opacity;

  const _ChipStyle({
    required this.background,
    required this.text,
    required this.opacity,
  });
}


const _opacityDisabled = 0.5;
const _opacityFocus = 0.85;
const _opacityEnabled = 1.0;
const _iconSizeS = 20.0;
const _hintIcon = Icons.lightbulb_outline;


class HintChip extends StatelessWidget {
  final String label;
  final Widget? icon;
  final String state;
  final VoidCallback onPressed;
  final TextStyle? style;

  const HintChip({
    Key? key,
    required this.label,
    this.icon,
    this.state = 'default',
    required this.onPressed,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<Tokens>()!;

    final chipStyles = {
      'default': _ChipStyle(
        background: tokens.colors.neutral200,
        text: tokens.colors.neutral900,
        opacity: _opacityDisabled,
      ),
      'armed': _ChipStyle(
        background: tokens.colors.error,
        text: tokens.colors.neutral100,
        opacity: _opacityFocus,
      ),
      'active': _ChipStyle(
        background: tokens.colors.secondary,
        text: tokens.colors.neutral100,
        opacity: _opacityEnabled,
      ),
    };

    final _ChipStyle styleData =
        chipStyles[state] ?? chipStyles['default']!;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(tokens.radii.m),
      child: Ink(
        decoration: BoxDecoration(
          color: styleData.background.withOpacity(styleData.opacity),
          borderRadius: BorderRadius.circular(tokens.radii.m),
        ),
        padding: EdgeInsets.all(tokens.spacing.m),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _hintIcon,
              size: _iconSizeS,
              color: tokens.colors.warning,
            ),
            SizedBox(width: tokens.spacing.m),
            Text(
              label,
              style: (style ??
                      TextStyle(
                        fontSize: tokens.typography.s,
                        fontFamily: tokens.typography.fontFamily,
                      ))
                  .copyWith(color: styleData.text),
            ),
          ],

        ),
      ),
    );
  }
}
