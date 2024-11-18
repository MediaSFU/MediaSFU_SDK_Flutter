import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../types/types.dart'
    show
        SignalNewConsumerTransportParameters,
        SignalNewConsumerTransportType,
        SignalNewConsumerTransportOptions;

/// Parameters for signaling new consumer transport.
abstract class GetProducersPipedParameters
    implements SignalNewConsumerTransportParameters {
  // Properties as abstract getters
  String get member;
  SignalNewConsumerTransportType get signalNewConsumerTransport;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

/// Options for retrieving piped producers.
class GetProducersPipedOptions {
  final io.Socket nsock;
  final String islevel;
  final GetProducersPipedParameters parameters;

  GetProducersPipedOptions({
    required this.nsock,
    required this.islevel,
    required this.parameters,
  });
}

typedef GetProducersPipedType = Future<void> Function(
    GetProducersPipedOptions options);

/// Retrieves piped producers and signals new consumer transport for each retrieved producer.
///
/// Emits a `getProducersPipedAlt` event to the server using the provided [nsock] socket instance, [islevel] flag,
/// and [parameters]. The server responds with a list of producer IDs, and for each ID, this function calls
/// the `signalNewConsumerTransport` function in [parameters] to handle the new consumer transport.
///
/// - [options] (`GetProducersPipedOptions`): The options for the operation, including the socket instance, level,
///   and additional parameters.
///
/// Example:
/// ```dart
/// final parameters = GetProducersPipedParameters(
///   member: 'memberId',
///   signalNewConsumerTransport: (nsock, remoteProducerId, islevel, parameters) async {
///     // Implementation for signaling new consumer transport
///   },
/// );
///
/// await getProducersPiped(
///   options: GetProducersPipedOptions(
///     nsock: socketInstance,
///     islevel: '1',
///     parameters: parameters,
///   ),
/// );
/// ```
///
/// Throws:
/// Logs and rethrows any errors encountered during the operation.
Future<void> getProducersPiped({
  required GetProducersPipedOptions options,
}) async {
  try {
    final nsock = options.nsock;
    final islevel = options.islevel;
    final parameters = options.parameters;
    final member = parameters.member;
    final signalNewConsumerTransport = parameters.signalNewConsumerTransport;

    // Emit request to get piped producers
    nsock.emitWithAck(
      'getProducersPipedAlt',
      {'islevel': islevel, 'member': member},
      ack: (dynamic producerIds) async {
        // Callback to handle the server response with producer IDs
        if (producerIds is List && producerIds.isNotEmpty) {
          for (final id in producerIds) {
            final options = SignalNewConsumerTransportOptions(
              nsock: nsock,
              remoteProducerId: id,
              islevel: islevel,
              parameters: parameters,
            );
            await signalNewConsumerTransport(options);
          }
        }
      },
    );
  } catch (error) {
    if (kDebugMode) {
      print('Error getting piped producers: ${error.toString()}');
    }
    rethrow;
  }
}
