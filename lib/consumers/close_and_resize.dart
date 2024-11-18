import 'dart:async';
import 'package:flutter/foundation.dart';

import '../types/types.dart'
    show
        EventType,
        Participant,
        Stream,
        ReorderStreamsType,
        PrepopulateUserMediaType,
        GetVideosType,
        RePortType,
        ReorderStreamsParameters,
        PrepopulateUserMediaParameters,
        RePortParameters,
        ReorderStreamsOptions,
        RePortOptions,
        PrepopulateUserMediaOptions,
        GetVideosOptions;

// Parameters Interface
abstract class CloseAndResizeParameters
    implements
        ReorderStreamsParameters,
        PrepopulateUserMediaParameters,
        RePortParameters {
  List<Stream> get allAudioStreams;
  List<Stream> get allVideoStreams;
  List<String> get activeNames;
  List<Participant> get participants;
  List<Stream> get streamNames;
  String get recordingDisplayType;
  bool get recordingVideoOptimized;
  String get adminIDStream;
  List<Stream> get newLimitedStreams;
  List<String> get newLimitedStreamsIDs;
  List<Stream> get oldAllStreams;
  bool get shareScreenStarted;
  bool get shared;
  String get meetingDisplayType;
  bool get deferReceive;
  bool get lockScreen;
  bool get firstAll;
  bool get firstRound;
  bool get gotAllVids;
  EventType get eventType;
  String get hostLabel;
  bool get shareEnded;
  bool get updateMainWindow;

  void Function(List<String> activeNames) get updateActiveNames;
  void Function(List<Stream> allVideoStreams) get updateAllVideoStreams;
  void Function(List<Stream> allAudioStreams) get updateAllAudioStreams;
  void Function(bool shareScreenStarted) get updateShareScreenStarted;
  void Function(bool updateMainWindow) get updateUpdateMainWindow;
  void Function(List<Stream> newLimitedStreams) get updateNewLimitedStreams;
  void Function(List<Stream> oldAllStreams) get updateOldAllStreams;
  void Function(bool deferReceive) get updateDeferReceive;
  void Function(double heightWidth) get updateMainHeightWidth;
  void Function(bool shareEnded) get updateShareEnded;
  void Function(bool lockScreen) get updateLockScreen;
  void Function(bool firstAll) get updateFirstAll;
  void Function(bool firstRound) get updateFirstRound;

  // Mediasfu functions
  ReorderStreamsType get reorderStreams;
  PrepopulateUserMediaType get prepopulateUserMedia;
  GetVideosType get getVideos;
  RePortType get rePort;
  CloseAndResizeParameters Function() get getUpdatedAllParams;
}

// Options Interface
class CloseAndResizeOptions {
  final String producerId;
  final String kind;
  final CloseAndResizeParameters parameters;

  CloseAndResizeOptions({
    required this.producerId,
    required this.kind,
    required this.parameters,
  });
}

// Type definition for the CloseAndResize function
typedef CloseAndResizeType = Future<void> Function(
    CloseAndResizeOptions options);

