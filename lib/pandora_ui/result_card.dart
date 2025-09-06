import 'package:flutter/material.dart';

import 'tokens.dart';

class ResultCard extends StatelessWidget {
  final Widget child;

  const ResultCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: PandoraTokens.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PandoraTokens.radiusM),
      ),
      child: child,

    );
  }
}
