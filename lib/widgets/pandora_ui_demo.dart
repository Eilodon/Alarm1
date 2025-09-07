import 'dart:async';

import 'package:flutter/material.dart';

import '../pandora_ui/bottom_sheet.dart';
import '../pandora_ui/dismissible_wrapper.dart';
import 'palette_list_item.dart';
import '../pandora_ui/result_card.dart';
import '../pandora_ui/security_cue.dart';
import '../pandora_ui/teach_ai_modal.dart';
import '../theme/tokens.dart';

/// Demonstrates the Pandora UI widgets in a simple screen.
class PandoraUiDemo extends StatelessWidget {
  const PandoraUiDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<Tokens>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('Pandora UI Demo')),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing.m),
        children: [
          const Text('Security modes'),
          Row(
            children: [
              const SecurityCue(mode: SecurityMode.onDevice),
              SizedBox(width: tokens.spacing.m),
              const SecurityCue(mode: SecurityMode.hybrid),
              SizedBox(width: tokens.spacing.m),
              const SecurityCue(mode: SecurityMode.cloud),
            ],
          ),
          SizedBox(height: tokens.spacing.l),
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
          SizedBox(height: tokens.spacing.l),
          PaletteListItem(
            color: Colors.blue,
            label: 'Blue',
            onTap: () {},
          ),
          SizedBox(height: tokens.spacing.l),
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
          SizedBox(height: tokens.spacing.l),
          ElevatedButton(
            onPressed: () => TeachAiModal.show(context),
            child: const Text('Teach AI'),
          ),
          SizedBox(height: tokens.spacing.l),
          DismissibleWrapper(
            onDismissed: () {},
            child: Container(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              padding: EdgeInsets.all(tokens.spacing.m),
              child: const Text('Swipe me'),
            ),
          )
        ],
      ),
    );
  }
}
