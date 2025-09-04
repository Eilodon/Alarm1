import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notes_reminder_app/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('save and load theme color', () async {
    final service = SettingsService();
    await service.saveThemeColor(Colors.red);
    final color = await service.loadThemeColor();
    expect(color, Colors.red);
  });

  test('save and load mascot path', () async {
    final service = SettingsService();
    await service.saveMascotPath('path.json');
    final path = await service.loadMascotPath();
    expect(path, 'path.json');
  });

  test('default values returned when not set', () async {
    final service = SettingsService();
    final color = await service.loadThemeColor();
    final path = await service.loadMascotPath();
    expect(color, Colors.blue);
    expect(path, 'assets/lottie/mascot.json');
  });
}
