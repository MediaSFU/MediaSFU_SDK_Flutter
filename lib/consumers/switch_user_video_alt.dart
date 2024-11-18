import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../types/types.dart'
    show
        VidCons,
        ShowAlert,
        RequestPermissionCameraType,
        StreamSuccessVideoType,
        SleepType,
        SleepOptions,
        StreamSuccessVideoOptions,
        StreamSuccessVideoParameters;

import '../methods/stream_methods/click_video.dart'
    show clickVideo, ClickVideoOptions, ClickVideoParameters;

// Abstract class for SwitchUserVideoAltParameters
abstract class SwitchUserVideoAltParameters
    implements StreamSuccessVideoParameters, ClickVideoParameters {
  bool get audioOnlyRoom;
  int get frameRate;
  VidCons get vidCons;
  ShowAlert? get showAlert;
  bool get hasCameraPermission;
  void Function(bool) get updateVideoSwitching;
  void Function(String) get updateCurrentFacingMode;
  String get currentFacingMode;
  String get prevFacingMode;

  // Mediasfu functions
  RequestPermissionCameraType get requestPermissionCamera;
  StreamSuccessVideoType get streamSuccessVideo;
  SleepType get sleep;
  bool get checkMediaPermission;
  SwitchUserVideoAltParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
  // void operator []=(String key, dynamic value);
}

// Options class for SwitchUserVideoAlt
class SwitchUserVideoAltOptions {
  String videoPreference;
  bool checkoff;
  SwitchUserVideoAltParameters parameters;

  SwitchUserVideoAltOptions({
    required this.videoPreference,
    required this.checkoff,
    required this.parameters,
  });
}

typedef SwitchUserVideoAltType = Future<void> Function(
    SwitchUserVideoAltOptions options);

/// Switches video input devices, handling permission checks, device switching, and error handling.
///
/// ### Overview:
/// - **Permission Check**: Verifies camera access before proceeding; prompts user if access is not granted.
/// - **Device Switching**: Attempts to switch to the specified video input device, adjusting constraints.
/// - **Error Handling**: Checks for alternative video devices if the preferred device is unavailable.
///
/// ### Parameters:
/// - `options` (`SwitchUserVideoAltOptions`): Contains:
///   - `videoPreference`: ID or type of the preferred video input device (e.g., "front" or "back").
///   - `checkoff`: Boolean to skip device click handling if true.
///   - `parameters` (`SwitchUserVideoAltParameters`): The parameters needed for switching, including:
///     - `audioOnlyRoom`: Boolean indicating if the event is audio-only (prevents video activation).
///     - `frameRate`: Desired frame rate for the video.
///     - `vidCons`: Constraints for video resolution, including width and height.
///     - `showAlert`: Optional function for displaying alerts to the user.
///     - `hasCameraPermission`: Boolean to track camera permission status.
///     - `checkMediaPermission`: Boolean to control if media permissions should be checked.
///     - `requestPermissionCamera`: Function to request camera permission if needed.
///     - `streamSuccessVideo`: Function to handle successful video stream setup.
///     - `sleep`: Function to introduce a delay when switching video input devices.
///
/// ### Process:
/// 1. **Permission and Audio-Only Check**:
///    - If the event is audio-only, an alert is displayed, and the process exits early.
///    - If the camera permission is not granted, it prompts the user to enable camera access.
///
/// 2. **Device Switching**:
///    - Defines video constraints based on the video preference and frame rate.
///    - Attempts to acquire the video stream with the preferred device.
///
/// 3. **Error Handling**:
///    - If the preferred device is unavailable, the function attempts to access alternative devices based on the user preference.
///    - If all attempts fail, an alert informs the user to retry after toggling the video.
///
/// ### Example Usage:
/// ```dart
/// final parameters = SwitchUserVideoAltParameters(
///   audioOnlyRoom: false,
///   frameRate: 30,
///   vidCons: VidCons(width: 1280, height: 720),
///   showAlert: (message, type, duration) => print('Alert: $message'),
///   hasCameraPermission: true,
///   updateVideoSwitching: (switching) => print('Video Switching: $switching'),
///   updateCurrentFacingMode: (facingMode) => print('Current Facing Mode: $facingMode'),
///   requestPermissionCamera: myRequestPermissionFunction,
///   streamSuccessVideo: myStreamSuccessVideoFunction,
///   sleep: mySleepFunction,
///   checkMediaPermission: true,
/// );
///
/// await switchUserVideoAlt(
///   options: SwitchUserVideoAltOptions(
///     videoPreference: 'user', // Switch to front camera
///     checkoff: false,
///     parameters: parameters,
///   ),
/// );
/// ```
///
/// ### Error Handling:
/// - Checks for alternative devices if the preferred device is unavailable.
/// - Updates the facing mode to its previous state if switching fails.
/// - Displays an alert if the camera access fails or if an alternative device cannot be accessed.

