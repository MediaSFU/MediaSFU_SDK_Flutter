import 'dart:math';
import 'package:intl/intl.dart'; // Import the intl package

/// Generates random messages for a chat application.
///
/// The [generateRandomMessages] function takes in a list of [participants],
/// the [member], [coHost], and [host] names, and an optional parameter
/// [forChatBroadcast] which indicates whether the messages are for a chat broadcast.
///
/// It returns a list of maps, where each map represents a message with the following properties:
/// - 'sender': The name of the sender.
/// - 'receivers': A list of names of the message receivers.
/// - 'message': The content of the message.
/// - 'timestamp': The timestamp of the message in the format 'HH:mm:ss'.
/// - 'group': A boolean value indicating whether the message is a group message.
///
/// The function generates direct messages and group messages for each participant,
/// with a random receiver for each direct message. The timestamps of the messages
/// are incremented by 15 seconds for each message.

List<Map<String, dynamic>> generateRandomMessages(
    List<dynamic> participants, String member, String coHost, String host,
    {bool forChatBroadcast = false}) {
  List<Map<String, dynamic>> messages = [];

  // Function to get a random participant other than the sender
  String getRandomReceiver(String sender) {
    List<String> potentialReceivers = participants
        .where((participant) => participant['name'] != sender)
        .map<String>((participant) => participant['name'])
        .toList();
    String randomReceiver =
        potentialReceivers[Random().nextInt(potentialReceivers.length)];
    return randomReceiver;
  }

  // Force add messages for specific participants
  List<String> refNames = [];
  if (forChatBroadcast) {
    refNames = [member, host];
  } else {
    if (coHost.isNotEmpty) {
      refNames = [
        member,
        coHost,
        host,
        ...participants.map((participant) => participant['name'])
      ];
    } else {
      refNames = [
        member,
        host,
        ...participants.map((participant) => participant['name'])
      ];
    }
  }

  // Return unique names for the refNames
  refNames = refNames.toSet().toList();

// Generate messages
  DateTime currentTime = DateTime.now();
  int timeIncrement = 0;
  for (var sender in refNames) {
    // Send direct messages
    Map<String, dynamic> directMessage = {
      'sender': sender,
      'receivers': [getRandomReceiver(sender)],
      'message': 'Direct message from $sender',
      'timestamp': DateFormat('HH:mm:ss')
          .format(currentTime.add(Duration(milliseconds: timeIncrement))),
      'group': false,
    };
    messages.add(directMessage);

    // Send group messages
    Map<String, dynamic> groupMessage = {
      'sender': sender,
      'receivers':
          participants.map((participant) => participant['name']).toList(),
      'message': 'Group message from $sender',
      'timestamp': DateFormat('HH:mm:ss')
          .format(currentTime.add(Duration(milliseconds: timeIncrement))),
      'group': true,
    };
    messages.add(groupMessage);

    timeIncrement += 15000; // Increment time by 15 seconds for each message
  }
  return messages;
}
