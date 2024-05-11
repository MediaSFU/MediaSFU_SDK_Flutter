// ignore_for_file: empty_catches

import 'dart:async';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Sends a message to the server.
///
/// The [parameters] map should contain the following keys:
/// - 'member': The member's name (optional, default: '').
/// - 'islevel': The level of the member (optional, default: '1').
/// - 'showAlert': A function to show an alert (optional).
/// - 'coHostResponsibility': A list of co-host responsibilities (optional, default: []).
/// - 'coHost': The co-host's name (optional, default: '').
/// - 'chatSetting': The chat setting (optional, default: '').
/// - 'message': The message to send (optional).
/// - 'roomName': The name of the room (optional, default: '').
/// - 'messagesLength': The length of the messages (optional, default: 0).
/// - 'receivers': A list of message receivers (optional, default: []).
/// - 'group': A flag indicating if it's a group message (optional, default: false).
/// - 'sender': The sender's name (optional).
/// - 'socket': The socket to communicate with the server.
///
/// The function checks the message count limit based on the room type and shows an alert if the limit is exceeded.
/// It validates the message, sender, and receivers and shows an alert if they are not valid.
/// It creates a message object with the sender, receivers, message, timestamp, and group flag.
/// It checks the co-host responsibility for chat and allows sending the message if the conditions are met.
/// If the user is not allowed to send a message in the event room, it shows an alert.
/// Finally, it sends the message to the server using the provided socket.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef CoHostResponsibility = List<dynamic>;

Future<void> sendMessage({required Map<String, dynamic> parameters}) async {
  final String member = parameters['member'] ?? '';
  final String islevel = parameters['islevel'] ?? '1';
  final ShowAlert? showAlert = parameters['showAlert'];
  final CoHostResponsibility coHostResponsibility =
      parameters['coHostResponsibility'] ?? [];
  final String coHost = parameters['coHost'] ?? '';
  final String chatSetting = parameters['chatSetting'] ?? '';
  final String? message = parameters['message'] ?? '';
  final String roomName = parameters['roomName'] ?? '';
  final int messagesLength = parameters['messagesLength'] ?? 0;
  final List receivers = parameters['receivers'] ?? [];
  final bool? group = parameters['group'] ?? false;
  final String? sender = parameters['sender'] ?? '';
  final io.Socket socket = parameters['socket'];

  bool chatValue = false;

  // Check message count limit based on the room type
  if ((messagesLength > 100 && roomName.startsWith('d')) ||
      (messagesLength > 500 && roomName.startsWith('s')) ||
      (messagesLength > 100000 && roomName.startsWith('p'))) {
    if (showAlert != null) {
      showAlert(
        message: 'You have reached the maximum number of messages allowed.',
        type: 'danger',
        duration: 3000,
      );
    }
    return;
  }

  // Validate message, sender, and receivers
  if (message == null || (member.isEmpty && sender == null)) {
    if (showAlert != null) {
      showAlert(
        message: 'Message is not valid.',
        type: 'danger',
        duration: 3000,
      );
    }
    return;
  }

  // Create the message object
  final messageObject = {
    'sender': sender != null && sender.isNotEmpty ? sender : member,
    'receivers': receivers,
    'message': message,
    'timestamp': DateFormat('HH:mm:ss').format(DateTime.now()),
    'group': group != null && group == true,
  };

  try {
    // Check co-host responsibility for chat
    chatValue = coHostResponsibility
        .firstWhere((item) => item['name'] == 'chat')['value'];
  } catch (error) {}

  if (islevel == '2' || (coHost == member && chatValue == true)) {
    // Allow sending message
  } else {
    // Check if user is allowed to send a message in the event room
    if (chatSetting != 'allow') {
      if (showAlert != null) {
        showAlert(
          message: 'You are not allowed to send a message in this event room',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }
  }

  // Send the message to the server
  socket.emit('sendMessage', {
    'messageObject': messageObject,
    'roomName': roomName,
  });
}
