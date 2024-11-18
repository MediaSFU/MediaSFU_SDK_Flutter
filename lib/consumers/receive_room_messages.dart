import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../types/types.dart' show Message;

/// Function to update messages
typedef UpdateMessages = void Function(List<Message> messages);

/// Options for receiving room messages
class ReceiveRoomMessagesOptions {
  final io.Socket? socket;
  final String roomName;
  final UpdateMessages updateMessages;

  ReceiveRoomMessagesOptions({
    this.socket,
    required this.roomName,
    required this.updateMessages,
  });
}

typedef ReceiveRoomMessagesType = Future<void> Function(
    ReceiveRoomMessagesOptions options);

/// Retrieves messages from a specified room using a socket connection.
///
/// The [ReceiveRoomMessagesOptions] contains the following keys:
/// - [socket]: The socket connection to communicate with the server.
/// - [roomName]: The name of the room for which messages are to be retrieved.
/// - [updateMessages]: Callback to update the message list with retrieved messages.
///
/// Example usage:
/// ```dart
/// final options = ReceiveRoomMessagesOptions(
///   socket: socket,
///   roomName: 'Room1',
///   updateMessages: (messages) => print(messages),
/// );
/// await receiveRoomMessages(options);
/// ```
///
Future<void> receiveRoomMessages(ReceiveRoomMessagesOptions options) async {
  try {
    // Request messages from the server
    options.socket!.emitWithAck(
      "getMessage",
      {"roomName": options.roomName},
      ack: (responseData) async {
        if (responseData != null && responseData["messages_"] is List) {
          // Ensure messages_ is a list of Message objects

          List<Message>? messages;

          messages = (responseData["messages_"] as List<dynamic>)
              .map((item) => Message.fromMap(item as Map<String, dynamic>))
              .toList();

          options.updateMessages(messages);
        } else {
          if (kDebugMode) {
            print("Error: Invalid message format received.");
          }
        }
      },
    );
  } catch (error) {
    // Handle errors if any
    if (kDebugMode) {
      print("Error receiving messages: $error");
    }
  }
}
