// ignore_for_file: unused_import

import 'package:flutter/material.dart';

/// Style configuration for modern MediaSFU components.
///
/// This class provides a unified way to customize the appearance of
/// modern UI components. It supports custom decorations, colors, shadows,
/// animations, and builder hooks for maximum flexibility.
///
/// Example usage:
/// ```dart
/// ModernStyleOptions(
///   containerDecoration: BoxDecoration(
///     gradient: MediasfuColors.metallicGradient(),
///     borderRadius: BorderRadius.circular(16),
///   ),
///   glowEnabled: true,
///   glowIntensity: 0.5,
///   animationDuration: MediasfuAnimations.fast,
/// )
/// ```
class ModernStyleOptions {
  /// Custom decoration for the container.
  /// If provided, this overrides the default decoration.
  final BoxDecoration? containerDecoration;

  /// Custom decoration for hover/focus states.
  final BoxDecoration? hoverDecoration;

  /// Custom decoration for pressed/active states.
  final BoxDecoration? activeDecoration;

  /// Custom padding for the container.
  final EdgeInsetsGeometry? padding;

  /// Custom margin for the container.
  final EdgeInsetsGeometry? margin;

  /// Enable glow effect around the container.
  final bool glowEnabled;

  /// Intensity of the glow effect (0.0 to 1.0).
  final double glowIntensity;

  /// Custom color for the glow effect.
  final Color? glowColor;

  /// Enable neumorphic (soft 3D) effect.
  final bool neumorphicEnabled;

  /// Depth of neumorphic effect (1, 2, or 3).
  final int neumorphicDepth;

  /// Enable pulse border animation.
  final bool pulseBorderEnabled;

  /// Color of the pulse border.
  final Color? pulseBorderColor;

  /// Enable skeleton loading state.
  final bool showSkeleton;

  /// Custom border radius.
  final BorderRadius? borderRadius;

  /// Custom border.
  final Border? border;

  /// Custom background color.
  final Color? backgroundColor;

  /// Custom gradient background.
  final Gradient? backgroundGradient;

  /// Custom box shadows.
  final List<BoxShadow>? shadows;

  /// Animation duration for state transitions.
  final Duration? animationDuration;

  /// Animation curve for state transitions.
  final Curve? animationCurve;

  /// Enable/disable animations.
  final bool animationsEnabled;

  /// Opacity for disabled state.
  final double disabledOpacity;

  /// Custom transform for container.
  final Matrix4? transform;

  /// Custom clip behavior.
  final Clip clipBehavior;

  /// Builder for overlaying custom content.
  final Widget Function(BuildContext context, Widget child)? overlayBuilder;

  /// Builder for custom foreground effects.
  final Widget Function(BuildContext context)? foregroundBuilder;

  /// Builder for custom background effects.
  final Widget Function(BuildContext context)? backgroundBuilder;

  /// Custom constraints for the container.
  final BoxConstraints? constraints;

  /// Minimum height for the container.
  final double? minHeight;

  /// Minimum width for the container.
  final double? minWidth;

  /// Maximum height for the container.
  final double? maxHeight;

  /// Maximum width for the container.
  final double? maxWidth;

  /// Fixed height for the container.
  final double? height;

  /// Fixed width for the container.
  final double? width;

  /// Alignment of child within the container.
  final AlignmentGeometry? alignment;

  /// Whether to use adaptive styling based on platform.
  final bool adaptiveStyling;

  /// Theme brightness override (light/dark).
  final Brightness? brightnessOverride;

  /// Custom color filter to apply.
  final ColorFilter? colorFilter;

  /// Blur effect for glassmorphism.
  final double? blurAmount;

  /// Enable backdrop filter blur.
  final bool backdropBlurEnabled;

  /// Custom blend mode for decorations.
  final BlendMode? blendMode;

  const ModernStyleOptions({
    this.containerDecoration,
    this.hoverDecoration,
    this.activeDecoration,
    this.padding,
    this.margin,
    this.glowEnabled = false,
    this.glowIntensity = 0.3,
    this.glowColor,
    this.neumorphicEnabled = false,
    this.neumorphicDepth = 1,
    this.pulseBorderEnabled = false,
    this.pulseBorderColor,
    this.showSkeleton = false,
    this.borderRadius,
    this.border,
    this.backgroundColor,
    this.backgroundGradient,
    this.shadows,
    this.animationDuration,
    this.animationCurve,
    this.animationsEnabled = true,
    this.disabledOpacity = 0.5,
    this.transform,
    this.clipBehavior = Clip.none,
    this.overlayBuilder,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.constraints,
    this.minHeight,
    this.minWidth,
    this.maxHeight,
    this.maxWidth,
    this.height,
    this.width,
    this.alignment,
    this.adaptiveStyling = true,
    this.brightnessOverride,
    this.colorFilter,
    this.blurAmount,
    this.backdropBlurEnabled = false,
    this.blendMode,
  });