/// Manages the closing and resizing of streams within a media session, adapting the layout
/// and updating participant and stream information as needed.
///
/// This function performs the following operations based on the specified stream type (`kind`):
/// - **Audio Stream**: Stops audio by removing the relevant stream, updates active participant names, and triggers stream reordering if applicable.
/// - **Video Stream**: Stops video by removing it from both the active and limited streams lists, updates the main window if the admin's video is affected, and triggers reordering.
/// - **Screenshare**: Stops screen sharing, updates various flags, restores deferred video receiving, and triggers reordering.
///
/// ### Parameters:
///
/// - `options` (`CloseAndResizeOptions`): Configuration options for handling the stream:
///   - `producerId` (`String`): The ID of the producer whose stream is being managed.
///   - `kind` (`String`): Specifies the type of stream (`'audio'`, `'video'`, or `'screenshare'`).
///   - `parameters` (`CloseAndResizeParameters`): Additional parameters required for handling:
///     - `allAudioStreams`, `allVideoStreams`: Lists of all active audio and video streams, respectively.
///     - `participants`: List of all participants in the session.
///     - `lockScreen` (`bool`): Indicates if screen is currently locked.
///     - `updateAllVideoStreams` and `updateAllAudioStreams` (functions): Callbacks for updating stream lists.
///     - Various update callbacks for managing flags like `updateMainWindow`, `updateFirstAll`, etc.
///     - `reorderStreams` (`ReorderStreamsType`): Function to reorder streams based on active session state.
///
/// ### Returns:
///
/// A `Future<void>` that completes once the function operations are done.
///
/// ### Throws:
///
/// This function does not throw directly but logs errors in debug mode if any occur during execution.
///
/// ### Example:
///
/// ```dart
/// final options = CloseAndResizeOptions(
///   producerId: 'producer-123',
///   kind: 'video',
///   parameters: CloseAndResizeParametersMock(
///     allAudioStreams: [],
///     allVideoStreams: [],
///     activeNames: [],
///     participants: [Participant(id: 'user1', name: 'User 1')],
///     lockScreen: false,
///     updateAllVideoStreams: (videoStreams) => print('Updated video streams'),
///     updateMainHeightWidth: (heightWidth) => print('Updated main height width: $heightWidth'),
///     reorderStreams: (options) async => print('Reordered streams'),
///     prepopulateUserMedia: (options) async => print('Prepopulated user media'),
///     rePort: (options) async => print('Reported changes'),
///   ),
/// );
///
/// await closeAndResize(options);
/// ```

