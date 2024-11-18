import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../methods/stream_methods/click_video.dart' show clickVideo;
import '../types/types.dart'
    show
        ShowAlert,
        VidCons,
        RequestPermissionCameraType,
        StreamSuccessVideoType,
        SleepType,
        StreamSuccessVideoParameters,
        SleepOptions,
        StreamSuccessVideoOptions,
        ClickVideoOptions,
        ClickVideoParameters;

// Abstract class for parameters
abstract class SwitchUserVideoParameters
    implements StreamSuccessVideoParameters, ClickVideoParameters {
  bool get audioOnlyRoom;
  int get frameRate;
  VidCons get vidCons;
  String get prevVideoInputDevice;
  String get userDefaultVideoInputDevice;
  ShowAlert? get showAlert;
  bool get hasCameraPermission;
  void Function(bool) get updateVideoSwitching;
  void Function(String) get updateUserDefaultVideoInputDevice;

  RequestPermissionCameraType get requestPermissionCamera;
  StreamSuccessVideoType get streamSuccessVideo;
  SleepType get sleep;
  bool get checkMediaPermission;

  SwitchUserVideoParameters Function() get getUpdatedAllParams;

  // void operator []=(String key, dynamic value);
}

class SwitchUserVideoOptions {
  final String videoPreference;
  final bool checkoff;
  final SwitchUserVideoParameters parameters;

  SwitchUserVideoOptions({
    required this.videoPreference,
    required this.checkoff,
    required this.parameters,
  });
}

typedef SwitchUserVideoType = Future<void> Function(
    SwitchUserVideoOptions options);

/// Toggles or switches the video stream based on user preferences and permission checks.
///
/// ### Parameters:
/// - `options` (`SwitchUserVideoOptions`): Contains:
///   - `videoPreference`: Specifies the preferred video device or facing mode.
///   - `checkoff`: Boolean that indicates whether to bypass initial click checks.
///   - `parameters`: Provides access to required properties and functions, such as:
///     - `audioOnlyRoom`: Boolean to check if the room is audio-only.
///     - `frameRate`: Preferred frame rate for video.
///     - `vidCons`: Constraints for video width, height, etc.
///     - `prevVideoInputDevice`: ID of the previous video input device.
///     - `userDefaultVideoInputDevice`: ID of the current preferred video input device.
///     - `showAlert`: Optional function for displaying alerts to the user.
///
/// ### Process:
/// 1. **Audio-Only Check**:
///    - Displays an alert if the user tries to turn on the video in an audio-only room.
///
/// 2. **Initial Click Toggle**:
///    - Optionally triggers the `clickVideo` function to toggle the video on or off, followed by a short delay.
///
/// 3. **Camera Permission Check**:
///    - Requests camera access if permission is not already granted. If permission is denied, an alert is shown.
///
/// 4. **Media Constraints Setup and Stream Attempt**:
///    - Builds media constraints based on `videoPreference`, `vidCons`, and `frameRate`.
///    - Attempts to access the video stream with the preferred constraints.
///
/// ### Helper Functions:
/// - **_buildMediaConstraints**: Configures media constraints using the preferred device ID and settings.
/// - **_attemptStream**: Attempts to access the video stream based on the provided constraints. Reverts to the previous device on failure.
///
/// ### Example Usage:
/// ```dart
/// final options = SwitchUserVideoOptions(
///   videoPreference: 'user',
///   checkoff: false,
///   parameters: SwitchUserVideoParameters(
///     audioOnlyRoom: false,
///     frameRate: 30,
///     vidCons: VidCons(width: 1280, height: 720),
///     prevVideoInputDevice: 'back',
///     userDefaultVideoInputDevice: 'front',
///     showAlert: (message, type, duration) => print('Alert: $message'),
///   ),
/// );
///
/// await switchUserVideo(options);
/// ```
///
/// ### Error Handling:
/// - If the camera access fails, reverts to the previous video input device and displays an alert.
/// - Attempts to access alternative video constraints if the preferred ones are not accessible.

Future<void> switchUserVideo(SwitchUserVideoOptions options) async {
  final parameters = options.parameters.getUpdatedAllParams();

  final audioOnlyRoom = parameters.audioOnlyRoom;
  final frameRate = parameters.frameRate;
  final vidCons = parameters.vidCons;
  final prevVideoInputDevice = parameters.prevVideoInputDevice;
  String userDefaultVideoInputDevice = parameters.userDefaultVideoInputDevice;
  final showAlert = parameters.showAlert;
  final hasCameraPermission = parameters.hasCameraPermission;
  final updateVideoSwitching = parameters.updateVideoSwitching;
  final updateUserDefaultVideoInputDevice =
      parameters.updateUserDefaultVideoInputDevice;

  final requestPermissionCamera = parameters.requestPermissionCamera;
  final streamSuccessVideo = parameters.streamSuccessVideo;
  final sleep = parameters.sleep;
  final checkMediaPermission = parameters.checkMediaPermission;

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
        parameters: parameters,
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

    Map<String, dynamic> mediaConstraints = _buildMediaConstraints(
      videoPreference: options.videoPreference,
      vidCons: vidCons,
      frameRate: frameRate,
    );

    await _attemptStream(
      mediaConstraints,
      streamSuccessVideo,
      parameters,
      showAlert,
      userDefaultVideoInputDevice,
      prevVideoInputDevice,
      updateUserDefaultVideoInputDevice,
    );
  } catch (error) {
    userDefaultVideoInputDevice = prevVideoInputDevice;
    updateUserDefaultVideoInputDevice(userDefaultVideoInputDevice);
    showAlert?.call(
      message:
          'Error switching; not accessible, might need to turn off your video and turn it back on after switching.',
      type: 'danger',
      duration: 3000,
    );
  }
}

Map<String, dynamic> _buildMediaConstraints({
  required String videoPreference,
  required VidCons? vidCons,
  required int frameRate,
}) {
  if (vidCons != null) {
    final vidConsMap = vidCons.toMap();
    return {
      'video': {
        'mandatory': {
          'sourceId': videoPreference,
          'minWidth': vidConsMap['width'],
          'minHeight': vidConsMap['height'],
          'maxFrameRate': frameRate,
        },
      },
      'audio': false,
    };
  } else {
    return {
      'video': {
        'mandatory': {
          'deviceId': {'exact': videoPreference},
          'frameRate': {'ideal': frameRate},
        },
      },
      'audio': false,
    };
  }
}

Future<void> _attemptStream(
  Map<String, dynamic> mediaConstraints,
  StreamSuccessVideoType streamSuccessVideo,
  SwitchUserVideoParameters parameters,
  ShowAlert? showAlert,
  String userDefaultVideoInputDevice,
  String prevVideoInputDevice,
  void Function(String) updateUserDefaultVideoInputDevice,
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
    updateUserDefaultVideoInputDevice(prevVideoInputDevice);
    showAlert?.call(
      message:
          'Error switching; not accessible, might need to turn off your video and turn it back on after switching.',
      type: 'danger',
      duration: 3000,
    );
  }
}
