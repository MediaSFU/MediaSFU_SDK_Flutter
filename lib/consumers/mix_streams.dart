import 'dart:async';
import 'package:flutter/foundation.dart';

/// Mixes video streams based on the given parameters.
///
/// The [parameters] map should contain the following keys:
/// - 'getUpdatedAllParams': A function that returns a map of updated parameters.
/// - 'alVideoStreams': A list of video streams from the 'al' category.
/// - 'nonAlVideoStreams': A list of video streams from the 'non-al' category.
/// - 'refParticipants': A list of reference participants.
///
/// The function first destructures the parameters and retrieves the updated parameters
/// using the 'getUpdatedAllParams' function. It then separates the 'al' and 'non-al'
/// video streams and reference participants from the parameters.
///
/// Next, it filters the 'al' video streams based on whether they are muted or not,
/// and whether the corresponding participant is muted or not. The unmuted 'al' video
/// streams are added to the 'mixedStreams' list.
///
/// The function then interleaves the muted 'al' video streams and 'non-al' video streams
/// in the 'mixedStreams' list. It starts by adding the first 'non-al' video stream, followed
/// by the first muted 'al' video stream, and so on.
///
/// After that, any remaining 'non-al' video streams are added to the 'mixedStreams' list.
///
/// Finally, if there is a 'youyou' or 'youyouyou' video stream, it is inserted at the beginning
/// of the 'mixedStreams' list.
///
/// The function returns the resulting 'mixedStreams' list.
///
/// If an error occurs during the process of mixing streams, it is handled and rethrown.
/// If the code is running in debug mode, the error is printed to the console.

typedef GetUpdatedAllParams = Map<String, dynamic> Function();

Future<List<dynamic>> mixStreams(
    {required Map<String, dynamic> parameters}) async {
  try {
    // Destructure parameters
    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
    parameters = getUpdatedAllParams();

    var alVideoStreams = parameters['alVideoStreams'] as List<dynamic>;
    var nonAlVideoStreams = parameters['nonAlVideoStreams'] as List<dynamic>;
    var refParticipants = parameters['refParticipants'] as List<dynamic>;

    var mixedStreams = <dynamic>[];
    var youyouStream = alVideoStreams.firstWhere(
        (obj) =>
            obj['producerId'] == 'youyou' || obj['producerId'] == 'youyouyou',
        orElse: () => null);
    alVideoStreams = alVideoStreams
        .where((obj) =>
            obj['producerId'] != 'youyou' && obj['producerId'] != 'youyouyou')
        .toList();

    var unmutedAlVideoStreams = alVideoStreams.where((obj) {
      var participant = refParticipants.firstWhere(
          (p) => p['videoID'] == obj['producerId'],
          orElse: () => null);
      return !obj['muted'] &&
          participant != null &&
          participant['muted'] == false;
    }).toList();

    var mutedAlVideoStreams = alVideoStreams.where((obj) {
      var participant = refParticipants.firstWhere(
          (p) => p['videoID'] == obj['producerId'],
          orElse: () => null);
      return obj['muted'] ||
          (participant != null && participant['muted'] == true);
    }).toList();

    nonAlVideoStreams =
        List.from(nonAlVideoStreams); // Create a copy of nonAlVideoStreams

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

    // Handle remaining nonAlVideoStreams (if any)
    for (var i = nonAlIndex; i < nonAlVideoStreams.length; i++) {
      mixedStreams.add(nonAlVideoStreams[i]);
    }

    // Unshift 'youyou' or 'youyouyou' stream to mixedStreams
    if (youyouStream != null) {
      mixedStreams.insert(0, youyouStream);
    }

    return mixedStreams;
  } catch (error) {
    // Handle errors during the process of mixing streams
    if (kDebugMode) {
      // print('Error mixing streams: ${error.toString()}');
    }
    rethrow;
  }
}
