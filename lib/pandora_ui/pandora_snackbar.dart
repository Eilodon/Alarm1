import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'tokens.dart';


class SnackbarKind {
  final IconData icon;
  final Color color;

  const SnackbarKind._(this.icon, this.color);


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
      liveRegion: true,
      label: widget.text,
      container: true,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
            backdropFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(getIcon(kind)),
              SizedBox(width: 8),
              Expanded(child: Text(text)),
              TextButton(
                onPressed: onUndo,
                child: Text(AppLocalizations.of(context)!.undo),
              ),
              IconButton(
                icon: Icon(Icons.close),
                tooltip: AppLocalizations.of(context)!.cancel,
                onPressed: onClose,


              ),
            ],
          ),
        ),
      ),
    );
  }
}

