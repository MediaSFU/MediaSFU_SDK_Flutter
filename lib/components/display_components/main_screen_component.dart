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

  MainScreenComponentOptions({
    required this.mainSize,
    required this.doStack,
    this.containerWidthFraction = 1,
    this.containerHeightFraction = 1,
    required this.updateComponentSizes,
    this.defaultFraction = 0.94,
    this.showControls = false,
    required this.children,
  });
}

typedef MainScreenComponentType = Widget Function(
    {required MainScreenComponentOptions options});

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

    final parentWidth = mediaQuery.size.width * options.containerWidthFraction;
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
      } else {
        return ComponentSizes(
          mainHeight: parentHeight,
          otherHeight: parentHeight,
          mainWidth: parentWidth,
          otherWidth: parentWidth,
        );
      }
    }

    final dimensions = computeDimensions();

    // Update component sizes when parent dimensions, main size, or stacking mode changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      options.updateComponentSizes(dimensions);
    });

    return SizedBox(
      width: parentWidth,
      height: parentHeight,
      child: Flex(
        direction: isWideScreen ? Axis.horizontal : Axis.vertical,
        children: options.children.map((child) {
          final index = options.children.indexOf(child);
          final childStyle = options.doStack
              ? {
                  'height': index == 0
                      ? dimensions.mainHeight
                      : dimensions.otherHeight,
                  'width':
                      index == 0 ? dimensions.mainWidth : dimensions.otherWidth,
                }
              : {
                  'height': dimensions.mainHeight,
                  'width': dimensions.mainWidth,
                };

          return Stack(
            children: [
              SizedBox(
                width: childStyle['width'],
                height: childStyle['height'],
                child: child,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
