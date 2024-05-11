import 'dart:async';
import 'package:flutter/foundation.dart';

/// Resumes or pauses consumer streams based on the provided parameters.
///
/// The [parameters] map should contain the following keys:
/// - 'participants': A list of dynamic objects representing the participants.
/// - 'dispActiveNames': A list of strings representing the active participant names.
/// - 'consumerTransports': A list of dynamic objects representing the consumer transports.
/// - 'screenId': A string representing the screen ID.
/// - 'islevel': A string representing the level of the user.
///
/// This function resumes the consumer transports for the video IDs of the participants
/// in [dispActiveNames] and [screenId], excluding the host video ID if the user is the host.
/// It uses the provided [consumerTransports] to resume the consumer transports and emits
/// the 'consumer-resume' event to the corresponding socket. If the resume operation is successful,
/// it calls the `resume()` method on the consumer object.
///
/// Throws an error if there is an error during the process of resuming or pausing streams.

Future<void> resumePauseStreams(
    {required Map<String, dynamic> parameters}) async {
  List<dynamic> participants = parameters['participants'];
  List<String> dispActiveNames = parameters['dispActiveNames'];
  List<dynamic> consumerTransports = parameters['consumerTransports'];
  String screenId = parameters['screenId'];
  String islevel = parameters['islevel'];

  try {
    // Get the videoID of the host (islevel=2)
    var host = participants.firstWhere(
        (participant) => participant['islevel'] == '2',
        orElse: () => null);
    var hostVideoID = host != null ? host['videoID'] : null;

    // Get videoIDs of participants in dispActiveNames and screenproducerId
    var videosIDs = dispActiveNames.map((name) {
      var participant = participants.firstWhere(
          (participant) => participant['name'] == name,
          orElse: () => null);
      return participant != null ? participant['videoID'] : null;
    }).toList();

    // Add screenproducerId to allVideoIDs if it's not null or empty
    if (screenId.isNotEmpty) {
      videosIDs.add(screenId);
    }

    // Add hostVideoID to allVideoIDs if it's not null or empty (only if the user is not the host)
    if (islevel != '2' && hostVideoID != null && hostVideoID.isNotEmpty) {
      videosIDs.add(hostVideoID);
    }

    // Remove null or empty videoIDs
    var allVideoIDs = videosIDs
        .where((videoID) => videoID != null && videoID.isNotEmpty)
        .toList();

    if (allVideoIDs.isNotEmpty) {
      // Get consumer transports with producerId in allVideoIDs
      var consumerTransportsToResume = consumerTransports.where((transport) =>
          allVideoIDs.contains(transport['producerId']) &&
          transport['consumer'].track.kind != 'audio');

      // Resume all consumerTransportsToResume
      for (var transport in consumerTransportsToResume) {
        await transport['socket_'].emitWithAck('consumer-resume', {
          'serverConsumerId': transport['serverConsumerTransportId']
        }, ack: (responseData) async {
          var resumed = responseData['resumed'];
          if (resumed) {
            await transport['consumer'].resume();
          }
        });
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error during resuming or pausing streams: $error');
    }
    // Handle errors during the process of resuming or pausing streams
    // throw Error('Error during resuming or pausing streams: $error.message');
  }
}
