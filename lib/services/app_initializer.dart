import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'auth_service.dart';
import 'settings_service.dart';
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
    Future<void> Function(NotificationResponse)? onDidReceiveNotificationResponse,
  }) async {
    final startupResult = await StartupService().initialize(
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    final settings = SettingsService();
    final requireAuth = await settings.loadRequireAuth();
    if (requireAuth) {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final supported = AppLocalizations.delegate.isSupported(locale);
      final effectiveLocale = supported ? locale : const Locale('en');
      final l10n = await AppLocalizations.delegate.load(effectiveLocale);
      final ok = await AuthService().authenticate(l10n);
      if (!ok) {
        final results = await Future.wait([
          settings.loadThemeColor(),
          settings.loadFontScale(),
          settings.loadThemeMode(),
          settings.loadHasSeenOnboarding(),
        ]);
        final themeColor = results[0] as Color;
        final fontScale = results[1] as double;
        final themeMode = results[2] as ThemeMode;
        final hasSeenOnboarding = results[3] as bool;
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
    final results = await Future.wait([
      settings.loadThemeColor(),
      settings.loadFontScale(),
      settings.loadThemeMode(),
      settings.loadHasSeenOnboarding(),
    ]);
    final themeColor = results[0] as Color;
    final fontScale = results[1] as double;
    final themeMode = results[2] as ThemeMode;
    final hasSeenOnboarding = results[3] as bool;

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
