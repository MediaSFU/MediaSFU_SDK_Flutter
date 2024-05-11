import 'package:flutter/material.dart';

/// A grid component with customizable children, dimensions, and background color.
///
/// Parameters:
/// - children: The widgets to be displayed inside the grid.
/// - backgroundColor: The background color of the grid.
/// - mainSize: The size of the main grid component.
/// - height: The height of the grid.
/// - width: The width of the grid.
/// - showAspect: A boolean value indicating whether to show the aspect ratio.
/// - timeBackgroundColor: The background color of the timer.
/// - showTimer: A boolean value indicating whether to show the timer.
/// - meetingProgressTime: The time progress of the meeting.
///
/// Example:
/// ```dart
/// MainGridComponent(
///   backgroundColor: Colors.blue,
///   children: [
///     // Your widgets here
///   ],
///   mainSize: 200,
///   height: 300,
///   width: 500,
///   timeBackgroundColor: Colors.white,
///   showTimer: true,
///   meetingProgressTime: '10:00',
/// )
/// ```

class MainGridComponent extends StatelessWidget {
  final List<Widget> children;
  final Color backgroundColor;
  final double mainSize;
  final double height;
  final double width;
  final bool showAspect;
  final Color timeBackgroundColor;
  final bool showTimer;
  final String meetingProgressTime;

  const MainGridComponent({
    super.key,
    required this.children,
    required this.backgroundColor,
    required this.mainSize,
    required this.height,
    required this.width,
    this.showAspect = true,
    required this.timeBackgroundColor,
    required this.showTimer,
    required this.meetingProgressTime,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: showAspect,
      child: Container(
        height: height,
        width: width,
        color: backgroundColor,
        // child: Container(
        // scrollDirection: Axis.horizontal,
        child: Stack(
          children: [
            ...children,
          ],
        ),
        // ),
      ),
    );
  }
}