  /// Creates a copy with updated values.
  ModernStyleOptions copyWith({
    BoxDecoration? containerDecoration,
    BoxDecoration? hoverDecoration,
    BoxDecoration? activeDecoration,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    bool? glowEnabled,
    double? glowIntensity,
    Color? glowColor,
    bool? neumorphicEnabled,
    int? neumorphicDepth,
    bool? pulseBorderEnabled,
    Color? pulseBorderColor,
    bool? showSkeleton,
    BorderRadius? borderRadius,
    Border? border,
    Color? backgroundColor,
    Gradient? backgroundGradient,
    List<BoxShadow>? shadows,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? animationsEnabled,
    double? disabledOpacity,
    Matrix4? transform,
    Clip? clipBehavior,
    Widget Function(BuildContext context, Widget child)? overlayBuilder,
    Widget Function(BuildContext context)? foregroundBuilder,
    Widget Function(BuildContext context)? backgroundBuilder,
    BoxConstraints? constraints,
    double? minHeight,
    double? minWidth,
    double? maxHeight,
    double? maxWidth,
    double? height,
    double? width,
    AlignmentGeometry? alignment,
    bool? adaptiveStyling,
    Brightness? brightnessOverride,
    ColorFilter? colorFilter,
    double? blurAmount,
    bool? backdropBlurEnabled,
    BlendMode? blendMode,
  }) {
    return ModernStyleOptions(
      containerDecoration: containerDecoration ?? this.containerDecoration,
      hoverDecoration: hoverDecoration ?? this.hoverDecoration,
      activeDecoration: activeDecoration ?? this.activeDecoration,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      glowEnabled: glowEnabled ?? this.glowEnabled,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      glowColor: glowColor ?? this.glowColor,
      neumorphicEnabled: neumorphicEnabled ?? this.neumorphicEnabled,
      neumorphicDepth: neumorphicDepth ?? this.neumorphicDepth,
      pulseBorderEnabled: pulseBorderEnabled ?? this.pulseBorderEnabled,
      pulseBorderColor: pulseBorderColor ?? this.pulseBorderColor,
      showSkeleton: showSkeleton ?? this.showSkeleton,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      shadows: shadows ?? this.shadows,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
      transform: transform ?? this.transform,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      overlayBuilder: overlayBuilder ?? this.overlayBuilder,
      foregroundBuilder: foregroundBuilder ?? this.foregroundBuilder,
      backgroundBuilder: backgroundBuilder ?? this.backgroundBuilder,
      constraints: constraints ?? this.constraints,
      minHeight: minHeight ?? this.minHeight,
      minWidth: minWidth ?? this.minWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      maxWidth: maxWidth ?? this.maxWidth,
      height: height ?? this.height,
      width: width ?? this.width,
      alignment: alignment ?? this.alignment,
      adaptiveStyling: adaptiveStyling ?? this.adaptiveStyling,
      brightnessOverride: brightnessOverride ?? this.brightnessOverride,
      colorFilter: colorFilter ?? this.colorFilter,
      blurAmount: blurAmount ?? this.blurAmount,
      backdropBlurEnabled: backdropBlurEnabled ?? this.backdropBlurEnabled,
      blendMode: blendMode ?? this.blendMode,
    );
  }

  /// Merges this with another [ModernStyleOptions].
  /// Values from [other] take precedence when not null.
  ModernStyleOptions merge(ModernStyleOptions? other) {
    if (other == null) return this;
    return copyWith(
      containerDecoration: other.containerDecoration,
      hoverDecoration: other.hoverDecoration,
      activeDecoration: other.activeDecoration,
      padding: other.padding,
      margin: other.margin,
      glowEnabled: other.glowEnabled,
      glowIntensity: other.glowIntensity,
      glowColor: other.glowColor,
      neumorphicEnabled: other.neumorphicEnabled,
      neumorphicDepth: other.neumorphicDepth,
      pulseBorderEnabled: other.pulseBorderEnabled,
      pulseBorderColor: other.pulseBorderColor,
      showSkeleton: other.showSkeleton,
      borderRadius: other.borderRadius,
      border: other.border,
      backgroundColor: other.backgroundColor,
      backgroundGradient: other.backgroundGradient,
      shadows: other.shadows,
      animationDuration: other.animationDuration,
      animationCurve: other.animationCurve,
      animationsEnabled: other.animationsEnabled,
      disabledOpacity: other.disabledOpacity,
      transform: other.transform,
      clipBehavior: other.clipBehavior,
      overlayBuilder: other.overlayBuilder,
      foregroundBuilder: other.foregroundBuilder,
      backgroundBuilder: other.backgroundBuilder,
      constraints: other.constraints,
      minHeight: other.minHeight,
      minWidth: other.minWidth,
      maxHeight: other.maxHeight,
      maxWidth: other.maxWidth,
      height: other.height,
      width: other.width,
      alignment: other.alignment,
      adaptiveStyling: other.adaptiveStyling,
      brightnessOverride: other.brightnessOverride,
      colorFilter: other.colorFilter,
      blurAmount: other.blurAmount,
      backdropBlurEnabled: other.backdropBlurEnabled,
      blendMode: other.blendMode,
    );
  }

