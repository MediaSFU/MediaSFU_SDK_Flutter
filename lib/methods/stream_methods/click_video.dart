import 'dart:async';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart'
    show
        CheckPermissionType,
        DisconnectSendTransportVideoParameters,
        DisconnectSendTransportVideoType,
        RequestPermissionCameraType,
        ShowAlert,
        StreamSuccessVideoParameters,
        StreamSuccessVideoType,
        VidCons,
        DisconnectSendTransportVideoOptions,
        CheckPermissionOptions,
        StreamSuccessVideoOptions;

abstract class ClickVideoParameters
    implements
        DisconnectSendTransportVideoParameters,
        StreamSuccessVideoParameters {
  bool get checkMediaPermission;
  bool get hasCameraPermission;
  bool get videoAlreadyOn;
  bool get audioOnlyRoom;
  bool get recordStarted;
  bool get recordResumed;
  bool get recordPaused;
  bool get recordStopped;
  String get recordingMediaOptions;
  String get islevel;
  bool get youAreCoHost;
  bool get adminRestrictSetting;
  String? get videoRequestState;
  int? get videoRequestTime;
  String get member;
  io.Socket? get socket;
  String get roomName;
  String get userDefaultVideoInputDevice;
  String get currentFacingMode;
  VidCons get vidCons;
  int get frameRate;
  bool get videoAction;
  MediaStream? get localStream;
  String get audioSetting;
  String get videoSetting;
  String get screenshareSetting;
  String get chatSetting;
  int get updateRequestIntervalSeconds;

  ShowAlert? get showAlert;
  void Function(bool) get updateVideoAlreadyOn;
  void Function(String) get updateVideoRequestState;
  void Function(MediaStream?) get updateLocalStream;

  StreamSuccessVideoType get streamSuccessVideo;
  DisconnectSendTransportVideoType get disconnectSendTransportVideo;
  RequestPermissionCameraType get requestPermissionCamera;
  CheckPermissionType get checkPermission;

  ClickVideoParameters Function() get getUpdatedAllParams;

  //dynamic operator [](String key);
  //void operator []=(String key, dynamic value);
}

class ClickVideoOptions {
  final ClickVideoParameters parameters;

  ClickVideoOptions({required this.parameters});
}

typedef ClickVideoType = Future<void> Function(ClickVideoOptions options);

/// Toggles the video stream on or off based on the user's input and checks required permissions and constraints.
///
/// ### Parameters:
/// - `options` (`ClickVideoOptions`): Contains the parameters needed for toggling video, including:
///   - `checkMediaPermission`: Boolean to verify media permission.
///   - `hasCameraPermission`: Boolean indicating if camera permission is granted.
///   - `videoAlreadyOn`: Boolean to check if the video is already on.
///   - `audioOnlyRoom`: Boolean indicating if the room is audio-only.
///   - `recordStarted`, `recordResumed`, `recordPaused`, `recordStopped`: Flags for recording state.
///   - `recordingMediaOptions`: String defining the current recording mode ("video" or "audio").
///   - `islevel`: User level (e.g., host, co-host).
///   - `showAlert`: Optional function for displaying alerts.
///   - `vidCons`: Video constraints for video width, height, etc.
///   - `frameRate`: Preferred frame rate for video.
///   - `userDefaultVideoInputDevice`: The device ID of the user's preferred video input device.
///   - `currentFacingMode`: The facing mode for the camera (e.g., front or back).
///
/// ### Process:
/// 1. **Permission and Recording State Check**:
///    - Checks if the user is in an audio-only room or if video toggling conflicts with ongoing recording.
///
/// 2. **Video Turn Off**:
///    - If the video is already on, it disables the video tracks and disconnects the transport.
///
/// 3. **Video Turn On**:
///    - Checks for admin or co-host restrictions before proceeding.
///    - If permitted, requests camera access if not already granted, applies media constraints, and initiates the video stream.
///
/// ### Helper Functions:
/// - **_buildMediaConstraints**: Builds media constraints using device ID and other parameters.
/// - **_buildAltMediaConstraints**: Builds alternative media constraints when the preferred device is unavailable.
/// - **_buildFinalMediaConstraints**: Builds final media constraints for the video stream.
/// - **_attemptStream**: Attempts to initialize the video stream with the specified constraints.
///
/// ### Example Usage:
/// ```dart
/// final options = ClickVideoOptions(
///   parameters: ClickVideoParameters(
///     checkMediaPermission: true,
///     hasCameraPermission: false,
///     videoAlreadyOn: false,
///     audioOnlyRoom: false,
///     showAlert: (message, type, duration) => print('Alert: $message'),
///     vidCons: VidCons(width: 1280, height: 720),
///     frameRate: 30,
///     userDefaultVideoInputDevice: 'front',
///     currentFacingMode: 'user',
///   ),
/// );
///
/// await clickVideo(options);
/// ```
///
/// ### Error Handling:
/// - Handles permission issues by displaying alerts.
/// - Attempts to access alternative video devices if the preferred device is unavailable.
/// - Displays a message if camera access is denied or unavailable.

