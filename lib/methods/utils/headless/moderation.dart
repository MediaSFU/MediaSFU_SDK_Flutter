import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../types/types.dart'
    show
        CoHostResponsibility,
        Participant,
        Request,
        ShowAlert,
        WaitingRoomParticipant;
import '../../co_host_methods/modify_co_host_settings.dart';
import '../../participants_methods/remove_participants.dart';
import '../../requests_methods/respond_to_requests.dart';
import '../../waiting_methods/respond_to_waiting.dart';
import 'room_actions.dart' show HeadlessActionResult;

typedef ModerationArea = String;

abstract class ModerationParameters {
  String get member;
  String get roomName;
  String get islevel;
  String get coHost;
  List<CoHostResponsibility> get coHostResponsibility;
  List<Participant> get participants;
  List<Participant> get participantsAll;
  List<WaitingRoomParticipant> get waitingRoomList;
  List<Request> get requestList;
  io.Socket? get socket;
  ShowAlert? get showAlert;
  void Function(List<Participant>) get updateParticipants;
  void Function(List<WaitingRoomParticipant>) get updateWaitingRoomList;
  void Function(List<Request>) get updateRequestList;
  void Function(bool) get updateIsCoHostModalVisible;
  void Function(List<CoHostResponsibility>) get updateCoHostResponsibility;
  void Function(String) get updateCoHost;
}

class ModerationPermissions {
  final bool isHost;
  final bool isCoHost;
  final bool canControlMedia;
  final bool canManageParticipants;
  final bool canManageChat;
  final bool canManageWaitingRoom;

  const ModerationPermissions({
    required this.isHost,
    required this.isCoHost,
    required this.canControlMedia,
    required this.canManageParticipants,
    required this.canManageChat,
    required this.canManageWaitingRoom,
  });
}

ModerationPermissions getModerationPermissions(
    ModerationParameters parameters) {
  final isHost = parameters.islevel == '2';
  final isCoHost =
      parameters.coHost.isNotEmpty && parameters.coHost == parameters.member;
  bool allows(String area) =>
      isHost ||
      (isCoHost &&
          parameters.coHostResponsibility
              .any((item) => item.name == area && item.value));
  return ModerationPermissions(
    isHost: isHost,
    isCoHost: isCoHost,
    canControlMedia: allows('media'),
    canManageParticipants: allows('participants'),
    canManageChat: allows('chat'),
    canManageWaitingRoom: allows('waiting'),
  );
}

List<Participant> _participantList(ModerationParameters parameters) =>
    parameters.participants.isNotEmpty
        ? parameters.participants
        : parameters.participantsAll;

Participant? _findParticipant(
  ModerationParameters parameters, {
  String id = '',
  String name = '',
}) {
  for (final participant in _participantList(parameters)) {
    if ((id.isNotEmpty && participant.id == id) ||
        (name.isNotEmpty && participant.name == name)) {
      return participant;
    }
  }
  return null;
}

Future<HeadlessActionResult> setParticipantMedia(
  ModerationParameters parameters, {
  String id = '',
  String name = '',
  required String kind,
}) async {
  final permissions = getModerationPermissions(parameters);
  if (!permissions.canControlMedia) {
    return const HeadlessActionResult.failure(
        'You are not allowed to control media for other participants.');
  }
  final participant = _findParticipant(parameters, id: id, name: name);
  if (participant == null) {
    return const HeadlessActionResult.failure(
        'That participant is not in the room.');
  }
  if (participant.islevel == '2') {
    return const HeadlessActionResult.failure(
        'A host’s media cannot be turned off.');
  }
  if (parameters.socket == null || parameters.roomName.isEmpty) {
    return const HeadlessActionResult.failure(
        'The room connection is not ready.');
  }
  try {
    parameters.socket!.emit('controlMedia', {
      'participantId': participant.id,
      'participantName': participant.name,
      'type': kind,
      'roomName': parameters.roomName,
    });
    return const HeadlessActionResult.success();
  } catch (error) {
    return HeadlessActionResult.failure('The media control failed: $error');
  }
}

Future<HeadlessActionResult> muteParticipant(ModerationParameters parameters,
        {String id = '', String name = ''}) =>
    setParticipantMedia(parameters, id: id, name: name, kind: 'audio');

Future<HeadlessActionResult> disableParticipantVideo(
        ModerationParameters parameters,
        {String id = '',
        String name = ''}) =>
    setParticipantMedia(parameters, id: id, name: name, kind: 'video');

Future<HeadlessActionResult> stopParticipantScreenShare(
        ModerationParameters parameters,
        {String id = '',
        String name = ''}) =>
    setParticipantMedia(parameters, id: id, name: name, kind: 'screenshare');

