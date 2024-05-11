// ignore_for_file: empty_catches

import 'dart:async';

import 'package:flutter/foundation.dart';

/// Switches the user's video (from front to back camera and vice versa) based on the given parameters.
///
/// The [parameters] map contains the following keys:
/// - `recordStarted`: A boolean indicating if recording has started.
/// - `recordResumed`: A boolean indicating if recording has resumed.
/// - `recordStopped`: A boolean indicating if recording has stopped.
/// - `recordPaused`: A boolean indicating if recording has paused.
/// - `recordingMediaOptions`: A string representing the recording media options.
/// - `videoAlreadyOn`: A boolean indicating if the video is already turned on.
/// - `currentFacingMode`: A string representing the current facing mode of the camera.
/// - `allowed`: A boolean indicating if camera access is allowed.
/// - `audioOnlyRoom`: A boolean indicating if the room is audio-only.
/// - `updateCurrentFacingMode`: A function that updates the current facing mode.
/// - `updateIsMediaSettingsModalVisible`: A function that updates the visibility of the media settings modal.
/// - `showAlert`: A function that shows an alert message.
/// - `switchUserVideoAlt`: A function that switches the user's video alternative.
///
/// If the room is audio-only, an alert message will be shown and the function will return.
///
/// If camera access is not allowed, an alert message will be shown and the function will return.
///
/// Depending on the video state and the selected video device, different alert messages will be shown.
///
/// The camera switching logic is implemented here by updating the current facing mode and calling the `switchUserVideoAlt` function.
///
/// Example usage:
/// ```dart
/// await switchVideoAlt(parameters: {
///   'recordStarted': true,
///   'videoAlreadyOn': false,
///   'currentFacingMode': 'user',
///   'allowed': true,
///   'audioOnlyRoom': false,
///   'updateCurrentFacingMode': (mode) {
///     // Update the current facing mode logic
///   },
///   'updateIsMediaSettingsModalVisible': (visible) {
///     // Update the media settings modal visibility logic
///   },
///   'showAlert': ({message, type, duration}) {
///     // Show alert message logic
///   },
///   'switchUserVideoAlt': ({parameters}) async {
///     // Switch user's video alternative logic
///   },
/// });
/// ```

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef SwitchUserVideoAlt = Future<void> Function(
    {required Map<String, dynamic> parameters});

Future<void> switchVideoAlt({required Map<String, dynamic> parameters}) async {
  // Destructuring parameters for ease of use

  try {
    bool recordStarted = parameters['recordStarted'] ?? false;
    bool recordResumed = parameters['recordResumed'] ?? false;
    bool recordStopped = parameters['recordStopped'] ?? false;
    bool recordPaused = parameters['recordPaused'] ?? false;
    String recordingMediaOptions = parameters['recordingMediaOptions'] ?? '';
    bool videoAlreadyOn = parameters['videoAlreadyOn'] ?? false;
    String currentFacingMode = parameters['currentFacingMode'] ?? 'user';
    bool allowed = parameters['allowed'] ?? false;
    bool audioOnlyRoom = parameters['audioOnlyRoom'] ?? false;
    Function(String)? updateCurrentFacingMode =
        parameters['updateCurrentFacingMode'];
    Function(bool)? updateIsMediaSettingsModalVisible =
        parameters['updateIsMediaSettingsModalVisible'];
    ShowAlert? showAlert = parameters['showAlert'];

    // mediasfu functions
    SwitchUserVideoAlt? switchUserVideoAlt = parameters['switchUserVideoAlt'];

    if (audioOnlyRoom) {
      if (showAlert != null) {
        showAlert(
          message: 'You cannot turn on your camera in an audio-only event.',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    // Check if recording is in progress and whether the selected video device is the default one
    bool checkoff = false;
    if ((recordStarted || recordResumed) && (!recordStopped && !recordPaused)) {
      if (recordingMediaOptions == 'video') {
        checkoff = true;
      }
    }

    // Check camera access permission
    if (!allowed) {
      if (showAlert != null) {
        showAlert(
          message:
              'Allow access to your camera by starting it for the first time.',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    // Check video state and display appropriate alert messages
    if (checkoff) {
      if (videoAlreadyOn) {
        if (showAlert != null) {
          showAlert(
            message: 'Please turn off your video before switching.',
            type: 'danger',
            duration: 3000,
          );
        }
        return;
      }
    } else {
      if (!videoAlreadyOn) {
        if (showAlert != null) {
          showAlert(
            message: 'Please turn on your video before switching.',
            type: 'danger',
            duration: 3000,
          );
        }
        return;
      }
    }

    // Camera switching logic here
    currentFacingMode =
        currentFacingMode == 'environment' ? 'user' : 'environment';
    if (updateCurrentFacingMode != null) {
      await updateCurrentFacingMode(currentFacingMode);
    }

    if (updateIsMediaSettingsModalVisible != null) {
      updateIsMediaSettingsModalVisible(false);
    }

    if (switchUserVideoAlt != null) {
      try {
        await switchUserVideoAlt(parameters: {
          'videoPreference': currentFacingMode,
          'checkoff': checkoff,
          ...parameters
        });
      } catch (error) {}
    }
  } catch (error) {
    if (kDebugMode) {
      print('switchVideoAlt error: $error');
    }
  }
}
