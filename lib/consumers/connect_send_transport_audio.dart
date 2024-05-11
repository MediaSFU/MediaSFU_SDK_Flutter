import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';

/// Connects the send transport for audio by producing audio data.
///
/// This function connects the send transport for audio by performing the following steps:
/// 1. Destructures the parameters to get the necessary variables.
/// 2. Closes the existing audio track if it exists.
/// 3. Retrieves the local audio stream and audio constraints.
/// 4. Gets the user media stream using the audio constraints.
/// 5. Updates the local audio stream with the new stream.
/// 6. Adds the audio track to the local audio stream.
/// 7. Connects the send transport for audio by producing audio data.
/// 8. Updates the audio producer and producer transport objects.
///
/// Parameters:
/// - `audioParams`: The audio parameters for producing audio data.
/// - `parameters`: The map of parameters containing the necessary functions and objects.
///
/// Throws:
/// - If an error occurs during the process, it is caught and printed in debug mode.
///
/// Example usage:
/// ```dart
/// await connectSendTransportAudio(
///   audioParams: audioParams,
///   parameters: {
///     'getUpdatedAllParams': getUpdatedAllParams,
///     'producerTransport': producerTransport,
///     'updateProducerTransport': updateProducerTransport,
///     'updateLocalStreamAudio': updateLocalStreamAudio,
///     'updateLocalStream': updateLocalStream,
///     'audioConstraints': audioConstraints,
///   },
/// );

typedef UpdateAudioProducer = void Function(dynamic audioProducer);
typedef UpdateProducerTransport = void Function(dynamic producerTransport);
typedef UpdateLocalStreamAudio = void Function(dynamic localStreamAudio);
typedef UpdateLocalStream = void Function(dynamic localStream);
typedef GetUpdatedAllParams = Map<String, dynamic> Function();

Future<void> connectSendTransportAudio({
  required dynamic audioParams,
  required Map<String, dynamic> parameters,
}) async {
  try {
    // Destructure parameters
    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
    Transport producerTransport = parameters['producerTransport'];
    UpdateProducerTransport updateProducerTransport =
        parameters['updateProducerTransport'];
    UpdateLocalStreamAudio updateLocalStreamAudio =
        parameters['updateLocalStreamAudio'];
    UpdateLocalStream updateLocalStream = parameters['updateLocalStream'];

    dynamic localStream = getUpdatedAllParams()['localStream'];
    dynamic localStreamAudio = getUpdatedAllParams()['localStreamAudio'];
    dynamic audioConstraints = parameters['audioConstraints'];

    // Close the existing audio track
    if (localStream != null) {
      var audioTracks = localStream.getAudioTracks().toList();
      for (var track in audioTracks) {
        localStream.removeTrack(track);
      }
    }

    if (localStreamAudio != null) {
      var audioTracks = localStreamAudio.getAudioTracks().toList();
      for (var track in audioTracks) {
        localStreamAudio.removeTrack(track);
      }
    }

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(audioConstraints);

    updateLocalStreamAudio(stream);

    // Add video track to localStream
    if (localStream == null) {
      localStream = stream;

      // Update the localStream
      updateLocalStream(localStream);
    } else {
      // Remove existing video tracks from localStream
      for (var track in localStream!.getAudioTracks().toList()) {
        localStream!.removeTrack(track);
      }

      // Add the new video track to the localStream
      localStream.addTrack(stream.getAudioTracks().first);
      updateLocalStream(localStream);
    }

    // Connect the send transport for audio by producing audio data
    //get the first codec from the first video track
    producerTransport.produce(
      track: stream.getAudioTracks().first,
      stream: stream,
      source: 'mic',
    );

    // Update the audio producer and producer transport objects
    updateProducerTransport(producerTransport);
  } catch (error) {
    if (kDebugMode) {
      print('connectSendTransportAudio error: $error');
    }
    // throw error;
  }
}
