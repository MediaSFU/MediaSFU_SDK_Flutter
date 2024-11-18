typedef UpdateRecordElapsedTime = void Function(int elapsedTime);
typedef UpdateRecordingProgressTime = void Function(String formattedTime);

/// Options required for updating the record timer.
class RecordUpdateTimerOptions {
  int recordElapsedTime;
  int recordStartTime;
  final UpdateRecordElapsedTime updateRecordElapsedTime;
  final UpdateRecordingProgressTime updateRecordingProgressTime;

  RecordUpdateTimerOptions({
    required this.recordElapsedTime,
    required this.recordStartTime,
    required this.updateRecordElapsedTime,
    required this.updateRecordingProgressTime,
  });
}

typedef RecordUpdateTimerType = void Function(
    {required RecordUpdateTimerOptions options});

/// Updates the recording timer and formats the elapsed time in HH:MM:SS format.
///
/// The `recordUpdateTimer` function calculates the elapsed recording time from the
/// start time, updates it, and formats it in a human-readable format (hours, minutes, seconds).
/// It also invokes callback functions to handle the elapsed time and formatted time display.
///
/// ## Parameters:
/// - `options`: An instance of `RecordUpdateTimerOptions` containing:
///   - `recordStartTime`: The start time of the recording in milliseconds since epoch.
///   - `recordElapsedTime`: The elapsed time since the start of recording (updated in seconds).
///   - `updateRecordElapsedTime`: Callback to update the elapsed time in seconds.
///   - `updateRecordingProgressTime`: Callback to update the formatted elapsed time (HH:MM:SS).
///
/// ## Example Usage:
///
/// ```dart
/// // Define the callback for updating elapsed time
/// void updateElapsedTime(int elapsedTime) {
///   print('Elapsed Time: $elapsedTime seconds');
/// }
///
/// // Define the callback for updating formatted time
/// void updateFormattedTime(String formattedTime) {
///   print('Formatted Time: $formattedTime');
/// }
///
/// // Create options with a start time set to the current time
/// final options = RecordUpdateTimerOptions(
///   recordElapsedTime: 0,
///   recordStartTime: DateTime.now().millisecondsSinceEpoch,
///   updateRecordElapsedTime: updateElapsedTime,
///   updateRecordingProgressTime: updateFormattedTime,
/// );
///
/// // Call the function to update and display the recording time
/// recordUpdateTimer(options: options);
/// // Expected output:
/// // Elapsed Time: [seconds]
/// // Formatted Time: HH:MM:SS
/// ```
///
/// This example demonstrates how to initialize and update the recording timer using the current start time.

void recordUpdateTimer({required RecordUpdateTimerOptions options}) {
  // Utility function to pad single-digit numbers with leading zeros.
  String padNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  int currentTime =
      DateTime.now().millisecondsSinceEpoch; // Get the current timestamp
  options.recordElapsedTime = ((currentTime - options.recordStartTime) / 1000)
      .floor(); // Calculate elapsed time in seconds
  options.updateRecordElapsedTime(options.recordElapsedTime);

  // Format the time in HH:MM:SS format
  int hours = options.recordElapsedTime ~/ 3600;
  int minutes = (options.recordElapsedTime % 3600) ~/ 60;
  int seconds = options.recordElapsedTime % 60;
  String formattedTime =
      '${padNumber(hours)}:${padNumber(minutes)}:${padNumber(seconds)}';

  options.updateRecordingProgressTime(formattedTime);
}
