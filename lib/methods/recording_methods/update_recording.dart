import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import './record_pause_timer.dart' show recordPauseTimer;
import './record_resume_timer.dart' show recordResumeTimer;
import './check_pause_state.dart' show checkPauseState;
import './check_resume_state.dart' show checkResumeState;

/// Updates the recording based on the given parameters.
///
/// The [parameters] map contains the following keys:
/// - 'roomName': The name of the room.
/// - 'userRecordingParams': The parameters for user recording.
/// - 'socket': The socket for communication.
/// - 'updateIsRecordingModalVisible': A function to update the visibility of the recording modal.
/// - 'confirmedToRecord': A boolean indicating whether the recording is confirmed.
/// - 'showAlert': A function to show an alert message.
/// - 'recordingMediaOptions': The options for recording media (default is 'audio').
/// - 'videoAlreadyOn': A boolean indicating whether the video is already on.
/// - 'audioAlreadyOn': A boolean indicating whether the audio is already on.
/// - 'recordStarted': A boolean indicating whether the recording has started.
/// - 'recordPaused': A boolean indicating whether the recording is paused.
/// - 'recordResumed': A boolean indicating whether the recording is resumed.
/// - 'recordStopped': A boolean indicating whether the recording is stopped.
/// - 'recordChangeSeconds': The number of milliseconds for record change.
/// - 'pauseRecordCount': The count of pause records.
/// - 'startReport': A boolean indicating whether the report has started.
/// - 'endReport': A boolean indicating whether the report has ended.
/// - 'canRecord': A boolean indicating whether recording is allowed.
/// - 'updateCanPauseResume': A function to update the ability to pause/resume recording.
/// - 'updateClearedToRecord': A function to update the cleared to record state.
/// - 'updateRecordPaused': A function to update the paused state of recording.
/// - 'updateRecordResumed': A function to update the resumed state of recording.
/// - 'updateStartReport': A function to update the start report state.
/// - 'updateEndReport': A function to update the end report state.
/// - 'updateCanRecord': A function to update the ability to record.
/// - 'updatePauseRecordCount': A function to update the count of pause records.
/// - 'rePort': A function to report the recording.
///
/// This function performs various checks and updates the recording state accordingly.
/// It communicates with the server using the provided socket and emits appropriate events.
/// It also handles pause and resume functionality based on the current recording state.
/// If any error occurs during the process, it shows an alert message.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef RePort = Future<void> Function({
  bool restart,
  required Map<String, dynamic> parameters,
});

typedef UpdateBooleanState = void Function(bool value);
typedef UpdateRecordState = void Function(String recordState);
typedef UpdatePauseRecordCount = void Function(int value);

