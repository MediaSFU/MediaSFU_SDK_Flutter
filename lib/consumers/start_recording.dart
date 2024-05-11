import 'dart:async';

/// Starts the recording process.
///
/// This function attempts to start the recording process based on the provided options.
/// It communicates with a socket and updates various variables and functions based on the recording state.
///
/// The [options] parameter is a map that contains the following keys:
///   - 'parameters': A map of parameters required for the recording process.
///
/// The function returns a [Future] that resolves to a boolean value indicating whether the recording attempt was successful.
/// If the recording is successful, the function updates various variables and functions related to the recording state.
///
/// Example usage:
/// ```dart
/// bool recordingStarted = await startRecordings(options: {
///   'parameters': {
///     'socket': socket,
///     'showAlert': showAlertFunction,
///     'roomName': 'exampleRoom',
///     'userRecordingParams': userParams,
///     'recordStarted': false,
///     'recordPaused': false,
///     'recordResumed': false,
///     'recordStopped': false,
///     'canRecord': true,
///     'startReport': false,
///     'endReport': false,
///     'rePort': rePortFunction,
///     'updateRecordStarted': updateRecordStartedFunction,
///     'updateRecordPaused': updateRecordPausedFunction,
///     'updateRecordResumed': updateRecordResumedFunction,
///     'updateRecordStopped': updateRecordStoppedFunction,
///     'updateCanRecord': updateCanRecordFunction,
///     'updateStartReport': updateStartReportFunction,
///     'updateEndReport': updateEndReportFunction,
///   },
/// });
/// ```

typedef ShowAlertFunction = void Function(Map<String, dynamic> message);
typedef RePortFunction = Future<void> Function({
  bool restart,
  required Map<String, dynamic> parameters,
});
typedef UpdateRecordFunction = void Function(bool value);

Future<bool> startRecordings({required Map<String, dynamic> options}) async {
  Map<String, dynamic> parameters = options['parameters'];
  dynamic socket = parameters['socket'];
  ShowAlertFunction? showAlert = parameters['showAlert'];
  String roomName = parameters['roomName'];
  Map<String, dynamic> userRecordingParams = parameters['userRecordingParams'];
  bool recordStarted = parameters['recordStarted'];
  bool recordPaused = parameters['recordPaused'];
  bool recordResumed = parameters['recordResumed'];
  bool recordStopped = parameters['recordStopped'];
  bool canRecord = parameters['canRecord'];
  bool startReport = parameters['startReport'];
  bool endReport = parameters['endReport'];
  RePortFunction rePort = parameters['rePort'];
  UpdateRecordFunction updateRecordStarted = parameters['updateRecordStarted'];
  UpdateRecordFunction updateRecordPaused = parameters['updateRecordPaused'];
  UpdateRecordFunction updateRecordResumed = parameters['updateRecordResumed'];
  UpdateRecordFunction updateRecordStopped = parameters['updateRecordStopped'];
  UpdateRecordFunction updateCanRecord = parameters['updateCanRecord'];
  UpdateRecordFunction updateStartReport = parameters['updateStartReport'];
  UpdateRecordFunction updateEndReport = parameters['updateEndReport'];

  // Attempt to start recording and return true if successful
  bool recAttempt = false;

  String action;
  if (recordStarted && recordPaused && !recordResumed && !recordStopped) {
    action = 'resumeRecord';
  } else {
    action = 'startRecord';
  }

  await socket.emit(action, {
    'roomName': roomName,
    'userRecordingParams': userRecordingParams
  }, ({success, reason, recordState}) async {
    if (success) {
      recordStarted = true;
      startReport = true;
      endReport = false;
      recordPaused = false;
      recAttempt = true;

      if (action == 'startRecord') {
        rePort(parameters: parameters);
      } else {
        recordResumed = true;
        rePort(restart: true, parameters: parameters);
      }
    } else {
      if (showAlert != null) {
        showAlert({
          'message':
              'Recording Failed: $reason; the current state is: $recordState',
          'type': 'danger',
          'duration': 3000,
        });
      }
      canRecord = true;
      startReport = false;
      endReport = true;
      recAttempt = false;
    }

    // Resolve the promise
    return recAttempt;
  });

  // Update the recordStarted variable
  updateRecordStarted(recordStarted);
  updateRecordPaused(recordPaused);
  updateRecordResumed(recordResumed);
  updateRecordStopped(recordStopped);
  updateCanRecord(canRecord);
  updateStartReport(startReport);
  updateEndReport(endReport);

  return recAttempt;
}
