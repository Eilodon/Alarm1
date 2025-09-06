import 'package:flutter/material.dart';

import 'tokens.dart';

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

const Map<String, _ChipStyle> _chipStyles = {
  'default': _ChipStyle(
    background: PandoraTokens.neutral200,
    text: PandoraTokens.neutral900,
    opacity: PandoraTokens.opacityDisabled,
  ),
  'armed': _ChipStyle(
    background: PandoraTokens.error,
    text: PandoraTokens.neutral100,
    opacity: PandoraTokens.opacityFocus,
  ),
  'active': _ChipStyle(
    background: PandoraTokens.secondary,
    text: PandoraTokens.neutral100,
    opacity: PandoraTokens.opacityEnabled,
  ),
};

class HintChip extends StatelessWidget {
  final String label;
  final String state;
  final VoidCallback onPressed;
  final TextStyle? style;

  const HintChip({
    Key? key,
    required this.label,
    this.state = 'default',
    required this.onPressed,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ChipStyle styleData = _chipStyles[state] ?? _chipStyles['default']!;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(PandoraTokens.radiusM),
      child: Ink(
        decoration: BoxDecoration(
          color: styleData.background.withOpacity(styleData.opacity),
          borderRadius: BorderRadius.circular(PandoraTokens.radiusM),
        ),
        padding: const EdgeInsets.all(PandoraTokens.spacingM),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PandoraTokens.hintIcon,
              size: PandoraTokens.iconS,
              color: PandoraTokens.warning,
            ),
            const SizedBox(width: PandoraTokens.spacingM),
            Text(
              label,
              style: (style ??
                      const TextStyle(
                        fontSize: PandoraTokens.fontSizeS,
                        fontFamily: PandoraTokens.fontFamily,
                      ))
                  .copyWith(color: styleData.text),
            ),
          ],
        ),
      ),
    );
  }
}