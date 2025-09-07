import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/models/security_cue.dart';
import 'package:notes_reminder_app/pandora_ui/result_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ResultCard shows stream text and triggers haptic', (
    tester,
  ) async {
    int hapticCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method.startsWith('HapticFeedback')) {
            hapticCalls++;
          }
          return null;
        });

    final controller = StreamController<String>();
    await tester.pumpWidget(
      MaterialApp(
        home: ResultCard(
          resultStream: controller.stream,
          securityCue: SecurityCue.onDevice,
        ),
      ),
    );

    // Initially shows shimmer
    expect(find.byType(AnimatedBuilder), findsWidgets);

    controller.add('hi');
    await tester.pump();
    expect(find.text('hi'), findsOneWidget);

    await tester.tap(find.byType(ResultCard));
    await tester.pump();
    expect(hapticCalls, greaterThan(0));

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });
}
