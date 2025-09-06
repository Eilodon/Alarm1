import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'tokens.dart';

/// Simple modal dialog allowing the user to provide feedback to improve the AI.
class TeachAiModal extends StatefulWidget {
  const TeachAiModal({super.key, this.onSubmit});

  final void Function(String)? onSubmit;

  /// Convenience method to show the modal.
  static Future<void> show(BuildContext context, {void Function(String)? onSubmit}) {
    return showDialog<void>(
      context: context,
      builder: (_) => TeachAiModal(onSubmit: onSubmit),
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
    return AlertDialog(
      contentPadding: const EdgeInsets.all(PandoraTokens.spacingM),
      title: Text(AppLocalizations.of(context)!.teachAi),
      content: TextField(
        controller: _controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.teachAiHint,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: PandoraTokens.spacingM,
        vertical: PandoraTokens.spacingS,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSubmit?.call(_controller.text);
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.submit),
        ),
      ],
    );
  }
}
