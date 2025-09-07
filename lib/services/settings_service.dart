import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/tokens.dart';
import 'backup_service.dart';

class SettingsService {
  SettingsService({SharedPreferences? sharedPreferences})
      : _preferences = sharedPreferences;

  static const _kThemeColor = 'theme_color';
  static const _kMascotPath = 'mascot_path';
  static const _kFontScale = 'font_scale';
  static const _kRequireAuth = 'require_auth';
  static const _kBackupFormat = 'backup_format';
  static const _kThemeMode = 'theme_mode';

  static const _kHasSeenOnboarding = 'has_seen_onboarding';


  SharedPreferences? _preferences;

  Future<SharedPreferences> get _sp async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  Future<void> saveThemeColor(Color color) async {
    final sp = await _sp;
    await sp.setInt(_kThemeColor, color.value);
  }

  Future<Color> loadThemeColor() async {
    final sp = await _sp;
    final v = sp.getInt(_kThemeColor);
    return v != null ? Color(v) : Tokens.light.colors.primary;
  }

  Future<void> saveMascotPath(String path) async {
    final sp = await _sp;
    await sp.setString(_kMascotPath, path);
  }

  Future<String> loadMascotPath() async {
    final sp = await _sp;
    return sp.getString(_kMascotPath) ?? 'assets/lottie/mascot.json';
  }

  Future<void> saveFontScale(double scale) async {
    final sp = await _sp;
    await sp.setDouble(_kFontScale, scale);
  }

  Future<double> loadFontScale() async {
    final sp = await _sp;
    return sp.getDouble(_kFontScale) ?? 1.0;
  }

  Future<void> saveRequireAuth(bool value) async {
    final sp = await _sp;
    await sp.setBool(_kRequireAuth, value);
  }

  Future<bool> loadRequireAuth() async {
    final sp = await _sp;
    return sp.getBool(_kRequireAuth) ?? false;
  }


  Future<void> saveBackupFormat(BackupFormat format) async {
    final sp = await _sp;
    await sp.setString(_kBackupFormat, format.name);
  }

  Future<BackupFormat> loadBackupFormat() async {
    final sp = await _sp;
    final value = sp.getString(_kBackupFormat);
    return BackupFormat.values.firstWhere(
      (f) => f.name == value,
      orElse: () => BackupFormat.json,
    );

  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final sp = await _sp;
    await sp.setString(_kThemeMode, mode.name);
  }

  Future<ThemeMode> loadThemeMode() async {
    final sp = await _sp;
    final value = sp.getString(_kThemeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveHasSeenOnboarding(bool value) async {
    final sp = await _sp;
    await sp.setBool(_kHasSeenOnboarding, value);
  }

  Future<bool> loadHasSeenOnboarding() async {
    final sp = await _sp;
    return sp.getBool(_kHasSeenOnboarding) ?? false;
  }
}
