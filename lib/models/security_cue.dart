import 'package:flutter/services.dart';

/// Describes where data is processed and which haptic feedback to use.
enum SecurityCue { onDevice, hybrid, cloud }

extension SecurityCueHaptics on SecurityCue {
  /// Triggers a haptic feedback associated with the security cue.
  Future<void> triggerHaptic() {
    switch (this) {
      case SecurityCue.onDevice:
        return HapticFeedback.selectionClick();
      case SecurityCue.hybrid:
        return HapticFeedback.lightImpact();
      case SecurityCue.cloud:
        return HapticFeedback.heavyImpact();
    }
  }
}
