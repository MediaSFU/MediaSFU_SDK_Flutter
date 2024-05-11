import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Initiates the recording process by sending a 'startRecording' event to the server with the roomName and member information.
///
/// The [parameters] parameter is a map that contains the following required keys:
///   - 'roomName': A string representing the name of the room.
///   - 'member': A string representing the member information.
///   - 'socket': An instance of the socket to communicate with the server.
///
/// Throws an error if any of the required parameters are missing or if an error occurs during the process.
///
/// Example usage:
/// ```dart
/// startRecords(parameters: {
///   'roomName': 'room1',
///   'member': 'John Doe',
///   'socket': socket,
/// });
/// ```
void startRecords({
  required Map<String, dynamic> parameters,
}) async {
  try {
    // Destructure the parameters
    String roomName = parameters['roomName'];
    String member = parameters['member'];
    io.Socket socket = parameters['socket'];

    // Send the 'startRecording' event to the server with roomName and member information
    socket.emitWithAck('startRecordIng', {
      'roomName': roomName,
      'member': member,
    }, ack: (data) {
      // Handle the acknowledgment from the server
      if (data is Map && data['success'] == true) {
        // Handle success case
        if (kDebugMode) {
          print('Recording started: ${data['success']}');
        }
      } else {
        // Handle failure case
        if (kDebugMode) {
          print('Recording failed to start: ${data['success']}');
        }
      }
    });
  } catch (error) {
    if (kDebugMode) {
      print("Error in startRecording: $error");
    }
    // Handle error accordingly
  }
}
