import 'dart:async';

/// Checks if the user can pause recording based on the provided parameters.
///
/// The [parameters] map should contain the following keys:
/// - 'recordingMediaOptions': A string indicating the recording media options ('video' or 'audio').
/// - 'recordingVideoPausesLimit': An integer indicating the maximum number of pauses allowed for video recording.
/// - 'recordingAudioPausesLimit': An integer indicating the maximum number of pauses allowed for audio recording.
/// - 'pauseRecordCount': An integer indicating the current number of pauses.
/// - 'showAlert': An optional function that shows an alert with the specified message, type, and duration.
///
/// Returns `true` if the user can pause recording, `false` otherwise.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

Future<bool> checkPauseState({required Map<String, dynamic> parameters}) async {
  // Extract the required parameters from the 'parameters' map
  String recordingMediaOptions = parameters['recordingMediaOptions'];
  int recordingVideoPausesLimit = parameters['recordingVideoPausesLimit'];
  int recordingAudioPausesLimit = parameters['recordingAudioPausesLimit'];
  int pauseRecordCount = parameters['pauseRecordCount'];
  ShowAlert? showAlert = parameters['showAlert'];
  // Function to check if the user can pause recording
  int refLimit = 0;
  if (recordingMediaOptions == 'video') {
    refLimit = recordingVideoPausesLimit;
  } else {
    refLimit = recordingAudioPausesLimit;
  }

  if (pauseRecordCount < refLimit) {
    return true;
  } else {
    if (showAlert != null) {
      showAlert(
        message:
            'You have reached the limit of pauses - you can choose to stop recording.',
        type: 'danger',
        duration: 3000,
      );
    }
    return false;
  }
}
