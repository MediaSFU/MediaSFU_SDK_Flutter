import '../../types/types.dart' show ShowAlert;

/// Options for controlling the recording timer, allowing pause and resume actions.
class RecordPauseTimerOptions {
  final bool stop;
  final bool isTimerRunning;
  final bool canPauseResume;
  final ShowAlert? showAlert;

  RecordPauseTimerOptions({
    this.stop = false,
    required this.isTimerRunning,
    required this.canPauseResume,
    this.showAlert,
  });
}

/// Type alias for the recordPauseTimer function.
typedef RecordPauseTimerType = bool Function(RecordPauseTimerOptions options);

/// Controls the recording timer by allowing pause and resume actions.
///
/// Returns true if the timer can be paused or resumed based on `isTimerRunning`
/// and `canPauseResume` flags in [options]. Shows an alert if conditions are not met.
///
/// If [stop] is true, the alert shows a message about stopping only after 15 seconds;
/// otherwise, it shows a pause/resume restriction message.
///
/// Example usage:
/// ```dart
/// final canPause = recordPauseTimer(RecordPauseTimerOptions(
///   stop: false,
///   isTimerRunning: true,
///   canPauseResume: true,
///   showAlert: (alert) => print(alert.message),
/// ));
/// print("Can pause: $canPause"); // Logs true or shows alert if conditions not met.
/// ```
bool recordPauseTimer(RecordPauseTimerOptions options) {
  final showAlert = options.showAlert;

  // Ensure the timer is running and pause/resume actions are allowed
  if (options.isTimerRunning && options.canPauseResume) {
    return true;
  }

  // Determine appropriate message based on `stop` flag
  final message = options.stop
      ? 'Can only stop after 15 seconds of starting or pausing or resuming recording'
      : 'Can only pause or resume after 15 seconds of starting or pausing or resuming recording';

  // Show alert if conditions not met
  showAlert?.call(
    message: message,
    type: 'danger',
    duration: 3000,
  );
  return false;
}
