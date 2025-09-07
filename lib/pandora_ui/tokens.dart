import 'package:flutter/material.dart';

/// Basic design tokens used by Pandora UI components.
///
/// These values mirror the defaults defined in [Tokens] but are
/// accessible without a BuildContext, for example in tests.
class PandoraTokens {
  PandoraTokens._();

  /// Minimum dimension for interactive widgets.
  static const double touchTarget = 48.0;

  /// Medium spacing value.
  static const double spacingM = 16.0;

  /// Medium border radius.
  static const double radiusM = 12.0;

  /// Primary brand color.
  static const Color primary = Color(0xFF4255FF);
}
