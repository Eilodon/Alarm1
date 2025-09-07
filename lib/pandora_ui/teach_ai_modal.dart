import 'package:flutter/material.dart';

import '../models/security_cue.dart';

/// Modal dialog that lets user "teach" the AI with custom easing.
class TeachAiModal extends StatefulWidget {
  const TeachAiModal({super.key, this.securityCue = SecurityCue.onDevice});

  final SecurityCue securityCue;

  @override
  State<TeachAiModal> createState() => _TeachAiModalState();
}

class _TeachAiModalState extends State<TeachAiModal>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _ctrl;
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _anim, curve: Curves.easeOutQuart);
    return ScaleTransition(
      scale: curved,
      child: AlertDialog(
        title: const Text('Teach AI'),
        content: TextField(controller: _ctrl),
        actions: [
          TextButton(
            onPressed: () {
              widget.securityCue.triggerHaptic();
              Navigator.pop(context, _ctrl.text);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
