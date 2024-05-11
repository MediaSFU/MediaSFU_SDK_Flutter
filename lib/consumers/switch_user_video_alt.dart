import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../methods/stream_methods/click_video.dart' show clickVideo;

/// Switches the user's video based on the given parameters.
///
/// The [parameters] map should contain the following keys:
/// - 'audioOnlyRoom': A boolean indicating whether the room is audio-only.
/// - 'frameRate': An integer representing the desired frame rate.
/// - 'vidCons': A dynamic value representing video constraints.
/// - 'showAlert': An optional function to show an alert message.
/// - 'hasCameraPermission': A boolean indicating whether the camera permission is granted.
/// - 'updateVideoSwitching': A function to update the video switching state.
/// - 'updateCurrentFacingMode': A function to update the current facing mode.
/// - 'checkMediaPermission': A boolean indicating whether to check media permission.
/// - 'currentFacingMode': A string representing the current facing mode.
/// - 'prevFacingMode': A string representing the previous facing mode.
/// - 'requestPermissionCamera': A function to request camera permission.
/// - 'streamSuccessVideo': A function to handle successful video streaming.
/// - 'sleep': A function to pause execution for a specified duration.
///
/// Throws an error if there is an issue with switching the video.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef UpdateCurrentFacingMode = void Function(String value);
typedef RequestPermissionCamera = Future<bool> Function();
typedef StreamSuccessVideo = Future<void> Function(
    {required MediaStream stream, required Map<String, dynamic> parameters});
typedef Sleep = Future<void> Function(int milliseconds);
typedef SwitchUserVideoAlt = Future<void> Function(
    {required Map<String, dynamic> parameters});
typedef UpdateVideoSwitching = void Function(bool value);

typedef ClickVideo = Future<void> Function(
    Map<String, dynamic> options, Map<String, dynamic> parameters);

