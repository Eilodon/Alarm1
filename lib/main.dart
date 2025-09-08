import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:notes_reminder_app/generated/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:provider/provider.dart';

import 'app.dart';
import 'app_providers.dart';
import 'features/note/domain/domain.dart';
import 'features/note/presentation/note_provider.dart';
import 'services/app_initializer.dart';
import 'services/connectivity_service.dart';
import 'screens/error_screen.dart';
import 'features/settings/domain/settings_service.dart';

Future<void> _onNotificationResponse(
  dynamic response,
  BuildContext context,
) async {
  final notificationResponse = response as fln.NotificationResponse;
  final id = notificationResponse.payload;
  if (id == null || !context.mounted) return;
  final noteProvider = context.read<NoteProvider>();
  final note = noteProvider.notes.firstWhereOrNull((n) => n.id == id);
  if (note == null) return;
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final supported = AppLocalizations.delegate.isSupported(locale);
  final effectiveLocale = supported ? locale : const Locale('en');
  final l10n = await AppLocalizations.delegate.load(effectiveLocale);
  if (notificationResponse.actionId == 'done') {
    await noteProvider.updateNote(
      note.copyWith(alarmTime: null, notificationId: null, active: false),
      l10n,
    );
  } else if (notificationResponse.actionId == 'snooze') {
    await noteProvider.snoozeNote(note, l10n);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    AppProviders(
      child: Builder(
        builder: (context) {
          final settingsService = context.read<SettingsService>();
          return FutureBuilder<AppInitializationData>(
          future: AppInitializer(settingsService: settingsService).initialize(
            onDidReceiveNotificationResponse: (response) =>
                _onNotificationResponse(response, context),
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return MaterialApp(home: ErrorScreen(onRetry: main));
            }
            if (!snapshot.hasData) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            final data = snapshot.data!;
            return MyApp(
              themeColor: data.themeColor,
              fontScale: data.fontScale,
              themeMode: data.themeMode,
              hasSeenOnboarding: data.hasSeenOnboarding,
              authFailed: data.authFailed,
              notificationFailed: data.notificationFailed,
              connectivityService: ConnectivityService(),
              settingsService: settingsService,
            );
          },
        );
        },
      ),
    ),
  );
}
