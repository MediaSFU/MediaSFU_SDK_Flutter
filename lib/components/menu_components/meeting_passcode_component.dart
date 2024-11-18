import 'package:flutter/material.dart';

/// MeetingPasscodeComponentOptions - Defines options for the MeetingPasscodeComponent widget.
class MeetingPasscodeComponentOptions {
  final String meetingPasscode;
  final TextStyle? labelStyle;
  final TextStyle? inputTextStyle;
  final Color? inputBackgroundColor;

  MeetingPasscodeComponentOptions({
    required this.meetingPasscode,
    this.labelStyle,
    this.inputTextStyle,
    this.inputBackgroundColor,
  });
}

typedef MeetingPasscodeComponentType = Widget Function(
    MeetingPasscodeComponentOptions options);

/// MeetingPasscodeComponent - A widget for displaying a meeting passcode in a read-only text field.
///
/// This component displays a read-only input field showing the meeting passcode, with customizable styling options.
///
/// ### Parameters:
/// - `options` (required): An instance of `MeetingPasscodeComponentOptions` that configures the component.
///
/// ### Example Usage:
/// ```dart
/// MeetingPasscodeComponent(
///   options: MeetingPasscodeComponentOptions(
///     meetingPasscode: "1234",
///     labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
///     inputTextStyle: TextStyle(color: Colors.black),
///     inputBackgroundColor: Colors.grey[300],
///   ),
/// );
/// ```
class MeetingPasscodeComponent extends StatelessWidget {
  final MeetingPasscodeComponentOptions options;

  const MeetingPasscodeComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Passcode (Host):',
            style: options.labelStyle ??
                const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 51, 51, 51),
                ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            initialValue: options.meetingPasscode,
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
