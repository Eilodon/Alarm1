import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Visual indicator of how a result was processed.
///
/// The cue displays an icon representing where the work was done
/// (on-device, hybrid or in the cloud).
enum SecurityMode { onDevice, hybrid, cloud }

class SecurityCue extends StatelessWidget {
  const SecurityCue({super.key, required this.mode, this.size = _iconSizeM});

  /// Mode the result was processed in.
  final SecurityMode mode;

  /// Size of the icon.
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = switch (mode) {
      SecurityMode.onDevice => Icons.shield,
      SecurityMode.hybrid => Icons.sync,
      SecurityMode.cloud => Icons.cloud,
    };

    final tokens = Theme.of(context).extension<Tokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (mode) {
      SecurityMode.onDevice => colorScheme.primary,
      SecurityMode.hybrid => tokens.colors.warning,
      SecurityMode.cloud => tokens.colors.info,
    };

    return Icon(icon, size: size, color: color);
  }
}

const _iconSizeM = 24.0;
