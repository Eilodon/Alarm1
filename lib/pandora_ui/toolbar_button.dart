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
    return ElevatedButton.icon(
      onPressed: disabled ? null : onPressed,
      icon: icon,
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            disabled ? PandoraTokens.neutral300 : PandoraTokens.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
            vertical: PandoraTokens.spacingS,
            horizontal: PandoraTokens.spacingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PandoraTokens.radiusM),
        ),
        elevation: PandoraTokens.elevationLow,
      ),
    );
  }
}
