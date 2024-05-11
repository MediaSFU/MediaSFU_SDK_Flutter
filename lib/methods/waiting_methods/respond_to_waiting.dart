// ignore_for_file: empty_catches

import 'package:socket_io_client/socket_io_client.dart' as io;

/// Responds to a waiting participant by emitting an event to allow or deny them access.
///
/// The [parameters] map should contain the following keys:
/// - participantId: The ID of the participant.
/// - participantName: The name of the participant.
/// - updateWaitingList: A function to update the waiting list.
/// - waitingList: The current waiting list.
/// - type: The response type, either true or false.
/// - roomName: The name of the room.
/// - socket: The socket to emit the event on.
///
/// The function filters out the participant from the waiting list, updates the waiting list,
/// converts the response type to a string if it's a boolean, and emits an event to allow or deny
/// the participant based on the response type.

Future<void> respondToWaiting(
    {required Map<String, dynamic> parameters}) async {
  final String participantId = parameters['participantId'];
  final String participantName = parameters['participantName'];
  final Function(List<dynamic>) updateWaitingList =
      parameters['updateWaitingList'];
  List<dynamic> waitingList = parameters['waitingList'];
  final dynamic type = parameters['type'];
  final String roomName = parameters['roomName'];
  final io.Socket socket = parameters['socket'];

  // Filter out the participant from the waiting list
  List<dynamic> newWaitingList =
      waitingList.where((item) => item['name'] != participantName).toList();

  // Update the waiting list
  updateWaitingList(newWaitingList);

  // Convert type to string if it's a boolean
  final String responseType =
      (type == true || type == 'true') ? 'true' : 'false';

  try {
    // Emit an event to allow or deny the participant based on the response type
    socket.emit('allowUserIn', {
      'participantId': participantId,
      'participantName': participantName,
      'type': responseType,
      'roomName': roomName,
    });
  } catch (error) {}
}
