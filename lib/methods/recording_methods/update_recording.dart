import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import './record_pause_timer.dart'
    show recordPauseTimer, RecordPauseTimerOptions;
import './record_resume_timer.dart'
    show
        recordResumeTimer,
        RecordResumeTimerOptions,
        RecordResumeTimerParameters;
import './check_pause_state.dart' show checkPauseState, CheckPauseStateOptions;
import './check_resume_state.dart'
    show checkResumeState, CheckResumeStateOptions;
import '../../types/types.dart'
    show
        RePortParameters,
        RePortType,
        ShowAlert,
        RePortOptions,
        UserRecordingParams;

typedef UpdateBooleanState = void Function(bool);

/// Parameters required for updating the recording state, implementing several
/// interfaces for managing recording and timer state, and providing abstract
/// getters for flexible and detailed recording configurations.
abstract class UpdateRecordingParameters
    implements RePortParameters, RecordResumeTimerParameters {
  // Core properties as abstract getters
  String get roomName;
  UserRecordingParams get userRecordingParams;
  io.Socket? get socket;
  io.Socket? get localSocket;
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
  int get recordChangeSeconds;
  int get pauseRecordCount;
  bool get startReport;
  bool get endReport;
  bool get canRecord;
  bool get canPauseResume;
  int get recordingVideoPausesLimit;
  int get recordingAudioPausesLimit;
  bool get isTimerRunning;

  // Update functions as abstract getters returning functions
  UpdateBooleanState get updateCanPauseResume;
  void Function(int) get updatePauseRecordCount;
  UpdateBooleanState get updateClearedToRecord;
  UpdateBooleanState get updateRecordPaused;
  UpdateBooleanState get updateRecordResumed;
  UpdateBooleanState get updateStartReport;
  UpdateBooleanState get updateEndReport;
  UpdateBooleanState get updateCanRecord;

  // Mediasfu function as an abstract getter
  RePortType get rePort;

  // Method to retrieve updated parameters as an abstract getter
  UpdateRecordingParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

/// Options for the updateRecording function, containing recording parameters.
class UpdateRecordingOptions {
  final UpdateRecordingParameters parameters;

  UpdateRecordingOptions({required this.parameters});
}

/// Typedef for the update recording function
typedef UpdateRecordingType = Future<void> Function(
    UpdateRecordingParameters options);

/// Updates the recording based on the given parameters, managing recording start,
/// pause, and resume states, as well as providing alerts for required conditions.
///
/// ### Recording State Management
/// - **Pause**: Validates if recording can be paused based on limits and triggers
///   the `recordPauseTimer` if conditions are met.
/// - **Resume**: Validates if recording can be resumed based on limits and confirms
///   before triggering the `recordResumeTimer`.
///
/// ### Example Usage:
/// ```dart
/// final options = UpdateRecordingOptions(
///   parameters: recordingParameters,
/// );
///
/// await updateRecording(options);
/// ```
///
/// ### Error Handling:
/// - Provides alerts for invalid actions (e.g., recording stopped or media not on).
/// - Reports success or failure for each recording state change through `ShowAlert`.

Future<void> updateRecording(UpdateRecordingOptions options) async {
  final parameters = options.parameters;
  String roomName = parameters.roomName;
  UserRecordingParams userRecordingParams = parameters.userRecordingParams;
  io.Socket? socket = parameters.socket;
  io.Socket? localSocket = parameters.localSocket;
  void Function(bool) updateIsRecordingModalVisible =
      parameters.updateIsRecordingModalVisible;
  bool confirmedToRecord = parameters.confirmedToRecord;
  ShowAlert? showAlert = parameters.showAlert;
  String recordingMediaOptions = parameters.recordingMediaOptions;
  bool videoAlreadyOn = parameters.videoAlreadyOn;
  bool audioAlreadyOn = parameters.audioAlreadyOn;
  bool recordStarted = parameters.recordStarted;
  bool recordPaused = parameters.recordPaused;
  bool recordResumed = parameters.recordResumed;
  bool recordStopped = parameters.recordStopped;
  int recordChangeSeconds = parameters.recordChangeSeconds;
  int pauseRecordCount = parameters.pauseRecordCount;
  bool startReport = parameters.startReport;
  bool endReport = parameters.endReport;
  bool canRecord = parameters.canRecord;
  void Function(bool) updateCanPauseResume = parameters.updateCanPauseResume;
  void Function(int) updatePauseRecordCount = parameters.updatePauseRecordCount;
  void Function(bool) updateClearedToRecord = parameters.updateClearedToRecord;
  void Function(bool) updateRecordPaused = parameters.updateRecordPaused;
  void Function(bool) updateRecordResumed = parameters.updateRecordResumed;
  void Function(bool) updateStartReport = parameters.updateStartReport;
  void Function(bool) updateEndReport = parameters.updateEndReport;
  void Function(bool) updateCanRecord = parameters.updateCanRecord;
  RePortType rePort = parameters.rePort;

  // Check if recording has stopped
  if (recordStopped) {
    showAlert?.call(
      message: 'Recording has already stopped',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  // Check media options for video and audio
  if (recordingMediaOptions == 'video' && !videoAlreadyOn) {
    showAlert?.call(
      message: 'You must turn on your video before you can start recording',
      type: 'danger',
      duration: 3000,
    );
    return;
  }
  if (recordingMediaOptions == 'audio' && !audioAlreadyOn) {
    showAlert?.call(
      message: 'You must turn on your audio before you can start recording',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  io.Socket socketRef = socket!;
  if (localSocket != null && localSocket.id != null) {
    socketRef = localSocket;
  }

  // Handle Pause Action
  if (recordStarted && !recordPaused && !recordStopped) {
    final optionsCheckPause = CheckPauseStateOptions(
      recordingMediaOptions: recordingMediaOptions,
      recordingVideoPausesLimit: parameters.recordingVideoPausesLimit,
      recordingAudioPausesLimit: parameters.recordingAudioPausesLimit,
      pauseRecordCount: pauseRecordCount,
      showAlert: showAlert,
    );
    bool proceed = await checkPauseState(optionsCheckPause);
    if (!proceed) return;

    final optionsPause = RecordPauseTimerOptions(
      stop: false,
      isTimerRunning: parameters.isTimerRunning,
      canPauseResume: parameters.canPauseResume,
      showAlert: parameters.showAlert,
    );
    bool record = recordPauseTimer(optionsPause);
    if (record) {
      String action = 'pauseRecord';

      await Future(() async {
        socketRef.emitWithAck(action, {'roomName': roomName},
            ack: (data) async {
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

            showAlert?.call(
              message: 'Recording paused',
              type: 'success',
              duration: 3000,
            );

            updateIsRecordingModalVisible(false);
            Future.delayed(Duration(milliseconds: recordChangeSeconds), () {
              updateCanPauseResume(true);
            });
          } else {
            String reasonMessage =
                'Recording Pause Failed: $reason; the current state is: $recordState';
            showAlert?.call(
              message: reasonMessage,
              type: 'danger',
              duration: 3000,
            );
          }
        });
      });
    }
  }

  // Handle Resume Action
  else if (recordStarted && recordPaused && !recordStopped) {
    if (!confirmedToRecord) {
      showAlert?.call(
        message: 'You must click confirm before you can start recording',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    final optionsResumeParameters = parameters;
    final optionsResume = RecordResumeTimerOptions(
      parameters: optionsResumeParameters,
    );

    final optionsCheckResume = CheckResumeStateOptions(
      recordingMediaOptions: recordingMediaOptions,
      recordingVideoPausesLimit: parameters.recordingVideoPausesLimit,
      recordingAudioPausesLimit: parameters.recordingAudioPausesLimit,
      pauseRecordCount: pauseRecordCount,
    );
    bool proceed = await checkResumeState(options: optionsCheckResume);
    if (!proceed) return;

    bool resume = await recordResumeTimer(options: optionsResume);
    if (resume) {
      updateClearedToRecord(true);

      String action = 'resumeRecord';
      await Future(() async {
        socketRef.emitWithAck(action, {
          'roomName': roomName,
          'userRecordingParams': userRecordingParams.toMap(),
        }, ack: (data) async {
          bool success = data['success'] ?? false;
          String reason = data['reason'] ?? '';

          if (success) {
            recordPaused = false;
            recordResumed = true;
            updateRecordPaused(recordPaused);
            updateRecordResumed(recordResumed);

            final optionsReport = RePortOptions(
              parameters: parameters.getUpdatedAllParams(),
              restart: true,
            );
            await rePort(optionsReport);
          } else {
            showAlert?.call(
              message: 'Recording could not start - $reason',
              type: 'danger',
              duration: 3000,
            );

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
