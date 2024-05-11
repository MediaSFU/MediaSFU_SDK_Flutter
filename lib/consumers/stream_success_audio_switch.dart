// ignore_for_file: empty_catches

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Handles the success event when switching the audio stream in a media application.
///
/// This function takes in a [parameters] map and a [stream] of type [MediaStream].
/// The [parameters] map contains various parameters required for the audio stream switch.
/// The [stream] represents the new audio stream to be switched.
///
/// The function performs the following tasks:
/// 1. Retrieves the necessary parameters from the [parameters] map.
/// 2. Checks if the audio device has changed and performs the necessary actions.
/// 3. Updates the local audio stream with the new audio tracks.
/// 4. Creates or connects to the send transport for audio.
/// 5. Pauses the audio producer if necessary.
/// 6. Updates the UI based on the participant's level and screen lock status.
///
/// Throws an error if any exception occurs during the process.

typedef ConnectSendTransport = Future<void> Function({
  required String option,
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

typedef PrepopulateUserMedia = List<dynamic> Function(
    {required String name, required Map<String, dynamic> parameters});

typedef Sleep = Future<void> Function(int milliseconds);
typedef GetUpdatedAllParamsFunction = Future<Map<String, dynamic>> Function();

typedef UpdateAudioProducer = void Function(dynamic audioProducer);
typedef UpdateLocalStream = void Function(MediaStream localStream);
typedef UpdateLocalStreamAudio = void Function(MediaStream localStreamAudio);
typedef UpdateAudioParams = void Function(dynamic audioParams);
typedef UpdateAudioPaused = void Function(bool audioPaused);
typedef UpdateAudioAlreadyOn = void Function(bool audioAlreadyOn);
typedef UpdateTransportCreated = void Function(bool transportCreated);
typedef UpdateDefAudioID = void Function(String defAudioID);
typedef UpdateUserDefaultAudioInputDevice = void Function(
    String userDefaultAudioInputDevice);
typedef UpdateUpdateMainWindow = void Function(bool updateMainWindow);

Future<void> streamSuccessAudioSwitch(
    {required Map<String, dynamic> parameters,
    required MediaStream stream}) async {
  try {
    dynamic audioProducer = parameters['audioProducer'];
    io.Socket socket = parameters['socket'];
    String roomName = parameters['roomName'] ?? '';
    MediaStream? localStream = parameters['localStream'];
    MediaStream? localStreamAudio = parameters['localStreamAudio'];
    dynamic audioParams = parameters['audioParams'];
    bool audioPaused = parameters['audioPaused'] ?? false;
    bool audioAlreadyOn = parameters['audioAlreadyOn'];
    bool transportCreated = parameters['transportCreated'] ?? false;
    dynamic audioParamse = parameters['audioParamse'] ?? {};
    String defAudioID = parameters['defAudioID'] ?? '';
    String userDefaultAudioInputDevice =
        parameters['userDefaultAudioInputDevice'] ?? '';
    String hostLabel = parameters['hostLabel'];
    bool updateMainWindow = parameters['updateMainWindow'];
    bool videoAlreadyOn = parameters['videoAlreadyOn'];
    String islevel = parameters['islevel'];
    bool lockScreen = parameters['lockScreen'] ?? false;
    bool shared = parameters['shared'] ?? false;

    final UpdateAudioProducer updateAudioProducer =
        parameters['updateAudioProducer'];
    final UpdateLocalStream updateLocalStream = parameters['updateLocalStream'];
    final UpdateAudioParams updateAudioParams = parameters['updateAudioParams'];
    final UpdateDefAudioID updateDefAudioID = parameters['updateDefAudioID'];
    final UpdateUserDefaultAudioInputDevice updateUserDefaultAudioInputDevice =
        parameters['updateUserDefaultAudioInputDevice'];
    final UpdateUpdateMainWindow updateUpdateMainWindow =
        parameters['updateUpdateMainWindow'];

    // mediasfu functions
    final Sleep sleep = parameters['sleep'];

    final CreateSendTransport createSendTransport =
        parameters['createSendTransport'];
    final ConnectSendTransportAudio connectSendTransportAudio =
        parameters['connectSendTransportAudio'];

    final PrepopulateUserMedia prepopulateUserMedia =
        parameters['prepopulateUserMedia'];

    // Get the new default audio device ID
    var newDefAudioID = stream.getAudioTracks().first.getSettings()['deviceId'];

    // Check if the audio device has changed
    if (newDefAudioID != defAudioID) {
      // Close the current audioProducer
      if (audioProducer != null) {
        await audioProducer.close();
        updateAudioProducer(audioProducer);
      }

      // Emit a pauseProducerMedia event to pause the audio media
      socket.emit('pauseProducerMedia',
          {'mediaTag': 'audio', 'roomName': roomName, 'force': true});

      // Update the localStreamAudio with the new audio tracks
      localStreamAudio = stream;

      // If localStream is null, create a new MediaStream with the new audio track
      if (localStream == null || localStream.getAudioTracks().isEmpty) {
        localStream = localStreamAudio;
      } else {
        // Remove all existing audio tracks from localStream and add the new audio track
        for (var track in localStream.getAudioTracks().toList()) {
          localStream.removeTrack(track);
        }

        localStream.addTrack(localStreamAudio.getAudioTracks().first);
      }

      // Update localStream
      updateLocalStream(localStream);

      // Get the new default audio device ID from the new audio track
      var audioTracked = localStream.getAudioTracks().first;
      defAudioID = audioTracked.getSettings()['deviceId'];
      updateDefAudioID(defAudioID);

      // Update userDefaultAudioInputDevice
      userDefaultAudioInputDevice = defAudioID;
      updateUserDefaultAudioInputDevice(userDefaultAudioInputDevice);

      //get the opus codec

      // Update audioParams with the new audio track
      audioParams = {
        'track': stream.getAudioTracks().first,
        'stream': stream,
        ...audioParamse!
      };
      updateAudioParams(audioParams!);

      // Sleep for 500 milliseconds
      await sleep(500);

      // Create a new send transport if not created, otherwise, connect the existing transport
      if (!transportCreated) {
        try {
          await createSendTransport(
              parameters: {...parameters, 'audioParams': audioParams},
              option: 'audio');
        } catch (error) {
          if (kDebugMode) {
            print(
                'Error in streamSuccessAudioSwitch createSendTransport: $error');
          }
        }
      } else {
        try {
          await connectSendTransportAudio(
              audioParams: audioParams, parameters: parameters);
        } catch (error) {}
      }

      // If audio is paused and not already on, pause the audioProducer and emit a pauseProducerMedia event
      if (audioPaused == true && !audioAlreadyOn) {
        await audioProducer.pause();
        updateAudioProducer(audioProducer);
        socket.emit(
            'pauseProducerMedia', {'mediaTag': 'audio', 'roomName': roomName});
      }
    }

    // Update the UI based on the participant's level and screen lock status
    if (videoAlreadyOn == false && islevel == '2') {
      if (!lockScreen && !shared) {
        // Set updateMainWindow to true, prepopulate user media, and set updateMainWindow back to false
        updateMainWindow = true;
        updateUpdateMainWindow(updateMainWindow);
        prepopulateUserMedia(name: hostLabel, parameters: parameters);
        updateMainWindow = false;
        updateUpdateMainWindow(updateMainWindow);
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - Error in streamSuccessAudio Switch: $error');
    }
  }
}
