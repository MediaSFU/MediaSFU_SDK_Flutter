import '../../../types/types.dart' show Participant;

abstract class MediaPermissionsParameters {
  String get islevel;
  String get member;
  bool get audioOnlyRoom;
  bool get recordStarted;
  bool get recordResumed;
  bool get recordPaused;
  bool get recordStopped;
  String get recordingMediaOptions;
  bool get adminRestrictSetting;
  bool get panelistsFocused;
  List<Participant> get panelists;
  bool get muteOthersMic;
  bool get muteOthersCamera;
  String get audioSetting;
  String get videoSetting;
  String get screenshareSetting;
}

class MediaPermission {
  final bool allowed;
  final String reason;
  final bool needsApproval;

  const MediaPermission({
    required this.allowed,
    this.reason = '',
    this.needsApproval = false,
  });
}

class MediaPermissions {
  final MediaPermission microphone;
  final MediaPermission camera;
  final MediaPermission screenShare;
  final bool isHost;
  final bool focusModeBlocked;

  const MediaPermissions({
    required this.microphone,
    required this.camera,
    required this.screenShare,
    required this.isHost,
    required this.focusModeBlocked,
  });
}

MediaPermissions getMediaPermissions(MediaPermissionsParameters parameters) {
  final isHost = parameters.islevel == '2';
  final recording = (parameters.recordStarted || parameters.recordResumed) &&
      !(parameters.recordPaused || parameters.recordStopped);
  final isPanelist =
      parameters.panelists.any((entry) => entry.name == parameters.member);
  final focusModeBlocked =
      parameters.panelistsFocused && !isHost && !isPanelist;

  MediaPermission evaluate(String kind) {
    const allowed = MediaPermission(allowed: true);
    MediaPermission deny(String reason) =>
        MediaPermission(allowed: false, reason: reason);

    if (parameters.audioOnlyRoom && kind != 'audio') {
      return deny('This is an audio-only event.');
    }
    if (isHost && recording) {
      if (kind == 'audio' && parameters.recordingMediaOptions == 'audio') {
        return deny(
            'Pause or stop the recording before changing your microphone.');
      }
      if (kind == 'video' && parameters.recordingMediaOptions == 'video') {
        return deny('Pause or stop the recording before changing your camera.');
      }
    }
    if (isHost) return allowed;
    if (parameters.adminRestrictSetting) {
      return deny('Access denied by the host.');
    }
    if (focusModeBlocked && kind == 'audio' && parameters.muteOthersMic) {
      return deny('Only panelists can unmute while focus mode is active.');
    }
    if (focusModeBlocked && kind == 'video' && parameters.muteOthersCamera) {
      return deny(
          'Only panelists can enable video while focus mode is active.');
    }

    final setting = kind == 'audio'
        ? parameters.audioSetting
        : kind == 'video'
            ? parameters.videoSetting
            : parameters.screenshareSetting;
    if (setting == 'disallow') {
      return deny('The host has disabled this for participants.');
    }
    if (setting == 'approval') {
      return const MediaPermission(
        allowed: true,
        reason: 'The host must approve this.',
        needsApproval: true,
      );
    }
    return allowed;
  }

  return MediaPermissions(
    microphone: evaluate('audio'),
    camera: evaluate('video'),
    screenShare: evaluate('screenshare'),
    isHost: isHost,
    focusModeBlocked: focusModeBlocked,
  );
}
