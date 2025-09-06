import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'services/auth_service.dart';

import 'package:provider/provider.dart';

import 'models/note.dart';

import 'firebase_options.dart';
import 'pandora_ui/tokens.dart';


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

  final startupResult = await StartupService().initialize(
    onDidReceiveNotificationResponse: _onNotificationResponse,
  );

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
        themeMode: themeMode,
        hasSeenOnboarding: hasSeenOnboarding,
        authFailed: startupResult.authFailed,
        notificationFailed: startupResult.notificationFailed,
      ),
    ),
  );
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
          seedColor: PandoraTokens.primary,
          background: PandoraTokens.lightBg,
          surface: PandoraTokens.neutral100,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: PandoraTokens.primary,
          background: PandoraTokens.darkBg,
          surface: PandoraTokens.neutral900,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
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
            )
          : OnboardingScreen(onFinished: _completeOnboarding),


    );
  }
}

