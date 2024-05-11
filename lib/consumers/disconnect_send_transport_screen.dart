import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Disconnects the send transport for screen sharing.
///
/// This function closes the screen producer and notifies the server about
/// closing the screen producer and pausing screen sharing.
///
/// Parameters:
/// - `parameters`: A map of parameters containing the following keys:
///   - `getUpdatedAllParams`: A function that returns an updated map of parameters.
///   - `screenProducer`: The screen producer to be closed.
///   - `socket`: The socket connection to the server.
///   - `roomName`: The name of the room.
///
/// Throws:
/// - Any error that occurs during the disconnection process.

typedef UpdateScreenProducer = void Function(dynamic screenProducer);
typedef GetUpdatedAllParams = Map<String, dynamic> Function();

Future<void> disconnectSendTransportScreen(
    {required Map<String, dynamic> parameters}) async {
  try {
    // Destructure parameters
    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];

    parameters = getUpdatedAllParams();

    dynamic screenProducer = parameters['screenProducer'];
    final io.Socket socket = parameters['socket'];
    String roomName = parameters['roomName'];

    // Close the screen producer and update the state
    await screenProducer.close();

    // Notify the server about closing the screen producer and pausing screen sharing
    socket.emit('closeScreenProducer');
    socket.emit(
        'pauseProducerMedia', {'mediaTag': 'screen', 'roomName': roomName});
  } catch (error) {
    // Handle errors during the disconnection process
    if (kDebugMode) {
      // print('Error disconnecting send transport for screen: ${error.toString()}');
    }
  }
}