Future<HeadlessActionResult> muteEveryone(
  ModerationParameters parameters, {
  String kind = 'audio',
}) async {
  final targets = _participantList(parameters)
      .where((entry) => entry.islevel != '2' && entry.name != parameters.member)
      .toList(growable: false);
  if (targets.isEmpty) {
    return const HeadlessActionResult.failure('There is nobody else to mute.');
  }
  var successes = 0;
  for (final target in targets) {
    final result = await setParticipantMedia(parameters,
        id: target.id ?? '', name: target.name, kind: kind);
    if (result.ok) successes++;
  }
  return successes > 0
      ? const HeadlessActionResult.success()
      : const HeadlessActionResult.failure('No participant could be muted.');
}

Future<HeadlessActionResult> removeParticipant(
  ModerationParameters parameters, {
  String id = '',
  String name = '',
}) async {
  if (!getModerationPermissions(parameters).canManageParticipants) {
    return const HeadlessActionResult.failure(
        'You are not allowed to remove participants.');
  }
  final participant = _findParticipant(parameters, id: id, name: name);
  if (participant == null) {
    return const HeadlessActionResult.failure(
        'That participant is not in the room.');
  }
  if (participant.islevel == '2') {
    return const HeadlessActionResult.failure('A host cannot be removed.');
  }
  try {
    await removeParticipants(RemoveParticipantsOptions(
      coHostResponsibility: parameters.coHostResponsibility,
      participant: participant,
      member: parameters.member,
      islevel: parameters.islevel,
      showAlert: parameters.showAlert,
      coHost: parameters.coHost,
      participants: _participantList(parameters),
      socket: parameters.socket,
      roomName: parameters.roomName,
      updateParticipants: parameters.updateParticipants,
    ));
    return const HeadlessActionResult.success();
  } catch (error) {
    return HeadlessActionResult.failure(
        'The participant could not be removed: $error');
  }
}

Future<HeadlessActionResult> respondToWaitingParticipant(
  ModerationParameters parameters, {
  String id = '',
  String name = '',
  required bool admit,
}) async {
  if (!getModerationPermissions(parameters).canManageWaitingRoom) {
    return const HeadlessActionResult.failure(
        'You are not allowed to manage the waiting room.');
  }
  WaitingRoomParticipant? entry;
  for (final person in parameters.waitingRoomList) {
    if ((id.isNotEmpty && person.id == id) ||
        (name.isNotEmpty && person.name == name)) {
      entry = person;
      break;
    }
  }
  if (entry == null) {
    return const HeadlessActionResult.failure(
        'That person is no longer waiting to join.');
  }
  await respondToWaiting(
    options: RespondToWaitingOptions(
      participantId: entry.id,
      participantName: entry.name,
      updateWaitingList: parameters.updateWaitingRoomList,
      waitingList: parameters.waitingRoomList,
      type: admit,
      roomName: parameters.roomName,
      socket: parameters.socket,
    ),
  );
  return const HeadlessActionResult.success();
}

Future<HeadlessActionResult> respondToParticipantRequest(
  ModerationParameters parameters, {
  String requestId = '',
  String name = '',
  required bool approve,
}) async {
  if (!getModerationPermissions(parameters).canManageParticipants) {
    return const HeadlessActionResult.failure(
        'You are not allowed to respond to requests.');
  }
  Request? request;
  for (final item in parameters.requestList) {
    if ((requestId.isNotEmpty && item.id == requestId) ||
        (name.isNotEmpty && (item.name == name || item.username == name))) {
      request = item;
      break;
    }
  }
  if (request == null) {
    return const HeadlessActionResult.failure(
        'That request is no longer pending.');
  }
  await respondToRequests(RespondToRequestsOptions(
    socket: parameters.socket,
    request: request,
    updateRequestList: parameters.updateRequestList,
    requestList: parameters.requestList,
    action: approve ? 'accepted' : 'rejected',
    roomName: parameters.roomName,
  ));
  return const HeadlessActionResult.success();
}

Future<HeadlessActionResult> setCoHost(
  ModerationParameters parameters,
  String name, {
  List<ModerationArea> areas = const <ModerationArea>['media', 'participants'],
}) async {
  if (parameters.islevel != '2') {
    return const HeadlessActionResult.failure(
        'Only the host can assign a co-host.');
  }
  const all = <String>['media', 'participants', 'chat', 'waiting'];
  final responsibilities = all
      .map((area) => CoHostResponsibility(
          name: area, value: areas.contains(area), dedicated: false))
      .toList(growable: false);
  await modifyCoHostSettings(ModifyCoHostSettingsOptions(
    roomName: parameters.roomName,
    showAlert: parameters.showAlert,
    selectedParticipant: name,
    coHost: parameters.coHost,
    coHostResponsibility: responsibilities,
    updateIsCoHostModalVisible: parameters.updateIsCoHostModalVisible,
    updateCoHostResponsibility: parameters.updateCoHostResponsibility,
    updateCoHost: parameters.updateCoHost,
    socket: parameters.socket,
  ));
  return const HeadlessActionResult.success();
}
