import 'dart:async';
import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show
        Stream,
        Participant,
        OnScreenChangesType,
        ReorderStreamsType,
        ChangeVidsType,
        OnScreenChangesParameters,
        ReorderStreamsParameters,
        ChangeVidsParameters,
        EventType,
        ReorderStreamsOptions,
        ChangeVidsOptions,
        OnScreenChangesOptions;

abstract class ReUpdateInterParameters
    implements
        OnScreenChangesParameters,
        ReorderStreamsParameters,
        ChangeVidsParameters {
  // Basic properties as abstract getters
  int get screenPageLimit;
  int get itemPageLimit;
  int get reorderInterval;
  int get fastReorderInterval;
  EventType get eventType;
  List<Participant> get participants;
  List<Stream> get allVideoStreams; // Use Stream for (Participant | Stream)
  bool get shared;
  bool get shareScreenStarted;
  String get adminNameStream;
  String get screenShareNameStream;
  bool get updateMainWindow;
  bool get sortAudioLoudness;
  int get lastReorderTime;
  List<Stream> get newLimitedStreams;
  List<String> get newLimitedStreamsIDs;
  List<String> get oldSoundIds;

  // Update functions as abstract getters
  void Function(bool) get updateUpdateMainWindow;
  void Function(bool) get updateSortAudioLoudness;
  void Function(int) get updateLastReorderTime;
  void Function(List<Stream>) get updateNewLimitedStreams;
  void Function(List<String>) get updateNewLimitedStreamsIDs;
  void Function(List<String>) get updateOldSoundIds;

  // Mediasfu functions as abstract getters
  OnScreenChangesType get onScreenChanges;
  ReorderStreamsType get reorderStreams;
  ChangeVidsType get changeVids;

  // Getter for updated parameters as a method
  ReUpdateInterParameters Function() get getUpdatedAllParams;

  // Dynamic access operator
  // dynamic operator [](String key);
}

class ReUpdateInterOptions {
  final String name;
  final bool add;
  final bool force;
  final double average;
  final ReUpdateInterParameters parameters;

  ReUpdateInterOptions({
    required this.name,
    this.add = false,
    this.force = false,
    this.average = 127.0,
    required this.parameters,
  });
}

// Function type definition
typedef ReUpdateInterType = Future<void> Function(ReUpdateInterOptions options);

/// Updates the layout or content of the media streams based on user activity, screen share, or conference settings.
///
/// This function reorganizes or adds video streams to the screen layout. It Streamally adjusts stream visibility
/// and layout based on screen sharing, conference activity, and audio loudness changes. If a user is actively
/// sharing or speaking loudly, the function may promote their stream to a prominent position based on defined intervals.
///
/// Parameters:
/// - [options] (`ReUpdateInterOptions`): Options for updating the stream layout. Includes:
///   - [name]: Name of the participant whose stream might be updated.
///   - [add]: Determines if a stream should be added to the layout.
///   - [force]: Forces the removal of a stream if true.
///   - [average]: Audio loudness average for determining active speakers.
///   - [parameters]: Parameters containing configuration settings for updating streams.
///
/// Example:
/// ```dart
/// final parameters = ReUpdateInterParameters(
///   screenPageLimit: 6,
///   itemPageLimit: 3,
///   reorderInterval: 10000,
///   fastReorderInterval: 5000,
///   eventType: EventType.conference,
///   participants: [participant1, participant2],
///   allVideoStreams: [stream1, stream2],
///   shared: false,
///   shareScreenStarted: false,
///   updateMainWindow: false,
///   sortAudioLoudness: false,
///   lastReorderTime: DateTime.now().millisecondsSinceEpoch,
///   newLimitedStreams: [],
///   newLimitedStreamsIDs: [],
///   oldSoundIds: [],
///   updateUpdateMainWindow: (value) => print('Update main window: $value'),
///   updateSortAudioLoudness: (value) => print('Sort audio loudness: $value'),
///   updateLastReorderTime: (value) => print('Last reorder time updated: $value'),
///   updateNewLimitedStreams: (streams) => print('Updated new limited streams'),
///   updateNewLimitedStreamsIDs: (ids) => print('Updated limited stream IDs'),
///   updateOldSoundIds: (ids) => print('Updated old sound IDs'),
///   onScreenChanges: (options) async => print('On screen changes called'),
///   reorderStreams: (options) async => print('Reorder streams called'),
///   changeVids: (options) async => print('Change vids called'),
///   getUpdatedAllParams: () => parameters,
/// );
///
/// final options = ReUpdateInterOptions(
///   name: "JohnDoe",
///   add: true,
///   average: 129.0,
///   parameters: parameters,
/// );
///
/// await reUpdateInter(options);
/// ```

