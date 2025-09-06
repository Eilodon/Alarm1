import 'package:flutter/material.dart';
import '../theme/tokens.dart';

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

    final tokens = Theme.of(context).extension<Tokens>()!;

    return ElevatedButton.icon(
      onPressed: disabled ? null : onPressed,
      icon: icon,
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            disabled ? tokens.colors.neutral300 : tokens.colors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
            vertical: tokens.spacing.s, horizontal: tokens.spacing.m),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radii.m),
        ),
        elevation: tokens.elevation.low,
      ),
    );
  }
}
