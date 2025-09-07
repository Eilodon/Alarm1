/// Describes where data is processed and which haptic feedback to use.
enum SecurityCue { onDevice, hybrid, cloud }

/// Abstraction for triggering haptic feedback.
abstract class HapticFeedbackDriver {
  Future<void> selectionClick();
  Future<void> lightImpact();
  Future<void> heavyImpact();
}

extension SecurityCueHaptics on SecurityCue {
  /// Triggers a haptic feedback associated with the security cue.
  Future<void> triggerHaptic(HapticFeedbackDriver driver) {
    switch (this) {
      case SecurityCue.onDevice:
        return driver.selectionClick();
      case SecurityCue.hybrid:
        return driver.lightImpact();
      case SecurityCue.cloud:
        return driver.heavyImpact();
    }
  }
}
