import 'package:socket_io_client/socket_io_client.dart' as io;

/// Confirms the exit of a user from a room.
///
/// This function emits a socket event to disconnect the user from the specified room.
/// The [socket] parameter is the socket connection to the server.
/// The [member] parameter is the name of the member who wants to exit the room.
/// The [roomName] parameter is the name of the room the member wants to exit from.
/// The [ban] parameter indicates whether the member should be banned from the room.
///
/// Example usage:
/// ```dart
/// await confirmExit(
///   socket: socket,
///   member: 'John',
///   roomName: 'Room 1',
///   ban: true,
/// );
///

Future<void> confirmExit({
  required io.Socket socket,
  required String member,
  required String roomName,
  bool ban = false,
}) async {
  // Emit a socket event to disconnect the user from the room
  socket.emit(
      'disconnectUser', {'member': member, 'roomName': roomName, 'ban': ban});
}
