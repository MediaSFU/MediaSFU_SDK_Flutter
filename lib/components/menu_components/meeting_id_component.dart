import 'package:flutter/material.dart';

/// MeetingIdComponentOptions - Defines options for the MeetingIdComponent widget.
class MeetingIdComponentOptions {
  final String meetingID;
  final TextStyle? labelStyle;
  final TextStyle? inputTextStyle;
  final Color? inputBackgroundColor;

  MeetingIdComponentOptions({
    required this.meetingID,
    this.labelStyle,
    this.inputTextStyle,
    this.inputBackgroundColor,
  });
}

typedef MeetingIdComponentType = Widget Function({
  required MeetingIdComponentOptions options,
});

/// MeetingIdComponent - A widget for displaying a meeting ID with a text input field.
///
/// This component displays a read-only input field showing the meeting ID, with customizable styling options.
///
/// ### Parameters:
/// - `options` (required): An instance of `MeetingIdComponentOptions` that configures the component.
///
/// ### Example Usage:
/// ```dart
/// MeetingIdComponent(
///   options: MeetingIdComponentOptions(
///     meetingID: "1234567890",
///     labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
///     inputTextStyle: TextStyle(color: Colors.black),
///     inputBackgroundColor: Colors.grey[300],
///   ),
/// );
/// ```
class MeetingIdComponent extends StatelessWidget {
  final MeetingIdComponentOptions options;

  const MeetingIdComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event ID:',
            style: options.labelStyle ??
                const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 58, 58, 58),
                ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            initialValue: options.meetingID,
            readOnly: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              filled: true,
              fillColor:
                  options.inputBackgroundColor ?? const Color(0xFFF0F0F0),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            ),
            style:
                options.inputTextStyle ?? const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
