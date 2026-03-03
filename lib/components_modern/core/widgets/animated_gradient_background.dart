import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/mediasfu_colors.dart';

/// An animated gradient background that smoothly transitions between colors.
///
/// Supports:
/// - Multiple gradient types (linear, radial, sweep)
/// - Smooth color transitions
/// - Rotation animations
/// - Mesh gradient effects
class AnimatedGradientBackground extends StatefulWidget {
  /// The child widget to display on top of the gradient.
  final Widget? child;

  /// List of colors for the gradient.
  final List<Color>? colors;

  /// Duration for one complete animation cycle.
  final Duration duration;

  /// Type of gradient animation.
  final GradientAnimationType animationType;

  /// Whether the animation should run.
  final bool animate;

  /// Border radius for the container.
  final double? borderRadius;

  /// Optional custom gradient stops.
  final List<double>? stops;

  const AnimatedGradientBackground({
    super.key,
    this.child,
    this.colors,
    this.duration = const Duration(seconds: 5),
    this.animationType = GradientAnimationType.colorShift,
    this.animate = true,
    this.borderRadius,
    this.stops,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedGradientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.repeat();
    } else if (!widget.animate && oldWidget.animate) {
      _controller.stop();
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
    final gradientColors = widget.colors ??
        (isDark
            ? [
                MediasfuColors.primaryDark,
                MediasfuColors.accentDark,
                MediasfuColors.secondaryDarkMode,
              ]
            : [
                MediasfuColors.primary,
                MediasfuColors.accent,
                MediasfuColors.secondary,
              ]);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final gradient = _buildGradient(gradientColors);

        return Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: widget.borderRadius != null
                ? BorderRadius.circular(widget.borderRadius!)
                : null,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  Gradient _buildGradient(List<Color> colors) {
    switch (widget.animationType) {
      case GradientAnimationType.colorShift:
        return _buildColorShiftGradient(colors);
      case GradientAnimationType.rotate:
        return _buildRotatingGradient(colors);
      case GradientAnimationType.wave:
        return _buildWaveGradient(colors);
      case GradientAnimationType.radialPulse:
        return _buildRadialPulseGradient(colors);
      case GradientAnimationType.sweep:
        return _buildSweepGradient(colors);
    }
  }

  LinearGradient _buildColorShiftGradient(List<Color> colors) {
    // Shift colors based on animation value
    final shift = (_controller.value * colors.length).floor();
    final shiftedColors = <Color>[];
    for (int i = 0; i < colors.length; i++) {
      shiftedColors.add(colors[(i + shift) % colors.length]);
    }

    // Interpolate between current and next color set
    final progress = (_controller.value * colors.length) % 1.0;
    final nextShift = (shift + 1) % colors.length;
    final interpolatedColors = <Color>[];
    for (int i = 0; i < colors.length; i++) {
      final current = colors[(i + shift) % colors.length];
      final next = colors[(i + nextShift) % colors.length];
      interpolatedColors.add(Color.lerp(current, next, progress)!);
    }

    return LinearGradient(
      colors: interpolatedColors,
      stops: widget.stops,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient _buildRotatingGradient(List<Color> colors) {
    final angle = _controller.value * 2 * math.pi;
    final x = math.cos(angle);
    final y = math.sin(angle);

    return LinearGradient(
      colors: colors,
      stops: widget.stops,
      begin: Alignment(-x, -y),
      end: Alignment(x, y),
    );
  }

  LinearGradient _buildWaveGradient(List<Color> colors) {
    final wave = math.sin(_controller.value * 2 * math.pi);
    final offset = wave * 0.5;

    return LinearGradient(
      colors: colors,
      stops: widget.stops,
      begin: Alignment(-1 + offset, -1 - offset),
      end: Alignment(1 + offset, 1 - offset),
    );
  }

  RadialGradient _buildRadialPulseGradient(List<Color> colors) {
    final pulse = 0.8 + (math.sin(_controller.value * 2 * math.pi) * 0.4);

    return RadialGradient(
      colors: colors,
      stops: widget.stops,
      radius: pulse,
      center: Alignment.center,
    );
  }

  SweepGradient _buildSweepGradient(List<Color> colors) {
    final rotation = _controller.value * 2 * math.pi;

    return SweepGradient(
      colors: [...colors, colors.first],
      stops: widget.stops ??
          List.generate(colors.length + 1, (i) => i / colors.length),
      startAngle: rotation,
      endAngle: rotation + 2 * math.pi,
      center: Alignment.center,
    );
  }
}

/// Types of gradient animations available.
enum GradientAnimationType {
  /// Colors smoothly shift through the palette.
  colorShift,

  /// Gradient rotates around the center.
  rotate,

  /// Gradient moves in a wave pattern.
  wave,

  /// Radial gradient pulses in and out.
  radialPulse,

  /// Sweep gradient rotates continuously.
  sweep,
}

/// A mesh gradient background with multiple focal points.
class MeshGradientBackground extends StatefulWidget {
  /// The child widget.
  final Widget? child;

  /// Colors for the mesh points.
  final List<Color>? colors;

  /// Duration for the animation cycle.
  final Duration duration;

  /// Whether to animate the mesh.
  final bool animate;

  /// Border radius.
  final double? borderRadius;

  /// Number of mesh points.
  final int meshPoints;

  const MeshGradientBackground({
    super.key,
    this.child,
    this.colors,
    this.duration = const Duration(seconds: 8),
    this.animate = true,
    this.borderRadius,
    this.meshPoints = 4,
  });

  @override
  State<MeshGradientBackground> createState() => _MeshGradientBackgroundState();
}

class _MeshGradientBackgroundState extends State<MeshGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.animate) {
      _controller.repeat();
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
    final colors = widget.colors ??
        (isDark
            ? [
                MediasfuColors.primaryDark.withOpacity(0.6),
                MediasfuColors.accentDark.withOpacity(0.6),
                MediasfuColors.secondaryDarkMode.withOpacity(0.6),
                MediasfuColors.successLight.withOpacity(0.4),
              ]
            : [
                MediasfuColors.primary.withOpacity(0.4),
                MediasfuColors.accent.withOpacity(0.4),
                MediasfuColors.secondary.withOpacity(0.4),
                MediasfuColors.success.withOpacity(0.3),
              ]);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _MeshGradientPainter(
            colors: colors,
            animationValue: _controller.value,
            meshPoints: widget.meshPoints,
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius != null
                ? BorderRadius.circular(widget.borderRadius!)
                : BorderRadius.zero,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _MeshGradientPainter extends CustomPainter {
  final List<Color> colors;
  final double animationValue;
  final int meshPoints;

  _MeshGradientPainter({
    required this.colors,
    required this.animationValue,
    required this.meshPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Create multiple overlapping radial gradients
    for (int i = 0; i < meshPoints && i < colors.length; i++) {
      final phase = (animationValue + (i / meshPoints)) % 1.0;
      final angle = phase * 2 * math.pi;

      // Calculate position - orbiting around center
      final radius = size.shortestSide * 0.3;
      final centerX =
          size.width / 2 + math.cos(angle + (i * math.pi / 2)) * radius;
      final centerY =
          size.height / 2 + math.sin(angle + (i * math.pi / 2)) * radius;

      final gradient = RadialGradient(
        center: Alignment(
          (centerX / size.width) * 2 - 1,
          (centerY / size.height) * 2 - 1,
        ),
        radius: 0.8,
        colors: [
          colors[i],
          colors[i].withOpacity(0),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..blendMode = BlendMode.plus;

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_MeshGradientPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}

/// A simple aurora-style animated background.
class AuroraBackground extends StatelessWidget {
  /// The child widget.
  final Widget? child;

  /// Duration for the animation.
  final Duration duration;

  /// Whether to animate.
  final bool animate;

  /// Border radius.
  final double? borderRadius;

  const AuroraBackground({
    super.key,
    this.child,
    this.duration = const Duration(seconds: 6),
    this.animate = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedGradientBackground(
      colors: isDark
          ? [
              const Color(0xFF10B981).withOpacity(0.6),
              const Color(0xFF22D3EE).withOpacity(0.6),
              const Color(0xFF60A5FA).withOpacity(0.6),
              const Color(0xFF818CF8).withOpacity(0.6),
            ]
          : [
              const Color(0xFF059669).withOpacity(0.4),
              const Color(0xFF06B6D4).withOpacity(0.4),
              const Color(0xFF3B82F6).withOpacity(0.4),
              const Color(0xFF6366F1).withOpacity(0.4),
            ],
      duration: duration,
      animationType: GradientAnimationType.colorShift,
      animate: animate,
      borderRadius: borderRadius,
      child: child,
    );
  }
}
