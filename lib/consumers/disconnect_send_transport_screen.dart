import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';

/// Function typedefs for update and parameter retrieval
typedef UpdateScreenProducer = void Function(Producer? screenProducer);
typedef GetUpdatedAllParams = DisconnectSendTransportScreenParameters
    Function();

/// Represents the parameters required to disconnect the screen send transport.
abstract class DisconnectSendTransportScreenParameters {
  Producer? get screenProducer;
  io.Socket? get socket;
  String get roomName;

  UpdateScreenProducer get updateScreenProducer;
  GetUpdatedAllParams get getUpdatedAllParams;

  // Dynamic access to additional properties if needed
  // dynamic operator [](String key);
}

/// Represents the options required to disconnect the screen send transport.
class DisconnectSendTransportScreenOptions {
  final DisconnectSendTransportScreenParameters parameters;

  DisconnectSendTransportScreenOptions({
    required this.parameters,
  });
}

/// Type definition for disconnectSendTransportScreen function
typedef DisconnectSendTransportScreenType = Future<void> Function(
    DisconnectSendTransportScreenOptions options);

/// Disconnects the send transport for screen sharing by closing the screen producer and notifying the server.
///
/// This function handles the termination of screen-sharing functionality. It performs the following:
/// 1. **Closes the Screen Producer**:
///    - If there is an active `screenProducer`, it is closed to stop screen sharing on the client side.
///    - The producer state is then updated to reflect the closure.
/// 2. **Server Notification**:
///    - Notifies the server that the screen producer has been closed by emitting the `closeScreenProducer` event.
///    - Sends a `pauseProducerMedia` event with the media tag `screen` to pause screen sharing for the current room.
///
/// ### Parameters:
/// - `options` (`DisconnectSendTransportScreenOptions`): The options for disconnecting the screen send transport.
///   - Contains the required parameters, including the screen producer, socket, room name, and update function.
///
/// ### Error Handling:
/// - Catches and logs any errors that occur during the disconnection process.
/// - In debug mode, errors are printed to the console for troubleshooting.
///
/// ### Example Usage:
/// ```dart
/// final options = DisconnectSendTransportScreenOptions(
///   parameters: MyDisconnectSendTransportScreenParameters(
///     screenProducer: myScreenProducer,
///     socket: mySocket,
///     roomName: 'myRoom',
///     updateScreenProducer: (producer) => print('Screen producer updated: $producer'),
///     getUpdatedAllParams: () => myUpdatedParameters,
///   ),
/// );
///
/// disconnectSendTransportScreen(options).then((_) {
///   print('Screen sharing disconnected successfully');
/// }).catchError((error) {
///   print('Error disconnecting screen sharing: $error');
/// });
/// ```
///
/// ### Notes:
/// - This function relies on the server to handle `closeScreenProducer` and `pauseProducerMedia` events appropriately.
/// - It assumes that the server will process these events to update the screen-sharing status in the room.
///
/// ### Additional Considerations:
/// - Ensures that the state is updated by calling `updateScreenProducer(null)` after closing the producer.

Future<void> disconnectSendTransportScreen(
    DisconnectSendTransportScreenOptions options) async {
  try {
    // Retrieve and update parameters
    final parameters = options.parameters.getUpdatedAllParams();

    final Producer? screenProducer = parameters.screenProducer;
    final io.Socket? socket = parameters.socket;
    final String roomName = parameters.roomName;
    final UpdateScreenProducer updateScreenProducer =
        parameters.updateScreenProducer;

    // Close the screen producer and update the state
    if (screenProducer != null) {
      screenProducer.close();
      updateScreenProducer(null);
    }

    // Notify the server about closing the screen producer and pausing screen sharing
    socket!.emit('closeScreenProducer');
    socket.emit(
        'pauseProducerMedia', {'mediaTag': 'screen', 'roomName': roomName});
  } catch (error) {
    // Handle errors during the disconnection process
    if (kDebugMode) {
      print('Error disconnecting send transport for screen: $error');
    }
  }
}
