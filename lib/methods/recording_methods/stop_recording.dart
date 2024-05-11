import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import './record_pause_timer.dart' show recordPauseTimer;

/// Stops the recording process.
///
/// This function stops the recording process by emitting a 'stopRecord' event to the server.
/// It takes a map of parameters as an argument, including the room name, socket connection,
/// and various update functions for state management.
/// If the recording is successfully stopped, it updates the state variables and shows a success alert.
/// If the recording stop fails, it shows an error alert with the reason for the failure.
///
/// Parameters:
/// - `parameters`: A map of parameters including the room name, socket connection, and update functions.
///
/// Returns: A `Future` that completes when the recording is stopped.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef UpdateBooleanState = void Function(bool value);
typedef UpdateRecordState = void Function(dynamic recordState);
typedef UpdatePauseRecordCount = void Function(int pauseRecordCount);

Future<void> stopRecording({required Map<String, dynamic> parameters}) async {
  String roomName = parameters['roomName'];
  io.Socket socket = parameters['socket'];
  ShowAlert? showAlert = parameters['showAlert'];
  bool recordStarted = parameters['recordStarted'] ?? false;
  bool startReport = parameters['startReport'] ?? false;
  bool endReport = parameters['endReport'] ?? false;
  bool recordPaused = parameters['recordPaused'] ?? false;
  bool recordStopped = parameters['recordStopped'] ?? false;
  UpdateBooleanState updateRecordPaused = parameters['updateRecordPaused'];
  UpdateBooleanState updateRecordStopped = parameters['updateRecordStopped'];
  UpdateBooleanState updateStartReport = parameters['updateStartReport'];
  UpdateBooleanState updateEndReport = parameters['updateEndReport'];
  UpdateBooleanState updateShowRecordButtons =
      parameters['updateShowRecordButtons'];

  if (recordStarted && !recordStopped) {
    bool? stop = recordPauseTimer(stop: true, parameters: parameters);
    if (stop) {
      String action = 'stopRecord';

      await Future(() async {
        socket.emitWithAck(action, {'roomName': roomName}, ack: (data) async {
          bool success = data['success'];
          String reason = data['reason'];
          String recordState = data['recordState'];
          if (success) {
            startReport = false;
            endReport = true;
            recordPaused = false;
            recordStopped = true;

            updateStartReport(startReport);
            updateEndReport(endReport);
            updateRecordPaused(recordPaused);
            updateRecordStopped(recordStopped);

            if (showAlert != null) {
              showAlert(
                message: 'Recording Stopped',
                type: 'success',
                duration: 3000,
              );
            }

            updateShowRecordButtons(false);
          } else {
            String reasonMessage =
                'Recording Stop Failed: $reason; the recording is currently $recordState';
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
    } else {
      return;
    }
  } else {
    if (showAlert != null) {
      showAlert(
        message: 'Recording is not started yet or already stopped',
        type: 'danger',
        duration: 3000,
      );
    }
  }
}
