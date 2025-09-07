import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConnectivityService {
  StreamSubscription<ConnectivityResult>? _subscription;
  ConnectivityResult? _lastResult;

  void initialize(BuildContext context, GlobalKey<ScaffoldMessengerState> messengerKey) {
    try {
      _subscription = Connectivity().onConnectivityChanged.listen((result) {
        if (!context.mounted) return;
        final l10n = AppLocalizations.of(context)!;
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
    } on MissingPluginException {
      // Ignore if connectivity plugin is not available (e.g., tests)
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
