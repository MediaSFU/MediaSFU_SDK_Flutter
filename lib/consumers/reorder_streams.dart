// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'package:flutter/foundation.dart'; // Import async for Future

/// Reorders the streams based on the given parameters.
///
/// The [reorderStreams] function is responsible for reordering the video streams
/// based on the provided parameters. It takes in several optional named parameters:
/// - [add]: A boolean value indicating whether to add new streams or not. Default is `false`.
/// - [screenChanged]: A boolean value indicating whether the screen has changed or not. Default is `false`.
/// - [parameters]: A map containing the required parameters for reordering the streams.
///
/// The [parameters] map should contain the following keys:
/// - 'allVideoStreams': A list of all video streams.
/// - 'participants': A list of participants.
/// - 'oldAllStreams': A list of old streams.
/// - 'screenId': The ID of the screen.
/// - 'adminVidID': The ID of the admin video.
/// - 'updateNewLimitedStreams': A function to update the new limited streams.
/// - 'updateNewLimitedStreamsIDs': A function to update the new limited stream IDs.
/// - 'updateActiveSounds': A function to update the active sounds.
/// - 'updateScreenShareIDStream': A function to update the screen share ID stream.
/// - 'updateScreenShareNameStream': A function to update the screen share name stream.
/// - 'updateAdminIDStream': A function to update the admin ID stream.
/// - 'updateAdminNameStream': A function to update the admin name stream.
/// - 'updateYouYouStream': A function to update the youyou stream.
/// - 'changeVids': A function to change the videos.
///
/// The function first destructures the parameters and initializes some variables.
/// It then checks if the admin video ID is empty or not. If it's not empty, it adds
/// the admin stream to the new limited streams. It also adds the youyou stream and
/// the screen share stream if applicable. If the admin video ID is empty, it only
/// adds the youyou stream and the screen share stream if applicable.
///
/// Finally, it updates the necessary states and reflects the changes on the UI.
/// Any errors that occur during the process are caught and handled.
///
/// Example usage:
/// ```dart
/// reorderStreams(parameters: {
///   'allVideoStreams': allVideoStreams,
///   'participants': participants,
///   'oldAllStreams': oldAllStreams,
///   'screenId': screenId,
///   'adminVidID': adminVidID,
///   'updateNewLimitedStreams': updateNewLimitedStreams,
///   'updateNewLimitedStreamsIDs': updateNewLimitedStreamsIDs,
///   'updateActiveSounds': updateActiveSounds,
///   'updateScreenShareIDStream': updateScreenShareIDStream,
///   'updateScreenShareNameStream': updateScreenShareNameStream,
///   'updateAdminIDStream': updateAdminIDStream,
///   'updateAdminNameStream': updateAdminNameStream,
///   'updateYouYouStream': updateYouYouStream,
///   'changeVids': changeVids,
/// });
/// ```
///
/// Note: This code is ignoring the `non_constant_identifier_names` lint.
/// This is done intentionally to avoid renaming the typedefs.

typedef ChangeVids = Future<void> Function({
  bool screenChanged,
  required Map<String, dynamic> parameters,
});

typedef UpdateNewLimitedStreams = void Function(List<dynamic> value);
typedef UpdateNewLimitedStreamsIDs = void Function(List<String> value);
typedef UpdateActiveSounds = void Function(List<String> value);
typedef UpdateScreenShareIDStream = void Function(String value);
typedef UpdateScreenShareNameStream = void Function(String value);
typedef UpdateAdminIDStream = void Function(String value);
typedef UpdateAdminNameStream = void Function(String value);
typedef UpdateYouYouStream = void Function(dynamic value);
typedef UpdateAdminVidID = void Function(String value);

