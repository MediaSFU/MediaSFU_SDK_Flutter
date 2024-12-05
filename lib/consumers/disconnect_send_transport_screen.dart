import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show Producer;

/// Dart equivalent of DisconnectSendTransportScreenParameters interface
abstract class DisconnectSendTransportScreenParameters {
  // Remote Screen Transport and Producer
  Producer? get screenProducer;
  io.Socket? get socket;

  // Local Screen Transport and Producer
  Producer? get localScreenProducer;
  io.Socket? get localSocket;

  // Other Parameters
  String get roomName;

  // Update Functions
  void Function(Producer? screenProducer) get updateScreenProducer;
  void Function(Producer? localScreenProducer)? get updateLocalScreenProducer;

  // Method to retrieve updated parameters
  DisconnectSendTransportScreenParameters Function() get getUpdatedAllParams;

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

/// Disconnects the local send transport for screen sharing by closing the local screen producer and notifying the server.
///
/// ### Parameters:
/// - `options` (`DisconnectSendTransportScreenOptions`): Contains the parameters required for disconnecting the local screen transport.
///
/// ### Workflow:
/// 1. **Close Local Screen Producer**:
///    - If an active local screen producer exists, it is closed.
///    - The local state is updated to reflect the closed producer.
/// 2. **Notify Server**:
///    - Emits `closeScreenProducer` and `pauseProducerMedia` events to the server to notify about the paused local screen producer.
///
/// ### Returns:
/// - A `Future<void>` that completes when the local screen transport is successfully disconnected.
///
/// ### Error Handling:
/// - Logs errors to the console in debug mode and rethrows them for higher-level handling.
///
/// ### Example Usage:
/// ```dart
/// final options = DisconnectSendTransportScreenOptions(
///   parameters: myDisconnectSendTransportScreenParameters,
/// );
///
/// disconnectLocalSendTransportScreen(options)
///   .then(() => print('Local screen send transport disconnected successfully'))
///   .catchError((error) => print('Error disconnecting local screen send transport: $error'));
/// ```
Future<void> disconnectLocalSendTransportScreen(
    DisconnectSendTransportScreenOptions options) async {
  try {
    final parameters = options.parameters;

    final Producer? localScreenProducer = parameters.localScreenProducer;
    final io.Socket? localSocket = parameters.localSocket;
    final String roomName = parameters.roomName;
    final void Function(Producer? localScreenProducer)?
        updateLocalScreenProducer = parameters.updateLocalScreenProducer;

    if (localSocket == null || localSocket.id == null) {
      // Local socket is not connected; nothing to disconnect
      return;
    }

    // Close the local screen producer and update the state
    if (localScreenProducer != null) {
      localScreenProducer.close();
      updateLocalScreenProducer?.call(null); // Set to null after closing
    }

    // Notify the server about closing the local screen producer and pausing screen sharing
    localSocket.emit('closeScreenProducer');
    localSocket.emit('pauseProducerMedia', {
      'mediaTag': 'screen',
      'roomName': roomName,
    });
  } catch (error) {
    if (kDebugMode) {
      print('Error disconnecting local send transport for screen: $error');
    }
    rethrow; // Re-throw to propagate the error
  }
}

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
///     localScreenProducer: myLocalScreenProducer,
///     socket: mySocket,
///     localSocket: myLocalSocket,
///     roomName: 'myRoom',
///     updateScreenProducer: (producer) => print('Screen producer updated: $producer'),
///     updateLocalScreenProducer: (producer) => print('Local screen producer updated: $producer'),
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
    final void Function(Producer? screenProducer) updateScreenProducer =
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

  // Handle local screen transport disconnection
  try {
    await disconnectLocalSendTransportScreen(options);
  } catch (localError) {
    if (kDebugMode) {
      print('Error disconnecting local send transport for screen: $localError');
    }
    // Optionally, handle the local error (e.g., show a notification)
  }
}
