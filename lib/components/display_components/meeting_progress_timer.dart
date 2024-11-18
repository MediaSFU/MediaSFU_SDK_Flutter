import 'package:flutter/material.dart';

/// MeetingProgressTimerOptions - Configuration options for the `MeetingProgressTimer`.
///
/// /// `MeetingProgressTimerOptions` - Configuration options for the `MeetingProgressTimer` widget.
///
/// ### Properties:
/// - `meetingProgressTime` (`String`): The time to display as the meeting progress (required).
/// - `initialBackgroundColor` (`Color`): Background color for the timer (default is `Colors.green`).
/// - `position` (`String`): Position of the timer on the screen. Can be `'topLeft'`, `'topRight'`, `'bottomLeft'`, or `'bottomRight'`.
/// - `textStyle` (`TextStyle?`): Custom text style for the timer (optional).
/// - `showTimer` (`bool`): Controls the visibility of the timer (default is `true`).
///
/// ### Example Usage:
/// ```dart
/// MeetingProgressTimerOptions(
///   meetingProgressTime: "10:00",
///   initialBackgroundColor: Colors.green,
///   position: "topLeft",
///   textStyle: TextStyle(fontSize: 16, color: Colors.white),
///   showTimer: true,
/// );
/// ```

class MeetingProgressTimerOptions {
  final String meetingProgressTime;
  final Color initialBackgroundColor;
  final String position;
  final TextStyle? textStyle;
  final bool showTimer;

  MeetingProgressTimerOptions({
    required this.meetingProgressTime,
    this.initialBackgroundColor = Colors.green,
    this.position = 'topLeft',
    this.textStyle,
    this.showTimer = true,
  });
}

typedef MeetingProgressTimerType = Widget Function(
    {required MeetingProgressTimerOptions options});

/// `MeetingProgressTimer` - A widget that displays the meeting progress time with customizable style and position.
///
/// This widget can be positioned in any corner of the screen and is useful for displaying the ongoing
/// meeting time, with customizable options such as background color, text style, and visibility.
///
/// ### Parameters:
/// - `options` (`MeetingProgressTimerOptions`): Configuration options for the widget.
///
/// ### Example Usage:
/// ```dart
/// MeetingProgressTimer(
///   options: MeetingProgressTimerOptions(
///     meetingProgressTime: "10:00",
///     initialBackgroundColor: Colors.blue,
///     position: "bottomRight",
///     textStyle: TextStyle(fontSize: 16, color: Colors.white),
///     showTimer: true,
///   ),
/// );
/// ```
///
/// ### Notes:
/// - The timer visibility can be controlled with the `showTimer` property.
/// - Positioning is handled based on the `position` option.

class MeetingProgressTimer extends StatelessWidget {
  final MeetingProgressTimerOptions options;

  const MeetingProgressTimer({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    // Set positioning values based on the position option
    double? top, bottom, left, right;
    switch (options.position) {
      case 'topLeft':
        top = 0;
        left = 0;
        break;
      case 'topRight':
        top = 0;
        right = 0;
        break;
      case 'bottomLeft':
        bottom = 0;
        left = 0;
        break;
      case 'bottomRight':
        bottom = 0;
        right = 0;
        break;
      default:
        top = 0;
        left = 0;
    }

    return Visibility(
      visible: options.showTimer,
      child: Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: options.initialBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            options.meetingProgressTime,
            style: options.textStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  decoration: TextDecoration.none,
                ),
          ),
        ),
      ),
    );
  }
}
