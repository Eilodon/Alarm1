import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/settings_service.dart';
import 'theme/tokens.dart';

final messengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  final Color themeColor;
  final double fontScale;
  final ThemeMode themeMode;
  final bool authFailed;
  final bool notificationFailed;
  final bool hasSeenOnboarding;
  const MyApp({
    super.key,
    required this.themeColor,
    required this.fontScale,
    required this.themeMode,
    required this.hasSeenOnboarding,
    this.authFailed = false,
    this.notificationFailed = false,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _themeColor = Colors.blue;
  double _fontScale = 1.0;
  ThemeMode _themeMode = ThemeMode.system;
  StreamSubscription<ConnectivityResult>? _connSub;
  bool _hasSeenOnboarding = true;

  @override
  void initState() {
    super.initState();
    _themeColor = widget.themeColor;
    _fontScale = widget.fontScale;
    _themeMode = widget.themeMode;
    _hasSeenOnboarding = widget.hasSeenOnboarding;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      if (widget.authFailed) {
        messengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(l10n.authFailedMessage),
          ),
        );
      }
      if (widget.notificationFailed) {
        messengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(l10n.notificationFailedMessage),
          ),
        );
      }
    });
    try {
      _connSub = Connectivity().onConnectivityChanged.listen((result) {
        if (result == ConnectivityResult.none) {
          final l10n = AppLocalizations.of(context)!;
          messengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(l10n.noInternetConnection),
            ),
          );
        }
      });
    } on MissingPluginException {
      // Ignore if connectivity plugin is not available (e.g., tests)
    }
  }

  void updateTheme(Color newColor) async {
    setState(() => _themeColor = newColor);
    await SettingsService().saveThemeColor(newColor);
  }

  void updateFontScale(double newScale) async {
    setState(() => _fontScale = newScale);
    await SettingsService().saveFontScale(newScale);
  }

  void updateThemeMode(ThemeMode newMode) async {
    setState(() => _themeMode = newMode);
    await SettingsService().saveThemeMode(newMode);
  }

  void _completeOnboarding() {
    setState(() => _hasSeenOnboarding = true);
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('vi')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _themeColor,
          background: Tokens.light.colors.background,
          surface: Tokens.light.colors.surface,
        ),
        fontFamily: Tokens.light.typography.fontFamily,
        useMaterial3: true,
        extensions: const [Tokens.light],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _themeColor,
          background: Tokens.dark.colors.background,
          surface: Tokens.dark.colors.surface,
          brightness: Brightness.dark,
        ),
        fontFamily: Tokens.dark.typography.fontFamily,
        useMaterial3: true,
        extensions: const [Tokens.dark],
      ),
      themeMode: _themeMode,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: _fontScale),
        child: child!,
      ),
      home: _hasSeenOnboarding
          ? HomeScreen(
              onThemeChanged: updateTheme,
              onFontScaleChanged: updateFontScale,
              onThemeModeChanged: updateThemeMode,
            )
          : OnboardingScreen(onFinished: _completeOnboarding),
    );
  }
}

