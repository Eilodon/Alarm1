import 'package:flutter/material.dart';

import '../theme/tokens.dart';

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
    final theme = Theme.of(context);
    final tokens = theme.extension<Tokens>()!;
    return Dismissible(
      key: dismissibleKey ?? ValueKey(child.hashCode),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed?.call(),
      background: Container(
        color: tokens.colors.error,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: tokens.spacing.m),
        child: Icon(
          Icons.delete,
          color: theme.colorScheme.onError,
        ),
      ),
      child: child,
    );
  }
}
