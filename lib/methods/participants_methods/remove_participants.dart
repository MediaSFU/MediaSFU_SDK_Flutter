import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart'
    show ShowAlert, CoHostResponsibility, Participant;

/// Defines options for removing a participant from a room.
class RemoveParticipantsOptions {
  final List<CoHostResponsibility> coHostResponsibility;
  final Participant participant;
  final String member;
  final String islevel;
  final ShowAlert? showAlert;
  final String coHost;
  final List<Participant> participants;
  final io.Socket? socket;
  final String roomName;
  final void Function(List<Participant>) updateParticipants;

  RemoveParticipantsOptions({
    required this.coHostResponsibility,
    required this.participant,
    required this.member,
    required this.islevel,
    this.showAlert,
    required this.coHost,
    required this.participants,
    this.socket,
    required this.roomName,
    required this.updateParticipants,
  });
}

/// Type definition for the function that removes a participant.
typedef RemoveParticipantsType = Future<void> Function(
    RemoveParticipantsOptions options);

/// Removes a participant from the room if the user has the necessary permissions.
///
/// This function checks if the current user has the required permissions based on their level and co-host responsibilities.
/// If authorized, it emits a socket event to remove the participant and updates the local participant list.
///
/// Example:
/// ```dart
/// final options = RemoveParticipantsOptions(
///   coHostResponsibility: [{'name': 'participants', 'value': true}],
///   participant: {'id': '123', 'name': 'John Doe', 'islevel': '1'},
///   member: 'currentMember',
///   islevel: '2',
///   showAlert: (alert) => print(alert.message),
///   coHost: 'coHostMember',
///   participants: [{'id': '123', 'name': 'John Doe', 'islevel': '1'}],
///   socket: socketInstance,
///   roomName: 'room1',
///   updateParticipants: (updatedParticipants) => print(updatedParticipants),
/// );
///
/// await removeParticipants(options);
/// ```
Future<void> removeParticipants(RemoveParticipantsOptions options) async {
  bool participantsValue = false;

  try {
    participantsValue = options.coHostResponsibility
        .firstWhere((item) => item.name == 'participants')
        .value;
  } catch (_) {
    participantsValue = false;
  }

  if (options.islevel == '2' ||
      (options.coHost == options.member && participantsValue)) {
    if (options.participant.islevel != '2') {
      final participantId = options.participant.id;

      // Emit a socket event to disconnect the user
      options.socket!.emit('disconnectUserInitiate', {
        'member': options.participant.name,
        'roomName': options.roomName,
        'id': participantId,
      });

      // Remove the participant from the local array
      options.participants
          .removeWhere((obj) => obj.name == options.participant.name);

      // Update the participants array
      options.updateParticipants(options.participants);
    }
  } else {
    options.showAlert?.call(
      message: 'You are not allowed to remove other participants',
      type: 'danger',
      duration: 3000,
    );
  }
}
