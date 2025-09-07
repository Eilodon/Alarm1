import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/pandora_ui/pandora_snackbar.dart';
import 'package:notes_reminder_app/theme/tokens.dart';

void main() {
  testWidgets('snackIn and snackOut animations run', (tester) async {
    const durationShort = Duration(milliseconds: 150);
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: const [Tokens.light]),
      home: const Scaffold(
        body: PandoraSnackbar(
          text: 'Hello',
          kind: SnackbarKind.success,
        ),
      ),
    ));

    await tester.pump();
    await tester.pump(durationShort);

    final fade = tester.widget<FadeTransition>(find.byType(FadeTransition));
    expect(fade.opacity.value, 1);

    final state = tester.state(find.byType(PandoraSnackbar)) as dynamic;
    state.hide();
    await tester.pump();
    await tester.pump(durationShort);

    final fadeAfter =
        tester.widget<FadeTransition>(find.byType(FadeTransition));
    expect(fadeAfter.opacity.value, 0);
  });

  testWidgets('has status semantics', (tester) async {
    final semantics = SemanticsTester(tester);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: PandoraSnackbar(
          text: 'Hello',
          kind: SnackbarKind.success,
        ),
      ),
    ));

    final node = tester.getSemantics(find.byType(PandoraSnackbar));
    expect(node.hasFlag(SemanticsFlag.isLiveRegion), isTrue);
    expect(node.label, 'Hello');

    semantics.dispose();
  });
}
