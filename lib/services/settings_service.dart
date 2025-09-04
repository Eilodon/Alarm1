import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsService {
  static const _kThemeColor = 'theme_color';
  static const _kMascotPath = 'mascot_path';
  static const _kFontScale = 'font_scale';

  Future<void> saveThemeColor(Color color) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kThemeColor, color.value);
  }

  Future<Color> loadThemeColor() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getInt(_kThemeColor);
    return v != null ? Color(v) : Colors.blue;
  }

  Future<void> saveMascotPath(String path) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kMascotPath, path);
  }

  Future<String> loadMascotPath() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kMascotPath) ?? 'assets/lottie/mascot.json';
  }

  Future<void> saveFontScale(double scale) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble(_kFontScale, scale);
  }

  Future<double> loadFontScale() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getDouble(_kFontScale) ?? 1.0;
  }
}
