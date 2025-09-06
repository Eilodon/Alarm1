import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'models/note.dart';
import 'providers/note_provider.dart';
import 'services/auth_service.dart';
import 'services/settings_service.dart';
import 'services/startup_service.dart';
import 'app.dart';

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

