import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';

/// Connects the receiving transport to consume media.
///
/// This function establishes a connection between the receiving transport and the media consumer.
/// It adds the consumer to the list of consumer transports, updates the consumer transports array,
/// extracts the track from the consumer, and emits a 'consumer-resume' event to signal consumer resumption.
///
/// Parameters:
/// - `consumer`: The consumer object representing the media consumer.
/// - `consumerTransport`: The consumer transport object.
/// - `remoteProducerId`: The ID of the remote producer.
/// - `serverConsumerTransportId`: The ID of the server consumer transport.
/// - `nsock`: The socket object for communication.
/// - `parameters`: Additional parameters for the function.
///
/// Returns: A [Future] that completes when the connection is established.

/// Definition:
/// - ConsumerResume: Represents a function that resumes a consumer.
///   Parameters:
///     - stream: The media stream to resume.
///     - kind: The type of media (e.g., audio, video).
///     - remoteProducerId: The ID of the remote producer.
///     - parameters: Additional parameters needed for resuming.
///     - nsock: The socket connection.
/// connectRecvTransport(
///   consumer: myConsumer,
///   consumerTransport: myConsumerTransport,
///   remoteProducerId: 'remote_producer_id',
///   serverConsumerTransportId: 'server_consumer_transport_id',
///   nsock: mySocket,
///   parameters: {
///     'getUpdatedAllParams': getUpdatedAllParamsFunction,
///     'updateConsumerTransports': updateConsumerTransportsFunction,
///     'consumerResume': consumerResumeFunction,
///   },
/// );
///

typedef GetUpdatedAllparameters = Map<String, dynamic> Function();
typedef UpdateConsumerTransports = void Function(
    List<dynamic> consumerTransports);
typedef ConsumerResume = Future<void> Function({
  required MediaStream stream,
  required String kind,
  required String remoteProducerId,
  required Map<String, dynamic> parameters,
  required io.Socket nsock,
});

Future<void> connectRecvTransport({
  required Consumer consumer,
  required dynamic consumerTransport,
  required String remoteProducerId,
  required String serverConsumerTransportId,
  required io.Socket nsock,
  required Map<String, dynamic> parameters,
}) async {
  try {
    GetUpdatedAllparameters getUpdatedAllParams =
        parameters['getUpdatedAllParams'];

    List<dynamic> consumerTransports =
        getUpdatedAllParams()['consumerTransports'];
    UpdateConsumerTransports updateConsumerTransports =
        parameters['updateConsumerTransports'];

    // mediasfu functions
    ConsumerResume consumerResume = parameters['consumerResume'];

    // Update consumerTransports array with the new consumer
    consumerTransports.add({
      'consumerTransport': consumerTransport,
      'serverConsumerTransportId': serverConsumerTransportId,
      'producerId': remoteProducerId,
      'consumer': consumer,
      'socket_': nsock,
    });

    updateConsumerTransports(consumerTransports);

    // Extract track from the consumer
    MediaStream stream = consumer.stream;

    // Emit 'consumer-resume' event to signal consumer resumption
    nsock.emitWithAck('consumer-resume', {
      'serverConsumerId': consumer.id,
    }, ack: (dynamic data) async {
      if (data['resumed'] == true) {
        // Consumer resumed and ready to be used
        try {
          await consumerResume(
            stream: stream,
            kind: consumer.kind ?? '',
            remoteProducerId: remoteProducerId,
            parameters: parameters,
            nsock: nsock,
          );
        } catch (error) {
          // Handle error
          if (kDebugMode) {
            print('consumerResume error: $error');
          }
        }
      }
    });
  } catch (error) {
    // Handle error
    if (kDebugMode) {
      print('connectRecvTransport error: $error');
    }

    // throw new Error('Error connecting receiving transport to consume media.');
  }
}
