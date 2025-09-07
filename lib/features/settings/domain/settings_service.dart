import 'package:flutter/material.dart';
import 'package:alarm_data/alarm_data.dart';

abstract class SettingsService {
  Future<void> saveThemeColor(Color color);
  Future<Color> loadThemeColor();

  Future<void> saveMascotPath(String path);
  Future<String> loadMascotPath();

  Future<void> saveFontScale(double scale);
  Future<double> loadFontScale();

  Future<void> saveRequireAuth(bool value);
  Future<bool> loadRequireAuth();

  Future<void> saveBackupFormat(BackupFormat format);
  Future<BackupFormat> loadBackupFormat();

  Future<void> saveThemeMode(ThemeMode mode);
  Future<ThemeMode> loadThemeMode();

  Future<void> saveHasSeenOnboarding(bool value);
  Future<bool> loadHasSeenOnboarding();
}
