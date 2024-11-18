import 'dart:async';
import 'package:flutter/foundation.dart';
import '../types/types.dart' show Participant, Stream;

/// Options for retrieving and processing video streams.
class GetVideosOptions {
  final List<Participant> participants;
  final List<Stream> allVideoStreams; // Stream or Participant
  final List<Stream> oldAllStreams; // Stream or Participant
  final String? adminVidID;
  final UpdateAllVideoStreamsFunction updateAllVideoStreams;
  final UpdateOldAllStreamsFunction updateOldAllStreams;

  GetVideosOptions({
    required this.participants,
    required this.allVideoStreams,
    required this.oldAllStreams,
    this.adminVidID,
    required this.updateAllVideoStreams,
    required this.updateOldAllStreams,
  });
}

typedef GetVideosType = Future<void> Function(
    {required GetVideosOptions options});

/// Function type for updating the list of all video streams.
typedef UpdateAllVideoStreamsFunction = void Function(List<Stream>);

/// Function type for updating the list of old video streams.
typedef UpdateOldAllStreamsFunction = void Function(List<Stream>);

/// Processes and updates video streams by filtering out the admin's video stream.
///
/// Filters out the admin's video stream from the list of all video streams and updates
/// the state variables using the provided update functions. If no admin's video stream
/// is found, it reverts to the previous state.
///
/// - [options] (`GetVideosOptions`): Configuration options containing the list of participants,
///   video streams, and functions for updating the state.
///
/// Example:
/// ```dart
/// final options = GetVideosOptions(
///   participants: participantList,
///   allVideoStreams: allStreams,
///   oldAllStreams: oldStreams,
///   adminVidID: 'admin-video-id',
///   updateAllVideoStreams: (streams) => print('All video streams updated: $streams'),
///   updateOldAllStreams: (streams) => print('Old video streams updated: $streams'),
/// );
///
/// await getVideos(options: options);
/// ```
///
/// Throws:
/// If an error occurs during the process of updating video streams, it logs the error in debug mode and rethrows it.
Future<void> getVideos({required GetVideosOptions options}) async {
  try {
    var participants = options.participants;
    List<Stream> allVideoStreams = List.from(options.allVideoStreams);
    List<Stream> oldAllStreams = List.from(options.oldAllStreams);
    String? adminVidID = options.adminVidID;

    // Filter for participants with admin level "2"
    var admin = participants
        .where((participant) => participant.islevel == '2')
        .toList();

    if (admin.isNotEmpty) {
      adminVidID = admin[0].videoID;

      if (adminVidID.isNotEmpty) {
        List<Stream> oldAllStreams_ = [];

        // Backup oldAllStreams if it has items
        if (oldAllStreams.isNotEmpty) {
          oldAllStreams_ = List.from(oldAllStreams);
        }

        // Filter old streams for admin's video ID
        oldAllStreams = allVideoStreams
            .where((stream) => stream.producerId == adminVidID)
            .toList();

        // Revert to previous state if no admin's video stream found
        if (oldAllStreams.isEmpty) {
          oldAllStreams = List.from(oldAllStreams_);
        }

        // Update old video streams state
        options.updateOldAllStreams(oldAllStreams);

        // Filter all video streams excluding admin's stream
        allVideoStreams = allVideoStreams
            .where((stream) => stream.producerId != adminVidID)
            .toList();

        // Update all video streams state
        options.updateAllVideoStreams(allVideoStreams);
      }
    }
  } catch (error) {
    // Log error in debug mode
    if (kDebugMode) {
      print('Error updating video streams: ${error.toString()}');
    }
    rethrow;
  }
}
