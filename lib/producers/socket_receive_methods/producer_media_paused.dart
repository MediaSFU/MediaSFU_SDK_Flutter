// ignore_for_file: empty_catches

import 'dart:async';

/// Pauses the audio, video, or screenshare of a participant.
///
/// [producerId] is the ID of the producer.
/// [kind] is the kind of media (audio, video, screenshare).
/// [name] is the name of the participant.
/// [parameters] is a map of additional parameters.
///
/// The function iterates through all activeSounds and checks if any participant with the muted property set to true is in it, and removes them.
/// It also updates the UI based on the mediaDisplayType and optimizes interest levels for audio.
/// If screenshare is active, it removes the participant from activeSounds and updates the UI accordingly.
/// If screenshare is not active, it obeys the user display settings.
///
/// The function also handles updating the UI based on the mediaDisplayType and meetingVideoOptimized.
/// It checks if the participant's videoID is null or empty and updates the UI accordingly.
///
/// If the kind is 'audio', it stops the audio by removing the miniAudio with the specified producerId.
/// It also checks if the participant's name is in oldSoundIds and updates the UI accordingly.
///
/// Throws an error if any exception occurs during the process.

typedef ReUpdateInter = Future<void> Function({
  required String name,
  bool add,
  bool force,
  double average,
  required Map<String, dynamic> parameters,
});

typedef CloseAndResize = Future<void> Function({
  required String producerId,
  required String kind,
  required Map<String, dynamic> parameters,
});

typedef PrepopulateUserMedia = List<dynamic> Function({
  required String name,
  required Map<String, dynamic> parameters,
});

typedef ReorderStreams = Future<void> Function({
  bool add,
  bool screenChanged,
  required Map<String, dynamic> parameters,
});

typedef UpdateActiveSounds = void Function(List<String> activeSounds);
typedef UpdateOldSoundIds = void Function(List<String> oldSoundIds);
typedef UpdateShared = void Function(bool shared);
typedef UpdateShareScreenStarted = void Function(bool shareScreenStarted);
typedef UpdateUpdateMainWindow = void Function(bool updateMainWindow);
typedef UpdateParticipants = void Function(List<dynamic> participants);

Future<void> producerMediaPaused(
    {required String producerId,
    required String kind,
    required String name,
    required Map<String, dynamic> parameters}) async {
  // Update to pause the audio, video, screenshare of a participant
  // producerId is the id of the producer
  // kind is the kind of media (audio, video, screenshare)
  // name is the name of the participant

  List<String> activeSounds = parameters['activeSounds'];
  String meetingDisplayType = parameters['meetingDisplayType'];
  bool meetingVideoOptimized = parameters['meetingVideoOptimized'];
  List<dynamic> participants = parameters['participants'];
  List<dynamic> oldSoundIds = parameters['oldSoundIds'];
  bool shared = parameters['shared'];
  bool shareScreenStarted = parameters['shareScreenStarted'];
  String hostLabel = parameters['hostLabel'];
  String islevel = parameters['islevel'];

  UpdateActiveSounds updateActiveSounds = parameters['updateActiveSounds'];

  //mediasfu functions
  PrepopulateUserMedia prepopulateUserMedia =
      parameters['prepopulateUserMedia'];
  ReorderStreams reorderStreams = parameters['reorderStreams'];
  ReUpdateInter reUpdateInter = parameters['reUpdateInter'];

  // Iterate through all activeSounds and check if any participant with muted property of true is in it and remove it
  for (var participant in participants) {
    // Update the UI for mediaDisplayTypes and re-render
    if (participant['muted']) {
      if (participant['islevel'] == '2') {
        // Look for videoID is null or "" or undefined
        if (participant['videoID'] == null || participant['videoID'] == "") {
          if (!shared && !shareScreenStarted && islevel != '2') {
            prepopulateUserMedia(name: hostLabel, parameters: parameters);
          }
        }
      }

      if (shareScreenStarted || shared) {
        // Check if the participant is in activeSounds
        // Remove the participant from activeSounds if need be; others might have both audio and video on
        if (activeSounds.contains(participant['name'])) {
          activeSounds.remove(participant['name']);
          updateActiveSounds(activeSounds);
        }

        try {
          reUpdateInter(
              name: participant['name'],
              add: false,
              force: true,
              parameters: parameters);
        } catch (error) {}
      } else {
        // No screensahre so obey user display settings; show waveforms, ..
      }
    }
  }

  // Operation to update the UI based on the mediaDisplayType
  bool checker = false;

  if (meetingDisplayType == 'media' ||
      (meetingDisplayType == 'video' && !meetingVideoOptimized)) {
    var participant = participants.firstWhere((obj) => obj['name'] == name,
        orElse: () => null);
    checker = participant != null &&
        participant['videoID'] != null &&
        participant['videoID'] != "";

    if (!checker) {
      if (shareScreenStarted || shared) {
      } else {
        reorderStreams(add: false, screenChanged: true, parameters: parameters);
      }
    }
  }

  if (kind == 'audio') {
    // Operation to update UI to optimize interest levels
    // Stop the audio by removing the miniAudio with id = producerId
    // Get audio element with id = producerId
    try {
      var participant = participants.firstWhere(
          (obj) => obj['audioID'] == producerId,
          orElse: () => null);

      // Check if the participant name is in oldSoundsIds
      if (participant != null && oldSoundIds.contains(participant['name'])) {
        // Remove the participant name from oldSoundsIds
        reUpdateInter(
            name: participant['name'],
            add: false,
            force: true,
            parameters: parameters);
      }
    } catch (error) {}
  }
}
