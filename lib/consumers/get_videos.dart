import 'dart:async';
import 'package:flutter/foundation.dart';

/// Retrieves videos based on the provided parameters and updates the state variables for video streams.
///
/// The [parameters] parameter is a map that contains the following keys:
/// - 'participants': A list of participants.
/// - 'allVideoStreams': A list of all video streams.
/// - 'oldAllStreams': A list of old video streams.
/// - 'adminVidID': The ID of the admin's video stream.
/// - 'updateOldAllStreams': A function to update the state variable for old video streams.
/// - 'updateAllVideoStreams': A function to update the state variable for all video streams.
///
/// The function filters out the admin's video stream from the video streams and updates the state variables accordingly.
/// If no admin's video stream is found, it reverts to the previous state.
///
/// Throws an error if there is an error during the process of updating video streams.

typedef UpdateAllVideoStreamsFunction = void Function(List<dynamic>);
typedef UpdateOldAllStreamsFunction = void Function(List<dynamic>);

Future<void> getVideos({required Map<String, dynamic> parameters}) async {
  try {
    // Destructure parameters
    final List<dynamic> participants = parameters['participants'];
    List<dynamic> allVideoStreams = parameters['allVideoStreams'];
    List<dynamic> oldAllStreams = parameters['oldAllStreams'];
    String adminVidID = parameters['adminVidID'] ?? "";
    UpdateOldAllStreamsFunction updateOldAllStreams =
        parameters['updateOldAllStreams'];
    UpdateAllVideoStreamsFunction updateAllVideoStreams =
        parameters['updateAllVideoStreams'];

    // Filter out the admin's video stream and update state variables
    var admin = participants
        .where((participant) => participant['islevel'] == '2')
        .toList();

    if (admin.isNotEmpty) {
      adminVidID = admin[0]['videoID'];

      if (adminVidID.isNotEmpty && adminVidID != "") {
        var oldAllStreams_ = [];

        // Check if the length of oldAllStreams is greater than 0
        if (oldAllStreams.isNotEmpty) {
          oldAllStreams_ = List.from(oldAllStreams);
        }

        // Filter out admin's video stream from oldAllStreams
        oldAllStreams = allVideoStreams
            .where((stream) => stream['producerId'] == adminVidID)
            .toList();

        // If no admin's video stream found, revert to the previous state
        if (oldAllStreams.isEmpty) {
          oldAllStreams = List.from(oldAllStreams_);
        }

        // Update the state variable for old video streams
        updateOldAllStreams(oldAllStreams);

        // Filter out admin's video stream from allVideoStreams
        allVideoStreams = allVideoStreams
            .where((stream) => stream['producerId'] != adminVidID)
            .toList();

        // Update the state variable for all video streams
        updateAllVideoStreams(allVideoStreams);
      }
    }
  } catch (error) {
    // Handle errors during the process of updating video streams
    if (kDebugMode) {
      // print('Error updating video streams: ${error.toString()}');
    }
    // throw error;
  }
}
