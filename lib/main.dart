import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  final settings = SettingsService();
  final themeColor = await settings.loadThemeColor();
  final fontScale = await settings.loadFontScale();
  runApp(MyApp(themeColor: themeColor, fontScale: fontScale));
}

class MyApp extends StatefulWidget {
  final Color themeColor;
  final double fontScale;
  const MyApp({super.key, required this.themeColor, required this.fontScale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _themeColor = Colors.blue;
  double _fontScale = 1.0;

  @override
  void initState() {
    super.initState();
    _themeColor = widget.themeColor;
    _fontScale = widget.fontScale;
  }

  void updateTheme(Color newColor) async {
    setState(() => _themeColor = newColor);
    await SettingsService().saveThemeColor(newColor);
  }

  void updateFontScale(double newScale) async {
    setState(() => _fontScale = newScale);
    await SettingsService().saveFontScale(newScale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('vi')],
      theme: ThemeData(
        colorSchemeSeed: _themeColor,
        useMaterial3: true,
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: _fontScale),
        child: child!,
      ),
      home: HomeScreen(
        onThemeChanged: updateTheme,
        onFontScaleChanged: updateFontScale,
      ),
    );
  }
}
