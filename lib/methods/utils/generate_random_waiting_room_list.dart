import 'dart:math';

/// Generates a random waiting room list with assigned names and mute statuses.
///
/// Given a list of participants, this function generates a waiting room list
/// with randomly assigned names and mute statuses for each participant.
/// The generated waiting room list is a list of maps, where each map contains
/// the participant's name, mute status, and an ID.
///
/// Example usage:
/// ```dart
/// List<dynamic> participants = [...];
/// List<Map<String, dynamic>> waitingRoomList = generateRandomWaitingRoomList(participants);
/// print(waitingRoomList);
///

List<Map<String, dynamic>> generateRandomWaitingRoomList(
    List<dynamic> participants) {
  // Array of random names to assign to participants in the waiting room
  List<String> names = ['Dimen', 'Nore', 'Ker', 'Lor', 'Mik'];

  // Generate waiting room list with randomly assigned names and mute statuses
  List<Map<String, dynamic>> waitingRoomList = [];
  for (int i = 0; i < names.length; i++) {
    String randomName = names[i];
    bool randomMuted = Random().nextBool(); // Randomly assign mute status
    waitingRoomList.add({
      'name': randomName,
      'muted': randomMuted,
      'id': i.toString(),
    });
  }

  return waitingRoomList;
}
