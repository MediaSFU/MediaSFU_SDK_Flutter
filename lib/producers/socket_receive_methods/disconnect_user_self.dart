import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Function to initiate the disconnection of the user (self) from the room, often used when banning a user.
///
/// Parameters:
/// - `parameters`: A map containing the required parameters for disconnection.
///   - `member`: The member to be disconnected.
///   - `roomName`: The name of the room from which the member should be disconnected.
///   - `socket`: The socket connection to the server.
///
/// Throws:
/// - Throws an exception if any of the required parameters are missing.
///
/// Example usage:
/// ```dart
/// await disconnectUserSelf(parameters: {
///   'member': 'JohnDoe',
///   'roomName': 'Room1',
///   'socket': socket,
/// });
/// ```
Future<void> disconnectUserSelf({
  required Map<String, dynamic> parameters,
}) async {
  // Destructure parameters
  final String member = parameters['member'];
  final String roomName = parameters['roomName'];
  final io.Socket socket = parameters['socket'];

  // Update that the user needs to be disconnected; this is initiated by the host when banning a user
  socket.emit(
      'disconnectUser', {'member': member, 'roomName': roomName, 'ban': true});
}
