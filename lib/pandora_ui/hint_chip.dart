import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';
import 'tokens.dart' as pui;

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

Map<String, _ChipStyle> _chipStyles(Tokens tokens) => {
      'default': _ChipStyle(
        background: tokens.colors.neutral200,
        text: tokens.colors.neutral900,
        opacity: pui.PandoraTokens.opacityDisabled,
      ),
      'armed': _ChipStyle(
        background: tokens.colors.error,
        text: tokens.colors.neutral100,
        opacity: pui.PandoraTokens.opacityFocus,
      ),
      'active': _ChipStyle(
        background: tokens.colors.secondary,
        text: tokens.colors.neutral100,
        opacity: pui.PandoraTokens.opacityEnabled,
      ),
    };

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
    final styles = _chipStyles(tokens);
    final _ChipStyle styleData = styles[state] ?? styles['default']!;
    final baseStyle =
        style ?? Theme.of(context).textTheme.bodySmall ?? const TextStyle();

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: pui.PandoraTokens.touchTarget,
        minWidth: pui.PandoraTokens.touchTarget,
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
                    pui.PandoraTokens.hintIcon,
                    size: pui.PandoraTokens.iconS,
                    color: tokens.colors.warning,
                  ),
              SizedBox(width: tokens.spacing.m),
              Text(label, style: baseStyle.copyWith(color: styleData.text)),
            ],
          ),
        ),
      ),
    );
  }
}
