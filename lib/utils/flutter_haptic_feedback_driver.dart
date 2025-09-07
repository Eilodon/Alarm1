import 'package:alarm_domain/alarm_domain.dart';
import 'package:flutter/services.dart';

class FlutterHapticFeedbackDriver implements HapticFeedbackDriver {
  const FlutterHapticFeedbackDriver();

  @override
  Future<void> selectionClick() => HapticFeedback.selectionClick();

  @override
  Future<void> lightImpact() => HapticFeedback.lightImpact();

  @override
  Future<void> heavyImpact() => HapticFeedback.heavyImpact();
}

const HapticFeedbackDriver hapticFeedbackDriver = FlutterHapticFeedbackDriver();
