import 'package:flutter/widgets.dart';

/// Defines the canonical spacing scale for the modern MediaSFU UI.
class MediasfuSpacing {
  MediasfuSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Full rounded (pill shape) - use a very large number
  static const double full = 9999;

  static EdgeInsets insetAll(double value) => EdgeInsets.all(value);

  static EdgeInsets insetSymmetric(
      {double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  static EdgeInsets insetHorizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);

  static EdgeInsets insetVertical(double value) =>
      EdgeInsets.symmetric(vertical: value);
}
