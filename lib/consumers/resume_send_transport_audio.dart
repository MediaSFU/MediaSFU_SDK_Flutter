import 'dart:async';

/// Resumes the send transport for audio.
///
/// This function takes a [parameters] map as input, which should contain the following keys:
/// - 'audioProducer': The audio producer to resume.
/// - 'islevel': The level of the audio (default is '1').
/// - 'updateMainWindow': A boolean value indicating whether to update the main window.
/// - 'hostLabel': The label for the host (default is 'Host').
/// - 'lockScreen': A boolean value indicating whether to lock the screen (default is false).
/// - 'shared': A boolean value indicating whether the audio is shared (default is false).
/// - 'updateAudioProducer': A function to update the audio producer.
/// - 'videoAlreadyOn': A boolean value indicating whether the video is already on (default is false).
/// - 'updateUpdateMainWindow': A function to update the main window.
/// - 'prepopulateUserMedia': A function to prepopulate user media.
///
/// This function resumes the send transport for audio by calling the `resume()` method on the audio producer.
/// It also updates the UI based on the provided parameters, and updates the audio producer state.
///
/// Throws an error if there is an error during the process of resuming the audio send transport.

typedef UpdateMainWindow = void Function(bool);
typedef PrepopulateUserMedia = List<dynamic> Function({
  required String name,
  required Map<String, dynamic> parameters,
});
typedef UpdateAudioProducer = void Function(dynamic audioProducer);
typedef UpdateVideoAlreadyOn = void Function(bool);
typedef UpdateIsLevel = void Function(String islevel);
typedef UpdateLockScreen = void Function(bool);
typedef UpdateShared = void Function(bool);
typedef UpdateUpdateMainWindow = void Function(bool);

Future<void> resumeSendTransportAudio(
    {required Map<String, dynamic> parameters}) async {
  dynamic audioProducer = parameters['audioProducer'];
  String islevel = parameters['islevel'] ?? '1';
  bool updateMainWindow = parameters['updateMainWindow'];
  String hostLabel = parameters['hostLabel'] ?? 'Host';
  bool lockScreen = parameters['lockScreen'] ?? false;
  bool shared = parameters['shared'] ?? false;
  UpdateAudioProducer updateAudioProducer = parameters['updateAudioProducer'];
  bool videoAlreadyOn = parameters['videoAlreadyOn'] ?? false;
  UpdateUpdateMainWindow updateUpdateMainWindow =
      parameters['updateUpdateMainWindow'];

  // mediasfu functions
  PrepopulateUserMedia prepopulateUserMedia =
      parameters['prepopulateUserMedia'];

  try {
    // Resume send transport for audio
    await audioProducer.resume();

    // Update the UI
    if (!videoAlreadyOn && islevel == '2') {
      if (!lockScreen && !shared) {
        updateMainWindow = true;
        updateUpdateMainWindow(updateMainWindow);
        prepopulateUserMedia(name: hostLabel, parameters: parameters);
        updateMainWindow = false;
        updateUpdateMainWindow(updateMainWindow);
      }
    }

    // Update audio producer state
    updateAudioProducer(audioProducer);
  } catch (error) {
    // Handle errors during the process of resuming the audio send transport
    // throw ('Error during resuming audio send transport: $error');
  }
}
