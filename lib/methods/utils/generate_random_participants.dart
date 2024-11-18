import 'dart:math';
import '../../types/types.dart' show Participant;

/// Options for generating a random list of participants.
class GenerateRandomParticipantsOptions {
  final String member;
  final String? coHost;
  final String host;
  final bool forChatBroadcast;

  GenerateRandomParticipantsOptions({
    required this.member,
    this.coHost,
    required this.host,
    this.forChatBroadcast = false,
  });
}

typedef GenerateRandomParticipantsType = List<Participant> Function(
    GenerateRandomParticipantsOptions options);

/// Generates a list of random participants for a meeting based on specified options.
///
/// This function creates a randomized list of participants for a meeting or broadcast
/// session, placing the specified `member`, `coHost`, and `host` at the beginning of the
/// list if they are not already included. When `forChatBroadcast` is `true`, only two
/// participants are included to simulate a broadcast chat environment.
///
/// ## Parameters:
/// - [options] - An instance of `GenerateRandomParticipantsOptions` containing:
///   - `member`: The name of the main member to be included in the list.
///   - `coHost`: An optional name for the co-host to be included in the list.
///   - `host`: The name of the host, set to have a unique level in the list.
///   - `forChatBroadcast`: If `true`, limits the list to two participants for broadcast.
///
/// ## Returns:
/// A list of `Participant` objects with randomized names, levels, and muted states.
///
/// ## Example Usage:
///
/// ```dart
/// // Define the options for generating random participants
/// final options = GenerateRandomParticipantsOptions(
///   member: 'John Doe',
///   coHost: 'Jane Smith',
///   host: 'Host1',
///   forChatBroadcast: false, // Set to true for a broadcast session
/// );
///
/// // Generate the participants list
/// List<Participant> participants = generateRandomParticipants(options);
///
/// // Print participant details
/// participants.forEach((participant) {
///   print(
///       'Name: ${participant.name}, Level: ${participant.islevel}, Muted: ${participant.muted}');
/// });
/// // Expected output:
/// // Name: Host1, Level: 2, Muted: false
/// // Name: Jane Smith, Level: 1, Muted: true
/// // Name: John Doe, Level: 1, Muted: false
/// // ...
/// ```

List<Participant> generateRandomParticipants(
    GenerateRandomParticipantsOptions options) {
  List<String> names = [
    'Alice',
    'Bob',
    'Charlie',
    'David',
    'Eve',
    'Frank',
    'Grace',
    'Hank',
    'Ivy',
    'Jack',
    'Kate',
    'Liam',
    'Mia',
    'Nina',
    'Olivia',
    'Pete',
    'Quinn',
    'Rachel',
    'Steve',
    'Tina',
    'Ursula',
    'Vince',
    'Wendy',
    'Xander',
    'Yvonne',
    'Zack'
  ];

  // Limit names to 2 if for chat broadcast
  if (options.forChatBroadcast) {
    names = names.take(2).toList();
  }

  // Place member, coHost, and host at the beginning if not already included
  if (!names.contains(options.member)) {
    names.insert(0, options.member);
  }
  if (options.coHost != null &&
      !names.contains(options.coHost) &&
      !options.forChatBroadcast) {
    names.insert(0, options.coHost!);
  }
  if (!names.contains(options.host)) {
    names.insert(0, options.host);
  }

  // Remove names of length 1 or less
  names = names.where((name) => name.length > 1).toList();

  // Shuffle the names to ensure unique positions
  List<String> shuffledNames = List.from(names);
  for (int i = shuffledNames.length - 1; i > 0; i--) {
    int j = Random().nextInt(i + 1);
    String temp = shuffledNames[i];
    shuffledNames[i] = shuffledNames[j];
    shuffledNames[j] = temp;
  }

  bool hasLevel2Participant = false;
  List<Participant> participants = [];

  // Generate participant objects
  for (int i = 0; i < shuffledNames.length; i++) {
    String randomName = shuffledNames[i];
    String randomLevel = hasLevel2Participant
        ? '1'
        : randomName == options.host
            ? '2'
            : '1'; // Set `islevel` to '2' only once
    bool randomMuted = options.forChatBroadcast
        ? true
        : Random().nextBool(); // Set muted to true for chat broadcast

    if (randomLevel == '2') {
      hasLevel2Participant = true;
    }

    participants.add(Participant(
      name: randomName,
      islevel: randomLevel,
      muted: randomMuted,
      id: i.toString(),
      audioID: 'audio-$i',
      videoID: 'video-$i',
    ));
  }

  return participants;
}
