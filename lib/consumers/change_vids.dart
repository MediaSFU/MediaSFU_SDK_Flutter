// ignore_for_file: empty_catches, unused_local_variable

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import '../../types/types.dart'
    show
        Stream,
        AudioDecibels,
        BreakoutParticipant,
        EventType,
        Participant,
        MediaStream,
        DispStreamsParameters,
        DispStreamsType,
        MixStreamsType,
        MixStreamsOptions,
        DispStreamsOptions;

/// Parameters used for changing video streams based on various conditions.
abstract class ChangeVidsParameters implements DispStreamsParameters {
  // Properties as getters
  List<Stream> get allVideoStreams;
  List<String> get pActiveNames;
  List<String> get activeNames;
  List<String> get dispActiveNames;
  bool get shareScreenStarted;
  bool get shared;
  List<Stream> get newLimitedStreams;
  List<Stream> get nonAlVideoStreams;
  List<Participant> get refParticipants;
  List<Participant> get participants;
  EventType get eventType;
  String get islevel;
  String get member;
  bool get sortAudioLoudness;
  List<AudioDecibels> get audioDecibels;
  List<Stream> get mixedAlVideoStreams;
  List<Stream> get nonAlVideoStreamsMuted;
  MediaStream? get localStreamVideo;
  List<Stream> get oldAllStreams;
  int get screenPageLimit;
  String get meetingDisplayType;
  bool get meetingVideoOptimized;
  bool get recordingVideoOptimized;
  String get recordingDisplayType;
  List<List<Stream>> get paginatedStreams;
  int get itemPageLimit;
  bool get doPaginate;
  bool get prevDoPaginate;
  int get currentUserPage;
  List<List<BreakoutParticipant>> get breakoutRooms;
  int get hostNewRoom;
  bool get breakOutRoomStarted;
  bool get breakOutRoomEnded;
  MediaStream? get virtualStream;
  int get mainRoomsLength;
  int get memberRoom;

  // Update functions as abstract methods
  void Function(List<String> names) get updatePActiveNames;
  void Function(List<String> activeNames) get updateActiveNames;
  void Function(List<String> dispActiveNames) get updateDispActiveNames;
  void Function(List<Stream> newLimitedStreams) get updateNewLimitedStreams;
  void Function(List<Stream> nonAlVideoStreams) get updateNonAlVideoStreams;
  void Function(List<Participant> refParticipants) get updateRefParticipants;
  void Function(bool sortAudioLoudness) get updateSortAudioLoudness;
  void Function(List<Stream> mixedAlVideoStreams) get updateMixedAlVideoStreams;
  void Function(List<Stream> nonAlVideoStreamsMuted)
      get updateNonAlVideoStreamsMuted;
  void Function(List<List<Stream>> paginatedStreams) get updatePaginatedStreams;
  void Function(bool doPaginate) get updateDoPaginate;
  void Function(bool prevDoPaginate) get updatePrevDoPaginate;
  void Function(int currentUserPage) get updateCurrentUserPage;
  void Function(int numberPages) get updateNumberPages;
  void Function(int mainRoomsLength) get updateMainRoomsLength;
  void Function(int memberRoom) get updateMemberRoom;

  // Functions
  MixStreamsType get mixStreams;
  DispStreamsType get dispStreams;
  ChangeVidsParameters Function() get getUpdatedAllParams;

  // Operator for dynamic access
  // dynamic operator [](String key);
}

class ChangeVidsOptions {
  bool screenChanged;
  ChangeVidsParameters parameters;

  ChangeVidsOptions({this.screenChanged = false, required this.parameters});
}

typedef ChangeVidsType = Future<void> Function(ChangeVidsOptions options);

