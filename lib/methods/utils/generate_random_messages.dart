import 'dart:math';
import 'package:intl/intl.dart';
import '../../types/types.dart' show Message, Participant;

/// Options for generating random messages.
class GenerateRandomMessagesOptions {
  final List<Participant> participants;
  final String member;
  final String? coHost;
  final String host;
  final bool forChatBroadcast;

  GenerateRandomMessagesOptions({
    required this.participants,
    required this.member,
    this.coHost,
    required this.host,
    this.forChatBroadcast = false,
  });
}

typedef GenerateRandomMessagesType = List<Message> Function(
    GenerateRandomMessagesOptions options);

/// Generates random messages for a chat application based on specified options.
///
/// This function creates a list of `Message` objects for chat, simulating both direct and group messages
/// among participants. Specific participants (`member`, `coHost`, and `host`) are always included in the
/// messages. If `forChatBroadcast` is set to `true`, only `member` and `host` are included.
///
/// Each `Message` includes:
/// - `sender`: The name of the message sender.
/// - `receivers`: A list containing the recipients of the message.
/// - `message`: The text content of the message.
/// - `timestamp`: The message time in `'HH:mm:ss'` format.
/// - `group`: A boolean indicating if the message is a group message.
///
/// ## Parameters:
/// - `options`: An instance of `GenerateRandomMessagesOptions` containing:
///   - `participants`: A list of participants in the chat.
///   - `member`: The name of the primary member.
///   - `coHost`: An optional co-host name.
///   - `host`: The name of the host in the chat.
///   - `forChatBroadcast`: If `true`, restricts messages to just `member` and `host`.
///
/// ## Returns:
/// A list of `Message` objects with details for each message.
///
/// ## Example Usage:
///
/// ```dart
/// // Define participants
/// List<Participant> participants = [
///   Participant(name: 'Alice', id: '1', audioID: 'audio-1', videoID: 'video-1'),
///   Participant(name: 'Bob', id: '2', audioID: 'audio-2', videoID: 'video-2'),
///   Participant(name: 'Carol', id: '3', audioID: 'audio-3', videoID: 'video-3'),
/// ];
///
/// // Options for generating messages
/// final options = GenerateRandomMessagesOptions(
///   participants: participants,
///   member: 'Alice',
///   coHost: 'Carol',
///   host: 'Bob',
///   forChatBroadcast: false,
/// );
///
/// // Generate messages
/// List<Message> messages = generateRandomMessages(options);
///
/// // Print messages
/// messages.forEach((msg) {
///   print('Sender: ${msg.sender}, Receivers: ${msg.receivers}, Message: ${msg.message}, Timestamp: ${msg.timestamp}, Group: ${msg.group}');
/// });
/// // Example output:
/// // Sender: Bob, Receivers: [Alice], Message: Direct message from Bob, Timestamp: HH:mm:ss, Group: false
/// // Sender: Bob, Receivers: [Alice, Bob, Carol], Message: Group message from Bob, Timestamp: HH:mm:ss, Group: true
/// // ...
/// ```

List<Message> generateRandomMessages(GenerateRandomMessagesOptions options) {
  List<Message> messages = [];

  // Function to get a random participant other than the sender
  String getRandomReceiver(String sender) {
    List<String> potentialReceivers = options.participants
        .where((participant) => participant.name != sender)
        .map((participant) => participant.name)
        .toList();
    return potentialReceivers[Random().nextInt(potentialReceivers.length)];
  }

  // Force add messages for specific participants
  List<String> refNames = [];
  if (options.forChatBroadcast) {
    refNames = [options.member, options.host];
  } else if (options.coHost != null) {
    refNames = [
      options.member,
      options.coHost!,
      options.host,
      ...options.participants.map((participant) => participant.name)
    ];
  } else {
    refNames = [
      options.member,
      options.host,
      ...options.participants.map((participant) => participant.name)
    ];
  }

  // Ensure unique names for the refNames
  refNames = refNames.toSet().toList();

  // Generate messages
  DateTime currentTime = DateTime.now();
  int timeIncrement = 0;
  for (var sender in refNames) {
    // Send direct messages
    Message directMessage = Message(
      sender: sender,
      receivers: [getRandomReceiver(sender)],
      message: 'Direct message from $sender',
      timestamp: DateFormat('HH:mm:ss')
          .format(currentTime.add(Duration(milliseconds: timeIncrement))),
      group: false,
    );
    messages.add(directMessage);

    // Send group messages
    Message groupMessage = Message(
      sender: sender,
      receivers:
          options.participants.map((participant) => participant.name).toList(),
      message: 'Group message from $sender',
      timestamp: DateFormat('HH:mm:ss')
          .format(currentTime.add(Duration(milliseconds: timeIncrement))),
      group: true,
    );
    messages.add(groupMessage);

    timeIncrement += 15000; // Increment time by 15 seconds for each message
  }

  return messages;
}
