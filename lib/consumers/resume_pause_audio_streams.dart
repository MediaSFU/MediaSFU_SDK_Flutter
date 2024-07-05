import 'dart:async';
import 'package:flutter/foundation.dart';

/// Resumes or pauses audio streams based on the current room and breakout status.
///
/// The [breakRoom] parameter is the breakout room number.
/// The [inBreakRoom] parameter indicates whether the user is in a breakout room.
/// The [parameters] parameter is a map containing various parameters and state values.
///
/// The function performs the following steps:
/// 1. Retrieves updated parameters.
/// 2. Determines the room based on breakout status.
/// 3. Filters and updates the list of audio streams to resume or pause based on the current room.
/// 4. Processes consumer transports to resume or pause audio streams.

typedef GetUpdatedAllParamsFunction = Map<String, dynamic> Function();
typedef UpdateLimitedBreakRoomFunction = void Function(List<dynamic>);
typedef ProcessConsumerTransportsAudio = Future<void> Function({
  required List<dynamic> consumerTransports,
  required List<dynamic> lStreams,
  required Map<String, dynamic> parameters,
});

Future<void> resumePauseAudioStreams({
  required int breakRoom,
  required bool inBreakRoom,
  required Map<String, dynamic> parameters,
}) async {
  GetUpdatedAllParamsFunction getUpdatedAllParams =
      parameters['getUpdatedAllParams'];

  parameters = getUpdatedAllParams();
  try {
    // Destructure parameters
    var breakoutRooms = parameters['breakoutRooms'] as List<dynamic>;
    var refParticipants = parameters['refParticipants'] as List<dynamic>;
    var allAudioStreams = parameters['allAudioStreams'] as List<dynamic>;
    var participants = parameters['participants'] as List<dynamic>;
    var islevel = parameters['islevel'] as String;
    var eventType = parameters['eventType'] as String;
    var consumerTransports = parameters['consumerTransports'] as List<dynamic>;
    // ignore: unused_local_variable
    var limitedBreakRoom = parameters['limitedBreakRoom'] as List<dynamic>;
    var hostNewRoom = parameters['hostNewRoom'] as int;
    var member = parameters['member'] as String;

    UpdateLimitedBreakRoomFunction updateLimitedBreakRoom =
        parameters['updateLimitedBreakRoom'];
    ProcessConsumerTransportsAudio processConsumerTransportsAudio =
        parameters['processConsumerTransportsAudio'];

    List<dynamic> room;
    List<dynamic> currentStreams = [];

    // Determine the room based on breakout status
    if (inBreakRoom && breakRoom != -1) {
      room = breakoutRooms[breakRoom];
      limitedBreakRoom = room;
    } else {
      room = refParticipants
          .where((participant) => !breakoutRooms
              .expand((x) => x)
              .map((obj) => obj['name'])
              .contains(participant['name']))
          .toList();
      limitedBreakRoom = room;
    }
    updateLimitedBreakRoom(room);

    try {
      bool addHostAudio = false;

      if (islevel != '2' && eventType == 'conference') {
        var roomMember = breakoutRooms.firstWhere(
            (r) => r.any((p) => p['name'] == member),
            orElse: () => null);
        int memberBreakRoom = -1;
        if (roomMember != null) {
          memberBreakRoom = breakoutRooms.indexOf(roomMember);
        }
        if ((inBreakRoom && breakRoom != hostNewRoom) ||
            (!inBreakRoom &&
                hostNewRoom != -1 &&
                hostNewRoom != memberBreakRoom)) {
          var host = participants.firstWhere((obj) => obj['islevel'] == '2');
          // Remove the host from the room
          room = room
              .where((participant) => participant['name'] != host['name'])
              .toList();
        } else {
          if ((inBreakRoom && breakRoom == hostNewRoom) ||
              (!inBreakRoom && hostNewRoom == -1) ||
              (!inBreakRoom &&
                  hostNewRoom == memberBreakRoom &&
                  memberBreakRoom != -1)) {
            addHostAudio = true;
          }
        }
      }

      for (var participant in room) {
        var streams = allAudioStreams.where((stream) {
          if ((stream.containsKey('producerId') &&
                  stream['producerId'] != null) ||
              (stream.containsKey('audioID') && stream['audioID'] != null)) {
            var producerId = stream['producerId'] ?? stream['audioID'];
            var matchingParticipant = refParticipants.firstWhere(
                (obj) => obj['audioID'] == producerId,
                orElse: () => null);
            return matchingParticipant != null &&
                matchingParticipant['name'] == participant['name'];
          }
          return false;
        }).toList();

        currentStreams.addAll(streams);
      }

      // If webinar, add the host audio stream if it is not in the currentStreams
      if (islevel != '2' && (eventType == 'webinar' || addHostAudio)) {
        var host = participants.firstWhere((obj) => obj['islevel'] == '2');
        var hostStream = allAudioStreams.firstWhere(
            (obj) => obj['producerId'] == host['audioID'],
            orElse: () => null);
        if (hostStream != null && !currentStreams.contains(hostStream)) {
          currentStreams.add(hostStream);
          if (!room.map((obj) => obj['name']).contains(host['name'])) {
            room.add({'name': host['name'], 'breakRoom': -1});
          }
          updateLimitedBreakRoom(room);
        }
      }

      await processConsumerTransportsAudio(
        consumerTransports: consumerTransports,
        lStreams: currentStreams,
        parameters: parameters,
      );
    } catch (error) {
      if (kDebugMode) {
        print('Error in resumePauseAudioStreams: $error');
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error in MediaSFU resumePauseAudioStreams: $error');
    }
  }
}
