import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import './record_start_timer.dart' show recordStartTimer;
import './record_resume_timer.dart' show recordResumeTimer;

/// Starts the recording process with the given parameters.
///
/// The [parameters] map should contain the following keys:
/// - 'roomName': The name of the room for recording.
/// - 'userRecordingParams': The parameters for user recording.
/// - 'socket': The socket for communication.
/// - 'updateIsRecordingModalVisible': A function to update the visibility of the recording modal.
/// - 'confirmedToRecord': A boolean indicating whether the recording is confirmed.
/// - 'showAlert': A function to show an alert message.
/// - 'recordingMediaOptions': The options for recording media (e.g., 'video', 'audio').
/// - 'videoAlreadyOn': A boolean indicating whether the video is already turned on.
/// - 'audioAlreadyOn': A boolean indicating whether the audio is already turned on.
/// - 'recordStarted': A boolean indicating whether the recording has started.
/// - 'recordPaused': A boolean indicating whether the recording is paused.
/// - 'recordResumed': A boolean indicating whether the recording is resumed.
/// - 'recordStopped': A boolean indicating whether the recording is stopped.
/// - 'startReport': A boolean indicating whether the start report is enabled.
/// - 'endReport': A boolean indicating whether the end report is enabled.
/// - 'canRecord': A boolean indicating whether recording is allowed.
/// - 'updateClearedToRecord': A function to update the cleared to record state.
/// - 'updateRecordStarted': A function to update the record started state.
/// - 'updateRecordPaused': A function to update the record paused state.
/// - 'updateStartReport': A function to update the start report state.
/// - 'updateEndReport': A function to update the end report state.
/// - 'updateCanRecord': A function to update the can record state.
/// - 'rePort': A function to handle reporting.
///
/// This function performs various checks and emits the appropriate action to start or resume recording.
/// It also handles the acknowledgment from the server and updates the state accordingly.
/// If any error occurs during the process, it will be caught and printed in debug mode.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef UpdateBooleanState = void Function(bool value);
typedef UpdateRecordState = void Function(String recordState);
typedef UpdatePauseRecordCount = void Function(int pauseRecordCount);

typedef RePort = Future<void> Function({
  bool restart,
  required Map<String, dynamic> parameters,
});

Future<void> startRecording({
  required Map<String, dynamic> parameters,
}) async {
  try {
    String roomName = parameters['roomName'];
    Map<String, dynamic> userRecordingParams =
        parameters['userRecordingParams'];
    io.Socket? socket = parameters['socket'];
    Function updateIsRecordingModalVisible =
        parameters['updateIsRecordingModalVisible'];
    bool confirmedToRecord = parameters['confirmedToRecord'];
    ShowAlert? showAlert = parameters['showAlert'];
    String recordingMediaOptions = parameters['recordingMediaOptions'];
    bool videoAlreadyOn = parameters['videoAlreadyOn'];
    bool audioAlreadyOn = parameters['audioAlreadyOn'];
    bool recordStarted = parameters['recordStarted'];
    bool recordPaused = parameters['recordPaused'];
    bool recordResumed = parameters['recordResumed'];
    bool recordStopped = parameters['recordStopped'];
    bool startReport = parameters['startReport'];
    bool endReport = parameters['endReport'];
    bool canRecord = parameters['canRecord'];
    UpdateBooleanState updateClearedToRecord =
        parameters['updateClearedToRecord'];
    UpdateBooleanState updateRecordStarted = parameters['updateRecordStarted'];
    UpdateBooleanState updateRecordPaused = parameters['updateRecordPaused'];
    UpdateBooleanState updateStartReport = parameters['updateStartReport'];
    UpdateBooleanState updateEndReport = parameters['updateEndReport'];
    UpdateBooleanState updateCanRecord = parameters['updateCanRecord'];

    // mediasfu functions
    RePort rePort = parameters['rePort'];

    // Check if recording is confirmed before starting
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

    // Check for recordingMediaOptions for video
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

    // Check for recordingMediaOptions for audio
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

    // Set clearedToRecord to true
    updateClearedToRecord(true);

    String action =
        recordStarted && recordPaused && !recordResumed && !recordStopped
            ? 'resumeRecord'
            : 'startRecord';

    await Future(() async {
      // Emit the action with acknowledgment
      socket!.emitWithAck(action, {
        'roomName': roomName,
        'userRecordingParams': userRecordingParams,
      }, ack: (data) async {
        // Handle acknowledgment
        bool success = data['success'];
        String reason = data['reason'];

        if (success) {
          recordStarted = true;
          startReport = true;
          endReport = false;
          recordPaused = false;

          updateRecordStarted(recordStarted);
          updateStartReport(startReport);
          updateEndReport(endReport);
          updateRecordPaused(recordPaused);

          if (action == 'startRecord') {
            await rePort(restart: false, parameters: parameters);
            await recordStartTimer(parameters: parameters);
          } else {
            recordResumed = true;
            await rePort(restart: true, parameters: parameters);
            await recordResumeTimer(parameters: parameters);
          }

          // Set isRecordingModalVisible to false
          updateIsRecordingModalVisible(false);
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

          // Set isRecordingModalVisible to false
          updateIsRecordingModalVisible(false);
        }
      });
    });
  } catch (error) {
    if (kDebugMode) {
      print('Error in startRecording: $error');
    }
  }
}