Future<void> reUpdateInter(ReUpdateInterOptions options) async {
  // Destructure options
  final name = options.name;
  final add = options.add;
  final force = options.force;
  final average = options.average;
  final parameters = options.parameters;

  try {
    int screenPageLimit = parameters.screenPageLimit;
    int itemPageLimit = parameters.itemPageLimit;
    int reorderInterval = parameters.reorderInterval;
    int fastReorderInterval = parameters.fastReorderInterval;
    EventType eventType = parameters.eventType;
    List<Participant> participants = parameters.participants;
    List<Stream> allVideoStreams = parameters.allVideoStreams;
    bool shared = parameters.shared;
    bool shareScreenStarted = parameters.shareScreenStarted;
    String adminNameStream = parameters.adminNameStream;
    String screenShareNameStream = parameters.screenShareNameStream;
    bool updateMainWindow = parameters.updateMainWindow;
    bool sortAudioLoudness = parameters.sortAudioLoudness;
    int lastReorderTime = parameters.lastReorderTime;
    List<Stream> newLimitedStreams = parameters.newLimitedStreams;
    List<String> newLimitedStreamsIDs = parameters.newLimitedStreamsIDs;
    List<String> oldSoundIds = parameters.oldSoundIds;
    void Function(bool) updateUpdateMainWindow =
        parameters.updateUpdateMainWindow;
    void Function(bool) updateSortAudioLoudness =
        parameters.updateSortAudioLoudness;
    void Function(int) updateLastReorderTime = parameters.updateLastReorderTime;
    void Function(List<Stream>) updateNewLimitedStreams =
        parameters.updateNewLimitedStreams;
    void Function(List<String>) updateNewLimitedStreamsIDs =
        parameters.updateNewLimitedStreamsIDs;
    void Function(List<String>) updateOldSoundIds =
        parameters.updateOldSoundIds;

    // mediasfu functions
    OnScreenChangesType onScreenChanges = parameters.onScreenChanges;
    ReorderStreamsType reorderStreams = parameters.reorderStreams;
    ChangeVidsType changeVids = parameters.changeVids;

    int refLimit = screenPageLimit - 1;

    if (eventType == EventType.broadcast || eventType == EventType.chat) {
      return;
    }

    if (shareScreenStarted || shared) {
      // Implementation for shareScreenStarted or shared scenario
    } else {
      refLimit = itemPageLimit - 1;

      if (add) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        if (((currentTime - lastReorderTime >= reorderInterval) &&
                (average > 128.5)) ||
            (average > 130 &&
                currentTime - lastReorderTime >= fastReorderInterval)) {
          lastReorderTime = currentTime;
          sortAudioLoudness = true;
          if (eventType == EventType.conference) {
            final optionsOnScreenChanges = OnScreenChangesOptions(
              changed: true,
              parameters: parameters,
            );
            await onScreenChanges(optionsOnScreenChanges);
          } else {
            final optionsReorderStreams = ReorderStreamsOptions(
              add: false,
              screenChanged: true,
              parameters: parameters,
            );
            await reorderStreams(
              optionsReorderStreams,
            );
          }
          sortAudioLoudness = false;

          updateSortAudioLoudness(sortAudioLoudness);
          updateUpdateMainWindow(updateMainWindow);
          updateLastReorderTime(lastReorderTime);

          return;
        }
      }
    }

    String? videoID;
    if (shareScreenStarted || shared) {
      if (add) {
        Participant? participant = participants.firstWhere(
            (p) => p.name == name,
            orElse: () => Participant(name: "", videoID: "", audioID: ""));

        videoID = participant.videoID;
        if (videoID.isEmpty || videoID == "") {
          return;
        }

        if (!newLimitedStreamsIDs.contains(videoID)) {
          if (newLimitedStreams.length > refLimit) {
            List<String> oldSoundsCopy = List<String>.from(oldSoundIds);
            for (var oldSoundId in oldSoundIds) {
              if (newLimitedStreams.length > refLimit) {
                if (newLimitedStreams.length < screenPageLimit) {
                  return;
                }
                if (oldSoundId != screenShareNameStream &&
                    oldSoundId != adminNameStream) {
                  newLimitedStreams
                      .removeWhere((stream) => stream.producerId == oldSoundId);
                  newLimitedStreamsIDs.removeWhere((id) => id == oldSoundId);
                  oldSoundsCopy.removeWhere((id) => id == oldSoundId);
                }
              }
            }
            oldSoundIds = List<String>.from(oldSoundsCopy);
          }

          var stream = allVideoStreams.firstWhere(
              (stream) => stream.producerId == videoID,
              orElse: () => Stream(producerId: "", name: "none"));
          if (stream.name != 'none' &&
              newLimitedStreams.length < screenPageLimit) {
            newLimitedStreams.add(stream);
            newLimitedStreamsIDs.add(videoID);
            if (!oldSoundIds.contains(name)) {
              oldSoundIds.add(name);
            }
            final optionsChangeVids = ChangeVidsOptions(
              parameters: parameters,
            );
            await changeVids(optionsChangeVids);
          }
        }
      } else {
        Participant? participant = participants.firstWhere(
            (p) => p.name == name,
            orElse: () => Participant(name: "", videoID: "", audioID: ""));

        videoID = participant.videoID;
        if (videoID == "" || videoID.isEmpty) {
          return;
        }

        if (!force) {
          try {
            newLimitedStreams
                .removeWhere((stream) => stream.producerId == videoID);
            newLimitedStreamsIDs.removeWhere((id) => id == videoID);
            oldSoundIds.removeWhere((id) => id == name);
            final optionsChangeVids = ChangeVidsOptions(
              parameters: parameters,
            );
            await changeVids(optionsChangeVids);
          } catch (_) {}
        } else {
          var mic = participant.muted;
          if (mic != null && mic) {
            try {
              newLimitedStreams
                  .removeWhere((stream) => stream.producerId == videoID);
              newLimitedStreamsIDs.removeWhere((id) => id == videoID);
              oldSoundIds.removeWhere((id) => id == name);
              final optionsChangeVids = ChangeVidsOptions(
                parameters: parameters,
              );
              await changeVids(optionsChangeVids);
            } catch (_) {}
          }
        }
      }

      updateNewLimitedStreams(newLimitedStreams);
      updateNewLimitedStreamsIDs(newLimitedStreamsIDs);
      updateOldSoundIds(oldSoundIds);
    }
  } catch (_) {
    if (kDebugMode) {
      // print('Error updating UI for active media streams: $error');
    }
    // Handle errors if necessary
  }
}
