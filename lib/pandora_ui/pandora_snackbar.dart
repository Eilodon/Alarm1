import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'tokens.dart';

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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(PandoraTokens.radiusM),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(PandoraTokens.radiusM),
                border: Border.all(
                  color: widget.kind.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(PandoraTokens.spacingM),
              child: Row(
                children: [
                  Icon(
                    widget.kind.icon,
                    color: widget.kind.color,
                    size: PandoraTokens.iconS,
                  ),
                  const SizedBox(width: PandoraTokens.spacingS),
                  Expanded(
                    child: Text(
                      widget.text,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  if (widget.onUndo != null) ...[
                    const SizedBox(width: PandoraTokens.spacingS),
                    TextButton(
                      onPressed: widget.onUndo,
                      style: TextButton.styleFrom(
                        foregroundColor: widget.kind.color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: PandoraTokens.spacingS,
                        ),
                      ),
                      child: Text(l10n.undo),
                    ),
                  ],
                  if (widget.onClose != null) ...[
                    const SizedBox(width: PandoraTokens.spacingXS),
                    IconButton(
                      icon: const Icon(Icons.close),
                      iconSize: PandoraTokens.iconS,
                      padding: const EdgeInsets.all(PandoraTokens.spacingXS),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: widget.onClose,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}