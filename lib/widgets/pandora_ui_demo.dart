import 'dart:async';

import 'package:flutter/material.dart';

import '../pandora_ui/bottom_sheet.dart';
import '../pandora_ui/dismissible_wrapper.dart';
import '../pandora_ui/palette_list_item.dart';
import '../pandora_ui/result_card.dart';
import '../pandora_ui/security_cue.dart';
import '../pandora_ui/teach_ai_modal.dart';
import '../pandora_ui/tokens.dart';

/// Demonstrates the Pandora UI widgets in a simple screen.
class PandoraUiDemo extends StatelessWidget {
  const PandoraUiDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pandora UI Demo')),
      body: ListView(
        padding: const EdgeInsets.all(PandoraTokens.spacingM),
        children: [
          const Text('Security modes'),
          const Row(
            children: [
              SecurityCue(mode: SecurityMode.onDevice),
              SizedBox(width: PandoraTokens.spacingM),
              SecurityCue(mode: SecurityMode.hybrid),
              SizedBox(width: PandoraTokens.spacingM),
              SecurityCue(mode: SecurityMode.cloud),
            ],
          ),
          const SizedBox(height: PandoraTokens.spacingL),
          ResultCard(
            textStream: Stream<String>.periodic(
              const Duration(milliseconds: 400),
              (i) => 'Chunk ' + (i + 1).toString(),
            ).take(3).transform(StreamTransformer.fromHandlers(
                handleData: (data, sink) => sink.add(data + '...'))),
            images: const [
              NetworkImage('https://placekitten.com/200/200'),
            ],
            code: "print('hello world');",
            actions: [
              TextButton(onPressed: () {}, child: const Text('Action')),
            ],
            onFeedback: (liked) {},
            securityMode: SecurityMode.hybrid,
          ),
          const SizedBox(height: PandoraTokens.spacingL),
          PaletteListItem(
            color: Colors.blue,
            label: 'Blue',
            onTap: () {},
          ),
          const SizedBox(height: PandoraTokens.spacingL),
          ElevatedButton(
            onPressed: () {
              PandoraBottomSheet.show(
                context,
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Text('Pull down to close',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
              );
            },
            child: const Text('Show Bottom Sheet'),
          ),
          const SizedBox(height: PandoraTokens.spacingL),
          ElevatedButton(
            onPressed: () => TeachAiModal.show(context),
            child: const Text('Teach AI'),
          ),
          const SizedBox(height: PandoraTokens.spacingL),
          DismissibleWrapper(
            onDismissed: () {},
            child: Container(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              padding: const EdgeInsets.all(PandoraTokens.spacingM),
              child: const Text('Swipe me'),
            ),
          )
        ],
      ),
    );
  }
}
