import 'package:flutter/foundation.dart';

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

/// Displays an alert message indicating that the recording has stopped.
///
/// The [stoppedRecording] function takes in the following parameters:
/// - [state]: The state of the recording.
/// - [reason]: The reason for stopping the recording.
/// - [parameters]: Additional parameters, including the [showAlert] function.
///
/// The [showAlert] function is used to display the alert message. It takes in the following parameters:
/// - [message]: The message to be displayed in the alert.
/// - [type]: The type of the alert (e.g., 'danger', 'warning', 'success').
/// - [duration]: The duration for which the alert should be displayed (in milliseconds).
///
/// Example usage:
/// ```dart
/// stoppedRecording(
///   state: 'stopped',
///   reason: 'User stopped the recording',
///   parameters: {
///     'showAlert': showAlertFunction,
///   },
/// );
/// ```
void stoppedRecording({
  required String state,
  required String reason,
  required Map<String, dynamic> parameters,
}) async {
  try {
    // Extract showAlert from parameters
    final ShowAlert? showAlert = parameters['showAlert'];

    // Display alert message
    if (showAlert != null) {
      showAlert(
        message: 'Recording stopped: $reason',
        type: 'danger',
        duration: 2000,
      );
    }
  } catch (error) {
    if (kDebugMode) {
      // print("Error in stoppedRecording: $error");
    }
    // throw Exception("Failed to display the recording stopped alert message.");
  }
}
