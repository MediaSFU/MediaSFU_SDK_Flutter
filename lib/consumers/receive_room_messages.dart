import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart'
    as io; // Import socket_io_client

/// Retrieves room messages from the server using a socket connection.
///
/// This function takes a [socket] and [parameters] as input and retrieves
/// messages for a specific room from the server. The retrieved messages are
/// then passed to the [updateMessages] callback function for further processing.
///
/// Example usage:
/// ```dart
/// io.Socket socket = ...; // Create a socket connection
/// Map<String, dynamic> parameters = {
///   'roomName': 'exampleRoom',
///   'updateMessages': (List<dynamic> messages) {
///     // Handle received messages
///   },
/// };
/// await receiveRoomMessages(socket: socket, parameters: parameters);

typedef UpdateMessages = void Function(List<dynamic> messages);

Future<void> receiveRoomMessages(
    {required io.Socket socket,
    required Map<String, dynamic> parameters}) async {
  String roomName = parameters['roomName'];
  UpdateMessages updateMessages = parameters['updateMessages'];

  try {
    // Retrieve messages from the server
    socket.emitWithAck("getMessage", {"roomName": roomName},
        ack: (dynamic responseData) async {
      var messages_ = responseData["messages_"];
      updateMessages(messages_);
    });
  } catch (error) {
    // Handle errors if any
    if (kDebugMode) {
      print("MediaSFU - Error receiving messages: $error");
    }
  }
}
