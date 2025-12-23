import 'package:flutter/material.dart';

/// Typography scale derived from the redesign specification.
class MediasfuTypography {
  MediasfuTypography._();

  static const String _fontFamily = 'Inter';

  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.05,
    fontFamily: _fontFamily,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.1,
    fontFamily: _fontFamily,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    fontFamily: _fontFamily,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    fontFamily: _fontFamily,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  static TextTheme textTheme({required bool darkMode}) {
    final baseColor = darkMode ? Colors.white : const Color(0xFF0F172A);
    final muted = baseColor.withOpacity(0.74);

    return TextTheme(
      displayLarge: displayLarge.copyWith(color: baseColor),
      displayMedium: displayMedium.copyWith(color: baseColor),
      headlineLarge: headlineLarge.copyWith(color: baseColor),
      titleLarge: titleLarge.copyWith(color: baseColor),
      bodyLarge: bodyLarge.copyWith(color: muted),
      bodyMedium: bodyLarge.copyWith(fontSize: 14, color: muted),
      bodySmall:
          bodyLarge.copyWith(fontSize: 12, color: muted.withOpacity(0.8)),
      labelLarge: labelLarge.copyWith(color: baseColor),
      labelMedium: labelLarge.copyWith(fontSize: 12, color: muted),
    );
  }

  // Convenience helpers for legacy call-sites while we migrate sizing.
  static TextStyle getTitleLarge(bool darkMode) =>
      textTheme(darkMode: darkMode).titleLarge ?? titleLarge;

  static TextStyle getTitleMedium(bool darkMode) =>
      (textTheme(darkMode: darkMode).titleLarge ?? titleLarge)
          .copyWith(fontSize: 18, fontWeight: FontWeight.w600);

  static TextStyle getTitleSmall(bool darkMode) =>
      (textTheme(darkMode: darkMode).titleLarge ?? titleLarge)
          .copyWith(fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle getBodySmall(bool darkMode) =>
      textTheme(darkMode: darkMode).bodySmall ?? bodyLarge;

  static TextStyle getBodyMedium(bool darkMode) =>
      textTheme(darkMode: darkMode).bodyMedium ?? bodyLarge;
}
