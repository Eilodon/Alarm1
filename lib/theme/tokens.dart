import 'package:flutter/material.dart';

@immutable
class Tokens extends ThemeExtension<Tokens> {
  final Spacing spacing;
  final Radii radii;
  final Elevation elevation;
  final TypographyTokens typography;
  final ColorTokens colors;

  const Tokens({
    required this.spacing,
    required this.radii,
    required this.elevation,
    required this.typography,
    required this.colors,
  });

  static const light = Tokens(
    spacing: Spacing(),
    radii: Radii(),
    elevation: Elevation(),
    typography: TypographyTokens(),
    colors: ColorTokens.light(),
  );

  static const dark = Tokens(
    spacing: Spacing(),
    radii: Radii(),
    elevation: Elevation(),
    typography: TypographyTokens(),
    colors: ColorTokens.dark(),
  );

  @override
  Tokens copyWith({
    Spacing? spacing,
    Radii? radii,
    Elevation? elevation,
    TypographyTokens? typography,
    ColorTokens? colors,
  }) {
    return Tokens(
      spacing: spacing ?? this.spacing,
      radii: radii ?? this.radii,
      elevation: elevation ?? this.elevation,
      typography: typography ?? this.typography,
      colors: colors ?? this.colors,
    );
  }

  @override
  Tokens lerp(Tokens? other, double t) {
    if (other == null) return this;
    return Tokens(
      spacing: spacing,
      radii: radii,
      elevation: elevation,
      typography: typography,
      colors: ColorTokens.lerp(colors, other.colors, t),
    );
  }
}

@immutable
class Spacing {
  final double xs;
  final double s;
  final double m;
  final double l;
  final double xl;
  const Spacing({
    this.xs = 4,
    this.s = 8,
    this.m = 16,
    this.l = 24,
    this.xl = 32,
  });
}

@immutable
class Radii {
  final double xs;
  final double s;
  final double m;
  final double l;
  const Radii({
    this.xs = 4,
    this.s = 8,
    this.m = 12,
    this.l = 18,
  });
}

@immutable
class Elevation {
  final double low;
  final double medium;
  final double high;
  const Elevation({
    this.low = 2,
    this.medium = 6,
    this.high = 12,
  });
}

@immutable
class TypographyTokens {
  final String fontFamily;
  final double xs;
  final double s;
  final double m;
  final double l;
  final double xl;
  const TypographyTokens({
    this.fontFamily = 'Inter',
    this.xs = 11,
    this.s = 13,
    this.m = 15,
    this.l = 18,
    this.xl = 22,
  });
}

@immutable
class ColorTokens {
  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color error;
  final Color warning;
  final Color info;
  final Color neutral100;
  final Color neutral200;
  final Color neutral300;
  final Color neutral700;
  final Color neutral900;

  const ColorTokens({
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.error,
    required this.warning,
    required this.info,
    required this.neutral100,
    required this.neutral200,
    required this.neutral300,
    required this.neutral700,
    required this.neutral900,
  });

  const ColorTokens.light()
      : background = const Color(0xFFF8F8FA),
        surface = const Color(0xFFFFFFFF),
        primary = const Color(0xFF4255FF),
        secondary = const Color(0xFF22C1C3),
        error = const Color(0xFFFF3333),
        warning = const Color(0xFFFFD600),
        info = const Color(0xFF2196F3),
        neutral100 = const Color(0xFFFFFFFF),
        neutral200 = const Color(0xFFEEEEEE),
        neutral300 = const Color(0xFFBDBDBD),
        neutral700 = const Color(0xFF424242),
        neutral900 = const Color(0xFF191919);

  const ColorTokens.dark()
      : background = const Color(0xFF16161F),
        surface = const Color(0xFF191919),
        primary = const Color(0xFF4255FF),
        secondary = const Color(0xFF22C1C3),
        error = const Color(0xFFFF3333),
        warning = const Color(0xFFFFD600),
        info = const Color(0xFF2196F3),
        neutral100 = const Color(0xFFFFFFFF),
        neutral200 = const Color(0xFFEEEEEE),
        neutral300 = const Color(0xFFBDBDBD),
        neutral700 = const Color(0xFF424242),
        neutral900 = const Color(0xFF191919);

  static ColorTokens lerp(ColorTokens a, ColorTokens b, double t) {
    return ColorTokens(
      background: Color.lerp(a.background, b.background, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      primary: Color.lerp(a.primary, b.primary, t)!,
      secondary: Color.lerp(a.secondary, b.secondary, t)!,
      error: Color.lerp(a.error, b.error, t)!,
      warning: Color.lerp(a.warning, b.warning, t)!,
      info: Color.lerp(a.info, b.info, t)!,
      neutral100: Color.lerp(a.neutral100, b.neutral100, t)!,
      neutral200: Color.lerp(a.neutral200, b.neutral200, t)!,
      neutral300: Color.lerp(a.neutral300, b.neutral300, t)!,
      neutral700: Color.lerp(a.neutral700, b.neutral700, t)!,
      neutral900: Color.lerp(a.neutral900, b.neutral900, t)!,
    );
  }
}

