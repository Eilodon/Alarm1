import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'services/auth_service.dart';
import 'package:provider/provider.dart';
import 'providers/note_provider.dart';
import 'models/note.dart';
import 'firebase_options.dart';

final messengerKey = GlobalKey<ScaffoldMessengerState>();
late final NoteProvider noteProvider;

Future<void> _onNotificationResponse(NotificationResponse response) async {
  final id = response.payload;
  if (id == null) return;
  Note? note;
  try {
    note = noteProvider.notes.firstWhere((n) => n.id == id);
  } catch (_) {
    note = null;
  }
  if (note == null) return;
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final l10n = await AppLocalizations.delegate.load(locale);
  if (response.actionId == 'done') {
    await noteProvider.updateNote(
      note.copyWith(alarmTime: null, notificationId: null, active: false),
      l10n,
    );
  } else if (response.actionId == 'snooze') {
    await noteProvider.snoozeNote(note, l10n);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  noteProvider = NoteProvider();
  bool authFailed = false;
  bool notificationFailed = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.signInAnonymously();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    await FirebaseAnalytics.instance.logAppOpen();
  } catch (e) {
    authFailed = true;
  }

  try {
    await NotificationService().init(
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  } catch (e) {
    notificationFailed = true;
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
  final themeMode = await settings.loadThemeMode();

  final hasSeenOnboarding = await settings.loadHasSeenOnboarding();

  runApp(
    ChangeNotifierProvider.value(
      value: noteProvider,
      child: MyApp(
        themeColor: themeColor,
        fontScale: fontScale,

        themeMode: await settings.loadThemeMode(),


        hasSeenOnboarding: hasSeenOnboarding,

        authFailed: authFailed,
        notificationFailed: notificationFailed,
      ),
    ),
  );

}

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
        colorSchemeSeed: _themeColor,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: _themeColor,
        brightness: Brightness.dark,
        useMaterial3: true,
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
