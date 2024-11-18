import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import './record_start_timer.dart'
    show recordStartTimer, RecordStartTimerOptions, RecordStartTimerParameters;
import './record_resume_timer.dart'
    show
        recordResumeTimer,
        RecordResumeTimerOptions,
        RecordResumeTimerParameters;
import '../../types/types.dart'
    show
        RePortType,
        // CaptureCanvasStreamType,
        CaptureCanvasStreamParameters,
        RePortParameters,
        ShowAlert,
        RePortOptions,
        // CaptureCanvasStreamOptions,
        UserRecordingParams;

typedef UpdateBooleanState = void Function(bool);

/// Parameters required for starting the recording.
abstract class StartRecordingParameters
    implements
        CaptureCanvasStreamParameters,
        RePortParameters,
        RecordStartTimerParameters,
        RecordResumeTimerParameters {
  // Core properties as abstract getters
  String get roomName;
  UserRecordingParams get userRecordingParams;
  io.Socket? get socket;
  UpdateBooleanState get updateIsRecordingModalVisible;
  bool get confirmedToRecord;
  ShowAlert? get showAlert;
  String get recordingMediaOptions;
  bool get videoAlreadyOn;
  bool get audioAlreadyOn;
  bool get recordStarted;
  bool get recordPaused;
  bool get recordResumed;
  bool get recordStopped;
  bool get startReport;
  bool get endReport;
  bool get canRecord;
  UpdateBooleanState get updateClearedToRecord;
  UpdateBooleanState get updateRecordStarted;
  UpdateBooleanState get updateRecordPaused;
  UpdateBooleanState get updateRecordResumed;
  UpdateBooleanState get updateStartReport;
  UpdateBooleanState get updateEndReport;
  UpdateBooleanState get updateCanRecord;
  void Function(String) get updateRecordingProgressTime;
  bool get whiteboardStarted;
  bool get whiteboardEnded;

  // Mediasfu functions as abstract getters
  RePortType get rePort;
  // CaptureCanvasStreamType get captureCanvasStream;

  // Method to retrieve updated parameters as an abstract getter
  StartRecordingParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

class StartRecordingOptions {
  final StartRecordingParameters parameters;

  StartRecordingOptions({required this.parameters});
}

typedef StartRecordingType = Future<bool?> Function(
    StartRecordingOptions options);

/// Starts the recording process, managing different states and actions based on recording options.
///
/// The `startRecording` function validates if recording can begin by checking conditions such as user confirmation,
/// video/audio availability, and specific recording options. It then initiates either a new recording or resumes an
/// existing one, updating related state properties and calling required functions.
///
/// This function is also responsible for displaying alerts if conditions are not met and emitting socket events
/// to manage recording on the server. Additionally, it supports capturing a whiteboard stream if specified.
///
/// ## Parameters:
/// - `parameters`: An instance of [StartRecordingParameters] that provides all the required properties and callback
///   functions needed to manage the recording state, interactions with socket events, and any required updates.
///
/// ## Returns:
/// - `Future<bool?>`: A `Future` that resolves to a boolean indicating whether the recording started/resumed
///   successfully (`true`), was unable to start due to a condition (`false`), or encountered an error (`null`).
///
/// ## Example Usage:
///
/// ```dart
/// final startParams = StartRecordingParameters(
///   roomName: 'Room_123',
///   userRecordingParams: {'resolution': '1080p'},
///   socket: io.Socket(),
///   updateIsRecordingModalVisible: (visible) => print('Recording Modal Visibility: $visible'),
///   confirmedToRecord: true,
///   showAlert: (message, type, duration) => print('Alert: $message'),
///   recordingMediaOptions: 'video',
///   videoAlreadyOn: true,
///   audioAlreadyOn: true,
///   recordStarted: false,
///   recordPaused: false,
///   recordResumed: false,
///   recordStopped: false,
///   startReport: false,
///   endReport: true,
///   canRecord: true,
///   updateClearedToRecord: (cleared) => print('Cleared to Record: $cleared'),
///   updateRecordStarted: (started) => print('Record Started: $started'),
///   updateRecordPaused: (paused) => print('Record Paused: $paused'),
///   updateRecordResumed: (resumed) => print('Record Resumed: $resumed'),
///   updateStartReport: (start) => print('Start Report: $start'),
///   updateEndReport: (end) => print('End Report: $end'),
///   updateCanRecord: (canRecord) => print('Can Record: $canRecord'),
///   whiteboardStarted: true,
///   whiteboardEnded: false,
///   rePort: (parameters) => print('Reporting: $parameters'),
///
///   getUpdatedAllParams: () => startParams,
/// );
///
/// startRecording(
///   StartRecordingOptions(parameters: startParams),
///   print('Recording started: $started');
/// );
/// ```

Future<bool?> startRecording(StartRecordingOptions options) async {
  final parameters = options.parameters;
  try {
    var updatedParams = parameters.getUpdatedAllParams();
    var recordStarted = parameters.recordStarted;
    var startReport = parameters.startReport;
    var endReport = parameters.endReport;
    var recordPaused = parameters.recordPaused;

    if (!parameters.confirmedToRecord) {
      parameters.showAlert?.call(
        message: 'You must click confirm before you can start recording',
        type: 'danger',
        duration: 3000,
      );
      return false;
    }

    if (parameters.recordingMediaOptions == 'video' &&
        !parameters.videoAlreadyOn) {
      parameters.showAlert?.call(
        message: 'You must turn on your video before you can start recording',
        type: 'danger',
        duration: 3000,
      );
      return false;
    }

    if (parameters.recordingMediaOptions == 'audio' &&
        !parameters.audioAlreadyOn) {
      parameters.showAlert?.call(
        message: 'You must turn on your audio before you can start recording',
        type: 'danger',
        duration: 3000,
      );
      return false;
    }

    parameters.updateClearedToRecord(true);

    String action = parameters.recordStarted &&
            parameters.recordPaused &&
            !parameters.recordResumed &&
            !parameters.recordStopped
        ? 'resumeRecord'
        : 'startRecord';

    bool recAttempt = false;

    parameters.socket!.emitWithAck(action, {
      'roomName': parameters.roomName,
      'userRecordingParams': parameters.userRecordingParams.toMap(),
    }, ack: (data) async {
      bool success = data['success'];
      String reason = data['reason'];

      if (success) {
        recordStarted = true;
        startReport = true;
        endReport = false;
        recordPaused = false;
        recAttempt = true;

        parameters.updateRecordStarted(recordStarted);
        parameters.updateStartReport(startReport);
        parameters.updateEndReport(endReport);
        parameters.updateRecordPaused(recordPaused);

        if (action == 'startRecord') {
          final optionsReport = RePortOptions(parameters: updatedParams);
          await parameters.rePort(optionsReport);
          final recordOptions =
              RecordStartTimerOptions(parameters: updatedParams);
          recordStartTimer(options: recordOptions);
        } else {
          parameters.updateRecordResumed(true);
          final optionsReport =
              RePortOptions(parameters: updatedParams, restart: true);
          await parameters.rePort(optionsReport);
          final recordOptions =
              RecordResumeTimerOptions(parameters: updatedParams);
          recordResumeTimer(options: recordOptions);
        }
      } else {
        parameters.showAlert?.call(
          message: 'Recording could not start - $reason',
          type: 'danger',
          duration: 3000,
        );
        parameters.updateCanRecord(true);
        parameters.updateStartReport(false);
        parameters.updateEndReport(true);
      }
    });

    if (recAttempt &&
        parameters.whiteboardStarted &&
        !parameters.whiteboardEnded &&
        parameters.recordingMediaOptions == 'video') {
      // not implemented
      // final optionsCapture = CaptureCanvasStreamOptions();
      // parameters.captureCanvasStream(optionsCapture);
    }

    parameters.updateIsRecordingModalVisible(false);
    return recAttempt;
  } catch (error) {
    if (kDebugMode) {
      print('Error in startRecording: $error');
    }
    return null;
  }
}
