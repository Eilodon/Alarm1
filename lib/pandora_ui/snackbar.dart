import 'package:flutter/material.dart';

import 'package:alarm_domain/alarm_domain.dart';
import 'package:pandora/utils/flutter_haptic_feedback_driver.dart';

/// Simple snackbar that slides in with a custom easing and triggers haptics.
class SimpleSnackBar extends StatefulWidget {
  const SimpleSnackBar({
    super.key,
    required this.message,
    this.securityCue = SecurityCue.onDevice,
    this.curve = Curves.easeOutBack,
  });

  final String message;
  final SecurityCue securityCue;
  final Curve curve;

  @override
  State<SimpleSnackBar> createState() => _SimpleSnackBarState();
}

class _SimpleSnackBarState extends State<SimpleSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _offset = Tween(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    widget.securityCue.triggerHaptic(hapticFeedbackDriver);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SlideTransition(
      position: _offset,
      child: Material(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.message,
            style: TextStyle(color: scheme.onInverseSurface),
          ),
        ),
      ),
    );
  }
}

/// Shows the [SimpleSnackBar] using an [Overlay].
void showSimpleSnackBar(BuildContext context, String message, SecurityCue cue) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: SimpleSnackBar(message: message, securityCue: cue),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 2), () => entry.remove());
}
