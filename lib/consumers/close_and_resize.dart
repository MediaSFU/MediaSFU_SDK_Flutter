import 'dart:async';

/// Closes and resizes the media streams based on the provided parameters.
///
/// The [producerId] is the ID of the producer.
/// The [kind] specifies the type of media stream (audio, video, screenshare, or screen).
/// The [parameters] is a map containing various parameters related to the media streams.
///
/// Usage:
/// ```dart
/// await closeAndResize(
///   producerId: '123',
///   kind: 'audio',
///   parameters: {
///     'getUpdatedAllParams': () => {...},
///     'allAudioStreams': [...],
///     'allVideoStreams': [...],
///     'activeNames': [...],
///     'participants': [...],
///     'streamNames': [...],
///     'recordingDisplayType': 'video',
///     'recordingVideoOptimized': true,
///     'adminIDStream': '456',
///     'newLimitedStreams': [...],
///     'newLimitedStreamsIDs': [...],
///     'oldAllStreams': [...],
///     'shareScreenStarted': true,
///     'shared': true,
///     'meetingDisplayType': 'video',
///     'deferReceive': true,
///     'lockScreen': true,
///     'firstAll': true,
///     'firstRound': true,
///     'gotAllVids': true,
///     'eventType': 'conference',
///     'hostLabel': 'Host',
///     'shareEnded': true,
///     'updateMainWindow': true,
///     'reorderStreams': () async {...},
///     'prepopulateUserMedia': () => [...],
///     'getVideos': () async {...},
///     'rePort': () async {...},
///   },
/// );
/// ```

typedef GetUpdatedAllParams = Map<String, dynamic> Function();

