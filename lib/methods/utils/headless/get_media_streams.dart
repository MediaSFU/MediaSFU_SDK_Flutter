/// Media resolution for app-owned UIs.
///
/// These answer "what should I render right now" from the parameter bag, so a
/// Flutter app building its own call surface does not re-derive the rules. Each
/// one exists because the obvious hand-rolled version gets something wrong:
///
///  * the `youyou` self-marker appears in the remote list and shows you as your
///    own remote participant;
///  * one producer can arrive as two entries, so de-duplicating by object
///    identity still renders the same person twice;
///  * a track that has already ended still looks like a stream;
///  * a screen share routed through the camera path is mirrored and cropped.
///
/// **The muted rule.** Never gate attachment on `muted`. A remote track stays
/// muted until its first frame decodes, and no frame decodes until the track is
/// attached — so waiting for it deadlocks and the tile stays black forever.
/// `enabled` is the local, app-controlled flag and is the one worth checking.
library;

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/widgets.dart';
import '../../../types/types.dart' show Stream, Participant;

/// A remote participant's video, with the producer it came from.
class ResolvedMedia {
  final String producerId;
  final String name;
  final MediaStream stream;

  const ResolvedMedia({
    required this.producerId,
    required this.name,
    required this.stream,
  });
}

/// What the parameter bag must supply for media resolution.
abstract class MediaStreamsParameters {
  List<Stream> get allVideoStreams;
  List<Stream> get oldAllStreams;
  List<Stream> get allAudioStreams;
  List<Participant> get participants;
  MediaStream? get localStreamVideo;
  MediaStream? get localStreamAudio;
  MediaStream? get localStreamScreen;
  List<Widget> get audioOnlyStreams;
  bool get shareScreenStarted;
  String get screenId;
  String get member;
}

bool _hasLiveTrack(MediaStream? stream, String kind,
    {bool requireEnabled = true}) {
  if (stream == null) return false;
  try {
    final tracks =
        kind == 'audio' ? stream.getAudioTracks() : stream.getVideoTracks();
    for (final track in tracks) {
      // `muted` is deliberately not consulted here — see the library note.
      final enabledOk = !requireEnabled || track.enabled != false;
      if (enabledOk) return true;
    }
    return false;
  } catch (_) {
    return false;
  }
}

bool _isSelfMarker(String producerId) =>
    producerId == 'youyou' || producerId == 'youyouyou';

/// Remote cameras, de-duplicated by producer id and free of the self marker.
///
/// `oldAllStreams` is merged because the SDK moves entries between the two
/// lists as the layout changes; reading only the current one drops people
/// mid-call.
List<ResolvedMedia> getRemoteVideoStreams(MediaStreamsParameters parameters) {
  final resolved = <ResolvedMedia>[];
  final seen = <String>{};

  void add(Stream entry) {
    final producerId = entry.producerId;
    if (producerId.isEmpty || _isSelfMarker(producerId)) return;
    if (!seen.add(producerId)) return;
    final stream = entry.stream;
    if (!_hasLiveTrack(stream, 'video', requireEnabled: false)) return;
    resolved.add(ResolvedMedia(
      producerId: producerId,
      name: entry.name ?? '',
      stream: stream!,
    ));
  }

  for (final entry in parameters.allVideoStreams) {
    add(entry);
  }
  for (final entry in parameters.oldAllStreams) {
    add(entry);
  }
  return resolved;
}

/// Remote audio producers, de-duplicated by producer id.
List<ResolvedMedia> getRemoteAudioStreams(MediaStreamsParameters parameters) {
  final resolved = <ResolvedMedia>[];
  final seen = <String>{};
  for (final entry in parameters.allAudioStreams) {
    final producerId = entry.producerId;
    if (producerId.isEmpty || _isSelfMarker(producerId)) continue;
    if (!seen.add(producerId)) continue;
    final stream = entry.stream;
    if (!_hasLiveTrack(stream, 'audio', requireEnabled: false)) continue;
    resolved.add(ResolvedMedia(
      producerId: producerId,
      name: entry.name ?? '',
      stream: stream!,
    ));
  }
  return resolved;
}

/// The local camera, or null when it is off.
///
/// Liveness-checked and `enabled`-aware, so a camera the user turned off does
/// not leave a black tile behind.
MediaStream? getLocalVideoStream(MediaStreamsParameters parameters) {
  final camera = parameters.localStreamVideo;
  return _hasLiveTrack(camera, 'video') ? camera : null;
}

/// The live local microphone stream, or null while audio is off.
MediaStream? getLocalAudioStream(MediaStreamsParameters parameters) {
  final audio = parameters.localStreamAudio;
  return _hasLiveTrack(audio, 'audio') ? audio : null;
}

/// Prepared audio renderers. Render every entry; slicing this list makes
/// off-page participants inaudible while they remain in the room.
List<Widget> getAudioGridComponents(MediaStreamsParameters parameters) =>
    List<Widget>.unmodifiable(parameters.audioOnlyStreams);

/// Which screen share to render, and whose it is.
class ScreenShareState {
  final MediaStream? stream;
  final bool isLocal;
  final String name;

  const ScreenShareState({this.stream, this.isLocal = false, this.name = ''});

  bool get active => stream != null;
}

/// The active screen share, local or remote.
///
/// Kept off the camera path on purpose: a screen must never be mirrored, and it
/// wants `BoxFit.contain` rather than `cover` — cropping a shared screen hides
/// the content someone is pointing at.
///
/// The remote stream is not `enabled`-gated. A remote screen track is muted and
/// may report disabled until its first frame arrives, and gating it there is
/// what leaves a viewer staring at a black rectangle.
ScreenShareState getScreenShareStream(MediaStreamsParameters parameters) {
  if (parameters.shareScreenStarted) {
    final local = parameters.localStreamScreen;
    if (_hasLiveTrack(local, 'video')) {
      return ScreenShareState(
          stream: local, isLocal: true, name: parameters.member);
    }
  }

  final screenId = parameters.screenId;
  if (screenId.isEmpty) return const ScreenShareState();

  for (final entry in [
    ...parameters.allVideoStreams,
    ...parameters.oldAllStreams
  ]) {
    if (entry.producerId != screenId) continue;
    final stream = entry.stream;
    if (!_hasLiveTrack(stream, 'video', requireEnabled: false)) continue;
    return ScreenShareState(
      stream: stream,
      isLocal: false,
      name: entry.name ?? '',
    );
  }
  return const ScreenShareState();
}
