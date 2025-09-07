import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'models/note.dart';
import 'providers/note_provider.dart';
import 'services/app_initializer.dart';
import 'services/connectivity_service.dart';

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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  noteProvider = NoteProvider();

  runApp(
    FutureBuilder<AppInitializationData?>(
      future: AppInitializer().initialize(
        onDidReceiveNotificationResponse: _onNotificationResponse,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final data = snapshot.data!;
        return ChangeNotifierProvider.value(
          value: noteProvider,
          child: MyApp(
            themeColor: data.themeColor,
            fontScale: data.fontScale,
            themeMode: data.themeMode,
            hasSeenOnboarding: data.hasSeenOnboarding,
            authFailed: data.authFailed,
            notificationFailed: data.notificationFailed,
            connectivityService: ConnectivityService(),
          ),
        );
      },
    ),
  );
}
