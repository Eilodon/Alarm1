import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:alarm_domain/alarm_domain.dart';
import '../theme/tokens.dart';
import '../utils/flutter_haptic_feedback_driver.dart';

/// Simple modal dialog allowing the user to provide feedback to improve the AI.
class TeachAiModal extends StatefulWidget {
  const TeachAiModal({super.key, this.onSubmit, this.securityCue = SecurityCue.onDevice});

  final void Function(String)? onSubmit;
  final SecurityCue securityCue;

  /// Convenience method to show the modal.
  static Future<void> show(
    BuildContext context, {
    void Function(String)? onSubmit,
    SecurityCue securityCue = SecurityCue.onDevice,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => TeachAiModal(onSubmit: onSubmit, securityCue: securityCue),
    );
  }

  @override
  State<TeachAiModal> createState() => _TeachAiModalState();
}

class _TeachAiModalState extends State<TeachAiModal> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<Tokens>()!;
    return AlertDialog(
      contentPadding: EdgeInsets.all(tokens.spacing.m),
      title: Text(l10n.teachAi),
      content: TextField(
        controller: _controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: l10n.teachAiHint,
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.m,
        vertical: tokens.spacing.s,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            widget.securityCue.triggerHaptic(hapticFeedbackDriver);
            widget.onSubmit?.call(_controller.text);
            Navigator.of(context).pop();
          },
          child: Text(l10n.submit),
        ),
      ],
    );
  }
}

