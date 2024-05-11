import 'package:flutter/material.dart';

/// A widget to display meeting progress time with customizable style and position.
///
/// This widget allows you to display meeting progress time with customizable
/// background color, text style, and position on the screen. It provides options
/// to control the visibility of the timer.
///
/// /// The meeting progress time to display.
///final String meetingProgressTime;

/// The initial background color of the timer container.
///
/// Defaults to [Colors.green] if not provided.
/// final Color initialBackgroundColor;

/// The position of the timer on the screen.
///
/// The position can be specified as a combination of 'top'/'bottom' and
/// 'left'/'right'. For example, 'topLeft', 'bottomRight', etc.
/// Defaults to 'topLeft' if not provided.
// final String position;

/// The text style of the timer text.
///
/// If not provided, the default text color is white.
//final TextStyle? textStyle;

/// A flag indicating whether to show the timer.
///
/// If set to false, the timer will be hidden.
///final bool showTimer;

/// Creates a meeting progress timer with the specified parameters.
///
/// The [meetingProgressTime] parameter is required. The [initialBackgroundColor]
/// parameter defaults to [Colors.green], the [position] parameter defaults to
/// 'topLeft', and the [showTimer] parameter defaults to true if not provided.

class MeetingProgressTimer extends StatelessWidget {
  final String meetingProgressTime;
  final Color initialBackgroundColor;
  final String position;
  final TextStyle? textStyle;
  final bool showTimer;

  const MeetingProgressTimer({
    super.key,
    required this.meetingProgressTime,
    this.initialBackgroundColor = Colors.green,
    this.position = 'topLeft',
    this.textStyle,
    this.showTimer = true,
  });

  @override
  Widget build(BuildContext context) {
    // Convert the initialBackgroundColor to a Color object
    Color backgroundColor = initialBackgroundColor;

    return Visibility(
      visible: showTimer,
      child: Positioned(
        // Position based on provided position parameter
        top: position.contains('top') ? 0 : null,
        bottom: position.contains('bottom') ? 0 : null,
        left: position.contains('left') ? 0 : null,
        right: position.contains('Right') ? 0 : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: backgroundColor,
          ),
          child: Text(
            meetingProgressTime,
            style: (textStyle?.merge(const TextStyle(color: Colors.white)) ??
                    const TextStyle(color: Colors.white))
                .copyWith(
                    fontSize: 18,
                    decoration:
                        TextDecoration.none), // Remove text decoration here
          ),
        ),
      ),
    );
  }
}
