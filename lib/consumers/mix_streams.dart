import 'dart:async';
import 'package:flutter/foundation.dart';
import '../types/types.dart' show Participant, Stream;

/// Parameters for mixing video and audio streams with participants.
class MixStreamsOptions {
  final List<Stream> alVideoStreams; // Stream or Participant
  final List<Stream> nonAlVideoStreams;
  final List<Participant> refParticipants; // Stream or Participant

  MixStreamsOptions({
    required this.alVideoStreams,
    required this.nonAlVideoStreams,
    required this.refParticipants,
  });
}

typedef MixStreamsType = Future<List<Stream>> Function({
  required MixStreamsOptions options,
});

/// Mixes video and audio streams and participants based on specified parameters.
///
/// Combines `alVideoStreams`, `nonAlVideoStreams`, and `refParticipants` by interleaving
/// muted and unmuted streams, while ensuring prioritized positioning for streams with specific identifiers.
///
/// - [options] (`MixStreamsOptions`): The options for mixing streams.
///   - `alVideoStreams` (`List<Stream>`): List of "al" category video and audio streams to mix.
///   - `nonAlVideoStreams` (`List<Stream>`): List of non-"al" category streams to mix.
///   - `refParticipants` (`List<Stream>`): List of reference participants.
///
/// Returns:
/// A `Future<List<Stream>>` that completes with the mixed streams list.
///
/// Example:
/// ```dart
/// final mixedStreams = await mixStreams(
///   options: MixStreamsOptions(
///     alVideoStreams: [stream1, stream2],
///     nonAlVideoStreams: [participant1, participant2],
///     refParticipants: [participant1, participant2],
///   ),
/// );
/// print('Mixed streams: $mixedStreams');
/// ```
///
/// Throws:
/// If an error occurs during the process of mixing streams, it logs the error in debug mode and rethrows it.
Future<List<Stream>> mixStreams({
  required MixStreamsOptions options,
}) async {
  try {
    List<Stream> alVideoStreams = List.from(options.alVideoStreams);
    List<Stream> nonAlVideoStreams = List.from(options.nonAlVideoStreams);
    var refParticipants = options.refParticipants;

    var mixedStreams = <Stream>[];

    // Identify "youyou" or "youyouyou" stream
    var youyouStream = alVideoStreams.firstWhere(
      (obj) => obj.producerId == 'youyou' || obj.producerId == 'youyouyou',
      orElse: () => Stream(
        producerId: '',
        name: '',
        muted: false,
      ),
    );

    alVideoStreams = alVideoStreams
        .where((obj) =>
            obj.producerId != 'youyou' && obj.producerId != 'youyouyou')
        .toList();

    // Separate unmuted and muted streams
    var unmutedAlVideoStreams = alVideoStreams.where((obj) {
      var participant = refParticipants.firstWhere(
          (p) => p.videoID == obj.producerId,
          orElse: () => Participant(
              name: 'none', videoID: '', audioID: '', muted: false));
      return !obj.muted! &&
          participant.muted == false &&
          (participant.name != 'none');
    }).toList();

    var mutedAlVideoStreams = alVideoStreams.where((obj) {
      var participant = refParticipants.firstWhere(
          (p) => p.videoID == obj.producerId,
          orElse: () => Participant(
              name: 'none', videoID: '', audioID: '', muted: false));
      return obj.muted! ||
          (participant.name != 'none' && participant.muted == true);
    }).toList();

    // Add unmutedAlVideoStreams to mixedStreams
    mixedStreams.addAll(unmutedAlVideoStreams);

    // Interleave the mutedAlVideoStreams and nonAlVideoStreams
    var nonAlIndex = 0;
    for (var i = 0; i < mutedAlVideoStreams.length; i++) {
      if (nonAlIndex < nonAlVideoStreams.length) {
        mixedStreams.add(nonAlVideoStreams[nonAlIndex]);
        nonAlIndex++;
      }
      mixedStreams.add(mutedAlVideoStreams[i]);
    }

    // Add any remaining nonAlVideoStreams
    mixedStreams.addAll(nonAlVideoStreams.sublist(nonAlIndex));

    // Insert 'youyou' or 'youyouyou' stream at the start
    if (youyouStream.producerId.isNotEmpty) {
      mixedStreams.insert(0, youyouStream);
    }

    return mixedStreams;
  } catch (error) {
    if (kDebugMode) {
      print('Error mixing streams: ${error.toString()}');
    }
    rethrow;
  }
}
