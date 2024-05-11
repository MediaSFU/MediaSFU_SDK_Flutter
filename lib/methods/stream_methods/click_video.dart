import 'dart:async';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// This function handles the click event for the video button.
/// It takes in a map of parameters that control various settings and behaviors.
/// The function performs actions based on the provided parameters, such as turning on/off the camera, sending a request to the host, and handling permission checks.
/// It also utilizes several callback functions for updating the UI and interacting with the mediasoup library.
///
/// Parameters:
/// - `parameters`: A map of parameters that control the behavior of the function. It includes the following keys:
///   - `checkMediaPermission` (bool): Whether to check for media permissions before turning on the camera. Default is `false`.
///   - `hasCameraPermission` (bool): Whether the user has camera permission. Default is `false`.
///   - `videoAlreadyOn` (bool): Whether the video is already turned on. Default is `false`.
///   - `audioOnlyRoom` (bool): Whether the room is audio-only. Default is `false`.
///   - `recordStarted` (bool): Whether the recording has started. Default is `false`.
///   - `recordResumed` (bool): Whether the recording has been resumed. Default is `false`.
///   - `recordPaused` (bool): Whether the recording has been paused. Default is `false`.
///   - `recordStopped` (bool): Whether the recording has been stopped. Default is `false`.
///   - `recordingMediaOptions` (String): The recording media options. Default is an empty string.
///   - `islevel` (String): The level of the user. Default is `'1'`.
///   - `youAreCoHost` (bool): Whether the user is a co-host. Default is `false`.
///   - `adminRestrictSetting` (bool): Whether the host has restricted camera access. Default is `false`.
///   - `videoRequestState` (String): The state of the video request. Default is an empty string.
///   - `videoRequestTime` (DateTime?): The time when the video request was made. Default is `null`.
///   - `member` (String): The name of the member. Default is an empty string.
///   - `socket` (io.Socket?): The socket for communication. Default is `null`.
///   - `roomName` (String): The name of the room. Default is an empty string.
///   - `userDefaultVideoInputDevice` (String?): The default video input device for the user. Default is `null`.
///   - `currentFacingMode` (String): The current facing mode of the camera. Default is `'user'`.
///   - `vidCons` (Map<String, dynamic>): The video constraints for the camera. Default is an empty map.
///   - `frameRate` (int): The desired frame rate for the camera. Default is `5`.
///   - `videoAction` (bool): Whether a video action is allowed. Default is `false`.
///   - `localStream` (dynamic): The local media stream. Default is `null`.
///   - `audioSetting` (String): The audio setting for the user. Default is `'allow'`.
///   - `videoSetting` (String): The video setting for the user. Default is `'allow'`.
///   - `screenshareSetting` (String): The screenshare setting for the user. Default is `'allow'`.
///   - `chatSetting` (String): The chat setting for the user. Default is `'allow'`.
///   - `updateRequestIntervalSeconds` (int): The interval in seconds for updating the request. Default is `240`.
///   - `streamSuccessVideo` (StreamSuccessVideo): The callback function for handling successful video streaming. Default is `null`.
///   - `showAlert` (ShowAlert?): The callback function for showing alerts. Default is `null`.
///   - `updateVideoAlreadyOn` (UpdateVideoAlreadyOn): The callback function for updating the video already on state. Default is `null`.
///   - `updateVideoRequestState` (UpdateVideoRequestState): The callback function for updating the video request state. Default is `null`.
///   - `updateLocalStream` (UpdateLocalStream): The callback function for updating the local media stream. Default is `null`.
///   - `disconnectSendTransportVideo` (DisconnectSendTransportVideo): The function for disconnecting the send transport for video. Default is `null`.
///   - `requestPermissionCamera` (RequestPermissionCamera): The function for requesting camera permission. Default is `null`.
///   - `checkPermission` (CheckPermission): The function for checking permission. Default is `null`.
///
/// Returns: A `Future` that completes when the function finishes its execution.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef StreamSuccessVideo = Future<void> Function(
    {required MediaStream stream, required Map<String, dynamic> parameters});

typedef RequestPermissionCamera = Future<bool> Function();

typedef DisconnectSendTransportVideo = Future<void> Function({
  required Map<String, dynamic> parameters,
});

