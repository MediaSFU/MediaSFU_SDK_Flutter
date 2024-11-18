import '../../types/types.dart'
    show SwitchUserAudioParameters, SwitchUserAudioType, SwitchUserAudioOptions;

abstract class SwitchAudioParameters implements SwitchUserAudioParameters {
  // Core properties as abstract getters
  String get defAudioID;
  String get userDefaultAudioInputDevice;
  String get prevAudioInputDevice;

  // Update functions as abstract getters
  void Function(String) get updateUserDefaultAudioInputDevice;
  void Function(String) get updatePrevAudioInputDevice;

  // Mediasfu function as an abstract getter
  SwitchUserAudioType get switchUserAudio;

  // Method to retrieve updated parameters as an abstract getter
  SwitchAudioParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Options for switching the audio input device.
class SwitchAudioOptions {
  final String audioPreference;
  final SwitchAudioParameters parameters;

  SwitchAudioOptions({
    required this.audioPreference,
    required this.parameters,
  });
}

typedef SwitchAudioType = Future<void> Function(SwitchAudioOptions options);

/// Switches the audio input device based on user preference.
///
/// This function updates the user's default audio input device and the previous audio input device.
/// It also calls the [switchUserAudio] function to perform the actual audio device switching.
/// If the [audioPreference] is the same as the default audio ID, no switching is performed.
///
/// ### Parameters:
/// - [options] (`SwitchAudioOptions`): Contains the `audioPreference` and `parameters` required for switching audio.
///
/// ### Example:
/// ```dart
/// final switchAudioOptions = SwitchAudioOptions(
///   audioPreference: "newAudioDeviceID",
///   parameters: SwitchAudioParameters(
///     defAudioID: "defaultAudioDeviceID",
///     userDefaultAudioInputDevice: "currentAudioDeviceID",
///     prevAudioInputDevice: "previousAudioDeviceID",
///     updateUserDefaultAudioInputDevice: (deviceId) => setUserDefaultAudio(deviceId),
///     updatePrevAudioInputDevice: (deviceId) => setPrevAudioDevice(deviceId),
///     switchUserAudio: switchUserAudioFunction,
///   ),
/// );
///
/// await switchAudio(switchAudioOptions);
/// ```

Future<void> switchAudio(SwitchAudioOptions options) async {
  final parameters = options.parameters.getUpdatedAllParams();

  String defAudioID = parameters.defAudioID;
  String userDefaultAudioInputDevice = parameters.userDefaultAudioInputDevice;
  String prevAudioInputDevice = parameters.prevAudioInputDevice;
  final void Function(String) updateUserDefaultAudioInputDevice =
      parameters.updateUserDefaultAudioInputDevice;
  final void Function(String) updatePrevAudioInputDevice =
      parameters.updatePrevAudioInputDevice;

  // mediasfu functions
  final SwitchUserAudioType switchUserAudio = parameters.switchUserAudio;

  if (options.audioPreference != defAudioID) {
    // Update previous audio input device
    prevAudioInputDevice = userDefaultAudioInputDevice;
    updatePrevAudioInputDevice(prevAudioInputDevice);

    // Update current audio input device
    userDefaultAudioInputDevice = options.audioPreference;
    updateUserDefaultAudioInputDevice(userDefaultAudioInputDevice);

    // Perform the audio switch
    if (defAudioID.isNotEmpty) {
      final optionsSwitch = SwitchUserAudioOptions(
        parameters: parameters,
        audioPreference: options.audioPreference,
      );
      await switchUserAudio(
        options: optionsSwitch,
      );
    }
  }
}
