import 'package:flutter/material.dart';
import '../../types/types.dart' show ComponentSizes;

/// Configuration payload for [MainScreenComponent].
///
/// Drives MediaSFU's adaptive spotlight/gallery split with advanced options for
/// stacking vs. equal-size tiles:
///
/// * `mainSize` (0–100): percentage of space allocated to the primary (spotlight)
///   region when `doStack` is true. Ignored when `doStack` is false.
/// * `doStack`: when true the first child receives `mainSize` and remaining
///   children split the rest. When false all children share space equally.
/// * `containerWidthFraction` / `containerHeightFraction`: scale factors applied
///   to the parent's layout space, allowing the component to occupy less than
///   the full viewport.
/// * `updateComponentSizes`: callback delivering computed [ComponentSizes] so
///   downstream widgets can react to dimension changes (e.g., repositioning
///   control overlays or adjusting padding).
/// * `showControls`: reserves vertical space for a control bar. The component
///   applies `defaultFraction` (default 0.94) to the height, leaving room for
///   buttons.
/// * Builder hooks (`containerBuilder`, `childrenBuilder`, `childBuilder`) let
///   you wrap or re-theme the default widget tree without re-implementing the
///   responsive math.
///
/// Override this component via `MediasfuUICustomOverrides.mainScreen` when you
/// need a custom spotlight layout or branded child arrangements.
class MainScreenComponentOptions {
  final double mainSize;
  final bool doStack;
  final double containerWidthFraction;
  final double containerHeightFraction;
  final Function(ComponentSizes) updateComponentSizes;
  final double defaultFraction;
  final bool showControls;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;
  final MainScreenContainerBuilder? containerBuilder;
  final MainScreenChildrenBuilder? childrenBuilder;
  final MainScreenChildBuilder? childBuilder;

  MainScreenComponentOptions({
    required this.mainSize,
    required this.doStack,
    this.containerWidthFraction = 1,
    this.containerHeightFraction = 1,
    required this.updateComponentSizes,
    this.defaultFraction = 0.94,
    this.showControls = false,
    required this.children,
    this.padding,
    this.margin,
    this.decoration,
    this.alignment,
    this.clipBehavior = Clip.none,
    this.containerBuilder,
    this.childrenBuilder,
    this.childBuilder,
  });
}

typedef MainScreenComponentType = Widget Function(
    {required MainScreenComponentOptions options});

class MainScreenContainerContext {
  final BuildContext buildContext;
  final MainScreenComponentOptions options;
  final Size dimensions;
  final bool isWideScreen;

  const MainScreenContainerContext({
    required this.buildContext,
    required this.options,
    required this.dimensions,
    required this.isWideScreen,
  });
}

class MainScreenChildrenContext {
  final BuildContext buildContext;
  final MainScreenComponentOptions options;
  final Size dimensions;
  final bool isWideScreen;

  const MainScreenChildrenContext({
    required this.buildContext,
    required this.options,
    required this.dimensions,
    required this.isWideScreen,
  });
}

class MainScreenChildContext {
  final BuildContext buildContext;
  final MainScreenComponentOptions options;
  final int index;
  final bool isWideScreen;
  final bool doStack;
  final double mainSize;
  final Size computedSize;
  final ComponentSizes componentSizes;

  const MainScreenChildContext({
    required this.buildContext,
    required this.options,
    required this.index,
    required this.isWideScreen,
    required this.doStack,
    required this.mainSize,
    required this.computedSize,
    required this.componentSizes,
  });
}

typedef MainScreenContainerBuilder = Widget Function(
  MainScreenContainerContext context,
  Widget defaultContainer,
);

typedef MainScreenChildrenBuilder = Widget Function(
  MainScreenChildrenContext context,
  Widget defaultChildren,
);

typedef MainScreenChildBuilder = Widget Function(
  MainScreenChildContext context,
  Widget defaultChild,
);

