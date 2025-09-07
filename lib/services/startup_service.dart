import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;

import '../firebase_options.dart';
import 'notification_service.dart';

class StartupResult {
  final bool authFailed;
  final bool notificationFailed;

  const StartupResult({
    this.authFailed = false,
    this.notificationFailed = false,
  });
}

class StartupService {
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
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      await FirebaseAnalytics.instance.logAppOpen();
    } catch (_) {
      authFailed = true;
    }

    try {
      await NotificationService().init(
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );
    } catch (_) {
      notificationFailed = true;
    }

    return StartupResult(
      authFailed: authFailed,
      notificationFailed: notificationFailed,
    );
  }
}

