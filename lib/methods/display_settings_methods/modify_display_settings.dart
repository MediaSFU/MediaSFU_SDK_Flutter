import 'package:flutter/foundation.dart';
import 'dart:async';

/// Modifies the display settings based on the provided parameters.
///
/// The [parameters] map contains the following keys:
/// - showAlert: A function that shows an alert with the specified message, type, and duration.
/// - meetingDisplayType: The current meeting display type.
/// - autoWave: A boolean indicating whether auto wave is enabled.
/// - forceFullDisplay: A boolean indicating whether force full display is enabled.
/// - meetingVideoOptimized: A boolean indicating whether meeting video is optimized.
/// - islevel: The current level.
/// - recordStarted: A boolean indicating whether recording has started.
/// - recordResumed: A boolean indicating whether recording has resumed.
/// - recordStopped: A boolean indicating whether recording has stopped.
/// - recordPaused: A boolean indicating whether recording has paused.
/// - recordingDisplayType: The current recording display type.
/// - recordingVideoOptimized: A boolean indicating whether recording video is optimized.
/// - prevForceFullDisplay: The previous force full display value.
/// - prevMeetingDisplayType: The previous meeting display type.
/// - updateMeetingDisplayType: A function to update the meeting display type.
/// - updateAutoWave: A function to update the auto wave value.
/// - updateForceFullDisplay: A function to update the force full display value.
/// - updateMeetingVideoOptimized: A function to update the meeting video optimized value.
/// - updatePrevForceFullDisplay: A function to update the previous force full display value.
/// - updatePrevMeetingDisplayType: A function to update the previous meeting display type.
/// - updateIsDisplaySettingsModalVisible: A function to update the visibility of the display settings modal.
/// - updateFirstAll: A function to update the first all value.
/// - updateUpdateMainWindow: A function to update the main window update value.
/// - onScreenChanges: A function that handles on-screen changes.
///
/// The function checks and updates the state variables based on the provided logic.
/// It also shows alerts and performs additional actions based on the logic.
/// If an error occurs, it prints the error message in debug mode.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef UpdateFunction = void Function(dynamic);

typedef OnScreenChanges = Future<void> Function({
  required bool changed,
  required Map<String, dynamic> parameters,
});

typedef UpdateBoolFunction = void Function(bool);

typedef UpdateStringFunction = void Function(String);

Future<void> modifyDisplaySettings(
    {required Map<String, dynamic> parameters}) async {
  try {
    ShowAlert? showAlert = parameters['showAlert'];
    String meetingDisplayType = parameters['meetingDisplayType'];
    bool autoWave = parameters['autoWave'] ?? false;
    bool forceFullDisplay = parameters['forceFullDisplay'] ?? false;
    bool meetingVideoOptimized = parameters['meetingVideoOptimized'] ?? false;
    String islevel = parameters['islevel'] ?? '1';
    bool recordStarted = parameters['recordStarted'] ?? false;
    bool recordResumed = parameters['recordResumed'] ?? false;
    bool recordStopped = parameters['recordStopped'] ?? false;
    bool recordPaused = parameters['recordPaused'] ?? false;
    String recordingDisplayType = parameters['recordingDisplayType'];
    bool recordingVideoOptimized = parameters['recordingVideoOptimized'];
    bool prevForceFullDisplay = parameters['prevForceFullDisplay'];
    String prevMeetingDisplayType = parameters['prevMeetingDisplayType'];
    UpdateStringFunction updateMeetingDisplayType =
        parameters['updateMeetingDisplayType'];
    UpdateBoolFunction updateAutoWave = parameters['updateAutoWave'];
    UpdateBoolFunction updateForceFullDisplay =
        parameters['updateForceFullDisplay'];
    UpdateBoolFunction updateMeetingVideoOptimized =
        parameters['updateMeetingVideoOptimized'];
    UpdateBoolFunction updatePrevForceFullDisplay =
        parameters['updatePrevForceFullDisplay'];
    UpdateStringFunction updatePrevMeetingDisplayType =
        parameters['updatePrevMeetingDisplayType'];
    UpdateBoolFunction updateIsDisplaySettingsModalVisible =
        parameters['updateIsDisplaySettingsModalVisible'];
    UpdateBoolFunction updateFirstAll = parameters['updateFirstAll'];
    UpdateBoolFunction updateUpdateMainWindow =
        parameters['updateUpdateMainWindow'];

    //mediasfu functions
    OnScreenChanges onScreenChanges = parameters['onScreenChanges'];

    // Update previous states
    updateAutoWave(autoWave);
    updateForceFullDisplay(forceFullDisplay);

    // Check and update state variables based on the provided logic
    if (islevel == '2' &&
        (recordStarted || recordResumed) &&
        (!recordStopped && !recordPaused)) {
      if (recordingDisplayType == 'video') {
        if (meetingDisplayType == 'video' &&
            meetingVideoOptimized &&
            !recordingVideoOptimized) {
          if (showAlert != null) {
            showAlert(
              message:
                  'Meeting display type can be either video, media, or all when recording display type is non-optimized video.',
              type: 'danger',
              duration: 3000,
            );
          }
          // Reset to previous values or handle as needed
          meetingDisplayType = recordingDisplayType;
          updateMeetingDisplayType(meetingDisplayType);
          meetingVideoOptimized = recordingVideoOptimized;
          updateMeetingVideoOptimized(meetingVideoOptimized);
          return;
        }
      } else if (recordingDisplayType == 'media') {
        if (meetingDisplayType == 'video') {
          if (showAlert != null) {
            showAlert(
              message:
                  'Meeting display type can be either media or all when recording display type is media.',
              type: 'danger',
              duration: 3000,
            );
          }
          // Reset to previous values or handle as needed
          meetingDisplayType = recordingDisplayType;
          updateMeetingDisplayType(meetingDisplayType);
          return;
        }
      } else if (recordingDisplayType == 'all') {
        if (meetingDisplayType == 'video' || meetingDisplayType == 'media') {
          if (showAlert != null) {
            showAlert(
              message:
                  'Meeting display type can be only all when recording display type is all.',
              type: 'danger',
              duration: 3000,
            );
          }
          // Reset to previous values or handle as needed
          meetingDisplayType = recordingDisplayType;
          updateMeetingDisplayType(meetingDisplayType);
          return;
        }
      }
    }

    // Update state variables based on logic
    updateMeetingDisplayType(meetingDisplayType);
    updateMeetingVideoOptimized(meetingVideoOptimized);

    // Close the modal or perform additional actions
    updateIsDisplaySettingsModalVisible(false);
    if (prevMeetingDisplayType != meetingDisplayType ||
        prevForceFullDisplay != forceFullDisplay) {
      if (meetingDisplayType != 'all') {
        updateFirstAll(true);
      } else {
        updateFirstAll(false);
      }
      updateUpdateMainWindow(true);
      // Handle on-screen changes
      await onScreenChanges(changed: true, parameters: parameters);
      updatePrevForceFullDisplay(forceFullDisplay);
      updatePrevMeetingDisplayType(meetingDisplayType);
    }
  } catch (error) {
    if (kDebugMode) {
      print("MediaSFU - Error in modifyDisplaySettings: $error");
    }
  }
}
