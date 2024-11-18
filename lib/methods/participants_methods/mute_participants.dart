import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart'
    show Participant, CoHostResponsibility, ShowAlert;

/// Defines options for muting a participant in a room.
class MuteParticipantsOptions {
  final io.Socket? socket;
  final List<CoHostResponsibility> coHostResponsibility;
  final Participant participant;
  final String member;
  final String islevel;
  final ShowAlert? showAlert;
  final String coHost;
  final String roomName;

  MuteParticipantsOptions({
    this.socket,
    required this.coHostResponsibility,
    required this.participant,
    required this.member,
    required this.islevel,
    this.showAlert,
    required this.coHost,
    required this.roomName,
  });
}

/// Type definition for the function that mutes a participant.
typedef MuteParticipantsType = Future<void> Function(
    MuteParticipantsOptions options);

/// Mutes a participant in the room if the current member has the necessary permissions.
///
/// This function checks if the current member has the required permissions based on their level
/// and co-host responsibilities. If authorized, it emits a socket event to mute the participant.
///
/// Example:
/// ```dart
/// final options = MuteParticipantsOptions(
///   socket: socketInstance,
///   coHostResponsibility: [{'name': 'media', 'value': true}],
///   participant: {'id': '123', 'name': 'John Doe', 'muted': false, 'islevel': '1'},
///   member: 'currentMember',
///   islevel: '2',
///   showAlert: (alert) => print(alert.message),
///   coHost: 'coHostMember',
///   roomName: 'room1',
/// );
///
/// await muteParticipants(options);
/// ```
Future<void> muteParticipants(MuteParticipantsOptions options) async {
  bool mediaValue = false;

  try {
    mediaValue = options.coHostResponsibility
        .firstWhere((item) => item.name == 'media',
            orElse: () =>
                CoHostResponsibility(name: '', value: false, dedicated: false))
        .value;
  } catch (_) {
    mediaValue = false;
  }

  if (options.islevel == '2' ||
      (options.coHost == options.member && mediaValue)) {
    if (!(options.participant.muted ?? false) &&
        options.participant.islevel != '2') {
      final participantId = options.participant.id;
      options.socket!.emit('controlMedia', {
        'participantId': participantId,
        'participantName': options.participant.name,
        'type': 'all',
        'roomName': options.roomName,
      });
    }
  } else {
    options.showAlert?.call(
      message: 'You are not allowed to mute other participants',
      type: 'danger',
      duration: 3000,
    );
  }
}
