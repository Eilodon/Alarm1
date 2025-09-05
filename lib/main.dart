import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'services/auth_service.dart';
import 'package:provider/provider.dart';
import 'providers/note_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app'),
          ),
        ),
      ),
    );
    return;
  }
  var authFailed = false;
  var notificationFailed = false;
  try {
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    authFailed = true;
    debugPrint('Anonymous sign-in failed: $e');
  }
  try {
    await NotificationService().init();
  } catch (e) {
    notificationFailed = true;
    debugPrint('Notification setup failed: $e');
  }
  final settings = SettingsService();
  final requireAuth = await settings.loadRequireAuth();
  if (requireAuth) {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final l10n = await AppLocalizations.delegate.load(locale);
    final ok = await AuthService().authenticate(l10n);
    if (!ok) {
      return;
    }
  }
  final themeColor = await settings.loadThemeColor();
  final fontScale = await settings.loadFontScale();
  runApp(
    ChangeNotifierProvider(
      create: (_) => NoteProvider(),
      child: MyApp(
        themeColor: themeColor,
        fontScale: fontScale,
        authFailed: authFailed,
        notificationFailed: notificationFailed,
      ),
    ),
  );

}

class MyApp extends StatefulWidget {
  final Color themeColor;
  final double fontScale;
  final bool authFailed;
  final bool notificationFailed;
  const MyApp({
    super.key,
    required this.themeColor,
    required this.fontScale,
    this.authFailed = false,
    this.notificationFailed = false,
  });


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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      if (widget.authFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.authFailedMessage),
          ),
        );
      }
      if (widget.notificationFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notificationFailedMessage),
          ),
        );
      }
    });
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
