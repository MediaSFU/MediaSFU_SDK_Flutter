import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show MediaStream, Transport, Consumer;
import '../types/types.dart'
    show
        ConsumerResumeType,
        ConsumerResumeParameters,
        TransportType,
        ConsumerResumeOptions;

/// Parameters for connecting the receiving transport.
abstract class ConnectRecvTransportParameters
    implements ConsumerResumeParameters {
  List<TransportType> get consumerTransports;
  void Function(List<TransportType> transports) get updateConsumerTransports;

  // mediasfu functions
  ConsumerResumeType get consumerResume;
  ConnectRecvTransportParameters Function() get getUpdatedAllParams;

  /// Allows accessing additional dynamic properties.
  // dynamic operator [](String key);
}

/// Options for connecting the receiving transport.
class ConnectRecvTransportOptions {
  final Consumer consumer;
  final Transport consumerTransport;
  final String remoteProducerId;
  final String serverConsumerTransportId;
  final io.Socket nsock;
  final ConnectRecvTransportParameters parameters;

  ConnectRecvTransportOptions({
    required this.consumer,
    required this.consumerTransport,
    required this.remoteProducerId,
    required this.serverConsumerTransportId,
    required this.nsock,
    required this.parameters,
  });
}

/// Type definition for the [connectRecvTransport] function.
typedef ConnectRecvTransportType = Future<void> Function(
    ConnectRecvTransportOptions options);

/// Establishes a connection for the receiving transport to consume media from a remote producer and resumes the consumer stream.
///
/// ### Parameters:
/// - `options` (`ConnectRecvTransportOptions`): Contains all necessary details to connect and manage the receiving transport:
///   - `consumer` (`Consumer`): The media consumer instance.
///   - `consumerTransport` (`Transport`): The transport associated with the consumer.
///   - `remoteProducerId` (`String`): The ID of the producer being consumed.
///   - `serverConsumerTransportId` (`String`): The server-generated transport ID.
///   - `nsock` (`io.Socket`): The socket instance for real-time communication.
///   - `parameters` (`ConnectRecvTransportParameters`): Includes parameters for updating transports, resuming the consumer, and device details.
///
/// ### Workflow:
/// 1. **Consumption Initiation**: Emits a `consume` event to the socket to initiate media consumption, passing in the device's `rtpCapabilities`.
/// 2. **Consumer Transport Management**: Adds the transport and consumer details to the `consumerTransports` list for tracking active connections.
/// 3. **Stream Resumption**: If the consumer is successfully created, emits a `consumer-resume` event to resume media reception and triggers `consumerResume` to update the UI and media handling.
///
/// ### Returns:
/// - A `Future<void>` that completes once the transport is connected and the consumer is resumed.
///
/// ### Example Usage:
/// ```dart
/// final options = ConnectRecvTransportOptions(
///   consumer: myConsumer,
///   consumerTransport: myConsumerTransport,
///   remoteProducerId: 'producer-id-123',
///   serverConsumerTransportId: 'transport-id-abc',
///   nsock: mySocket,
///   parameters: myConnectRecvTransportParameters,
/// );
///
/// connectRecvTransport(options).then(() {
///   print('Receiving transport connected and consumer resumed');
/// }).catchError((error) {
///   print('Error connecting transport: $error');
/// });
/// ```
///
/// ### Error Handling:
/// - Logs any errors encountered during the consumption or resumption process in debug mode.

Future<void> connectRecvTransport(ConnectRecvTransportOptions options) async {
  var parameters = options.parameters.getUpdatedAllParams();

  // Extract parameters
  final consumer = options.consumer;
  final consumerTransports = parameters.consumerTransports;
  final updateConsumerTransports = parameters.updateConsumerTransports;
  final consumerResume = parameters.consumerResume;

  final nsock = options.nsock;
  final consumerTransport = options.consumerTransport;
  final remoteProducerId = options.remoteProducerId;
  final serverConsumerTransportId = options.serverConsumerTransportId;

  try {
    // Update consumerTransports array with the new consumer
    consumerTransports.add(TransportType(
      consumerTransport: consumerTransport,
      serverConsumerTransportId: serverConsumerTransportId,
      producerId: remoteProducerId,
      consumer: consumer,
      socket_: nsock,
    ));

    updateConsumerTransports(consumerTransports);

    // Extract track from the consumer
    MediaStream stream = consumer.stream;

    // Emit 'consumer-resume' event to signal consumer resumption
    nsock.emitWithAck('consumer-resume', {
      'serverConsumerId': consumer.id,
    }, ack: (resumeData) async {
      if (resumeData['resumed'] == true) {
        // Consumer resumed and ready to be used
        try {
          await consumerResume(ConsumerResumeOptions(
            stream: stream,
            kind: consumer.kind ?? '',
            remoteProducerId: remoteProducerId,
            parameters: parameters,
            nsock: nsock,
          ));
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
      print('consume error: $error');
    }
  }
}
