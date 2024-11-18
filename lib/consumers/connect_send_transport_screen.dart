import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../types/types.dart' show ProducerOptionsType;

abstract class ConnectSendTransportScreenParameters {
  Producer? get screenProducer;
  Device? get device;
  ProducerOptionsType? get screenParams;
  Transport? get producerTransport;
  ProducerOptionsType? get params;

  void Function(Producer screenProducer) get updateScreenProducer;
  void Function(Transport producerTransport) get updateProducerTransport;

  ConnectSendTransportScreenParameters Function() get getUpdatedAllParams;
  // dynamic operator [](String key);
}

class ConnectSendTransportScreenOptions {
  final MediaStream stream;
  final ConnectSendTransportScreenParameters parameters;

  ConnectSendTransportScreenOptions(
      {required this.stream, required this.parameters});
}

typedef ConnectSendTransportScreenType = Future<void> Function(
    ConnectSendTransportScreenOptions options);

/// Sets up and initiates the screen-sharing transport connection, configuring codec options and producing a video track for screen sharing.
///
/// ### Parameters:
/// - `options` (`ConnectSendTransportScreenOptions`): Contains:
///   - `stream` (`MediaStream`): The media stream that includes the screen video track for sharing.
///   - `parameters` (`ConnectSendTransportScreenParameters`): Contains necessary configurations, such as codec options, transport, and update functions.
///
/// ### Workflow:
/// 1. **Codec Selection**:
///    - Attempts to select the VP9 codec for optimized video sharing.
///    - If VP9 is unavailable, defaults to the first available video codec in device capabilities.
/// 2. **Producer Transport Setup**:
///    - Uses `producerTransport` to initiate screen sharing with the selected codec and screen-sharing settings.
/// 3. **Transport and Producer Updates**:
///    - Updates the `producerTransport` and `screenProducer` in the provided `parameters` to reflect the active screen-sharing session.
///
/// ### Returns:
/// - A `Future<void>` that completes when the screen-sharing transport is successfully established.
///
/// ### Example Usage:
/// ```dart
/// final screenOptions = ConnectSendTransportScreenOptions(
///   stream: screenStream,
///   parameters: myConnectSendTransportScreenParameters,
/// );
///
/// connectSendTransportScreen(screenOptions).then(() {
///   print("Screen-sharing transport connected.");
/// }).catchError((error) {
///   print("Error connecting screen-sharing transport: $error");
/// });
/// ```
///
/// ### Error Handling:
/// - Logs errors to the console in debug mode if an issue occurs during transport setup.

Future<void> connectSendTransportScreen(
    ConnectSendTransportScreenOptions options) async {
  final MediaStream stream = options.stream;
  final ConnectSendTransportScreenParameters parameters = options.parameters;

  try {
    // Retrieve and update latest parameters
    Device? device = parameters.getUpdatedAllParams().device;
    Transport? producerTransport = parameters.producerTransport;
    ProducerOptionsType? screenParams = parameters.screenParams;

    // Update parameters for the codec and screen production
    ProducerOptionsType producerParams = screenParams!;

    // Find VP9 codec in device capabilities
    RtpCodecCapability? codec = device?.rtpCapabilities.codecs
        .firstWhere((codec) => codec.mimeType.toLowerCase() == 'video/vp9');

    // If no VP9 codec is found, get the first video codec
    codec ??= device?.rtpCapabilities.codecs.firstWhere(
        (codec) => codec.kind == RTCRtpMediaType.RTCRtpMediaTypeVideo);

    // Produce screen share video using the transport and codec
    producerTransport!.produce(
      track: stream.getVideoTracks()[0],
      stream: stream,
      codecOptions: ProducerCodecOptions(
        videoGoogleStartBitrate:
            producerParams.codecOptions!.videoGoogleStartBitrate,
      ),
      codec: codec,
      appData: {'mediaTag': 'screen-video'},
      source: 'screen',
    );

    // Update screenProducer and producerTransport in parameters
    parameters.updateProducerTransport(producerTransport);
  } catch (error) {
    if (kDebugMode) {
      print('connectSendTransportScreen error: $error');
    }
    // throw error;
  }
}
