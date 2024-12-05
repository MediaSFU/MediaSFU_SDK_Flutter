import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../../types/types.dart' show ProducerOptionsType;

abstract class ConnectSendTransportVideoParameters {
  Producer? get videoProducer;
  Transport? get producerTransport;
  // Local Transport and Producer
  Producer? get localVideoProducer;
  Transport? get localProducerTransport;
  String get islevel;
  bool get updateMainWindow;
  MediaStream? get localStream;
  MediaStream? get localStreamVideo;
  void Function(Producer? videoProducer) get updateVideoProducer;
  void Function(Producer? localVideoProducer)? get updateLocalVideoProducer;
  void Function(Transport? producerTransport) get updateProducerTransport;
  void Function(Transport? localProducerTransport)?
      get updateLocalProducerTransport;
  void Function(bool updateMainWindow) get updateUpdateMainWindow;
  void Function(MediaStream? localStreamVideo) get updateLocalStreamVideo;
  void Function(MediaStream? localStream) get updateLocalStream;
  ConnectSendTransportVideoParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

class ConnectSendTransportVideoOptions {
  final ProducerOptionsType videoParams;
  final Map<String, dynamic>? videoConstraints;
  final ConnectSendTransportVideoParameters parameters;
  final String targetOption; // 'all', 'local', 'remote'

