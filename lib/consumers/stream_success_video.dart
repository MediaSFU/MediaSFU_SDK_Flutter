// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Handles the success scenario when streaming video.
///
/// This function takes a [stream] of type [MediaStream] and [parameters] of type [Map<String, dynamic>].
/// It performs various operations such as updating parameters, getting parameters, updating state variables,
/// applying video constraints, creating or connecting transport, updating display screen, updating participants array,
/// and reordering streams.
///
/// The [streamSuccessVideo] function is typically used in a video streaming application to handle the success scenario
/// when streaming video. It is called with the [stream] and [parameters] as arguments.
///
/// Example usage:
/// ```dart
/// MediaStream stream = ...;
/// Map<String, dynamic> parameters = ...;
/// await streamSuccessVideo(stream: stream, parameters: parameters);
///

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef CreateSendTransport = Future<void> Function({
  required String option,
  required Map<String, dynamic> parameters,
});

typedef ReorderStreams = Future<void> Function({
  bool add,
  bool screenChanged,
  required Map<String, dynamic> parameters,
});

typedef ConnectSendTransportVideo = Future<void> Function({
  required dynamic videoParams,
  required Map<String, dynamic> parameters,
});

typedef UpdateUpdateParticipants = void Function(List<dynamic> participants);

typedef GetUpdatedAllParams = Map<String, dynamic> Function();
typedef UpdatedBoolFunction = void Function(bool);
typedef UpdatedStringFunction = void Function(String);
typedef UpdatedDynamicFunction = void Function(dynamic);

