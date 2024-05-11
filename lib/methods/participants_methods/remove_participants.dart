import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

/// A function that removes participants from a room.
///
/// The [removeParticipants] function takes a map of parameters as input and removes participants from a room based on certain conditions.
/// It requires the following parameters:
/// - `parameters`: A map containing the necessary parameters for removing participants.
///
/// The function performs the following steps:
/// 1. Extracts the necessary parameters from the `parameters` map.
/// 2. Checks if the user has the permission to remove participants based on their role and the value of `coHostResponsibility`.
/// 3. If the user has the permission, it disconnects the participant from the room using a socket event and removes them from the local array.
/// 4. Finally, it updates the participants array.
///
/// Example usage:
/// ```dart
/// await removeParticipants(parameters: {
///   'coHostResponsibility': [],
///   'participant': {},
///   'member': '',
///   'islevel': '1',
///   'showAlert': null,
///   'coHost': '',
///   'participants': [],
///   'socket': io.Socket,
///   'roomName': '',
///   'updateParticipants': (List<dynamic>) {},
/// });
///

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

Future<void> removeParticipants(
    {required Map<String, dynamic> parameters}) async {
  final List<dynamic> coHostResponsibility =
      parameters['coHostResponsibility'] ?? [];
  final dynamic participant = parameters['participant'] ?? {};
  final String member = parameters['member'] ?? '';
  final String islevel = parameters['islevel'] ?? '1';
  final ShowAlert? showAlert = parameters['showAlert'];
  final String coHost = parameters['coHost'] ?? '';
  final List<dynamic> participants = parameters['participants'] ?? [];
  final io.Socket socket = parameters['socket'];
  final String roomName = parameters['roomName'] ?? '';
  final void Function(List<dynamic>) updateParticipants =
      parameters['updateParticipants'];

  bool participantsValue = false;

  try {
    participantsValue = coHostResponsibility
        .firstWhere((item) => item['name'] == 'participants')['value'];
    // ignore: empty_catches
  } catch (error) {}

  if (islevel == '2' || (coHost == member && participantsValue == true)) {
    if (participant['islevel'] != '2') {
      final participantId = participant['id'];

      // Emit a socket event to disconnect the user
      socket.emit('disconnectUserInitiate', {
        'member': participant['name'],
        'roomName': roomName,
        'id': participantId
      });

      // Remove the participant from the local array
      participants.removeWhere((obj) => obj['name'] == participant['name']);

      // Update the participants array
      updateParticipants(participants);
    }
  } else {
    if (showAlert != null) {
      showAlert(
        message: 'You are not allowed to remove other participants',
        type: 'danger',
        duration: 3000,
      );
    }
  }
}
