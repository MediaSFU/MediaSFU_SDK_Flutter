import 'package:flutter/material.dart';

/// MeetingPasscodeComponent - A component for displaying a meeting passcode with a text input field.
///
/// This component displays a meeting passcode with a text input field that is read-only.
///
/// The meeting passcode to be displayed.
/// final String meetingPasscode;

class MeetingPasscodeComponent extends StatelessWidget {
  final String meetingPasscode;

  const MeetingPasscodeComponent({super.key, this.meetingPasscode = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Passcode (Host):',
            style: TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
          ),
          const SizedBox(height: 5),
          TextFormField(
            initialValue: meetingPasscode,
            readOnly: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[300],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            ),
          ),
        ],
      ),
    );
  }
}
