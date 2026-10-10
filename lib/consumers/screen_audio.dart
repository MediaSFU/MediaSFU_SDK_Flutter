import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../types/types.dart' show Participant;
import 'screen_audio_platform_stub.dart'
    if (dart.library.js_interop) 'screen_audio_platform_web.dart';

/// How a screen share treats audio: [ask] (default) offers "Screen + audio" / "Screen only" first, [always] requests
/// audio without asking, [never] shares video only.
enum ScreenAudioMode { ask, always, never }

/// The answer to "share audio too?".
enum ScreenAudioChoice { audio, video }

/// `appData.mediaTag` of audio shared with a screen share.
const String kScreenAudioMediaTag = 'screen-audio';

/// Producer `source` used for screen audio, so the send transport never stores it as the microphone.
const String kScreenAudioSource = 'screen-audio';

/// Screen audio: the audio of a shared tab, window or screen, published as its own producer tagged
/// `mediaTag: 'screen-audio'`. It belongs to the screen share (it stops with it), never to the sharer's microphone,
/// so it never marks the sharer as speaking.
///
/// Capture is web only (browsers that offer display audio, Chromium today); every platform can listen, through the
/// normal audio path. A client publishes it only when the media server's join response says `supportsScreenAudio`,
/// so older servers keep video-only screen share.
///
/// ```dart
/// MediasfuScreenAudio.enabled = false; // app-wide opt-out
/// ```
class MediasfuScreenAudio {
  MediasfuScreenAudio._();

  /// App-wide switch; when false, screen share never asks the browser for audio.
  static bool enabled = true;

  /// Audio constraints for display capture: unprocessed, for music and video soundtracks.
  static const Map<String, dynamic> audioConstraints = {
    'echoCancellation': false,
    'noiseSuppression': false,
    'autoGainControl': false,
  };

  static final Expando<bool> _supportBySocket = Expando<bool>('screenAudioSupport');
  static final Expando<Producer> _producerBySocket = Expando<Producer>('screenAudioProducer');

  /// Records the join response's `supportsScreenAudio` for this producer socket.
  static void rememberSupport(io.Socket? socket, bool supported) {
    if (socket != null) _supportBySocket[socket] = supported;
  }

  static bool isSupported(io.Socket? socket) => socket != null && (_supportBySocket[socket] ?? false);

  /// App-wide mode; see [ScreenAudioMode].
  static ScreenAudioMode mode = ScreenAudioMode.ask;

  /// Replace the default "share audio too?" dialog. Return null to cancel the share.
  static Future<ScreenAudioChoice?> Function(BuildContext context)? prompt;

  /// Override browser detection (default: Chromium desktop browsers on web).
  static bool Function()? canCaptureDisplayAudio;

  static bool _platformCanCapture() => (canCaptureDisplayAudio ?? browserCanCaptureDisplayAudio)();

  /// Whether a screen share started now may carry audio (server, platform, app settings).
  static bool shouldRequestAudio(io.Socket? socket, {bool onWeb = kIsWeb}) =>
      onWeb && enabled && mode != ScreenAudioMode.never && isSupported(socket) && _platformCanCapture();

  /// Resolves whether this share includes audio. In [ScreenAudioMode.ask] it shows the dialog when a [context] is
  /// available (without one, the browser picker's own audio option decides). Returns null when the user cancels.
  static Future<bool?> resolveShareAudio(io.Socket? socket, BuildContext? context, {bool onWeb = kIsWeb}) async {
    if (!shouldRequestAudio(socket, onWeb: onWeb)) return false;
    if (mode == ScreenAudioMode.always || context == null) return true;
    final choice = await (prompt ?? showScreenAudioPrompt)(context);
    if (choice == null) return null;
    return choice == ScreenAudioChoice.audio;
  }

