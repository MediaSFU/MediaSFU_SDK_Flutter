import 'package:flutter/foundation.dart';
import '../../types/types.dart'
    show
        OnScreenChangesParameters,
        OnScreenChangesType,
        ShowAlert,
        OnScreenChangesOptions;

/// Parameters for modifying display settings, including functions and states.
abstract class ModifyDisplaySettingsParameters
    implements OnScreenChangesParameters {
  // Properties as abstract getters
  ShowAlert? get showAlert;
  String get meetingDisplayType;
  bool get autoWave;
  bool get forceFullDisplay;
  bool get meetingVideoOptimized;
  String get islevel;
  bool get recordStarted;
  bool get recordResumed;
  bool get recordStopped;
  bool get recordPaused;
  String get recordingDisplayType;
  bool get recordingVideoOptimized;
  bool get prevForceFullDisplay;
  String get prevMeetingDisplayType;
  bool get breakOutRoomStarted;
  bool get breakOutRoomEnded;

  // Update functions as abstract getters
  void Function(String) get updateMeetingDisplayType;
  void Function(bool) get updateAutoWave;
  void Function(bool) get updateForceFullDisplay;
  void Function(bool) get updateMeetingVideoOptimized;
  void Function(bool) get updatePrevForceFullDisplay;
  void Function(String) get updatePrevMeetingDisplayType;
  void Function(bool) get updateIsDisplaySettingsModalVisible;
  void Function(bool) get updateFirstAll;
  void Function(bool) get updateUpdateMainWindow;

  // Mediasfu function as an abstract getter
  OnScreenChangesType get onScreenChanges;

  // dynamic operator [](String key);
  // void operator []=(String key, dynamic value);
}

class ModifyDisplaySettingsOptions {
  final ModifyDisplaySettingsParameters parameters;

  ModifyDisplaySettingsOptions({
    required this.parameters,
  });
}

typedef ModifyDisplaySettingsType = Future<void> Function(
    ModifyDisplaySettingsOptions options);

/// Adjusts meeting display settings, updating state variables and handling alerts.
///
/// ### Parameters:
/// - `options` (`ModifyDisplaySettingsOptions`): Contains:
///   - `parameters`: Settings and functions, including:
///     - Display settings (`meetingDisplayType`, `autoWave`, etc.)
///     - Recording status flags (`recordStarted`, `recordResumed`, etc.)
///     - Update functions for changing settings.
///
/// ### Workflow:
/// 1. **Auto-Wave and Force Display Settings**:
///    - Sets `autoWave` and `forceFullDisplay` as configured in `parameters`.
///
/// 2. **Recording-Dependent Display Adjustments**:
///    - If recording is active, validates compatible display types:
///      - `meetingDisplayType` changes based on `recordingDisplayType` to ensure compatible display settings for recording sessions.
///
/// 3. **Breakout Room Display Restriction**:
///    - If a breakout room is active, restricts display type to "all."
///
/// 4. **Display Update with On-Screen Changes**:
///    - If the display settings or breakout room requirements change, triggers `onScreenChanges` to apply them to the UI.
///
/// ### Example Usage:
/// ```dart
/// final parameters = ModifyDisplaySettingsParameters(
///   meetingDisplayType: 'video',
///   forceFullDisplay: true,
///   recordStarted: true,
///   recordingDisplayType: 'media',
///   updateMeetingDisplayType: (type) => print("Updated meeting display type: $type"),
///   updateForceFullDisplay: (forced) => print("Force full display: $forced"),
///   onScreenChanges: (options) async => print("Screen updated"),
///   // Additional parameter implementations...
/// );
///
/// await modifyDisplaySettings(
///   ModifyDisplaySettingsOptions(parameters: parameters),
/// );
/// ```
///
/// ### Error Handling:
/// - Prints error messages to the console in debug mode if an error occurs during settings modification.

