import 'package:flutter/material.dart';

/// OtherGridComponentOptions - Configuration options for the `OtherGridComponent`.
class OtherGridComponentOptions {
  final Color backgroundColor;
  final List<Widget> children;
  final double width;
  final double height;
  final bool showAspect;
  final Color timeBackgroundColor;
  final bool showTimer;
  final String meetingProgressTime;

  const OtherGridComponentOptions({
    required this.backgroundColor,
    required this.children,
    required this.width,
    required this.height,
    this.showAspect = true,
    required this.timeBackgroundColor,
    required this.showTimer,
    required this.meetingProgressTime,
  });
}

typedef OtherGridComponentType = Widget Function(
    {required OtherGridComponentOptions options});

/// OtherGridComponent - A widget for displaying a grid with customizable background color, children, and optional timer.
///
/// This widget displays a grid-like container with optional timer functionality. It allows flexibility for various layouts
/// by accepting child widgets and controlling visibility through `showAspect`.
///
/// ### Parameters:
/// - `options` (`OtherGridComponentOptions`): Configuration options for the grid component.
///
/// ### Example Usage:
/// ```dart
/// OtherGridComponent(
///   options: OtherGridComponentOptions(
///     backgroundColor: Colors.black,
///     width: 100.0,
///     height: 100.0,
///     showAspect: true,
///     timeBackgroundColor: Colors.white,
///     showTimer: true,
///     meetingProgressTime: "10:00",
///     children: [ChildWidget()],
///   ),
/// );
/// ```
class OtherGridComponent extends StatelessWidget {
  final OtherGridComponentOptions options;

  const OtherGridComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: options.showAspect,
      child: Container(
        width: options.width,
        height: options.height,
        color: options.backgroundColor,
        child: Stack(
          children: [
            ...options.children,
          ],
        ),
      ),
    );
  }
}
