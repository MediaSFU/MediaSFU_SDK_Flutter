import '../../types/types.dart' show WaitingRoomParticipant;

/// Defines options for managing all waiting room members.
class AllWaitingRoomMembersOptions {
  final List<WaitingRoomParticipant> waitingParticipants;
  final void Function(List<WaitingRoomParticipant>) updateWaitingRoomList;
  final void Function(int) updateTotalReqWait;

  AllWaitingRoomMembersOptions({
    required this.waitingParticipants,
    required this.updateWaitingRoomList,
    required this.updateTotalReqWait,
  });
}

typedef AllWaitingRoomMembersType = Future<void> Function(
    AllWaitingRoomMembersOptions options);

/// Updates the waiting room participants list and the total count of waiting room participants.
///
/// This function calculates the total number of participants currently in the waiting room,
/// updates the waiting room list with the provided list of `waitingParticipants`,
/// and updates the total request count.
///
/// ### Example Usage:
/// ```dart
/// final options = AllWaitingRoomMembersOptions(
///   waitingParticipants: [
///     WaitingRoomParticipant(name: 'Alice', id: '1'),
///     WaitingRoomParticipant(name: 'Bob', id: '2'),
///   ],
///   updateWaitingRoomList: (updatedList) {
///     print('Updated waiting room list: $updatedList');
///   },
///   updateTotalReqWait: (totalRequests) {
///     print('Total waiting room requests: $totalRequests');
///   },
/// );
///
/// await allWaitingRoomMembers(options);
/// ```
///
/// In this example:
/// - The function updates the list of waiting participants with `Alice` and `Bob`.
/// - It also sets the total count of requests to the length of `waitingParticipants`.

Future<void> allWaitingRoomMembers(AllWaitingRoomMembersOptions options) async {
  // Calculate the total number of waiting room participants
  final int totalReqs = options.waitingParticipants.length;

  // Update the waiting room participants list
  options.updateWaitingRoomList(options.waitingParticipants);

  // Update the total count of waiting room participants
  options.updateTotalReqWait(totalReqs);
}