/// Changes the video streams on the screen based on the provided options and parameters.
///
/// This function adjusts video streams based on conditions like event type, active participants,
/// and screen sharing status. It updates the necessary lists and variables to display the appropriate
/// video streams.
///
/// Example:
/// ```dart
/// final options = ChangeVidsOptions(
///   screenChanged: false,
///   parameters: ChangeVidsParameters(
///     allVideoStreams: [],
///     pActiveNames: [],
///     activeNames: [],
///     dispActiveNames: [],
///     shareScreenStarted: false,
///     shared: false,
///     newLimitedStreams: [],
///     nonAlVideoStreams: [],
///     refParticipants: [],
///     participants: [],
///     eventType: EventType.conference,
///     islevel: "2",
///     member: "John Doe",
///     sortAudioLoudness: true,
///     audioDecibels: [],
///     mixedAlVideoStreams: [],
///     nonAlVideoStreamsMuted: [],
///     oldAllStreams: [],
///     screenPageLimit: 10,
///     meetingDisplayType: "video",
///     meetingVideoOptimized: true,
///     recordingVideoOptimized: false,
///     recordingDisplayType: "video",
///     paginatedStreams: [],
///     itemPageLimit: 10,
///     doPaginate: true,
///     prevDoPaginate: false,
///     currentUserPage: 1,
///     breakoutRooms: [],
///     hostNewRoom: 0,
///     breakOutRoomStarted: false,
///     breakOutRoomEnded: false,
///     mainRoomsLength: 2,
///     memberRoom: 0,
///     updatePActiveNames: (names) => print('Updated active names: $names'),
///     updateActiveNames: (names) => print('Updated names: $names'),
///     updateDispActiveNames: (names) => print('Displayed names: $names'),
///     updateNewLimitedStreams: (streams) => print('New limited streams: $streams'),
///     updateNonAlVideoStreams: (participants) => print('Non-AL video streams: $participants'),
///     updateRefParticipants: (participants) => print('Reference participants: $participants'),
///     updateSortAudioLoudness: (sort) => print('Sort audio loudness: $sort'),
///     updateMixedAlVideoStreams: (streams) => print('Mixed AL video streams: $streams'),
///     updateNonAlVideoStreamsMuted: (participants) => print('Muted non-AL video streams: $participants'),
///     updatePaginatedStreams: (streams) => print('Paginated streams: $streams'),
///     updateDoPaginate: (paginate) => print('Do paginate: $paginate'),
///     updatePrevDoPaginate: (paginate) => print('Previous do paginate: $paginate'),
///     updateCurrentUserPage: (page) => print('Current user page: $page'),
///     updateNumberPages: (pages) => print('Number of pages: $pages'),
///     updateMainRoomsLength: (length) => print('Main rooms length: $length'),
///     updateMemberRoom: (room) => print('Member room: $room'),
///     mixStreams: (parameters) async => [],
///     dispStreams: (lStreams, ind, {auto = true, parameters = const {}, breakRoom = 0, inBreakRoom = false}) async {},
///     getUpdatedAllParams: () => {},
///   ),
/// );
/// changeVids(options);
/// ```

