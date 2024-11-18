import 'dart:async';
import './record_update_timer.dart'
    show recordUpdateTimer, RecordUpdateTimerOptions;

/// Parameters required for the recording timer.
abstract class RecordStartTimerParameters {
  // Core properties as abstract getters
  int? get recordStartTime;
  Timer? get recordTimerInterval;
  bool get isTimerRunning;
  bool get canPauseResume;
  int get recordChangeSeconds;
  bool get recordPaused;
  bool get recordStopped;
  String? get roomName;
  int get recordElapsedTime;
  String get recordingProgressTime;

  // Update functions as abstract getters returning functions
  Function(int?) get updateRecordStartTime;
  Function(Timer?) get updateRecordTimerInterval;
  Function(bool) get updateIsTimerRunning;
  Function(bool) get updateCanPauseResume;
  Function(int) get updateRecordElapsedTime;
  Function(String) get updateRecordingProgressTime;

  // Method to get updated parameters as an abstract getter
  RecordStartTimerParameters Function() get getUpdatedAllParams;

  // Allows dynamic property access if needed
  // dynamic operator [](String key);
}

/// Options for initiating the recording timer.
class RecordStartTimerOptions {
  final RecordStartTimerParameters parameters;

  RecordStartTimerOptions({required this.parameters});
}

typedef RecordStartTimerType = Future<void> Function(
    {required RecordStartTimerOptions options});

/// Starts the recording timer by initializing the timer state and managing the timer interval.
///
/// The `recordStartTimer` function initializes the recording start time, sets up a timer interval to track recording progress,
/// and updates the timer state based on pause, stop, or room availability conditions. It also enables the ability to pause or resume
/// the recording after a specified delay.
///
/// ## Parameters:
/// - `options`: An instance of `RecordStartTimerOptions` containing:
///   - `parameters`: The recording timer parameters, an instance of `RecordStartTimerParameters`, which includes:
///     - `recordStartTime`: The initial start time of the recording.
///     - `recordTimerInterval`: The timer interval to update the recording time.
///     - `isTimerRunning`: Whether the timer is currently active.
///     - `canPauseResume`: Whether pause/resume actions are permitted.
///     - `recordChangeSeconds`: Delay time in milliseconds before enabling pause/resume.
///     - `recordPaused`: Flag indicating if the recording is paused.
///     - `recordStopped`: Flag indicating if the recording is stopped.
///     - `roomName`: Optional room name to ensure recording is linked to an active session.
///
/// ## Example Usage:
///
/// ```dart
/// // Define a class implementing RecordStartTimerParameters
/// class MyRecordTimerParams extends RecordStartTimerParameters {
///   // Define all required properties and methods
///   MyRecordTimerParams({
///     required int recordStartTime,
///     Timer? recordTimerInterval,
///     required bool isTimerRunning,
///     required bool canPauseResume,
///     required int recordChangeSeconds,
///     required bool recordPaused,
///     required bool recordStopped,
///     required String roomName,
///     required Function(int) updateRecordStartTime,
///     required Function(Timer?) updateRecordTimerInterval,
///     required Function(bool) updateIsTimerRunning,
///     required Function(bool) updateCanPauseResume,
///     required RecordStartTimerParameters Function() getUpdatedAllParams,
///   }) : super(
///           recordStartTime: recordStartTime,
///           recordTimerInterval: recordTimerInterval,
///           isTimerRunning: isTimerRunning,
///           canPauseResume: canPauseResume,
///           recordChangeSeconds: recordChangeSeconds,
///           recordPaused: recordPaused,
///           recordStopped: recordStopped,
///           roomName: roomName,
///           updateRecordStartTime: updateRecordStartTime,
///           updateRecordTimerInterval: updateRecordTimerInterval,
///           updateIsTimerRunning: updateIsTimerRunning,
///           updateCanPauseResume: updateCanPauseResume,
///           getUpdatedAllParams: getUpdatedAllParams,
///         );
/// }
///
/// // Instantiate RecordStartTimerOptions and call recordStartTimer
/// final options = RecordStartTimerOptions(
///   parameters: myRecordTimerParamsInstance,
/// );
///
/// // Start the recording timer
/// recordStartTimer(options: options);
/// ```
///
/// This example demonstrates how to start the recording timer with the specified parameters and handle state updates.

Future<void> recordStartTimer(
    {required RecordStartTimerOptions options}) async {
  // Access updated parameters
  RecordStartTimerParameters parameters = options.parameters;
  parameters = parameters.getUpdatedAllParams();

  // Initialize timer properties
  int? recordStartTime = parameters.recordStartTime ?? 0;
  Timer? recordTimerInterval = parameters.recordTimerInterval;
  bool isTimerRunning = parameters.isTimerRunning;
  bool canPauseResume = parameters.canPauseResume;
  int recordChangeSeconds = parameters.recordChangeSeconds;

  void enablePauseResume() {
    canPauseResume = true;
    parameters.updateCanPauseResume(canPauseResume);
  }

  if (!isTimerRunning) {
    // Start the timer
    recordStartTime = DateTime.now().millisecondsSinceEpoch;
    parameters.updateRecordStartTime(recordStartTime);

    var newParameters = parameters.getUpdatedAllParams();
    recordStartTime = newParameters.recordStartTime!;
    parameters.updateRecordStartTime(recordStartTime);

    recordTimerInterval = Timer.periodic(const Duration(seconds: 1), (timer) {
      final optionsUpdate = RecordUpdateTimerOptions(
          recordElapsedTime: parameters.recordElapsedTime,
          recordStartTime: parameters.recordStartTime!,
          updateRecordElapsedTime: parameters.updateRecordElapsedTime,
          updateRecordingProgressTime: parameters.updateRecordingProgressTime);
      recordUpdateTimer(options: optionsUpdate);
      parameters = parameters.getUpdatedAllParams();

      if (parameters.recordPaused ||
          parameters.recordStopped ||
          parameters.roomName == null ||
          parameters.roomName == '') {
        timer.cancel();
        parameters.updateRecordTimerInterval(null);
        isTimerRunning = false;
        parameters.updateIsTimerRunning(isTimerRunning);
        canPauseResume = false;
        parameters.updateCanPauseResume(canPauseResume);
      }
    });

    // Update state variables
    parameters.updateRecordTimerInterval(recordTimerInterval);
    isTimerRunning = true;
    parameters.updateIsTimerRunning(isTimerRunning);
    canPauseResume = false;
    parameters.updateCanPauseResume(canPauseResume);

    Timer(Duration(milliseconds: recordChangeSeconds), enablePauseResume);
  }
}
