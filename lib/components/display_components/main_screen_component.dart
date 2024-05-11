import 'package:flutter/material.dart';

/// A flexible component for building main screens with customizable layout.
///
/// This component allows you to define a main screen layout with flexible
/// dimensions and child widgets. It automatically computes the dimensions
/// of its children based on the available space and layout settings.
///
///  /// The size of the main component relative to the parent container.
///
/// This value represents the percentage of the parent container's width or height
/// that the main component should occupy. It is used to compute the dimensions
/// of the main component relative to the available space.
/// final double mainSize;

/// A flag indicating whether the child widgets should be stacked vertically
/// or horizontally within the main screen.
///
/// If set to true, the child widgets will be stacked vertically (one on top
/// of the other). If set to false, the child widgets will be laid out in a row
/// or column depending on the screen width.
///final bool doStack;

/// The fraction of the parent container's width that the main component
/// should occupy.
///
/// This value represents the percentage of the parent container's width that
/// the main component should occupy. It allows you to customize the width of
/// the main component relative to the available space.
///final double containerWidthFraction;

/// The fraction of the parent container's height that the main component
/// should occupy.
///
/// This value represents the percentage of the parent container's height that
/// the main component should occupy. It allows you to customize the height of
/// the main component relative to the available space.
/// final double containerHeightFraction;

/// A callback function to update the sizes of child components.
///
/// This function is called whenever the parent dimensions, main size, or
/// stacking mode changes. It allows you to dynamically adjust the sizes
/// of child components based on the available space and layout settings.
//final Function updateComponentSizes;

/// The default fraction of the parent container's height to be used when
/// [showControls] is true.
///
/// This value represents the percentage of the parent container's height
/// that the main component should occupy when controls are shown. It allows
/// you to customize the height of the main component when controls are displayed.
///final double defaultFraction;

/// A flag indicating whether to show controls on the main screen.
///
/// If set to true, additional controls will be displayed on the main screen,
/// affecting the layout of child components. If set to false, no controls will
/// be displayed, and the main component will occupy the entire parent container.
///final bool showControls;

/// Creates a main screen component with the specified parameters.
///
/// The [children], [mainSize], [doStack], [updateComponentSizes], and
/// [showControls] parameters are required. The [containerWidthFraction],
/// [containerHeightFraction], and [defaultFraction] parameters have default
/// values but can be customized as needed.

class MainScreenComponent extends StatelessWidget {
  final List<Widget> children;
  final double mainSize;
  final bool doStack;
  final double containerWidthFraction;
  final double containerHeightFraction;
  final Function updateComponentSizes;
  final double defaultFraction;
  final bool showControls;

  const MainScreenComponent({
    super.key,
    required this.children,
    required this.mainSize,
    required this.doStack,
    this.containerWidthFraction = 1,
    this.containerHeightFraction = 1,
    required this.updateComponentSizes,
    this.defaultFraction = 0.94,
    this.showControls = false,
  });

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final EdgeInsets safeAreaInsets = MediaQuery.of(context).padding +
        MediaQuery.of(context).systemGestureInsets;
    final double parentWidth = (mediaQuery.size.width) * containerWidthFraction;
    final double parentHeight = showControls
        ? ((mediaQuery.size.height - 0.0) *
            containerHeightFraction *
            defaultFraction)
        : ((mediaQuery.size.height - safeAreaInsets.top) *
            containerHeightFraction);
    final bool isWideScreen = parentWidth > 768;
    Map<String, double> computeDimensions() {
      if (doStack) {
        return isWideScreen
            ? {
                'mainHeight': (parentHeight).floorToDouble(),
                'otherHeight': (parentHeight).floorToDouble(),
                'mainWidth': ((mainSize / 100) * parentWidth).floorToDouble(),
                'otherWidth':
                    (((100 - mainSize) / 100) * parentWidth).floorToDouble(),
              }
            : {
                'mainHeight':
                    (((mainSize / 100) * parentHeight)).floorToDouble(),
                'otherHeight':
                    ((((100 - mainSize) / 100) * parentHeight)).floorToDouble(),
                'mainWidth': parentWidth.floorToDouble(),
                'otherWidth': parentWidth.floorToDouble(),
              };
      } else {
        return {
          'mainHeight': parentHeight.floorToDouble(),
          'otherHeight': parentHeight.floorToDouble(),
          'mainWidth': parentWidth.floorToDouble(),
          'otherWidth': parentWidth.floorToDouble(),
        };
      }
    }

    final dimensions = computeDimensions();

    // Update component sizes when parent dimensions, main size, or stacking mode change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dimensions = computeDimensions();
      updateComponentSizes(dimensions);
    });

    return SizedBox(
      width: parentWidth,
      height: parentHeight,
      child: Flex(
        direction: isWideScreen ? Axis.horizontal : Axis.vertical,
        children: children.map((child) {
          final index = children.indexOf(child);
          final childStyle = doStack
              ? {
                  'height': index == 0
                      ? dimensions['mainHeight']
                      : dimensions['otherHeight'],
                  'width': index == 0
                      ? dimensions['mainWidth']
                      : dimensions['otherWidth'],
                }
              : {
                  'height': dimensions['mainHeight'],
                  'width': dimensions['mainWidth'],
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
