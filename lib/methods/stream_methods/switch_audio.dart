typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

/// Function to switch the user's audio device.
///
/// The [audioPreference] parameter represents the preferred audio device to switch to.
/// The [parameters] parameter represents the parameters required for switching the audio device.
///
/// This function updates the user's default audio input device and the previous audio input device.
/// It also calls the [switchUserAudio] function to perform the actual audio device switching.
/// If the [audioPreference] is the same as the default audio ID, no switching is performed.

typedef SwitchUserAudio = Function(
    {required Map<String, dynamic> parameters,
    required String audioPreference});
// Function to switch the user's audio device

void switchAudio(
    {required String audioPreference,
    required Map<String, dynamic> parameters}) async {
  String? defAudioID = parameters['defAudioID'];
  String? userDefaultAudioInputDevice =
      parameters['userDefaultAudioInputDevice'];
  String? prevAudioInputDevice = parameters['prevAudioInputDevice'];
  Function(String)? updateUserDefaultAudioInputDevice =
      parameters['updateUserDefaultAudioInputDevice'];
  Function(String)? updatePrevAudioInputDevice =
      parameters['updatePrevAudioInputDevice'];

  //mediasfu functions
  SwitchUserAudio switchUserAudio = parameters['switchUserAudio'];

  if (audioPreference != defAudioID) {
    prevAudioInputDevice = userDefaultAudioInputDevice;
    updatePrevAudioInputDevice!(prevAudioInputDevice!);

    userDefaultAudioInputDevice = audioPreference;
    updateUserDefaultAudioInputDevice!(userDefaultAudioInputDevice);

    if (defAudioID != null) {
      await switchUserAudio(
        audioPreference: audioPreference,
        parameters: parameters,
      );
    }
  }
}
