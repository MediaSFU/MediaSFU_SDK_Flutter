import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../producers/producer_emits/join_room.dart'
    show joinRoom, JoinRoomOptions;
import '../../producers/producer_emits/join_con_room.dart'
    show joinConRoom, JoinConRoomOptions;
import '../../types/types.dart' show ResponseJoinRoom;

/// Represents options for joining a room client.
class JoinRoomClientOptions {
  final io.Socket? socket;
  final String roomName;
  final String islevel;
  final String member;
  final String sec;
  final String apiUserName;
  final bool consume;

  JoinRoomClientOptions({
    this.socket,
    required this.roomName,
    required this.islevel,
    required this.member,
    required this.sec,
    required this.apiUserName,
    this.consume = false, // Default to false
  });
}

typedef JoinRoomClientType = Future<ResponseJoinRoom> Function(
    JoinRoomClientOptions options);

/// Joins a room by emitting the `joinRoom` or `joinConRoom` event to the server using the provided socket.
///
/// This function uses `JoinRoomClientOptions` as input, selecting `joinRoom` if `consume` is false
/// and `joinConRoom` if `consume` is true. It returns a `ResponseJoinRoom` object containing data
/// from the server. If the process fails, an error is thrown and a message is logged in debug mode.
///
/// ### Example Usage:
/// ```dart
/// final options = JoinRoomClientOptions(
///   socket: io.Socket(),
///   roomName: 'meeting123',
///   islevel: '1',
///   member: 'user123',
///   sec: 'abc123',
///   apiUserName: 'user123',
///   consume: true,
/// );
///
/// try {
///   final response = await joinRoomClient(options);
///   print('Joined room successfully: ${response.roomId}');
/// } catch (error) {
///   print('Error joining room: $error');
/// }
/// ```
///
/// In this example:
/// - The function attempts to join `meeting123` using `joinConRoom` (since `consume` is true).
/// - If successful, it prints the `roomId` from `ResponseJoinRoom`. If not, it catches and logs the error.

Future<ResponseJoinRoom> joinRoomClient(JoinRoomClientOptions options) async {
  try {
    ResponseJoinRoom data;

    if (options.consume) {
      // Use `joinConRoom` for consuming
      final option = JoinConRoomOptions(
        socket: options.socket,
        roomName: options.roomName,
        islevel: options.islevel,
        member: options.member,
        sec: options.sec,
        apiUserName: options.apiUserName,
      );
      data = await joinConRoom(
        option,
      );
    } else {
      // Use `joinRoom` for non-consuming
      final option = JoinRoomOptions(
        socket: options.socket,
        roomName: options.roomName,
        islevel: options.islevel,
        member: options.member,
        sec: options.sec,
        apiUserName: options.apiUserName,
      );
      data = await joinRoom(
        option,
      );
    }

    return data;
  } catch (error) {
    if (kDebugMode) {
      print('Error joining room: $error');
    }
    throw Exception(
        'Failed to join the room. Please check your connection and try again.');
  }
}
