import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async'; // Import async library for Completer

/// Joins the event room with the specified parameters.
///
/// This function emits the 'joinConRoom' event to the provided [socket] with the given [roomName],
/// [islevel], [member], [sec], and [apiUserName]. It returns a [Future] that completes with a
/// [Map<String, dynamic>] containing the data received from the acknowledgment.
///
/// If the [rtpCapabilities] in the acknowledgment data is null, it checks for banned, suspended,
/// or noAdmin status and throws an [Exception] accordingly.
///
/// If any exception occurs during the process, the [Completer] completes with an error.
///
/// If [kDebugMode] is enabled, it prints the error message when joining the consume room fails.
///
/// Example usage:
/// ```dart
/// final socket = io.Socket();
/// final roomName = 'room1';
/// final islevel = 'level1';
/// final member = 'member1';
/// final sec = 'secret';
/// final apiUserName = 'user1';
///
/// final result = await joinConRoom(socket, roomName, islevel, member, sec, apiUserName);
/// print(result);
/// ```

Future<Map<String, dynamic>> joinConRoom(
  io.Socket socket,
  String roomName,
  String islevel,
  String member,
  String sec,
  String apiUserName,
) async {
  try {
    // Validate inputs (same as before)

    final Completer<Map<String, dynamic>> completer =
        Completer(); // Create a Completer

    // Emit the 'joinConRoom' event with Acknowledgment
    socket.emitWithAck('joinConRoom', [
      {
        'roomName': roomName,
        'islevel': islevel,
        'member': member,
        'sec': sec,
        'apiUserName': apiUserName
      }
    ], ack: (data) {
      try {
        // Check if rtpCapabilities is null (same as before)
        if (data['rtpCapabilities'] == null) {
          // Check if banned, suspended, or noAdmin (same as before)
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
        completer.complete(
            data); // Resolve the Completer with the data received from the acknowledgment
      } catch (error) {
        completer.completeError(
            error); // Complete the Completer with an error if any exception occurs
      }
    });

    return completer.future; // Return the Future from the Completer
  } catch (error) {
    if (kDebugMode) {
      print('Error joining consume room: $error');
    }
    rethrow;
  }
}
