import '../../settings_methods/modify_settings.dart';
import '../../stream_methods/switch_audio.dart';
import '../../stream_methods/switch_video.dart';
import '../../stream_methods/switch_video_alt.dart';
import '../mediasfu_parameters.dart' show MediasfuParameters;
import 'room_actions.dart' show HeadlessActionResult;

Future<HeadlessActionResult> _invokeChecked(
  MediasfuParameters parameters,
  Future<void> Function() action,
) async {
  final before = parameters.alertMessage;
  try {
    await action();
  } catch (error) {
    return HeadlessActionResult.failure('The device switch failed: $error');
  }
  final refused = parameters.alertMessage.isNotEmpty &&
      parameters.alertMessage != before &&
      (parameters.alertType == 'danger' || parameters.alertType == 'warning');
  return refused
      ? HeadlessActionResult.failure(parameters.alertMessage)
      : const HeadlessActionResult.success();
}

Future<HeadlessActionResult> switchCamera(
  MediasfuParameters parameters,
  String deviceId,
) {
  if (deviceId.isEmpty) {
    return Future.value(
        const HeadlessActionResult.failure('A camera deviceId is required.'));
  }
  return _invokeChecked(
      parameters,
      () => switchVideo(SwitchVideoOptions(
          videoPreference: deviceId, parameters: parameters)));
}

Future<HeadlessActionResult> switchMicrophone(
  MediasfuParameters parameters,
  String deviceId,
) {
  if (deviceId.isEmpty) {
    return Future.value(const HeadlessActionResult.failure(
        'A microphone deviceId is required.'));
  }
  return _invokeChecked(
      parameters,
      () => switchAudio(SwitchAudioOptions(
          audioPreference: deviceId, parameters: parameters)));
}

Future<HeadlessActionResult> flipCamera(MediasfuParameters parameters) =>
    _invokeChecked(parameters,
        () => switchVideoAlt(SwitchVideoAltOptions(parameters: parameters)));

const _policyValues = <String>{'allow', 'approval', 'disallow'};

Future<HeadlessActionResult> setRoomMediaPolicy(
  MediasfuParameters parameters, {
  String? audio,
  String? video,
  String? screenshare,
  String? chat,
}) async {
  if (parameters.islevel != '2') {
    return const HeadlessActionResult.failure(
        'Only the host can change room settings.');
  }
  if (parameters.socket == null) {
    return const HeadlessActionResult.failure(
        'The room connection is not ready yet.');
  }
  for (final value in <String?>[audio, video, screenshare, chat]) {
    if (value != null && !_policyValues.contains(value)) {
      return HeadlessActionResult.failure(
          'Unsupported room policy value: $value');
    }
  }
  try {
    await modifySettings(ModifySettingsOptions(
      showAlert: parameters.showAlert,
      roomName: parameters.roomName,
      audioSet: audio ?? parameters.audioSetting,
      videoSet: video ?? parameters.videoSetting,
      screenshareSet: screenshare ?? parameters.screenshareSetting,
      chatSet: chat ?? parameters.chatSetting,
      socket: parameters.socket,
      updateAudioSetting: parameters.updateAudioSetting,
      updateVideoSetting: parameters.updateVideoSetting,
      updateScreenshareSetting: parameters.updateScreenshareSetting,
      updateChatSetting: parameters.updateChatSetting,
      updateIsSettingsModalVisible: parameters.updateIsSettingsModalVisible,
    ));
    return const HeadlessActionResult.success();
  } catch (error) {
    return HeadlessActionResult.failure(
        'The room settings could not be updated: $error');
  }
}

class ChatMessage {
  final String sender;
  final String message;
  final String timestamp;
  final List<String> receivers;
  final bool direct;
  final bool mine;

  const ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.receivers,
    required this.direct,
    required this.mine,
  });
}

List<ChatMessage> getChatMessages(
  MediasfuParameters parameters, {
  String scope = 'all',
  String withPerson = '',
}) =>
    parameters.messages
        .map((entry) => ChatMessage(
              sender: entry.sender,
              message: entry.message,
              timestamp: entry.timestamp,
              receivers: List<String>.unmodifiable(entry.receivers),
              direct: entry.receivers.isNotEmpty,
              mine: entry.sender == parameters.member,
            ))
        .where((message) {
      if (scope == 'group' && message.direct) return false;
      if (scope == 'direct' && !message.direct) return false;
      if (withPerson.isNotEmpty) {
        return message.sender == withPerson ||
            message.receivers.contains(withPerson);
      }
      return true;
    }).toList(growable: false);

class PendingApprovalPerson {
  final String id;
  final String name;
  final String icon;
  final String username;

  const PendingApprovalPerson({
    required this.id,
    required this.name,
    this.icon = '',
    this.username = '',
  });
}

class PendingApprovals {
  final List<PendingApprovalPerson> waiting;
  final List<PendingApprovalPerson> requests;
  int get total => waiting.length + requests.length;

  const PendingApprovals({required this.waiting, required this.requests});
}

PendingApprovals getPendingApprovals(MediasfuParameters parameters) =>
    PendingApprovals(
      waiting: parameters.waitingRoomList
          .map((entry) => PendingApprovalPerson(id: entry.id, name: entry.name))
          .toList(growable: false),
      requests: parameters.requestList
          .map((entry) => PendingApprovalPerson(
                id: entry.id,
                name: entry.name ?? '',
                icon: entry.icon,
                username: entry.username ?? entry.name ?? '',
              ))
          .toList(growable: false),
    );

class SessionTimer {
  final String elapsed;
  final bool presenceCheckPending;

  const SessionTimer(
      {required this.elapsed, required this.presenceCheckPending});
}

SessionTimer getSessionTimer(MediasfuParameters parameters) => SessionTimer(
      elapsed: parameters.meetingProgressTime,
      presenceCheckPending: parameters.isConfirmHereModalVisible,
    );

class PresenceCheck {
  final bool pending;
  const PresenceCheck({required this.pending});
}

PresenceCheck getPresenceCheck(MediasfuParameters parameters) =>
    PresenceCheck(pending: parameters.isConfirmHereModalVisible);

HeadlessActionResult confirmStillHere(MediasfuParameters parameters) {
  parameters.updateIsConfirmHereModalVisible(false);
  return const HeadlessActionResult.success();
}
