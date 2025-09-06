import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'tokens.dart';

/// Defines the different styles of [PandoraSnackbar].
class SnackbarKind {
  final IconData icon;
  final Color Function(ColorScheme) _resolveColor;

  const SnackbarKind._(this.icon, this._resolveColor);

  static const SnackbarKind success =
      SnackbarKind._(Icons.check_circle, _successColor);
  static const SnackbarKind warn =
      SnackbarKind._(Icons.warning, _warnColor);
  static const SnackbarKind error =
      SnackbarKind._(Icons.error, _errorColor);

  static Color _successColor(ColorScheme scheme) => scheme.secondary;
  static Color _warnColor(ColorScheme scheme) => scheme.tertiary;
  static Color _errorColor(ColorScheme scheme) => scheme.error;

  /// Returns the color associated with this kind for the given [ColorScheme].
  Color color(ColorScheme scheme) => _resolveColor(scheme);
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
    final scheme = Theme.of(context).colorScheme;
    final background = scheme.surface.withOpacity(0.9);
    final iconColor = widget.kind.color(scheme);

    return Semantics(
      container: true,
      liveRegion: true,
      label: widget.text,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PandoraTokens.radiusM),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: background,
                padding: const EdgeInsets.all(PandoraTokens.spacingM),
                child: Row(
                  children: [
                    Icon(widget.kind.icon, color: iconColor),
                    const SizedBox(width: PandoraTokens.spacingS),
                    Expanded(child: Text(widget.text)),
                    if (widget.onUndo != null)
                      TextButton(
                        onPressed: widget.onUndo,
                        child: Text(AppLocalizations.of(context)!.undo),
                      ),
                    if (widget.onClose != null)
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: iconColor,
                        onPressed: widget.onClose,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

