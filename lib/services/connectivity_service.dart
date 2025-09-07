import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_reminder_app/generated/app_localizations.dart';

class ConnectivityService {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  List<ConnectivityResult>? _lastResult;

  void initialize(
    AppLocalizations l10n,
    GlobalKey<ScaffoldMessengerState> messengerKey,
  ) {
    try {
      _subscription = Connectivity().onConnectivityChanged.listen((results) {
        if (_lastResult != null) {
          final wasOffline = _lastResult!.contains(ConnectivityResult.none);
          final isOffline = results.contains(ConnectivityResult.none);
          if (wasOffline && !isOffline) {
            messengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(l10n.internetConnectionRestored),
              ),
            );
          } else if (!wasOffline && isOffline) {
            messengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(l10n.noInternetConnection),
              ),
            );
          }
        }
        _lastResult = results;
      });
    } on MissingPluginException catch (e, st) {
      debugPrint('Connectivity plugin missing: $e\n$st');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
