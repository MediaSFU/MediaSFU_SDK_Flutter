import '../../types/types.dart' show Request, WaitingRoomParticipant;

// Options for handling a participant's request to join the event.
class ParticipantRequestedOptions {
  final Request userRequest;
  final List<Request> requestList;
  final List<WaitingRoomParticipant> waitingRoomList;
  final void Function(int) updateTotalReqWait;
  final void Function(List<Request>) updateRequestList;

  ParticipantRequestedOptions({
    required this.userRequest,
    required this.requestList,
    required this.waitingRoomList,
    required this.updateTotalReqWait,
    required this.updateRequestList,
  });
}

typedef ParticipantRequestedType = void Function(
    ParticipantRequestedOptions options);

/// Handles the participant request to join the event.
///
/// This function takes a [ParticipantRequestedOptions] object, which contains the user's request,
/// the current request list, waiting room list, and functions to update the request list and the total count.
///
/// Example usage:
/// ```dart
/// final options = ParticipantRequestedOptions(
///   userRequest: Request(id: "user123", reason: "join"),
///   requestList: [Request(id: "user1", reason: "help")],
///   waitingRoomList: [WaitingRoomParticipant(id: "user2", name: "Alice")],
///   updateTotalReqWait: (count) => print("Total requests: $count"),
///   updateRequestList: (list) => print("Updated request list: $list"),
/// );
///
/// participantRequested(options);
/// // Output:
/// // "Updated request list: [{ id: 'user1', reason: 'help' }, { id: 'user123', reason: 'join' }] "
/// // "Total requests: 3"
/// ```
void participantRequested(ParticipantRequestedOptions options) {
  // Add the user request to the request list
  final updatedRequestList = List<Request>.from(options.requestList)
    ..add(options.userRequest);
  options.updateRequestList(updatedRequestList);

  // Update the total count of requests and waiting room participants
  final reqCount = updatedRequestList.length + options.waitingRoomList.length;
  options.updateTotalReqWait(reqCount);
}
