/// Is the room actually usable yet?
///
/// A headless surface has no SDK UI telling it what is happening, so it needs a
/// single honest answer rather than guessing from whichever field happens to be
/// populated. Rendering controls before this is `ready` produces buttons that
/// silently do nothing, and showing "connecting" after it is ready is the
/// premature-status bug in the other direction.
library;

/// What the parameter bag must supply to judge readiness.
abstract class RoomReadinessParameters {
  String get roomName;
  String get member;
  bool get validated;
  dynamic get socket;
  dynamic get device;
}

/// Readiness, with the reason when it is not ready.
class RoomReadiness {
  final bool ready;

  /// Why not — safe to show a user. Empty when ready.
  final String reason;

  final bool hasRoom;
  final bool hasSocket;
  final bool hasDevice;

  const RoomReadiness({
    required this.ready,
    required this.reason,
    required this.hasRoom,
    required this.hasSocket,
    required this.hasDevice,
  });
}

/// Judge whether the room can carry media.
///
/// All four conditions matter and they fail differently: without a room name
/// there is nothing to join, without validation the join was refused, without a
/// socket nothing is signalled, and without a loaded device no transport can be
/// created. Collapsing them into one boolean is what makes a stuck call
/// impossible to diagnose from the outside.
RoomReadiness getRoomReadiness(RoomReadinessParameters parameters) {
  final hasRoom =
      parameters.roomName.isNotEmpty && parameters.member.isNotEmpty;
  final hasSocket = parameters.socket != null;
  final hasDevice = parameters.device != null;
  final validated = parameters.validated;

  if (!hasRoom) {
    return RoomReadiness(
      ready: false,
      reason: 'Not in a room yet.',
      hasRoom: false,
      hasSocket: hasSocket,
      hasDevice: hasDevice,
    );
  }
  if (!validated) {
    return RoomReadiness(
      ready: false,
      reason: 'Waiting to be admitted to the room.',
      hasRoom: true,
      hasSocket: hasSocket,
      hasDevice: hasDevice,
    );
  }
  if (!hasSocket) {
    return RoomReadiness(
      ready: false,
      reason: 'The room connection is not established.',
      hasRoom: true,
      hasSocket: false,
      hasDevice: hasDevice,
    );
  }
  if (!hasDevice) {
    return RoomReadiness(
      ready: false,
      reason: 'Media transport is still starting.',
      hasRoom: true,
      hasSocket: true,
      hasDevice: false,
    );
  }
  return const RoomReadiness(
    ready: true,
    reason: '',
    hasRoom: true,
    hasSocket: true,
    hasDevice: true,
  );
}
