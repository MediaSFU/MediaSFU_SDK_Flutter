import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../types/types.dart' show ProducerOptionsType;

abstract class ConnectSendTransportScreenParameters {
  // Remote Transport and Producer
  Producer? get screenProducer;
  Transport? get producerTransport;

  // Local Transport and Producer
  Producer? get localScreenProducer;
  Transport? get localProducerTransport;

  // Device and Parameters
  Device? get device;
  ProducerOptionsType? get screenParams;
  ProducerOptionsType? get params;

  // Update Functions
  void Function(Producer screenProducer) get updateScreenProducer;
  void Function(Producer? localScreenProducer)? get updateLocalScreenProducer;
  void Function(Transport producerTransport) get updateProducerTransport;
  void Function(Transport? localProducerTransport)?
      get updateLocalProducerTransport;

  ConnectSendTransportScreenParameters Function() get getUpdatedAllParams;
}

class ConnectSendTransportScreenOptions {
  final MediaStream stream;
  final ConnectSendTransportScreenParameters parameters;
  final String targetOption; // 'all', 'local', 'remote'

  ConnectSendTransportScreenOptions({
    required this.stream,
    required this.parameters,
    this.targetOption = 'all',
  });
}

typedef ConnectSendTransportScreenType = Future<void> Function(
    ConnectSendTransportScreenOptions options);

Future<void> connectLocalSendTransportScreen({
  required MediaStream stream,
  required ConnectSendTransportScreenParameters parameters,
}) async {
  try {
    Producer? localScreenProducer = parameters.localScreenProducer;
    Transport? localProducerTransport = parameters.localProducerTransport;
    Device? device = parameters.device;
    final updateLocalScreenProducer = parameters.updateLocalScreenProducer;
    final updateLocalProducerTransport =
        parameters.updateLocalProducerTransport;

    // Find VP9 codec in device capabilities
    RtpCodecCapability? codec = device?.rtpCapabilities.codecs
        .firstWhere((codec) => codec.mimeType.toLowerCase() == 'video/vp9');

    // If no VP9 codec is found, get the first video codec
    codec ??= device?.rtpCapabilities.codecs.firstWhere(
        (codec) => codec.kind == RTCRtpMediaType.RTCRtpMediaTypeVideo);

    // Produce local screen share data
    if (localProducerTransport != null) {
      localProducerTransport.produce(
        track: stream.getVideoTracks()[0],
        stream: stream,
        codec: codec,
        appData: {'mediaTag': 'screen-video'},
        source: 'screen',
      );

      // Update the local producer and transport objects
      if (updateLocalScreenProducer != null) {
        updateLocalScreenProducer(localScreenProducer);
      }
      if (updateLocalProducerTransport != null) {
        updateLocalProducerTransport(localProducerTransport);
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error connecting local screen transport: $error');
    }
    rethrow; // Re-throw to propagate the error
  }
}

/// Sets up and initiates the screen-sharing transport connection, configuring codec options and producing a video track for screen sharing.
///
/// ### Parameters:
/// - `options` (`ConnectSendTransportScreenOptions`): Contains:
///   - `targetOption` (`String`): Specifies the target option for connection ('all' by default).
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
///   targetOption: 'all',
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
  final String targetOption = options.targetOption;
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
    if (targetOption == 'remote' || targetOption == 'all') {
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
    }

    if (targetOption == 'local' || targetOption == 'all') {
      try {
        await connectLocalSendTransportScreen(
          stream: stream,
          parameters: parameters,
        );
      } catch (localError) {
        if (kDebugMode) {
          print('Error connecting local screen transport: $localError');
        }
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('connectSendTransportScreen error: $error');
    }
    // throw error;
  }
}
