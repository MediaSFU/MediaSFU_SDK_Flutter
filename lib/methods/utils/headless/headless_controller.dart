import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../mediasfu_parameters.dart' show MediasfuParameters;
import 'get_media_streams.dart';
import 'get_room_readiness.dart';
import 'participant_state.dart';

/// ChangeNotifier bridge for `returnUI: false` integrations.
///
/// Pass [updateSourceParameters] directly to a MediaSFU room component. Every
/// publication is accepted; snapshots are never de-duplicated because the SDK
/// replaces fields over time and an older bag goes stale.
class MediasfuHeadlessController extends ChangeNotifier {
  MediasfuParameters? _parameters;

  MediasfuParameters? get parameters => _parameters;
  bool get hasParameters => _parameters != null;

  void updateSourceParameters(MediasfuParameters? parameters) {
    if (parameters == null) return;
    _parameters = parameters;
    notifyListeners();
  }

  RoomReadiness get readiness => _parameters == null
      ? const RoomReadiness(
          ready: false,
          reason: 'Not in a room yet.',
          hasRoom: false,
          hasSocket: false,
          hasDevice: false,
        )
      : getRoomReadiness(_parameters!);

  bool get ready => readiness.ready;
  List<ResolvedMedia> get remoteVideos => _parameters == null
      ? const <ResolvedMedia>[]
      : getRemoteVideoStreams(_parameters!);
  List<ResolvedMedia> get remoteAudios => _parameters == null
      ? const <ResolvedMedia>[]
      : getRemoteAudioStreams(_parameters!);
  MediaStream? get localVideo =>
      _parameters == null ? null : getLocalVideoStream(_parameters!);
  MediaStream? get localAudio =>
      _parameters == null ? null : getLocalAudioStream(_parameters!);
  ScreenShareState get screenShare => _parameters == null
      ? const ScreenShareState()
      : getScreenShareStream(_parameters!);
  List<ParticipantMediaState> get participants => _parameters == null
      ? const <ParticipantMediaState>[]
      : listParticipantMediaStates(_parameters!);
}
