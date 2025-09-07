import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A draggable bottom sheet that traps focus when opened.
class PandoraBottomSheet extends StatefulWidget {
  const PandoraBottomSheet({super.key, required this.child});

  final Widget child;

  /// Shows the bottom sheet using [showModalBottomSheet].
  static Future<T?> show<T>(BuildContext context, Widget child) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PandoraBottomSheet(child: child),
    );
  }

  @override
  State<PandoraBottomSheet> createState() => _PandoraBottomSheetState();
}

class _PandoraBottomSheetState extends State<PandoraBottomSheet> {
  final FocusScopeNode _focusNode = FocusScopeNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, controller) {
        final theme = Theme.of(context);
        final tokens = theme.extension<Tokens>()!;
        return FocusScope(
          node: _focusNode,
          autofocus: true,
          child: Container(
            decoration: BoxDecoration(
              color: theme.canvasColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(tokens.radii.l),
              ),
            ),
            child: SingleChildScrollView(
              controller: controller,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
