/// Retrieves the media stream of a participant by ID or name.
///
/// This function searches for a participant's media stream (video or audio)
/// using either their producer ID or participant name.
///
/// **Parameters:**
/// - [id] (`String`): The producer ID of the participant. Default is empty string.
/// - [name] (`String`): The name of the participant. Default is empty string.
/// - [kind] (`String`): The type of media stream to retrieve:
///   - `'video'`: Video stream
///   - `'audio'`: Audio stream
///   Default is `'video'`.
/// - [parameters] (`GetParticipantMediaParameters`): Parameters containing:
///   - `allVideoStreams`: List of all video streams
///   - `allAudioStreams`: List of all audio streams
///   - `participants`: List of all participants
///
/// **Returns:**
/// - `Future<MediaStream?>`: The media stream if found, otherwise `null`.
///
/// **Example:**
/// ```dart
/// // Get video stream by producer ID
/// final videoStream = await getParticipantMedia(
///   id: 'producer-id-123',
///   name: '',
///   kind: 'video',
///   parameters: parameters,
/// );
///
/// // Get audio stream by participant name
/// final audioStream = await getParticipantMedia(
///   id: '',
///   name: 'John Doe',
///   kind: 'audio',
///   parameters: parameters,
/// );
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../types/types.dart' show Stream, Participant;

/// Options for the getParticipantMedia function.
class GetParticipantMediaOptions {
  final String id;
  final String name;
  final String kind;
  final GetParticipantMediaParameters parameters;

  GetParticipantMediaOptions({
    this.id = '',
    this.name = '',
    this.kind = 'video',
    required this.parameters,
  });
}

/// Parameters interface for getParticipantMedia.
abstract class GetParticipantMediaParameters {
  List<Stream> get allVideoStreams;
  List<Stream> get allAudioStreams;
  List<Participant> get participants;
}

/// Type definition for the getParticipantMedia function.
typedef GetParticipantMediaType = Future<MediaStream?> Function(
    GetParticipantMediaOptions options);

/// Retrieves the media stream of a participant by ID or name.
Future<MediaStream?> getParticipantMedia(
    GetParticipantMediaOptions options) async {
  try {
    final allVideoStreams = options.parameters.allVideoStreams;
    final allAudioStreams = options.parameters.allAudioStreams;
    final participants = options.parameters.participants;

    final kind = options.kind == 'audio' ? 'audio' : 'video';
    final streams = kind == 'video' ? allVideoStreams : allAudioStreams;
    if (streams.isEmpty) return null;

    MediaStream? firstMatch(String producerId) {
      if (producerId.isEmpty) return null;
      for (final entry in streams) {
        if (entry.producerId == producerId) return entry.stream;
      }
      return null;
    }

    // Resolve the participant by membership id first, then by name.
    Participant? participant;
    if (options.id.isNotEmpty) {
      for (final part in participants) {
        if (part.id == options.id) {
          participant = part;
          break;
        }
      }
    }
    if (participant == null && options.name.isNotEmpty) {
      for (final part in participants) {
        if (part.name == options.name) {
          participant = part;
          break;
        }
      }
    }

    // allVideoStreams / allAudioStreams are keyed by producerId only. A
    // participant's `id` is its membership id and never matches, so the
    // producer reference has to come from videoID / audioID. Matching on `id`
    // is why a lookup by name returned null for everyone.
    if (participant != null) {
      final producerId =
          kind == 'video' ? participant.videoID : participant.audioID;
      final match = firstMatch(producerId);
      if (match != null) return match;
    }

    // A caller that already holds a producer id may pass it directly as `id`.
    return firstMatch(options.id);
  } catch (e) {
    // Return null if an error occurs
    if (kDebugMode) {
      debugPrint('Error getting participant media: $e');
    }
    return null;
  }
}
