import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService({SharedPreferences? sharedPreferences})
      : _preferences = sharedPreferences;

  static const _kThemeColor = 'theme_color';
  static const _kMascotPath = 'mascot_path';
  static const _kFontScale = 'font_scale';
  static const _kRequireAuth = 'require_auth';
  static const _kThemeMode = 'theme_mode';

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
    return v != null ? Color(v) : Colors.blue;
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

  Future<void> saveThemeMode(ThemeMode mode) async {
    final sp = await _sp;
    await sp.setString(_kThemeMode, mode.name);
  }

  Future<ThemeMode> loadThemeMode() async {
    final sp = await _sp;
    final value = sp.getString(_kThemeMode);
    if (value != null) {
      return ThemeMode.values.firstWhere(
        (m) => m.name == value,
        orElse: () => ThemeMode.system,
      );
    }
    return ThemeMode.system;
  }
}
