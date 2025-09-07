import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:notes_reminder_app/theme/tokens.dart';

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
const _touchTarget = 48.0;

/// Simple chip widget displaying an icon with a label.
class HintChip extends StatelessWidget {
  const HintChip({
    super.key,
    required this.label,
    this.icon,
    this.state = 'default',
    required this.onPressed,
    this.style,
  });

  final String label;
  final Widget? icon;
  final String state;
  final VoidCallback onPressed;
  final TextStyle? style;

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

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: _touchTarget,
        minWidth: _touchTarget,
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        borderRadius: BorderRadius.circular(tokens.radii.m),
        child: Ink(
          decoration: BoxDecoration(
            color: styleData.background.withOpacity(styleData.opacity),
            borderRadius: BorderRadius.circular(tokens.radii.m),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.m,
            vertical: tokens.spacing.s,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon ??
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
      ),
    );
  }
}

