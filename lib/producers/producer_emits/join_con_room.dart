import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import '../../types/types.dart' show ResponseJoinRoom;

/// Validates if a string is alphanumeric.
void validateAlphanumeric(String value, String fieldName) {
  if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
    throw Exception('Invalid $fieldName. It should be alphanumeric.');
  }
}

/// Options for joining a conference room.
class JoinConRoomOptions {
  final io.Socket? socket;
  final String roomName;
  final String islevel;
  final String member;
  final String sec;
  final String apiUserName;

  JoinConRoomOptions({
    this.socket,
    required this.roomName,
    required this.islevel,
    required this.member,
    required this.sec,
    required this.apiUserName,
  });
}

typedef JoinConRoomType = Future<ResponseJoinRoom> Function(
    JoinConRoomOptions options);

/// Joins a conference room with the provided options.
/// Validates the input parameters before attempting to join the room.
///
/// Example usage:
/// ```dart
/// final options = JoinConRoomOptions(
///   socket: socketInstance,
///   roomName: "s12345678",
///   islevel: "1",
///   member: "user123",
///   sec: "64CharacterLongSecretHere",
///   apiUserName: "user123",
/// );
///
/// try {
///   final response = await joinConRoom(options);
///   print("Room joined: ${response.success}");
/// } catch (error) {
///   print("Failed to join room: $error");
/// }
/// ```
///

Future<ResponseJoinRoom> joinConRoom(JoinConRoomOptions options) async {
  try {
    // Input validation
    if (options.sec.isEmpty ||
        options.roomName.isEmpty ||
        options.islevel.isEmpty ||
        options.apiUserName.isEmpty ||
        options.member.isEmpty) {
      throw Exception('Missing required parameters');
    }

    // Alphanumeric validation
    validateAlphanumeric(options.roomName, 'roomName');
    validateAlphanumeric(options.apiUserName, 'apiUserName');
    validateAlphanumeric(options.member, 'member');

    // Validate roomName prefix
    if (!(options.roomName.startsWith('s') ||
        options.roomName.startsWith('p'))) {
      throw Exception('Invalid roomName, must start with "s" or "p"');
    }

    // Additional constraints
    if (!(options.sec.length == 64 &&
        options.roomName.length >= 8 &&
        options.islevel.length == 1 &&
        options.apiUserName.length >= 6 &&
        (options.islevel == '0' ||
            options.islevel == '1' ||
            options.islevel == '2'))) {
      throw Exception(
          'Invalid roomName, islevel, apiUserName, or secret format');
    }

    final completer = Completer<ResponseJoinRoom>();

    // Emit the 'joinConRoom' event with acknowledgment handling
    options.socket!.emitWithAck('joinConRoom', {
      'roomName': options.roomName,
      'islevel': options.islevel,
      'member': options.member,
      'sec': options.sec,
      'apiUserName': options.apiUserName,
    }, ack: (data) {
      if (data['rtpCapabilities'] == null) {
        if (data['banned'] == true) {
          throw Exception('User is banned.');
        } else if (data['suspended'] == true) {
          throw Exception('User is suspended.');
        } else if (data['noAdmin'] == true) {
          throw Exception('Host has not joined the room yet.');
        } else {
          throw Exception('Failed to join room');
        }
      } else {
        completer.complete(ResponseJoinRoom.fromJson(data));
      }
    });

    return completer.future;
  } catch (error) {
    if (kDebugMode) {
      print('Error joining consume room: $error');
    }
    rethrow;
  }
}
