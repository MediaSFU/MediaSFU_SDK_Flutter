import 'dart:async';

/// Checks if the user can resume recording based on the provided parameters.
///
/// The [parameters] map should contain the following keys:
/// - 'recordingMediaOptions': The type of media being recorded ('video' or 'audio').
/// - 'recordingVideoPausesLimit': The maximum number of pauses allowed for video recording.
/// - 'recordingAudioPausesLimit': The maximum number of pauses allowed for audio recording.
/// - 'pauseRecordCount': The current number of pauses during recording.
///
/// Returns `true` if the user can resume recording, `false` otherwise.

Future<bool> checkResumeState(
    {required Map<String, dynamic> parameters}) async {
  String recordingMediaOptions = parameters['recordingMediaOptions'];
  int recordingVideoPausesLimit = parameters['recordingVideoPausesLimit'];
  int recordingAudioPausesLimit = parameters['recordingAudioPausesLimit'];
  int pauseRecordCount = parameters['pauseRecordCount'];
  // Function to check if the user can resume recording
  int refLimit = 0;
  if (recordingMediaOptions == 'video') {
    refLimit = recordingVideoPausesLimit;
  } else {
    refLimit = recordingAudioPausesLimit;
  }

  if (pauseRecordCount > refLimit) {
    return false;
  } else {
    return true;
  }
}
