// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Updates the UI for active media streams based on the provided parameters.
///
/// The [name] parameter is required and represents the name of the stream.
/// The [add] parameter indicates whether a new stream is being added.
/// The [force] parameter indicates whether the update should be forced.
/// The [average] parameter represents the average value.
/// The [parameters] parameter is a map that contains various parameters for the update.
///
/// This function performs various operations based on the provided parameters,
/// such as reordering streams, changing videos, and updating the main window.
/// It also handles scenarios related to screen sharing and shared streams.
///
/// The function returns a [Future] that completes when the update is finished.

typedef OnScreenChanges = Future<void> Function(
    {bool changed, required Map<String, dynamic> parameters});
typedef ReorderStreams = Future<void> Function({
  bool add,
  bool screenChanged,
  required Map<String, dynamic> parameters,
});

typedef ChangeVids = Future<void> Function(
    {bool screenChanged, required Map<String, dynamic> parameters});

typedef UpdateUpdateMainWindowFunction = void Function(bool);
typedef UpdateSortAudioLoudnessFunction = void Function(bool);
typedef UpdateLastReOrderTimeFunction = void Function(int);
typedef UpdateNewLimitedStreamsFunction = void Function(List<dynamic>);
typedef UpdateNewLimitedStreamsIDsFunction = void Function(List<String>);
typedef UpdateOldSoundIdsFunction = void Function(List<String>);

Future<void> reUpdateInter(
    {required String name,
    bool add = false,
    bool force = false,
    double average = 127.0,
    required Map<String, dynamic> parameters}) async {
  try {
    int screenPageLimit = parameters['screenPageLimit'];
    int itemPageLimit = parameters['itemPageLimit'];
    int reOrderInterval = parameters['reOrderInterval'];
    int fastReOrderInterval = parameters['fastReOrderInterval'];
    String eventType = parameters['eventType'];
    List<dynamic> participants = parameters['participants'];
    List<dynamic> allVideoStreams = parameters['allVideoStreams'];
    bool shared = parameters['shared'] ?? false;
    bool shareScreenStarted = parameters['shareScreenStarted'];
    String adminNameStream = parameters['adminNameStream'];
    String screenShareNameStream = parameters['screenShareNameStream'];
    bool updateMainWindow = parameters['updateMainWindow'];
    bool sortAudioLoudness = parameters['sortAudioLoudness'] ?? false;
    int lastReOrderTime = parameters['lastReOrderTime'] ?? 0;
    List<dynamic> newLimitedStreams = parameters['newLimitedStreams'];
    List<String> newLimitedStreamsIDs = parameters['newLimitedStreamsIDs'];
    List<String> oldSoundIds = parameters['oldSoundIds'];
    UpdateUpdateMainWindowFunction updateUpdateMainWindow =
        parameters['updateUpdateMainWindow'];
    UpdateSortAudioLoudnessFunction updateSortAudioLoudness =
        parameters['updateSortAudioLoudness'];
    UpdateLastReOrderTimeFunction updateLastReOrderTime =
        parameters['updateLastReOrderTime'];
    UpdateNewLimitedStreamsFunction updateNewLimitedStreams =
        parameters['updateNewLimitedStreams'];
    UpdateNewLimitedStreamsIDsFunction updateNewLimitedStreamsIDs =
        parameters['updateNewLimitedStreamsIDs'];
    UpdateOldSoundIdsFunction updateOldSoundIds =
        parameters['updateOldSoundIds'];

    // mediasfu functions
    OnScreenChanges onScreenChanges = parameters['onScreenChanges'];
    ReorderStreams reorderStreams = parameters['reorderStreams'];
    ChangeVids changeVids = parameters['changeVids'];

    int refLimit = screenPageLimit - 1;

    if (eventType == 'broadcast' || eventType == 'chat') {
      return;
    }

    if (shareScreenStarted || shared) {
      // Implementation for shareScreenStarted or shared scenario
    } else {
      refLimit = itemPageLimit - 1;

      if (add) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        if (((currentTime - lastReOrderTime >= reOrderInterval) &&
                (average > 128.5)) ||
            (average > 130 &&
                currentTime - lastReOrderTime >= fastReOrderInterval)) {
          lastReOrderTime = currentTime;
          sortAudioLoudness = true;
          if (eventType == 'conference') {
            await onScreenChanges(changed: true, parameters: parameters);
          } else {
            await reorderStreams(
                add: false, screenChanged: true, parameters: parameters);
          }
          sortAudioLoudness = false;

          updateSortAudioLoudness(sortAudioLoudness);
          updateUpdateMainWindow(updateMainWindow);
          updateLastReOrderTime(lastReOrderTime);

          return;
        }
      }
    }

    String videoID;
    if (shareScreenStarted || shared) {
      if (add) {
        var participant = participants.firstWhere((p) => p['name'] == name,
            orElse: () => null);

        videoID = participant != null ? participant['videoID'] : null;
        if (videoID == "") {
          return;
        }

        if (!newLimitedStreamsIDs.contains(videoID)) {
          if (newLimitedStreams.length > refLimit) {
            var oldoldSounds = List<String>.from(oldSoundIds);
            for (int i = 0; i < oldSoundIds.length; i++) {
              if (newLimitedStreams.length > refLimit) {
                if (newLimitedStreams.length < screenPageLimit) {
                  return;
                }
                if (oldSoundIds[i] != screenShareNameStream ||
                    oldSoundIds[i] != adminNameStream) {
                  newLimitedStreams.removeWhere(
                      (stream) => stream['producerId'] == oldSoundIds[i]);
                  newLimitedStreamsIDs
                      .removeWhere((id) => id == oldSoundIds[i]);
                  oldoldSounds.removeWhere((id) => id == oldSoundIds[i]);
                }
              }
            }
            oldSoundIds = List<String>.from(oldoldSounds);
          }

          var stream = allVideoStreams.firstWhere(
              (stream) => stream['producerId'] == videoID,
              orElse: () => null);
          if (stream != null && newLimitedStreams.length < screenPageLimit) {
            newLimitedStreams.add(stream);
            newLimitedStreamsIDs.add(videoID);
            if (!oldSoundIds.contains(name)) {
              oldSoundIds.add(name);
            }
            await changeVids(parameters: parameters);
          }
        }
      } else {
        var participant = participants.firstWhere((p) => p['name'] == name,
            orElse: () => null);

        videoID = participant != null ? participant['videoID'] : null;
        if (videoID == "") {
          return;
        }

        if (!force) {
          try {
            newLimitedStreams
                .removeWhere((stream) => stream['producerId'] == videoID);
            newLimitedStreamsIDs.removeWhere((id) => id == videoID);
            oldSoundIds.removeWhere((id) => id == name);
            await changeVids(parameters: parameters);
          } catch (error) {}
        } else {
          var mic = participant != null ? participant['muted'] : null;
          if (mic != null && mic) {
            try {
              newLimitedStreams
                  .removeWhere((stream) => stream['producerId'] == videoID);
              newLimitedStreamsIDs.removeWhere((id) => id == videoID);
              oldSoundIds.removeWhere((id) => id == name);
              await changeVids(parameters: parameters);
            } catch (error) {}
          }
        }
      }

      updateNewLimitedStreams(newLimitedStreams);
      updateNewLimitedStreamsIDs(newLimitedStreamsIDs);
      updateOldSoundIds(oldSoundIds);
    }
  } catch (error) {
    if (kDebugMode) {
      // print('Error updating UI for active media streams: $error');
    }
    // Handle errors if necessary
  }
}
