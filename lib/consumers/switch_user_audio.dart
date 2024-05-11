import 'dart:async';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';

/// Switches the user's audio device based on the provided parameters.
///
/// The [parameters] map should contain the following keys:
/// - 'userDefaultAudioInputDevice': The user's default audio input device.
/// - 'prevAudioInputDevice': The previous audio input device.
/// - 'showAlert': A function to show an alert message.
/// - 'hasAudioPermission': A boolean indicating if the user has audio permission.
/// - 'updateUserDefaultAudioInputDevice': A function to update the user's default audio input device.
/// - 'checkMediaPermission': A boolean indicating if media permission should be checked.
/// - 'streamSuccessAudioSwitch': A function to switch the audio stream.
/// - 'requestPermissionAudio': A function to request audio permission.
///
/// The [audioPreference] parameter specifies the preferred audio input device.
///
/// Throws an error if there is an issue switching the audio device.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef StreamSuccessAudioSwitch = Future<void> Function(
    {required MediaStream stream, required Map<String, dynamic> parameters});

typedef Sleep = Future<void> Function(int milliseconds);

typedef RequestPermissionAudio = Future<bool> Function();

typedef UpdateDevice = void Function(String value);

Future<void> switchUserAudio(
    {required Map<String, dynamic> parameters,
    required String audioPreference}) async {
  // Function to switch the user's audio device

  try {
    String userDefaultAudioInputDevice =
        parameters['userDefaultAudioInputDevice'];
    String prevAudioInputDevice = parameters['prevAudioInputDevice'];
    ShowAlert? showAlert = parameters['showAlert'];
    bool hasAudioPermission = parameters['hasAudioPermission'];
    UpdateDevice updateUserDefaultAudioInputDevice =
        parameters['updateUserDefaultAudioInputDevice'];
    bool checkMediaPermission = parameters['checkMediaPermission'];

    // Media functions
    StreamSuccessAudioSwitch streamSuccessAudioSwitch =
        parameters['streamSuccessAudioSwitch'];
    RequestPermissionAudio requestPermissionAudio =
        parameters['requestPermissionAudio'];

    // Check if audio permission is granted
    if (!hasAudioPermission) {
      if (checkMediaPermission) {
        var statusMic = await requestPermissionAudio();
        if (statusMic != true) {
          if (showAlert != null) {
            showAlert(
              message:
                  'Allow access to your microphone or check if your microphone is not being used by another application.',
              type: 'danger',
              duration: 3000,
            );
          }
          return;
        }
      }
    }

    Map<String, dynamic> mediaConstraints = {
      'audio': {
        'optional': [
          {
            'sourceId': audioPreference,
          }
        ],
      },
      'video': false,
    };

    // Get user media with the defined audio constraints
    await navigator.mediaDevices
        .getUserMedia(mediaConstraints)
        .then((stream) async {
      await streamSuccessAudioSwitch(
          stream: stream,
          parameters: {...parameters, 'audioConstraints': mediaConstraints});
    }).catchError((error) {
      // Handle errors and revert to the previous audio input device
      userDefaultAudioInputDevice = prevAudioInputDevice;
      updateUserDefaultAudioInputDevice(userDefaultAudioInputDevice);

      if (showAlert != null) {
        showAlert(
          message:
              'Error switching; the specified microphone could not be accessed.',
          type: 'danger',
          duration: 3000,
        );
      }
    });
  } catch (error) {
    // Handle unexpected errors and revert to the previous audio input device
    String userDefaultAudioInputDevice =
        parameters['userDefaultAudioInputDevice'];
    String prevAudioInputDevice = parameters['prevAudioInputDevice'];
    UpdateDevice updateUserDefaultAudioInputDevice =
        parameters['updateUserDefaultAudioInputDevice'];
    ShowAlert? showAlert = parameters['showAlert'];
    userDefaultAudioInputDevice = prevAudioInputDevice;
    updateUserDefaultAudioInputDevice(userDefaultAudioInputDevice);

    if (showAlert != null) {
      showAlert(
        message:
            'Error switching; the specified microphone could not be accessed.',
        type: 'danger',
        duration: 3000,
      );
    }
  }
}
