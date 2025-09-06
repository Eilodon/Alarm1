import 'package:flutter/material.dart';
import 'tokens.dart';

class ToolbarButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onPressed;
  final bool disabled;

  const ToolbarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        disabled ? PandoraTokens.neutral200 : Colors.transparent;
    return Opacity(
      opacity: disabled
          ? PandoraTokens.opacityDisabled
          : PandoraTokens.opacityEnabled,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: PandoraTokens.spacingS,
            horizontal: PandoraTokens.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PandoraTokens.radiusM),
            side: BorderSide(color: borderColor),
          ),
          backgroundColor: PandoraTokens.neutral100,
        ),
        child: Row(
          children: [
            icon,
            SizedBox(width: PandoraTokens.spacingS),
            Text(label),
          ],
        ),
      ),
    );
  }
}