typedef CheckPermission = Future<int> Function({
  required String permissionType,
  required Map<String, dynamic> parameters,
});

typedef UpdateVideoRequestState = void Function(String value);
typedef UpdateVideoRequestTime = void Function(DateTime value);
typedef UpdateLocalStream = void Function(dynamic value);
typedef UpdateLocalStreamVideo = void Function(dynamic value);
typedef UpdateVideoAlreadyOn = void Function(bool value);

Future<void> clickVideo({required Map<String, dynamic> parameters}) async {
  bool checkMediaPermission = parameters['checkMediaPermission'] ?? false;
  bool hasCameraPermission = parameters['hasCameraPermission'] ?? false;
  bool videoAlreadyOn = parameters['videoAlreadyOn'] ?? false;
  bool audioOnlyRoom = parameters['audioOnlyRoom'] ?? false;
  bool recordStarted = parameters['recordStarted'] ?? false;
  bool recordResumed = parameters['recordResumed'] ?? false;
  bool recordPaused = parameters['recordPaused'] ?? false;
  bool recordStopped = parameters['recordStopped'] ?? false;
  String recordingMediaOptions = parameters['recordingMediaOptions'] ?? '';
  String islevel = parameters['islevel'] ?? '1';
  bool youAreCoHost = parameters['youAreCoHost'] ?? false;
  bool adminRestrictSetting = parameters['adminRestrictSetting'] ?? false;
  String videoRequestState = parameters['videoRequestState'] ?? '';
  DateTime? videoRequestTime = parameters['videoRequestTime'];
  String member = parameters['member'] ?? '';
  io.Socket? socket = parameters['socket'];
  String roomName = parameters['roomName'] ?? '';
  String? userDefaultVideoInputDevice =
      parameters['userDefaultVideoInputDevice'] ?? '';
  String currentFacingMode = parameters['currentFacingMode'] ?? 'user';
  Map<String, dynamic>? vidCons = parameters['vidCons'] ?? {};
  int frameRate = parameters['frameRate'] ?? 5;
  bool videoAction = parameters['videoAction'] ?? false;
  dynamic localStream = parameters['localStream']; // MediaStream
  String audioSetting = parameters['audioSetting'] ?? 'allow';
  String videoSetting = parameters['videoSetting'] ?? 'allow';
  String screenshareSetting = parameters['screenshareSetting'] ?? 'allow';
  String chatSetting = parameters['chatSetting'] ?? 'allow';
  int updateRequestIntervalSeconds =
      parameters['updateRequestIntervalSeconds'] ?? 240;
  StreamSuccessVideo streamSuccessVideo = parameters['streamSuccessVideo'];
  ShowAlert? showAlert = parameters['showAlert'];
  UpdateVideoAlreadyOn updateVideoAlreadyOn =
      parameters['updateVideoAlreadyOn'];
  UpdateVideoRequestState updateVideoRequestState =
      parameters['updateVideoRequestState'];
  UpdateLocalStream updateLocalStream = parameters['updateLocalStream'];

  // mediasfu functions
  DisconnectSendTransportVideo disconnectSendTransportVideo =
      parameters['disconnectSendTransportVideo'];
  RequestPermissionCamera requestPermissionCamera =
      parameters['requestPermissionCamera'];
  CheckPermission checkPermission = parameters['checkPermission'];

  if (audioOnlyRoom) {
    if (showAlert != null) {
      showAlert(
        message: 'You cannot turn on your camera in an audio only event.',
        type: 'danger',
        duration: 3000,
      );
    }
    return;
  }

  if (videoAlreadyOn) {
    if (islevel == '2' && (recordStarted || recordResumed)) {
      if (!(recordPaused || recordStopped)) {
        if (recordingMediaOptions == 'video') {
          if (showAlert != null) {
            showAlert(
              message:
                  'You cannot turn off your camera while recording video, please pause or stop recording first.',
              type: 'danger',
              duration: 3000,
            );
          }
          return;
        }
      }
    }

    videoAlreadyOn = false;
    updateVideoAlreadyOn(videoAlreadyOn);
    localStream.getVideoTracks()[0].enabled = false;
    updateLocalStream(localStream);
    await disconnectSendTransportVideo(parameters: parameters);
  } else {
    if (adminRestrictSetting) {
      if (showAlert != null) {
        showAlert(
          message: 'You cannot turn on your camera. Access denied by host.',
          duration: 3000,
          type: 'danger',
        );
      }
      return;
    }

    int response = 2;

    if (videoAction == false && islevel != '2' && !youAreCoHost) {
      response = await checkPermission(
        permissionType: 'videoSetting',
        parameters: {
          'audioSetting': audioSetting,
          'videoSetting': videoSetting,
          'screenshareSetting': screenshareSetting,
          'chatSetting': chatSetting
        },
      );
    } else {
      response = 0;
    }

    if (response == 1) {
      if (videoRequestState == 'pending') {
        if (showAlert != null) {
          showAlert(
            message:
                'A request is pending. Please wait for the host to respond.',
            type: 'danger',
            duration: 3000,
          );
        }
        return;
      }

      if (videoRequestState == 'rejected' &&
          (DateTime.now().millisecondsSinceEpoch -
                  videoRequestTime!.millisecondsSinceEpoch) <
              updateRequestIntervalSeconds) {
        if (showAlert != null) {
          showAlert(
            message:
                'A request was rejected. Please wait for $updateRequestIntervalSeconds seconds before sending another request.',
            type: 'danger',
            duration: 3000,
          );
        }
        return;
      }

      if (showAlert != null) {
        showAlert(
          message: 'Request sent to host.',
          type: 'success',
          duration: 3000,
        );
      }
      videoRequestState = 'pending';
      updateVideoRequestState(videoRequestState);

      Map<String, dynamic> userRequest = {
        'id': socket!.id,
        'name': member,
        'icon': 'fa-video'
      };
      socket.emit('participantRequest',
          {'userRequest': userRequest, 'roomName': roomName});
    } else if (response == 2) {
      if (showAlert != null) {
        showAlert(
          message: 'You cannot turn on your camera. Access denied by host.',
          type: 'danger',
          duration: 3000,
        );
      }
    } else {
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

      Map<String, dynamic> mediaConstraints = {};
      Map<String, dynamic> altMediaConstraints = {};
      if (userDefaultVideoInputDevice!.isNotEmpty) {
        if (vidCons != null &&
            vidCons['width'] != null &&
            vidCons['height'] != null) {
          mediaConstraints = {
            'video': {
              'mandatory': {
                'sourceId': userDefaultVideoInputDevice,
                'facingMode': currentFacingMode,
                'width': vidCons['width'],
                'height': vidCons['height'],
                'frameRate': {'ideal': frameRate}
              }
            },
            'audio': false
          };
          altMediaConstraints = {
            'video': {
              'mandatory': {
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
                'width': vidCons!['width'],
                'height': vidCons['height'],
                'frameRate': {'ideal': frameRate}
              }
            },
            'audio': false
          };
          altMediaConstraints = {
            'video': {
              'mandatory': {
                'frameRate': {'ideal': frameRate}
              }
            },
            'audio': false
          };
        }
      } else {
        if (vidCons != null &&
            vidCons['width'] != null &&
            vidCons['height'] != null) {
          mediaConstraints = {
            'video': {
              'mandatory': {
                'width': vidCons['width'],
                'height': vidCons['height'],
                'frameRate': {'ideal': frameRate}
              }
            },
            'audio': false
          };
          altMediaConstraints = {
            'video': {
              'mandatory': {
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
                'frameRate': {'ideal': frameRate}
              }
            },
            'audio': false
          };
        }
      }
      try {
        await navigator.mediaDevices
            .getUserMedia(mediaConstraints)
            .then((stream) async {
          await streamSuccessVideo(stream: stream, parameters: {
            ...parameters,
            'mediaConstraints': mediaConstraints
          });
        });
      } catch (error) {
        try {
          await navigator.mediaDevices
              .getUserMedia(altMediaConstraints)
              .then((stream) async {
            await streamSuccessVideo(stream: stream, parameters: {
              ...parameters,
              'mediaConstraints': altMediaConstraints
            });
          });
        } catch (error) {
          if (showAlert != null) {
            showAlert(
              message:
                  'Allow access to your camera or check if your camera is not being used by another application.',
              type: 'danger',
              duration: 3000,
            );
          }
        }
      }
    }
  }
}
