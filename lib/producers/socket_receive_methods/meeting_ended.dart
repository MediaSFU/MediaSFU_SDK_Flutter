import 'dart:async';
import '../../types/types.dart' show ShowAlert, EventType;

/// Defines options for handling the end of a meeting.
class MeetingEndedOptions {
  final ShowAlert? showAlert;
  final String? redirectURL;
  final bool onWeb;
  final EventType eventType;
  final void Function(bool)? updateValidated;

  MeetingEndedOptions({
    this.showAlert,
    this.redirectURL,
    required this.onWeb,
    required this.eventType,
    this.updateValidated,
  });
}

typedef MeetingEndedType = Future<void> Function(MeetingEndedOptions options);

/// Handles the end of a meeting by showing an alert and performing a redirect if necessary.
///
/// This function takes an instance of [MeetingEndedOptions] which includes options for showing an
/// alert message, redirecting to a URL, and updating the validation state.
///
/// If the event type is not 'chat', it displays an alert notifying that the event has ended.
/// If [onWeb] is true and [redirectURL] is provided, it redirects the user to the specified URL after a 2-second delay.
/// Otherwise, it calls [updateValidated] to update the validation state.
///
/// Example usage:
/// ```dart
/// final options = MeetingEndedOptions(
///   showAlert: (message, type, duration) => print("Alert: $message"),
///   redirectURL: "https://homepage.com",
///   onWeb: true,
///   eventType: "meeting",
///   updateValidated: (isValid) => print("Validation status: $isValid"),
/// );
///
/// await meetingEnded(options: options);
/// ```
Future<void> meetingEnded({required MeetingEndedOptions options}) async {
  // Show an alert if the event type is not 'chat'
  if (options.eventType != EventType.chat) {
    options.showAlert!(
      message: 'The meeting has ended. Redirecting to the home page...',
      type: 'danger',
      duration: 2000,
    );
  }

  // Handle redirection or validation update
  if (options.onWeb &&
      options.redirectURL != null &&
      options.redirectURL!.isNotEmpty) {
    await Future.delayed(const Duration(seconds: 2));
    // Here you could implement the actual redirection logic
    // For example: window.location.href = options.redirectURL
  } else if (options.updateValidated != null) {
    await Future.delayed(const Duration(seconds: 2));
    options.updateValidated!(false);
  }
}
