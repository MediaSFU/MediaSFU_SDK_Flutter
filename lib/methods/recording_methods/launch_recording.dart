typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

/// Launches the recording process with the given parameters.
///
/// The [parameters] map should contain the following keys:
/// - 'showAlert': A function that shows an alert with a message, type, and duration.
/// - 'isRecordingModalVisible': A boolean indicating if the recording modal is visible.
/// - 'stopLaunchRecord': A boolean indicating if the launch recording should be stopped.
/// - 'localUIMode': A boolean indicating if the recording is in local UI mode.
/// - 'canLaunchRecord': A boolean indicating if the recording can be launched.
/// - 'recordingAudioSupport': A boolean indicating if audio recording is supported.
/// - 'recordingVideoSupport': A boolean indicating if video recording is supported.
/// - 'recordStarted': A boolean indicating if the recording has started.
/// - 'recordPaused': A boolean indicating if the recording is paused.
/// - 'updateClearedToRecord': A function that updates the cleared to record status.
/// - 'updateCanRecord': A function that updates the can record status.
/// - 'updateIsRecordingModalVisible': A function that updates the visibility of the recording modal.
///
/// If the recording modal is not visible, the launch recording is stopped, and it's not in local UI mode,
/// an alert will be shown with a message indicating that the recording has already ended or the user is not allowed to record.
///
/// If the recording modal is not visible, the recording can be launched, and it's not in local UI mode,
/// an alert will be shown if audio or video recording is not supported, and the cleared to record and can record status will be updated.
///
/// If the recording modal is not visible and the recording has started, an alert will be shown if the recording is not paused.
///
/// If the recording modal is not visible, audio and video recording are not supported, and it's not in local UI mode,
/// an alert will be shown indicating that the user is not allowed to record.
///
/// The visibility of the recording modal will be updated at the end of the function.

typedef UpdateClearedToRecord = void Function(bool cleared);
typedef UpdateCanRecord = void Function(bool canRecord);
typedef UpdateIsRecordingModalVisible = void Function(bool visible);

void launchRecording({required Map<String, dynamic> parameters}) {
  final ShowAlert showAlert = parameters['showAlert'];
  final bool? isRecordingModalVisible = parameters['isRecordingModalVisible'];
  final bool? stopLaunchRecord = parameters['stopLaunchRecord'];
  final bool localUIMode = parameters['localUIMode'] ?? false;
  final bool canLaunchRecord = parameters['canLaunchRecord'];
  final bool recordingAudioSupport = parameters['recordingAudioSupport'];
  final bool recordingVideoSupport = parameters['recordingVideoSupport'];
  final bool recordStarted = parameters['recordStarted'];
  final bool recordPaused = parameters['recordPaused'];
  final UpdateClearedToRecord? updateClearedToRecord =
      parameters['updateClearedToRecord'];
  final UpdateCanRecord? updateCanRecord = parameters['updateCanRecord'];
  final UpdateIsRecordingModalVisible? updateIsRecordingModalVisible =
      parameters['updateIsRecordingModalVisible'];

  if (!isRecordingModalVisible! && stopLaunchRecord! && !localUIMode) {
    showAlert(
      message: 'Recording has already ended or you are not allowed to record',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  if (!isRecordingModalVisible && canLaunchRecord && !localUIMode) {
    if (!recordingAudioSupport && !recordingVideoSupport) {
      showAlert(
        message: 'You are not allowed to record',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    updateClearedToRecord!(false);
    updateCanRecord!(false);
  }

  if (!isRecordingModalVisible && recordStarted) {
    if (!recordPaused) {
      showAlert(
        message: 'You can only re-configure recording after pausing it',
        type: 'danger',
        duration: 3000,
      );
      return;
    }
  }

  if (!isRecordingModalVisible &&
      !recordingAudioSupport &&
      !recordingVideoSupport &&
      !localUIMode) {
    showAlert(
      message: 'You are not allowed to record',
      type: 'danger',
      duration: 3000,
    );
    return;
  }
  updateIsRecordingModalVisible!(!isRecordingModalVisible);
}