Future<void> switchUserVideoAlt(SwitchUserVideoAltOptions options) async {
  final params = options.parameters.getUpdatedAllParams();

  final audioOnlyRoom = params.audioOnlyRoom;
  final frameRate = params.frameRate;
  final vidCons = params.vidCons;
  final showAlert = params.showAlert;
  final hasCameraPermission = params.hasCameraPermission;
  final updateVideoSwitching = params.updateVideoSwitching;
  final updateCurrentFacingMode = params.updateCurrentFacingMode;
  final checkMediaPermission = params.checkMediaPermission;
  String currentFacingMode = params.currentFacingMode;
  final prevFacingMode = params.prevFacingMode;

  final requestPermissionCamera = params.requestPermissionCamera;
  final streamSuccessVideo = params.streamSuccessVideo;
  final sleep = params.sleep;

  try {
    if (audioOnlyRoom) {
      showAlert?.call(
        message: 'You cannot turn on your camera in an audio-only event.',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    if (!options.checkoff) {
      final optionsClick = ClickVideoOptions(
        parameters: params,
      );
      await clickVideo(optionsClick);
      updateVideoSwitching(true);
      await sleep(SleepOptions(ms: 500));
      updateVideoSwitching(false);
    }

    if (!hasCameraPermission && checkMediaPermission) {
      final statusCamera = await requestPermissionCamera();
      if (!statusCamera) {
        showAlert?.call(
          message:
              'Allow access to your camera or check if it’s not being used by another application.',
          type: 'danger',
          duration: 3000,
        );
        return;
      }
    }

    List<MediaDeviceInfo> videoDevices =
        await navigator.mediaDevices.enumerateDevices();

    Map<String, dynamic> mediaConstraints = _buildMediaConstraints(
      vidCons: vidCons,
      frameRate: frameRate,
      videoPreference: options.videoPreference,
    );

    await _attemptStream(
        mediaConstraints,
        streamSuccessVideo,
        params,
        showAlert,
        videoDevices,
        currentFacingMode,
        prevFacingMode,
        updateCurrentFacingMode);
  } catch (error) {
    await _handleStreamError(
      videoDevices: await navigator.mediaDevices.enumerateDevices(),
      vidCons: vidCons,
      frameRate: frameRate,
      videoPreference: options.videoPreference,
      streamSuccessVideo: streamSuccessVideo,
      currentFacingMode: currentFacingMode,
      prevFacingMode: prevFacingMode,
      updateCurrentFacingMode: updateCurrentFacingMode,
      showAlert: showAlert,
      parameters: params,
    );
  }
}

Map<String, dynamic> _buildMediaConstraints({
  required VidCons? vidCons,
  required int frameRate,
  required String videoPreference,
}) {
  if (vidCons != null) {
    final vidConsMap = vidCons.toMap();
    return {
      'video': {
        'mandatory': {
          'width': vidConsMap['width'],
          'height': vidConsMap['height'],
          'frameRate': {'ideal': frameRate},
        },
        'facingMode': videoPreference,
      },
      'audio': false,
    };
  } else {
    return {
      'video': {
        'mandatory': {
          'frameRate': {'ideal': frameRate},
        },
        'facingMode': videoPreference,
      },
      'audio': false,
    };
  }
}

Future<void> _attemptStream(
    Map<String, dynamic> mediaConstraints,
    StreamSuccessVideoType streamSuccessVideo,
    SwitchUserVideoAltParameters params,
    ShowAlert? showAlert,
    List<MediaDeviceInfo> videoDevices,
    String currentFacingMode,
    String prevFacingMode,
    void Function(String) updateCurrentFacingMode) async {
  await navigator.mediaDevices
      .getUserMedia(mediaConstraints)
      .then((stream) async {
    final optionsStream = StreamSuccessVideoOptions(
      stream: stream,
      videoConstraints: mediaConstraints,
      parameters: params,
    );
    await streamSuccessVideo(optionsStream);
  }).catchError((error) async {
    await _handleStreamError(
      videoDevices: videoDevices,
      vidCons: params.vidCons,
      frameRate: params.frameRate,
      videoPreference: currentFacingMode,
      streamSuccessVideo: streamSuccessVideo,
      currentFacingMode: currentFacingMode,
      prevFacingMode: prevFacingMode,
      updateCurrentFacingMode: updateCurrentFacingMode,
      showAlert: showAlert,
      parameters: params,
    );
  });
}

Future<void> _handleStreamError({
  required List<MediaDeviceInfo> videoDevices,
  required VidCons vidCons,
  required int frameRate,
  required String videoPreference,
  required StreamSuccessVideoType streamSuccessVideo,
  required String currentFacingMode,
  required String prevFacingMode,
  required void Function(String) updateCurrentFacingMode,
  required ShowAlert? showAlert,
  required SwitchUserVideoAltParameters parameters,
}) async {
  // Handling the error by checking for alternative video devices
  final videoDevicesFront = videoDevices.where((device) {
    return (videoPreference == 'user'
            ? device.label.contains('front')
            : device.label.contains('back')) &&
        device.kind == 'videoinput';
  }).toList();

  if (videoDevicesFront.isNotEmpty) {
    for (MediaDeviceInfo device in videoDevicesFront) {
      String videoDeviceId = device.deviceId;

      var mediaConstraints = _buildMediaConstraints(
        vidCons: vidCons,
        frameRate: frameRate,
        videoPreference: videoPreference,
      );

      try {
        final stream =
            await navigator.mediaDevices.getUserMedia(mediaConstraints);
        final optionsStream = StreamSuccessVideoOptions(
          stream: stream,
          videoConstraints: mediaConstraints,
          parameters: parameters,
        );
        await streamSuccessVideo(optionsStream);
        return;
      } catch (error) {
        if (videoDeviceId == videoDevicesFront.last.deviceId) {
          currentFacingMode = prevFacingMode;
          updateCurrentFacingMode(currentFacingMode);
          showAlert?.call(
            message:
                'Error switching; not accessible, might need to turn off your video and turn it back on after switching.',
            type: 'danger',
            duration: 3000,
          );
        }
      }
    }
  } else {
    currentFacingMode = prevFacingMode;
    updateCurrentFacingMode(currentFacingMode);
    showAlert?.call(
      message:
          'Error switching; not accessible, might need to turn off your video and turn it back on after switching.',
      type: 'danger',
      duration: 3000,
    );
  }
}