  ConnectSendTransportVideoOptions({
    required this.videoParams,
    required this.parameters,
    this.videoConstraints,
    this.targetOption = 'all',
  });
}

typedef ConnectSendTransportVideoType = Future<void> Function(
    ConnectSendTransportVideoOptions options);

Future<void> connectLocalSendTransportVideo({
  required MediaStream stream,
  required MediaStreamTrack track,
  required List<RtpEncodingParameters> encodings,
  required ProducerCodecOptions codecOptions,
  RtpCodecCapability? codec,
  required ConnectSendTransportVideoParameters parameters,
}) async {
  try {
    Producer? localVideoProducer = parameters.localVideoProducer;
    Transport? localProducerTransport = parameters.localProducerTransport;
    final updateLocalVideoProducer = parameters.updateLocalVideoProducer;
    final updateLocalProducerTransport =
        parameters.updateLocalProducerTransport;

    // Produce local video data if transport exists
    if (localProducerTransport != null) {
      localProducerTransport.produce(
        track: track,
        stream: stream,
        encodings: encodings,
        codecOptions: codecOptions,
        codec: codec,
        source: 'webcam',
      );

      // Update local producer and transport
      if (updateLocalVideoProducer != null) {
        updateLocalVideoProducer(localVideoProducer);
      }
      if (updateLocalProducerTransport != null) {
        updateLocalProducerTransport(localProducerTransport);
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error connecting local video transport: $error');
    }
    rethrow; // Re-throw to propagate the error
  }
}

/// Establishes a video transport connection, configuring video encoding and codec options for video transmission.
///
/// This function handles existing video tracks, acquires new video media, and updates the local video stream state.
///
/// ### Parameters:
/// - `options` (`ConnectSendTransportVideoOptions`): Contains:
///   - `videoParams` (`ProducerOptionsType`): Options for encoding, codec settings, and bitrate for video transmission.
///   - `parameters` (`ConnectSendTransportVideoParameters`): Holds configurations, update functions, and current video producer and transport details.
///
/// ### Workflow:
/// 1. **Existing Video Track Cleanup**:
///    - Removes any pre-existing video tracks in `localStream` and `localStreamVideo` to avoid conflicts.
/// 2. **New Video Media Acquisition**:
///    - Acquires a new video media stream based on `videoConstraints`.
///    - Updates `localStream` and `localStreamVideo` with the newly acquired video stream.
/// 3. **Encoding and Codec Configuration**:
///    - Sets encoding parameters from `videoParams` if available, including `videoGoogleStartBitrate`.
///    - Selects the first video codec available on the device, or a VP9 codec if present, for optimized streaming.
/// 4. **Transport Production**:
///    - Produces the video track for the transport with specified encoding and codec options, initiating video transmission.
/// 5. **State Updates**:
///    - Updates `videoProducer`, `producerTransport`, and `updateMainWindow` in the `parameters` to reflect the active video transport state.
///
/// ### Returns:
/// - A `Future<void>` that resolves when the video transport connection is successfully established and streaming begins.
///
/// ### Example Usage:
/// ```dart
/// final videoOptions = ConnectSendTransportVideoOptions(
///   videoParams: ProducerOptionsType(
///     encodings: [{'rid': 'r0', 'maxBitrate': 1500000}],
///     codecOptions: ProducerCodecOptions(videoGoogleStartBitrate: 1000),
///     codec: myCodec,
///   ),
///   parameters: myConnectSendTransportVideoParameters,
/// );
///
/// connectSendTransportVideo(videoOptions).then(() {
///   print("Video transport connected successfully.");
/// }).catchError((error) {
///   print("Error connecting video transport: $error");
/// });
/// ```
///
/// ### Error Handling:
/// - Logs any connection errors to the console in debug mode.

Future<void> connectSendTransportVideo(
    ConnectSendTransportVideoOptions options) async {
  final ProducerOptionsType videoParams = options.videoParams;
  final ConnectSendTransportVideoParameters parameters = options.parameters;
  final Map<String, dynamic>? videoConstraints = options.videoConstraints;
  final String targetOption = options.targetOption;

  try {
    // Destructure parameters
    Producer? videoProducer = parameters.videoProducer;
    Transport? producerTransport = parameters.producerTransport;
    String islevel = parameters.islevel;
    bool updateMainWindow = parameters.updateMainWindow;

    void Function(Producer? videoProducer) updateVideoProducer =
        parameters.updateVideoProducer;

    MediaStream? localStream = parameters.localStream;
    MediaStream? localStreamVideo = parameters.localStreamVideo;
    void Function(MediaStream? localStreamVideo) updateLocalStreamVideo =
        parameters.updateLocalStreamVideo;
    void Function(MediaStream? localStream) updateLocalStream =
        parameters.updateLocalStream;

    //close the existing video track
    if (localStream != null) {
      List<MediaStreamTrack> videoTracks =
          localStream.getVideoTracks().toList();
      for (MediaStreamTrack track in videoTracks) {
        await localStream.removeTrack(track);
      }
    }

    if (localStreamVideo != null) {
      List<MediaStreamTrack> videoTracks =
          localStreamVideo.getVideoTracks().toList();
      for (MediaStreamTrack track in videoTracks) {
        await localStreamVideo.removeTrack(track);
      }
    }

    MediaStream stream = await navigator.mediaDevices
        .getUserMedia(videoConstraints ?? {'video': true});

    //Update the localStreamVideo
    updateLocalStreamVideo(stream);

    // Add video track to localStream
    if (localStream == null) {
      localStream = stream;

      // Update the localStream
      updateLocalStream(localStream);
    } else {
      // Remove existing video tracks from localStream
      for (MediaStreamTrack track in localStream.getVideoTracks().toList()) {
        await localStream.removeTrack(track);
      }

      // Add the new video track to the localStream
      await localStream.addTrack(stream.getVideoTracks().first);
      updateLocalStream(localStream);
    }
    void Function(Transport? producerTransport) updateProducerTransport =
        parameters.updateProducerTransport;
    var updateUpdateMainWindow = parameters.updateUpdateMainWindow;

    List<RtpEncodingParameters> convertToRtpEncodingParametersList(
        List<dynamic> encodings) {
      return encodings.map((encoding) {
        return RtpEncodingParameters(
          rid: encoding.rid,
          maxBitrate: encoding.maxBitrate?.round(),
          minBitrate: encoding.minBitrate?.round(),
          scalabilityMode: encoding.scalabilityMode,
          scaleResolutionDownBy: encoding.scaleResolutionDownBy?.toDouble(),
        );
      }).toList();
    }

    List<RtpEncodingParameters> encodingsList = [];

    try {
      List encodings = videoParams.encodings;
      encodingsList = convertToRtpEncodingParametersList(encodings);
      // ignore: empty_catches
    } catch (e) {}

    //get the first codec from the first video track
    if (targetOption == 'all' || targetOption == 'remote') {
      producerTransport?.produce(
        track: stream.getVideoTracks().first,
        stream: stream,
        encodings: encodingsList.length > 1 ? encodingsList : [],
        codecOptions: ProducerCodecOptions(
            videoGoogleStartBitrate:
                videoParams.codecOptions?.videoGoogleStartBitrate?.round()),
        codec: videoParams.codec,
        source: 'webcam',
      );

      // Update main window state based on video connection level
      if (islevel == '2') {
        updateMainWindow = true;
      }

      // Update video producer and transport state
      updateVideoProducer(videoProducer);
      updateProducerTransport(producerTransport);
      updateUpdateMainWindow(updateMainWindow);
    }

    if (targetOption == 'all' || targetOption == 'local') {
      try {
        await connectLocalSendTransportVideo(
          track: stream.getVideoTracks().first,
          stream: stream,
          encodings: encodingsList.length > 1 ? encodingsList : [],
          codecOptions: ProducerCodecOptions(
              videoGoogleStartBitrate:
                  videoParams.codecOptions?.videoGoogleStartBitrate?.round()),
          codec: videoParams.codec,
          parameters: parameters,
        );
      } catch (localError) {
        if (kDebugMode) {
          print('Error connecting local video transport: $localError');
        }
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('connectSendTransportVideo error: $error');
    }
    rethrow;
  }
}
