import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  final settings = SettingsService();
  final themeColor = await settings.loadThemeColor();
  final requireAuth = await settings.loadRequireAuth();
  if (requireAuth) {
    final auth = LocalAuthentication();
    final ok = await auth.authenticate(
      localizedReason: 'Xác thực để mở ứng dụng',
      options: const AuthenticationOptions(biometricOnly: false),
    );
    if (!ok) return;
  }
  runApp(MyApp(themeColor: themeColor));
}

class MyApp extends StatefulWidget {
  final Color themeColor;
  const MyApp({super.key, required this.themeColor});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _themeColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _themeColor = widget.themeColor;
  }

  void updateTheme(Color newColor) async {
    setState(() => _themeColor = newColor);
    await SettingsService().saveThemeColor(newColor);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes & Reminders',
      theme: ThemeData(
        colorSchemeSeed: _themeColor,
        useMaterial3: true,
      ),
      home: HomeScreen(onThemeChanged: updateTheme),
    );
  }
}
