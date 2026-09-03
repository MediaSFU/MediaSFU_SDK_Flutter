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

  // ═══════════════════════════════════════════════════════════════════════
  // TYPE RAMP
  // ═══════════════════════════════════════════════════════════════════════
  //
  // Derived from what the modern components actually used, which was twelve
  // distinct sizes with no scale behind them — 12 appeared 77 times, 13 thirty
  // five times, 11 seventeen, 10 thirteen, 9 six, 15 seven. Consolidating to
  // eight steps moves only 9 -> 10, 12.5 -> 12 and 15 -> 16, so nothing shifts
  // by more than a pixel, but sizing becomes a decision rather than an
  // accident. A value that is not on this ramp should now look wrong.

  /// Badges, counters, timestamps. 10
  static const double sizeMicro = 10;

  /// Captions and helper text under a control. 11
  static const double sizeCaption = 11;

  /// The workhorse body size. 12
  static const double sizeBodySmall = 12;

  /// Body text that needs a little more presence. 13
  static const double sizeBodyCompact = 13;

  /// Default body and list rows. 14
  static const double sizeBodyMedium = 14;

  /// Section headings inside a panel. 16
  static const double sizeTitleSmall = 16;

  /// Modal titles. 18
  static const double sizeTitleMedium = 18;

  /// Screen and sheet titles. 22
  static const double sizeTitleLarge = 22;

  /// Countdowns and single big numbers. 32
  static const double sizeDisplay = 32;

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