Future<void> reorderStreams(
    {bool add = false,
    bool screenChanged = false,
    required Map<String, dynamic> parameters}) async {
  try {
    // Destructure parameters
    List<dynamic> allVideoStreams = parameters['allVideoStreams'] ?? [];
    List<dynamic> participants = parameters['participants'] ?? [];
    List<dynamic> oldAllStreams = parameters['oldAllStreams'] ?? [];
    String screenId = parameters['screenId'] ?? "";
    String adminVidID = parameters['adminVidID'] ?? "";
    UpdateNewLimitedStreams updateNewLimitedStreams =
        parameters['updateNewLimitedStreams'] ?? (value) {};
    UpdateNewLimitedStreamsIDs updateNewLimitedStreamsIDs =
        parameters['updateNewLimitedStreamsIDs'] ?? (value) {};
    UpdateActiveSounds updateActiveSounds = parameters['updateActiveSounds'];
    UpdateScreenShareIDStream updateScreenShareIDStream =
        parameters['updateScreenShareIDStream'];
    UpdateScreenShareNameStream updateScreenShareNameStream =
        parameters['updateScreenShareNameStream'];
    UpdateAdminIDStream updateAdminIDStream = parameters['updateAdminIDStream'];
    UpdateAdminNameStream updateAdminNameStream =
        parameters['updateAdminNameStream'];
    UpdateYouYouStream updateYouYouStream = parameters['updateYouYouStream'];

    // mediasfu functions
    ChangeVids changeVids = parameters['changeVids'];

    // function to reorder streams on the ui
    var newLimitedStreams = [];
    List<String> newLimitedStreamsIDs = [];
    List<String> activeSounds = [];

    if (!add) {
      newLimitedStreams = [];
      newLimitedStreamsIDs = [];
      activeSounds = []; // get actives back in
    }

    var youyou = allVideoStreams
        .where((stream) => stream['producerId'] == 'youyou')
        .toList();
    var admin = participants
        .where((participant) => participant['islevel'] == '2')
        .toList();

    if (admin.isNotEmpty) {
      adminVidID = admin[0]?['videoID'] ?? "";
    } else {
      adminVidID = "";
    }

    if (!(adminVidID == "")) {
      var adminStream = allVideoStreams.firstWhere(
          (stream) => stream['producerId'] == adminVidID,
          orElse: () => null);

      if (!add) {
        newLimitedStreams.addAll(youyou);
        newLimitedStreamsIDs
            .addAll(youyou.map((stream) => stream['producerId']));
      } else {
        var youyouStream = newLimitedStreams.firstWhere(
            (stream) => stream['producerId'] == 'youyou',
            orElse: () => null);
        if (youyouStream == null) {
          newLimitedStreams.addAll(youyou);
          newLimitedStreamsIDs
              .addAll(youyou.map((stream) => stream['producerId']));
        }
      }

      if (adminStream != null) {
        updateAdminIDStream(adminVidID);
        if (!add) {
          newLimitedStreams.add(adminStream);
          newLimitedStreamsIDs.add(adminStream['producerId']);
        } else {
          var adminStreamer = newLimitedStreams.firstWhere(
              (stream) => stream['producerId'] == adminVidID,
              orElse: () => null);
          if (adminStreamer == null) {
            newLimitedStreams.add(adminStream);
            newLimitedStreamsIDs.add(adminStream['producerId']);
          }
        }
      }

      var oldAdminStream = oldAllStreams.firstWhere(
          (stream) => stream['producerId'] == adminVidID,
          orElse: () => null);

      if (oldAdminStream != null) {
        updateAdminIDStream(adminVidID);
        updateAdminNameStream(admin[0]?['name'] ?? "");
        if (!add) {
          newLimitedStreams.add(oldAdminStream);
          newLimitedStreamsIDs.add(oldAdminStream['producerId']);
        } else {
          var adminStreamer = newLimitedStreams.firstWhere(
              (stream) => stream['producerId'] == adminVidID,
              orElse: () => null);
          if (adminStreamer == null) {
            newLimitedStreams.add(oldAdminStream);
            newLimitedStreamsIDs.add(oldAdminStream['producerId']);
          }
        }
      }

      var screenParticipant = participants
          .where((participant) => participant['ScreenID'] == screenId)
          .toList();

      if (screenParticipant.isNotEmpty) {
        var screenParticipantVidID = screenParticipant[0]['videoID'];
        var screenParticipantVidID_ = newLimitedStreams
            .where((stream) => stream['producerId'] == screenParticipantVidID)
            .toList();
        if (screenParticipantVidID_.isEmpty && screenParticipantVidID != null) {
          updateScreenShareIDStream(screenParticipantVidID);
          updateScreenShareNameStream(screenParticipant[0]['name']);
          var screenParticipantVidID__ = allVideoStreams
              .where((stream) => stream['producerId'] == screenParticipantVidID)
              .toList();
          newLimitedStreams.addAll(screenParticipantVidID__);
          newLimitedStreamsIDs.addAll(
              screenParticipantVidID__.map((stream) => stream['producerId']));
        }
      }
    } else {
      if (!add) {
        newLimitedStreams.addAll(youyou);
        newLimitedStreamsIDs
            .addAll(youyou.map((stream) => stream['producerId']));
      } else {
        var youyouStream = newLimitedStreams.firstWhere(
            (stream) => stream['producerId'] == 'youyou',
            orElse: () => null);
        if (youyouStream == null) {
          newLimitedStreams.addAll(youyou);
          newLimitedStreamsIDs
              .addAll(youyou.map((stream) => stream['producerId']));
        }
      }

      var screenParticipant = participants
          .where((participant) => participant['ScreenID'] == screenId)
          .toList();

      if (screenParticipant.isNotEmpty) {
        var screenParticipantVidID = screenParticipant[0]['videoID'];
        var screenParticipantVidID_ = newLimitedStreams
            .where((stream) => stream['producerId'] == screenParticipantVidID)
            .toList();
        if (screenParticipantVidID_.isEmpty && screenParticipantVidID != null) {
          updateScreenShareIDStream(screenParticipantVidID);
          updateScreenShareNameStream(screenParticipant[0]['name']);
          var screenParticipantVidID__ = allVideoStreams
              .where((stream) => stream['producerId'] == screenParticipantVidID)
              .toList();
          newLimitedStreams.addAll(screenParticipantVidID__);
          newLimitedStreamsIDs.addAll(
              screenParticipantVidID__.map((stream) => stream['producerId']));
        }
      }
    }

    // Update all the states
    updateNewLimitedStreams(newLimitedStreams);
    updateNewLimitedStreamsIDs(newLimitedStreamsIDs);
    updateActiveSounds(activeSounds);
    updateYouYouStream(youyou);

    // Reflect the changes on the UI
    await changeVids(screenChanged: screenChanged, parameters: parameters);
  } catch (error) {
    // Handle errors
    if (kDebugMode) {
      print('Error during reordering streams: $error');
    }
  }
}
