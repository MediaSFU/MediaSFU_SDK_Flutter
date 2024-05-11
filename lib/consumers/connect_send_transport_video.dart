import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';

/// Connects and sends video transport.
///
/// This function establishes a connection and sends video data using the provided parameters.
/// It takes in [videoParams] and [parameters] as required parameters.
/// The [videoParams] parameter contains information about the video encoding and codec options.
/// The [parameters] parameter is a map that contains various callback functions and objects required for the connection.
///
/// The function performs the following steps:
/// 1. Destructures the parameters and retrieves the required values.
/// 2. Closes the existing video tracks from the local stream.
/// 3. Retrieves the local media stream using the media constraints.
/// 4. Updates the local stream video with the retrieved stream.
/// 5. Adds the video track to the local stream.
/// 6. Updates the main window state based on the video connection level.
/// 7. Calls the provided callback functions to update the producer transport and main window state.
///
/// Throws an error if any exception occurs during the process.

typedef UpdateVideoProducer = void Function(dynamic videoProducer);
typedef UpdateProducerTransport = void Function(dynamic producerTransport);
typedef UpdateMainWindow = void Function(bool updateMainWindow);
typedef GetUpdatedAllParams = Map<String, dynamic> Function();

typedef UpdatedBoolFunction = void Function(bool);
typedef UpdatedStringFunction = void Function(String);
typedef UpdatedDynamicFunction = void Function(dynamic);

Future<void> connectSendTransportVideo({
  required dynamic videoParams,
  required Map<String, dynamic> parameters,
}) async {
  try {
    // Destructure parameters
    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
    Transport producerTransport = parameters['producerTransport'];
    String islevel = parameters['islevel'];
    dynamic mediaConstraints = parameters['mediaConstraints'];

    dynamic localStream = getUpdatedAllParams()['localStream'];
    dynamic localStreamVideo = getUpdatedAllParams()['localStreamVideo'];

    UpdatedDynamicFunction updateLocalStream = parameters['updateLocalStream'];
    UpdatedDynamicFunction updateLocalStreamVideo =
        parameters['updateLocalStreamVideo'];

    //close the existing video track
    if (localStream != null) {
      var videoTracks = localStream.getVideoTracks().toList();
      for (var track in videoTracks) {
        localStream.removeTrack(track);
      }
    }

    if (localStreamVideo != null) {
      var videoTracks = localStreamVideo.getVideoTracks().toList();
      for (var track in videoTracks) {
        localStreamVideo.removeTrack(track);
      }
    }

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    //Update the localStreamVideo
    updateLocalStreamVideo(stream);

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

    bool updateMainWindow = parameters['updateMainWindow'];
    UpdateProducerTransport updateProducerTransport =
        parameters['updateProducerTransport'];
    UpdateMainWindow updateUpdateMainWindow =
        parameters['updateUpdateMainWindow'];

    List<RtpEncodingParameters> convertToRtpEncodingParametersList(
        List<dynamic> encodings) {
      return encodings.map((encoding) {
        return RtpEncodingParameters(
          rid: encoding['rid'],
          maxBitrate: encoding['maxBitrate']?.round(),
          minBitrate: encoding['minBitrate']?.round(),
          scalabilityMode: encoding['scalabilityMode'],
          scaleResolutionDownBy: encoding['scaleResolutionDownBy']?.toDouble(),
        );
      }).toList();
    }

    List<RtpEncodingParameters> encodingsList = [];

    try {
      List encodings = videoParams["params"]['encodings'];
      encodingsList = convertToRtpEncodingParametersList(encodings);
      // ignore: empty_catches
    } catch (e) {}

    //get the first codec from the first video track

    producerTransport.produce(
      track: stream.getVideoTracks().first,
      stream: stream,
      encodings: encodingsList,
      codecOptions: ProducerCodecOptions(
          videoGoogleStartBitrate: videoParams["params"]['codecOptions']
                  ['videoGoogleStartBitrate']
              ?.round()),
      codec: videoParams['codecs'],
      source: 'webcam',
    );

    // Update main window state based on the video connection level
    if (islevel == '2') {
      updateMainWindow = true;
    }

    updateProducerTransport(producerTransport);
    updateUpdateMainWindow(updateMainWindow);
  } catch (error) {
    if (kDebugMode) {
      print('connectSendTransportVideo error: $error');
    }
    // throw error;
  }
}
