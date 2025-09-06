import 'package:flutter/material.dart';

import 'tokens.dart';
import 'security_cue.dart';

/// A card displaying AI results including streamed text, images, code preview,
/// actions and feedback controls.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    this.textStream,
    this.text,
    this.images,
    this.code,
    this.actions,
    this.onFeedback,
    this.securityMode,
  });

  /// Streamed text to display progressively.
  final Stream<String>? textStream;

  /// Static text to display if [textStream] is null.
  final String? text;

  /// Optional images to show in a wrap.
  final List<ImageProvider>? images;

  /// Optional code snippet to show in a monospace preview.
  final String? code;

  /// Optional action buttons shown at the bottom of the card.
  final List<Widget>? actions;

  /// Callback when feedback buttons are pressed. `true` for like.
  final void Function(bool)? onFeedback;

  /// Optional mode indicator.
  final SecurityMode? securityMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        theme.brightness == Brightness.dark ? PandoraTokens.darkBg : PandoraTokens.neutral100;

    final content = <Widget>[];

    if (securityMode != null) {
      content.add(Align(
        alignment: Alignment.centerRight,
        child: SecurityCue(mode: securityMode!),
      ));
    }

    if (textStream != null) {
      content.add(StreamBuilder<String>(
        stream: textStream,
        builder: (context, snapshot) {
          return Text(snapshot.data ?? '', style: theme.textTheme.bodyMedium);
        },
      ));
    } else if (text != null) {
      content.add(Text(text!, style: theme.textTheme.bodyMedium));
    }

    if (images != null && images!.isNotEmpty) {
      content.add(const SizedBox(height: PandoraTokens.spacingM));
      content.add(Wrap(
        spacing: PandoraTokens.spacingS,
        children: images!
            .map((img) => Image(image: img, width: 72, height: 72))
            .toList(),
      ));
    }

    if (code != null) {
      content.add(const SizedBox(height: PandoraTokens.spacingM));
      content.add(Container(
        width: double.infinity,
        padding: const EdgeInsets.all(PandoraTokens.spacingM),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(PandoraTokens.radiusS),
        ),
        child: SelectableText(
          code!,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ));
    }

    if (actions != null && actions!.isNotEmpty) {
      content.add(const SizedBox(height: PandoraTokens.spacingM));
      content.add(ButtonBar(children: actions!));
    }

    if (onFeedback != null) {
      content.add(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.thumb_up),
            onPressed: () => onFeedback!(true),
          ),
          IconButton(
            icon: const Icon(Icons.thumb_down),
            onPressed: () => onFeedback!(false),
          ),
        ],
      ));
    }

    return Card(
      color: bgColor,
      elevation: PandoraTokens.elevationLow,
      margin: const EdgeInsets.all(PandoraTokens.spacingM),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PandoraTokens.radiusM)),
      child: Padding(
        padding: const EdgeInsets.all(PandoraTokens.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: content,
        ),
      ),
    );
  }
}
