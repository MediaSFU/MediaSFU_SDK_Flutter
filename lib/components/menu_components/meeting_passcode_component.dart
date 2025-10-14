import 'package:flutter/material.dart';

/// Configuration options for the `MeetingPasscodeComponent` widget.
///
/// Defines the meeting passcode value and styling for a read-only display field,
/// typically shown only to hosts/admins in MenuModal for security credentials.
///
/// **Properties:**
/// - `meetingPasscode`: The passcode string to display (required, typically 4-6 digits)
/// - `labelStyle`: Custom TextStyle for "Event Passcode (Host):" label (defaults to bold, dark gray)
/// - `inputTextStyle`: Custom TextStyle for passcode text in field (defaults to black)
/// - `inputBackgroundColor`: Background color for text field (defaults to Color(0xFFF0F0F0) - light gray)
///
/// **Common Configurations:**
/// ```dart
/// // 1. Default styling
/// MeetingPasscodeComponentOptions(
///   meetingPasscode: "1234",
/// )
///
/// // 2. Custom colors for emphasis
/// MeetingPasscodeComponentOptions(
///   meetingPasscode: "ABCD",
///   labelStyle: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold),
///   inputTextStyle: TextStyle(color: Colors.red[900], fontSize: 18, letterSpacing: 2),
///   inputBackgroundColor: Colors.red[50],
/// )
/// ```
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

/// A stateless widget displaying a read-only meeting passcode in a styled text field.
///
/// Renders a labeled, non-editable text field showing the host passcode for the meeting.
/// Typically displayed only to hosts/admins (islevel == '2') in MenuModal for security.
///
/// **Rendering Structure:**
/// ```
/// Container (margin: 10px top, maxWidth: 300px)
///   └─ Column (crossAxisAlignment: start)
///      ├─ Text("Event Passcode (Host):", bold, dark gray)
///      ├─ SizedBox(height: 5)
///      └─ TextFormField
///         ├─ initialValue: meetingPasscode
///         ├─ readOnly: true
///         ├─ border: OutlineInputBorder(rounded 5px, gray)
///         ├─ fillColor: light gray
///         └─ padding: 12px vertical, 10px horizontal
/// ```
///
/// **Common Use Cases:**
/// 1. **Display in Host Menu:**
///    ```dart
///    // Only shown if user is host (islevel == '2')
///    if (parameters.islevel == '2') ...[
///      MeetingPasscodeComponent(
///        options: MeetingPasscodeComponentOptions(
///          meetingPasscode: parameters.meetingPasscode,
///        ),
///      ),
///    ]
///    ```
///
/// 2. **Custom Styled for Emphasis:**
///    ```dart
///    MeetingPasscodeComponent(
///      options: MeetingPasscodeComponentOptions(
///        meetingPasscode: "5678",
///        labelStyle: TextStyle(
///          color: Colors.orange[800],
///          fontWeight: FontWeight.w600,
///          fontSize: 14,
///        ),
///        inputTextStyle: TextStyle(
///          color: Colors.orange[900],
///          fontSize: 20,
///          fontWeight: FontWeight.bold,
///          letterSpacing: 3,
///        ),
///        inputBackgroundColor: Colors.orange[50],
///      ),
///    )
///    ```
///
/// 3. **In Host Credentials Dialog:**
///    ```dart
///    Column(
///      children: [
///        Text("Host Credentials:", style: TextStyle(fontSize: 18)),
///        SizedBox(height: 16),
///        MeetingIdComponent(
///          options: MeetingIdComponentOptions(
///            meetingID: currentMeetingId,
///          ),
///        ),
///        MeetingPasscodeComponent(
///          options: MeetingPasscodeComponentOptions(
///            meetingPasscode: hostPasscode,
///          ),
///        ),
///        SizedBox(height: 16),
///        Text(
///          "Keep this passcode confidential",
///          style: TextStyle(color: Colors.red, fontSize: 12),
///        ),
///      ],
///    )
///    ```
///
/// **Styling Defaults:**
/// - Label: "Event Passcode (Host):", bold, Color.fromARGB(255, 51, 51, 51)
/// - Input text: Black, default font size
/// - Background: Color(0xFFF0F0F0) - light gray
/// - Border: Rounded 5px, gray outline
/// - Padding: 12px vertical, 10px horizontal
/// - Max width: 300px (container constraint)
///
/// **Security Considerations:**
/// - Should only be rendered for authenticated hosts (check islevel == '2')
/// - Read-only field prevents accidental editing but allows text selection
/// - Users can still copy passcode text for sharing
/// - Consider masking passcode with obscureText option if needed (not implemented by default)
///
/// **Field Behavior:**
/// - Read-only (readOnly: true) - user cannot edit
/// - Uses TextFormField for consistent Material Design styling
/// - No copy-to-clipboard button (users can select/copy text manually)
/// - No validation (display-only field)
/// - Plain text display (not obscured like password fields)
///
/// **Typical Usage Context:**
/// - MenuModal host section (islevel == '2' only)
/// - Host credentials screen
/// - Meeting setup confirmation
/// - Pre-meeting host instructions
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