Future<void> streamSuccessVideo(
    {required MediaStream stream,
    required Map<String, dynamic> parameters}) async {
  try {
    // Update parameters
    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
    dynamic mediaConstraints = parameters['mediaConstraints'];
    parameters = getUpdatedAllParams();

    // Get parameters
    List<dynamic> participants = parameters['participants'];
    dynamic localStream = parameters['localStream'];
    dynamic localStreamVideo = parameters['localStreamVideo'];
    bool transportCreated = parameters['transportCreated'] ?? false;
    bool transportCreatedVideo = parameters['transportCreatedVideo'] ?? false;
    bool videoAlreadyOn = parameters['videoAlreadyOn'] ?? false;
    bool videoAction = parameters['videoAction'] ?? false;
    dynamic videoParams = parameters['videoParams'] ?? {};
    String defVideoID = parameters['defVideoID'] ?? '';
    String userDefaultVideoInputDevice =
        parameters['userDefaultVideoInputDevice'] ?? '';
    dynamic params = parameters['params'] ?? {};
    dynamic videoParamse = parameters['videoParamse'] ?? {};
    dynamic vParams = parameters['vParams'] ?? {};
    dynamic hParams = parameters['hParams'] ?? {};
    bool allowed = parameters['allowed'] ?? false;
    String currentFacingMode = parameters['currentFacingMode'] ?? 'user';
    dynamic device = parameters['device'] ?? {};
    String islevel = parameters['islevel'] ?? '1';
    bool shared = parameters['shared'] ?? false;
    bool shareScreenStarted = parameters['shareScreenStarted'] ?? false;
    bool updateMainWindow = parameters['updateMainWindow'] ?? false;
    String member = parameters['member'] ?? '';
    bool lockScreen = parameters['lockScreen'] ?? false;
    UpdatedBoolFunction updateTransportCreatedVideo =
        parameters['updateTransportCreatedVideo'];
    UpdatedBoolFunction updateVideoAlreadyOn =
        parameters['updateVideoAlreadyOn'];
    UpdatedBoolFunction updateVideoAction = parameters['updateVideoAction'];
    UpdatedDynamicFunction updateLocalStream = parameters['updateLocalStream'];
    UpdatedDynamicFunction updateLocalStreamVideo =
        parameters['updateLocalStreamVideo'];
    UpdatedStringFunction updateDefVideoID = parameters['updateDefVideoID'];
    UpdatedStringFunction updateUserDefaultVideoInputDevice =
        parameters['updateUserDefaultVideoInputDevice'];
    UpdatedStringFunction updateCurrentFacingMode =
        parameters['updateCurrentFacingMode'];
    UpdatedBoolFunction updateAllowed = parameters['updateAllowed'];
    UpdatedBoolFunction updateUpdateMainWindow =
        parameters['updateUpdateMainWindow'];
    UpdateUpdateParticipants updateParticipants =
        parameters['updateParticipants'];
    UpdatedDynamicFunction updateVideoParams = parameters['updateVideoParams'];

// mediasfu functions
    CreateSendTransport createSendTransport = parameters['createSendTransport'];
    ConnectSendTransportVideo connectSendTransportVideo =
        parameters['connectSendTransportVideo'];
    ShowAlert? showAlert = parameters['showAlert'];
    ReorderStreams reorderStreams = parameters['reorderStreams'];

    io.Socket socket = parameters['socket'];

    localStreamVideo = stream;

    // Update localStreamVideo
    updateLocalStreamVideo(localStreamVideo);

    // Add video track to localStream
    if (localStream == null) {
      localStream = stream;

      // Update the localStream
      updateLocalStream(localStream);
    } else {
      // Remove existing video tracks from localStream
      for (var track in localStream!.getVideoTracks().toList()) {
        localStream!.removeTrack(track);
      }

      // Add the new video track to the localStream
      localStream.addTrack(stream.getVideoTracks().first);
      updateLocalStream(localStream);
    }

    // Get video track settings
    MediaStreamTrack videoTracked = localStream.getVideoTracks().first;
    try {
      defVideoID = await videoTracked.getSettings()['deviceId'];
      userDefaultVideoInputDevice = defVideoID;
    } catch (error) {}

    try {
      currentFacingMode = await videoTracked.getSettings()['facingMode'];
    } catch (error) {}

    // Update state variables
    if (defVideoID != '') {
      updateDefVideoID(defVideoID);
    }
    if (userDefaultVideoInputDevice != '') {
      updateUserDefaultVideoInputDevice(userDefaultVideoInputDevice);
    }
    if (currentFacingMode != '') {
      updateCurrentFacingMode(currentFacingMode);
    }

    allowed = true;
    updateAllowed(allowed);

    try {
      // Apply video constraints
      if (islevel == '2') {
        if (!shared || !shareScreenStarted) {
          params = await hParams;
          videoParamse = {'params': params};
        } else {
          params = await vParams;
          videoParamse = {'params': params};
        }
      } else {
        params = await vParams;
        videoParamse = {'params': params};
      }

      // Remove VP9 codec from the video codecs; support only VP8 and H264
      RtpCodecCapability? codec = device.rtpCapabilities.codecs
          .where((codec) =>
              codec.mimeType.toLowerCase() != 'video/vp9' &&
              codec.mimeType.toLowerCase().contains('video'))
          .first;

      // Create videoParams
      videoParams = {
        ...videoParamse,
        'track': stream.getVideoTracks().first,
        'codecs': codec,
        'stream': stream,
      };
      updateVideoParams(videoParams);

      // Create or connect transport
      if (!transportCreated) {
        await createSendTransport(parameters: {
          ...parameters,
          'videoParams': videoParams,
          'mediaConstraints': mediaConstraints
        }, option: 'video');
      } else {
        await connectSendTransportVideo(
            videoParams: videoParams,
            parameters: {...parameters, 'mediaConstraints': mediaConstraints});
      }
    } catch (error) {
      if (showAlert != null) {
        showAlert(
          message: 'Error sharing video: make sure you have a camera connected',
          type: 'danger',
          duration: 3000,
        );
      }
    }

    // Update videoAlreadyOn state
    videoAlreadyOn = true;
    updateVideoAlreadyOn(videoAlreadyOn);

    // If user requested to share video, update the videoAction state
    if (videoAction == true) {
      videoAction = false;
      updateVideoAction(videoAction);
    }

    // Update display screen if host
    if (islevel == '2') {
      updateMainWindow = true;
      updateUpdateMainWindow(updateMainWindow);
    }

    // Update participants array
    for (var participant in participants) {
      if (participant['socketId'] == socket.id &&
          participant['name'] == member) {
        participant['videoOn'] = true;
      }
    }
    updateParticipants(participants);

    // Update transport created state
    transportCreatedVideo = true;
    updateTransportCreatedVideo(transportCreatedVideo);

    // Reupdate the screen display
    if (lockScreen) {
      await reorderStreams(
          add: true,
          screenChanged: true,
          parameters: {...parameters, 'videoAlreadyOn': videoAlreadyOn});
      if (!kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 1000));
        await reorderStreams(
            add: true,
            screenChanged: true,
            parameters: {...parameters, 'videoAlreadyOn': videoAlreadyOn});
      }
    } else {
      await reorderStreams(
          add: false,
          screenChanged: true,
          parameters: {...parameters, 'videoAlreadyOn': videoAlreadyOn});
      if (!kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 1000));
        await reorderStreams(
            add: false,
            screenChanged: true,
            parameters: {...parameters, 'videoAlreadyOn': videoAlreadyOn});
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - streamSuccessVideo error: $error');
    }
    // throw error;
  }
}
