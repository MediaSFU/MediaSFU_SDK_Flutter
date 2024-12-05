import 'package:socket_io_client/socket_io_client.dart' as io;

/// Defines the options for confirming the exit of a member from a room.
class ConfirmExitOptions {
  final io.Socket? socket;
  io.Socket? localSocket;
  final String member;
  final String roomName;
  final bool ban;

  ConfirmExitOptions({
    this.socket,
    this.localSocket,
    required this.member,
    required this.roomName,
    this.ban = false,
  });
}

/// Type definition for the function that confirms a member's exit.
typedef ConfirmExitType = Future<void> Function(ConfirmExitOptions options);

/// Confirms the exit of a member from a room and optionally bans them.
///
/// This function emits a socket event to disconnect the user from the specified room
/// and optionally bans them if [ban] is set to true.
///
/// Example:
/// ```dart
/// final options = ConfirmExitOptions(
///   socket: socketInstance,
///   localSocket: socketInstance,
///   member: "JohnDoe",
///   roomName: "Room123",
///   ban: true,
/// );
///
/// await confirmExit(options);
/// // Disconnects "JohnDoe" from "Room123" and bans them if specified.
/// ```
Future<void> confirmExit(ConfirmExitOptions options) async {
  // Emit a socket event to disconnect the user from the room
  options.socket!.emit('disconnectUser', {
    'member': options.member,
    'roomName': options.roomName,
    'ban': options.ban,
  });

  if (options.localSocket != null && options.localSocket!.id != null) {
    options.localSocket!.emit('disconnectUser', {
      'member': options.member,
      'roomName': options.roomName,
      'ban': options.ban,
    });
  }
}
