import 'dart:async';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show ShowAlert, CoHostResponsibility, Message;

/// Defines options for sending a message to a room.
class SendMessageOptions {
  final String member;
  final String islevel;
  final ShowAlert? showAlert;
  final List<CoHostResponsibility> coHostResponsibility;
  final String coHost;
  final String chatSetting;
  final String message;
  final String roomName;
  final int messagesLength;
  final List<String> receivers;
  final bool group;
  final String sender;
  final io.Socket? socket;

  SendMessageOptions({
    required this.member,
    required this.islevel,
    this.showAlert,
    required this.coHostResponsibility,
    required this.coHost,
    required this.chatSetting,
    required this.message,
    required this.roomName,
    required this.messagesLength,
    required this.receivers,
    required this.group,
    required this.sender,
    this.socket,
  });
}

/// Type definition for the function that sends a message.
typedef SendMessageType = Future<void> Function(SendMessageOptions options);

/// Sends a message to the specified room.
///
/// This function checks the message limit, validates input, and
/// checks permissions based on user level and co-host responsibilities.
///
/// Example:
/// ```dart
/// final options = SendMessageOptions(
///   member: "JohnDoe",
///   islevel: "2",
///   coHostResponsibility: [{"name": "chat", "value": true}],
///   coHost: "JaneDoe",
///   chatSetting: "allow",
///   message: "Hello, world!",
///   roomName: "Room123",
///   messagesLength: 50,
///   receivers: ["UserA", "UserB"],
///   group: true,
///   sender: "JohnDoe",
///   socket: socketInstance,
/// );
///
/// await sendMessage(options);
/// ```
Future<void> sendMessage(SendMessageOptions options) async {
  bool chatValue = false;

  // Check message count limit based on the room type
  if ((options.messagesLength > 100 && options.roomName.startsWith('d')) ||
      (options.messagesLength > 500 && options.roomName.startsWith('s')) ||
      (options.messagesLength > 100000 && options.roomName.startsWith('p'))) {
    options.showAlert?.call(
      message: 'You have reached the maximum number of messages allowed.',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  // Validate message, sender, and receivers
  if (options.message.isEmpty ||
      (options.member.isEmpty && options.sender.isEmpty)) {
    options.showAlert?.call(
      message: 'Message is not valid.',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  // Create the message object
  Message messageObject = Message(
    sender: options.sender.isNotEmpty ? options.sender : options.member,
    receivers: options.receivers,
    message: options.message,
    timestamp: DateFormat('HH:mm:ss').format(DateTime.now()),
    group: options.group,
  );

  // Check co-host responsibility for chat
  chatValue = options.coHostResponsibility
      .firstWhere((item) => item.name == 'chat',
          orElse: () => CoHostResponsibility(
              name: 'chat', value: false, dedicated: false))
      .value;

  if (options.islevel == '2' ||
      (options.coHost == options.member && chatValue == true)) {
    // Allow sending message
  } else {
    // Check if user is allowed to send a message in the event room
    if (options.chatSetting != 'allow') {
      options.showAlert?.call(
        message: 'You are not allowed to send a message in this event room',
        type: 'danger',
        duration: 3000,
      );
      return;
    }
  }

  // Send the message to the server
  options.socket!.emit('sendMessage', {
    'messageObject': messageObject.toMap(),
    'roomName': options.roomName,
  });
}
