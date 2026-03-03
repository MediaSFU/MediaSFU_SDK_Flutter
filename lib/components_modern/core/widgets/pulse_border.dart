// ignore_for_file: unused_import

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_animations.dart';

/// A container with an animated pulsing border effect.
///
/// Supports:
/// - Single color pulse
/// - Gradient border pulse
/// - Multiple pulse waves
/// - Customizable pulse speed and intensity
class PulseBorderContainer extends StatefulWidget {
  /// The child widget to display inside the container.
  final Widget child;

  /// The pulse color. Defaults to primary theme color.
  final Color? pulseColor;

  /// List of colors for gradient pulse effect.
  final List<Color>? gradientColors;

  /// Background color of the container.
  final Color? backgroundColor;

  /// Border radius for the container corners.
  final double borderRadius;

  /// Width of the border.
  final double borderWidth;

  /// Padding inside the container.
  final EdgeInsetsGeometry? padding;

  /// Margin around the container.
  final EdgeInsetsGeometry? margin;

  /// Duration of one pulse cycle.
  final Duration pulseDuration;

  /// Whether the pulse animation is running.
  final bool isPulsing;

  /// Number of concurrent pulse waves.
  final int pulseWaves;

  /// Optional width constraint.
  final double? width;

  /// Optional height constraint.
  final double? height;

  /// Callback when the container is tapped.
  final VoidCallback? onTap;

  const PulseBorderContainer({
    super.key,
    required this.child,
    this.pulseColor,
    this.gradientColors,
    this.backgroundColor,
    this.borderRadius = 16,
    this.borderWidth = 2,
    this.padding,
    this.margin,
    this.pulseDuration = const Duration(milliseconds: 1500),
    this.isPulsing = true,
    this.pulseWaves = 1,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  State<PulseBorderContainer> createState() => _PulseBorderContainerState();
}

class _PulseBorderContainerState extends State<PulseBorderContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    );

    if (widget.isPulsing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(PulseBorderContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing && !oldWidget.isPulsing) {
      _controller.repeat();
    } else if (!widget.isPulsing && oldWidget.isPulsing) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.pulseColor ??
        (isDark ? MediasfuColors.primaryDark : MediasfuColors.primary);
    final bgColor = widget.backgroundColor ??
        (isDark ? MediasfuColors.surfaceDark : MediasfuColors.surface);

    Widget container = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _PulseBorderPainter(
            color: color,
            gradientColors: widget.gradientColors,
            borderRadius: widget.borderRadius,
            borderWidth: widget.borderWidth,
            animationValue: _controller.value,
            pulseWaves: widget.pulseWaves,
          ),
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            padding: widget.padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: widget.child,
          ),
        );
      },
    );

    if (widget.onTap != null) {
      container = GestureDetector(
        onTap: widget.onTap,
        child: container,
      );
    }

    return container;
  }
}

class _PulseBorderPainter extends CustomPainter {
  final Color color;
  final List<Color>? gradientColors;
  final double borderRadius;
  final double borderWidth;
  final double animationValue;
  final int pulseWaves;

  _PulseBorderPainter({
    required this.color,
    this.gradientColors,
    required this.borderRadius,
    required this.borderWidth,
    required this.animationValue,
    required this.pulseWaves,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    // Draw multiple pulse waves
    for (int i = 0; i < pulseWaves; i++) {
      final waveOffset = i / pulseWaves;
      final waveValue = (animationValue + waveOffset) % 1.0;

      // Calculate opacity based on wave phase
      final opacity = (1.0 - waveValue) * 0.6;

      // Calculate expansion
      final expansion = waveValue * 12;

      final expandedRect = RRect.fromRectAndRadius(
        rect.inflate(expansion),
        Radius.circular(borderRadius + expansion),
      );

      Paint paint;
      if (gradientColors != null && gradientColors!.isNotEmpty) {
        final gradient = SweepGradient(
          colors: [...gradientColors!, gradientColors!.first],
          startAngle: animationValue * 2 * math.pi,
          endAngle: (animationValue * 2 * math.pi) + (2 * math.pi),
        );
        paint = Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..color = color.withOpacity(opacity);
      } else {
        paint = Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;
      }

      canvas.drawRRect(expandedRect, paint);
    }

    // Draw the main border
    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    if (gradientColors != null && gradientColors!.isNotEmpty) {
      final gradient = SweepGradient(
        colors: [...gradientColors!, gradientColors!.first],
        startAngle: animationValue * 2 * math.pi,
        endAngle: (animationValue * 2 * math.pi) + (2 * math.pi),
      );
      mainPaint.shader = gradient.createShader(rect);
    }

    canvas.drawRRect(rrect, mainPaint);
  }

  @override
  bool shouldRepaint(_PulseBorderPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        color != oldDelegate.color;
  }
}

/// A simple pulsing ring indicator.
class PulseRing extends StatefulWidget {
  /// Size of the ring.
  final double size;

  /// Color of the ring.
  final Color? color;

  /// Width of the ring stroke.
  final double strokeWidth;

  /// Duration of one pulse cycle.
  final Duration duration;

  /// Number of rings.
  final int ringCount;

  /// Child widget in the center.
  final Widget? child;

  const PulseRing({
    super.key,
    this.size = 48,
    this.color,
    this.strokeWidth = 2,
    this.duration = const Duration(milliseconds: 1500),
    this.ringCount = 3,
    this.child,
  });

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing>
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
    final ringColor = widget.color ??
        (isDark ? MediasfuColors.primaryDark : MediasfuColors.primary);

    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _PulseRingPainter(
              color: ringColor,
              strokeWidth: widget.strokeWidth,
              animationValue: _controller.value,
              ringCount: widget.ringCount,
            ),
            child: Center(child: child),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _PulseRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double animationValue;
  final int ringCount;

  _PulseRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.animationValue,
    required this.ringCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide / 2;

    for (int i = 0; i < ringCount; i++) {
      final offset = i / ringCount;
      final value = (animationValue + offset) % 1.0;

      final radius = maxRadius * 0.3 + (maxRadius * 0.7 * value);
      final opacity = (1.0 - value).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_PulseRingPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}

/// An attention-grabbing pulsing button border.
class PulseButton extends StatelessWidget {
  /// The child widget (button content).
  final Widget child;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Pulse color.
  final Color? pulseColor;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Whether to show the pulse effect.
  final bool showPulse;

  /// Padding inside the button.
  final EdgeInsetsGeometry? padding;

  const PulseButton({
    super.key,
    required this.child,
    this.onPressed,
    this.pulseColor,
    this.backgroundColor,
    this.borderRadius = 12,
    this.showPulse = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return PulseBorderContainer(
      pulseColor: pulseColor,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      isPulsing: showPulse,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      onTap: onPressed,
      child: child,
    );
  }
}
