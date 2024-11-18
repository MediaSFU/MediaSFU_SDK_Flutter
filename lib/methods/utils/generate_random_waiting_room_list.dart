import '../../types/types.dart' show WaitingRoomParticipant;

typedef GenerateRandomWaitingRoomListType = List<WaitingRoomParticipant>
    Function();

/// Generates a random list of participants for a waiting room.
///
/// Each participant is given a unique name from a predefined list and a unique ID.
///
/// Example usage:
/// ```dart
/// List<WaitingRoomParticipant> waitingRoomList = generateRandomWaitingRoomList();
/// print(waitingRoomList);
/// // Output:
/// // [
/// //   WaitingRoomParticipant(name: "Dimen", id: "0"),
/// //   WaitingRoomParticipant(name: "Nore", id: "1"),
/// //   WaitingRoomParticipant(name: "Ker", id: "2"),
/// //   WaitingRoomParticipant(name: "Lor", id: "3"),
/// //   WaitingRoomParticipant(name: "Mik", id: "4")
/// // ]
/// ```
List<WaitingRoomParticipant> generateRandomWaitingRoomList() {
  // Array of random names to assign to participants in the waiting room
  List<String> names = ['Dimen', 'Nore', 'Ker', 'Lor', 'Mik'];

  // Generate the waiting room list
  List<WaitingRoomParticipant> waitingRoomList = [];
  for (int i = 0; i < names.length; i++) {
    String randomName = names[i];
    waitingRoomList
        .add(WaitingRoomParticipant(name: randomName, id: i.toString()));
  }

  return waitingRoomList;
}
