import 'package:flutter/foundation.dart';
import '../../../types/types.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

/// Validates if a string is alphanumeric.
bool _validateAlphanumeric(String value) {
  final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
  return alphanumericRegex.hasMatch(value);
}

/// Options for joining a room.
class JoinRoomOptions {
  final io.Socket? socket;
  final String roomName;
  final String islevel;
  final String member;
  final String sec;
  final String apiUserName;

  JoinRoomOptions({
    this.socket,
    required this.roomName,
    required this.islevel,
    required this.member,
    required this.sec,
    required this.apiUserName,
  });
}

typedef JoinRoomType = Future<ResponseJoinRoom> Function(
    JoinRoomOptions options);

/// Joins a room on the socket server with specified options.
///
/// This function validates the input parameters, then emits a `joinRoom` event to the server.
/// It returns a `Future` that completes with the server’s response data or an error if validation fails
/// or if the server returns a specific status.
///
/// - Throws: `Exception` if input validation fails or if the user is banned, suspended, or if
///           the host has not joined the room yet.
///
/// - Returns: A `Future<Map<String, dynamic>>` containing the server's response data on success.
///
/// Example usage:
/// ```dart
/// final socket = io.io('https://your-socket-server.com', <String, dynamic>{
///   'transports': ['websocket'],
///   'autoConnect': false,
/// });
/// socket.connect();
///
/// final options = JoinRoomOptions(
///   socket: socket,
///   roomName: 's12345678',
///   islevel: '1',
///   member: 'User123',
///   sec: 'your-secure-key-here-64-characters-long',
///   apiUserName: 'apiUser',
/// );
///
/// try {
///   final response = await joinRoom(options);
///   print('Successfully joined room: $response');
/// } catch (e) {
///   print('Error joining room: $e');
/// }
/// ```
///
/// Parameters:
/// - [options] (`JoinRoomOptions`): The options for joining the room, including socket and user details.

Future<ResponseJoinRoom> joinRoom(JoinRoomOptions options) async {
  // Validate inputs
  if (!_validateInputs(options)) {
    throw Exception('Validation failed for input parameters.');
  }

  // Emit the 'joinRoom' event and return the response
  return await _emitJoinRoom(
    options.socket,
    options.roomName,
    options.islevel,
    options.member,
    options.sec,
    options.apiUserName,
  );
}

/// Validates the inputs for joining a room.
bool _validateInputs(JoinRoomOptions options) {
  // Check that required fields are non-empty
  if (options.sec.isEmpty ||
      options.roomName.isEmpty ||
      options.islevel.isEmpty ||
      options.apiUserName.isEmpty ||
      options.member.isEmpty) {
    if (kDebugMode) {
      print('Missing required parameters');
    }
    return false;
  }

  // Validate alphanumeric fields
  if (!_validateAlphanumeric(options.roomName) ||
      !_validateAlphanumeric(options.apiUserName) ||
      !_validateAlphanumeric(options.member)) {
    if (kDebugMode) {
      print('Invalid roomName, apiUserName, or member');
    }
    return false;
  }

  // Validate specific conditions for the inputs
  if (!(options.roomName.startsWith('s') || options.roomName.startsWith('p'))) {
    if (kDebugMode) {
      print('Invalid roomName, must start with "s" or "p"');
    }
    return false;
  }

  if (!(options.sec.length == 64 &&
      options.roomName.length >= 8 &&
      options.islevel.length == 1 &&
      options.apiUserName.length >= 6 &&
      ['0', '1', '2'].contains(options.islevel))) {
    if (kDebugMode) {
      print('Invalid roomName, islevel, apiUserName, or secret');
    }
    return false;
  }

  return true;
}

/// Emits the 'joinRoom' event to the socket server and handles the acknowledgment.
///
/// This function returns a Future that completes with a Map containing the server's response data.
Future<ResponseJoinRoom> _emitJoinRoom(
  io.Socket? socket,
  String roomName,
  String islevel,
  String member,
  String sec,
  String apiUserName,
) {
  final completer = Completer<ResponseJoinRoom>();

  socket!.emitWithAck('joinRoom', [
    {
      'roomName': roomName,
      'islevel': islevel,
      'member': member,
      'sec': sec,
      'apiUserName': apiUserName
    }
  ], ack: (data) {
    try {
      if (data['rtpCapabilities'] == null) {
        if (data['banned'] == true) {
          throw Exception('User is banned.');
        }
        if (data['suspended'] == true) {
          throw Exception('User is suspended.');
        }
        if (data['noAdmin'] == true) {
          throw Exception('Host has not joined the room yet.');
        }
      }
      completer.complete(ResponseJoinRoom.fromJson(data));
    } catch (error) {
      completer.completeError(error);
    }
  });

  return completer.future;
}