  /// The default dialog: "Screen + audio" (primary), "Screen only", "Cancel".
  static Future<ScreenAudioChoice?> showScreenAudioPrompt(BuildContext context) {
    const accent = Color(0xFF0D9488);
    return showDialog<ScreenAudioChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Share audio too?'),
        content: const Text(
            'Include the sound from the tab or screen you share, such as a video or music. '
            'Your browser asks what to share next.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(ScreenAudioChoice.video),
            child: const Text('Screen only'),
          ),
          FilledButton(
            autofocus: true,
            style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(dialogContext).pop(ScreenAudioChoice.audio),
            child: const Text('Screen + audio'),
          ),
        ],
      ),
    );
  }

  // Listener side: producer ids announced as screen audio (ids are globally unique).
  static final Set<String> _screenAudioProducerIds = <String>{};

  /// Records a producer announced with `mediaTag: 'screen-audio'`.
  static void markProducer(String? producerId, Object? mediaTag) {
    if (producerId != null && producerId.isNotEmpty && mediaTag == kScreenAudioMediaTag) {
      _screenAudioProducerIds.add(producerId);
    }
  }

  static void forgetProducer(String? producerId) {
    if (producerId != null) _screenAudioProducerIds.remove(producerId);
  }

  /// True when the producer is screen audio, by server tag or the sharer's `ScreenAudioID`.
  static bool isScreenAudioProducer(String producerId, [List<Participant> participants = const []]) =>
      producerId.isNotEmpty &&
      (_screenAudioProducerIds.contains(producerId) ||
          participants.any((p) => p['ScreenAudioID'] == producerId));

  /// Name of the participant sharing this screen audio (or the current screen sharer).
  static String ownerName(String producerId, List<Participant> participants) {
    for (final p in participants) {
      if (p['ScreenAudioID'] == producerId) return p.name;
    }
    for (final p in participants) {
      if (p.ScreenOn == true && (p.ScreenID ?? '').isNotEmpty) return p.name;
    }
    return '';
  }

  /// Mutes or unmutes the sharer's screen audio without stopping the screen share. Returns the new muted state, or
  /// null when no screen audio is being shared.
  static bool? toggle(io.Socket? socket, {bool? paused}) {
    final producer = producerFor(socket);
    if (producer == null) return null;
    final next = paused ?? !producer.paused;
    if (next && !producer.paused) producer.pause();
    if (!next && producer.paused) producer.resume();
    return producer.paused;
  }

  /// The `audio` member for `getDisplayMedia`.
  static Object displayAudioConstraint(io.Socket? socket, {bool onWeb = kIsWeb}) =>
      shouldRequestAudio(socket, onWeb: onWeb) ? Map<String, dynamic>.from(audioConstraints) : false;

  static Producer? producerFor(io.Socket? socket) {
    if (socket == null) return null;
    final producer = _producerBySocket[socket];
    if (producer != null && producer.closed) {
      _producerBySocket[socket] = null;
      return null;
    }
    return producer;
  }

  /// Called by the send transport's producer callback for producers with [kScreenAudioSource].
  static void rememberProducer(io.Socket? socket, Producer? producer) {
    if (socket != null) _producerBySocket[socket] = producer;
  }

  /// Publishes the stream's audio as screen audio on [transport]. Returns false when there is nothing to publish
  /// (no audio track, unsupported server or platform, turned off, or no transport).
  static bool publish({
    required MediaStream stream,
    required Transport? transport,
    required io.Socket? socket,
    bool onWeb = kIsWeb,
  }) {
    if (!shouldRequestAudio(socket, onWeb: onWeb)) return false;
    final tracks = stream.getAudioTracks();
    if (tracks.isEmpty || transport == null || transport.closed) return false;
    if (producerFor(socket) != null) return true;
    final track = tracks.first;
    transport.produce(
      track: track,
      stream: stream,
      codecOptions: ProducerCodecOptions(
        opusStereo: 1,
        opusFec: 1,
        opusDtx: 0,
        opusMaxAverageBitrate: 128000,
      ),
      // The track belongs to the screen-share stream, which stops it with the share.
      stopTracks: false,
      appData: const {'mediaTag': kScreenAudioMediaTag},
      source: kScreenAudioSource,
    );
    track.onEnded = () => close(socket, notifyServer: true);
    return true;
  }

  /// Closes the screen-audio producer, if any. [notifyServer] is for when only the audio stops; when the whole
  /// screen share stops the server closes screen audio itself.
  static void close(io.Socket? socket, {bool notifyServer = false}) {
    final producer = producerFor(socket);
    if (producer == null) return;
    try {
      producer.close();
    } catch (_) {}
    rememberProducer(socket, null);
    if (notifyServer) {
      try {
        socket?.emit('closeScreenAudioProducer');
      } catch (_) {}
    }
  }
}
