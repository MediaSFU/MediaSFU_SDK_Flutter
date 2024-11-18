import 'package:flutter/foundation.dart';
import '../../types/types.dart' show ShowAlert;

/// Options to manage the time left for recording.
class TimeLeftRecordingOptions {
  final int timeLeft;
  final ShowAlert? showAlert;

  TimeLeftRecordingOptions({
    required this.timeLeft,
    this.showAlert,
  });
}

typedef TimeLeftRecordingType = void Function(TimeLeftRecordingOptions options);

/// Displays an alert message indicating the remaining time left for recording.
///
/// @param [TimeLeftRecordingOptions] options - Options for managing time left for recording.
/// - `timeLeft`: Remaining time in seconds.
/// - `showAlert`: Optional callback to display an alert.
///
/// @example
/// ```dart
/// final options = TimeLeftRecordingOptions(
///   timeLeft: 30,
///   showAlert: (message, type, duration) => print("Alert: $message"),
/// );
/// timeLeftRecording(options);
/// // Output: "The recording will stop in less than 30 seconds."
/// ```
void timeLeftRecording(TimeLeftRecordingOptions options) {
  try {
    options.showAlert?.call(
      message:
          'The recording will stop in less than ${options.timeLeft} seconds.',
      duration: 3000,
      type: 'danger',
    );
  } catch (error) {
    if (kDebugMode) {
      print("Error in timeLeftRecording: $error");
    }
  }
}
