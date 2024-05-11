import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Clicks the audio button to toggle audio on/off in a video conference room.
///
/// This function handles the logic for turning on/off the audio in a video conference room.
/// It takes a map of parameters as input, including various settings and callbacks.
/// The function checks for permissions, handles audio requests, and updates the UI accordingly.
///
/// Parameters:
/// - `parameters`: A map of parameters including settings and callbacks.
///
/// Callbacks:
/// - `showAlert`: A callback function to show an alert message.
/// - `checkPermission`: A callback function to check for permissions.
/// - `streamSuccessAudio`: A callback function to handle successful audio streaming.
/// - `requestPermissionAudio`: A callback function to request audio permission.
/// - `disconnectSendTransportAudio`: A callback function to disconnect the audio send transport.
/// - `resumeSendTransportAudio`: A callback function to resume the audio send transport.
/// - `updateAudioAlreadyOn`: A callback function to update the audio already on state.
/// - `updateAudioRequestState`: A callback function to update the audio request state.
/// - `updateLocalStream`: A callback function to update the local stream.
/// - `updateAudioPaused`: A callback function to update the audio paused state.
/// - `updateParticipants`: A callback function to update the participants list.
/// - `updateTransportCreated`: A callback function to update the transport created state.
/// - `updateTransportCreatedAudio`: A callback function to update the audio transport created state.
/// - `updateMicAction`: A callback function to update the mic action state.
///
/// Returns: A Future that completes when the audio click operation is finished.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef CheckPermission = Future<int> Function({
  required String permissionType,
  required Map<String, dynamic> parameters,
});

typedef StreamSuccessAudio = Future<void> Function({
  required MediaStream stream,
  required Map<String, dynamic> parameters,
});

typedef RequestPermissionAudio = Future<bool> Function();

typedef DisconnectSendTransportAudio = Future<void> Function({
  required Map<String, dynamic> parameters,
});

typedef ResumeSendTransportAudio = Future<void> Function({
  required Map<String, dynamic> parameters,
});

typedef UpdateVideoRequestState = void Function(String value);
typedef UpdateAudioRequestState = void Function(String value);
typedef UpdateVideoRequestTime = void Function(DateTime value);
typedef UpdateAudioRequestTime = void Function(DateTime value);
typedef UpdateLocalStream = void Function(dynamic value);
typedef UpdateLocalStreamVideo = void Function(dynamic value);
typedef UpdateAudioAlreadyOn = void Function(bool value);
typedef UpdateLocalStreamAudio = void Function(dynamic value);
typedef UpdateAudioPaused = void Function(bool audioPaused);
typedef UpdateParticipants = void Function(List<dynamic> participants);
typedef UpdateTransportCreated = void Function(bool transportCreated);
typedef UpdateTransportCreatedAudio = void Function(bool transportCreatedAudio);
typedef UpdateMicAction = void Function(bool micAction);

