import 'package:flutter/material.dart';

/// `MainGridComponentOptions` - Configuration options for the `MainGridComponent`.
///
/// ### Properties:
/// - `backgroundColor` (`Color`): Background color of the main grid container.
/// - `children` (`List<Widget>`): List of child widgets to be displayed inside the grid.
/// - `mainSize` (`double`): Main component size within the grid as a percentage (0-100).
/// - `height` (`double`): Height of the grid container.
/// - `width` (`double`): Width of the grid container.
/// - `showAspect` (`bool`): If `true`, displays the grid with aspect ratio; default is `true`.
/// - `timeBackgroundColor` (`Color`): Background color of the meeting progress timer.
/// - `showTimer` (`bool`): If `true`, displays the meeting progress timer; default is `true`.
/// - `meetingProgressTime` (`String`): Time to display on the meeting progress timer.
///
/// ### Example Usage:
/// ```dart
/// MainGridComponentOptions(
///   backgroundColor: Colors.blue,
///   children: [
///     // List of child widgets
///   ],
///   mainSize: 200,
///   height: 300,
///   width: 500,
///   showAspect: true,
///   timeBackgroundColor: Colors.white,
///   showTimer: true,
///   meetingProgressTime: '10:00',
/// );
/// ```

class MainGridComponentOptions {
  /// The background color of the main grid container.
  final Color backgroundColor;

  /// The list of child widgets to be displayed inside the main grid.
  final List<Widget> children;

  /// The main size percentage (0-100) of the primary component within the grid.
  final double mainSize;

  /// The height of the main grid container.
  final double height;

  /// The width of the main grid container.
  final double width;

  /// A flag indicating whether to show the aspect ratio of the grid.
  final bool showAspect;

  /// The background color of the meeting progress timer.
  final Color timeBackgroundColor;

  /// A flag indicating whether to show the meeting progress timer.
  final bool showTimer;

  /// The meeting progress time to display on the timer.
  final String meetingProgressTime;

  /// Constructs a MainGridComponentOptions object.
  const MainGridComponentOptions({
    required this.backgroundColor,
    required this.children,
    required this.mainSize,
    required this.height,
    required this.width,
    this.showAspect = true,
    this.timeBackgroundColor = Colors.transparent,
    this.showTimer = true,
    required this.meetingProgressTime,
  });
}

typedef MainGridComponentType = Widget Function(
    {required MainGridComponentOptions options});

/// `MainGridComponent` - A flexible grid component with customizable layout, child widgets, and background color.
///
/// This widget displays a grid container that can include custom child widgets and a configurable meeting progress timer.
/// It provides options for controlling visibility, styling, and grid layout based on the provided configuration.
///
/// ### Parameters:
/// - `options` (`MainGridComponentOptions`): Configuration options for customizing the grid component.
///
/// ### Example Usage:
/// ```dart
/// MainGridComponent(
///   options: MainGridComponentOptions(
///     backgroundColor: Colors.blue,
///     children: [
///       Text("Child 1"),
///       Text("Child 2"),
///     ],
///     mainSize: 200,
///     height: 300,
///     width: 500,
///     showAspect: true,
///     timeBackgroundColor: Colors.white,
///     showTimer: true,
///     meetingProgressTime: '10:00',
///   ),
/// );
/// ```
///
/// ### Notes:
/// - `MainGridComponent` uses the `Stack` widget to layer child widgets within the grid container.
/// - `showAspect` controls the grid visibility; if `false`, the component is hidden.
class MainGridComponent extends StatelessWidget {
  final MainGridComponentOptions options;

  /// Constructs a MainGridComponent widget.
  ///
  /// ### Parameters:
  /// - `options` (`MainGridComponentOptions`): Configuration options for the main grid component.
  ///
  /// ### Example Usage:
  /// ```dart
  /// MainGridComponent(
  ///   options: MainGridComponentOptions(
  ///     backgroundColor: Colors.blue,
  ///     children: [
  ///       // Your widgets here
  ///     ],
  ///     mainSize: 200,
  ///     height: 300,
  ///     width: 500,
  ///     timeBackgroundColor: Colors.white,
  ///     showTimer: true,
  ///     meetingProgressTime: '10:00',
  ///   ),
  /// );
  /// ```
  const MainGridComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: options.showAspect,
      child: Container(
        width: options.width,
        height: options.height,
        decoration: BoxDecoration(
          color: options.backgroundColor,
          border: Border.all(color: Colors.black, width: 4),
        ),
        child: Stack(
          children: [
            ...options.children,
          ],
        ),
      ),
    );
  }
}