Future<void> switchUserVideoAlt(
    {required Map<String, dynamic> parameters}) async {
  bool audioOnlyRoom = parameters['audioOnlyRoom'];
  int frameRate = parameters['frameRate'];
  dynamic vidCons = parameters['vidCons'];
  ShowAlert? showAlert = parameters['showAlert'];
  bool hasCameraPermission = parameters['hasCameraPermission'];
  UpdateVideoSwitching updateVideoSwitching =
      parameters['updateVideoSwitching'];
  UpdateCurrentFacingMode updateCurrentFacingMode =
      parameters['updateCurrentFacingMode'];
  bool checkMediaPermission = parameters['checkMediaPermission'];

  String currentFacingMode = parameters['currentFacingMode'];
  String prevFacingMode = parameters['prevFacingMode'];

  //mediasfu functions
  RequestPermissionCamera requestPermissionCamera =
      parameters['requestPermissionCamera'];
  StreamSuccessVideo streamSuccessVideo = parameters['streamSuccessVideo'];
  Sleep sleep = parameters['sleep'];

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

    if (!parameters['checkoff']) {
      await clickVideo(parameters: parameters);

      updateVideoSwitching(true);
      sleep(500);
      updateVideoSwitching(false);
    }

    if (!hasCameraPermission) {
      if (checkMediaPermission) {
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

    List<MediaDeviceInfo> videoDevices =
        await navigator.mediaDevices.enumerateDevices();

    dynamic mediaConstraints = {};

    if (vidCons != null &&
        vidCons['width'] != null &&
        vidCons['height'] != null) {
      mediaConstraints = {
        'video': {
          'mandatory': {
            'width': vidCons['width'],
            'height': vidCons['height'],
            'frameRate': {'ideal': frameRate}
          },
          'facingMode': parameters['videoPreference']
        },
        'audio': false
      };
    } else {
      mediaConstraints = {
        'video': {
          'mandatory': {
            'frameRate': {'ideal': frameRate}
          },
          'facingMode': parameters['videoPreference']
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
      List<dynamic> videoDevicesFront = [];

      if (parameters['videoPreference'] == 'user') {
        videoDevicesFront = videoDevices
            .where((device) =>
                device.label.contains('front') && device.kind == 'videoinput')
            .toList();
      } else {
        videoDevicesFront = videoDevices
            .where((device) =>
                device.label.contains('back') && device.kind == 'videoinput')
            .toList();
      }

      if (videoDevicesFront.isNotEmpty) {
        for (MediaDeviceInfo device in videoDevicesFront) {
          if (device.kind == 'videoinput') {
            String videoDeviceId = device.deviceId;

            if (vidCons != null &&
                vidCons['width'] != null &&
                vidCons['height'] != null) {
              mediaConstraints = {
                'video': {
                  'mandatory': {
                    'sourceId': videoDeviceId,
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
                    'sourceId': videoDeviceId,
                    'frameRate': {'ideal': frameRate}
                  }
                },
                'audio': false
              };
            }

            await navigator.mediaDevices
                .getUserMedia(mediaConstraints)
                .then((stream) async {
              await streamSuccessVideo(stream: stream, parameters: {
                ...parameters,
                'mediaConstraints': mediaConstraints
              });
            }).catchError((error) {
              if (videoDeviceId == videoDevicesFront.last['deviceId']) {
                currentFacingMode = prevFacingMode;
                updateCurrentFacingMode(currentFacingMode);
                if (showAlert != null) {
                  showAlert(
                    message:
                        'Error switching; not accessible, might need to turn off your video and turn it back on after switching.',
                    type: 'danger',
                    duration: 3000,
                  );
                }
              }
            });
          }
        }
      } else {
        currentFacingMode = prevFacingMode;
        updateCurrentFacingMode(currentFacingMode);
        if (showAlert != null) {
          showAlert(
            message:
                'Error switching; not accessible, might need to turn off your video and turn it back on after switching.',
            type: 'danger',
            duration: 3000,
          );
        }
      }
    });
  } catch (error) {
    List<MediaDeviceInfo> videoDevices =
        await navigator.mediaDevices.enumerateDevices();

    List<dynamic> videoDevicesFront = [];

    if (parameters['videoPreference'] == 'user') {
      videoDevicesFront = videoDevices
          .where((device) =>
              device.label.contains('front') && device.kind == 'videoinput')
          .toList();
    } else {
      videoDevicesFront = videoDevices
          .where((device) =>
              device.label.contains('back') && device.kind == 'videoinput')
          .toList();
    }

    dynamic mediaConstraints = {};

    if (videoDevicesFront.isNotEmpty) {
      for (MediaDeviceInfo device in videoDevicesFront) {
        if (device.kind == 'videoinput') {
          String videoDeviceId = device.deviceId;

          if (vidCons != null &&
              vidCons['width'] != null &&
              vidCons['height'] != null) {
            mediaConstraints = {
              'video': {
                'mandatory': {
                  'sourceId': videoDeviceId,
                  'width': vidCons['width'],
                  'height': vidCons['height'],
                  'frameRate': {'ideal': frameRate}
                },
              },
              'audio': false
            };
          } else {
            mediaConstraints = {
              'video': {
                'mandatory': {
                  'sourceId': videoDeviceId,
                  'frameRate': {'ideal': frameRate}
                },
              },
              'audio': false
            };
          }

          await navigator.mediaDevices
              .getUserMedia(mediaConstraints)
              .then((stream) async {
            await streamSuccessVideo(stream: stream, parameters: {
              ...parameters,
              'mediaConstraints': mediaConstraints
            });
          }).catchError((error) {
            if (videoDeviceId == videoDevicesFront.last['deviceId']) {
              currentFacingMode = prevFacingMode;
              updateCurrentFacingMode(currentFacingMode);
              if (showAlert != null) {
                showAlert(
                  message:
                      'Error switching; not accessible, might need to turn off your video and turn it back on after switching.',
                  type: 'danger',
                  duration: 3000,
                );
              }
            }
          });
        }
      }
    } else {
      currentFacingMode = prevFacingMode;
      updateCurrentFacingMode(currentFacingMode);
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
}
