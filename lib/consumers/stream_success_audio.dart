// ignore_for_file: empty_catches

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Handles the success scenario when streaming audio.
///
/// This function takes in a [stream] of type [MediaStream] and [parameters] of type [Map<String, dynamic>].
/// The [stream] represents the audio stream to be handled, while the [parameters] contain various parameters and callbacks needed for the handling process.
///
/// The function performs the following steps:
/// 1. Destructures the [parameters] to obtain the required variables.
/// 2. Updates the local audio stream with the provided [stream].
/// 3. If the [localStream] is null, assigns it the value of [localStreamAudio]. Otherwise, updates the [localStream] by removing existing audio tracks and adding the audio track from [localStreamAudio].
/// 4. Retrieves the default audio ID from the [localStream] and updates the [defAudioID] and [userDefaultAudioInputDevice] variables accordingly.
/// 5. Updates the [audioParams] with the provided [stream] and other audio parameters.
/// 6. If the send transport has not been created, calls the [createSendTransport] function with the necessary parameters to create the send transport for audio.
/// 7. If the send transport has been created but the audio transport has not, calls the [connectSendTransportAudio] function to connect the audio transport.
/// 8. If both the send transport and audio transport have been created, calls the [resumeSendTransportAudio] function to resume the audio transport.
/// 9. Handles any errors that occur during the process and displays an error message if [kDebugMode] is true.
/// 10. Updates the [audioAlreadyOn] variable to true.
/// 11. Updates the [micAction] variable to false if it was previously true.
/// 12. Updates the [muted] status of the current participant in the [participants] list.
/// 13. Updates the [transportCreated] and [transportCreatedAudio] variables to true.
/// 14. If [videoAlreadyOn] is false and [islevel] is '2', updates the [updateMainWindow] variable to true, prepopulates the user media, and then updates the [updateMainWindow] variable to false.
///
/// The function also makes use of various typedefs and callbacks to handle different actions and updates.
///
/// Example usage:
/// ```dart
/// await streamSuccessAudio(stream: mediaStream, parameters: {
///   'socket': socket,
///   'participants': participants,
///   'localStream': localStream,
///   // other parameters and callbacks
/// });
/// ```

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef CheckPermission = Future<int> Function({
  required String permissionType,
  required Map<String, dynamic> parameters,
});

typedef CreateSendTransport = Future<void> Function({
  required String option,
  required Map<String, dynamic> parameters,
});

typedef ConnectSendTransportAudio = Future<void> Function({
  required dynamic audioParams,
  required Map<String, dynamic> parameters,
});

typedef ResumeSendTransportAudio = Future<void> Function({
  required Map<String, dynamic> parameters,
});

typedef UpdateAudioAlreadyOn = void Function(bool value);
typedef UpdateMicAction = void Function(bool value);
typedef UpdateAudioParams = void Function(dynamic value);
typedef UpdateLocalStream = void Function(dynamic value);
typedef UpdateLocalStreamAudio = void Function(dynamic value);
typedef UpdateDefAudioID = void Function(String value);
typedef UpdateUserDefaultAudioInputDevice = void Function(String value);
typedef UpdateUpdateMainWindow = void Function(bool value);
typedef UpdateParticipants = void Function(List<dynamic> value);
typedef UpdateTransportCreated = void Function(bool value);
typedef UpdateTransportCreatedAudio = void Function(bool value);

typedef PrepopulateUserMedia = List<dynamic> Function(
    {required String name, required Map<String, dynamic> parameters});