Future<void> clickVideo(ClickVideoOptions options) async {
  final parameters = options.parameters.getUpdatedAllParams();

  final checkMediaPermission = parameters.checkMediaPermission;
  final hasCameraPermission = parameters.hasCameraPermission;
  bool videoAlreadyOn = parameters.videoAlreadyOn;
  final audioOnlyRoom = parameters.audioOnlyRoom;
  final recordStarted = parameters.recordStarted;
  final recordResumed = parameters.recordResumed;
  final recordPaused = parameters.recordPaused;
  final recordStopped = parameters.recordStopped;
  final recordingMediaOptions = parameters.recordingMediaOptions;
  final islevel = parameters.islevel;
  final youAreCoHost = parameters.youAreCoHost;
  final adminRestrictSetting = parameters.adminRestrictSetting;
  final videoRequestState = parameters.videoRequestState;
  final videoRequestTime = parameters.videoRequestTime;
  final member = parameters.member;
  final socket = parameters.socket;
  final roomName = parameters.roomName;
  final userDefaultVideoInputDevice = parameters.userDefaultVideoInputDevice;
  final currentFacingMode = parameters.currentFacingMode;
  final vidCons = parameters.vidCons;
  final frameRate = parameters.frameRate;
  final videoAction = parameters.videoAction;
  var localStream = parameters.localStream;
  final audioSetting = parameters.audioSetting;
  final videoSetting = parameters.videoSetting;
  final screenshareSetting = parameters.screenshareSetting;
  final chatSetting = parameters.chatSetting;
  final updateRequestIntervalSeconds = parameters.updateRequestIntervalSeconds;
  final streamSuccessVideo = parameters.streamSuccessVideo;
  final showAlert = parameters.showAlert;
  final updateVideoAlreadyOn = parameters.updateVideoAlreadyOn;
  final updateVideoRequestState = parameters.updateVideoRequestState;
  final updateLocalStream = parameters.updateLocalStream;

  final disconnectSendTransportVideo = parameters.disconnectSendTransportVideo;
  final requestPermissionCamera = parameters.requestPermissionCamera;
  final checkPermission = parameters.checkPermission;

  if (audioOnlyRoom) {
    showAlert?.call(
      message: 'You cannot turn on your camera in an audio-only event.',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  if (videoAlreadyOn) {
    if (islevel == '2' && (recordStarted || recordResumed)) {
      if (!(recordPaused || recordStopped) &&
          recordingMediaOptions == 'video') {
        showAlert?.call(
          message:
              'You cannot turn off your camera while recording video. Please pause or stop recording first.',
          type: 'danger',
          duration: 3000,
        );
        return;
      }
    }

    videoAlreadyOn = false;
    updateVideoAlreadyOn(videoAlreadyOn);
    localStream!.getVideoTracks()[0].enabled = false;
    updateLocalStream(localStream);
    final optionsDisconnect = DisconnectSendTransportVideoOptions(
      parameters: parameters,
    );
    await disconnectSendTransportVideo(optionsDisconnect);
  } else {
    if (adminRestrictSetting) {
      showAlert?.call(
        message: 'You cannot turn on your camera. Access denied by host.',
        duration: 3000,
        type: 'danger',
      );
      return;
    }

    int response = 2;

    if (!videoAction && islevel != '2' && !youAreCoHost) {
      final optionsCheck = CheckPermissionOptions(
        permissionType: 'videoSetting',
        audioSetting: audioSetting,
        videoSetting: videoSetting,
        screenshareSetting: screenshareSetting,
        chatSetting: chatSetting,
      );
      response = await checkPermission(
        optionsCheck,
      );
    } else {
      response = 0;
    }

    if (response == 1) {
      if (videoRequestState == 'pending') {
        showAlert?.call(
          message: 'A request is pending. Please wait for the host to respond.',
          type: 'danger',
          duration: 3000,
        );
        return;
      }

      if (videoRequestState == 'rejected' &&
          DateTime.now().millisecondsSinceEpoch - videoRequestTime! <
              updateRequestIntervalSeconds) {
        showAlert?.call(
          message:
              'A request was rejected. Please wait $updateRequestIntervalSeconds seconds before sending another request.',
          type: 'danger',
          duration: 3000,
        );
        return;
      }

      showAlert?.call(
        message: 'Request sent to host.',
        type: 'success',
        duration: 3000,
      );
      updateVideoRequestState('pending');
      socket!.emit('participantRequest', {
        'userRequest': {'id': socket.id, 'name': member, 'icon': 'fa-video'},
        'roomName': roomName,
      });
    } else if (response == 2) {
      showAlert?.call(
        message: 'You cannot turn on your camera. Access denied by host.',
        type: 'danger',
        duration: 3000,
      );
    } else {
      if (!hasCameraPermission && checkMediaPermission) {
        final statusCamera = await requestPermissionCamera();
        if (!statusCamera) {
          showAlert?.call(
            message:
                'Allow access to your camera or check if your camera is not being used by another application.',
            type: 'danger',
            duration: 3000,
          );
          return;
        }
      }

      Map<String, dynamic> mediaConstraints =
          userDefaultVideoInputDevice.isNotEmpty
              ? _buildMediaConstraints(userDefaultVideoInputDevice, vidCons,
                  currentFacingMode, frameRate)
              : _buildAltMediaConstraints(vidCons, frameRate);
      try {
        await _attemptStream(
            mediaConstraints, streamSuccessVideo, parameters, showAlert);
      } catch (error) {
        mediaConstraints = _buildAltMediaConstraints(vidCons, frameRate);
        try {
          await _attemptStream(
              mediaConstraints, streamSuccessVideo, parameters, showAlert);
        } catch (error) {
          mediaConstraints = _buildFinalMediaConstraints(vidCons);
          try {
            await _attemptStream(
                mediaConstraints, streamSuccessVideo, parameters, showAlert);
          } catch (error) {
            showAlert?.call(
              message:
                  'Allow access to your camera or check if it is not being used by another application.',
              type: 'danger',
              duration: 3000,
            );
          }
        }
      }
    }
  }
}

Map<String, dynamic> _buildMediaConstraints(
  String deviceId,
  VidCons vidCons,
  String? facingMode,
  int frameRate,
) {
  final vidConsMap = vidCons.toMap();

  return {
    'video': {
      'mandatory': {
        'sourceId': deviceId,
        'facingMode': facingMode ?? 'user',
        'width': vidConsMap['width'],
        'height': vidConsMap['height'],
        'frameRate': {'ideal': frameRate},
      },
    },
    'audio': false,
  };
}

Map<String, dynamic> _buildAltMediaConstraints(
  VidCons vidCons,
  int frameRate,
) {
  final vidConsMap = vidCons.toMap();

  return {
    'video': {
      'mandatory': {
        'width': vidConsMap['width'],
        'height': vidConsMap['height'],
        'frameRate': {'ideal': frameRate},
      },
    },
    'audio': false,
  };
}

Map<String, dynamic> _buildFinalMediaConstraints(VidCons vidCons) {
  final vidConsMap = vidCons.toMap();

  return {
    'video': {
      'mandatory': {
        'width': vidConsMap['width'],
        'height': vidConsMap['height'],
      },
    },
    'audio': false,
  };
}

Future<void> _attemptStream(
  Map<String, dynamic> mediaConstraints,
  StreamSuccessVideoType streamSuccessVideo,
  ClickVideoParameters parameters,
  ShowAlert? showAlert,
) async {
  try {
    final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    final optionsStream = StreamSuccessVideoOptions(
      stream: stream,
      videoConstraints: mediaConstraints,
      parameters: parameters,
    );
    await streamSuccessVideo(optionsStream);
  } catch (error) {
    rethrow;
  }
}
