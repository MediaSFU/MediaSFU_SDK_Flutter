import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../types/types.dart' show WaitingRoomParticipant;

/// Options for responding to a waiting participant.
class RespondToWaitingOptions {
  final String participantId;
  final String participantName;
  final Function(List<WaitingRoomParticipant>) updateWaitingList;
  final List<WaitingRoomParticipant> waitingList;
  final dynamic type; // Can be either a string or boolean
  final String roomName;
  final io.Socket? socket;

  RespondToWaitingOptions({
    required this.participantId,
    required this.participantName,
    required this.updateWaitingList,
    required this.waitingList,
    required this.type,
    required this.roomName,
    this.socket,
  });
}

typedef RespondToWaitingType = Future<void> Function({
  required RespondToWaitingOptions options,
});

/// Responds to a waiting participant by allowing or denying access based on specified options.
///
/// This function uses `RespondToWaitingOptions` to handle a participant in the waiting room,
/// updating the waiting list and emitting an event through a socket to approve or deny access.
/// The response type (`"true"` or `"false"`) is determined based on the `type` provided.
///
/// ## Parameters:
/// - [options] - An instance of `RespondToWaitingOptions` containing:
///   - `participantId`: The unique identifier for the participant.
///   - `participantName`: The name of the participant.
///   - `updateWaitingList`: A function to update the waiting list.
///   - `waitingList`: The current list of participants in the waiting room.
///   - `type`: The approval type, which can be a `bool` or `String` (`"true"` or `"false"`).
///   - `roomName`: The name of the room the participant is waiting to join.
///   - `socket`: The socket used to emit the response event.
///
/// ## Example Usage:
///
/// ```dart
/// // Define a sample waiting list and an update function
/// List<WaitingRoomParticipant> waitingList = [
///   WaitingRoomParticipant(name: 'John Doe', id: '123'),
///   WaitingRoomParticipant(name: 'Jane Smith', id: '456'),
/// ];
///
/// void updateWaitingList(List<WaitingRoomParticipant> newList) {
///   waitingList = newList;
///   print('Updated waiting list: ${waitingList.map((p) => p.name).toList()}');
/// }
///
/// // Initialize options for responding to a participant
/// final options = RespondToWaitingOptions(
///   participantId: '123',
///   participantName: 'John Doe',
///   updateWaitingList: updateWaitingList,
///   waitingList: waitingList,
///   type: true, // Allow participant
///   roomName: 'MainRoom',
///   socket: io.Socket(), // Assume socket connection is established
/// );
///
/// // Call respondToWaiting to process the response
/// respondToWaiting(options: options);
/// // Expected output:
/// // Updated waiting list: [Jane Smith]
/// // Emits an event to allow "John Doe" to join the "MainRoom".
/// ```

Future<void> respondToWaiting({
  required RespondToWaitingOptions options,
}) async {
  // Filter out the participant from the waiting list
  List<WaitingRoomParticipant> newWaitingList = options.waitingList
      .where((item) => item.name != options.participantName)
      .toList();

  // Update the waiting list
  options.updateWaitingList(newWaitingList);

  // Determine the response type as a string ("true" or "false")
  final String responseType =
      (options.type == true || options.type == 'true') ? 'true' : 'false';

  try {
    // Emit an event to allow or deny the participant based on the response type
    options.socket!.emit('allowUserIn', {
      'participantId': options.participantId,
      'participantName': options.participantName,
      'type': responseType,
      'roomName': options.roomName,
    });
  } catch (error) {
    // Handle any socket-related errors here if needed
  }
}
