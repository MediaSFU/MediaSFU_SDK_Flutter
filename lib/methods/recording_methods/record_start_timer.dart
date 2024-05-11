import 'dart:async';
import './record_update_timer.dart' show recordUpdateTimer;

/// Starts the recording timer.
///
/// This function starts the recording timer and updates the timer every second.
/// It also enables pause/resume actions after a specified time.
///
/// Parameters:
/// - `parameters`: A map containing the required parameters for the timer.
///
/// Required Parameters:
/// - `getUpdatedAllParams`: A function that returns a map of updated parameters.
///
/// Example usage:
/// ```dart
/// recordStartTimer(parameters: {
///   'getUpdatedAllParams': () => getUpdatedAllParams(),
/// });
/// ```

typedef RecordUpdateTimer = void Function({Map<String, dynamic> parameters});
typedef GetUpdatedAllParams = Map<String, dynamic> Function();

Future<void> recordStartTimer(
    {required Map<String, dynamic> parameters}) async {
  GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
  parameters = getUpdatedAllParams();

  int? recordStartTime = parameters['recordStartTime'];
  late Timer recordTimer; // Declare a Timer variable to store the Timer object

  bool isTimerRunning = parameters['isTimerRunning'] ?? false;
  bool canPauseResume = parameters['canPauseResume'] ?? false;
  int recordChangeSeconds = parameters['recordChangeSeconds'] ?? 15000;

  void enablePauseResume() {
    canPauseResume = true;
    parameters['updateCanPauseResume'](canPauseResume);
  }

  if (!isTimerRunning) {
    recordStartTime = DateTime.now().millisecondsSinceEpoch;
    parameters['updateRecordStartTime'](recordStartTime);

    recordTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      // Update the timer every second (1000 milliseconds)
      recordUpdateTimer(
          parameters: {...parameters, 'recordStartTime': recordStartTime});
      parameters = parameters['getUpdatedAllParams']();

      // Check if recording is paused or stopped, and close the interval if needed
      if (parameters['recordPaused'] ||
          parameters['recordStopped'] ||
          parameters['roomName'] == "" ||
          parameters['roomName'] == null) {
        timer.cancel();
        parameters['updateRecordTimerInterval'](null);
        isTimerRunning = false;
        parameters['updateIsTimerRunning'](isTimerRunning);
        canPauseResume = false;
        parameters['updateCanPauseResume'](canPauseResume);
      }
    });
    parameters['updateRecordTimerInterval'](
        recordTimer); // Store the Timer object
    isTimerRunning = true;
    parameters['updateIsTimerRunning'](isTimerRunning);
    canPauseResume = false;
    parameters['updateCanPauseResume'](canPauseResume);
    Timer(Duration(milliseconds: recordChangeSeconds),
        enablePauseResume); // Enable pause/resume actions after specified time
  }
}
