import 'dart:async';
import '../../types/types.dart' show ShowAlert;

/// Defines options for checking the pause state.
class CheckPauseStateOptions {
  final String recordingMediaOptions; // "video" or "audio"
  final int recordingVideoPausesLimit;
  final int recordingAudioPausesLimit;
  final int pauseRecordCount;
  final ShowAlert? showAlert;

  CheckPauseStateOptions({
    required this.recordingMediaOptions,
    required this.recordingVideoPausesLimit,
    required this.recordingAudioPausesLimit,
    required this.pauseRecordCount,
    this.showAlert,
  });
}

typedef CheckPauseStateType = Future<bool> Function(
    CheckPauseStateOptions options);

/// Checks if the recording can be paused based on the current pause count and the allowed limits.
///
/// The `checkPauseState` function evaluates whether a recording (either audio or video)
/// can be paused based on the current pause count and the configured maximum pause limit for
/// the selected media type. If the pause limit is reached, an alert is shown using the `showAlert`
/// function, if provided.
///
/// ## Parameters:
/// - `options`: An instance of `CheckPauseStateOptions` containing:
///   - `recordingMediaOptions`: The media type, either "video" or "audio".
///   - `recordingVideoPausesLimit`: Maximum number of pauses allowed for video recordings.
///   - `recordingAudioPausesLimit`: Maximum number of pauses allowed for audio recordings.
///   - `pauseRecordCount`: The current number of pauses taken.
///   - `showAlert`: An optional callback for displaying an alert if the pause limit is reached.
///
/// ## Returns:
/// - `Future<bool>`: Returns `true` if the recording can be paused, or `false` if the limit has been reached.
///
/// ## Example Usage:
///
/// ```dart
/// // Define a showAlert function to display an alert message
/// void showAlert({required String message, required String type, required int duration}) {
///   print('$type Alert: $message (Duration: $duration ms)');
/// }
///
/// // Define options for checking pause state
/// final checkPauseStateOptions = CheckPauseStateOptions(
///   recordingMediaOptions: 'video',
///   recordingVideoPausesLimit: 3,
///   recordingAudioPausesLimit: 5,
///   pauseRecordCount: 2,
///   showAlert: showAlert,
/// );
///
/// // Check if the recording can be paused
/// bool canPause = await checkPauseState(checkPauseStateOptions);
/// print(canPause ? 'Recording can be paused' : 'Pause limit reached');
/// // Output:
/// // Recording can be paused
/// ```

Future<bool> checkPauseState(CheckPauseStateOptions options) async {
  // Determine the reference limit for pauses based on the media type
  final refLimit = options.recordingMediaOptions == 'video'
      ? options.recordingVideoPausesLimit
      : options.recordingAudioPausesLimit;

  // Check if the user can still pause the recording
  if (options.pauseRecordCount < refLimit) {
    return true;
  }

  // Show alert if the pause limit is reached
  options.showAlert?.call(
    message:
        'You have reached the limit of pauses - you can choose to stop recording.',
    type: 'danger',
    duration: 3000,
  );

  return false;
}