Future<void> clickAudio({
  required Map<String, dynamic> parameters,
}) async {
  try {
    // Destructure parameters
    bool checkMediaPermission = parameters['checkMediaPermission'] ?? false;
    bool hasAudioPermission = parameters['hasAudioPermission'] ?? false;
    bool audioPaused = parameters['audioPaused'] ?? false;
    bool audioAlreadyOn = parameters['audioAlreadyOn'] ?? false;
    bool audioOnlyRoom = parameters['audioOnlyRoom'] ?? false;
    bool recordStarted = parameters['recordStarted'] ?? false;
    bool recordResumed = parameters['recordResumed'] ?? false;
    bool recordPaused = parameters['recordPaused'] ?? false;
    bool recordStopped = parameters['recordStopped'] ?? false;
    String recordingMediaOptions = parameters['recordingMediaOptions'] ?? '';
    String islevel = parameters['islevel'] ?? '1';
    bool youAreCoHost = parameters['youAreCoHost'] ?? false;
    bool adminRestrictSetting = parameters['adminRestrictSetting'] ?? false;
    String audioRequestState = parameters['audioRequestState'] ?? '';
    DateTime? audioRequestTime = parameters['audioRequestTime'];
    String member = parameters['member'] ?? '';
    io.Socket? socket = parameters['socket'];
    String roomName = parameters['roomName'] ?? '';
    String userDefaultAudioInputDevice =
        parameters['userDefaultAudioInputDevice'] ?? '';
    bool micAction = parameters['micAction'] ?? false;
    dynamic localStream = parameters['localStream'];
    String audioSetting = parameters['audioSetting'] ?? 'allow';
    String videoSetting = parameters['videoSetting'] ?? 'allow';
    String screenshareSetting = parameters['screenshareSetting'] ?? 'allow';
    String chatSetting = parameters['chatSetting'] ?? 'allow';
    int requestIntervalSeconds = parameters['requestIntervalSeconds'] ?? 0;
    dynamic participants = parameters['participants'];
    bool transportCreated = parameters['transportCreated'] ?? false;
    bool transportCreatedAudio = parameters['transportCreatedAudio'] ?? false;
    ShowAlert? showAlert = parameters['showAlert'];
    UpdateAudioAlreadyOn updateAudioAlreadyOn =
        parameters['updateAudioAlreadyOn'];
    UpdateAudioRequestState updateAudioRequestState =
        parameters['updateAudioRequestState'];
    UpdateLocalStream updateLocalStream = parameters['updateLocalStream'];
    UpdateAudioPaused updateAudioPaused = parameters['updateAudioPaused'];
    UpdateParticipants updateParticipants = parameters['updateParticipants'];
    UpdateTransportCreated updateTransportCreated =
        parameters['updateTransportCreated'];
    UpdateTransportCreatedAudio updateTransportCreatedAudio =
        parameters['updateTransportCreatedAudio'];
    UpdateMicAction updateMicAction = parameters['updateMicAction'];

    //mediasfu functions
    CheckPermission checkPermission = parameters['checkPermission'];
    StreamSuccessAudio streamSuccessAudio = parameters['streamSuccessAudio'];
    RequestPermissionAudio requestPermissionAudio =
        parameters['requestPermissionAudio'];
    DisconnectSendTransportAudio disconnectSendTransportAudio =
        parameters['disconnectSendTransportAudio'];
    ResumeSendTransportAudio resumeSendTransportAudio =
        parameters['resumeSendTransportAudio'];

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

    if (audioAlreadyOn) {
      // Check and alert before turning off
      if (islevel == '2' &&
          (recordStarted || recordResumed) &&
          !(recordPaused || recordStopped) &&
          recordingMediaOptions == 'audio') {
        if (showAlert != null) {
          showAlert(
            message:
                'You cannot turn off your audio while recording, please pause or stop recording first.',
            type: 'danger',
            duration: 3000,
          );
        }
        return;
      }

      // Update the icon and turn off audio
      audioAlreadyOn = false;
      updateAudioAlreadyOn(audioAlreadyOn);
      localStream.getAudioTracks()[0].enabled = false;
      updateLocalStream(localStream);
      await disconnectSendTransportAudio(parameters: parameters);
      audioPaused = true;
      updateAudioPaused(audioPaused);
    } else {
      if (adminRestrictSetting) {
        // Return with access denied by admin
        if (showAlert != null) {
          showAlert(
            message:
                'You cannot turn on your microphone. Access denied by host.',
            type: 'danger',
            duration: 3000,
          );
        }
        return;
      }

      int response = 2;
      if (!micAction && islevel != '2' && !youAreCoHost) {
        // Check if audio permission is set to approval
        response =
            await checkPermission(permissionType: 'audioSetting', parameters: {
          'audioSetting': audioSetting,
          'videoSetting': videoSetting,
          'screenshareSetting': screenshareSetting,
          'chatSetting': chatSetting,
        });
      } else {
        response = 0;
      }

      switch (response) {
        case 1:
          // Approval

          // Check if request is pending or not
          if (audioRequestState == 'pending') {
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

          // Send request to host
          if (showAlert != null) {
            showAlert(
              message: 'Request sent to host.',
              type: 'success',
              duration: 3000,
            );
          }
          audioRequestState = 'pending';
          updateAudioRequestState(audioRequestState);
          // Create a request and add to the request list and send to host
          var userRequest = {
            'id': socket!.id,
            'name': member,
            'icon': 'fa-microphone'
          };
          socket.emit('participantRequest',
              {'userRequest': userRequest, 'roomName': roomName});
          break;

        case 2:
          // Check if rejected and current time is less than audioRequestTime
          if (audioRequestState == 'rejected' &&
              (DateTime.now().millisecondsSinceEpoch -
                      audioRequestTime!.millisecondsSinceEpoch) <
                  requestIntervalSeconds) {
            if (showAlert != null) {
              showAlert(
                message:
                    'A request was rejected. Please wait for $requestIntervalSeconds seconds before sending another request.',
                type: 'danger',
                duration: 3000,
              );
            }
            return;
          }
          break;

        case 0:
          // Allow
          if (audioPaused) {
            localStream.getAudioTracks()[0].enabled = true;
            audioAlreadyOn = true;
            await resumeSendTransportAudio(parameters: parameters);
            socket!.emit('resumeProducerAudio',
                {'mediaTag': 'audio', 'roomName': roomName});
            updateLocalStream(localStream);
            updateAudioAlreadyOn(audioAlreadyOn);
            if (micAction == true) {
              micAction = false;
              updateMicAction(micAction);
            }

            for (var participant in participants.toList()) {
              if (participant['socketId'] == socket.id &&
                  participant['name'] == member) {
                participant['muted'] = false;
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
            Map<String, dynamic> mediaConstraints = {};
            if (userDefaultAudioInputDevice != '') {
              mediaConstraints = {
                'audio': {'deviceId': userDefaultAudioInputDevice},
                'video': false
              };
            } else {
              mediaConstraints = {'audio': true, 'video': false};
            }
            try {
              MediaStream stream =
                  await navigator.mediaDevices.getUserMedia(mediaConstraints);
              await streamSuccessAudio(stream: stream, parameters: {
                ...parameters,
                'audioConstraints': mediaConstraints,
              });
            } catch (error) {
              if (showAlert != null) {
                showAlert(
                  message:
                      'Allow access to your microphone or check if your microphone is not being used by another application.',
                  type: 'danger',
                  duration: 3000,
                );
              }
            }
          }
          break;
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error in clickAudio: $error');
    }
  }
}