/// Changes the video streams on the screen based on the provided options and parameters.
///
/// This function adjusts video streams based on conditions like event type, active participants,
/// and screen sharing status. It updates the necessary lists and variables to display the appropriate
/// video streams.
///
/// Example:
/// ```dart
/// final options = ChangeVidsOptions(
///   screenChanged: false,
///   parameters: ChangeVidsParameters(
///     allVideoStreams: [],
///     pActiveNames: [],
///     activeNames: [],
///     dispActiveNames: [],
///     shareScreenStarted: false,
///     shared: false,
///     newLimitedStreams: [],
///     nonAlVideoStreams: [],
///     refParticipants: [],
///     participants: [],
///     eventType: EventType.conference,
///     islevel: "2",
///     member: "John Doe",
///     sortAudioLoudness: true,
///     audioDecibels: [],
///     mixedAlVideoStreams: [],
///     nonAlVideoStreamsMuted: [],
///     localStreamVideo: null,
///     oldAllStreams: [],
///     screenPageLimit: 10,
///     meetingDisplayType: "video",
///     meetingVideoOptimized: true,
///     recordingVideoOptimized: false,
///     recordingDisplayType: "video",
///     paginatedStreams: [],
///     itemPageLimit: 10,
///     doPaginate: true,
///     prevDoPaginate: false,
///     currentUserPage: 1,
///     breakoutRooms: [],
///     hostNewRoom: 0,
///     breakOutRoomStarted: false,
///     breakOutRoomEnded: false,
///     virtualStream: null,
///     mainRoomsLength: 2,
///     memberRoom: 0,
///     updatePActiveNames: (names) => print('Updated active names: $names'),
///     updateActiveNames: (names) => print('Updated names: $names'),
///     updateDispActiveNames: (names) => print('Displayed names: $names'),
///     updateNewLimitedStreams: (streams) => print('New limited streams: $streams'),
///     updateNonAlVideoStreams: (participants) => print('Non-AL video streams: $participants'),
///     updateRefParticipants: (participants) => print('Reference participants: $participants'),
///     updateSortAudioLoudness: (sort) => print('Sort audio loudness: $sort'),
///     updateMixedAlVideoStreams: (streams) => print('Mixed AL video streams: $streams'),
///     updateNonAlVideoStreamsMuted: (participants) => print('Muted non-AL video streams: $participants'),
///     updatePaginatedStreams: (streams) => print('Paginated streams: $streams'),
///     updateDoPaginate: (paginate) => print('Do paginate: $paginate'),
///     updatePrevDoPaginate: (paginate) => print('Previous do paginate: $paginate'),
///     updateCurrentUserPage: (page) => print('Current user page: $page'),
///     updateNumberPages: (pages) => print('Number of pages: $pages'),
///     updateMainRoomsLength: (length) => print('Main rooms length: $length'),
///     updateMemberRoom: (room) => print('Member room: $room'),
///     mixStreams: (parameters) async => [],
///     dispStreams: (List<dynamic> lStreams, int ind, {bool auto = true, Map<String, dynamic> parameters = const {}, int breakRoom = 0, bool inBreakRoom = false}) async {},
///     getUpdatedAllParams: () => ChangeVidsParameters(
///       allVideoStreams: [],
///       pActiveNames: [],
///       activeNames: [],
///       dispActiveNames: [],
///       shareScreenStarted: false,
///       shared: false,
///       newLimitedStreams: [],
///       nonAlVideoStreams: [],
///       refParticipants: [],
///       participants: [],
///       eventType: EventType.conference,
///       islevel: "2",
///       member: "John Doe",
///       sortAudioLoudness: true,
///       audioDecibels: [],
///       mixedAlVideoStreams: [],
///       nonAlVideoStreamsMuted: [],
///       localStreamVideo: null,
///       oldAllStreams: [],
///       screenPageLimit: 10,
///       meetingDisplayType: "video",
///       meetingVideoOptimized: true,
///       recordingVideoOptimized: false,
///       recordingDisplayType: "video",
///       paginatedStreams: [],
///       itemPageLimit: 10,
///       doPaginate: true,
///       prevDoPaginate: false,
///       currentUserPage: 1,
///       breakoutRooms: [],
///       hostNewRoom: 0,
///       breakOutRoomStarted: false,
///       breakOutRoomEnded: false,
///       virtualStream: null,
///       mainRoomsLength: 2,
///       memberRoom: 0,
///       updatePActiveNames: (names) => print('Updated active names: $names'),
///       updateActiveNames: (names) => print('Updated names: $names'),
///       updateDispActiveNames: (names) => print('Displayed names: $names'),
///       updateNewLimitedStreams: (streams) => print('New limited streams: $streams'),
///       updateNonAlVideoStreams: (participants) => print('Non-AL video streams: $participants'),
///       updateRefParticipants: (participants) => print('Reference participants: $participants'),
///       updateSortAudioLoudness: (sort) => print('Sort audio loudness: $sort'),
///       updateMixedAlVideoStreams: (streams) => print('Mixed AL video streams: $streams'),
///       updateNonAlVideoStreamsMuted: (participants) => print('Muted non-AL video streams: $participants'),
///       updatePaginatedStreams: (streams) => print('Paginated streams: $streams'),
///       updateDoPaginate: (paginate) => print('Do paginate: $paginate'),
///       updatePrevDoPaginate: (paginate) => print('Previous do paginate: $paginate'),
///       updateCurrentUserPage: (page) => print('Current user page: $page'),
///       updateNumberPages: (pages) => print('Number of pages: $pages'),
///       updateMainRoomsLength: (length) => print('Main rooms length: $length'),
///       updateMemberRoom: (room) => print('Member room: $room'),
///       mixStreams: (parameters) async => [],
///       dispStreams: (List<dynamic> lStreams, int ind, {bool auto = true, Map<String, dynamic> parameters = const {}, int breakRoom = 0, bool inBreakRoom = false}) async {},
///     ),
///   ),
/// );
/// changeVids(options)
///   .then(() => {
///     print('Video streams changed successfully');
///   });
/// ```
Future<void> changeVids(ChangeVidsOptions options) async {
  // Retrieve updated parameters
  ChangeVidsParameters parameters = options.parameters.getUpdatedAllParams();

  try {
    // Clone lists to avoid mutating original data
    List<Stream> alVideoStreams = List.from(parameters.allVideoStreams);
    List<Stream> allVideoStreams = List.from(parameters.allVideoStreams);
    List<String> pActiveNames = List.from(parameters.pActiveNames);
    List<String> activeNames = List.from(parameters.activeNames);
    List<String> dispActiveNames = List.from(parameters.dispActiveNames);
    List<Stream> newLimitedStreams = List.from(parameters.newLimitedStreams);
    List<Stream> nonAlVideoStreams = List.from(parameters.nonAlVideoStreams);
    List<Participant> refParticipants = List.from(parameters.refParticipants);
    List<Participant> participants = List.from(parameters.participants);
    List<AudioDecibels> audioDecibels = List.from(parameters.audioDecibels);
    List<Stream> mixedAlVideoStreams =
        List.from(parameters.mixedAlVideoStreams);
    List<Stream> nonAlVideoStreamsMuted =
        List.from(parameters.nonAlVideoStreamsMuted);
    List<Stream> oldAllStreams = List.from(parameters.oldAllStreams);
    List<List<BreakoutParticipant>> breakoutRooms =
        List.from(parameters.breakoutRooms);
    List<List<Stream>> paginatedStreams =
        List.from(parameters.paginatedStreams);

    bool shareScreenStarted = parameters.shareScreenStarted;
    bool shared = parameters.shared;
    String eventType = parameters.eventType
        .toString()
        .split('.')
        .last; // Assuming enum to string
    String islevel = parameters.islevel;
    String member = parameters.member;
    bool sortAudioLoudness = parameters.sortAudioLoudness;
    String meetingDisplayType = parameters.meetingDisplayType;
    bool meetingVideoOptimized = parameters.meetingVideoOptimized;
    bool recordingVideoOptimized = parameters.recordingVideoOptimized;
    String recordingDisplayType = parameters.recordingDisplayType;
    int screenPageLimit = parameters.screenPageLimit;
    int itemPageLimit = parameters.itemPageLimit;
    bool doPaginate = parameters.doPaginate;
    bool prevDoPaginate = parameters.prevDoPaginate;
    int currentUserPage = parameters.currentUserPage;
    int hostNewRoom = parameters.hostNewRoom;
    bool breakOutRoomStarted = parameters.breakOutRoomStarted;
    bool breakOutRoomEnded = parameters.breakOutRoomEnded;
    MediaStream? virtualStream = parameters.virtualStream;
    int mainRoomsLength = parameters.mainRoomsLength;
    int memberRoom = parameters.memberRoom;

    // Initialize temporary variables
    Stream? streame;

    // Handle screen sharing
    if (shareScreenStarted || shared) {
      alVideoStreams = List.from(newLimitedStreams);
      activeNames.clear();
    }

    String? remoteProducerId;

    activeNames.clear();
    dispActiveNames.clear();
    refParticipants = List.from(participants);

    // Identify and remove streams without corresponding participants
    List<Stream> tempStreams = List.from(alVideoStreams);
    List<String> elementsToRemove = [];

    for (var stream in tempStreams) {
      try {
        Participant? participant = refParticipants
            .firstWhereOrNull((obj) => obj.videoID == stream.producerId);

        if (participant == null &&
            stream.producerId != 'youyou' &&
            stream.producerId != 'youyouyou') {
          elementsToRemove.add(stream.producerId);
        }
      } catch (error) {
        // Log error if necessary
      }
    }

    // Remove identified streams
    alVideoStreams
        .removeWhere((obj) => elementsToRemove.contains(obj.producerId));

    // Adjust audio loudness sorting based on event type
    if (eventType == 'broadcast' || eventType == 'chat') {
      sortAudioLoudness = false;
    }

    // Reset non-al video streams based on screen sharing status
    if (shareScreenStarted || shared) {
      nonAlVideoStreams = [];
      nonAlVideoStreamsMuted = [];
      mixedAlVideoStreams = [];
    } else {
      // Handle case where number of video streams exceeds screen page limit
      if (alVideoStreams.length > screenPageLimit) {
        alVideoStreams.removeWhere((obj) => obj.producerId == 'youyou');
        alVideoStreams.removeWhere((obj) => obj.producerId == 'youyouyou');

        // Sort participants based on mute status
        refParticipants.sort((a, b) {
          if (a.muted == b.muted) return 0;
          return (a.muted ?? false) ? 1 : -1;
        });

        // Reorder video streams based on sorted participants
        List<Stream> temp = [];
        for (var participant in refParticipants) {
          Stream? stream = alVideoStreams.firstWhereOrNull(
            (obj) => obj.producerId == participant.videoID,
          );
          if (stream != null) {
            temp.add(stream);
          }
        }
        alVideoStreams = temp;

        // Prioritize 'youyou' and 'youyouyou' streams
        var youyou = allVideoStreams
            .firstWhereOrNull((obj) => obj.producerId == 'youyou');

        if (youyou == null) {
          var youyouyou = allVideoStreams.firstWhereOrNull(
            (obj) => obj.producerId == 'youyouyou',
          );
          if (youyouyou != null) {
            alVideoStreams.insert(0, youyouyou);
          }
        } else {
          alVideoStreams.insert(0, youyou);
        }
      }

      // Identify admin participant
      var admin = participants.firstWhereOrNull(
        (participant) => participant.isAdmin! && participant.islevel == '2',
      );
      String adminName = '';
      if (admin != null) {
        adminName = admin.name;
      }

      // Populate non-al video streams based on event type and participant status
      nonAlVideoStreams = [];
      for (var participant in refParticipants) {
        var stream = alVideoStreams.firstWhereOrNull(
          (obj) => obj.producerId == participant.videoID,
        );

        if (eventType != 'chat' && eventType != 'conference') {
          if (stream == null &&
              participant.name != member &&
              !(participant.muted ?? false) &&
              participant.name != adminName) {
            final newStream = Stream.fromMap(participant.toMap());
            nonAlVideoStreams.add(newStream);
          }
        } else {
          if (stream == null &&
              participant.name != member &&
              !(participant.muted ?? false)) {
            final newStream = Stream.fromMap(participant.toMap());
            nonAlVideoStreams.add(newStream);
          }
        }
      }

      // Sort non-al video streams based on audio loudness if required
      if (sortAudioLoudness) {
        nonAlVideoStreams.sort((a, b) {
          var avgLoudnessA = audioDecibels
              .firstWhereOrNull(
                (obj) => obj.name == a.name,
              )!
              .averageLoudness;

          var avgLoudnessB = audioDecibels
              .firstWhereOrNull(
                (obj) => obj.name == b.name,
              )!
              .averageLoudness;

          return avgLoudnessB.compareTo(avgLoudnessA);
        });

        // Mix streams unless specific conditions are met
        if (!((meetingDisplayType == "video" && meetingVideoOptimized) &&
            (recordingVideoOptimized && recordingDisplayType == "video"))) {
          final optionsMix = MixStreamsOptions(
            alVideoStreams: alVideoStreams,
            nonAlVideoStreams: nonAlVideoStreams,
            refParticipants: refParticipants,
          );
          mixedAlVideoStreams =
              await parameters.mixStreams(options: optionsMix);
        }
      }

      // Populate muted non-al video streams based on event type and participant status
      nonAlVideoStreamsMuted = [];
      for (var participant in refParticipants) {
        var stream = alVideoStreams.firstWhereOrNull(
          (obj) => obj.producerId == participant.videoID,
        );

        if (eventType != 'chat' && eventType != 'conference') {
          if (stream == null &&
              participant.name != member &&
              (participant.muted ?? false) &&
              participant.name != adminName) {
            final newStream = Stream.fromMap(participant.toMap());
            nonAlVideoStreamsMuted.add(newStream);
          }
        } else {
          if (stream == null &&
              participant.name != member &&
              (participant.muted ?? false)) {
            final newStream = Stream.fromMap(participant.toMap());
            nonAlVideoStreamsMuted.add(newStream);
          }
        }
      }
    }

    // Handle conference event type with specific conditions
    if (eventType == 'conference' && islevel != '2') {
      var host = participants.firstWhereOrNull((obj) => obj.islevel == '2');

      if (host != null) {
        remoteProducerId = host.videoID;

        if (islevel == '2') {
          // Assign local stream to host if participant is host
          host['stream'] = parameters.localStreamVideo;
        } else {
          var hostVideo = alVideoStreams.firstWhereOrNull(
            (obj) => obj.producerId == remoteProducerId,
          );

          if (hostVideo == null) {
            streame = oldAllStreams.firstWhereOrNull(
              (streame) => streame.producerId == remoteProducerId,
            );

            if (streame != null) {
              // Remove host's old streams
              alVideoStreams
                  .removeWhere((obj) => obj.producerId == host.videoID);
              nonAlVideoStreams.removeWhere((obj) => obj.name == host.name);
              nonAlVideoStreamsMuted
                  .removeWhere((obj) => obj.name == host.name);

              if (sortAudioLoudness) {
                mixedAlVideoStreams.removeWhere((obj) => obj.name == host.name);
                nonAlVideoStreamsMuted
                    .removeWhere((obj) => obj.name == host.name);

                if (meetingDisplayType == "video" && meetingVideoOptimized) {
                  alVideoStreams.insert(0, streame);
                } else {
                  mixedAlVideoStreams.insert(0, streame);
                }
              } else {
                alVideoStreams.insert(0, streame);
              }
            } else {
              // Assign participant's stream to host if available
              for (var participant in refParticipants) {
                var stream = alVideoStreams.firstWhereOrNull(
                  (obj) =>
                      obj.producerId == participant.videoID &&
                      participant.name == host.name,
                );
                if (stream != null) {
                  if (sortAudioLoudness) {
                    mixedAlVideoStreams
                        .removeWhere((obj) => obj.name == host.name);
                    nonAlVideoStreamsMuted
                        .removeWhere((obj) => obj.name == host.name);
                    mixedAlVideoStreams.insert(0, stream);
                  } else {
                    nonAlVideoStreams
                        .removeWhere((obj) => obj.name == host.name);
                    nonAlVideoStreams.insert(0, stream);
                    break;
                  }
                }
              }
            }
          }
        }
      }
    }

    // Compile all streams based on sorting preferences

    List<Stream> allStreamsPaged = [];
    if (sortAudioLoudness) {
      if (meetingDisplayType == 'video') {
        if (meetingVideoOptimized) {
          allStreamsPaged = List.from(alVideoStreams);
        } else {
          allStreamsPaged = List.from(mixedAlVideoStreams);
        }
      } else if (meetingDisplayType == 'media') {
        allStreamsPaged = List.from(mixedAlVideoStreams);
      } else if (meetingDisplayType == 'all') {
        allStreamsPaged = List.from(mixedAlVideoStreams)
          ..addAll(nonAlVideoStreamsMuted);
      }
    } else {
      if (meetingDisplayType == 'video') {
        allStreamsPaged = List.from(alVideoStreams);
      } else if (meetingDisplayType == 'media') {
        allStreamsPaged = List.from(alVideoStreams)..addAll(nonAlVideoStreams);
      } else if (meetingDisplayType == 'all') {
        allStreamsPaged = List.from(alVideoStreams)
          ..addAll(nonAlVideoStreams)
          ..addAll(nonAlVideoStreamsMuted);
      }
    }

    // Handle recording display type if necessary
    if (sortAudioLoudness) {
      if (recordingDisplayType == 'video') {
        if (recordingVideoOptimized) {
          // Implement optimized video recording handling if needed
        } else {
          // Implement non-optimized video recording handling if needed
        }
      } else if (recordingDisplayType == 'media') {
        // Implement media recording handling if needed
      } else if (recordingDisplayType == 'all') {
        // Implement all recording handling if needed
      }
    } else {
      if (recordingDisplayType == 'video') {
        // Implement video recording handling if needed
      } else if (recordingDisplayType == 'media') {
        // Implement media recording handling if needed
      } else if (recordingDisplayType == 'all') {
        // Implement all recording handling if needed
      }
    }

    // Reset paginated streams
    paginatedStreams = [];
    int limit = itemPageLimit;

    if (shareScreenStarted || shared) {
      limit = screenPageLimit;
    }

    List<Stream> firstPage = [];
    List<Stream> page;
    int limit_ = limit + 1;

    if (eventType == 'conference') {
      if (shared || shareScreenStarted) {
        // No adjustment needed
      } else {
        limit_ -= 1;
      }
    }

    // Create pagination
    bool memberInRoom = false;
    bool filterHost = false;

    if (breakOutRoomStarted && !breakOutRoomEnded) {
      List<List<BreakoutParticipant>> tempBreakoutRooms =
          List.from(breakoutRooms);
      var host = participants.firstWhereOrNull((obj) => obj.islevel == '2');

      for (var room in tempBreakoutRooms) {
        try {
          List<Stream> currentStreams = [];
          int roomIndex = tempBreakoutRooms.indexOf(room);

          if (hostNewRoom != -1 && roomIndex == hostNewRoom) {
            if (host != null) {
              if (!room.any((obj) => obj.name == host.name)) {
                room = List.from(room)
                  ..add(BreakoutParticipant(
                      name: host.name, breakRoom: roomIndex));
                filterHost = true;
              }
            }
          }

          for (var participant in room) {
            if (participant.name == member && !memberInRoom) {
              memberInRoom = true;
              memberRoom = participant.breakRoom!;
              parameters.updateMemberRoom(memberRoom);
            }

            List<Stream> streams = allStreamsPaged.where((stream) {
              bool hasProducerId = stream.containsKey('producerId') &&
                  stream.producerId.isNotEmpty;
              bool hasAudioId = stream.containsKey('audioID') &&
                  stream.audioID != null &&
                  stream.audioID!.isNotEmpty;

              if (hasProducerId || hasAudioId) {
                String producerId = stream.producerId.isNotEmpty
                    ? stream.producerId
                    : stream.audioID!;
                var matchingParticipant = refParticipants.firstWhereOrNull(
                  (obj) =>
                      obj.audioID == producerId ||
                      obj.videoID == producerId ||
                      ((producerId == 'youyou' || producerId == 'youyouyou') &&
                          member == participant.name),
                );
                return (matchingParticipant != null &&
                        matchingParticipant.name == participant.name) ||
                    (participant.name == member &&
                        (producerId == 'youyou' || producerId == 'youyouyou'));
              } else {
                return stream.containsKey('name') &&
                    stream.name == participant.name;
              }
            }).toList();

            for (var stream in streams) {
              if (currentStreams.length < limit_) {
                currentStreams.add(stream);
              }
            }
          }

          paginatedStreams.add(currentStreams);
        } catch (error) {
          // Handle error if necessary
        }
      }

      // Identify remaining streams not in breakout rooms
      List<Stream> remainingStreams = allStreamsPaged.where((stream) {
        bool hasProducerId =
            stream.containsKey('producerId') && stream.producerId.isNotEmpty;
        bool hasAudioId = stream.containsKey('audioID') &&
            stream.audioID != null &&
            stream.audioID!.isNotEmpty;

        if (hasProducerId || hasAudioId) {
          String producerId = stream.producerId.isNotEmpty
              ? stream.producerId
              : stream.audioID!;
          var matchingParticipant = refParticipants.firstWhereOrNull(
            (obj) =>
                obj.audioID == producerId ||
                obj.videoID == producerId ||
                ((producerId == 'youyou' || producerId == 'youyouyou') &&
                    member == obj.name),
          );
          return (matchingParticipant != null &&
                  !breakoutRooms
                      .expand((room) => room)
                      .map((obj) => obj.name)
                      .contains(matchingParticipant.name)) &&
              (!filterHost ||
                  (host!.name.isNotEmpty &&
                      matchingParticipant.name != host.name));
        } else {
          return !(breakoutRooms
                  .expand((room) => room)
                  .map((obj) => obj.name)
                  .contains(stream.name)) &&
              (!filterHost ||
                  (host!.name.isNotEmpty && stream.name != host.name));
        }
      }).toList();

      // Ensure member's stream is included
      if (memberInRoom) {
        var memberStream = allStreamsPaged.firstWhereOrNull(
          (stream) =>
              stream.containsKey('producerId') && stream.producerId.isNotEmpty,
        );
        if (memberStream != null && !remainingStreams.contains(memberStream)) {
          remainingStreams.insert(0, memberStream);
        }
      }

      List<List<Stream>> remainingPaginatedStreams = [];

      if (remainingStreams.isNotEmpty) {
        // Determine the length of the remainingStreams list
        int listEnd = remainingStreams.length;

        // Check if the length exceeds the limit
        if (listEnd > limit) {
          // Add the first page to remainingPaginatedStreams
          firstPage = remainingStreams.sublist(0, limit_);
          remainingPaginatedStreams.add(firstPage);

          // Add the remaining streams to the pagination
          for (int i = limit_; i < remainingStreams.length; i += limit) {
            if (i + limit > listEnd) {
              page = remainingStreams.sublist(i, listEnd);
            } else {
              page = remainingStreams.sublist(i, i + limit);
            }
            remainingPaginatedStreams.add(page);
          }
        } else {
          // If the list length is within the limit, add the entire list as the first page
          firstPage = remainingStreams;
          remainingPaginatedStreams.add(firstPage);
        }
      }

      // Update main rooms length
      mainRoomsLength = remainingPaginatedStreams.length;
      parameters.updateMainRoomsLength(mainRoomsLength);

      // Add the remaining streams to the beginning of the paginatedStreams
      for (int i = remainingPaginatedStreams.length - 1; i >= 0; i--) {
        paginatedStreams.insert(0, remainingPaginatedStreams[i]);
      }
    } else {
      // Handle pagination when not in breakout rooms
      int listEnd = allStreamsPaged.length;
      if (listEnd > limit) {
        firstPage = allStreamsPaged.sublist(0, limit_);
        paginatedStreams.add(firstPage);

        // Add the remaining streams to the pagination
        for (int i = limit_; i < allStreamsPaged.length; i += limit) {
          if (i + limit > listEnd) {
            page = allStreamsPaged.sublist(i, listEnd);
          } else {
            page = allStreamsPaged.sublist(i, i + limit);
          }
          paginatedStreams.add(page);
        }
      } else {
        firstPage = allStreamsPaged;
        paginatedStreams.add(firstPage);
      }
    }

    // Update state with the modified lists
    parameters.updatePActiveNames(pActiveNames);
    parameters.updateActiveNames(activeNames);
    parameters.updateDispActiveNames(dispActiveNames);
    parameters.updateNewLimitedStreams(newLimitedStreams);
    parameters.updateNonAlVideoStreams(nonAlVideoStreams);
    parameters.updateRefParticipants(refParticipants);
    parameters.updateSortAudioLoudness(sortAudioLoudness);
    parameters.updateMixedAlVideoStreams(mixedAlVideoStreams);
    parameters.updateNonAlVideoStreamsMuted(nonAlVideoStreamsMuted);
    parameters.updatePaginatedStreams(paginatedStreams);

    // Update pagination flags
    parameters.updatePrevDoPaginate(doPaginate);
    parameters.updateDoPaginate(false);

    bool isActive = false;

    if (paginatedStreams.length > 1) {
      if (!shareScreenStarted && !shared) {
        parameters.updateDoPaginate(true);
      }

      if (currentUserPage > (paginatedStreams.length - 1)) {
        if (breakOutRoomStarted && !breakOutRoomEnded) {
          currentUserPage = 0;
        } else {
          currentUserPage = paginatedStreams.length - 1;
        }
      } else if (currentUserPage == 0) {
        isActive = true;
      }

      parameters.updateCurrentUserPage(currentUserPage);
      parameters.updateNumberPages(paginatedStreams.length - 1);

      // Display the first stream or paginated stream based on screen change
      if (options.screenChanged) {
        final optionsDisp = DispStreamsOptions(
          lStreams: paginatedStreams[0],
          ind: 0,
          parameters: parameters,
          breakRoom: 0,
          inBreakRoom: false,
        );
        await parameters.dispStreams(
          optionsDisp,
        );
      } else {
        final optionsDisp = DispStreamsOptions(
          lStreams: paginatedStreams[0],
          ind: 0,
          auto: true,
          parameters: parameters,
          breakRoom: 0,
          inBreakRoom: false,
        );
        await parameters.dispStreams(
          optionsDisp,
        );
      }

      // Display current user page stream if not active
      if (!isActive) {
        int currentPageBreak = currentUserPage - mainRoomsLength;
        final optionsDisp = DispStreamsOptions(
          lStreams: paginatedStreams[currentUserPage],
          ind: currentUserPage,
          parameters: parameters,
          breakRoom: currentPageBreak,
          inBreakRoom: currentPageBreak >= 0,
        );
        await parameters.dispStreams(
          optionsDisp,
        );
      }
    } else if (paginatedStreams.isNotEmpty) {
      // Handle case with a single paginated stream
      parameters.updateDoPaginate(false);
      currentUserPage = 0;
      parameters.updateCurrentUserPage(currentUserPage);

      final optionsDisp = DispStreamsOptions(
        lStreams: paginatedStreams[0],
        ind: 0,
        parameters: parameters,
        breakRoom: 0,
        inBreakRoom: false,
      );
      if (options.screenChanged) {
        await parameters.dispStreams(
          optionsDisp,
        );
      } else {
        final optionsDisp = DispStreamsOptions(
          lStreams: paginatedStreams[0],
          ind: 0,
          auto: true,
          parameters: parameters,
          breakRoom: 0,
          inBreakRoom: false,
        );
        await parameters.dispStreams(
          optionsDisp,
        );
      }
    }
  } catch (error, stackTrace) {
    if (kDebugMode) {
      print('changeVids error: $error');
      print('changeVids stack trace: $stackTrace');
    }
  }
}
