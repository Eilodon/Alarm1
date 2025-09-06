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

  test('save and load font scale', () async {
    final service = SettingsService();
    await service.saveFontScale(1.5);
    final scale = await service.loadFontScale();
    expect(scale, 1.5);
  });

  test('save and load require auth', () async {
    final service = SettingsService();
    await service.saveRequireAuth(true);
    final value = await service.loadRequireAuth();
    expect(value, true);
  });

  test('save and load has seen onboarding', () async {
    final service = SettingsService();
    await service.saveHasSeenOnboarding(true);
    final value = await service.loadHasSeenOnboarding();
    expect(value, true);
  });

  test('default values returned when not set', () async {
    final service = SettingsService();
    final color = await service.loadThemeColor();
    final path = await service.loadMascotPath();
    final scale = await service.loadFontScale();
    final auth = await service.loadRequireAuth();
    final onboarding = await service.loadHasSeenOnboarding();
    expect(color, Colors.blue);
    expect(path, 'assets/lottie/mascot.json');
    expect(scale, 1.0);
    expect(auth, false);
    expect(onboarding, false);
  });
}
