import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// Simple wrapper for a [Card] that can show slide actions.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.child,
    this.endActionPane,
  });

  final Widget child;
  final ActionPane? endActionPane;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: child,
    );
    if (endActionPane == null) {
      return card;
    }
    return Slidable(
      key: key,
      endActionPane: endActionPane,
      child: card,
    );
  }
}
