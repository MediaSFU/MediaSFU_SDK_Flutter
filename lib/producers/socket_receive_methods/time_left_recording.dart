import 'package:flutter/foundation.dart';

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

/// Displays an alert message indicating the time left for recording.
///
/// This function takes in the [timeLeft] parameter, which represents the remaining time in seconds for recording.
/// It also takes an optional [showAlert] callback function that can be used to display the alert message.
/// The [showAlert] function should have the following signature:
/// ```
/// void showAlert({
///   required String message,
///   required String type,
///   required int duration,
/// });
/// ```
/// The alert message will be displayed with the following details:
/// - Message: "The recording will stop in less than [timeLeft] seconds."
/// - Duration: 3000 milliseconds (3 seconds)
/// - Type: 'danger'
///
/// If an error occurs during the execution of this function, it will be caught and handled accordingly.
void timeLeftRecording({
  required int timeLeft,
  required ShowAlert? showAlert,
}) {
  try {
    // Display alert message
    if (showAlert != null) {
      showAlert(
        message: 'The recording will stop in less than $timeLeft seconds.',
        duration: 3000,
        type: 'danger',
      );
    }
  } catch (error) {
    if (kDebugMode) {
      // print("Error in timeLeftRecording: $error");
    }
    // Handle error accordingly
  }
}