Future<void> modifyDisplaySettings(ModifyDisplaySettingsOptions options) async {
  try {
    final parameters = options.parameters;
    var showAlert = parameters.showAlert;
    var meetingDisplayType = parameters.meetingDisplayType;
    var autoWave = parameters.autoWave;
    var forceFullDisplay = parameters.forceFullDisplay;
    var meetingVideoOptimized = parameters.meetingVideoOptimized;
    var islevel = parameters.islevel;
    var recordStarted = parameters.recordStarted;
    var recordResumed = parameters.recordResumed;
    var recordStopped = parameters.recordStopped;
    var recordPaused = parameters.recordPaused;
    var recordingDisplayType = parameters.recordingDisplayType;
    var recordingVideoOptimized = parameters.recordingVideoOptimized;
    var prevForceFullDisplay = parameters.prevForceFullDisplay;
    var prevMeetingDisplayType = parameters.prevMeetingDisplayType;

    parameters.updateAutoWave(autoWave);
    parameters.updateForceFullDisplay(forceFullDisplay);

    if (islevel == '2' &&
        (recordStarted || recordResumed) &&
        !recordStopped &&
        !recordPaused) {
      if (recordingDisplayType == 'video' &&
          meetingDisplayType == 'video' &&
          meetingVideoOptimized &&
          !recordingVideoOptimized) {
        showAlert?.call(
          message:
              "Meeting display type can be either video, media, or all when recording display type is non-optimized video.",
          type: "danger",
          duration: 3000,
        );
        meetingDisplayType = recordingDisplayType;
        parameters.updateMeetingDisplayType(meetingDisplayType);
        meetingVideoOptimized = recordingVideoOptimized;
        parameters.updateMeetingVideoOptimized(meetingVideoOptimized);
        return;
      } else if (recordingDisplayType == 'media' &&
          meetingDisplayType == 'video') {
        showAlert?.call(
          message:
              "Meeting display type can be either media or all when recording display type is media.",
          type: "danger",
          duration: 3000,
        );
        meetingDisplayType = recordingDisplayType;
        parameters.updateMeetingDisplayType(meetingDisplayType);
        return;
      } else if (recordingDisplayType == 'all' &&
          (meetingDisplayType == 'video' || meetingDisplayType == 'media')) {
        showAlert?.call(
          message:
              "Meeting display type can be only all when recording display type is all.",
          type: "danger",
          duration: 3000,
        );
        meetingDisplayType = recordingDisplayType;
        parameters.updateMeetingDisplayType(meetingDisplayType);
        return;
      }
    }

    parameters.updateMeetingDisplayType(meetingDisplayType);
    parameters.updateMeetingVideoOptimized(meetingVideoOptimized);
    parameters.updateIsDisplaySettingsModalVisible(false);

    if (prevMeetingDisplayType != meetingDisplayType ||
        prevForceFullDisplay != forceFullDisplay) {
      if (parameters.breakOutRoomStarted &&
          !parameters.breakOutRoomEnded &&
          meetingDisplayType != 'all') {
        showAlert?.call(
          message: "Breakout room is active. Display type can only be all.",
          type: "danger",
          duration: 3000,
        );
        meetingDisplayType = prevMeetingDisplayType;
        parameters.updateMeetingDisplayType(prevMeetingDisplayType);
        return;
      }

      parameters.updateFirstAll(meetingDisplayType != 'all');
      parameters.updateUpdateMainWindow(true);
      parameters.updateMeetingDisplayType(meetingDisplayType);
      parameters.updateForceFullDisplay(forceFullDisplay);
      await parameters.onScreenChanges(
        OnScreenChangesOptions(
          changed: true,
          parameters: parameters,
        ),
      );
      parameters.updatePrevForceFullDisplay(forceFullDisplay);
      parameters.updatePrevMeetingDisplayType(meetingDisplayType);
    }
  } catch (error) {
    if (kDebugMode) {
      print("MediaSFU - Error in modifyDisplaySettings: $error");
    }
  }
}
