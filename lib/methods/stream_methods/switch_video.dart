import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../types/types.dart'
    show
        ShowAlert,
        SwitchUserVideoType,
        SwitchUserVideoOptions,
        SwitchUserVideoParameters;

/// Parameters for switching the user's video device.
abstract class SwitchVideoParameters implements SwitchUserVideoParameters {
  // Core properties as abstract getters
  bool get recordStarted;
  bool get recordResumed;
  bool get recordStopped;
  bool get recordPaused;
  String get recordingMediaOptions;
  bool get videoAlreadyOn;
  String get userDefaultVideoInputDevice;
  String get defVideoID;
  bool get allowed;

  // Update functions as abstract getters
  void Function(String) get updateDefVideoID;
  void Function(String) get updatePrevVideoInputDevice;
  void Function(String) get updateUserDefaultVideoInputDevice;
  void Function(bool) get updateIsMediaSettingsModalVisible;

  // Mediasfu function as an abstract getter
  SwitchUserVideoType get switchUserVideo;

  // Optional alert as an abstract getter
  ShowAlert? get showAlert;

  // Method to retrieve updated parameters as an abstract getter
  SwitchVideoParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Options for switching the user's video device.
class SwitchVideoOptions {
  final String videoPreference;
  final SwitchVideoParameters parameters;

  SwitchVideoOptions({
    required this.videoPreference,
    required this.parameters,
  });
}

/// Type definition for the switchVideo function.
typedef SwitchVideoType = Future<void> Function(SwitchVideoOptions options);

/// Switches the user's video device based on the provided video preference.
///
/// This function performs the following tasks:
/// - Checks if the room is audio-only and shows an alert if camera usage is restricted.
/// - Validates recording states to determine if video can be switched.
/// - Checks if camera access is allowed and prompts the user accordingly.
/// - Updates the default and previous video input devices.
/// - Calls the [switchUserVideo] function to perform the actual video device switching.
///
/// ### Parameters:
/// - [options] (`SwitchVideoOptions`): Contains the `videoPreference` and `parameters` required for switching video.
///
/// ### Example:
/// ```dart
/// final switchVideoOptions = SwitchVideoOptions(
///   videoPreference: "newVideoDeviceID",
///   parameters: SwitchVideoParameters(
///     recordStarted: true,
///     recordResumed: false,
///     recordStopped: false,
///     recordPaused: false,
///     recordingMediaOptions: "video",
///     videoAlreadyOn: true,
///     userDefaultVideoInputDevice: "currentVideoDeviceID",
///     defVideoID: "defaultVideoDeviceID",
///     allowed: true,
///     updateDefVideoID: (deviceId) => setDefVideoID(deviceId),
///     updatePrevVideoInputDevice: (deviceId) => setPrevVideoDevice(deviceId),
///     updateUserDefaultVideoInputDevice: (deviceId) => setUserDefaultVideo(deviceId),
///     updateIsMediaSettingsModalVisible: (isVisible) => setMediaSettingsModal(isVisible),
///     showAlert: (alertOptions) => showAlert(alertOptions),
///     switchUserVideo: switchUserVideoFunction,
///   ),
/// );
///
/// await switchVideo(switchVideoOptions);
/// ```

Future<void> switchVideo(SwitchVideoOptions options) async {
  try {
    final parameters = options.parameters.getUpdatedAllParams();

    // Destructure parameters for easier access
    bool recordStarted = parameters.recordStarted;
    bool recordResumed = parameters.recordResumed;
    bool recordStopped = parameters.recordStopped;
    bool recordPaused = parameters.recordPaused;
    String recordingMediaOptions = parameters.recordingMediaOptions;
    bool videoAlreadyOn = parameters.videoAlreadyOn;
    String userDefaultVideoInputDevice = parameters.userDefaultVideoInputDevice;
    String defVideoID = parameters.defVideoID;
    bool allowed = parameters.allowed;

    // Callback functions to update state
    final void Function(String) updateDefVideoID = parameters.updateDefVideoID;
    final void Function(String) updatePrevVideoInputDevice =
        parameters.updatePrevVideoInputDevice;
    final void Function(String) updateUserDefaultVideoInputDevice =
        parameters.updateUserDefaultVideoInputDevice;
    final void Function(bool) updateIsMediaSettingsModalVisible =
        parameters.updateIsMediaSettingsModalVisible;

    // mediasfu function to switch user video
    final SwitchUserVideoType switchUserVideo = parameters.switchUserVideo;

    // Optional alert function
    final ShowAlert? showAlert = parameters.showAlert;

    // Check if recording is in progress and whether the selected video device is the default one
    bool checkoff = false;
    if ((recordStarted || recordResumed) && !recordStopped && !recordPaused) {
      if (recordingMediaOptions == "video") {
        checkoff = true;
      }
    }

    // Check camera access permission
    if (!allowed) {
      showAlert?.call(
        message:
            "Allow access to your camera by starting it for the first time.",
        type: "danger",
        duration: 3000,
      );
      return;
    }

    // Check video state and display appropriate alert messages
    if (checkoff) {
      if (videoAlreadyOn) {
        showAlert?.call(
          message: "Please turn off your video before switching.",
          type: "danger",
          duration: 3000,
        );
        return;
      }
    } else {
      if (!videoAlreadyOn) {
        showAlert?.call(
          message: "Please turn on your video before switching.",
          type: "danger",
          duration: 3000,
        );
        return;
      }
    }

    // Set default video ID if not already set
    if (defVideoID.isEmpty) {
      defVideoID = userDefaultVideoInputDevice.isNotEmpty
          ? userDefaultVideoInputDevice
          : "default";
      updateDefVideoID(defVideoID);
    }

    // Switch video only if the selected video device is different from the default
    if (options.videoPreference != defVideoID) {
      // Update previous video input device
      String prevVideoInputDevice = userDefaultVideoInputDevice;
      updatePrevVideoInputDevice(prevVideoInputDevice);

      // Update current video input device
      userDefaultVideoInputDevice = options.videoPreference;
      updateUserDefaultVideoInputDevice(userDefaultVideoInputDevice);

      // Hide media settings modal if visible
      updateIsMediaSettingsModalVisible(false);

      // Perform the video switch using the mediasfu function
      final optionsSwitch = SwitchUserVideoOptions(
        parameters: parameters,
        videoPreference: options.videoPreference,
        checkoff: checkoff,
      );
      await switchUserVideo(
        optionsSwitch,
      );
    }
  } catch (error) {
    if (kDebugMode) {
      print('switchVideo error: $error');
    }
  }
}
