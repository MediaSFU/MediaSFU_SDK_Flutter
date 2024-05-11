import 'package:flutter/material.dart';

/// OtherGridComponent - A widget for displaying a grid component with customizable background color and children.
///
/// This widget allows you to display a grid component with customizable background color and child widgets.
/// It provides options to control the visibility of the grid component and to show a timer with meeting progress time.

/// The background color of the grid component.
///final Color backgroundColor;

/// The list of child widgets to display within the grid component.
///final List<Widget> children;

/// The width of the grid component.
///final double width;

/// The height of the grid component.
///final double height;

/// A flag indicating whether to show the aspect of the grid component.
///
/// If set to true, the grid component will be visible. If set to false, the grid component will be hidden.
///final bool showAspect;

/// The background color for the time display.
/// final Color timeBackgroundColor;

/// A flag indicating whether to show the timer.
///
/// If set to true, the timer will be displayed. If set to false, the timer will be hidden.
///final bool showTimer;

/// The meeting progress time to display on the timer.
///final String meetingProgressTime;

class OtherGridComponent extends StatelessWidget {
  final Color backgroundColor;
  final List<Widget> children;
  final double width;
  final double height;
  final bool showAspect;
  final Color timeBackgroundColor;
  final bool showTimer;
  final String meetingProgressTime;

  const OtherGridComponent({
    super.key,
    required this.backgroundColor,
    required this.children,
    required this.width,
    required this.height,
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
        width: width,
        height: height,
        color: backgroundColor,
        child: Stack(
          children: [
            ...children,
          ],
        ),
      ),
    );
  }
}
