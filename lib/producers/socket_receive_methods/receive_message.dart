import 'dart:async';
import '../../types/types.dart' show Participant, EventType, Message;

/// Represents options for receiving and processing a message.
class ReceiveMessageOptions {
  final Message message;
  final List<Message> messages;
  final List<Participant> participantsAll;
  final String member;
  final EventType eventType;
  final String islevel;
  final String coHost;
  final void Function(List<Message>) updateMessages;
  final void Function(bool) updateShowMessagesBadge;

  ReceiveMessageOptions({
    required this.message,
    required this.messages,
    required this.participantsAll,
    required this.member,
    required this.eventType,
    required this.islevel,
    required this.coHost,
    required this.updateMessages,
    required this.updateShowMessagesBadge,
  });
}

typedef ReceiveMessageType = Future<void> Function(
    ReceiveMessageOptions options);

/// Processes an incoming message and updates the message list and badge display based on specified rules.
/// Filters out messages from banned participants and categorizes messages into group and direct.
/// Displays a badge for new messages if certain conditions are met.
///
/// Example usage:
/// ```dart
/// final receiveOptions = ReceiveMessageOptions(
///   message: Message(sender: 'Alice', receivers: ['Bob'], content: 'Hello, Bob!', timestamp: DateTime.now(), group: false),
///   messages: [],
///   participantsAll: [Participant(name: 'Alice', isBanned: false)],
///   member: 'Bob',
///   eventType: EventType.direct,
///   islevel: '2',
///   coHost: 'Alice',
///   updateMessages: (updatedMessages) {
///     print("Updated messages: $updatedMessages");
///   },
///   updateShowMessagesBadge: (showBadge) {
///     print("Show message badge: $showBadge");
///   },
/// );
/// await receiveMessage(receiveOptions);
/// ```
///
/// This function adds new messages, filters banned participants, and updates the badge visibility.
Future<void> receiveMessage(ReceiveMessageOptions options) async {
  final message = options.message;
  final sender = message.sender;
  final receivers = message.receivers;
  final content = message.message;
  final timestamp = message.timestamp;
  final group = message.group;

  List<Message> messages = List.from(options.messages);
  messages.add(Message(
      sender: sender,
      receivers: receivers,
      message: content,
      timestamp: timestamp,
      group: group));

  // Filter out messages with banned senders
  if (options.eventType != EventType.broadcast &&
      options.eventType != EventType.chat) {
    messages = messages
        .where((msg) => options.participantsAll.any((participant) =>
            participant.name == msg.sender && !participant.isBanned!))
        .toList();
  } else {
    messages = messages.where((msg) {
      final participant = options.participantsAll.firstWhere(
          (p) => p.name == msg.sender,
          orElse: () =>
              Participant(name: '', isBanned: true, videoID: '', audioID: ''));
      return !participant.isBanned!;
    }).toList();
  }
  options.updateMessages(messages);

  // Separate group and direct messages
  final oldGroupMessages = options.messages.where((msg) => msg.group).toList();
  final oldDirectMessages =
      options.messages.where((msg) => !msg.group).toList();
  final groupMessages = messages.where((msg) => msg.group).toList();
  final directMessages = messages.where((msg) => !msg.group).toList();

  // Group messages logic
  if (options.eventType != EventType.broadcast &&
      options.eventType != EventType.chat) {
    if (oldGroupMessages.length != groupMessages.length) {
      final newGroupMessages = groupMessages
          .where((msg) => !oldGroupMessages
              .any((oldMsg) => oldMsg.timestamp == msg.timestamp))
          .toList();

      final relevantNewGroupMessages = newGroupMessages
          .where((msg) =>
              msg.sender == options.member ||
              msg.receivers.contains(options.member))
          .toList();

      if (newGroupMessages.isNotEmpty &&
          newGroupMessages.length != relevantNewGroupMessages.length) {
        options.updateShowMessagesBadge(true);
      }
    }
  }

  // Direct messages logic
  if (options.eventType != EventType.broadcast &&
      options.eventType != EventType.chat) {
    if (oldDirectMessages.length != directMessages.length) {
      final newDirectMessages = directMessages
          .where((msg) => !oldDirectMessages
              .any((oldMsg) => oldMsg.timestamp == msg.timestamp))
          .toList();

      final relevantNewDirectMessages = newDirectMessages
          .where((msg) =>
              msg.sender == options.member ||
              msg.receivers.contains(options.member))
          .toList();

      if ((newDirectMessages.isNotEmpty &&
              relevantNewDirectMessages.isNotEmpty) ||
          (newDirectMessages.isNotEmpty &&
              (options.islevel == '2' || options.coHost == options.member))) {
        if (options.islevel == '2' || options.coHost == options.member) {
          if (newDirectMessages.length != relevantNewDirectMessages.length) {
            options.updateShowMessagesBadge(true);
          }
        } else if (relevantNewDirectMessages.isNotEmpty) {
          if (newDirectMessages.length != relevantNewDirectMessages.length) {
            options.updateShowMessagesBadge(true);
          }
        }
      }
    }
  }
}
