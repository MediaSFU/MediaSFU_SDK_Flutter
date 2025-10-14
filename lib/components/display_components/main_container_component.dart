import 'package:flutter/material.dart';

/// Configuration payload for [MainContainerComponent].
///
/// Powers the root container that wraps all MediaSFU UI surfaces. Typically
/// overridden via `MediasfuUICustomOverrides.mainContainer` to apply branded
/// theming, shadows, borders, or gradient backgrounds without rebuilding the
/// entire experience:
///
/// * `containerWidthFraction` / `containerHeightFraction`: scale the container
///   relative to the screen dimensions. Defaults to 1.0 (full viewport).
/// * Legacy margin fields (`marginLeft`, `marginRight`, `marginTop`,
///   `marginBottom`) combine into a single [EdgeInsets] unless `margin` is
///   explicitly set—in which case `margin` overrides the legacy values.
/// * `decoration`: replaces the default `BoxDecoration(color: backgroundColor)`
///   so you can inject gradients, images, or multi-layer effects.
/// * `children`: rendered inside a [Stack], enabling layered overlays, floating
///   action buttons, or positioned widgets.
///
/// Use this options object when you want to inject theming providers, apply
/// rounded corners, or add debug overlays to the entire MediaSFU surface.
class MainContainerComponentOptions {
  /// The background color of the container.
  final Color backgroundColor;

  /// The list of child widgets to be displayed inside the container.
  final List<Widget> children;

  /// The fraction of the screen width that the container should occupy.
  final double containerWidthFraction;

  /// The fraction of the screen height that the container should occupy.
  final double containerHeightFraction;

  /// The left margin of the container.
  final double marginLeft;

  /// The right margin of the container.
  final double marginRight;

  /// The top margin of the container.
  final double marginTop;

  /// The bottom margin of the container.
  final double marginBottom;

  /// Optional custom margin that overrides the individual margin values when provided.
  final EdgeInsetsGeometry? margin;

  /// Optional padding applied within the container.
  final EdgeInsetsGeometry? padding;

  /// Optional decoration for advanced styling (gradients, borders, etc.).
  final Decoration? decoration;

  /// Alignment for the child stack within the container.
  final AlignmentGeometry? alignment;

  /// Clip behaviour applied to the container.
  final Clip? clipBehavior;

  /// Constructs a MainContainerComponentOptions object.
  const MainContainerComponentOptions({
    required this.backgroundColor,
    required this.children,
    this.containerWidthFraction = 1.0,
    this.containerHeightFraction = 1.0,
    this.marginLeft = 0.0,
    this.marginRight = 0.0,
    this.marginTop = 0.0,
    this.marginBottom = 0.0,
    this.margin,
    this.padding,
    this.decoration,
    this.alignment,
    this.clipBehavior,
  });
}

typedef MainContainerComponentType = Widget Function(
    {required MainContainerComponentOptions options});

/// Root container widget wrapping the entire MediaSFU UI surface.
///
/// * Scales dimensions by `containerWidthFraction` / `containerHeightFraction`
///   relative to the screen, allowing the experience to occupy a subset of the
///   viewport (e.g., for picture-in-picture or split-screen UIs).
/// * Applies margin via legacy fields or the unified `margin` property, and
///   optional `padding`, `decoration`, `alignment`, and `clipBehavior` for
///   advanced theming.
/// * Renders `children` inside a [Stack] so you can layer overlays, debug info,
///   or floating controls atop the experience.
///
/// Override this component via `MediasfuUICustomOverrides.mainContainer` to
/// inject gradients, rounded corners, shadows, or theming providers without
/// replacing the entire layout tree. Commonly used to apply branded backgrounds
/// or wrap the UI in additional context providers.
///
/// ### Notes:
/// - The component recalculates dimensions on every build, ensuring responsive
///   behavior during orientation changes or window resizes.
/// - When `decoration` is `null`, a simple `BoxDecoration(color: backgroundColor)`
///   is applied.
class MainContainerComponent extends StatelessWidget {
  final MainContainerComponentOptions options;

  const MainContainerComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double containerWidth = options.containerWidthFraction * screenWidth;
    final double containerHeight =
        options.containerHeightFraction * screenHeight;

    return Container(
      width: containerWidth,
      height: containerHeight,
      margin: options.margin ??
          EdgeInsets.fromLTRB(
            options.marginLeft,
            options.marginTop,
            options.marginRight,
            options.marginBottom,
          ),
      padding: options.padding,
      decoration: options.decoration,
      color: options.decoration == null ? options.backgroundColor : null,
      alignment: options.alignment,
      clipBehavior: options.clipBehavior ?? Clip.none,
      child: Stack(
        children: options.children,
      ),
    );
  }
}
