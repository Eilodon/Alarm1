import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConnectivityService {
  StreamSubscription<ConnectivityResult>? _subscription;

  void initialize(BuildContext context, GlobalKey<ScaffoldMessengerState> messengerKey) {
    try {
      _subscription = Connectivity().onConnectivityChanged.listen((result) {
        if (result == ConnectivityResult.none) {
          final l10n = AppLocalizations.of(context)!;
          messengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(l10n.noInternetConnection),
            ),
          );
        }
      });
    } on MissingPluginException {
      // Ignore if connectivity plugin is not available (e.g., tests)
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