typedef CloseAndResizeFunction = Future<void> Function({
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

typedef GetVideos = Future<void> Function({
  required Map<String, dynamic> parameters,
});

typedef RePort = Future<void> Function({
  bool restart,
  required Map<String, dynamic> parameters,
});

typedef UpdateActiveNamesFunction = void Function(List<String>);
typedef UpdateAllAudioStreamsFunction = void Function(List<dynamic>);
typedef UpdateAllVideoStreamsFunction = void Function(List<dynamic>);
typedef UpdateSharedFunction = void Function(bool);
typedef UpdateShareScreenStartedFunction = void Function(bool);
typedef UpdateUpdateMainWindowFunction = void Function(bool);
typedef UpdateNewLimitedStreamsFunction = void Function(List<dynamic>);
typedef UpdateNewLimitedStreamsIDsFunction = void Function(List<String>);
typedef UpdateOldAllStreamsFunction = void Function(List<dynamic>);
typedef UpdateDeferReceiveFunction = void Function(bool);
typedef UpdateMainHeightWidthFunction = void Function(int);
typedef UpdateShareEndedFunction = void Function(bool);
typedef UpdateLockScreenFunction = void Function(bool);
typedef UpdateFirstAllFunction = void Function(bool);
typedef UpdateFirstRoundFunction = void Function(bool);
typedef UpdateGotAllVidsFunction = void Function(bool);
typedef UpdateEventTypeFunction = void Function(String);

// Usage:
Future<void> closeAndResize({
  required String producerId,
  required String kind,
  required Map<String, dynamic> parameters,
}) async {
  GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];

  parameters = getUpdatedAllParams();

  List<dynamic> allAudioStreams = parameters['allAudioStreams'];
  List<dynamic> allVideoStreams = parameters['allVideoStreams'];
  List<String> activeNames = parameters['activeNames'];
  List<dynamic> participants = parameters['participants'];
  List<dynamic> streamNames = parameters['streamNames'];
  String recordingDisplayType = parameters['recordingDisplayType'];
  bool recordingVideoOptimized = parameters['recordingVideoOptimized'];
  String adminIDStream = parameters['adminIDStream'];
  List<dynamic> newLimitedStreams = parameters['newLimitedStreams'];
  List<String> newLimitedStreamsIDs = parameters['newLimitedStreamsIDs'];
  List<dynamic> oldAllStreams = parameters['oldAllStreams'];
  bool shareScreenStarted = parameters['shareScreenStarted'];
  bool shared = parameters['shared'];
  String meetingDisplayType = parameters['meetingDisplayType'];
  bool? deferReceive = parameters['deferReceive'];
  bool? lockScreen = parameters['lockScreen'];
  bool? firstAll = parameters['firstAll'];
  bool? firstRound = parameters['firstRound'];
  bool? gotAllVids = parameters['gotAllVids'];
  String? eventType = parameters['eventType'];
  String? hostLabel = parameters['hostLabel'];
  bool? shareEnded = parameters['shareEnded'];
  bool? updateMainWindow = parameters['updateMainWindow'];

  UpdateActiveNamesFunction updateActiveNames = parameters['updateActiveNames'];
  UpdateAllAudioStreamsFunction updateAllAudioStreams =
      parameters['updateAllAudioStreams'];
  UpdateAllVideoStreamsFunction updateAllVideoStreams =
      parameters['updateAllVideoStreams'];
  UpdateShareScreenStartedFunction updateShareScreenStarted =
      parameters['updateShareScreenStarted'];
  UpdateUpdateMainWindowFunction updateUpdateMainWindow =
      parameters['updateUpdateMainWindow'];
  UpdateNewLimitedStreamsFunction updateNewLimitedStreams =
      parameters['updateNewLimitedStreams'];
  UpdateOldAllStreamsFunction updateOldAllStreams =
      parameters['updateOldAllStreams'];
  UpdateDeferReceiveFunction updateDeferReceive =
      parameters['updateDeferReceive'];
  UpdateMainHeightWidthFunction updateMainHeightWidth =
      parameters['updateMainHeightWidth'];
  UpdateShareEndedFunction updateShareEnded = parameters['updateShareEnded'];
  UpdateLockScreenFunction updateLockScreen = parameters['updateLockScreen'];
  UpdateFirstAllFunction updateFirstAll = parameters['updateFirstAll'];
  UpdateFirstRoundFunction updateFirstRound = parameters['updateFirstRound'];

  // mediasfu functions
  ReorderStreams reorderStreams = parameters['reorderStreams'];
  PrepopulateUserMedia prepopulateUserMedia =
      parameters['prepopulateUserMedia'];
  GetVideos getVideos = parameters['getVideos'];
  RePort rePort = parameters['rePort'];

  try {
    dynamic participant;

    if (kind == 'audio') {
      // Stop the audio by removing the miniAudio with id = producerId
      allAudioStreams.removeWhere(
          (audioStream) => audioStream['producerId'] == producerId);
      updateAllAudioStreams(allAudioStreams);

      if (recordingDisplayType == 'video' && recordingVideoOptimized) {
        // Handle optimized recording case
      } else {
        // Get the name of the participant with the producerId
        participant = participants.firstWhere(
            (obj) => obj['audioID'] == producerId,
            orElse: () => null);

        if (participant != null) {
          if (participant['videoID'] == null || participant['videoID'] == "") {
            // Remove the participant from the activeNames array
            activeNames.removeWhere((name) => name == participant['name']);
            updateActiveNames(activeNames);
          }
        }
      }

      // Check if the participant's videoID is not null or ""
      var checker = meetingDisplayType == 'video'
          ? participant[0]['videoID'] != null && participant[0]['videoID'] != ""
          : true;

      if (checker) {
        if (shareScreenStarted || shared) {
          if (meetingDisplayType != 'video' ||
              participant[0]['videoID'] != null &&
                  participant[0]['videoID'] != "") {
            await reorderStreams(parameters: parameters);
          }
        } else {
          if (meetingDisplayType != 'video') {
            await reorderStreams(
                add: false, screenChanged: true, parameters: parameters);
          }
        }
      }
    } else if (kind == 'video') {
      if (producerId == adminIDStream) {
        updateMainWindow = true;
        updateUpdateMainWindow(updateMainWindow);
      }

      allVideoStreams.removeWhere(
          (videoStream) => videoStream['producerId'] == producerId);
      updateAllVideoStreams(allVideoStreams);

      oldAllStreams.removeWhere(
          (videoStream) => videoStream['producerId'] == producerId);
      updateOldAllStreams(oldAllStreams);

      newLimitedStreams.removeWhere(
          (videoStream) => videoStream['producerId'] == producerId);
      updateNewLimitedStreams(newLimitedStreams);

      // Remove the participant from activeNames
      activeNames.removeWhere((name) {
        var participant = streamNames.firstWhere(
            (obj) => obj['producerId'] == producerId,
            orElse: () => null);
        return participant != null ? name == participant['name'] : false;
      });
      updateActiveNames(activeNames);

      if (lockScreen!) {
        deferReceive = true;
        if (newLimitedStreamsIDs.contains(producerId)) {
          prepopulateUserMedia(name: hostLabel!, parameters: parameters);
          await reorderStreams(
              add: false, screenChanged: true, parameters: parameters);
        }
      } else {
        prepopulateUserMedia(name: hostLabel!, parameters: parameters);
        await reorderStreams(
            add: false, screenChanged: true, parameters: parameters);
      }
    } else if (kind == 'screenshare' || kind == 'screen') {
      updateMainWindow = true;

      shareScreenStarted = false;
      shareEnded = true;
      lockScreen = false;
      firstAll = false;
      firstRound = false;

      updateShareScreenStarted(shareScreenStarted);
      updateShareEnded(shareEnded);
      updateLockScreen(lockScreen);
      updateFirstAll(firstAll);
      updateFirstRound(firstRound);

      if (!gotAllVids! || deferReceive!) {
        deferReceive = false;
        updateDeferReceive(deferReceive);
        await getVideos(parameters: parameters);
        await rePort(parameters: parameters);
      }

      if (eventType == 'conference') {
        updateMainHeightWidth(0);
      }

      prepopulateUserMedia(name: hostLabel!, parameters: parameters);
      await reorderStreams(
          add: false, screenChanged: true, parameters: parameters);
    }
  } catch (error) {
    // Handle error
  }
}
