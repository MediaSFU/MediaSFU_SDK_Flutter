// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter/foundation.dart';

/// This function is responsible for changing the videos on the screen based on the given parameters.
/// It updates the necessary lists and variables to display the appropriate video streams.
///
/// Parameters:
/// - [screenChanged]: A boolean value indicating whether the screen has changed.
/// - [parameters]: A map containing the required parameters for changing the videos.
///
/// Returns: A [Future] that completes when the videos have been changed.

typedef MixStreamsFunction = Future<List<dynamic>> Function(
    {required Map<String, dynamic> parameters});

typedef DispStreamsFunction = void Function({
  required List<dynamic> lStreams,
  required int ind,
  bool auto,
  bool chatSkip,
  dynamic forChatCard,
  dynamic forChatID,
  required Map<String, dynamic> parameters,
  int breakRoom,
  bool inBreakRoom,
});

typedef GetUpdatedAllParams = Map<String, dynamic> Function();

Future<void> changeVids(
    {bool screenChanged = false,
    required Map<String, dynamic> parameters}) async {
  // Function to change the videos on the screen
  // Call updateMiniCardsGrid() with the current number of rows and columns

  GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
  parameters = getUpdatedAllParams();

  List<dynamic> allVideoStreams = parameters['allVideoStreams'];
  List<String> pActiveNames = parameters['pActiveNames'];
  List<String> activeNames = parameters['activeNames'];
  List<String> dispActiveNames = parameters['dispActiveNames'];
  bool shareScreenStarted = parameters['shareScreenStarted'] ?? false;
  bool shared = parameters['shared'] ?? false;
  List<dynamic> newLimitedStreams = parameters['newLimitedStreams'];
  List<dynamic> nonAlVideoStreams = parameters['nonAlVideoStreams'];
  List<dynamic> refParticipants = parameters['refParticipants'];
  List<dynamic> participants = parameters['participants'];
  String eventType = parameters['eventType'];
  String islevel = parameters['islevel'];
  String member = parameters['member'];
  bool sortAudioLoudness = parameters['sortAudioLoudness'];
  List<dynamic> audioDecibels = parameters['audioDecibels'];
  List<dynamic> mixedAlVideoStreams = parameters['mixedAlVideoStreams'];
  List<dynamic> nonAlVideoStreamsMuted = parameters['nonAlVideoStreamsMuted'];
  dynamic remoteProducerId = parameters['remoteProducerId'];
  dynamic localStreamVideo = parameters['localStreamVideo'];
  List<dynamic> oldAllStreams = parameters['oldAllStreams'];
  int screenPageLimit = parameters['screenPageLimit'];
  String meetingDisplayType = parameters['meetingDisplayType'];
  bool meetingVideoOptimized = parameters['meetingVideoOptimized'];
  bool recordingVideoOptimized = parameters['recordingVideoOptimized'];
  String recordingDisplayType = parameters['recordingDisplayType'];
  List<dynamic> paginatedStreams = parameters['paginatedStreams'];
  int itemPageLimit = parameters['itemPageLimit'];
  bool doPaginate = parameters['doPaginate'];
  bool prevDoPaginate = parameters['prevDoPaginate'];
  int currentUserPage = parameters['currentUserPage'];

  List<dynamic> breakoutRooms = parameters['breakoutRooms'];
  int hostNewRoom = parameters['hostNewRoom'];
  bool breakOutRoomStarted = parameters['breakOutRoomStarted'];
  bool breakOutRoomEnded = parameters['breakOutRoomEnded'];
  int mainRoomsLength = parameters['mainRoomsLength'];
  int memberRoom = parameters['memberRoom'];

  void Function(List<String> value) updatePActiveNames =
      parameters['updatePActiveNames'];
  void Function(List<String> value) updateActiveNames =
      parameters['updateActiveNames'];
  void Function(List<String> value) updateDispActiveNames =
      parameters['updateDispActiveNames'];
  void Function(List<dynamic> value) updateNewLimitedStreams =
      parameters['updateNewLimitedStreams'];
  void Function(List<dynamic> value) updateNonAlVideoStreams =
      parameters['updateNonAlVideoStreams'];
  void Function(List<dynamic> value) updateRefParticipants =
      parameters['updateRefParticipants'];
  void Function(bool value) updateSortAudioLoudness =
      parameters['updateSortAudioLoudness'];
  void Function(dynamic value) updateMixedAlVideoStreams =
      parameters['updateMixedAlVideoStreams'];
  void Function(dynamic value) updateNonAlVideoStreamsMuted =
      parameters['updateNonAlVideoStreamsMuted'];
  void Function(dynamic value) updatePaginatedStreams =
      parameters['updatePaginatedStreams'];
  void Function(bool value) updateDoPaginate = parameters['updateDoPaginate'];
  void Function(bool value) updatePrevDoPaginate =
      parameters['updatePrevDoPaginate'];
  void Function(int value) updateCurrentUserPage =
      parameters['updateCurrentUserPage'];
  void Function(int value) updateNumberPages = parameters['updateNumberPages'];

  void Function(int value) updateMainRoomsLength =
      parameters['updateMainRoomsLength'];
  void Function(int value) updateMemberRoom = parameters['updateMemberRoom'];

  // mediasfu functions
  MixStreamsFunction mixStreams = parameters['mixStreams'];
  DispStreamsFunction dispStreams = parameters['dispStreams'];

  try {
    List<dynamic> alVideoStreams = List.from(allVideoStreams);
    pActiveNames = List.from(activeNames);

    dynamic streame;

    if (shareScreenStarted || shared) {
      allVideoStreams = List.from(newLimitedStreams);
      activeNames = [];
    }
    activeNames = [];
    dispActiveNames = [];
    refParticipants = participants;

    List<dynamic> temp = List.from(allVideoStreams);

    // Create a list to store elements to remove
    List<dynamic> elementsToRemove = [];

    for (var stream in temp) {
      try {
        var participant = refParticipants.firstWhere(
          (obj) => obj['videoID'] == stream['producerId'],
          orElse: () => null,
        );

        if (participant == null &&
            stream['producerId'] != 'youyou' &&
            stream['producerId'] != 'youyouyou') {
          // Add the stream to the list of elements to remove
          elementsToRemove.add(stream['producerId']);
        }
      } catch (error) {}
    }

    // Remove elements from alVideoStreams after the loop
    alVideoStreams
        .removeWhere((obj) => elementsToRemove.contains(obj['producerId']));

    if (eventType == 'broadcast' || eventType == 'chat') {
      sortAudioLoudness = false;
    }

    if (shareScreenStarted || shared) {
      nonAlVideoStreams = [];
      nonAlVideoStreamsMuted = [];
      mixedAlVideoStreams = [];
    } else {
      if (alVideoStreams.length > screenPageLimit) {
        alVideoStreams.removeWhere((obj) => obj['producerId'] == 'youyou');
        alVideoStreams.removeWhere((obj) => obj['producerId'] == 'youyouyou');

        refParticipants.sort((a, b) => a['muted'] == b['muted']
            ? 0
            : a['muted'] == true
                ? 1
                : -1);

        List<dynamic> temp = [];
        for (var participant in refParticipants) {
          var stream = alVideoStreams.firstWhere(
              (obj) => obj['producerId'] == participant['videoID'],
              orElse: () => null);
          if (stream != null) {
            temp.add(stream);
          }
        }
        alVideoStreams = temp;

        var youyou = allVideoStreams.firstWhere(
            (obj) => obj['producerId'] == 'youyou',
            orElse: () => null);

        if (youyou == null) {
          var youyouyou = allVideoStreams.firstWhere(
              (obj) => obj['producerId'] == 'youyouyou',
              orElse: () => null);
          if (youyouyou != null) {
            alVideoStreams.insert(0, youyouyou);
          }
        } else {
          alVideoStreams.insert(0, youyou);
        }
      }

      var admin = participants.firstWhere(
          (participant) =>
              participant['isAdmin'] == true && participant['islevel'] == '2',
          orElse: () => null);
      var adminName = '';
      if (admin != null) {
        adminName = admin['name'];
      }

      nonAlVideoStreams = [];
      for (var participant in refParticipants) {
        var stream = alVideoStreams.firstWhere(
            (obj) => obj['producerId'] == participant['videoID'],
            orElse: () => null);
        if (eventType != 'chat' && eventType != 'conference') {
          if (stream == null &&
              participant['name'] != member &&
              !participant['muted'] &&
              participant['name'] != adminName) {
            nonAlVideoStreams.add(participant);
          }
        } else {
          if (stream == null &&
              participant['name'] != member &&
              !participant['muted']) {
            nonAlVideoStreams.add(participant);
          }
        }
      }

      if (sortAudioLoudness) {
        nonAlVideoStreams.sort((a, b) {
          var avgLoudnessA = audioDecibels.firstWhere(
              (obj) => obj['name'] == a['name'],
              orElse: () => {'averageLoudness': 127})['averageLoudness'];
          var avgLoudnessB = audioDecibels.firstWhere(
              (obj) => obj['name'] == b['name'],
              orElse: () => {'averageLoudness': 127})['averageLoudness'];
          return avgLoudnessB - avgLoudnessA;
        });

        if ((meetingDisplayType == "video" && meetingVideoOptimized) &&
            (recordingVideoOptimized && recordingDisplayType == "video")) {
        } else {
          mixedAlVideoStreams = await mixStreams(
            parameters: {
              'alVideoStreams': alVideoStreams,
              'nonAlVideoStreams': nonAlVideoStreams,
              'refParticipants': refParticipants
            },
          );
        }
      }

      nonAlVideoStreamsMuted = [];
      for (var participant in refParticipants) {
        var stream = alVideoStreams.firstWhere(
            (obj) => obj['producerId'] == participant['videoID'],
            orElse: () => null);
        if (eventType != 'chat' && eventType != 'conference') {
          if (stream == null &&
              participant['name'] != member &&
              participant['muted'] &&
              participant['name'] != adminName) {
            nonAlVideoStreamsMuted.add(participant);
          }
        } else {
          if (stream == null &&
              participant['name'] != member &&
              participant['muted']) {
            nonAlVideoStreamsMuted.add(participant);
          }
        }
      }
    }

    if (eventType == 'conference' && islevel != '2') {
      var host = participants.firstWhere((obj) => obj['islevel'] == '2',
          orElse: () => null);
      if (host != null) {
        remoteProducerId = host['videoID'];

        if (islevel == '2') {
          host['stream'] = localStreamVideo;
        } else {
          var hostVideo = alVideoStreams.firstWhere(
              (obj) => obj['producerId'] == remoteProducerId,
              orElse: () => null);
          if (hostVideo == null) {
            streame = oldAllStreams.firstWhere(
                (streame) => streame['producerId'] == remoteProducerId,
                orElse: () => null);
            if (streame != null) {
              alVideoStreams
                  .removeWhere((obj) => obj['producerId'] == host['videoID']);
              nonAlVideoStreams
                  .removeWhere((obj) => obj['name'] == host['name']);
              nonAlVideoStreamsMuted
                  .removeWhere((obj) => obj['name'] == host['name']);
              if (sortAudioLoudness) {
                mixedAlVideoStreams
                    .removeWhere((obj) => obj['name'] == host['name']);
                nonAlVideoStreamsMuted
                    .removeWhere((obj) => obj['name'] == host['name']);
                if (meetingDisplayType == "video" && meetingVideoOptimized) {
                  alVideoStreams.insert(0, streame);
                } else {
                  mixedAlVideoStreams.insert(0, streame);
                }
              } else {
                alVideoStreams.insert(0, streame);
              }
            } else {
              for (var participant in refParticipants) {
                var stream = alVideoStreams.firstWhere(
                    (obj) =>
                        obj['producerId'] == participant['videoID'] &&
                        participant['name'] == host['name'],
                    orElse: () => null);
                if (stream != null) {
                  if (sortAudioLoudness) {
                    mixedAlVideoStreams
                        .removeWhere((obj) => obj['name'] == host['name']);
                    nonAlVideoStreamsMuted
                        .removeWhere((obj) => obj['name'] == host['name']);
                    mixedAlVideoStreams.insert(0, participant);
                  } else {
                    nonAlVideoStreams
                        .removeWhere((obj) => obj['name'] == host['name']);
                    nonAlVideoStreams.insert(0, participant);
                    break;
                  }
                }
              }
            }
          }
        }
      }
    }

    List<dynamic> allStreamsPaged = [];
    if (sortAudioLoudness) {
      if (meetingDisplayType == 'video') {
        if (meetingVideoOptimized) {
          allStreamsPaged = alVideoStreams;
        } else {
          allStreamsPaged = mixedAlVideoStreams;
        }
      } else if (meetingDisplayType == 'media') {
        allStreamsPaged = mixedAlVideoStreams;
      } else if (meetingDisplayType == 'all') {
        allStreamsPaged = mixedAlVideoStreams + nonAlVideoStreamsMuted;
      }
    } else {
      if (meetingDisplayType == 'video') {
        allStreamsPaged = alVideoStreams;
      } else if (meetingDisplayType == 'media') {
        allStreamsPaged = alVideoStreams + nonAlVideoStreams;
      } else if (meetingDisplayType == 'all') {
        allStreamsPaged =
            alVideoStreams + nonAlVideoStreams + nonAlVideoStreamsMuted;
      }
    }

    if (sortAudioLoudness) {
      if (recordingDisplayType == 'video') {
        if (recordingVideoOptimized) {
        } else {}
      } else if (recordingDisplayType == 'media') {
      } else if (recordingDisplayType == 'all') {}
    } else {
      if (recordingDisplayType == 'video') {
      } else if (recordingDisplayType == 'media') {
      } else if (recordingDisplayType == 'all') {}
    }

    paginatedStreams = [];
    int limit = itemPageLimit;

    if (shareScreenStarted || shared) {
      limit = screenPageLimit;
    }

    List<dynamic> firstPage = [];
    List<dynamic> page;
    int limit_ = limit + 1;

    if (eventType == 'conference') {
      if (shared || shareScreenStarted) {
      } else {
        limit_ -= 1;
      }
    }

    // Create pagination
    bool memberInRoom = false;
    bool filterHost = false;

    if (breakOutRoomStarted && !breakOutRoomEnded) {
      List<dynamic> tempBreakoutRooms = List.from(breakoutRooms);
      var host = participants.firstWhere((obj) => obj['islevel'] == '2',
          orElse: () => null);
      for (var room in tempBreakoutRooms) {
        try {
          List<dynamic> currentStreams = [];
          int roomIndex = tempBreakoutRooms.indexOf(room);
          if (hostNewRoom != -1 && roomIndex == hostNewRoom) {
            if (host != null) {
              if (!room.map((obj) => obj['name']).contains(host['name'])) {
                room = [
                  ...room,
                  {'name': host['name'], 'breakRoom': roomIndex}
                ];
                filterHost = true;
              }
            }
          }
          for (var participant in room) {
            if (participant['name'] == member && !memberInRoom) {
              memberInRoom = true;
              memberRoom = participant['breakRoom'];
              updateMemberRoom(memberRoom);
            }
            List<dynamic> streams = allStreamsPaged.where((stream) {
              if ((stream.containsKey('producerId') &&
                      (stream['producerId'] != null &&
                          stream['producerId'] != "")) ||
                  (stream.containsKey('audioID') &&
                      stream['audioID'] != null &&
                      stream['audioID'] != "")) {
                var producerId = stream['producerId'] ?? stream['audioID'];
                var matchingParticipant = refParticipants.firstWhere(
                    (obj) =>
                        obj['audioID'] == producerId ||
                        obj['videoID'] == producerId ||
                        ((producerId == 'youyou' ||
                                producerId == 'youyouyou') &&
                            member == participant['name']),
                    orElse: () => null);
                return (matchingParticipant != null &&
                        matchingParticipant['name'] == participant['name']) ||
                    (participant['name'] == member &&
                        (producerId == 'youyou' || producerId == 'youyouyou'));
              } else {
                return stream.containsKey('name') &&
                    stream['name'] == participant['name'];
              }
            }).toList();
            for (var stream in streams) {
              if (currentStreams.length < limit_) {
                currentStreams.add(stream);
              }
            }
          }
          paginatedStreams.add(currentStreams);
        } catch (error) {}
      }

      List<dynamic> remainingStreams = allStreamsPaged.where((stream) {
        if ((stream.containsKey('producerId') &&
                (stream['producerId'] != null && stream['producerId'] != "")) ||
            (stream.containsKey('audioID') &&
                stream['audioID'] != null &&
                stream['audioID'] != "")) {
          var producerId = stream['producerId'] ?? stream['audioID'];
          var matchingParticipant = refParticipants.firstWhere(
              (obj) =>
                  obj['audioID'] == producerId ||
                  obj['videoID'] == producerId ||
                  ((producerId == 'youyou' || producerId == 'youyouyou') &&
                      member == obj['name']),
              orElse: () => null);
          return matchingParticipant != null &&
              !breakoutRooms
                  .expand((room) => room)
                  .map((obj) => obj['name'])
                  .contains(matchingParticipant['name']) &&
              (!filterHost || matchingParticipant['name'] != host['name']);
        } else {
          return !breakoutRooms
                  .expand((room) => room)
                  .map((obj) => obj['name'])
                  .contains(stream['name']) &&
              (!filterHost || stream['name'] != host['name']);
        }
      }).toList();

      if (memberInRoom) {
        var memberStream = allStreamsPaged.firstWhere(
            (stream) =>
                stream.containsKey('producerId') &&
                (stream['producerId'] != null && stream['producerId'] != ""),
            orElse: () => null);
        if (memberStream != null && !remainingStreams.contains(memberStream)) {
          remainingStreams.insert(0, memberStream);
        }
      }
      List<dynamic> remainingPaginatedStreams = [];

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

      mainRoomsLength = remainingPaginatedStreams.length;
      updateMainRoomsLength(mainRoomsLength);

      for (int i = remainingPaginatedStreams.length - 1; i >= 0; i--) {
        paginatedStreams.insert(0, remainingPaginatedStreams[i]);
      }
    } else {
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

    updatePActiveNames(pActiveNames);
    updateActiveNames(activeNames);
    updateDispActiveNames(dispActiveNames);
    updateNewLimitedStreams(newLimitedStreams);
    updateNonAlVideoStreams(nonAlVideoStreams);
    updateRefParticipants(refParticipants);
    updateSortAudioLoudness(sortAudioLoudness);
    updateMixedAlVideoStreams(mixedAlVideoStreams);
    updateNonAlVideoStreamsMuted(nonAlVideoStreamsMuted);
    updatePaginatedStreams(paginatedStreams);

    prevDoPaginate = doPaginate;
    doPaginate = false;
    updatePrevDoPaginate(prevDoPaginate);
    updateDoPaginate(doPaginate);

    bool isActive = false;

    if (paginatedStreams.length > 1) {
      if (shareScreenStarted || shared) {
        doPaginate = false;
      } else {
        doPaginate = true;
      }
      updateDoPaginate(doPaginate);

      if (currentUserPage > (paginatedStreams.length - 1)) {
        if (breakOutRoomStarted && !breakOutRoomEnded) {
          currentUserPage = 0;
        } else {
          currentUserPage = paginatedStreams.length - 1;
        }
      } else {
        if (currentUserPage == 0) {
          isActive = true;
        }
      }
      updateCurrentUserPage(currentUserPage);
      updateNumberPages(paginatedStreams.length - 1);

      if (screenChanged) {
        dispStreams(
          lStreams: paginatedStreams[0],
          ind: 0,
          parameters: parameters,
          breakRoom: 0,
          inBreakRoom: false,
        );
      } else {
        dispStreams(
          lStreams: paginatedStreams[0],
          ind: 0,
          auto: true,
          parameters: parameters,
          breakRoom: 0,
          inBreakRoom: false,
        );
      }

      if (!isActive) {
        int currentPageBreak = currentUserPage - mainRoomsLength;
        dispStreams(
          lStreams: paginatedStreams[currentUserPage],
          ind: currentUserPage,
          parameters: parameters,
          breakRoom: currentPageBreak,
          inBreakRoom: currentPageBreak >= 0,
        );
      }
    } else {
      doPaginate = false;
      updateDoPaginate(doPaginate);
      currentUserPage = 0;
      updateCurrentUserPage(currentUserPage);

      if (screenChanged) {
        dispStreams(
          lStreams: paginatedStreams[0],
          ind: 0,
          parameters: parameters,
          breakRoom: 0,
          inBreakRoom: false,
        );
      } else {
        dispStreams(
          lStreams: paginatedStreams[0],
          ind: 0,
          auto: true,
          parameters: parameters,
          breakRoom: 0,
          inBreakRoom: false,
        );
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('changeVids error: $error');
    }
  }
}
