import '../../types/types.dart' show ShowAlert;

typedef UpdateClearedToRecord = void Function(bool cleared);
typedef UpdateCanRecord = void Function(bool canRecord);
typedef UpdateIsRecordingModalVisible = void Function(bool visible);

/// Options for launching a recording.
class LaunchRecordingOptions {
  final UpdateIsRecordingModalVisible updateIsRecordingModalVisible;
  final bool isRecordingModalVisible;
  final ShowAlert? showAlert;
  final bool stopLaunchRecord;
  final bool canLaunchRecord;
  final bool recordingAudioSupport;
  final bool recordingVideoSupport;
  final UpdateCanRecord updateCanRecord;
  final UpdateClearedToRecord updateClearedToRecord;
  final bool recordStarted;
  final bool recordPaused;
  final bool localUIMode;

  LaunchRecordingOptions({
    required this.updateIsRecordingModalVisible,
    required this.isRecordingModalVisible,
    this.showAlert,
    required this.stopLaunchRecord,
    required this.canLaunchRecord,
    required this.recordingAudioSupport,
    required this.recordingVideoSupport,
    required this.updateCanRecord,
    required this.updateClearedToRecord,
    required this.recordStarted,
    required this.recordPaused,
    required this.localUIMode,
  });
}

/// Type alias for the launch recording function.
typedef LaunchRecordingType = void Function(LaunchRecordingOptions options);

/// Launches the recording process based on various conditions and updates the UI accordingly.
///
/// The `launchRecording` function manages the initiation, configuration, and visibility of a recording process,
/// handling cases where recording is either allowed or restricted. Based on the provided `LaunchRecordingOptions`,
/// it checks for permissions, shows alerts for restrictions, and updates the visibility of the recording modal.
///
/// ## Parameters:
/// - `options`: An instance of `LaunchRecordingOptions` containing:
///   - `updateIsRecordingModalVisible`: Callback to update the visibility of the recording modal.
///   - `isRecordingModalVisible`: Boolean indicating the current visibility of the recording modal.
///   - `showAlert`: Optional callback for showing alerts.
///   - `stopLaunchRecord`: Indicates if launching recording should be stopped.
///   - `canLaunchRecord`: Indicates if launching recording is permitted.
///   - `recordingAudioSupport`: Indicates if audio recording is supported.
///   - `recordingVideoSupport`: Indicates if video recording is supported.
///   - `updateCanRecord`: Callback to update recording permission.
///   - `updateClearedToRecord`: Callback to update cleared-to-record status.
///   - `recordStarted`: Indicates if recording has already started.
///   - `recordPaused`: Indicates if the recording is currently paused.
///   - `localUIMode`: Indicates if the UI is in local-only mode (restricts recording).
///
/// ## Example Usage:
///
/// ```dart
/// // Define a showAlert function to display an alert message
/// void showAlert({required String message, required String type, required int duration}) {
///   print('$type Alert: $message (Duration: $duration ms)');
/// }
///
/// // Callbacks to update recording states
/// void updateCanRecord(bool canRecord) => print('Can Record: $canRecord');
/// void updateClearedToRecord(bool cleared) => print('Cleared to Record: $cleared');
/// void updateIsRecordingModalVisible(bool visible) => print('Recording Modal Visible: $visible');
///
/// // Define options for launching recording
/// final options = LaunchRecordingOptions(
///   updateIsRecordingModalVisible: updateIsRecordingModalVisible,
///   isRecordingModalVisible: false,
///   showAlert: showAlert,
///   stopLaunchRecord: true,
///   canLaunchRecord: true,
///   recordingAudioSupport: true,
///   recordingVideoSupport: false,
///   updateCanRecord: updateCanRecord,
///   updateClearedToRecord: updateClearedToRecord,
///   recordStarted: false,
///   recordPaused: false,
///   localUIMode: false,
/// );
///
/// // Launch recording process
/// launchRecording(options);
/// // Expected output:
/// // Recording Modal Visible: true
/// ```
///
/// This example sets up the options for launching recording, including alert handling and state updates.

void launchRecording(LaunchRecordingOptions options) {
  final showAlert = options.showAlert;

  // Check if recording is already launched
  if (!options.isRecordingModalVisible &&
      options.stopLaunchRecord &&
      !options.localUIMode) {
    showAlert?.call(
      message: 'Recording has already ended or you are not allowed to record',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  // Check if recording initiation is allowed
  if (!options.isRecordingModalVisible &&
      options.canLaunchRecord &&
      !options.localUIMode) {
    // Check if both audio and video recording are not allowed
    if (!options.recordingAudioSupport && !options.recordingVideoSupport) {
      showAlert?.call(
        message: 'You are not allowed to record',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    // Update clearedToRecord and canRecord
    options.updateClearedToRecord(false);
    options.updateCanRecord(false);
  }

  if (!options.isRecordingModalVisible && options.recordStarted) {
    if (!options.recordPaused) {
      showAlert?.call(
        message: 'You can only re-configure recording after pausing it',
        type: 'danger',
        duration: 3000,
      );
      return;
    }
  }

  if (!options.isRecordingModalVisible &&
      !options.recordingAudioSupport &&
      !options.recordingVideoSupport &&
      !options.localUIMode) {
    showAlert?.call(
      message: 'You are not allowed to record',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  // Update the visibility of the recording modal
  options.updateIsRecordingModalVisible(!options.isRecordingModalVisible);
}
