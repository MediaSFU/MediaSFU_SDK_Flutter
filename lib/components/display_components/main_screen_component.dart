import 'package:flutter/material.dart';
import '../../types/types.dart' show ComponentSizes;

/// `MainScreenComponentOptions` - Configuration options for the `MainScreenComponent` widget.
///
/// ### Properties:
/// - `mainSize` (`double`): Determines the size of the main section in percentage (0-100).
/// - `doStack` (`bool`): If `true`, splits the main screen into stacked sections; otherwise, all children have equal sizes.
/// - `containerWidthFraction` (`double`): Fraction of the parent width to use for the component's width (default is `1.0`).
/// - `containerHeightFraction` (`double`): Fraction of the parent height to use for the component's height (default is `1.0`).
/// - `updateComponentSizes` (`Function(Map<String, double>)`): Callback to receive updated component sizes for dynamic layouts.
/// - `defaultFraction` (`double`): Default fraction for the height when `showControls` is `true` (default is `0.94`).
/// - `showControls` (`bool`): If `true`, applies additional spacing for screen controls; affects component height.
///
/// ### Example Usage:
/// ```dart
/// MainScreenComponentOptions(
///   mainSize: 70,
///   doStack: true,
///   containerWidthFraction: 0.5,
///   containerHeightFraction: 0.5,
///   updateComponentSizes: (sizes) => print('Updated sizes: $sizes'),
///   defaultFraction: 0.9,
///   showControls: true,
///   children: [
///    ChildComponent1(),
///    ChildComponent2(),
///   ],
/// );
/// ```
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

/// `MainScreenComponent` - A flexible layout widget for creating main screens with adjustable layout and size.
///
/// This widget allows defining a main screen layout that dynamically calculates the component dimensions based on screen size,
/// orientation, and customizable layout options. It provides a flexible container for child widgets, adapting to screen size changes.
///
/// ### Parameters:
/// - `options` (`MainScreenComponentOptions`): Options for configuring layout dimensions and behaviors.
/// - `children` (`List<Widget>`): List of child widgets to display within the component.
///
/// ### Example Usage:
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

    final parentWidth =
        mediaQuery.size.width * options.containerWidthFraction;
    final parentHeight = options.showControls
        ? mediaQuery.size.height *
            options.containerHeightFraction *
            options.defaultFraction
        : mediaQuery.size.height * options.containerHeightFraction -
            safeAreaInsets.top;

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