Future<void> updateRecording({required Map<String, dynamic> parameters}) async {
  String roomName = parameters['roomName'];
  Map<String, dynamic> userRecordingParams = parameters['userRecordingParams'];
  io.Socket socket = parameters['socket'];
  UpdateBooleanState updateIsRecordingModalVisible =
      parameters['updateIsRecordingModalVisible'];
  bool confirmedToRecord = parameters['confirmedToRecord'];
  ShowAlert? showAlert = parameters['showAlert'];
  String recordingMediaOptions = parameters['recordingMediaOptions'] ?? 'audio';
  bool videoAlreadyOn = parameters['videoAlreadyOn'] ?? false;
  bool audioAlreadyOn = parameters['audioAlreadyOn'] ?? false;
  bool recordStarted = parameters['recordStarted'] ?? false;
  bool recordPaused = parameters['recordPaused'] ?? false;
  bool recordResumed = parameters['recordResumed'] ?? false;
  bool recordStopped = parameters['recordStopped'] ?? false;
  int recordChangeSeconds = parameters['recordChangeSeconds'] ?? 15000;
  int pauseRecordCount = parameters['pauseRecordCount'] ?? 0;
  bool startReport = parameters['startReport'] ?? false;
  bool endReport = parameters['endReport'] ?? false;
  bool canRecord = parameters['canRecord'] ?? false;

  UpdateBooleanState updateCanPauseResume = parameters['updateCanPauseResume'];
  UpdateBooleanState updateClearedToRecord =
      parameters['updateClearedToRecord'];
  UpdateBooleanState updateRecordPaused = parameters['updateRecordPaused'];
  UpdateBooleanState updateRecordResumed = parameters['updateRecordResumed'];
  UpdateBooleanState updateStartReport = parameters['updateStartReport'];
  UpdateBooleanState updateEndReport = parameters['updateEndReport'];
  UpdateBooleanState updateCanRecord = parameters['updateCanRecord'];

  UpdatePauseRecordCount updatePauseRecordCount =
      parameters['updatePauseRecordCount'];

  //mediasfu functions
  RePort rePort = parameters['rePort'];

  if (recordStopped) {
    if (showAlert != null) {
      showAlert(
        message: 'Recording has already stopped',
        type: 'danger',
        duration: 3000,
      );
    }
    return;
  }

  if (recordingMediaOptions == 'video' && !videoAlreadyOn) {
    if (showAlert != null) {
      showAlert(
        message: 'You must turn on your video before you can start recording',
        type: 'danger',
        duration: 3000,
      );
    }
    return;
  }

  if (recordingMediaOptions == 'audio' && !audioAlreadyOn) {
    if (showAlert != null) {
      showAlert(
        message: 'You must turn on your audio before you can start recording',
        type: 'danger',
        duration: 3000,
      );
    }
    return;
  }

  if (recordStarted && !recordPaused && !recordStopped) {
    bool? proceed = false;

    proceed = await checkPauseState(parameters: parameters);

    if (!proceed) {
      return;
    }

    bool? record = recordPauseTimer(stop: false, parameters: parameters);
    if (record) {
      String action = 'pauseRecord';

      await Future(() async {
        socket.emitWithAck(action, {'roomName': roomName}, ack: (data) async {
          bool success = data['success'] ?? false;
          String reason = data['reason'] ?? '';
          String recordState = data['recordState'] ?? '';
          int pauseCount = data['pauseCount'] ?? 0;
          pauseRecordCount = pauseCount;
          updatePauseRecordCount(pauseRecordCount);

          if (success) {
            startReport = false;
            endReport = true;
            recordPaused = true;
            updateStartReport(startReport);
            updateEndReport(endReport);
            updateRecordPaused(recordPaused);

            if (showAlert != null) {
              showAlert(
                message: 'Recording paused',
                type: 'success',
                duration: 3000,
              );
            }

            updateIsRecordingModalVisible(false);
            Future.delayed(Duration(milliseconds: recordChangeSeconds), () {
              updateCanPauseResume(true);
            });
          } else {
            String reasonMessage =
                'Recording Pause Failed: $reason; the current state is: $recordState';
            if (showAlert != null) {
              showAlert(
                message: reasonMessage,
                type: 'danger',
                duration: 3000,
              );
            }
          }
        });
      });
    }
  } else if (recordStarted && recordPaused && !recordStopped) {
    if (!confirmedToRecord) {
      if (showAlert != null) {
        showAlert(
          message: 'You must click confirm before you can start recording',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    bool? proceed = false;

    proceed = await checkResumeState(parameters: parameters);

    if (!proceed) {
      return;
    }

    bool? resume = await recordResumeTimer(parameters: parameters);
    if (resume) {
      updateClearedToRecord(true);

      String action = 'startRecord';
      if (recordStarted && recordPaused && !recordResumed && !recordStopped) {
        action = 'resumeRecord';
      } else {
        action = 'startRecord';
      }
      action = 'resumeRecord';

      await Future(() async {
        socket.emitWithAck(action, {
          'roomName': roomName,
          'userRecordingParams': userRecordingParams
        }, ack: (data) async {
          // Your callback function implementation
          bool success = data['success'] ?? false;
          String reason = data['reason'] ?? '';

          if (success) {
            recordPaused = false;
            recordResumed = true;
            updateRecordPaused(recordPaused);
            updateRecordResumed(recordResumed);

            if (action == 'startRecord') {
              await rePort(restart: false, parameters: parameters);
            } else {
              recordResumed = true;
              await rePort(restart: true, parameters: parameters);
            }
          } else {
            if (showAlert != null) {
              showAlert(
                message: 'Recording could not start - $reason',
                type: 'danger',
                duration: 3000,
              );
            }
            canRecord = true;
            startReport = false;
            endReport = true;

            updateCanRecord(canRecord);
            updateStartReport(startReport);
            updateEndReport(endReport);
          }
        });
      });

      updateIsRecordingModalVisible(false);
      Future.delayed(Duration(milliseconds: recordChangeSeconds), () {
        updateCanPauseResume(true);
      });
    }
  }
}