/// Adaptive layout widget powering MediaSFU's spotlight/gallery split.
///
/// * Computes child dimensions responsively based on `mainSize`, `doStack`, and
///   screen orientation. Wide screens (aspect ratio ≥ 1) apply fractional
///   sizing; narrow screens stack children vertically.
/// * Invokes `updateComponentSizes` whenever layout metrics change, delivering
///   [ComponentSizes] so external controllers can adjust pagination, overlays,
///   or helper positioning.
/// * Provides three builder hooks: `containerBuilder` (wrap the entire
///   component), `childrenBuilder` (wrap the row/column that holds children),
///   and `childBuilder` (wrap each individual child).
/// * Respects `showControls` by reserving `(1 - defaultFraction)` of the height
///   for an action bar.
///
/// Use this widget in `MediasfuUICustomOverrides.mainScreen` to deliver
/// custom spotlight arrangements, branded theming, or alternative child layouts.
///
/// ### Example:
/// ```dart
/// MainScreenComponent(
///   options: MainScreenComponentOptions(
///     mainSize: 70,
///     doStack: true,
///     containerWidthFraction: 0.5,
///     containerHeightFraction: 0.5,
///     updateComponentSizes: (sizes) => print('Updated sizes: $sizes'),
///     defaultFraction: 0.9,
///     showControls: true,
///     children: [
///     ChildComponent1(),
///     ChildComponent2(),
///    ],
///   ),
/// );
/// ```
///
/// ### Notes:
/// - The component adjusts layout direction (horizontal or vertical) based on screen width.
/// - The `updateComponentSizes` callback provides updated component dimensions for responsive adjustments.

class MainScreenComponent extends StatelessWidget {
  final MainScreenComponentOptions options;

  const MainScreenComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safeAreaInsets = mediaQuery.padding + mediaQuery.systemGestureInsets;

    final parentWidth = mediaQuery.size.width * options.containerWidthFraction;

    // Always subtract safe area insets since we're wrapped in SafeArea
    // The safe area (status bar, notch) is removed from the layout, so we need
    // to calculate based on actual available height
    final availableHeight =
        mediaQuery.size.height - safeAreaInsets.top - safeAreaInsets.bottom;
    final parentHeight = options.showControls
        ? availableHeight *
            options.containerHeightFraction *
            options.defaultFraction
        : availableHeight * options.containerHeightFraction;

    bool isWideScreen = parentWidth > 768;

    if (!isWideScreen && parentWidth > 1.5 * parentHeight) {
      isWideScreen = true;
    }

    ComponentSizes computeDimensions() {
      if (options.doStack) {
        return isWideScreen
            ? ComponentSizes(
                mainHeight: parentHeight,
                otherHeight: parentHeight,
                mainWidth: (options.mainSize / 100) * parentWidth,
                otherWidth: ((100 - options.mainSize) / 100) * parentWidth,
              )
            : ComponentSizes(
                mainHeight: (options.mainSize / 100) * parentHeight,
                otherHeight: ((100 - options.mainSize) / 100) * parentHeight,
                mainWidth: parentWidth,
                otherWidth: parentWidth,
              );
      }

      return ComponentSizes(
        mainHeight: parentHeight,
        otherHeight: parentHeight,
        mainWidth: parentWidth,
        otherWidth: parentWidth,
      );
    }

    final componentSizes = computeDimensions();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      options.updateComponentSizes(componentSizes);
    });

    final dimensions = Size(parentWidth, parentHeight);

    final children = List<Widget>.generate(options.children.length, (index) {
      final child = options.children[index];

      final Size computedSize;
      if (options.doStack) {
        if (index == 0) {
          computedSize = Size(
            componentSizes.mainWidth,
            componentSizes.mainHeight,
          );
        } else {
          computedSize = Size(
            componentSizes.otherWidth,
            componentSizes.otherHeight,
          );
        }
      } else {
        computedSize = Size(
          componentSizes.mainWidth,
          componentSizes.mainHeight,
        );
      }

      final defaultChild = Stack(
        children: [
          SizedBox(
            width: computedSize.width,
            height: computedSize.height,
            child: child,
          ),
        ],
      );

      return options.childBuilder?.call(
            MainScreenChildContext(
              buildContext: context,
              options: options,
              index: index,
              isWideScreen: isWideScreen,
              doStack: options.doStack,
              mainSize: options.mainSize,
              computedSize: computedSize,
              componentSizes: componentSizes,
            ),
            defaultChild,
          ) ??
          defaultChild;
    });

    final defaultChildrenWidget = Flex(
      direction: isWideScreen ? Axis.horizontal : Axis.vertical,
      children: children,
    );

    final childrenWidget = options.childrenBuilder?.call(
          MainScreenChildrenContext(
            buildContext: context,
            options: options,
            dimensions: dimensions,
            isWideScreen: isWideScreen,
          ),
          defaultChildrenWidget,
        ) ??
        defaultChildrenWidget;

    final defaultContainer = Container(
      width: dimensions.width,
      height: dimensions.height,
      padding: options.padding,
      margin: options.margin,
      alignment: options.alignment,
      decoration: options.decoration,
      clipBehavior: options.clipBehavior,
      child: childrenWidget,
    );

    final container = options.containerBuilder?.call(
          MainScreenContainerContext(
            buildContext: context,
            options: options,
            dimensions: dimensions,
            isWideScreen: isWideScreen,
          ),
          defaultContainer,
        ) ??
        defaultContainer;

    return container;
  }
}
