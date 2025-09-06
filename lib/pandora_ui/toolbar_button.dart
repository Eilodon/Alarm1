import 'package:flutter/material.dart';
import 'path/to/tokens.dart'; // Đường dẫn đến tokens.dart

class ToolbarButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onPressed;
  final bool disabled;

  ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.transparent), // Có thể thay đổi màu viền nếu cần
        ),
        backgroundColor: disabled ? Colors.grey : Color.fromARGB(255, /* lấy màu từ tokens.dart */),
      ),
      child: Row(
        children: [
          icon,
          SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}