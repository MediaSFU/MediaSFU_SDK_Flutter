import 'dart:math';

/// Generates a list of random participants for a meeting.
///
/// The [generateRandomParticipants] function takes in the names of the member,
/// co-host, and host, and generates a list of random participants for a meeting.
/// It also has an optional parameter [forChatBroadcast] which, when set to true,
/// limits the number of names to 2 for chat broadcast.
///
/// The function shuffles the names array to ensure unique names for each participant,
/// and assigns a random level and muted status to each participant.
///
/// Returns a list of participant objects, where each object contains the name,
/// level, muted status, and ID of the participant.

List<dynamic> generateRandomParticipants(
    String member, String coHost, String host,
    {bool forChatBroadcast = false}) {
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

  // Limit names to 2 for chat broadcast
  if (forChatBroadcast) {
    names = names.sublist(0, min(2, names.length));
  }

  // Place member, coHost, and host at the beginning if not already included
  if (!names.contains(member)) {
    names.insert(0, member);
  }
  if (!names.contains(coHost) && !forChatBroadcast) {
    names.insert(0, coHost);
  }
  if (!names.contains(host)) {
    names.insert(0, host);
  }

  // Remove names of length 1 or less
  names = names.where((name) => name.length > 1).toList();

  // Shuffle the names array to ensure unique names for each participant
  List<String> shuffledNames = List.from(names);
  for (int i = shuffledNames.length - 1; i > 0; i--) {
    int j = Random().nextInt(i + 1);
    String temp = shuffledNames[i];
    shuffledNames[i] = shuffledNames[j];
    shuffledNames[j] = temp;
  }

  bool hasLevel2Participant = false;
  List<dynamic> participants = [];

  // Generate participant objects
  for (int i = 0; i < shuffledNames.length; i++) {
    String randomName = shuffledNames[i];
    String randomLevel = hasLevel2Participant
        ? '1'
        : randomName == host
            ? '2'
            : '1'; // Set islevel to '2' only once
    bool randomMuted = forChatBroadcast
        ? true
        : Random().nextBool(); // Set muted to false for chat broadcast

    if (randomLevel == '2') {
      hasLevel2Participant = true;
    }

    participants.add({
      'name': randomName,
      'islevel': randomLevel,
      'muted': randomMuted,
      'id': i.toString(),
    });
  }

  return participants;
}
