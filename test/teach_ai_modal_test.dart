import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/models/security_cue.dart';
import 'package:notes_reminder_app/pandora_ui/teach_ai_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TeachAiModal returns input and triggers haptic', (tester) async {
    int hapticCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method.startsWith('HapticFeedback')) {
            hapticCalls++;
          }
          return null;
        });

    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await showDialog<String>(
                  context: context,
                  builder: (_) => const TeachAiModal(),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'foo');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(result, 'foo');
    expect(hapticCalls, greaterThan(0));

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });
}
