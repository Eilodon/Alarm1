import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;

import 'package:notes_reminder_app/firebase_options.dart';
import 'package:alarm_domain/alarm_domain.dart';

class StartupResult {
  final bool authFailed;
  final bool notificationFailed;

  const StartupResult({
    this.authFailed = false,
    this.notificationFailed = false,
  });
}

class StartupService {
  final NotificationService _notificationService;
  StartupService(this._notificationService);

  Future<StartupResult> initialize({
    Future<void> Function(fln.NotificationResponse)?
        onDidReceiveNotificationResponse,
  }) async {
    bool authFailed = false;
    bool notificationFailed = false;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseAuth.instance.signInAnonymously();
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(true);
      await FirebaseAnalytics.instance.logAppOpen();
    } catch (e, st) {
      authFailed = true;

      debugPrint('Firebase initialization error: $e\n$st');

    }

    try {
      await _notificationService.init(
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );
    } catch (e, st) {
      notificationFailed = true;

      debugPrint('Notification initialization error: $e\n$st');

    }

    return StartupResult(
      authFailed: authFailed,
      notificationFailed: notificationFailed,
    );
  }
}