Future<void> streamSuccessAudio(
    {required MediaStream stream,
    required Map<String, dynamic> parameters}) async {
  // Destructure parameters
  io.Socket socket = parameters['socket'];
  List<dynamic> participants = parameters['participants'];

  dynamic localStream = parameters['localStream'];
  bool transportCreated = parameters['transportCreated'] ?? false;
  bool transportCreatedAudio = parameters['transportCreatedAudio'] ?? false;
  bool audioAlreadyOn = parameters['audioAlreadyOn'] ?? false;
  bool micAction = parameters['micAction'] ?? false;
  dynamic audioParams = parameters['audioParams'] ?? {};
  dynamic localStreamAudio = parameters['localStreamAudio'];
  String defAudioID = parameters['defAudioID'] ?? '';
  String userDefaultAudioInputDevice =
      parameters['userDefaultAudioInputDevice'] ?? '';
  dynamic params = parameters['params'] ?? {};
  dynamic audioParamse = parameters['audioParamse'] ?? {};
  dynamic aParams = parameters['aParams'] ?? {};
  String hostLabel = parameters['hostLabel'] ?? '';
  String islevel = parameters['islevel'] ?? '1';
  String member = parameters['member'] ?? '';
  bool updateMainWindow = parameters['updateMainWindow'] ?? false;
  bool lockScreen = parameters['lockScreen'] ?? false;
  bool shared = parameters['shared'] ?? false;
  bool videoAlreadyOn = parameters['videoAlreadyOn'] ?? false;
  final UpdateParticipants updateParticipants =
      parameters['updateParticipants'];
  final UpdateTransportCreated updateTransportCreated =
      parameters['updateTransportCreated'];
  final UpdateTransportCreatedAudio updateTransportCreatedAudio =
      parameters['updateTransportCreatedAudio'];
  final UpdateAudioAlreadyOn updateAudioAlreadyOn =
      parameters['updateAudioAlreadyOn'];
  final UpdateMicAction updateMicAction = parameters['updateMicAction'];
  final UpdateAudioParams updateAudioParams = parameters['updateAudioParams'];
  final UpdateLocalStream updateLocalStream = parameters['updateLocalStream'];
  final UpdateLocalStreamAudio updateLocalStreamAudio =
      parameters['updateLocalStreamAudio'];
  final UpdateDefAudioID updateDefAudioID = parameters['updateDefAudioID'];
  final UpdateUserDefaultAudioInputDevice updateUserDefaultAudioInputDevice =
      parameters['updateUserDefaultAudioInputDevice'];
  final UpdateUpdateMainWindow updateUpdateMainWindow =
      parameters['updateUpdateMainWindow'];

  // mediasfu functions
  final CreateSendTransport createSendTransport =
      parameters['createSendTransport'];
  final ConnectSendTransportAudio connectSendTransportAudio =
      parameters['connectSendTransportAudio'];
  final ResumeSendTransportAudio resumeSendTransportAudio =
      parameters['resumeSendTransportAudio'];
  final PrepopulateUserMedia prepopulateUserMedia =
      parameters['prepopulateUserMedia'];

  try {
    // Update the local audio stream
    localStreamAudio = stream;
    updateLocalStreamAudio(localStreamAudio);

// Check if localStream is null
    if (localStream == null) {
      localStream =
          localStreamAudio; // Assign localStream to localStreamAudio if it's null
    } else {
      // Remove existing audio tracks from localStream
      for (var track in localStream!.getAudioTracks()) {
        localStream!.removeTrack(track);
      }

      // Add the first audio track from localStreamAudio to localStream
      var audioTracks = localStreamAudio!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        localStream!.addTrack(audioTracks.first);
      }

      // Update the local stream
      updateLocalStream(localStream!);
    }

    final MediaStreamTrack audioTracked = localStream.getAudioTracks().first;
    try {
      defAudioID = await audioTracked.getSettings()['deviceId'];
      userDefaultAudioInputDevice = defAudioID;
      updateDefAudioID(defAudioID);
      updateUserDefaultAudioInputDevice(userDefaultAudioInputDevice);
    } catch (error) {}

    params = aParams;
    audioParamse = {'params': params};
    audioParams = {
      'track': stream.getAudioTracks().first,
      'stream': stream,
      ...audioParamse
    };
    updateAudioParams(audioParams);

    if (!transportCreated) {
      try {
        await createSendTransport(
          parameters: {...parameters, 'audioParams': audioParams},
          option: 'audio',
        );
      } catch (error) {}
    } else {
      if (!transportCreatedAudio) {
        await connectSendTransportAudio(
            audioParams: audioParams, parameters: parameters);
      } else {
        await resumeSendTransportAudio(parameters: parameters);
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('streamSuccessAudio error: $error');
    }

    final ShowAlert? showAlert = parameters['showAlert'];
    if (showAlert != null) {
      showAlert(message: error.toString(), type: 'danger', duration: 3000);
    }
  }

  audioAlreadyOn = true;
  updateAudioAlreadyOn(audioAlreadyOn);

  if (micAction == true) {
    micAction = false;
    updateMicAction(micAction);
  }

  for (var participant in participants) {
    if (participant['socketId'] == socket.id && participant['name'] == member) {
      participant['muted'] = false;
    }
  }
  updateParticipants(participants);

  transportCreated = true;
  transportCreatedAudio = true;
  updateTransportCreated(transportCreated);
  updateTransportCreatedAudio(transportCreatedAudio);

  if (videoAlreadyOn == false && islevel == '2') {
    if (!lockScreen && !shared) {
      updateMainWindow = true;
      updateUpdateMainWindow(updateMainWindow);
      prepopulateUserMedia(name: hostLabel, parameters: parameters);
      updateMainWindow = false;
      updateUpdateMainWindow(updateMainWindow);
    }
  }
}
