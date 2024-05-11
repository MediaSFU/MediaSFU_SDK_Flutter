import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../methods/stream_methods/click_video.dart' show clickVideo;

/// Switches the user's video based on the given parameters.
///
/// The [videoPreference] parameter specifies the video preference.
/// The [checkoff] parameter indicates whether the video is checked off.
/// The [parameters] parameter is a map that contains various parameters required for the video switching process.
///
/// The [audioOnlyRoom] parameter indicates whether the room is audio-only.
/// The [frameRate] parameter specifies the frame rate for the video.
/// The [vidCons] parameter is a map that contains video constraints.
/// The [prevVideoInputDevice] parameter specifies the previous video input device.
/// The [userDefaultVideoInputDevice] parameter specifies the user's default video input device.
/// The [showAlert] parameter is a function that shows an alert message.
/// The [hasCameraPermission] parameter indicates whether the camera permission is granted.
/// The [updateVideoSwitching] parameter is a function that updates the video switching status.
/// The [updateUserDefaultVideoInputDevice] parameter is a function that updates the user's default video input device.
///
/// The [requestPermissionCamera] parameter is a function that requests camera permission.
/// The [streamSuccessVideo] parameter is a function that handles successful video streaming.
/// The [sleep] parameter is a function that pauses the execution for a specified duration.
/// The [checkMediaPermission] parameter indicates whether to check media permission.
///
/// Throws an error if there is an issue with switching the video.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});
typedef GetUpdatedAllparameters = Map<String, dynamic> Function();
typedef UpdateCurrentFacingMode = void Function(String value);
typedef RequestPermissionCamera = Future<bool> Function();
typedef StreamSuccessVideo = Future<void> Function(
    {required MediaStream stream, required Map<String, dynamic> parameters});
typedef Sleep = Future<void> Function(int milliseconds);
typedef SwitchUserVideoAlt = Future<void> Function(
    {required Map<String, dynamic> parameters});
typedef UpdateVideoSwitching = void Function(bool value);
typedef UpdateUserDefaultVideoInputDevice = void Function(String value);

Future<void> switchUserVideo(
    {required String videoPreference,
    required bool checkoff,
    required Map<String, dynamic> parameters}) async {
  bool audioOnlyRoom = parameters['audioOnlyRoom'] ?? false;
  int frameRate = parameters['frameRate'];
  Map<String, dynamic>? vidCons = parameters['vidCons'];
  String prevVideoInputDevice = parameters['prevVideoInputDevice'];
  String userDefaultVideoInputDevice =
      parameters['userDefaultVideoInputDevice'];
  ShowAlert? showAlert = parameters['showAlert'];
  bool hasCameraPermission = parameters['hasCameraPermission'];
  UpdateVideoSwitching updateVideoSwitching =
      parameters['updateVideoSwitching'];
  UpdateUserDefaultVideoInputDevice updateUserDefaultVideoInputDevice =
      parameters['updateUserDefaultVideoInputDevice'];

  //mediasfu functions
  RequestPermissionCamera requestPermissionCamera =
      parameters['requestPermissionCamera'];
  StreamSuccessVideo streamSuccessVideo = parameters['streamSuccessVideo'];
  Sleep sleep = parameters['sleep'];
  bool checkMediaPermission = parameters['checkMediaPermission'];

  try {
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

    if (!checkoff) {
      await clickVideo(parameters: parameters);
      updateVideoSwitching(true);
      await sleep(500);
      updateVideoSwitching(false);
    }

    if (!hasCameraPermission) {
      if (checkMediaPermission == true) {
        bool statusCamera = await requestPermissionCamera();
        if (statusCamera != true) {
          if (showAlert != null) {
            showAlert(
              message:
                  'Allow access to your camera or check if your camera is not being used by another application.',
              type: 'danger',
              duration: 3000,
            );
          }
          return;
        }
      }
    }

    Map<String, dynamic> mediaConstraints = {};

    if (vidCons != null &&
        vidCons['width'] != null &&
        vidCons['height'] != null) {
      mediaConstraints = {
        'video': {
          'mandatory': {
            'sourceId': userDefaultVideoInputDevice,
            'width': vidCons['width'],
            'height': vidCons['height'],
            'frameRate': {'ideal': frameRate}
          }
        },
        'audio': false
      };
    } else {
      mediaConstraints = {
        'video': {
          'mandatory': {
            'sourceId': userDefaultVideoInputDevice,
            'frameRate': {'ideal': frameRate}
          }
        },
        'audio': false
      };
    }

    await navigator.mediaDevices
        .getUserMedia(mediaConstraints)
        .then((stream) async {
      await streamSuccessVideo(
          stream: stream,
          parameters: {...parameters, 'mediaConstraints': mediaConstraints});
    }).catchError((error) async {
      userDefaultVideoInputDevice = prevVideoInputDevice;
      updateUserDefaultVideoInputDevice(userDefaultVideoInputDevice);

      if (showAlert != null) {
        showAlert(
          message:
              'Error switching; not accessible, might need to turn off your video and turn it back on after switching.',
          type: 'danger',
          duration: 3000,
        );
      }
    });
  } catch (error) {
    userDefaultVideoInputDevice = prevVideoInputDevice;
    updateUserDefaultVideoInputDevice(userDefaultVideoInputDevice);

    if (showAlert != null) {
      showAlert(
        message:
            'Error switching; not accessible, might need to turn off your video and turn it back on after switching.',
        type: 'danger',
        duration: 3000,
      );
    }
  }
}
