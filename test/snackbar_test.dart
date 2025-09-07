import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:notes_reminder_app/pandora_ui/snackbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SimpleSnackBar shows message and haptic', (tester) async {
    int hapticCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method.startsWith('HapticFeedback')) {
            hapticCalls++;
          }
          return null;
        });

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );

    final BuildContext context = tester.element(find.byType(SizedBox));
    showSimpleSnackBar(context, 'Hello', SecurityCue.hybrid);
    await tester.pump();

    expect(find.text('Hello'), findsOneWidget);
    expect(hapticCalls, greaterThan(0));

    // Allow the snackbar's timer to complete.
    await tester.pump(const Duration(seconds: 3));

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });
}
