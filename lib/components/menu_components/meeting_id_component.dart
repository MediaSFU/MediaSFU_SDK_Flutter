import 'package:flutter/material.dart';

/// MeetingIdComponent - A component for displaying a meeting ID with a text input field.
///
/// This component displays a meeting ID with a text input field that is read-only.
///
/// The meeting ID to be displayed.
/// final String meetingID;

class MeetingIdComponent extends StatelessWidget {
  final String meetingID;

  const MeetingIdComponent({super.key, this.meetingID = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event ID:',
            style: TextStyle(color: Color.fromARGB(255, 58, 58, 58)),
          ),
          const SizedBox(height: 5),
          TextFormField(
            initialValue: meetingID,
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
