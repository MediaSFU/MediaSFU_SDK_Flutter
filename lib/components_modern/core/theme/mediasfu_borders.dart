// ignore_for_file: unused_import
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'mediasfu_colors.dart';

/// Border utilities for the modern MediaSFU UI.
///
/// Provides:
/// - Animated gradient borders
/// - Glowing border effects
/// - Neumorphic border styles
/// - Focus ring utilities
/// - Pulse border animations
class MediasfuBorders {
  MediasfuBorders._();

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// No radius
  static const double none = 0;

  /// Extra small - 4px
  static const double xs = 4;

  /// Small - 8px
  static const double sm = 8;

  /// Medium - 12px
  static const double md = 12;

  /// Large - 16px
  static const double lg = 16;

  /// Extra large - 20px
  static const double xl = 20;

  /// 2XL - 24px
  static const double xxl = 24;

  /// 3XL - 32px
  static const double xxxl = 32;

  /// Full/Pill - 9999px
  static const double full = 9999;

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Circular radius for all corners
  static BorderRadius circular(double radius) => BorderRadius.circular(radius);

  /// Radius for top corners only
  static BorderRadius top(double radius) => BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      );

  /// Radius for bottom corners only
  static BorderRadius bottom(double radius) => BorderRadius.only(
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );

  /// Radius for left corners only
  static BorderRadius left(double radius) => BorderRadius.only(
        topLeft: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
      );

  /// Radius for right corners only
  static BorderRadius right(double radius) => BorderRadius.only(
        topRight: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER STYLE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Subtle border for cards and containers
  static Border subtle({bool darkMode = false}) {
    return Border.all(
      color: darkMode
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.06),
      width: 1,
    );
  }

  /// Standard border for inputs and interactive elements
  static Border standard({bool darkMode = false}) {
    return Border.all(
      color: darkMode ? MediasfuColors.dividerDark : MediasfuColors.divider,
      width: 1,
    );
  }

  /// Emphasized border for focused elements
  static Border emphasized({bool darkMode = false, Color? color}) {
    return Border.all(
      color: color ??
          (darkMode ? MediasfuColors.primaryDark : MediasfuColors.primary),
      width: 2,
    );
  }

  /// Focus ring border
  static BoxDecoration focusRing({
    bool darkMode = false,
    Color? color,
    double borderRadius = lg,
  }) {
    final ringColor = color ?? MediasfuColors.focusRing(darkMode: darkMode);
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: ringColor,
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: ringColor.withOpacity(0.3),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ],
    );
  }

  /// Error state border
  static Border error({bool darkMode = false}) {
    return Border.all(
      color: darkMode ? MediasfuColors.dangerLight : MediasfuColors.danger,
      width: 2,
    );
  }

  /// Success state border
  static Border success({bool darkMode = false}) {
    return Border.all(
      color: darkMode ? MediasfuColors.successLight : MediasfuColors.success,
      width: 2,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// GRADIENT BORDER PAINTER
// ═════════════════════════════════════════════════════════════════════════════

/// Custom painter for gradient borders.
class GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double strokeWidth;
  final double borderRadius;

  GradientBorderPainter({
    required this.gradient,
    this.strokeWidth = 2.0,
    this.borderRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(borderRadius - strokeWidth / 2),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(GradientBorderPainter oldDelegate) {
    return gradient != oldDelegate.gradient ||
        strokeWidth != oldDelegate.strokeWidth ||
        borderRadius != oldDelegate.borderRadius;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ANIMATED GRADIENT BORDER PAINTER
// ═════════════════════════════════════════════════════════════════════════════

/// Custom painter for animated rotating gradient borders.
class AnimatedGradientBorderPainter extends CustomPainter {
  final List<Color> colors;
  final double strokeWidth;
  final double borderRadius;
  final double rotation;

  AnimatedGradientBorderPainter({
    required this.colors,
    this.strokeWidth = 2.0,
    this.borderRadius = 16.0,
    this.rotation = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Rotate the gradient
    final rotatedGradient = SweepGradient(
      center: Alignment.center,
      startAngle: rotation,
      endAngle: rotation + math.pi * 2,
      colors: [...colors, colors.first], // Close the loop
      stops: List.generate(colors.length + 1, (i) => i / colors.length),
    );

    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(borderRadius - strokeWidth / 2),
    );

    final paint = Paint()
      ..shader = rotatedGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(AnimatedGradientBorderPainter oldDelegate) {
    return rotation != oldDelegate.rotation ||
        strokeWidth != oldDelegate.strokeWidth ||
        borderRadius != oldDelegate.borderRadius;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// GLOW BORDER PAINTER
// ═════════════════════════════════════════════════════════════════════════════

/// Custom painter for glowing borders.
class GlowBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final double glowIntensity;

  GlowBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.borderRadius = 16.0,
    this.glowIntensity = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(borderRadius - strokeWidth / 2),
    );

    // Draw multiple layers for glow effect
    for (int i = 3; i >= 0; i--) {
      final glowPaint = Paint()
        ..color = color.withOpacity((0.1 + (0.1 * i)) * glowIntensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + (i * 4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0 + (i * 2));
      canvas.drawRRect(rrect, glowPaint);
    }

    // Draw solid border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(GlowBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        borderRadius != oldDelegate.borderRadius ||
        glowIntensity != oldDelegate.glowIntensity;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// GRADIENT BORDER WIDGET
// ═════════════════════════════════════════════════════════════════════════════

/// A container with a gradient border.
class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final double strokeWidth;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const GradientBorderContainer({
    super.key,
    required this.child,
    this.gradient,
    this.strokeWidth = 2.0,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultGradient = MediasfuColors.brandGradient(darkMode: isDark);

    return CustomPaint(
      painter: GradientBorderPainter(
        gradient: gradient ?? defaultGradient,
        strokeWidth: strokeWidth,
        borderRadius: borderRadius,
      ),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ANIMATED GRADIENT BORDER WIDGET
// ═════════════════════════════════════════════════════════════════════════════

/// A container with an animated rotating gradient border.
class AnimatedGradientBorderContainer extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final double strokeWidth;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final Duration duration;

  const AnimatedGradientBorderContainer({
    super.key,
    required this.child,
    this.colors,
    this.strokeWidth = 2.0,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.padding,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedGradientBorderContainer> createState() =>
      _AnimatedGradientBorderContainerState();
}

class _AnimatedGradientBorderContainerState
    extends State<AnimatedGradientBorderContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColors = isDark
        ? [
            MediasfuColors.primaryDark,
            MediasfuColors.accentDark,
            MediasfuColors.secondaryDarkMode,
          ]
        : [
            MediasfuColors.primary,
            MediasfuColors.accent,
            MediasfuColors.secondary,
          ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, animChild) {
        return CustomPaint(
          painter: AnimatedGradientBorderPainter(
            colors: widget.colors ?? defaultColors,
            strokeWidth: widget.strokeWidth,
            borderRadius: widget.borderRadius,
            rotation: _controller.value * math.pi * 2,
          ),
          child: animChild,
        );
      },
      child: Container(
        padding: widget.padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: widget.child,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// GLOW BORDER WIDGET
// ═════════════════════════════════════════════════════════════════════════════

/// A container with a glowing border.
class GlowBorderContainer extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final double strokeWidth;
  final double borderRadius;
  final double glowIntensity;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const GlowBorderContainer({
    super.key,
    required this.child,
    this.glowColor,
    this.strokeWidth = 2.0,
    this.borderRadius = 16.0,
    this.glowIntensity = 0.5,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = glowColor ??
        (isDark ? MediasfuColors.primaryDark : MediasfuColors.primary);

    return CustomPaint(
      painter: GlowBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        borderRadius: borderRadius,
        glowIntensity: glowIntensity,
      ),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}
