import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_reminder_app/generated/app_localizations.dart';

class ConnectivityService {
  StreamSubscription<ConnectivityResult>? _subscription;
  ConnectivityResult? _lastResult;

  void initialize(
    AppLocalizations l10n,
    GlobalKey<ScaffoldMessengerState> messengerKey,
  ) {
    try {
      _subscription = Connectivity().onConnectivityChanged.listen((result) {
        if (_lastResult != null) {
          if (_lastResult == ConnectivityResult.none && result != ConnectivityResult.none) {
            messengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(l10n.internetConnectionRestored),
              ),
            );
          } else if (_lastResult != ConnectivityResult.none && result == ConnectivityResult.none) {
            messengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(l10n.noInternetConnection),
              ),
            );
          }
        }
        _lastResult = result;
      });
    } on MissingPluginException catch (e, st) {
      debugPrint('Connectivity plugin missing: $e\n$st');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
