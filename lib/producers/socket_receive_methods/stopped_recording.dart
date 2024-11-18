import 'package:flutter/foundation.dart';
import '../../types/types.dart' show ShowAlert;

/// Options for showing the recording stopped alert message.
class StoppedRecordingOptions {
  final String state;
  final String reason;
  final ShowAlert? showAlert;

  StoppedRecordingOptions({
    required this.state,
    required this.reason,
    this.showAlert,
  });
}

/// Function type for `stoppedRecording` to define consistency in function signature.
typedef StoppedRecordingType = Future<void> Function(
    StoppedRecordingOptions options);

/// Displays an alert message when the recording has stopped, indicating the reason.
///
/// @param [StoppedRecordingOptions] options - Options for showing the recording stopped alert.
/// - `state`: Should be "stop" to trigger the alert.
/// - `reason`: Reason why the recording stopped.
/// - `showAlert`: Optional function to display the alert message.
///
/// @returns [Future<void>] Resolves once the alert is shown, if applicable.
///
/// Example usage:
/// ```dart
/// final options = StoppedRecordingOptions(
///   state: "stop",
///   reason: "The session ended",
///   showAlert: (message, type, duration) => print("Alert: $message"),
/// );
/// stoppedRecording(options);
/// // Output: "The recording has stopped - The session ended."
/// ```
Future<void> stoppedRecording(StoppedRecordingOptions options) async {
  try {
    // Ensure the state is 'stop' before showing the alert
    if (options.state == 'stop') {
      options.showAlert?.call(
        message: 'The recording has stopped - ${options.reason}.',
        type: 'danger',
        duration: 3000,
      );
    }
  } catch (error) {
    if (kDebugMode) {
      print("Error in stoppedRecording: $error");
    }
  }
}
