import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'app_providers.dart';
import 'features/note/domain/entities/note.dart';
import 'features/note/presentation/providers/note_provider.dart';
import 'services/app_initializer.dart';
import 'services/connectivity_service.dart';
import 'screens/error_screen.dart';

Future<void> _onNotificationResponse(
  NotificationResponse response,
  BuildContext context,
) async {
  final id = response.payload;
  if (id == null || !context.mounted) return;
  final noteProvider = context.read<NoteProvider>();
  Note? note;
  try {
    note = noteProvider.notes.firstWhere((n) => n.id == id);
  } catch (_) {
    note = null;
  }
  if (note == null) return;
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final supported = AppLocalizations.delegate.isSupported(locale);
  final effectiveLocale = supported ? locale : const Locale('en');
  final l10n = await AppLocalizations.delegate.load(effectiveLocale);
  if (response.actionId == 'done') {
    await noteProvider.updateNote(
      note.copyWith(alarmTime: null, notificationId: null, active: false),
      l10n,
    );
  } else if (response.actionId == 'snooze') {
    await noteProvider.snoozeNote(note, l10n);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    AppProviders(
      child: Builder(
        builder: (context) => FutureBuilder<AppInitializationData>(
          future: AppInitializer().initialize(
            onDidReceiveNotificationResponse: (response) =>
                _onNotificationResponse(response, context),
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return MaterialApp(
                home: ErrorScreen(onRetry: main),
              );
            }
            if (!snapshot.hasData) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
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
            );
          },
        ),
      ),
    ),
  );
}
