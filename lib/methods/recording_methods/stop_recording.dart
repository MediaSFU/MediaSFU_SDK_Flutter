import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import './record_pause_timer.dart'
    show recordPauseTimer, RecordPauseTimerOptions;
import '../../types/types.dart' show ShowAlert;
//  CaptureCanvasStreamType, CaptureCanvasStreamOptions;

typedef UpdateBooleanState = void Function(bool);

/// Parameters required to stop the recording.
abstract class StopRecordingParameters {
  // Core properties as abstract getters
  String get roomName;
  io.Socket? get socket;
  io.Socket? get localSocket;
  ShowAlert? get showAlert;
  bool get startReport;
  bool get endReport;
  bool get recordStarted;
  bool get recordPaused;
  bool get recordStopped;
  bool get isTimerRunning;
  bool get canPauseResume;

  // Update functions as abstract getters returning functions
  UpdateBooleanState get updateRecordPaused;
  UpdateBooleanState get updateRecordStopped;
  UpdateBooleanState get updateStartReport;
  UpdateBooleanState get updateEndReport;
  UpdateBooleanState get updateShowRecordButtons;

  // Additional properties as abstract getters
  bool get whiteboardStarted;
  bool get whiteboardEnded;
  String get recordingMediaOptions;

  // Mediasfu function as an abstract getter
  // CaptureCanvasStreamType get captureCanvasStream;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

class StopRecordingOptions {
  final StopRecordingParameters parameters;

  StopRecordingOptions({required this.parameters});
}

typedef StopRecordingType = Future<void> Function(StopRecordingOptions options);

/// Stops the recording process, managing different states and actions based on current recording status.
///
/// The `stopRecording` function verifies if a recording session is active and not yet stopped. If conditions
/// allow, it sends an event to stop recording on the server, updates state parameters accordingly, and shows
/// an alert confirming the stop action. It also handles any required canvas stream stop if the recording involves video.
///
/// ## Parameters:
/// - `parameters`: An instance of [StopRecordingParameters] providing the recording room, socket connection,
///   and callback functions needed to manage recording states and UI updates.
///
/// ## Returns:
/// - `Future<void>`: This function completes once the recording stop action and any related updates or alerts are handled.
///
/// ## Example Usage:
///
/// ```dart
/// final stopParams = StopRecordingParameters(
///   roomName: 'Room_123',
///   socket: io.Socket(),
///   localSocket: io.Socket(),
///   showAlert: (message, type, duration) => print('Alert: $message'),
///   startReport: true,
///   endReport: false,
///   recordStarted: true,
///   recordPaused: false,
///   recordStopped: false,
///   updateRecordPaused: (paused) => print('Record Paused: $paused'),
///   updateRecordStopped: (stopped) => print('Record Stopped: $stopped'),
///   updateStartReport: (start) => print('Start Report: $start'),
///   updateEndReport: (end) => print('End Report: $end'),
///   updateShowRecordButtons: (show) => print('Show Record Buttons: $show'),
///   whiteboardStarted: true,
///   whiteboardEnded: false,
///   recordingMediaOptions: 'video',
/// );
///
/// // Call stopRecording to stop the recording process
/// stopRecording(StopRecordingOptions(parameters: stopParams));
/// // Expected output:
/// // Alert: Recording Stopped
/// // Show Record Buttons: false
/// // Capture Canvas Stream: {parameters: StopRecordingParameters, start: false}
/// ```

Future<void> stopRecording(StopRecordingOptions options) async {
  final parameters = options.parameters;
  var startReport = parameters.startReport;
  var endReport = parameters.endReport;
  var recordPaused = parameters.recordPaused;
  var recordStopped = parameters.recordStopped;
  if (parameters.recordStarted && !parameters.recordStopped) {
    final optionsPause = RecordPauseTimerOptions(
      stop: true,
      isTimerRunning: parameters.isTimerRunning,
      canPauseResume: parameters.canPauseResume,
      showAlert: parameters.showAlert,
    );
    bool? stop = recordPauseTimer(optionsPause);

    if (stop == true) {
      const String action = 'stopRecord';

      io.Socket socketRef = parameters.socket!;
      if (parameters.localSocket != null &&
          parameters.localSocket!.id != null) {
        socketRef = parameters.localSocket!;
      }

      socketRef.emitWithAck(
        action,
        {'roomName': parameters.roomName},
        ack: (data) async {
          bool success = data['success'];
          String reason = data['reason'];
          String recordState = data['recordState'];

          if (success) {
            startReport = false;
            endReport = true;
            recordPaused = false;
            recordStopped = true;

            parameters.updateStartReport(startReport);
            parameters.updateEndReport(endReport);
            parameters.updateRecordPaused(recordPaused);
            parameters.updateRecordStopped(recordStopped);

            parameters.showAlert?.call(
              message: 'Recording Stopped',
              type: 'success',
              duration: 3000,
            );

            parameters.updateShowRecordButtons(false);

            // Handle canvas stream if necessary
            if (parameters.whiteboardStarted &&
                !parameters.whiteboardEnded &&
                parameters.recordingMediaOptions == 'video') {
              // not implemented
              // final optionsCapture = CaptureCanvasStreamOptions();
              // parameters.captureCanvasStream(optionsCapture);
            }
          } else {
            String reasonMessage =
                'Recording Stop Failed: $reason; the recording is currently $recordState';
            parameters.showAlert?.call(
              message: reasonMessage,
              type: 'danger',
              duration: 3000,
            );
          }
        },
      );
    }
  } else {
    parameters.showAlert?.call(
      message: 'Recording is not started yet or already stopped',
      type: 'danger',
      duration: 3000,
    );
  }
}
