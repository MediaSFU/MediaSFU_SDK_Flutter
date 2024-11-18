import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Options for disconnecting the user (self) from a specified room.
class DisconnectUserSelfOptions {
  final String member;
  final String roomName;
  final io.Socket? socket;

  DisconnectUserSelfOptions({
    required this.member,
    required this.roomName,
    this.socket,
  });
}

typedef DisconnectUserSelfType = Future<void> Function(
    DisconnectUserSelfOptions options);

/// Disconnects the user from the specified room and bans them.
///
/// Takes an instance of [DisconnectUserSelfOptions] which includes:
/// - [member]: The member identifier to disconnect.
/// - [roomName]: The name of the room from which the user will be disconnected.
/// - [socket]: The socket instance to emit the disconnection request.
///
/// Example:
/// ```dart
/// await disconnectUserSelf(DisconnectUserSelfOptions(
///   member: "user123",
///   roomName: "main-room",
///   socket: socketInstance,
/// ));
/// ```
Future<void> disconnectUserSelf(DisconnectUserSelfOptions options) async {
  // Emit the disconnection request to the socket, indicating that the user is being banned.
  options.socket!.emit(
    'disconnectUser',
    {
      'member': options.member,
      'roomName': options.roomName,
      'ban': true,
    },
  );
}
