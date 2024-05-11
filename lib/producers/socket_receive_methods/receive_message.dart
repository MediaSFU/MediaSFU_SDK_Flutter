import 'dart:async';

/// Receives a message and updates the messages array based on the received message and parameters.
///
/// The [message] parameter is a map containing the details of the received message, including the sender, receivers, content, timestamp, and group status.
/// The [parameters] parameter is a map containing various parameters needed for processing the message, including the getUpdatedAllParams function, participantsAll list, member name, event type, islevel, coHost, updateMessages function, and updateShowMessagesBadge function.
/// The [messages] parameter is a list of previously received messages.
///
/// This function adds the received message to the messages array and performs filtering and updating based on the event type and participant status.
/// It separates group and direct messages, updates counts for group and direct messages, and triggers the updateShowMessagesBadge function to show the message count if necessary.
///
/// Example usage:
/// ```dart
/// receiveMessage(
///   message: {
///     'sender': 'John',
///     'receivers': ['Alice', 'Bob'],
///     'message': 'Hello',
///     'timestamp': '2022-01-01 12:00:00',
///     'group': false,
///   },
///   parameters: {
///     'getUpdatedAllParams': () => {
///       'participantsAll': [
///         {'name': 'Alice', 'isBanned': false},
///         {'name': 'Bob', 'isBanned': true},
///       ],
///       'member': 'Alice',
///       'eventType': 'chat',
///       'islevel': '1',
///       'coHost': '',
///       'updateMessages': (messages) => print(messages),
///       'updateShowMessagesBadge': (showBadge) => print(showBadge),
///     },
///   },
///   messages: [],
/// );
/// ```

typedef GetUpdatedAllParams = Map<String, dynamic> Function();

Future<void> receiveMessage({
  required Map<String, dynamic> message,
  required Map<String, dynamic> parameters,
  required List<dynamic> messages,
}) async {
  GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
  parameters = getUpdatedAllParams();

  List<dynamic> participantsAll = parameters['participantsAll'] ?? [];
  String member = parameters['member'] ?? '';
  String eventType = parameters['eventType'] ?? '';
  String islevel = parameters['islevel'] ?? '1';
  String coHost = parameters['coHost'] ?? '';
  Function updateMessages = parameters['updateMessages'];
  Function updateShowMessagesBadge = parameters['updateShowMessagesBadge'];

  // Add the received message to the messages array
  String sender = message['sender'];
  List<dynamic> receivers = message['receivers'];
  String content = message['message'];
  String timestamp = message['timestamp'];
  bool group = message['group'];
  List<dynamic> oldMessages = List.from(messages);
  messages.add({
    'sender': sender,
    'receivers': receivers,
    'message': content,
    'timestamp': timestamp,
    'group': group
  });

  // Filter out messages with banned senders in the participants array; keep others that are not banned and not in the participants array
  if (eventType != 'broadcast' && eventType != 'chat') {
    messages = messages
        .where((message) => participantsAll.any((participant) =>
            participant['name'] == message['sender'] &&
            !participant['isBanned']))
        .toList();
    updateMessages(messages);
  } else {
    messages = messages.where((message) {
      var participant = participantsAll.firstWhere(
          (participant) => participant['name'] == message['sender'],
          orElse: () => <String, dynamic>{});
      return participant.isEmpty || (!participant['isBanned']);
    }).toList();
    updateMessages(messages);
  }

  // Separate group and direct messages
  List<dynamic> oldGroupMessages =
      oldMessages.where((message) => message['group'] == true).toList();
  List<dynamic> oldDirectMessages =
      oldMessages.where((message) => message['group'] == false).toList();

  // Render and update counts for group messages
  List<dynamic> groupMessages =
      messages.where((message) => message['group'] == true).toList();

  if (eventType != 'broadcast' && eventType != 'chat') {
    // Check if oldGroupMessages length is different from groupMessages length
    if (oldGroupMessages.length != groupMessages.length) {
      // Identify new messages
      List<dynamic> newGroupMessages = groupMessages
          .where((message) => !oldGroupMessages.any(
              (oldMessage) => oldMessage['timestamp'] == message['timestamp']))
          .toList();

      // Check if newGroupMessages sender is the member or receivers include the member
      List<dynamic> newGroupMessages2 = newGroupMessages
          .where((message) =>
              message['sender'] == member ||
              message['receivers'].contains(member))
          .toList();

      // Check if member is the sender of any newGroupMessages
      List<dynamic> newGroupMessages3 = newGroupMessages2
          .where((message) => message['sender'] == member)
          .toList();

      // Check if member is the receiver of any newGroupMessages
      if (newGroupMessages.isNotEmpty) {
        if (newGroupMessages.length != newGroupMessages3.length) {
          // Show the message-count
          updateShowMessagesBadge(true);
        }
      }
    }
  }

  // Render and update counts for direct messages
  List<dynamic> directMessages =
      messages.where((message) => message['group'] == false).toList();

  if (eventType != 'broadcast' && eventType != 'chat') {
    // Check if oldDirectMessages length is different from directMessages length
    if (oldDirectMessages.length != directMessages.length) {
      // Identify new direct messages
      List<dynamic> newDirectMessages = directMessages
          .where((message) => !oldDirectMessages.any(
              (oldMessage) => oldMessage['timestamp'] == message['timestamp']))
          .toList();

      // Check if newDirectMessages sender is the member or receivers include the member
      List<dynamic> newDirectMessages2 = newDirectMessages
          .where((message) =>
              message['sender'] == member ||
              message['receivers'].contains(member))
          .toList();

      // Check if member is the sender of any newDirectMessages
      List<dynamic> newDirectMessages3 = newDirectMessages2
          .where((message) => message['sender'] == member)
          .toList();

      if ((newDirectMessages.isNotEmpty && newDirectMessages2.isNotEmpty) ||
          (newDirectMessages.isNotEmpty && (islevel == '2') ||
              coHost == member)) {
        if ((islevel == '2') || coHost == member) {
          if (newDirectMessages.length != newDirectMessages3.length) {
            // Show the message-count
            updateShowMessagesBadge(true);
          }
        } else {
          if (newDirectMessages2.isNotEmpty) {
            if (newDirectMessages.length != newDirectMessages3.length) {
              // Show the message-count
              updateShowMessagesBadge(true);
            }
          }
        }
      }
    }
  }
}