Future<void> closeAndResize(CloseAndResizeOptions options) async {
  var parameters = options.parameters.getUpdatedAllParams();

  // Extract parameters
  List<Stream> allAudioStreams = parameters.allAudioStreams;
  List<Stream> allVideoStreams = parameters.allVideoStreams;
  List<String> activeNames = parameters.activeNames;
  List<Participant> participants = parameters.participants;
  List<Stream> streamNames = parameters.streamNames;
  String recordingDisplayType = parameters.recordingDisplayType;
  bool recordingVideoOptimized = parameters.recordingVideoOptimized;
  String? adminIDStream = parameters.adminIDStream;
  List<Stream> newLimitedStreams = parameters.newLimitedStreams;
  List<String> newLimitedStreamsIDs = parameters.newLimitedStreamsIDs;
  List<Stream> oldAllStreams = parameters.oldAllStreams;
  bool shareScreenStarted = parameters.shareScreenStarted;
  bool shared = parameters.shared;
  String meetingDisplayType = parameters.meetingDisplayType;
  bool deferReceive = parameters.deferReceive;
  bool lockScreen = parameters.lockScreen;
  bool firstAll = parameters.firstAll;
  bool firstRound = parameters.firstRound;
  bool gotAllVids = parameters.gotAllVids;
  EventType eventType = parameters.eventType;
  String hostLabel = parameters.hostLabel;
  bool shareEnded = parameters.shareEnded;
  bool updateMainWindow = parameters.updateMainWindow;

  // Update functions
  var updateActiveNames = parameters.updateActiveNames;
  var updateAllVideoStreams = parameters.updateAllVideoStreams;
  var updateAllAudioStreams = parameters.updateAllAudioStreams;
  var updateShareScreenStarted = parameters.updateShareScreenStarted;
  var updateUpdateMainWindow = parameters.updateUpdateMainWindow;
  var updateNewLimitedStreams = parameters.updateNewLimitedStreams;
  var updateOldAllStreams = parameters.updateOldAllStreams;
  var updateDeferReceive = parameters.updateDeferReceive;
  var updateMainHeightWidth = parameters.updateMainHeightWidth;
  var updateShareEnded = parameters.updateShareEnded;
  var updateLockScreen = parameters.updateLockScreen;
  var updateFirstAll = parameters.updateFirstAll;
  var updateFirstRound = parameters.updateFirstRound;

  // Mediasfu functions
  var reorderStreams = parameters.reorderStreams;
  var prepopulateUserMedia = parameters.prepopulateUserMedia;
  var getVideos = parameters.getVideos;
  var rePort = parameters.rePort;

  try {
    Participant? participant;

    if (options.kind == 'audio') {
      // Stop the audio by removing the miniAudio with id = producerId
      allAudioStreams = allAudioStreams
          .where((audioStream) => audioStream.producerId != options.producerId)
          .toList();
      updateAllAudioStreams(allAudioStreams);

      if (recordingDisplayType == 'video' && recordingVideoOptimized) {
        // Handle optimized recording case
      } else {
        participant = participants.firstWhere(
          (obj) => obj.audioID == options.producerId,
        );

        if (participant.name.isNotEmpty) {
          if (participant.videoID.isEmpty || participant.videoID == "") {
            activeNames.removeWhere((name) => name == participant!.name);
            updateActiveNames(activeNames);
          }
        }
      }

      var checker = meetingDisplayType == 'video'
          ? participant != null &&
              participant.videoID.isNotEmpty &&
              participant.videoID != ""
          : true;

      if (checker) {
        if (shareScreenStarted || shared) {
          if (meetingDisplayType != 'video' ||
              (participant != null && participant.videoID.isNotEmpty)) {
            final optionsReorder = ReorderStreamsOptions(
              add: false,
              screenChanged: true,
              parameters: parameters,
            );
            await reorderStreams(optionsReorder);
          }
        } else {
          if (meetingDisplayType != 'video') {
            final optionsReorder = ReorderStreamsOptions(
              add: false,
              screenChanged: true,
              parameters: parameters,
            );
            await reorderStreams(
              optionsReorder,
            );
          }
        }
      }
    } else if (options.kind == 'video') {
      if (options.producerId == adminIDStream) {
        updateMainWindow = true;
        updateUpdateMainWindow(updateMainWindow);
      }

      allVideoStreams = allVideoStreams
          .where((videoStream) => videoStream.producerId != options.producerId)
          .toList();
      updateAllVideoStreams(allVideoStreams);

      oldAllStreams = oldAllStreams
          .where((videoStream) => videoStream.producerId != options.producerId)
          .toList();
      updateOldAllStreams(oldAllStreams);

      newLimitedStreams = newLimitedStreams
          .where((videoStream) => videoStream.producerId != options.producerId)
          .toList();
      updateNewLimitedStreams(newLimitedStreams);

      activeNames.removeWhere((name) {
        var participant = streamNames.firstWhere(
            (obj) => obj.producerId == options.producerId,
            orElse: () => Stream(producerId: '', name: ''));
        return name == participant.name;
      });
      updateActiveNames(activeNames);

      if (lockScreen) {
        deferReceive = true;
        if (newLimitedStreamsIDs.contains(options.producerId)) {
          final optionsPrepopulate = PrepopulateUserMediaOptions(
            name: hostLabel,
            parameters: parameters,
          );
          prepopulateUserMedia(optionsPrepopulate);
          final optionsReorder = ReorderStreamsOptions(
            add: false,
            screenChanged: true,
            parameters: parameters,
          );
          await reorderStreams(
            optionsReorder,
          );
        }
      } else {
        final optionsPrepopulate = PrepopulateUserMediaOptions(
          name: hostLabel,
          parameters: parameters,
        );
        prepopulateUserMedia(optionsPrepopulate);
        final optionsReorder = ReorderStreamsOptions(
          add: false,
          screenChanged: true,
          parameters: parameters,
        );
        await reorderStreams(
          optionsReorder,
        );
      }
    } else if (options.kind == 'screenshare' || options.kind == 'screen') {
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

      if (!gotAllVids || deferReceive) {
        deferReceive = false;
        updateDeferReceive(deferReceive);
        final optionsGetVideos = GetVideosOptions(
          participants: participants,
          allVideoStreams: allVideoStreams,
          oldAllStreams: oldAllStreams,
          updateAllVideoStreams: updateAllVideoStreams,
          updateOldAllStreams: updateOldAllStreams,
        );
        await getVideos(options: optionsGetVideos);
        final optionsRePort = RePortOptions(
          parameters: parameters,
        );
        await rePort(optionsRePort);
      }

      if (eventType == EventType.conference) {
        updateMainHeightWidth(0);
      }

      final optionsPrepopulate = PrepopulateUserMediaOptions(
        name: hostLabel,
        parameters: parameters,
      );
      prepopulateUserMedia(optionsPrepopulate);

      final optionsReorder = ReorderStreamsOptions(
        add: false,
        screenChanged: true,
        parameters: parameters,
      );
      await reorderStreams(
        optionsReorder,
      );
    }
  } catch (error) {
    if (kDebugMode) {
      print('closeAndResize error: $error');
    }
  }
}
