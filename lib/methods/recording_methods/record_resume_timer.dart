import 'dart:async';
import './record_update_timer.dart'
    show recordUpdateTimer, RecordUpdateTimerOptions;
import '../../types/types.dart' show ShowAlert;

/// Parameters for resuming the recording timer.
abstract class RecordResumeTimerParameters {
  // Core properties as abstract getters
  bool get isTimerRunning;
  bool get canPauseResume;
  int get recordElapsedTime;
  int? get recordStartTime;
  Timer? get recordTimerInterval;
  ShowAlert? get showAlert;
  bool get recordPaused;
  bool get recordStopped;
  String? get roomName;

  // Update functions as abstract getters returning functions
  void Function(int) get updateRecordStartTime;
  void Function(Timer?) get updateRecordTimerInterval;
  void Function(bool) get updateIsTimerRunning;
  void Function(bool) get updateCanPauseResume;
  void Function(int) get updateRecordElapsedTime;
  void Function(String) get updateRecordingProgressTime;

  // Mediasfu function to get updated parameters as an abstract getter
  RecordResumeTimerParameters Function() get getUpdatedAllParams;

  // Allows dynamic property access if needed
  // dynamic operator [](String key);
}

/// Options for the recordResumeTimer function.
class RecordResumeTimerOptions {
  final RecordResumeTimerParameters parameters;

  RecordResumeTimerOptions({
    required this.parameters,
  });
}

typedef RecordResumeTimerType = Future<bool> Function(
    {required RecordResumeTimerOptions options});

/// Resumes the recording timer if it is not already running and can be paused/resumed.
///
/// Returns `true` if the timer was successfully resumed, otherwise `false`.
///
/// Example usage:
/// ```dart
/// recordResumeTimer(RecordResumeTimerOptions(
///   parameters: RecordResumeTimerParameters(
///     isTimerRunning: false,
///     canPauseResume: true,
///     recordElapsedTime: 60,
///     recordStartTime: DateTime.now().millisecondsSinceEpoch,
///     showAlert: (alert) => print(alert.message),
///     updateRecordStartTime: (time) => print("New start time: $time"),
///     updateRecordTimerInterval: (interval) => print("New interval: $interval"),
///     updateIsTimerRunning: (isRunning) => print("Is timer running: $isRunning"),
///     updateCanPauseResume: (canPause) => print("Can pause/resume: $canPause"),
///     getUpdatedAllParams: () => updatedParameters,
///   ),
/// ));
/// ```
Future<bool> recordResumeTimer(
    {required RecordResumeTimerOptions options}) async {
  var parameters = options.parameters.getUpdatedAllParams();
  var recordStartTime = parameters.recordStartTime;
  var recordTimerInterval = parameters.recordTimerInterval;
  var isTimerRunning = parameters.isTimerRunning;

  // Utility function to show an alert message
  void showAlertMessage(String message) {
    if (parameters.showAlert != null) {
      parameters.showAlert!(
        message: message,
        type: 'danger',
        duration: 3000,
      );
    }
  }

  // Logic to resume the timer
  if (!parameters.isTimerRunning && parameters.canPauseResume) {
    recordStartTime = DateTime.now().millisecondsSinceEpoch -
        (parameters.recordElapsedTime * 1000);
    parameters.updateRecordStartTime(recordStartTime);

    recordTimerInterval =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      final optionsUpdate = RecordUpdateTimerOptions(
          recordElapsedTime: parameters.recordElapsedTime,
          recordStartTime: parameters.recordStartTime!,
          updateRecordElapsedTime: parameters.updateRecordElapsedTime,
          updateRecordingProgressTime: parameters.updateRecordingProgressTime);

      recordUpdateTimer(options: optionsUpdate);
      parameters = parameters.getUpdatedAllParams();

      if (parameters.recordPaused ||
          parameters.recordStopped ||
          parameters.roomName == '' ||
          parameters.roomName == null) {
        timer.cancel();
        parameters.updateRecordTimerInterval(null);
        isTimerRunning = false;
        parameters.updateIsTimerRunning(isTimerRunning);
        parameters.updateCanPauseResume(false);
      }
    });

    parameters.updateRecordTimerInterval(recordTimerInterval);
    isTimerRunning = true;
    parameters.updateIsTimerRunning(isTimerRunning);
    parameters.updateIsTimerRunning(true);
    parameters.updateCanPauseResume(false);
    return true;
  } else {
    showAlertMessage(
        'Can only pause or resume after 15 seconds of starting or pausing or resuming recording');
    return false;
  }
}