  /// Gets effective constraints based on min/max/fixed dimensions.
  BoxConstraints? get effectiveConstraints {
    if (constraints != null) return constraints;
    if (minHeight == null &&
        minWidth == null &&
        maxHeight == null &&
        maxWidth == null) {
      return null;
    }
    return BoxConstraints(
      minHeight: minHeight ?? 0,
      minWidth: minWidth ?? 0,
      maxHeight: maxHeight ?? double.infinity,
      maxWidth: maxWidth ?? double.infinity,
    );
  }

  /// Returns default empty style options.
  static const ModernStyleOptions none = ModernStyleOptions();

  /// Creates a glow-focused style preset.
  static ModernStyleOptions glow({
    Color? color,
    double intensity = 0.4,
    BorderRadius? borderRadius,
  }) {
    return ModernStyleOptions(
      glowEnabled: true,
      glowColor: color,
      glowIntensity: intensity,
      borderRadius: borderRadius,
    );
  }

  /// Creates a neumorphic style preset.
  static ModernStyleOptions neumorphic({
    int depth = 2,
    BorderRadius? borderRadius,
  }) {
    return ModernStyleOptions(
      neumorphicEnabled: true,
      neumorphicDepth: depth,
      borderRadius: borderRadius,
    );
  }

  /// Creates a glassmorphic style preset.
  static ModernStyleOptions glass({
    double blur = 10,
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) {
    return ModernStyleOptions(
      backdropBlurEnabled: true,
      blurAmount: blur,
      backgroundColor:
          backgroundColor ?? const Color(0x40FFFFFF), // Semi-transparent
      borderRadius: borderRadius,
    );
  }

  /// Creates a pulsing border style preset.
  static ModernStyleOptions pulsing({
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return ModernStyleOptions(
      pulseBorderEnabled: true,
      pulseBorderColor: color,
      borderRadius: borderRadius,
    );
  }

  /// Creates a gradient background style preset.
  static ModernStyleOptions gradient({
    required Gradient gradient,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
  }) {
    return ModernStyleOptions(
      backgroundGradient: gradient,
      borderRadius: borderRadius,
      shadows: shadows,
    );
  }

  /// Creates a minimal/subtle style preset.
  static ModernStyleOptions minimal({
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) {
    return ModernStyleOptions(
      backgroundColor: backgroundColor,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      animationsEnabled: true,
    );
  }

  /// Creates a premium/elevated style preset.
  static ModernStyleOptions premium({
    Color? backgroundColor,
    Color? glowColor,
    BorderRadius? borderRadius,
  }) {
    return ModernStyleOptions(
      backgroundColor: backgroundColor,
      glowEnabled: true,
      glowColor: glowColor,
      glowIntensity: 0.25,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      shadows: [
        BoxShadow(
          color: const Color(0x0A000000),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: const Color(0x0A000000),
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

/// Provides style options to descendant widgets.
class ModernStyleProvider extends InheritedWidget {
  /// The style options to provide to descendants.
  final ModernStyleOptions styleOptions;

  const ModernStyleProvider({
    super.key,
    required this.styleOptions,
    required super.child,
  });

  /// Gets the [ModernStyleOptions] from the nearest ancestor.
  static ModernStyleOptions? of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ModernStyleProvider>();
    return provider?.styleOptions;
  }

  /// Gets the [ModernStyleOptions] or returns [ModernStyleOptions.none].
  static ModernStyleOptions maybeOf(BuildContext context) {
    return of(context) ?? ModernStyleOptions.none;
  }

  @override
  bool updateShouldNotify(ModernStyleProvider oldWidget) {
    // Using identity check since ModernStyleOptions is immutable
    return styleOptions != oldWidget.styleOptions;
  }
}

/// Extension methods for easier style option access.
extension ModernStyleContextExtension on BuildContext {
  /// Gets the current [ModernStyleOptions] from the widget tree.
  ModernStyleOptions get modernStyle => ModernStyleProvider.maybeOf(this);
}
