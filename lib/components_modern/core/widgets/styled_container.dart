// ignore_for_file: unused_import

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_animations.dart';
import '../theme/modern_style_options.dart';

/// A versatile styled container that integrates all premium visual effects.
///
/// [StyledContainer] provides a unified API for applying:
/// - Neumorphism effects
/// - Glow effects
/// - Glassmorphism (backdrop blur)
/// - Pulse borders
/// - Gradient backgrounds
/// - Animated state transitions
///
/// It can be configured via [ModernStyleOptions] or individual properties.
///
/// Example usage:
/// ```dart
/// StyledContainer(
///   styleOptions: ModernStyleOptions.premium(),
///   child: Text('Premium Card'),
/// )
/// ```
class StyledContainer extends StatefulWidget {
  /// The child widget to display inside the container.
  final Widget child;

  /// Style configuration. Takes precedence over individual properties.
  final ModernStyleOptions? styleOptions;

  /// Custom decoration for the container.
  final BoxDecoration? decoration;

  /// Padding inside the container.
  final EdgeInsetsGeometry? padding;

  /// Margin outside the container.
  final EdgeInsetsGeometry? margin;

  /// Fixed width.
  final double? width;

  /// Fixed height.
  final double? height;

  /// Box constraints.
  final BoxConstraints? constraints;

  /// Border radius.
  final BorderRadius? borderRadius;

  /// Enable glow effect.
  final bool enableGlow;

  /// Glow intensity (0.0 to 1.0).
  final double glowIntensity;

  /// Custom glow color.
  final Color? glowColor;

  /// Enable neumorphism.
  final bool enableNeumorphism;

  /// Neumorphic depth level (1, 2, or 3).
  final int neumorphicDepth;

  /// Enable glassmorphism (backdrop blur).
  final bool enableGlassmorphism;

  /// Blur amount for glassmorphism.
  final double blurAmount;

  /// Enable pulsing border.
  final bool enablePulseBorder;

  /// Pulse border color.
  final Color? pulseBorderColor;

  /// Background color.
  final Color? backgroundColor;

  /// Background gradient.
  final Gradient? gradient;

  /// Custom shadows.
  final List<BoxShadow>? shadows;

  /// Animation duration for state transitions.
  final Duration animationDuration;

  /// Animation curve for state transitions.
  final Curve animationCurve;

  /// Whether animations are enabled.
  final bool animationsEnabled;

  /// Callback when container is tapped.
  final VoidCallback? onTap;

  /// Callback when container is long pressed.
  final VoidCallback? onLongPress;

  /// Whether the container is in pressed state.
  final bool isPressed;

  /// Whether the container is in hover state (for desktop).
  final bool isHovered;

  /// Whether to use dark mode styling.
  final bool isDarkMode;

  /// Scale factor when pressed.
  final double pressedScale;

  /// Scale factor when hovered.
  final double hoveredScale;

  /// Alignment of the child.
  final AlignmentGeometry? alignment;

  /// Clip behavior.
  final Clip clipBehavior;

