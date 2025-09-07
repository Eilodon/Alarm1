import 'package:flutter/material.dart';
import 'package:notes_reminder_app/generated/app_localizations.dart';

import '../theme/tokens.dart';

const _animationDuration = Duration(milliseconds: 150);

class SnackbarKind {
  final IconData icon;
  const SnackbarKind._(this.icon);

  static const success = SnackbarKind._(Icons.check_circle);
  static const warn = SnackbarKind._(Icons.warning);
  static const error = SnackbarKind._(Icons.error);
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
      duration: _animationDuration,
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
    final tokens = Theme.of(context).extension<Tokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    Color iconColor;
    if (widget.kind == SnackbarKind.success) {
      iconColor = tokens.colors.secondary;
    } else if (widget.kind == SnackbarKind.warn) {
      iconColor = tokens.colors.warning;
    } else {
      iconColor = tokens.colors.error;
    }

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          decoration: BoxDecoration(
            color: tokens.colors.surface,
            borderRadius: BorderRadius.circular(tokens.radii.m),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.2),
                blurRadius: 4,
              ),
            ],
          ),
          padding: EdgeInsets.all(tokens.spacing.m),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.kind.icon, color: iconColor),
              SizedBox(width: tokens.spacing.s),
              Expanded(child: Text(widget.text)),
              if (widget.onUndo != null)
                TextButton(
                  onPressed: widget.onUndo,
                  child: Text(AppLocalizations.of(context)?.undo ?? 'Undo'),
                ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose ?? hide,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

