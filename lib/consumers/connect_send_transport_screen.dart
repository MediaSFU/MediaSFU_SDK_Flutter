import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';

/// Connects the send transport for screen sharing by producing screen video data.
///
/// This function takes a [stream] and [parameters] as input. The [stream] is the media stream containing the screen video track to be shared.
/// The [parameters] is a map containing the necessary parameters for the screen sharing process, including the screen producer, device, screen parameters, producer transport, and other options.
///
/// The function connects the send transport for screen sharing by producing the screen video data using the producer transport. It retrieves the VP9 codec from the available video codecs and uses it to encode the screen video data.
/// The produced screen video data is then associated with the screen producer and the producer transport objects are updated accordingly.
///
/// The function handles any errors that occur during the process and prints the error message in debug mode.
///
/// Example usage:
/// ```dart
/// await connectSendTransportScreen(
///   stream: myMediaStream,
///   parameters: {
///     'screenProducer': myScreenProducer,
///     'device': myDevice,
///     'screenParams': myScreenParams,
///     'producerTransport': myProducerTransport,
///     'params': myParams,
///     'updateScreenProducer': myUpdateScreenProducerFunction,
///     'updateProducerTransport': myUpdateProducerTransportFunction,
///   },
/// );

typedef UpdateScreenProducerFunction = void Function(dynamic screenProducer);
typedef UpdateProducerTransportFunction = void Function(
    dynamic producerTransport);
typedef UpdateLocalStreamScreenFunction = void Function(MediaStream stream);

Future<void> connectSendTransportScreen({
  required MediaStream stream,
  required Map<String, dynamic> parameters,
}) async {
  try {
    dynamic screenProducer = parameters['screenProducer'];
    Device device = parameters['device'];
    dynamic screenParams = parameters['screenParams'];
    Transport producerTransport = parameters['producerTransport'];
    dynamic params = parameters['params'];

    UpdateScreenProducerFunction updateScreenProducer =
        parameters['updateScreenProducer'];
    UpdateProducerTransportFunction updateProducerTransport =
        parameters['updateProducerTransport'];

    // Connect the send transport for screen share by producing screen video data
    params = screenParams;

    // Get VP9 codec from the video codecs
    RtpCodecCapability? codec = device.rtpCapabilities.codecs
        .where((codec) => codec.mimeType.toLowerCase() == 'video/vp9')
        .first;

    // Produce screen share data using the producer transport
    producerTransport.produce(
      track: stream.getVideoTracks()[0],
      stream: stream,
      codecOptions: ProducerCodecOptions(
        videoGoogleStartBitrate: params['codecOptions']
            ['videoGoogleStartBitrate'],
      ),
      codec: codec,
      appData: {'mediaTag': 'screen-video'},
      source: 'screen',
    );

    // Update the screen producer and producer transport objects
    updateScreenProducer(screenProducer);
    updateProducerTransport(producerTransport);
  } catch (error) {
    if (kDebugMode) {
      print('connectSendTransportScreen error: $error');
    }
    // throw error;
  }
}
