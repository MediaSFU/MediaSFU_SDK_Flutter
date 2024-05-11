import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';

/// Connects the send transport based on the specified option.
///
/// The [option] parameter specifies the type of transport to connect:
/// - 'audio': Connects the audio send transport.
/// - 'video': Connects the video send transport.
/// - 'screen': Connects the screen send transport.
///
/// The [parameters] parameter is a map of parameters required for the connection.
///
/// Throws an error if there is an issue with the connection.

typedef ConnectSendTransportAudio = Future<void> Function({
  required dynamic audioParams,
  required Map<String, dynamic> parameters,
});

typedef ConnectSendTransportVideo = Future<void> Function({
  required dynamic videoParams,
  required Map<String, dynamic> parameters,
});

typedef ConnectSendTransportScreen = Future<void> Function({
  required MediaStream stream,
  required Map<String, dynamic> parameters,
});

Future<void> connectSendTransport({
  required String option,
  required Map<String, dynamic> parameters,
}) async {
  try {
    final dynamic audioParams =
        parameters['getUpdatedAllParams']()['audioParams'];
    final dynamic videoParams =
        parameters['getUpdatedAllParams']()['videoParams'];
    final MediaStream? localStreamScreen =
        parameters['getUpdatedAllParams']()['localStreamScreen'];

    // mediasfu functions
    final ConnectSendTransportAudio connectSendTransportAudio =
        parameters['connectSendTransportAudio'];
    final ConnectSendTransportVideo connectSendTransportVideo =
        parameters['connectSendTransportVideo'];
    final ConnectSendTransportScreen connectSendTransportScreen =
        parameters['connectSendTransportScreen'];

    // Connect send transport based on the specified option
    if (option == 'audio') {
      await connectSendTransportAudio(
          audioParams: audioParams!, parameters: parameters);
    } else if (option == 'video') {
      await connectSendTransportVideo(
          videoParams: videoParams!, parameters: parameters);
    } else if (option == 'screen') {
      try {
        await connectSendTransportScreen(
            stream: localStreamScreen!, parameters: parameters);
      } catch (error) {
        if (kDebugMode) {
          print('MediaSFU - Error starting screen share: $error');
        }
      }
    } else {
      // Connect both audio and video send transports
      await connectSendTransportAudio(
          audioParams: audioParams!, parameters: parameters);
      await connectSendTransportVideo(
          videoParams: videoParams!, parameters: parameters);
    }
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - connectSendTransport error: $error');
    }
    // throw error;
  }
}
