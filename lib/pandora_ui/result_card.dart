import 'dart:async';

import 'package:flutter/material.dart';

import 'package:alarm_domain/alarm_domain.dart';
import 'package:pandora/utils/flutter_haptic_feedback_driver.dart';

/// A card that listens to a [Stream] of text and shows a shimmer while loading.
class ResultCard extends StatefulWidget {
  const ResultCard({
    super.key,
    required this.resultStream,
    this.securityCue = SecurityCue.onDevice,
  });

  final Stream<String> resultStream;
  final SecurityCue securityCue;

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard>
    with SingleTickerProviderStateMixin {
  String? _result;
  late final AnimationController _controller;
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _sub = widget.resultStream.listen((event) {
      setState(() {
        _result = (_result ?? '') + event;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_result == null) {
      // Show a simple shimmer while waiting for stream data.
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  colorScheme.surfaceVariant,
                  colorScheme.surface,
                  colorScheme.surfaceVariant,
                ],
                stops: [
                  (_controller.value - 0.3).clamp(0.0, 1.0),
                  _controller.value.clamp(0.0, 1.0),
                  (_controller.value + 0.3).clamp(0.0, 1.0),
                ],
              ),
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        widget.securityCue.triggerHaptic(hapticFeedbackDriver);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: const Cubic(0.65, 0, 0.35, 1), // custom easing
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.25),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(_result!),
      ),
    );
  }
}
