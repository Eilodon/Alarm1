import 'package:flutter/material.dart';

class PandoraSnackbar extends StatelessWidget {
  final String text;
  final String kind;
  final VoidCallback? onUndo;
  final VoidCallback? onClose;

  const PandoraSnackbar({
    Key? key,
    required this.text,
    required this.kind,
    this.onUndo,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
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
              child: Text('Undo'),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }

  IconData getIcon(String kind) {
    switch (kind) {
      case 'success':
        return Icons.check_circle;
      case 'warn':
        return Icons.warning;
      case 'error':
        return Icons.error;
      default:
        return Icons.info;
    }
  }
}