import 'package:flutter/material.dart';

class HintChip extends StatelessWidget {
  final String label;
  final String state;
  final VoidCallback onPressed;
  final TextStyle? style;

  const HintChip({
    Key? key,
    required this.label,
    this.state = 'default',
    required this.onPressed,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (state) {
      case 'armed':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      case 'active':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        break;
      default:
        backgroundColor = Colors.grey[300]!;
        textColor = Colors.black;
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lightbulb, color: Colors.yellow),
            const SizedBox(width: 8),
            Text(
              label,
              style: style ?? TextStyle(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}