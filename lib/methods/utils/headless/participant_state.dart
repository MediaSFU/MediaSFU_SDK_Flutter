/// Per-participant media state for app-owned rosters.
///
/// The rule worth stating: a participant's `id` is their membership id and is
/// never a producer id. Video and audio are found through `videoID` / `audioID`,
/// and the SDK writes `'none'` (or leaves them empty) while that track is off.
/// Matching on `id` is why hand-rolled rosters report everyone as camera-off.
library;

import '../../../types/types.dart' show Participant, Stream;

/// What one participant is currently publishing.
class ParticipantMediaState {
  final String name;
  final String id;
  final bool isHost;
  final bool isSelf;

  /// True when this participant is publishing video right now.
  final bool cameraOn;

  /// True when this participant is publishing audio right now.
  final bool micOn;

  final String videoProducerId;
  final String audioProducerId;

  const ParticipantMediaState({
    required this.name,
    required this.id,
    required this.isHost,
    required this.isSelf,
    required this.cameraOn,
    required this.micOn,
    required this.videoProducerId,
    required this.audioProducerId,
  });
}

/// What the parameter bag must supply for roster state.
abstract class ParticipantStateParameters {
  List<Participant> get participants;
  List<Stream> get allVideoStreams;
  List<Stream> get allAudioStreams;
  String get member;
}

/// A producer id is only usable when it is a real reference.
///
/// The SDK uses `'none'` and empty strings as "not publishing", so a plain
/// non-empty check treats a switched-off camera as live.
bool _isUsableProducerId(String? value) {
  if (value == null) return false;
  final trimmed = value.trim();
  return trimmed.length > 3 && trimmed.toLowerCase() != 'none';
}

bool _isPublishing(List<Stream> streams, String producerId) {
  if (!_isUsableProducerId(producerId)) return false;
  for (final entry in streams) {
    if (entry.producerId == producerId && entry.stream != null) return true;
  }
  return false;
}

/// One participant's media state.
ParticipantMediaState resolveParticipantMediaState(
  ParticipantStateParameters parameters,
  Participant participant,
) {
  final videoProducerId = participant.videoID;
  final audioProducerId = participant.audioID;
  return ParticipantMediaState(
    name: participant.name,
    id: participant.id ?? '',
    isHost: participant.islevel == '2',
    isSelf: participant.name == parameters.member,
    cameraOn: _isPublishing(parameters.allVideoStreams, videoProducerId),
    micOn: _isPublishing(parameters.allAudioStreams, audioProducerId),
    videoProducerId:
        _isUsableProducerId(videoProducerId) ? videoProducerId : '',
    audioProducerId:
        _isUsableProducerId(audioProducerId) ? audioProducerId : '',
  );
}

/// The whole roster, ready to render.
///
/// Ordered as the room orders it, so tiles do not reshuffle on every
/// publication — a re-sorted grid mid-call reads as a glitch.
List<ParticipantMediaState> listParticipantMediaStates(
    ParticipantStateParameters parameters) {
  return parameters.participants
      .map((participant) =>
          resolveParticipantMediaState(parameters, participant))
      .toList(growable: false);
}

/// Who the room considers the host, or null.
Participant? getRoomHost(ParticipantStateParameters parameters) {
  for (final participant in parameters.participants) {
    if (participant.islevel == '2') return participant;
  }
  return null;
}
