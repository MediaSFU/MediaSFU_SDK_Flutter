// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show
        Participant,
        ChangeVidsParameters,
        ChangeVidsType,
        ChangeVidsOptions,
        Stream;

abstract class ReorderStreamsParameters implements ChangeVidsParameters {
  List<Stream> get allVideoStreams;
  List<Participant> get participants;
  List<Stream> get oldAllStreams;
  String get screenId;
  String get adminVidID;
  List<Stream> get newLimitedStreams;
  List<String> get newLimitedStreamsIDs;
  List<String> get activeSounds;
  String get screenShareIDStream;
  String get screenShareNameStream;
  String get adminIDStream;
  String get adminNameStream;

  // Update functions as abstract getters
  void Function(List<String> ids) get updateNewLimitedStreamsIDs;
  void Function(List<String> sounds) get updateActiveSounds;
  void Function(String id) get updateScreenShareIDStream;
  void Function(String name) get updateScreenShareNameStream;
  void Function(String id) get updateAdminIDStream;
  void Function(String name) get updateAdminNameStream;
  void Function(List<Stream> streams) get updateYouYouStream;

  // Mediasfu function as a getter
  ChangeVidsType get changeVids;

  // Method for getting updated parameters
  ReorderStreamsParameters Function() get getUpdatedAllParams;

  // Dynamic access operator for additional properties
  // dynamic operator [](String key);
}

class ReorderStreamsOptions {
  final bool add;
  final bool screenChanged;
  final ReorderStreamsParameters parameters;

  ReorderStreamsOptions({
    this.add = false,
    this.screenChanged = false,
    required this.parameters,
  });
}

typedef ReorderStreamsType = Future<void> Function(
    ReorderStreamsOptions options);

/// Reorders video streams in the participant grid based on user roles and screen share status.
///
/// This function updates the order of video streams, ensuring that the user's own stream, the admin's stream, and any shared screen are appropriately prioritized.
/// It checks for changes in the screen sharing status and admin status and adds these streams to the limited stream list.
///
/// If `add` is true, it will add new streams to the limited streams list; otherwise, it will reset the list. It also updates various states like active sounds,
/// screen share information, and admin information.
///
/// Parameters:
/// - [options] (`ReorderStreamsOptions`): Options for the reorder function, including whether to add streams or reflect screen changes.
///
/// Example:
/// ```dart
/// final reorderOptions = ReorderStreamsOptions(
///   add: true,
///   screenChanged: true,
///   parameters: ReorderStreamsParameters(
///     allVideoStreams: [/* video streams list */],
///     participants: [/* participants list */],
///     oldAllStreams: [/* old streams list */],
///     screenId: 'screen123',
///     adminVidID: 'admin123',
///     newLimitedStreams: [],
///     newLimitedStreamsIDs: [],
///     activeSounds: [],
///     screenShareIDStream: '',
///     screenShareNameStream: '',
///     adminIDStream: '',
///     adminNameStream: '',
///     changeVids: (ChangeVidsOptions options) async => /* function logic */,
///     getUpdatedAllParams: () => /* function to get updated parameters */,
///   ),
/// );
///
/// await reorderStreams(reorderOptions);
/// ```

