import 'package:socket_io_client/socket_io_client.dart' as io;
import '../get_piped_producers_alt.dart' show getPipedProducersAlt;

/// Creates and receives all piped transports for a given room and member using Socket.IO.
///
/// This function establishes a connection to the server using the provided Socket.IO socket [nsock],
/// and creates and receives all piped transports for the specified [roomName] and [member].
/// If there are existing producers, it calls the [getPipedProducersAlt] function for each option.
///
/// Parameters:
/// - [nsock]: The Socket.IO socket used to establish a connection to the server.
/// - [parameters]: A map containing the room name and member information.
///
/// Returns: A [Future] that completes when all piped transports have been created and received.
///
Future<void> createReceiveAllPipedTransports(
    {required io.Socket nsock,
    required Map<String, dynamic> parameters}) async {
  final String roomName = parameters['roomName'];
  final String member = parameters['member'];

  nsock.emitWithAck('createReceiveAllTransportsPiped',
      {'roomName': roomName, 'member': member}, ack: (dynamic data) async {
    // Callback function to handle the server's response
    // It will be called when the server responds to the 'createReceiveAllTransportsPiped' event
    // The response data will be passed as the parameter 'data'

    final bool producersExist = data['producersExist'];

    final List<String> options = ['0', '1', '2'];
    if (producersExist) {
      for (final String islevel in options) {
        await getPipedProducersAlt(
            nsock: nsock, islevel: islevel, parameters: parameters);
      }
    }
  });
}
