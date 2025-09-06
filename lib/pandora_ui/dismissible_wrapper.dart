import 'package:flutter/material.dart';

import 'tokens.dart';

/// Wrapper adding swipe-to-dismiss behaviour to any widget.
class DismissibleWrapper extends StatelessWidget {
  const DismissibleWrapper({
    super.key,
    required this.child,
    this.onDismissed,
    this.dismissibleKey,
  });

  final Widget child;
  final VoidCallback? onDismissed;
  final Key? dismissibleKey;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: dismissibleKey ?? ValueKey(child.hashCode),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed?.call(),
      background: Container(
        color: PandoraTokens.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: PandoraTokens.spacingM),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: child,
    );
  }
}
