import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

/// Joins a room on the socket server.
///
/// This function takes in the necessary parameters to join a room on the socket server.
/// It performs input validation and emits the 'joinRoom' event to the server.
/// It returns a Future that completes with a Map containing the response data from the server.
Future<Map<String, dynamic>> joinRoom(
  io.Socket socket,
  String roomName,
  String islevel,
  String member,
  String sec,
  String apiUserName,
) async {
  try {
    // Validate inputs
    if (!(sec.isNotEmpty &&
        roomName.isNotEmpty &&
        islevel.isNotEmpty &&
        apiUserName.isNotEmpty &&
        member.isNotEmpty)) {
      throw Exception('Missing required parameters');
    }

    // Validate alphanumeric for roomName, apiUserName, and member
    if (!_validateAlphanumeric(roomName) ||
        !_validateAlphanumeric(apiUserName) ||
        !_validateAlphanumeric(member)) {
      throw Exception('Invalid roomName, apiUserName, or member');
    }

    // Validate roomName starts with 's' or 'p'
    if (!(roomName.startsWith('s') || roomName.startsWith('p'))) {
      throw Exception('Invalid roomName, must start with s or p');
    }

    // Validate other conditions for sec, roomName, islevel, apiUserName
    if (!(sec.length == 64 &&
        roomName.length >= 8 &&
        islevel.length == 1 &&
        apiUserName.length >= 6 &&
        (islevel == '0' || islevel == '1' || islevel == '2'))) {
      throw Exception('Invalid roomName, islevel, apiUserName, or secret');
    }

    // Emit the 'joinRoom' event and handle the acknowledgment
    return await _emitJoinRoom(
        socket, roomName, islevel, member, sec, apiUserName);
  } catch (error) {
    if (kDebugMode) {
      print('Error joining room: $error');
    }
    rethrow;
  }
}

/// Emits the 'joinRoom' event to the socket server and handles the acknowledgment.
///
/// This function is called by the [joinRoom] function to emit the 'joinRoom' event
/// to the socket server with the provided parameters. It returns a Future that
/// completes with a Map containing the response data from the server.
Future<Map<String, dynamic>> _emitJoinRoom(
  io.Socket socket,
  String roomName,
  String islevel,
  String member,
  String sec,
  String apiUserName,
) {
  final completer = Completer<Map<String, dynamic>>();
  socket.emitWithAck('joinRoom', [
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
        if (data['banned']) {
          throw Exception('User is banned.');
        }
        if (data['suspended']) {
          throw Exception('User is suspended.');
        }
        if (data['noAdmin']) {
          throw Exception('Host has not joined the room yet.');
        }
      }
      completer.complete(data);
    } catch (error) {
      completer.completeError(error);
    }
  });
  return completer.future;
}

/// Validates that a string contains only alphanumeric characters.
///
/// This function takes in a string and checks if it contains only alphanumeric characters.
/// It returns true if the string is alphanumeric, and false otherwise.
bool _validateAlphanumeric(String value) {
  final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
  return alphanumericRegex.hasMatch(value);
}
