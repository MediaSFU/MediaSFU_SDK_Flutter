import 'package:flutter/material.dart';

/// Configuration options for the `MeetingIdComponent` widget.
///
/// Defines the meeting ID value and styling for a read-only display field,
/// typically used in MenuModal to show the current event/meeting identifier.
///
/// **Properties:**
/// - `meetingID`: The meeting/event ID string to display (required)
/// - `labelStyle`: Custom TextStyle for "Event ID:" label (defaults to bold, dark gray)
/// - `inputTextStyle`: Custom TextStyle for meeting ID text in field (defaults to black)
/// - `inputBackgroundColor`: Background color for text field (defaults to Color(0xFFF0F0F0) - light gray)
///
/// **Common Configurations:**
/// ```dart
/// // 1. Default styling
/// MeetingIdComponentOptions(
///   meetingID: "1234567890",
/// )
///
/// // 2. Custom colors
/// MeetingIdComponentOptions(
///   meetingID: "ABC-DEF-GHI",
///   labelStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
///   inputTextStyle: TextStyle(color: Colors.blue[900], fontSize: 16),
///   inputBackgroundColor: Colors.blue[50],
/// )
/// ```
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

/// A stateless widget displaying a read-only meeting/event ID in a styled text field.
///
/// Renders a labeled, non-editable text field showing the current meeting ID.
/// Used in MenuModal to display the event identifier for reference or sharing.
///
/// **Rendering Structure:**
/// ```
/// Container (margin: 10px top, maxWidth: 300px)
///   └─ Column (crossAxisAlignment: start)
///      ├─ Text("Event ID:", bold, dark gray)
///      ├─ SizedBox(height: 5)
///      └─ TextFormField
///         ├─ value: meetingID
///         ├─ readOnly: true
///         ├─ border: OutlineInputBorder(rounded 5px, gray)
///         ├─ fillColor: light gray
///         └─ padding: 12px vertical, 10px horizontal
/// ```
///
/// **Common Use Cases:**
/// 1. **Display in Menu Modal:**
///    ```dart
///    MeetingIdComponent(
///      options: MeetingIdComponentOptions(
///        meetingID: parameters.meetingID,
///      ),
///    )
///    ```
///
/// 2. **Custom Styled Display:**
///    ```dart
///    MeetingIdComponent(
///      options: MeetingIdComponentOptions(
///        meetingID: "MTG-2024-001",
///        labelStyle: TextStyle(
///          color: Colors.blue[800],
///          fontWeight: FontWeight.w600,
///          fontSize: 14,
///        ),
///        inputTextStyle: TextStyle(
///          color: Colors.blue[900],
///          fontSize: 16,
///          letterSpacing: 1.2,
///        ),
///        inputBackgroundColor: Colors.blue[50],
///      ),
///    )
///    ```
///
/// 3. **In Share Dialog:**
///    ```dart
///    Column(
///      children: [
///        Text("Share this meeting:", style: TextStyle(fontSize: 18)),
///        SizedBox(height: 16),
///        MeetingIdComponent(
///          options: MeetingIdComponentOptions(
///            meetingID: currentMeetingId,
///          ),
///        ),
///        SizedBox(height: 16),
///        ShareButtonsComponent(...),
///      ],
///    )
///    ```
///
/// **Styling Defaults:**
/// - Label: "Event ID:", bold, Color.fromARGB(255, 58, 58, 58)
/// - Input text: Black, default font size
/// - Background: Color(0xFFF0F0F0) - light gray
/// - Border: Rounded 5px, gray outline
/// - Padding: 12px vertical, 10px horizontal
/// - Max width: 300px (container constraint)
///
/// **Field Behavior:**
/// - Read-only (readOnly: true) - user cannot edit
/// - Uses TextFormField for consistent Material Design styling
/// - No copy-to-clipboard button (users can still select/copy text)
/// - No validation (display-only field)
///
/// **Typical Usage Context:**
/// - MenuModal metadata section
/// - ShareEventModal meeting information
/// - Meeting details dialog
/// - Pre-meeting lobby screen
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
