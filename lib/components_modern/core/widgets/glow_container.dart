import 'package:flutter/material.dart';
import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_animations.dart';

/// A container with customizable glowing effects.
///
/// Supports:
/// - Static glow
/// - Animated pulsing glow
/// - Hover glow intensity changes
/// - Neon-style intense glow
class GlowContainer extends StatefulWidget {
  /// The child widget to display inside the container.
  final Widget child;

  /// The glow color. Defaults to primary theme color.
  final Color? glowColor;

  /// Intensity of the glow (0.0 - 1.0).
  final double glowIntensity;

  /// Background color of the container.
  final Color? backgroundColor;

  /// Border radius for the container corners.
  final double borderRadius;

  /// Padding inside the container.
  final EdgeInsetsGeometry? padding;

  /// Margin around the container.
  final EdgeInsetsGeometry? margin;

  /// Whether the glow should pulse/animate.
  final bool isPulsing;

  /// Duration of the pulse animation.
  final Duration pulseDuration;

  /// Whether to use neon-style intense glow.
  final bool isNeon;

  /// Optional width constraint.
  final double? width;

  /// Optional height constraint.
  final double? height;

  /// Whether to show glow on hover only.
  final bool glowOnHover;

  /// Callback when the container is tapped.
  final VoidCallback? onTap;

  const GlowContainer({
    super.key,
    required this.child,
    this.glowColor,
    this.glowIntensity = 0.5,
    this.backgroundColor,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.isPulsing = false,
    this.pulseDuration = const Duration(milliseconds: 1500),
    this.isNeon = false,
    this.width,
    this.height,
    this.glowOnHover = false,
    this.onTap,
  });

  @override
  State<GlowContainer> createState() => _GlowContainerState();
}

class _GlowContainerState extends State<GlowContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlowContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing && !oldWidget.isPulsing) {
      _controller.repeat(reverse: true);
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
    final color = widget.glowColor ??
        (isDark ? MediasfuColors.primaryDark : MediasfuColors.primary);
    final bgColor = widget.backgroundColor ??
        (isDark ? MediasfuColors.surfaceDark : MediasfuColors.surface);

    Widget container = AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final effectiveIntensity = widget.glowOnHover
            ? (_isHovered ? widget.glowIntensity : 0.0)
            : widget.glowIntensity;

        final pulsePhase = widget.isPulsing ? _pulseAnimation.value : 0.0;

        final shadows = widget.isNeon
            ? MediasfuColors.neonGlow(color)
            : widget.isPulsing
                ? MediasfuColors.pulseGlow(color, pulsePhase)
                : MediasfuColors.glowShadow(color,
                    intensity: effectiveIntensity);

        return AnimatedContainer(
          duration: MediasfuAnimations.fast,
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          padding: widget.padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: shadows,
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: widget.child,
        );
      },
    );

    if (widget.glowOnHover || widget.onTap != null) {
      container = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: container,
        ),
      );
    }

    return container;
  }
}

/// A glowing card variant with optional gradient background.
class GlowCard extends StatelessWidget {
  /// The child widget.
  final Widget child;

  /// Title displayed at the top of the card.
  final String? title;

  /// Subtitle displayed below the title.
  final String? subtitle;

  /// Icon displayed before the title.
  final IconData? icon;

  /// The glow color.
  final Color? glowColor;

  /// Glow intensity (0.0 - 1.0).
  final double glowIntensity;

  /// Whether to use gradient background.
  final bool useGradient;

  /// Border radius.
  final double borderRadius;

  /// Padding inside the card.
  final EdgeInsetsGeometry? padding;

  /// Callback when tapped.
  final VoidCallback? onTap;

  const GlowCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.glowColor,
    this.glowIntensity = 0.3,
    this.useGradient = false,
    this.borderRadius = 16,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || icon != null)
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: glowColor ??
                      (isDark
                          ? MediasfuColors.primaryDark
                          : MediasfuColors.primary),
                ),
                const SizedBox(width: 8),
              ],
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: textTheme.bodySmall?.copyWith(
              color: isDark
                  ? MediasfuColors.textMutedDark
                  : MediasfuColors.textMuted,
            ),
          ),
        ],
        if (title != null || subtitle != null) const SizedBox(height: 12),
        child,
      ],
    );

    return GlowContainer(
      glowColor: glowColor,
      glowIntensity: glowIntensity,
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.all(16),
      glowOnHover: true,
      onTap: onTap,
      backgroundColor: useGradient
          ? null
          : (isDark ? MediasfuColors.cardDark : MediasfuColors.card),
      child: useGradient
          ? ShaderMask(
              shaderCallback: (bounds) =>
                  MediasfuColors.brandGradient(darkMode: isDark)
                      .createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: content,
            )
          : content,
    );
  }
}

/// A circular glowing indicator/badge.
class GlowIndicator extends StatelessWidget {
  /// Size of the indicator.
  final double size;

  /// The glow color.
  final Color? color;

  /// Whether the indicator should pulse.
  final bool isPulsing;

  /// Whether to use neon-style glow.
  final bool isNeon;

  /// Optional child widget (e.g., icon or text).
  final Widget? child;

  const GlowIndicator({
    super.key,
    this.size = 12,
    this.color,
    this.isPulsing = true,
    this.isNeon = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final glowColor = color ?? MediasfuColors.success;

    return GlowContainer(
      glowColor: glowColor,
      glowIntensity: 0.6,
      isPulsing: isPulsing,
      isNeon: isNeon,
      borderRadius: size / 2,
      width: size,
      height: size,
      padding: EdgeInsets.zero,
      backgroundColor: glowColor,
      child: child ?? const SizedBox.shrink(),
    );
  }
}
