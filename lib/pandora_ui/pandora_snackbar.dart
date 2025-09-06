import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:notes_reminder_app/pandora_ui/tokens.dart';

class SnackbarKind {
  final IconData icon;
  final Color color;

  const SnackbarKind._(this.icon, this.color);

  static const success =
      SnackbarKind._(Icons.check_circle, PandoraTokens.secondary);
  static const warn = SnackbarKind._(Icons.warning, PandoraTokens.warning);
  static const error = SnackbarKind._(Icons.error, PandoraTokens.error);
}

class PandoraSnackbar extends StatefulWidget {
  final String text;
  final SnackbarKind kind;
  final VoidCallback? onUndo;
  final VoidCallback? onClose;

  const PandoraSnackbar({
    super.key,
    required this.text,
    required this.kind,
    this.onUndo,
    this.onClose,
  });

  @override
  State<PandoraSnackbar> createState() => _PandoraSnackbarState();
}

class _PandoraSnackbarState extends State<PandoraSnackbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  static const Curve _curve = Cubic(0.0, 0.0, 0.2, 1.0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PandoraTokens.durationShort,
    );
    final animation = CurvedAnimation(parent: _controller, curve: _curve);
    _fade = animation;
    _slide =
        Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation);
    _controller.forward();
  }

  void hide() {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(PandoraTokens.radiusM),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: PandoraTokens.neutral100.withOpacity(0.7),
              padding: const EdgeInsets.all(PandoraTokens.spacingM),
              child: Row(
                children: [
                  Icon(widget.kind.icon, color: widget.kind.color),
                  const SizedBox(width: PandoraTokens.spacingS),
                  Expanded(child: Text(widget.text)),
                  if (widget.onUndo != null)
                    TextButton(
                      onPressed: widget.onUndo,
                      child: const Text('Undo'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose ?? hide,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