  const StyledContainer({
    super.key,
    required this.child,
    this.styleOptions,
    this.decoration,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.borderRadius,
    this.enableGlow = false,
    this.glowIntensity = 0.3,
    this.glowColor,
    this.enableNeumorphism = false,
    this.neumorphicDepth = 1,
    this.enableGlassmorphism = false,
    this.blurAmount = 10.0,
    this.enablePulseBorder = false,
    this.pulseBorderColor,
    this.backgroundColor,
    this.gradient,
    this.shadows,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOutCubic,
    this.animationsEnabled = true,
    this.onTap,
    this.onLongPress,
    this.isPressed = false,
    this.isHovered = false,
    this.isDarkMode = true,
    this.pressedScale = 0.97,
    this.hoveredScale = 1.02,
    this.alignment,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  State<StyledContainer> createState() => _StyledContainerState();
}

class _StyledContainerState extends State<StyledContainer>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isInternalPressed = false;
  bool _isInternalHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _glowController = AnimationController(
      vsync: this,
      duration: MediasfuAnimations.slow,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: widget.animationCurve),
    );
    _glowAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _updateScale() {
    final targetScale = _isInternalPressed || widget.isPressed
        ? widget.pressedScale
        : (_isInternalHovered || widget.isHovered ? widget.hoveredScale : 1.0);

    _scaleAnimation = Tween<double>(
      begin: _scaleAnimation.value,
      end: targetScale,
    ).animate(
      CurvedAnimation(parent: _scaleController, curve: widget.animationCurve),
    );
    _scaleController.forward(from: 0);
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      setState(() => _isInternalPressed = true);
      _updateScale();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      setState(() => _isInternalPressed = false);
      _updateScale();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null || widget.onLongPress != null) {
      setState(() => _isInternalPressed = false);
      _updateScale();
    }
  }

  void _handleHoverEnter(PointerEvent event) {
    setState(() => _isInternalHovered = true);
    _updateScale();
  }

  void _handleHoverExit(PointerEvent event) {
    setState(() => _isInternalHovered = false);
    _updateScale();
  }

  ModernStyleOptions get _effectiveStyle {
    return widget.styleOptions ?? ModernStyleOptions.none;
  }

  bool get _showGlow {
    return widget.enableGlow || _effectiveStyle.glowEnabled;
  }

  bool get _showNeumorphism {
    return widget.enableNeumorphism || _effectiveStyle.neumorphicEnabled;
  }

  bool get _showGlassmorphism {
    return widget.enableGlassmorphism || _effectiveStyle.backdropBlurEnabled;
  }

  bool get _showPulseBorder {
    return widget.enablePulseBorder || _effectiveStyle.pulseBorderEnabled;
  }

  BorderRadius get _effectiveBorderRadius {
    return widget.borderRadius ??
        _effectiveStyle.borderRadius ??
        BorderRadius.circular(16);
  }

  Color get _effectiveGlowColor {
    return widget.glowColor ??
        _effectiveStyle.glowColor ??
        MediasfuColors.primary;
  }

  double get _effectiveGlowIntensity {
    return _effectiveStyle.glowIntensity > 0
        ? _effectiveStyle.glowIntensity
        : widget.glowIntensity;
  }

  int get _effectiveNeumorphicDepth {
    return _effectiveStyle.neumorphicDepth > 0
        ? _effectiveStyle.neumorphicDepth
        : widget.neumorphicDepth;
  }

  double get _effectiveBlurAmount {
    return _effectiveStyle.blurAmount ?? widget.blurAmount;
  }

  Color get _effectivePulseBorderColor {
    return widget.pulseBorderColor ??
        _effectiveStyle.pulseBorderColor ??
        MediasfuColors.primary;
  }

  Color? get _effectiveBackgroundColor {
    return widget.backgroundColor ?? _effectiveStyle.backgroundColor;
  }

  Gradient? get _effectiveGradient {
    return widget.gradient ?? _effectiveStyle.backgroundGradient;
  }

  List<BoxShadow>? get _effectiveShadows {
    return widget.shadows ?? _effectiveStyle.shadows;
  }

  BoxDecoration _buildDecoration() {
    if (widget.decoration != null) return widget.decoration!;
    if (_effectiveStyle.containerDecoration != null) {
      return _effectiveStyle.containerDecoration!;
    }

    // Build neumorphic shadows if enabled
    List<BoxShadow>? shadows = _effectiveShadows;
    if (_showNeumorphism && shadows == null) {
      shadows = _buildNeumorphicShadows();
    }

    // Add glow shadows if enabled
    if (_showGlow && shadows != null) {
      shadows = [
        ...shadows,
        ..._buildGlowShadows(),
      ];
    } else if (_showGlow) {
      shadows = _buildGlowShadows();
    }

    return BoxDecoration(
      color: _effectiveBackgroundColor ??
          (widget.isDarkMode
              ? MediasfuColors.surfaceDark
              : MediasfuColors.surface),
      gradient: _effectiveGradient,
      borderRadius: _effectiveBorderRadius,
      boxShadow: shadows,
      border: _showPulseBorder
          ? null
          : _effectiveStyle.border ??
              Border.all(
                color: (widget.isDarkMode ? Colors.white : Colors.black)
                    .withValues(alpha: 0.08),
                width: 1,
              ),
    );
  }

  List<BoxShadow> _buildNeumorphicShadows() {
    final depth = _effectiveNeumorphicDepth.clamp(1, 3);
    final isDark = widget.isDarkMode;

    // Neumorphic effect: light shadow (top-left) and dark shadow (bottom-right)
    final baseOffset = 3.0 + (depth * 2);
    final baseBlur = 6.0 + (depth * 4);

    if (isDark) {
      return [
        BoxShadow(
          color: const Color(0xFF404060).withValues(alpha: 0.3 + (depth * 0.1)),
          offset: Offset(-baseOffset, -baseOffset),
          blurRadius: baseBlur,
        ),
        BoxShadow(
          color: const Color(0xFF0A0A12).withValues(alpha: 0.5 + (depth * 0.1)),
          offset: Offset(baseOffset, baseOffset),
          blurRadius: baseBlur,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.8),
          offset: Offset(-baseOffset, -baseOffset),
          blurRadius: baseBlur,
        ),
        BoxShadow(
          color: const Color(0xFFD1D9E6).withValues(alpha: 0.5 + (depth * 0.1)),
          offset: Offset(baseOffset, baseOffset),
          blurRadius: baseBlur,
        ),
      ];
    }
  }

  List<BoxShadow> _buildGlowShadows() {
    final intensity = _effectiveGlowIntensity * _glowAnimation.value;
    return MediasfuColors.glowShadow(_effectiveGlowColor, intensity: intensity);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;

    // Apply foreground builder if provided
    if (_effectiveStyle.foregroundBuilder != null) {
      content = Stack(
        children: [
          content,
          Positioned.fill(
            child: _effectiveStyle.foregroundBuilder!(context),
          ),
        ],
      );
    }

    // Wrap with decoration
    Widget container = AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        Widget decorated = Container(
          width: widget.width ?? _effectiveStyle.width,
          height: widget.height ?? _effectiveStyle.height,
          padding: widget.padding ?? _effectiveStyle.padding,
          margin: widget.margin ?? _effectiveStyle.margin,
          alignment: widget.alignment ?? _effectiveStyle.alignment,
          constraints:
              widget.constraints ?? _effectiveStyle.effectiveConstraints,
          decoration: _buildDecoration(),
          child: content,
        );

        // Apply glassmorphism
        if (_showGlassmorphism) {
          decorated = ClipRRect(
            borderRadius: _effectiveBorderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _effectiveBlurAmount,
                sigmaY: _effectiveBlurAmount,
              ),
              child: decorated,
            ),
          );
        }

        // Apply transform
        if (widget.animationsEnabled) {
          decorated = Transform.scale(
            scale: _scaleAnimation.value,
            child: decorated,
          );
        }

        return decorated;
      },
    );

    // Apply background builder if provided
    if (_effectiveStyle.backgroundBuilder != null) {
      container = Stack(
        children: [
          Positioned.fill(
            child: _effectiveStyle.backgroundBuilder!(context),
          ),
          container,
        ],
      );
    }

    // Apply overlay builder if provided
    if (_effectiveStyle.overlayBuilder != null) {
      container = _effectiveStyle.overlayBuilder!(context, container);
    }

    // Wrap with pulse border if enabled
    if (_showPulseBorder) {
      container = _PulseBorderWrapper(
        borderRadius: _effectiveBorderRadius,
        color: _effectivePulseBorderColor,
        child: container,
      );
    }

    // Add clip behavior
    container = ClipRRect(
      borderRadius: _effectiveBorderRadius,
      clipBehavior: widget.clipBehavior,
      child: container,
    );

    // Add interactivity
    if (widget.onTap != null || widget.onLongPress != null) {
      container = MouseRegion(
        onEnter: _handleHoverEnter,
        onExit: _handleHoverExit,
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: container,
        ),
      );
    }

    return container;
  }
}

/// Internal widget for pulse border animation.
class _PulseBorderWrapper extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final Color color;

  const _PulseBorderWrapper({
    required this.child,
    required this.borderRadius,
    required this.color,
  });

  @override
  State<_PulseBorderWrapper> createState() => _PulseBorderWrapperState();
}

class _PulseBorderWrapperState extends State<_PulseBorderWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: widget.color.withValues(alpha: _animation.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.3),
                blurRadius: 8 * _animation.value,
                spreadRadius: 1 * _animation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
