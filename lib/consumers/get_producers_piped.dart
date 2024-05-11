import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Retrieves producers and signals new consumer transport for each retrieved producer.
///
/// This function takes in a socket, islevel, and parameters as required arguments.
/// It emits a 'getProducersPipedAlt' event to the server with the islevel and member parameters.
/// The server responds with a list of producerIds, which are then used to signal new consumer transport.
///
/// The [signalNewConsumerTransport] callback function is called for each retrieved producer.
/// It takes in the socket, remoteProducerId, islevel, and parameters as required arguments.
///
/// Throws an error if there is an issue retrieving the producers.

typedef SignalNewConsumerTransport = void Function({
  required io.Socket nsock,
  required String remoteProducerId,
  required String islevel,
  required Map<String, dynamic> parameters,
});

Future<void> getProducersPiped({
  required io.Socket nsock,
  required String islevel,
  required Map<String, dynamic> parameters,
}) async {
  try {
    final String member = parameters['member'];

    // mediasfu functions
    final SignalNewConsumerTransport signalNewConsumerTransport =
        parameters['signalNewConsumerTransport'];

    nsock.emitWithAck(
        'getProducersPipedAlt', {'islevel': islevel, 'member': member},
        ack: (dynamic producerIds) async {
      // Callback function to handle the server's response
      // It will be called when the server responds to the 'getProducersPipedAlt' event
      // The response data will be passed as the parameter 'producerIds'

      // Check if producers are retrieved
      if (producerIds is List && producerIds.isNotEmpty) {
        // Signal new consumer transport for each retrieved producer
        for (final id in producerIds) {
          signalNewConsumerTransport(
              nsock: nsock,
              remoteProducerId: id,
              islevel: islevel,
              parameters: parameters);
        }
      }
    });
  } catch (error) {
    // Handle errors during the process of retrieving producers
    if (kDebugMode) {
      print('Error getting piped producers: ${error.toString()}');
    }
    // throw error;
  }
}
