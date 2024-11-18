import 'dart:async';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../types/types.dart'
    show
        ShowAlert,
        StreamSuccessAudioSwitchType,
        RequestPermissionAudioType,
        StreamSuccessAudioSwitchParameters,
        StreamSuccessAudioSwitchOptions;

abstract class SwitchUserAudioParameters
    implements StreamSuccessAudioSwitchParameters {
  // Core properties
  String get userDefaultAudioInputDevice;
  String get prevAudioInputDevice;
  ShowAlert? get showAlert;
  bool get hasAudioPermission;
  void Function(String) get updateUserDefaultAudioInputDevice;

  // Mediasfu functions
  StreamSuccessAudioSwitchType get streamSuccessAudioSwitch;
  RequestPermissionAudioType get requestPermissionAudio;
  bool get checkMediaPermission;

  // Dynamic access operator for additional properties
  // dynamic operator [](String key);
  // void operator []=(String key, dynamic value);
}

class SwitchUserAudioOptions {
  final SwitchUserAudioParameters parameters;
  final String audioPreference;
  final Map<String, dynamic>? audioConstraints;

  SwitchUserAudioOptions({
    required this.parameters,
    required this.audioPreference,
    this.audioConstraints,
  });
}

typedef SwitchUserAudioType = Future<void> Function({
  required SwitchUserAudioOptions options,
});

/// Switches the user's audio input to the specified device.
///
/// ### Parameters:
/// - `options` (`SwitchUserAudioOptions`): Contains:
///   - `parameters` (`SwitchUserAudioParameters`): Includes settings, callbacks, permissions, and device states.
///   - `audioPreference` (`String`): The ID of the new audio input device to switch to.
///
/// ### Workflow:
/// 1. **Permission Check**:
///    - Verifies if audio permissions are granted.
///    - If not, it prompts the user to allow microphone access.
///
/// 2. **Media Constraints Setup**:
///    - Configures `getUserMedia` constraints to select the desired `audioPreference` device.
///
/// 3. **Stream Retrieval and Switch**:
///    - Attempts to create a new audio stream with the specified device.
///    - Calls `streamSuccessAudioSwitch` to handle the switch in the application.
///
/// 4. **Error Handling and Fallback**:
///    - If accessing the device fails, it reverts to the previously used device and shows an alert.
///
/// ### Example Usage:
/// ```dart
/// final parameters = SwitchUserAudioParameters(
///   userDefaultAudioInputDevice: 'defaultDeviceID',
///   prevAudioInputDevice: 'oldDeviceID',
///   hasAudioPermission: true,
///   // Other properties and callbacks...
/// );
///
/// await switchUserAudio(
///   SwitchUserAudioOptions(
///     parameters: parameters,
///     audioPreference: 'newDeviceID',
///   ),
/// );
/// ```
///
/// ### Error Handling:
/// - If an error occurs during the switch, reverts to the previous device and shows an alert.

Future<void> switchUserAudio({
  required SwitchUserAudioOptions options,
}) async {
  final String audioPreference = options.audioPreference;
  final SwitchUserAudioParameters parameters = options.parameters;

  try {
    final String prevAudioInputDevice = parameters.prevAudioInputDevice;
    final bool hasAudioPermission = parameters.hasAudioPermission;
    final ShowAlert? showAlert = parameters.showAlert;
    final StreamSuccessAudioSwitchType streamSuccessAudioSwitch =
        parameters.streamSuccessAudioSwitch;
    final RequestPermissionAudioType requestPermissionAudio =
        parameters.requestPermissionAudio;
    final void Function(String) updateUserDefaultAudioInputDevice =
        parameters.updateUserDefaultAudioInputDevice;
    final bool checkMediaPermission = parameters.checkMediaPermission;

    // Check if audio permission is granted
    if (!hasAudioPermission) {
      if (checkMediaPermission) {
        bool permissionGranted = await requestPermissionAudio();
        if (!permissionGranted) {
          showAlert?.call(
            message:
                "Allow access to your microphone or check if your microphone is not being used by another application.",
            type: "danger",
            duration: 3000,
          );
          return;
        }
      }
    }

    // Define media constraints with the desired audio input device
    final MediaStreamConstraints mediaConstraints = MediaStreamConstraints(
      audio: {
        'optional': [
          {
            'sourceId': audioPreference,
          }
        ],
      },
      video: false,
    );

    // Attempt to get user media with the defined audio constraints
    try {
      MediaStream newAudioStream = await navigator.mediaDevices
          .getUserMedia(mediaConstraints as Map<String, dynamic>);
      final optionsSwitch = StreamSuccessAudioSwitchOptions(
        stream: newAudioStream,
        audioConstraints: options.audioConstraints,
        parameters: parameters,
      );
      await streamSuccessAudioSwitch(optionsSwitch);
    } catch (error) {
      // Revert to the previous audio input device
      updateUserDefaultAudioInputDevice.call(prevAudioInputDevice);

      showAlert?.call(
        message:
            "Error switching; the specified microphone could not be accessed.",
        type: "danger",
        duration: 3000,
      );
    }
  } catch (error) {
    String userDefaultAudioInputDevice = parameters.userDefaultAudioInputDevice;
    String prevAudioInputDevice = parameters.prevAudioInputDevice;
    void Function(String) updateUserDefaultAudioInputDevice =
        parameters.updateUserDefaultAudioInputDevice;
    ShowAlert? showAlert = parameters.showAlert;
    userDefaultAudioInputDevice = prevAudioInputDevice;
    updateUserDefaultAudioInputDevice(userDefaultAudioInputDevice);

    showAlert?.call(
      message:
          "Error switching; the specified microphone could not be accessed.",
      type: "danger",
      duration: 3000,
    );
  }
}
