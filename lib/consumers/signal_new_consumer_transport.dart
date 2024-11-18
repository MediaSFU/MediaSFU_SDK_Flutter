// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../types/types.dart'
    show
        ReorderStreamsParameters,
        ReorderStreamsType,
        ConnectRecvTransportType,
        ConnectRecvTransportParameters,
        ConnectRecvTransportOptions,
        GetVideosType,
        ReorderStreamsOptions,
        ConsumeResponse;

/// Parameters required for signaling a new consumer transport.
/// Extends [ReorderStreamsParameters] and [ConnectRecvTransportParameters].
abstract class SignalNewConsumerTransportParameters
    implements ReorderStreamsParameters, ConnectRecvTransportParameters {
  // Additional properties as abstract getters
  List<String> get consumingTransports;
  bool get lockScreen;
  Device? get device;

  // Update functions as an abstract getter
  void Function(List<String>) get updateConsumingTransports;

  // Mediasfu functions as abstract getters
  ConnectRecvTransportType get connectRecvTransport;
  ReorderStreamsType get reorderStreams;
  GetVideosType get getVideos;

  // Method to get updated parameters
  SignalNewConsumerTransportParameters Function() get getUpdatedAllParams;

  // Allow any other key-value pairs
  // dynamic operator [](String key);
}

/// Options required for signaling a new consumer transport.
class SignalNewConsumerTransportOptions {
  String remoteProducerId;
  String islevel;
  io.Socket nsock;
  SignalNewConsumerTransportParameters parameters;

  SignalNewConsumerTransportOptions({
    required this.remoteProducerId,
    required this.islevel,
    required this.nsock,
    required this.parameters,
  });
}

/// Function type definition for signaling a new consumer transport.
typedef SignalNewConsumerTransportType = Future<void> Function(
    SignalNewConsumerTransportOptions options);

/// Signals the creation of a new consumer transport.
///
/// This function communicates with the server to create a new WebRTC transport for consuming media from a remote producer.
/// It handles the transport connection and consumption of media streams.
///
/// Throws an error if the signaling process fails.
///
/// Example usage:
/// ```dart
/// final options = SignalNewConsumerTransportOptions(
///   remoteProducerId: 'producer-id',
///   islevel: '1',
///   nsock: socketInstance,
///   parameters: SignalNewConsumerTransportParameters(
///     device: mediaDevice,
///     consumingTransports: [],
///     lockScreen: false,
///     updateConsumingTransports: (transports) => print('Consuming Transports: $transports'),
///     connectRecvTransport: connectRecvTransportFunction,
///     reorderStreams: reorderStreamsFunction,
///     getVideos: getVideosFunction,
///     getUpdatedAllParams: () => options.parameters,
///   ),
/// );
///
/// await signalNewConsumerTransport(options);
/// ```
///
Future<void> signalNewConsumerTransport(
    SignalNewConsumerTransportOptions options) async {
  var parameters = options.parameters;
  final updatedParameters = options.parameters.getUpdatedAllParams();
  Device? device = updatedParameters.device;
  List<String> consumingTransports =
      List<String>.from(updatedParameters.consumingTransports);
  bool lockScreen = parameters.lockScreen;

  // Update functions
  void Function(List<String>) updateConsumingTransports =
      parameters.updateConsumingTransports;

  // mediasfu functions
  ConnectRecvTransportType connectRecvTransport =
      parameters.connectRecvTransport;
  ReorderStreamsType reorderStreams = parameters.reorderStreams;

  try {
    // Check if already consuming
    if (consumingTransports.contains(options.remoteProducerId)) {
      return;
    }

    // Add remote producer ID to consumingTransports array
    consumingTransports.add(options.remoteProducerId);
    updateConsumingTransports(consumingTransports);

    // Emit createWebRtcTransport event to signal a new consumer
    Completer<Map<String, dynamic>> completer = Completer();

    options.nsock.emitWithAck(
        "createWebRtcTransport", {"consumer": true, "islevel": options.islevel},
        ack: (response) {
      if (response['params'] == null || response['params']['error'] != null) {
        completer.completeError(response['params']['error'] ?? 'Unknown error');
      } else {
        completer.complete(response['params']);
      }
    });

    Map<String, dynamic> webrtcTransportMap = await completer.future;

    // Proceed with the result
    late Transport consumerTransport;

    // Consumer callback function
    void consumerCallbackFunction(Consumer consumer, [dynamic accept]) async {
      accept({});

      // Connect the receiving transport
      final optionsConnect = ConnectRecvTransportOptions(
        consumer: consumer,
        consumerTransport: consumerTransport,
        remoteProducerId: options.remoteProducerId,
        serverConsumerTransportId: webrtcTransportMap['id'],
        nsock: options.nsock,
        parameters: updatedParameters,
      );
      await connectRecvTransport(
        optionsConnect,
      );
    }

    consumerTransport = device!.createRecvTransportFromMap(webrtcTransportMap,
        consumerCallback: consumerCallbackFunction);
    // Handle 'connect' event for the consumer transport
    // Note consumer id changes from serverConsumerTransportId to consumer.id -- very important
    consumerTransport.on('connect', (data) async {
      try {
        // Emit transport-recv-connect event to signal connection
        options.nsock.emit('transport-recv-connect', {
          'dtlsParameters': data['dtlsParameters'].toMap(),
          'serverConsumerTransportId': webrtcTransportMap['id'],
        });

        data['callback']();
      } catch (error) {
        if (kDebugMode) {
          print('transport-recv-connect error: $error');
        }

        // Handle error
        data['errback'](error);
      }
    });

    // Listen for connection state change
    consumerTransport.on('connectionstatechange', (state) async {
      switch (state) {
        case 'connecting':
          // Handle connecting state
          break;

        case 'connected':
          // Handle connected state
          break;

        case 'failed':
          // Handle failed state
          await consumerTransport.close();

          //Reorder streams based on conditions
          if (lockScreen) {
            final optionsReorder = ReorderStreamsOptions(
              add: true,
              screenChanged: false,
              parameters: updatedParameters,
            );
            await reorderStreams(optionsReorder);
          } else {
            final optionsReorder = ReorderStreamsOptions(
              parameters: updatedParameters,
            );
            await reorderStreams(
              optionsReorder,
            );
          }
          break;

        default:
          break;
      }
    });

    // Emit consume event to signal consumption
    Completer<ConsumeResponse> consumeCompleter = Completer();
    try {
      options.nsock.emitWithAck('consume', {
        'rtpCapabilities': device.rtpCapabilities.toMap(),
        'remoteProducerId': options.remoteProducerId,
        'serverConsumerTransportId': webrtcTransportMap['id'],
      }, ack: (dynamic response) {
        if (response['error'] != null) {
          // Handle error
          consumeCompleter.completeError(response['error']);
          return;
        } else {
          consumeCompleter
              .complete(ConsumeResponse.fromMap(response['params']));
        }
      });
    } catch (error) {
      if (kDebugMode) {
        print('MediaSFU - consume error: $error');
      }

      return;
    }

    // Wait for acknowledgment
    ConsumeResponse consumeParams = await consumeCompleter.future;

    // Consume media using received parameters
    consumerTransport.consume(
        id: consumeParams.id,
        producerId: consumeParams.producerId,
        peerId: consumeParams.producerId,
        kind: RTCRtpMediaTypeExtension.fromString(consumeParams.kind),
        rtpParameters: consumeParams.rtpParameters,
        accept: (param) {});
  } catch (error) {
    if (kDebugMode) {
      print('signalNewConsumerTransport error: $error');
    }

    // Handle error
    return;
  }
}
