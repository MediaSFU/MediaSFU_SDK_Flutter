import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart'
    show
        CheckPermissionType,
        DisconnectSendTransportAudioParameters,
        DisconnectSendTransportAudioType,
        Participant,
        RequestPermissionAudioType,
        ResumeSendTransportAudioParameters,
        ResumeSendTransportAudioType,
        ShowAlert,
        StreamSuccessAudioParameters,
        StreamSuccessAudioType,
        DisconnectSendTransportAudioOptions,
        ResumeSendTransportAudioOptions,
        CheckPermissionOptions,
        StreamSuccessAudioOptions;

// Define ClickAudioParameters class with all parameters required for the clickAudio function
abstract class ClickAudioParameters
    implements
        DisconnectSendTransportAudioParameters,
        ResumeSendTransportAudioParameters,
        StreamSuccessAudioParameters {
  // Core properties as abstract getters
  bool get checkMediaPermission;
  bool get hasAudioPermission;
  bool get audioPaused;
  bool get audioAlreadyOn;
  bool get audioOnlyRoom;
  bool get recordStarted;
  bool get recordResumed;
  bool get recordPaused;
  bool get recordStopped;
  String get recordingMediaOptions;
  String get islevel;
  bool get youAreCoHost;
  bool get adminRestrictSetting;
  String? get audioRequestState;
  int? get audioRequestTime;
  String get member;
  io.Socket? get socket;
  String get roomName;
  String get userDefaultAudioInputDevice;
  bool get micAction;
  MediaStream? get localStream;
  String get audioSetting;
  String get videoSetting;
  String get screenshareSetting;
  String get chatSetting;
  int get updateRequestIntervalSeconds;
  List<Participant> get participants;
  bool get transportCreated;
  bool get transportCreatedAudio;

  // Callback functions as abstract getters
  void Function(bool) get updateAudioAlreadyOn;
  void Function(String?) get updateAudioRequestState;
  void Function(bool) get updateAudioPaused;
  void Function(MediaStream?) get updateLocalStream;
  void Function(List<Participant> participants) get updateParticipants;
  void Function(bool) get updateTransportCreated;
  void Function(bool) get updateTransportCreatedAudio;
  void Function(bool) get updateMicAction;
  ShowAlert? get showAlert;

  // Mediasfu functions as abstract getters
  CheckPermissionType get checkPermission;
  StreamSuccessAudioType get streamSuccessAudio;
  DisconnectSendTransportAudioType get disconnectSendTransportAudio;
  RequestPermissionAudioType get requestPermissionAudio;
  ResumeSendTransportAudioType get resumeSendTransportAudio;

  // Method to retrieve updated parameters
  ClickAudioParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
  // void operator []=(String key, dynamic value);
}

// Define ClickAudioOptions with parameters of type ClickAudioParameters
class ClickAudioOptions {
  final ClickAudioParameters parameters;

  ClickAudioOptions({required this.parameters});
}

// Type definition for the clickAudio function
typedef ClickAudioType = Future<void> Function(ClickAudioOptions options);

/// Toggles audio for a user, either enabling or disabling the microphone.
///
/// ### Parameters:
/// - `options` (`ClickAudioOptions`): Contains all required parameters and callbacks.
///   - `parameters` (`ClickAudioParameters`): The key configurations for permissions,
///      media settings, callback functions, and state variables.
///
/// ### Workflow:
/// 1. **Audio Toggle**:
///    - **Disable**: Checks if recording is active and if it's safe to disable audio.
///    - **Enable**: Verifies permissions and sends a request to the host if necessary.
///
/// 2. **Permissions & Requests**:
///    - If the user lacks permissions, sends a request to the host or prompts for permissions.
///    - Uses callbacks to update the UI and emit requests or permission checks.
///
/// 3. **Media Constraints**:
///    - Configures constraints for `getUserMedia` based on device and user preference.
///
/// ### Example Usage:
/// ```dart
/// final parameters = ClickAudioParameters(
///   checkMediaPermission: true,
///   hasAudioPermission: false,
///   audioPaused: false,
///   // Other properties and callbacks...
/// );
///
/// await clickAudio(ClickAudioOptions(parameters: parameters));
/// ```
///
/// ### Error Handling:
/// - Logs any errors to the console in debug mode.

