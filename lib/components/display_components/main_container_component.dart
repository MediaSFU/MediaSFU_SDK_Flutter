import 'package:flutter/material.dart';

/// `MainContainerComponentOptions` - Configuration options for `MainContainerComponent`.
///
/// ### Properties:
/// - `backgroundColor` (`Color`): Background color of the container.
/// - `children` (`List<Widget>`): List of child widgets to be displayed inside the container.
/// - `containerWidthFraction` (`double`): Fraction of the screen width that the container should occupy (default is 1.0).
/// - `containerHeightFraction` (`double`): Fraction of the screen height that the container should occupy (default is 1.0).
/// - `marginLeft` (`double`): Left margin of the container (default is 0.0).
/// - `marginRight` (`double`): Right margin of the container (default is 0.0).
/// - `marginTop` (`double`): Top margin of the container (default is 0.0).
/// - `marginBottom` (`double`): Bottom margin of the container (default is 0.0).
///
/// ### Example Usage:
/// ```dart
/// MainContainerComponentOptions(
///   backgroundColor: Colors.blue,
///   children: [
///     Text("Child 1"),
///     Text("Child 2"),
///   ],
///   containerWidthFraction: 0.8,
///   containerHeightFraction: 0.6,
///   marginLeft: 10,
///   marginRight: 10,
///   marginTop: 20,
///   marginBottom: 20,
/// );
/// ```
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
  });
}

typedef MainContainerComponentType = Widget Function(
    {required MainContainerComponentOptions options});

/// `MainContainerComponent` - A container widget with customizable dimensions, margins, and background color.
///
/// This component adapts its width and height based on the specified fractions of the screen size.
/// It also allows for custom margins and provides a background color for the container.
///
/// ### Parameters:
/// - `options` (`MainContainerComponentOptions`): Configuration options to customize the container.
///
/// ### Example Usage:
/// ```dart
/// MainContainerComponent(
///   options: MainContainerComponentOptions(
///     backgroundColor: Colors.blue,
///     children: [
///       Text("Sample Text"),
///     ],
///     containerWidthFraction: 0.9,
///     containerHeightFraction: 0.5,
///     marginLeft: 15,
///     marginRight: 15,
///     marginTop: 10,
///     marginBottom: 10,
///   ),
/// );
/// ```
///
/// ### Notes:
/// - `MainContainerComponent` uses the `Stack` widget to allow layered child widgets.
/// - The component adjusts to screen size changes by recalculating width and height based on the fractions provided.
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
      margin: EdgeInsets.fromLTRB(
        options.marginLeft,
        options.marginTop,
        options.marginRight,
        options.marginBottom,
      ),
      color: options.backgroundColor,
      child: Stack(
        children: options.children,
      ),
    );
  }
}
