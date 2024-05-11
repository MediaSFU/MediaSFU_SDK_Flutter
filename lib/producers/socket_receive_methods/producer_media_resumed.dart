import 'dart:async';

/// This function is called when a media is resumed for a producer.
/// It takes in the [name], [kind], and [parameters] of the media.
/// The [name] parameter represents the name of the participant.
/// The [kind] parameter represents the kind of media (always audio).
/// The [parameters] parameter is a map that contains various parameters related to the media.
///
/// This function performs operations to update the UI and optimize interest levels.
/// It checks if the main screen is filled and if the participant is at interest level 2.
/// If both conditions are met, it updates the main window, prepopulates the user media, and then resets the main window.
///
/// If the [meetingDisplayType] is 'media', it checks if the participant has a video ID.
/// If the participant does not have a video ID and screen sharing is not started or shared, it calls the [reorderStreams] function.
///
/// Note: This function is specifically for resuming audio media and does not handle video or screenshare media.

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
typedef UpdateUpdateMainWindow = void Function(bool updateMainWindow);

Future<void> producerMediaResumed(
    {required String name,
    required String kind,
    required Map<String, dynamic> parameters}) async {
  String meetingDisplayType = parameters['meetingDisplayType'];
  List<dynamic> participants = parameters['participants'];
  bool shared = parameters['shared'];
  bool shareScreenStarted = parameters['shareScreenStarted'];
  bool updateMainWindow = parameters['updateMainWindow'];
  bool mainScreenFilled = parameters['mainScreenFilled'];

  UpdateUpdateMainWindow updateUpdateMainWindow =
      parameters['updateUpdateMainWindow'];

  // mediasfu functions
  ReorderStreams reorderStreams = parameters['reorderStreams'];
  PrepopulateUserMedia prepopulateUserMedia =
      parameters['prepopulateUserMedia'];

  // Update to resume the audio only of a participant
  // Name is the name of the participant
  // Kind is the kind of media (always audio)
  // This is only emitted for audio (and not video or screenshare)

  // Operations to update UI to optimize interest levels
  var participant =
      participants.firstWhere((obj) => obj['name'] == name, orElse: () => null);

  if (!mainScreenFilled &&
      participant != null &&
      participant['islevel'] == '2') {
    updateMainWindow = true;
    updateUpdateMainWindow(updateMainWindow);
    prepopulateUserMedia(name: name, parameters: parameters);
    updateMainWindow = false;
  }

  bool checker;
  if (meetingDisplayType == 'media') {
    var participant = participants.firstWhere((obj) => obj['name'] == name,
        orElse: () => null);
    checker = participant != null &&
        participant['videoID'] != null &&
        participant['videoID'] != "";

    if (!checker) {
      if (shareScreenStarted || shared) {
      } else {
        await reorderStreams(
            add: false, screenChanged: true, parameters: parameters);
      }
    }
  }
}