Future<void> reorderStreams(
  ReorderStreamsOptions options,
) async {
  ReorderStreamsParameters parameters =
      options.parameters.getUpdatedAllParams();
  final bool add = options.add;
  final bool screenChanged = options.screenChanged;

  List<Stream> allVideoStreams = parameters.allVideoStreams;
  List<Participant> participants = parameters.participants;
  List<Stream> oldAllStreams = parameters.oldAllStreams;
  String screenId = parameters.screenId;
  String adminVidID = parameters.adminVidID;
  List<Stream> newLimitedStreams = add ? parameters.newLimitedStreams : [];
  List<String> newLimitedStreamsIDs =
      add ? parameters.newLimitedStreamsIDs : [];
  List<String> activeSounds = add ? parameters.activeSounds : [];

  try {
    var youyou = allVideoStreams
        .where((stream) => stream.producerId == 'youyou')
        .toList();
    var admin = participants
        .where((participant) => participant.islevel == '2')
        .toList();

    if (admin.isNotEmpty) {
      adminVidID = admin[0].videoID;
    } else {
      adminVidID = "";
    }

    if (adminVidID.isNotEmpty) {
      var adminStream = allVideoStreams.firstWhere(
          (stream) => stream.producerId == adminVidID,
          orElse: () => Stream(producerId: '', name: 'none'));

      if (!add) {
        newLimitedStreams.addAll(youyou);
        newLimitedStreamsIDs.addAll(youyou.map((stream) => stream.producerId));
      } else {
        var youyouStream = newLimitedStreams.firstWhere(
            (stream) => stream.producerId == 'youyou',
            orElse: () => Stream(producerId: '', name: 'none'));
        if (youyouStream.name == 'none') {
          newLimitedStreams.addAll(youyou);
          newLimitedStreamsIDs
              .addAll(youyou.map((stream) => stream.producerId));
        }
      }

      if (adminStream.name != 'none') {
        parameters.updateAdminIDStream(adminVidID);
        if (!add) {
          newLimitedStreams.add(adminStream);
          newLimitedStreamsIDs.add(adminStream.producerId);
        } else {
          var adminStreamer = newLimitedStreams.firstWhere(
              (stream) => stream.producerId == adminVidID,
              orElse: () => Stream(producerId: '', name: 'none'));
          if (adminStreamer.name == 'none') {
            newLimitedStreams.add(adminStream);
            newLimitedStreamsIDs.add(adminStream.producerId);
          }
        }
      }

      var oldAdminStream = oldAllStreams.firstWhere(
          (stream) => stream.producerId == adminVidID,
          orElse: () => Stream(producerId: '', name: 'none'));

      if (oldAdminStream.name != 'none') {
        parameters.updateAdminIDStream(adminVidID);
        parameters.updateAdminNameStream(admin[0].name);
        if (!add) {
          newLimitedStreams.add(oldAdminStream);
          newLimitedStreamsIDs.add(oldAdminStream.producerId);
        } else {
          var adminStreamer = newLimitedStreams.firstWhere(
              (stream) => stream.producerId == adminVidID,
              orElse: () => Stream(producerId: '', name: 'none'));
          if (adminStreamer.name == 'none') {
            newLimitedStreams.add(oldAdminStream);
            newLimitedStreamsIDs.add(oldAdminStream.producerId);
          }
        }
      }

      var screenParticipant = participants
          .where((participant) => participant.ScreenID == screenId)
          .toList();

      if (screenParticipant.isNotEmpty) {
        var screenParticipantVidID = screenParticipant[0].videoID;
        var screenParticipantVidID_ = newLimitedStreams
            .where((stream) => stream.producerId == screenParticipantVidID)
            .toList();
        if (screenParticipantVidID_.isEmpty &&
            screenParticipantVidID.isNotEmpty) {
          parameters.updateScreenShareIDStream(screenParticipantVidID);
          parameters.updateScreenShareNameStream(screenParticipant[0].name);
          var screenParticipantVidID__ = allVideoStreams
              .where((stream) => stream.producerId == screenParticipantVidID)
              .toList();
          newLimitedStreams.addAll(screenParticipantVidID__);
          newLimitedStreamsIDs.addAll(
              screenParticipantVidID__.map((stream) => stream.producerId));
        }
      }
    } else {
      if (!add) {
        newLimitedStreams.addAll(youyou);
        newLimitedStreamsIDs.addAll(youyou.map((stream) => stream.producerId));
      } else {
        var youyouStream = newLimitedStreams.firstWhere(
            (stream) => stream.producerId == 'youyou',
            orElse: () => Stream(producerId: '', name: 'none'));
        if (youyouStream.name == 'none') {
          newLimitedStreams.addAll(youyou);
          newLimitedStreamsIDs
              .addAll(youyou.map((stream) => stream.producerId));
        }
      }

      var screenParticipant = participants
          .where((participant) => participant.ScreenID == screenId)
          .toList();

      if (screenParticipant.isNotEmpty) {
        var screenParticipantVidID = screenParticipant[0].videoID;
        var screenParticipantVidID_ = newLimitedStreams
            .where((stream) => stream.producerId == screenParticipantVidID)
            .toList();
        if (screenParticipantVidID_.isEmpty &&
            screenParticipantVidID.isNotEmpty) {
          parameters.updateScreenShareIDStream(screenParticipantVidID);
          parameters.updateScreenShareNameStream(screenParticipant[0].name);
          var screenParticipantVidID__ = allVideoStreams
              .where((stream) => stream.producerId == screenParticipantVidID)
              .toList();
          newLimitedStreams.addAll(screenParticipantVidID__);
          newLimitedStreamsIDs.addAll(
              screenParticipantVidID__.map((stream) => stream.producerId));
        }
      }
    }

    // Update all the states
    parameters.updateNewLimitedStreams(newLimitedStreams);
    parameters.updateNewLimitedStreamsIDs(newLimitedStreamsIDs);
    parameters.updateActiveSounds(activeSounds);
    parameters.updateYouYouStream(youyou);

    // Reflect the changes on the UI
    final optionsChangeVids = ChangeVidsOptions(
      screenChanged: screenChanged,
      parameters: parameters,
    );
    await parameters.changeVids(
      optionsChangeVids,
    );
  } catch (error, stackTrace) {
    // Handle errors
    if (kDebugMode) {
      print('Error during reordering streams: $error');
      print('Stack trace reordering streams: $stackTrace');
    }
  }
}
