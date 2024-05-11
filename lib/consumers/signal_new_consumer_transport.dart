import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';

/// Signals a new consumer transport for consuming media from a remote producer.
///
/// The [remoteProducerId] is the ID of the remote producer.
/// The [islevel] is the level of the consumer.
/// The [nsock] is the socket for communication.
/// The [parameters] is a map of parameters including callbacks and transports.
///
/// This function establishes a connection with the remote producer and consumes media using the received parameters.
/// It also handles connection state changes and reorders streams based on conditions.
///
/// Throws an error if an error occurs during the process.
///
/// Definitions:
/// - GetUpdatedAllparameters: Function type to retrieve updated parameters.
/// - ReorderStreams: Function type to reorder streams.
/// - SignalNewConsumerTransport: Function type to signal a new consumer transport.
/// - UpdateConsumingTransports: Function type to update consuming transports.
/// - ConnectRecvTransport: Function type to connect a receiving transport.
///

typedef GetUpdatedAllparameters = Map<String, dynamic> Function();

typedef ReorderStreams = Future<void> Function({
  bool add,
  bool screenChanged,
  required Map<String, dynamic> parameters,
});

typedef SignalNewConsumerTransport = Future<List<String>> Function({
  required String remoteProducerId,
  required String islevel,
  required io.Socket nsock,
  required Map<String, dynamic> parameters,
});

typedef UpdateConsumingTransports = void Function(
    List<dynamic> consumingTransports);

typedef ConnectRecvTransport = Future<void> Function({
  required Consumer consumer,
  required dynamic consumerTransport,
  required String remoteProducerId,
  required String serverConsumerTransportId,
  required io.Socket nsock,
  required Map<String, dynamic> parameters,
});

Future<void> signalNewConsumerTransport(
    {required String remoteProducerId,
    required String islevel,
    required io.Socket nsock,
    required Map<String, dynamic> parameters}) async {
  try {
    // Get parameters from the parameters map
    GetUpdatedAllparameters getUpdatedAllParams =
        parameters['getUpdatedAllParams'];

    Device? device = getUpdatedAllParams()['device'];
    List<dynamic> consumingTransports =
        getUpdatedAllParams()['consumingTransports'];
    bool? lockScreen = parameters['lockScreen'];
    UpdateConsumingTransports updateConsumingTransports =
        parameters['updateConsumingTransports'];

    // mediasfu functions
    ConnectRecvTransport connectRecvTransport =
        parameters['connectRecvTransport'];
    ReorderStreams reorderStreams = parameters['reorderStreams'];

    // Check if already consuming
    if (consumingTransports.contains(remoteProducerId)) {
      return;
    }

    // Add remote producer ID to consumingTransports array
    consumingTransports.add(remoteProducerId);
    updateConsumingTransports(consumingTransports);

    // Emit createWebRtcTransport event to signal a new consumer
    Completer completer = Completer();
    nsock.emitWithAck(
        'createWebRtcTransport', {'consumer': true, 'islevel': islevel},
        ack: (dynamic params) {
      if (params['error'] != null) {
        // Handle error
        completer.completeError('Error occurred: ${params['error']}');
      } else {
        completer.complete(params);
      }
    });
    var webrtcTransport = await completer.future;

    // Proceed with the result
    late Transport consumerTransport;
    late dynamic params;

    // Consumer callback function
    void consumerCallbackFunction(Consumer consumer, [dynamic accept]) async {
      accept({});

      // // Connect the receiving transport
      await connectRecvTransport(
        consumer: consumer,
        consumerTransport: consumerTransport,
        remoteProducerId: remoteProducerId,
        serverConsumerTransportId: params['params']['id'],
        nsock: nsock,
        parameters: parameters,
      );
    }

    consumerTransport = device!.createRecvTransportFromMap(
        webrtcTransport['params'],
        consumerCallback: consumerCallbackFunction);

    // Handle 'connect' event for the consumer transport
    consumerTransport.on('connect', (data) async {
      try {
        // Emit transport-recv-connect event to signal connection
        nsock.emit('transport-recv-connect', {
          'dtlsParameters': data['dtlsParameters'].toMap(),
          'serverConsumerTransportId': webrtcTransport['params']['id'],
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
          if (lockScreen!) {
            await reorderStreams(
                add: true, screenChanged: false, parameters: parameters);
          } else {
            await reorderStreams(
                add: false, screenChanged: false, parameters: parameters);
          }
          break;

        default:
          break;
      }
    });

    // Emit consume event to signal consumption
    Completer completer_ = Completer();
    try {
      nsock.emitWithAck('consume', {
        'rtpCapabilities': device.rtpCapabilities.toMap(),
        'remoteProducerId': remoteProducerId,
        'serverConsumerTransportId': webrtcTransport['params']['id'],
      }, ack: (dynamic params) {
        if (params['error'] != null) {
          // Handle error
          completer_.completeError(params['error']);
          return;
        } else {
          completer_.complete(params);
        }
      });
    } catch (error) {
      if (kDebugMode) {
        print('MediaSFU - consume error: $error');
      }

      return;
    }

    // Wait for acknowledgment
    params = await completer_.future;

    // Consume media using received parameters
    consumerTransport.consume(
        id: params['params']['id'],
        producerId: params['params']['producerId'],
        peerId: params['params']['producerId'],
        kind: RTCRtpMediaTypeExtension.fromString(params['params']['kind']),
        rtpParameters: RtpParameters.fromMap(params['params']['rtpParameters']),
        accept: (param) {});
  } catch (error) {
    if (kDebugMode) {
      print('signalNewConsumerTransport error: $error');
    }

    // Handle error
    return;
  }
}
