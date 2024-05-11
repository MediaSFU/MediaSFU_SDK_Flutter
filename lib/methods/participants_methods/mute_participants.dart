import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

/// Mutes the participants in a room based on the provided parameters.
///
/// The [parameters] map should contain the following keys:
/// - 'socket': The socket for communication.
/// - 'coHostResponsibility': The list of co-host responsibilities.
/// - 'participant': The participant to be muted.
/// - 'member': The member performing the action.
/// - 'islevel': The level of the participant.
/// - 'showAlert': A function to show an alert message.
/// - 'coHost': The co-host performing the action.
/// - 'roomName': The name of the room.
///
/// Throws an error if there is an issue with muting the participant.
/// Shows an alert message if the user is not allowed to mute other participants.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef ParticipantAction = Future<void> Function(
    Map<String, dynamic> parameters);

Future<void> muteParticipants(
    {required Map<String, dynamic> parameters}) async {
  final io.Socket socket = parameters['socket'];
  final coHostResponsibility = parameters['coHostResponsibility'];
  final participant = parameters['participant'];
  final member = parameters['member'];
  final islevel = parameters['islevel'];
  final ShowAlert? showAlert = parameters['showAlert'];
  final coHost = parameters['coHost'];
  final roomName = parameters['roomName'];
  bool mediaValue = false;

  try {
    mediaValue = coHostResponsibility
        .firstWhere((item) => item['name'] == 'media')['value'];
    // ignore: empty_catches
  } catch (error) {}

  if (islevel == '2' || (coHost == member && mediaValue == true)) {
    if (!(participant['muted'] ?? false) && participant['islevel'] != '2') {
      final participantId = participant['id'];
      socket.emit('controlMedia', {
        'participantId': participantId,
        'participantName': participant['name'],
        'type': 'all',
        'roomName': roomName,
      });
    }
  } else {
    showAlert!(
      message: 'You are not allowed to mute other participants',
      type: 'danger',
      duration: 3000,
    );
  }
}
