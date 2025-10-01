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
    MediaStream? stream;

    // Get required parameters
    final allVideoStreams = options.parameters.allVideoStreams;
    final allAudioStreams = options.parameters.allAudioStreams;
    final participants = options.parameters.participants;

    // Search by ID if provided
    if (options.id.isNotEmpty) {
      if (options.kind == 'video') {
        // Find video stream by producer ID
        try {
          final videoStreamObj = allVideoStreams.firstWhere(
            (obj) => obj.producerId == options.id,
          );
          stream = videoStreamObj.stream;
        } catch (e) {
          // Not found
          stream = null;
        }
      } else if (options.kind == 'audio') {
        // Find audio stream by producer ID
        try {
          final audioStreamObj = allAudioStreams.firstWhere(
            (obj) => obj.producerId == options.id,
          );
          stream = audioStreamObj.stream;
        } catch (e) {
          // Not found
          stream = null;
        }
      }
    } else if (options.name.isNotEmpty) {
      // Search by name if ID not provided
      try {
        final participant = participants.firstWhere(
          (part) => part.name == options.name,
        );

        final participantId = participant.id ?? '';

        if (options.kind == 'video') {
          // Find video stream by participant ID
          try {
            final videoStreamObj = allVideoStreams.firstWhere(
              (obj) => obj.producerId == participantId,
            );
            stream = videoStreamObj.stream;
          } catch (e) {
            // Not found
            stream = null;
          }
        } else if (options.kind == 'audio') {
          // Find audio stream by participant ID
          try {
            final audioStreamObj = allAudioStreams.firstWhere(
              (obj) => obj.producerId == participantId,
            );
            stream = audioStreamObj.stream;
          } catch (e) {
            // Not found
            stream = null;
          }
        }
      } catch (e) {
        // Participant not found
        stream = null;
      }
    }

    return stream;
  } catch (e) {
    // Return null if an error occurs
    if (kDebugMode) {
      print('Error getting participant media: $e');
    }
    return null;
  }
}
