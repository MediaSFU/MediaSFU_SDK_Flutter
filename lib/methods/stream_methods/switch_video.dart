import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Switches the video preference for a media stream.
///
/// The [videoPreference] parameter specifies the desired video preference.
/// The [parameters] parameter is a map that contains various parameters needed for the function.
///
/// This function performs the following tasks:
/// - Shows an alert if camera access is not allowed.
/// - Shows an alert if the video is already on and the user tries to switch it on again.
/// - Shows an alert if the video is off and the user tries to switch it off again.
/// - Updates the default video input device if necessary.
/// - Calls the [switchUserVideo] function to switch the user's video.
///
/// Example usage:
/// ```dart
/// switchVideo(
///   videoPreference: 'front',
///   parameters: {
///     'showAlert': showAlert,
///     'recordStarted': false,
///     'recordResumed': false,
///     'recordStopped': false,
///     'recordPaused': false,
///     'recordingMediaOptions': '',
///     'videoAlreadyOn': false,
///     'userDefaultVideoInputDevice': '',
///     'defVideoID': '',
///     'allowed': true,
///     'updateDefVideoID': updateDefVideoID,
///     'updatePrevVideoInputDevice': updatePrevVideoInputDevice,
///     'updateUserDefaultVideoInputDevice': updateUserDefaultVideoInputDevice,
///     'updateIsMediaSettingsModalVisible': updateIsMediaSettingsModalVisible,
///     'switchUserVideo': switchUserVideo,
///   },
/// );
///

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

typedef UpdateVideoRequestState = void Function(String value);
typedef UpdateVideoRequestTime = void Function(DateTime value);
typedef UpdateLocalStream = void Function(dynamic value);
typedef UpdateLocalStreamVideo = void Function(dynamic value);
typedef UpdateVideoAlreadyOn = void Function(bool value);
typedef UpdateDefVideoID = void Function(String value);
typedef UpdatePrevVideoInputDevice = void Function(String value);
typedef UpdateAllowed = void Function(bool value);
typedef UpdateIsMediaSettingsModalVisible = void Function(bool value);
typedef CreateSendTransport = Future<void> Function({
  required String option,
  required Map<String, dynamic> parameters,
});
typedef ConnectSendTransportVideo = Future<void> Function({
  required dynamic videoParams,
  required Map<String, dynamic> parameters,
});
typedef ResumeSendTransportVideo = Future<void> Function({
  required Map<String, dynamic> parameters,
});
typedef ReorderStreams = Future<void> Function({
  bool add,
  bool screenChanged,
  required Map<String, dynamic> parameters,
});
typedef SwitchUserVideo = Future<void> Function({
  required String videoPreference,
  required bool checkoff,
  required Map<String, dynamic> parameters,
});

Future<void> switchVideo(
    {required String videoPreference,
    required Map<String, dynamic> parameters}) async {
  try {
    ShowAlert? showAlert = parameters['showAlert'];
    bool recordStarted = parameters['recordStarted'] ?? false;
    bool recordResumed = parameters['recordResumed'] ?? false;
    bool recordStopped = parameters['recordStopped'] ?? false;
    bool recordPaused = parameters['recordPaused'] ?? false;
    String recordingMediaOptions = parameters['recordingMediaOptions'] ?? '';
    bool videoAlreadyOn = parameters['videoAlreadyOn'] ?? false;
    String userDefaultVideoInputDevice =
        parameters['userDefaultVideoInputDevice'] ?? '';
    String defVideoID = parameters['defVideoID'] ?? '';
    bool allowed = parameters['allowed'] ?? false;
    UpdateDefVideoID updateDefVideoID = parameters['updateDefVideoID'];
    UpdatePrevVideoInputDevice updatePrevVideoInputDevice =
        parameters['updatePrevVideoInputDevice'];
    UpdateUserDefaultVideoInputDevice updateUserDefaultVideoInputDevice =
        parameters['updateUserDefaultVideoInputDevice'];
    UpdateIsMediaSettingsModalVisible updateIsMediaSettingsModalVisible =
        parameters['updateIsMediaSettingsModalVisible'];

    //mediasfu functions
    SwitchUserVideo switchUserVideo = parameters['switchUserVideo'];

    bool checkoff = false;
    if ((recordStarted || recordResumed) && (!recordStopped && !recordPaused)) {
      if (recordingMediaOptions == 'video') {
        checkoff = true;
      }
    }

    if (!allowed) {
      if (showAlert != null) {
        showAlert(
          message:
              'Allow access to your camera by starting it for the first time.',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    if (checkoff) {
      if (videoAlreadyOn) {
        if (showAlert != null) {
          showAlert(
            message: 'Please turn off your video before switching.',
            type: 'danger',
            duration: 3000,
          );
        }
        return;
      }
    } else {
      if (!videoAlreadyOn) {
        if (showAlert != null) {
          showAlert(
            message: 'Please turn on your video before switching.',
            type: 'danger',
            duration: 3000,
          );
        }
        return;
      }
    }

    if (defVideoID.isEmpty) {
      if (userDefaultVideoInputDevice.isNotEmpty) {
        defVideoID = userDefaultVideoInputDevice;
      } else {
        defVideoID = 'default';
      }
      updateDefVideoID(defVideoID);
    }

    if (videoPreference != defVideoID) {
      String prevVideoInputDevice = userDefaultVideoInputDevice;
      updatePrevVideoInputDevice(prevVideoInputDevice);

      userDefaultVideoInputDevice = videoPreference;
      updateUserDefaultVideoInputDevice(userDefaultVideoInputDevice);

      if (defVideoID.isNotEmpty) {
        updateIsMediaSettingsModalVisible(false);
        await switchUserVideo(
            videoPreference: videoPreference,
            checkoff: checkoff,
            parameters: parameters);
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('switchVideo error: $error');
    }
  }
}
