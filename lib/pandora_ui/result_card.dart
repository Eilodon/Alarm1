import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class ResultCard extends StatelessWidget {
  final Widget child;

  const ResultCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<Tokens>()!;
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: tokens.elevation.low,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radii.m),
      ),
      child: child,

    );
  }
}
