import 'dart:async';
import './record_update_timer.dart' show recordUpdateTimer;

/// Resumes the recording timer.
///
/// This function is responsible for resuming the recording timer. It takes a map of parameters as input, which includes the necessary data for the timer. The parameters map should contain the following keys:
/// - `getUpdatedAllParams`: A function that returns the updated parameters map.
/// - `isTimerRunning`: A boolean indicating whether the timer is currently running.
/// - `canPauseResume`: A boolean indicating whether the timer can be paused or resumed.
/// - `recordElapsedTime`: An integer representing the elapsed time of the recording.
/// - `recordStartTime`: An integer representing the start time of the recording.
/// - `recordTimerInterval`: A Timer object representing the current timer interval.
/// - `showAlert`: An optional function that shows an alert message.
/// - `updateRecordStartTime`: A function that updates the record start time.
/// - `updateRecordTimerInterval`: A function that updates the record timer interval.
/// - `updateIsTimerRunning`: A function that updates the isTimerRunning flag.
/// - `updateCanPauseResume`: A function that updates the canPauseResume flag.
///
/// If the timer is not currently running and can be paused or resumed, the function resumes the timer by updating the record start time, starting a new timer interval, and updating the necessary flags. It returns `true` to indicate a successful resume.
///
/// If the timer cannot be resumed, the function shows an alert message indicating the reason and returns `false`.
///
/// Example usage:
/// ```dart
/// recordResumeTimer(parameters: {
///   'getUpdatedAllParams': getUpdatedAllParams,
///   'isTimerRunning': isTimerRunning,
///   'canPauseResume': canPauseResume,
///   'recordElapsedTime': recordElapsedTime,
///   'recordStartTime': recordStartTime,
///   'recordTimerInterval': recordTimerInterval,
///   'showAlert': showAlert,
///   'updateRecordStartTime': updateRecordStartTime,
///   'updateRecordTimerInterval': updateRecordTimerInterval,
///   'updateIsTimerRunning': updateIsTimerRunning,
///   'updateCanPauseResume': updateCanPauseResume,
/// });
///

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

Future<bool> recordResumeTimer(
    {required Map<String, dynamic> parameters}) async {
  // Extracting parameters from the map
  var getUpdatedAllParams = parameters['getUpdatedAllParams'];
  parameters = await getUpdatedAllParams();

  var isTimerRunning = parameters['isTimerRunning'] as bool;
  var canPauseResume = parameters['canPauseResume'] as bool;
  var recordElapsedTime = parameters['recordElapsedTime'] as int;
  var recordStartTime = parameters['recordStartTime'] as int;
  var recordTimerInterval = parameters['recordTimerInterval'] as Timer?;
  final ShowAlert? showAlert = parameters['showAlert'];
  var updateRecordStartTime =
      parameters['updateRecordStartTime'] as Function(int);
  var updateRecordTimerInterval =
      parameters['updateRecordTimerInterval'] as Function(Timer?);
  var updateIsTimerRunning =
      parameters['updateIsTimerRunning'] as Function(bool);
  var updateCanPauseResume =
      parameters['updateCanPauseResume'] as Function(bool);

  // Utility function to show an alert message
  void showAlertMessage(String message) {
    if (showAlert != null) {
      showAlert(
        message: message,
        type: 'danger',
        duration: 3000,
      );
    }
  }

  if (!isTimerRunning && canPauseResume) {
    recordStartTime =
        DateTime.now().millisecondsSinceEpoch - (recordElapsedTime * 1000);
    updateRecordStartTime(recordStartTime);

    recordTimerInterval = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordUpdateTimer(parameters: parameters);
      parameters = getUpdatedAllParams();

      if (parameters['recordPaused'] ||
          parameters['recordStopped'] ||
          (parameters['roomName'] == "" || parameters['roomName'] == null)) {
        timer.cancel();
        updateRecordTimerInterval(null);
        isTimerRunning = false;
        updateIsTimerRunning(isTimerRunning);
        canPauseResume = false;
        updateCanPauseResume(canPauseResume);
      }
    });

    updateRecordTimerInterval(recordTimerInterval);
    isTimerRunning = true;
    updateIsTimerRunning(isTimerRunning);
    canPauseResume = false;
    updateCanPauseResume(canPauseResume);
    return true;
  } else {
    showAlertMessage(
        'Can only pause or resume after 15 seconds of starting or pausing or resuming recording');
    return false;
  }
}
