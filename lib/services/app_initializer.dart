import 'package:flutter/material.dart';
import 'package:notes_reminder_app/generated/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;

import 'auth_service.dart';
import '../features/settings/data/settings_service.dart';
import '../features/note/data/notification_service.dart';
import 'startup_service.dart';

class AppInitializationData {
  final Color themeColor;
  final double fontScale;
  final ThemeMode themeMode;
  final bool hasSeenOnboarding;
  final bool authFailed;
  final bool notificationFailed;

  const AppInitializationData({
    required this.themeColor,
    required this.fontScale,
    required this.themeMode,
    required this.hasSeenOnboarding,
    this.authFailed = false,
    this.notificationFailed = false,
  });
}

class AppInitializer {
  Future<AppInitializationData> initialize({
    Future<void> Function(fln.NotificationResponse)?
        onDidReceiveNotificationResponse,
  }) async {
    final settings = SettingsService();
    final notificationService = NotificationServiceImpl();
    final futures = await Future.wait([
      StartupService(notificationService).initialize(
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      ),
      settings.loadThemeColor(),
      settings.loadFontScale(),
      settings.loadThemeMode(),
      settings.loadHasSeenOnboarding(),
      settings.loadRequireAuth(),
    ]);
    final startupResult = futures[0] as StartupResult;
    final themeColor = futures[1] as Color;
    final fontScale = futures[2] as double;
    final themeMode = futures[3] as ThemeMode;
    final hasSeenOnboarding = futures[4] as bool;
    final requireAuth = futures[5] as bool;

    if (requireAuth) {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final supported = AppLocalizations.delegate.isSupported(locale);
      final effectiveLocale = supported ? locale : const Locale('en');
      final l10n = await AppLocalizations.delegate.load(effectiveLocale);
      final ok = await AuthService().authenticate(l10n);
      if (!ok) {
        return AppInitializationData(
          themeColor: themeColor,
          fontScale: fontScale,
          themeMode: themeMode,
          hasSeenOnboarding: hasSeenOnboarding,
          authFailed: true,
          notificationFailed: startupResult.notificationFailed,
        );
      }
    }

    return AppInitializationData(
      themeColor: themeColor,
      fontScale: fontScale,
      themeMode: themeMode,
      hasSeenOnboarding: hasSeenOnboarding,
      authFailed: startupResult.authFailed,
      notificationFailed: startupResult.notificationFailed,
    );
  }
}
