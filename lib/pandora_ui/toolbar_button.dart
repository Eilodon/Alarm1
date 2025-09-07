import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

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

const _touchTarget = 48.0;

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
    final tokens = Theme.of(context).extension<Tokens>()!;
    final toolbarStyles = <String, _ToolbarButtonStyle>{
      'default': _ToolbarButtonStyle(
        background: tokens.colors.primary,
        foreground: tokens.colors.neutral100,
        enabled: true,
      ),
      'active': _ToolbarButtonStyle(
        background: tokens.colors.secondary,
        foreground: tokens.colors.neutral100,
        enabled: true,
      ),
      'disabled': _ToolbarButtonStyle(
        background: tokens.colors.neutral300,
        foreground: tokens.colors.neutral100,
        enabled: false,
      ),
    };

    final style = toolbarStyles[state] ?? toolbarStyles['default']!;

    return Semantics(
      button: true,
      enabled: style.enabled,
      label: label,
      child: Tooltip(
        message: label,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _touchTarget,
            minWidth: _touchTarget,
          ),
          child: ElevatedButton.icon(
            onPressed: style.enabled
                ? () {
                    HapticFeedback.selectionClick();
                    onPressed();
                  }
                : null,
            icon: icon,
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: style.background,
              foregroundColor: style.foreground,
              padding: EdgeInsets.symmetric(
                vertical: tokens.spacing.s,
                horizontal: tokens.spacing.m,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radii.m),
              ),
              elevation: tokens.elevation.low,
            ),
          ),
        ),
      ),
    );
  }
}

