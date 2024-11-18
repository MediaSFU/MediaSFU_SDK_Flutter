import 'dart:async';

typedef CheckResumeStateType = Future<bool> Function(
    CheckResumeStateOptions options);

/// Options for checking if recording can be resumed.
class CheckResumeStateOptions {
  final String recordingMediaOptions; // 'video' or 'audio'
  final int recordingVideoPausesLimit;
  final int recordingAudioPausesLimit;
  final int pauseRecordCount;

  CheckResumeStateOptions({
    required this.recordingMediaOptions,
    required this.recordingVideoPausesLimit,
    required this.recordingAudioPausesLimit,
    required this.pauseRecordCount,
  });
}

/// Checks if the user can resume recording based on the provided options.
///
/// Example usage:
/// ```dart
/// final options = CheckResumeStateOptions(
///   recordingMediaOptions: 'video',
///   recordingVideoPausesLimit: 3,
///   recordingAudioPausesLimit: 5,
///   pauseRecordCount: 2,
/// );
/// final canResume = await checkResumeState(options: options);
/// print(canResume); // true if pauseRecordCount is within limits
/// ```
Future<bool> checkResumeState(
    {required CheckResumeStateOptions options}) async {
  int refLimit = options.recordingMediaOptions == 'video'
      ? options.recordingVideoPausesLimit
      : options.recordingAudioPausesLimit;

  return options.pauseRecordCount <= refLimit;
}
