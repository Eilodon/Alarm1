import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

class _ToolbarButtonStyle {
  final Color background;
  final Color foreground;
  final bool enabled;

  const _ToolbarButtonStyle({
    required this.background,
    required this.foreground,
    required this.enabled,
  });
}

const Map<String, _ToolbarButtonStyle> _toolbarStyles = {
  'default': _ToolbarButtonStyle(
    background: PandoraTokens.primary,
    foreground: PandoraTokens.neutral100,
    enabled: true,
  ),
  'active': _ToolbarButtonStyle(
    background: PandoraTokens.secondary,
    foreground: PandoraTokens.neutral100,
    enabled: true,
  ),
  'disabled': _ToolbarButtonStyle(
    background: PandoraTokens.neutral300,
    foreground: PandoraTokens.neutral100,
    enabled: false,
  ),
};

/// Toolbar button with icon and label.
class ToolbarButton extends StatelessWidget {
  const ToolbarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.state = 'default',
  });

  final Widget icon;
  final String label;
  final VoidCallback onPressed;
  final String state;

  @override
  Widget build(BuildContext context) {

    return ElevatedButton.icon(
      onPressed: disabled ? null : onPressed,
      icon: icon,
      label: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: disabled
            ? PandoraTokens.neutral300
            : PandoraTokens.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: PandoraTokens.spacingS,
          horizontal: PandoraTokens.spacingM,
        ),
        minimumSize: const Size(
          PandoraTokens.touchTarget,
          PandoraTokens.touchTarget,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PandoraTokens.radiusM),
        ),
        elevation: PandoraTokens.elevationLow,

      ),
    );
  }
}