Future<void> clickAudio(ClickAudioOptions options) async {
  try {
    final parameters = options.parameters;

    // Destructure parameters
    final bool checkMediaPermission = parameters.checkMediaPermission;
    bool hasAudioPermission = parameters.hasAudioPermission;
    bool audioPaused = parameters.audioPaused;
    bool audioAlreadyOn = parameters.audioAlreadyOn;
    final bool audioOnlyRoom = parameters.audioOnlyRoom;
    final bool recordStarted = parameters.recordStarted;
    final bool recordResumed = parameters.recordResumed;
    final bool recordPaused = parameters.recordPaused;
    final bool recordStopped = parameters.recordStopped;
    final String recordingMediaOptions = parameters.recordingMediaOptions;
    final String islevel = parameters.islevel;
    final bool youAreCoHost = parameters.youAreCoHost;
    final bool adminRestrictSetting = parameters.adminRestrictSetting;
    String? audioRequestState = parameters.audioRequestState;
    final int? audioRequestTime = parameters.audioRequestTime;
    final String member = parameters.member;
    final io.Socket? socket = parameters.socket;
    final String roomName = parameters.roomName;
    final String userDefaultAudioInputDevice =
        parameters.userDefaultAudioInputDevice;
    bool micAction = parameters.micAction;
    MediaStream? localStream = parameters.localStream;
    final String audioSetting = parameters.audioSetting;
    final String videoSetting = parameters.videoSetting;
    final String screenshareSetting = parameters.screenshareSetting;
    final String chatSetting = parameters.chatSetting;
    final int updateRequestIntervalSeconds =
        parameters.updateRequestIntervalSeconds;
    final List<Participant> participants = parameters.participants;
    bool transportCreated = parameters.transportCreated;
    bool transportCreatedAudio = parameters.transportCreatedAudio;

    // Callback functions
    final updateAudioAlreadyOn = parameters.updateAudioAlreadyOn;
    final updateAudioRequestState = parameters.updateAudioRequestState;
    final updateAudioPaused = parameters.updateAudioPaused;
    final updateLocalStream = parameters.updateLocalStream;
    final updateParticipants = parameters.updateParticipants;
    final updateTransportCreated = parameters.updateTransportCreated;
    final updateTransportCreatedAudio = parameters.updateTransportCreatedAudio;
    final updateMicAction = parameters.updateMicAction;
    final showAlert = parameters.showAlert;

    // mediasfu functions
    final checkPermission = parameters.checkPermission;
    final streamSuccessAudio = parameters.streamSuccessAudio;
    final requestPermissionAudio = parameters.requestPermissionAudio;
    final disconnectSendTransportAudio =
        parameters.disconnectSendTransportAudio;
    final resumeSendTransportAudio = parameters.resumeSendTransportAudio;

    if (audioOnlyRoom) {
      showAlert?.call(
          message: "You cannot turn on your camera in an audio-only event.",
          type: "danger",
          duration: 3000);
      return;
    }

    if (audioAlreadyOn) {
      // Check and alert before turning off
      if (islevel == '2' &&
          (recordStarted || recordResumed) &&
          !(recordPaused || recordStopped) &&
          recordingMediaOptions == 'audio') {
        showAlert?.call(
            message:
                "You cannot turn off your audio while recording, please pause or stop recording first.",
            type: "danger",
            duration: 3000);
        return;
      }

      // Update the icon and turn off audio
      audioAlreadyOn = false;
      updateAudioAlreadyOn(audioAlreadyOn);
      localStream?.getAudioTracks()[0].enabled = false;
      updateLocalStream(localStream);
      final optionsDisconnect = DisconnectSendTransportAudioOptions(
        parameters: parameters,
      );
      await disconnectSendTransportAudio(optionsDisconnect);
      audioPaused = true;
      updateAudioPaused(audioPaused);
    } else {
      if (adminRestrictSetting) {
        showAlert?.call(
            message:
                "You cannot turn on your microphone. Access denied by host.",
            type: "danger",
            duration: 3000);
        return;
      }

      int response = 2;

      if (!micAction && islevel != '2' && !youAreCoHost) {
        final optionsCheck = CheckPermissionOptions(
          permissionType: 'audioSetting',
          audioSetting: audioSetting,
          videoSetting: videoSetting,
          screenshareSetting: screenshareSetting,
          chatSetting: chatSetting,
        );
        response = await checkPermission(optionsCheck);
      } else {
        response = 0;
      }

      switch (response) {
        case 1:
          if (audioRequestState == 'pending') {
            showAlert?.call(
                message:
                    "A request is pending. Please wait for the host to respond.",
                type: "danger",
                duration: 3000);
            return;
          }

          if (audioRequestState == 'rejected' &&
              DateTime.now().millisecondsSinceEpoch - audioRequestTime! <
                  updateRequestIntervalSeconds * 1000) {
            showAlert?.call(
                message:
                    "A request was rejected. Please wait for $updateRequestIntervalSeconds seconds before sending another request.",
                type: "danger",
                duration: 3000);
            return;
          }

          showAlert?.call(
              message: "Request sent to host.",
              type: "success",
              duration: 3000);
          audioRequestState = 'pending';
          updateAudioRequestState(audioRequestState);

          final userRequest = {
            'id': socket!.id,
            'name': member,
            'icon': 'fa-microphone'
          };
          socket.emit('participantRequest',
              {'userRequest': userRequest, 'roomName': roomName});
          break;

        case 2:
          showAlert?.call(
            message:
                'You cannot turn on your microphone. Access denied by host.',
            type: 'danger',
            duration: 3000,
          );

          break;

        case 0:
          if (audioPaused) {
            localStream?.getAudioTracks()[0].enabled = true;
            updateAudioAlreadyOn(true);
            final optionsResume = ResumeSendTransportAudioOptions(
              parameters: parameters,
            );
            await resumeSendTransportAudio(options: optionsResume);
            socket!.emit("resumeProducerAudio",
                {"mediaTag": "audio", "roomName": roomName});
            updateLocalStream(localStream);
            updateAudioAlreadyOn(audioAlreadyOn);
            if (micAction == true) {
              micAction = false;
              updateMicAction(micAction);
            }

            for (var participant in participants) {
              if (participant['socketId'] == socket.id &&
                  participant.name == member) {
                participant.muted = false;
              }
            }
            updateParticipants(participants);

            transportCreated = true;
            updateTransportCreated(transportCreated);
            transportCreatedAudio = true;
            updateTransportCreatedAudio(transportCreatedAudio);
          } else {
            // First check if permission is granted
            if (!hasAudioPermission) {
              if (checkMediaPermission) {
                bool statusMic = await requestPermissionAudio();
                if (statusMic != true) {
                  showAlert?.call(
                      message:
                          "Allow access to your microphone or check if your microphone is not being used by another application.",
                      type: "danger",
                      duration: 3000);
                  return;
                }
              }
            }

            final mediaConstraints = userDefaultAudioInputDevice.isNotEmpty
                ? {
                    'audio': {'deviceId': userDefaultAudioInputDevice},
                    'video': false
                  }
                : {'audio': true, 'video': false};

            try {
              final stream =
                  await navigator.mediaDevices.getUserMedia(mediaConstraints);
              final optionsStream = StreamSuccessAudioOptions(
                parameters: parameters,
                stream: stream,
                audioConstraints: mediaConstraints,
              );
              await streamSuccessAudio(optionsStream);
            } catch (error) {
              showAlert?.call(
                  message:
                      "Allow access to your microphone or check if your microphone is not being used by another application.",
                  type: "danger",
                  duration: 3000);
            }
          }
          break;

        default:
          break;
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error in clickAudio: $error');
    }
  }
}
