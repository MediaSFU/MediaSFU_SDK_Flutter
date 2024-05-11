import 'dart:async';
import 'package:flutter/foundation.dart';

/// The `dispStreams` function takes in various parameters and performs the following tasks:
/// - Extracts parameters from the provided map.
/// - Filters the list of streams based on certain conditions.
/// - Determines the level of the stream based on the recording display type.
/// - Retrieves participant information based on the stream's producer ID.
///
/// The function also makes use of several typedefs and functions defined in the same file.
///
/// Example usage:
/// ```dart
/// await dispStreams(
///   lStreams: myStreams,
///   ind: 0,
///   auto: true,
///   chatSkip: false,
///   forChatCard: myChatCard,
///   forChatID: myChatID,
///   parameters: myParameters,
/// );
///

typedef GetUpdatedAllParams = Map<String, dynamic> Function();
typedef PrepopulateUserMedia = List<dynamic> Function({
  required String name,
  required Map<String, dynamic> parameters,
});
typedef RePort = Future<void> Function({
  bool restart,
  required Map<String, dynamic> parameters,
});
typedef ProcessConsumerTransports = Future<void> Function(
    {required List<dynamic> consumerTransports,
    required List<dynamic> lStreams_,
    required Map<String, dynamic> parameters});
typedef ResumePauseStreams = Future<void> Function(
    {required Map<String, dynamic> parameters});
typedef Readjust = Future<void> Function(
    {required int n,
    required int state,
    required Map<String, dynamic> parameters});
typedef AddVideosGrid = Future<void> Function({
  required List<dynamic> mainGridStreams,
  required List<dynamic> altGridStreams,
  required int numtoadd,
  required int numRows,
  required int numCols,
  required int remainingVideos,
  required int actualRows,
  required int lastrowcols,
  required bool removeAltGrid,
  required int ind,
  bool forChat,
  bool forChatMini,
  dynamic forChatCard,
  String? forChatID,
  required Map<String, dynamic> parameters,
});
typedef GetEstimate = List<dynamic> Function(
    {required int n, required Map<String, dynamic> parameters});
typedef CheckGrid = Future<List<dynamic>> Function(
    int rows, int cols, int refLength);

typedef UpdateActiveNames = void Function(List<String>);
typedef UpdateDispActiveNames = void Function(List<String>);
typedef UpdateLStreams = void Function(List<dynamic>);
typedef UpdateChatRefStreams = void Function(List<dynamic>);
typedef UpdateNForReadjustRecord = void Function(int);
typedef UpdateUpdateMainWindow = void Function(bool);
typedef UpdateShareEnded = void Function(bool);
typedef UpdateAddAltGrid = void Function(bool);
typedef UpdateShowMiniView = void Function(bool);

Future<void> dispStreams({
  required List<dynamic> lStreams,
  required int ind,
  bool auto = false,
  bool chatSkip = false,
  dynamic forChatCard,
  dynamic forChatID,
  required Map<String, dynamic> parameters,
}) async {
  // Function to display streams

  try {
    // Extract parameters
    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
    parameters = getUpdatedAllParams();

    List<dynamic> consumerTransports = parameters['consumerTransports'] ?? [];
    List<dynamic> streamNames = parameters['streamNames'] ?? [];
    List<dynamic> audStreamNames = parameters['audStreamNames'] ?? [];
    List<dynamic> participants = parameters['participants'] ?? [];
    List<dynamic> refParticipants = parameters['refParticipants'] ?? [];
    String recordingDisplayType = parameters['recordingDisplayType'] ?? '';
    bool recordingVideoOptimized =
        parameters['recordingVideoOptimized'] ?? false;
    String meetingDisplayType = parameters['meetingDisplayType'] ?? '';
    bool meetingVideoOptimized = parameters['meetingVideoOptimized'] ?? false;
    int currentUserPage = parameters['currentUserPage'] ?? 0;
    String hostLabel = parameters['hostLabel'] ?? '';
    double mainHeightWidth = parameters['mainHeightWidth'] ?? 0;
    double prevMainHeightWidth = parameters['prevMainHeightWidth'] ?? 0;
    bool prevDoPaginate = parameters['prevDoPaginate'] ?? false;
    bool doPaginate = parameters['doPaginate'] ?? false;
    bool firstAll = parameters['firstAll'] ?? false;
    bool shared = parameters['shared'] ?? false;
    bool shareScreenStarted = parameters['shareScreenStarted'] ?? false;
    bool shareEnded = parameters['shareEnded'] ?? false;
    List<dynamic> oldAllStreams = parameters['oldAllStreams'] ?? [];
    bool updateMainWindow = parameters['updateMainWindow'] ?? false;
    String? remoteProducerId = parameters['remoteProducerId'] ?? '';
    List<String> activeNames = parameters['activeNames'] ?? [];
    List<String> dispActiveNames = parameters['dispActiveNames'] ?? [];
    List<String> pDispActiveNames = parameters['pDispActiveNames'] ?? [];
    int nForReadjustRecord = parameters['nForReadjustRecord'] ?? 0;
    bool firstRound = parameters['firstRound'] ?? false;
    bool lockScreen = parameters['lockScreen'] ?? false;
    List<dynamic> chatRefStreams = parameters['chatRefStreams'] ?? [];
    String eventType = parameters['eventType'] ?? '';
    String islevel = parameters['islevel'] ?? '1';
    dynamic localStreamVideo = parameters['localStreamVideo'];

    UpdateActiveNames updateActiveNames = parameters['updateActiveNames'];
    UpdateDispActiveNames updateDispActiveNames =
        parameters['updateDispActiveNames'];
    UpdateLStreams updateLStreams = parameters['updateLStreams'];
    UpdateChatRefStreams updateChatRefStreams =
        parameters['updateChatRefStreams'];
    UpdateNForReadjustRecord updateNForReadjustRecord =
        parameters['updateNForReadjustRecord'];
    UpdateUpdateMainWindow updateUpdateMainWindow =
        parameters['updateUpdateMainWindow'];
    UpdateShareEnded updateShareEnded = parameters['updateShareEnded'];
    UpdateShowMiniView updateShowMiniView = parameters['updateShowMiniView'];

    // mediasfu functions
    PrepopulateUserMedia prepopulateUserMedia =
        parameters['prepopulateUserMedia'];
    RePort rePort = parameters['rePort'];
    ProcessConsumerTransports processConsumerTransports =
        parameters['processConsumerTransports'];
    ResumePauseStreams resumePauseStreams = parameters['resumePauseStreams'];
    Readjust readjust = parameters['readjust'];
    AddVideosGrid addVideosGrid = parameters['addVideosGrid'];
    GetEstimate getEstimate = parameters['getEstimate'];
    CheckGrid checkGrid = parameters['checkGrid'];

    var proceed = true;

    var lStreams_ = lStreams
        .where((stream) =>
            stream['producerId'] != 'youyou' &&
            stream['producerId'] != 'youyouyou')
        .toList();

    lStreams_ = lStreams_
        .where((stream) =>
            stream['id'] != 'youyou' &&
            stream['id'] != 'youyouyou' &&
            stream['name'] != 'youyou' &&
            stream['name'] != 'youyouyou')
        .toList();

    if (eventType == 'chat') {
      proceed = true;
    } else if (ind == 0 || (islevel != '2' && currentUserPage == ind)) {
      proceed = false;

      for (var stream in lStreams_) {
        var checker = false;
        var checkLevel = 0;

        if (recordingDisplayType == 'video') {
          if (recordingVideoOptimized) {
            if (stream.containsKey('producerId') &&
                stream['producerId'] != null &&
                stream['producerId'] != '') {
              checker = true;
              checkLevel = 0;
            }
          } else {
            if ((stream.containsKey('producerId') &&
                    (stream['producerId'] != null &&
                        stream['producerId'] != '')) ||
                ((stream.containsKey('audioID') &&
                    stream['audioID'] != null &&
                    stream['audioID'] != ''))) {
              checker = true;
              checkLevel = 1;
            }
          }
        } else if (recordingDisplayType == 'media') {
          if ((stream.containsKey('producerId') &&
                  (stream['producerId'] != null &&
                      stream['producerId'] != '')) ||
              ((stream.containsKey('audioID') &&
                  stream['audioID'] != null &&
                  stream['audioID'] != ''))) {
            checker = true;
            checkLevel = 1;
          }
        } else {
          if (((stream.containsKey('producerId') &&
                  (stream['producerId'] != null &&
                      stream['producerId'] != '')) ||
              ((stream.containsKey('audioID') &&
                  stream['audioID'] != null &&
                  stream['audioID'] != '')) ||
              (stream.containsKey('name') &&
                  stream['name'] != null &&
                  stream['name'] != ''))) {
            checker = true;
            checkLevel = 2;
          }
        }

        dynamic participant;

        if (checker) {
          if (checkLevel == 0) {
            if (stream.containsKey('producerId') &&
                (stream['producerId'] != null && stream['producerId'] != '')) {
              participant = streamNames.firstWhere(
                  (obj) => obj['producerId'] == stream['producerId'],
                  orElse: () => null);
            }
          } else if (checkLevel == 1) {
            if (stream.containsKey('producerId') &&
                (stream['producerId'] != null && stream['producerId'] != '')) {
              participant = streamNames.firstWhere(
                  (obj) => obj['producerId'] == stream['producerId'],
                  orElse: () => null);
            }
            if (participant == null) {
              if ((stream.containsKey('audioID') &&
                  stream['audioID'] != null &&
                  stream['audioID'] != '')) {
                participant = audStreamNames.firstWhere(
                    (obj) => obj['producerId'] == stream['audioID'],
                    orElse: () => null);
                participant ??= refParticipants.firstWhere(
                    (obj) => obj['audioID'] == stream['audioID'],
                    orElse: () => null);
              }
            }
          } else if (checkLevel == 2) {
            if (stream.containsKey('producerId') &&
                (stream['producerId'] != null && stream['producerId'] != '')) {
              participant = streamNames.firstWhere(
                  (obj) => obj['producerId'] == stream['producerId'],
                  orElse: () => null);
            }
            if (participant == null) {
              if ((stream.containsKey('audioID') &&
                  stream['audioID'] != null &&
                  stream['audioID'] != '')) {
                participant = audStreamNames.firstWhere(
                    (obj) => obj['producerId'] == stream['audioID'],
                    orElse: () => null);
                participant ??= refParticipants.firstWhere(
                    (obj) => obj['audioID'] == stream['audioID'],
                    orElse: () => null);
              }
            }
            if (participant == null) {
              if (stream.containsKey('name') &&
                  stream['name'] != null &&
                  stream['name'] != '') {
                participant = refParticipants.firstWhere(
                    (obj) => obj['name'] == stream['name'],
                    orElse: () => null);
              }
            }
          }

          if (participant != null) {
            if (!activeNames.contains(participant['name'])) {
              activeNames.add(participant['name']);
            }
          }
        }
      }

      updateActiveNames(activeNames);

      for (var stream in lStreams_) {
        var dispChecker = false;
        var dispCheckLevel = 0;

        if (meetingDisplayType == 'video') {
          if (meetingVideoOptimized) {
            if (stream.containsKey('producerId') &&
                stream['producerId'] != null &&
                stream['producerId'] != '') {
              dispChecker = true;
              dispCheckLevel = 0;
            }
          } else {
            if ((stream.containsKey('producerId') &&
                    (stream['producerId'] != null &&
                        stream['producerId'] != '')) ||
                ((stream.containsKey('audioID') &&
                    stream['audioID'] != null &&
                    stream['audioID'] != ''))) {
              dispChecker = true;
              dispCheckLevel = 1;
            }
          }
        } else if (meetingDisplayType == 'media') {
          if ((stream.containsKey('producerId') &&
                  (stream['producerId'] != null &&
                      stream['producerId'] != '')) ||
              ((stream.containsKey('audioID') &&
                  stream['audioID'] != null &&
                  stream['audioID'] != ''))) {
            dispChecker = true;
            dispCheckLevel = 1;
          }
        } else {
          if (((stream.containsKey('producerId') &&
                  (stream['producerId'] != null &&
                      stream['producerId'] != '')) ||
              ((stream.containsKey('audioID') &&
                  stream['audioID'] != null &&
                  stream['audioID'] != '')) ||
              (stream.containsKey('name') &&
                  stream['name'] != null &&
                  stream['name'] != ''))) {
            dispChecker = true;
            dispCheckLevel = 2;
          }
        }

        dynamic participant_;

        if (dispChecker) {
          if (dispCheckLevel == 0) {
            if (stream.containsKey('producerId') &&
                (stream['producerId'] != null && stream['producerId'] != '')) {
              participant_ = streamNames.firstWhere(
                  (obj) => obj['producerId'] == stream['producerId'],
                  orElse: () => null);
            }
          } else if (dispCheckLevel == 1) {
            if (stream.containsKey('producerId') &&
                (stream['producerId'] != null && stream['producerId'] != '')) {
              participant_ = streamNames.firstWhere(
                  (obj) => obj['producerId'] == stream['producerId'],
                  orElse: () => null);
            }
            if (participant_ == null) {
              if ((stream.containsKey('audioID') &&
                  stream['audioID'] != null &&
                  stream['audioID'] != '')) {
                participant_ = audStreamNames.firstWhere(
                    (obj) => obj['producerId'] == stream['audioID'],
                    orElse: () => null);
                participant_ ??= refParticipants.firstWhere(
                    (obj) => obj['audioID'] == stream['audioID'],
                    orElse: () => null);
              }
            }
          } else if (dispCheckLevel == 2) {
            if (stream.containsKey('producerId') &&
                (stream['producerId'] != null && stream['producerId'] != '')) {
              participant_ = streamNames.firstWhere(
                  (obj) => obj['producerId'] == stream['producerId'],
                  orElse: () => null);
            }
            if (participant_ == null) {
              if ((stream.containsKey('audioID') &&
                  stream['audioID'] != null &&
                  stream['audioID'] != '')) {
                participant_ = audStreamNames.firstWhere(
                    (obj) => obj['producerId'] == stream['audioID'],
                    orElse: () => null);
                participant_ ??= refParticipants.firstWhere(
                    (obj) => obj['audioID'] == stream['audioID'],
                    orElse: () => null);
              }
            }
            if (participant_ == null) {
              if (stream.containsKey('name') &&
                  stream['name'] != null &&
                  stream['name'] != '') {
                participant_ = refParticipants.firstWhere(
                    (obj) => obj['name'] == stream['name'],
                    orElse: () => null);
              }
            }
          }
        }

        if (participant_ != null) {
          if (!dispActiveNames.contains(participant_['name'])) {
            dispActiveNames.add(participant_['name']);
            if (!pDispActiveNames.contains(participant_['name'])) {
              proceed = true;
            }
          }
        }
      }

      updateDispActiveNames(dispActiveNames);

      if (lStreams_.isEmpty) {
        if (shareScreenStarted || shared) {
          proceed = true;
        } else if (!firstAll) {
          proceed = true;
        }
      }

      if (shareScreenStarted || shared) {
      } else {
        if ((prevMainHeightWidth != mainHeightWidth)) {
          updateMainWindow = true;
          updateUpdateMainWindow(updateMainWindow);
        }
      }

      nForReadjustRecord = activeNames.length;
      updateNForReadjustRecord(nForReadjustRecord);
    }

    if (!proceed && auto) {
      if (updateMainWindow) {
        if (!lockScreen && !shared) {
          prepopulateUserMedia(name: hostLabel, parameters: parameters);
        } else {
          if (!firstRound) {
            prepopulateUserMedia(name: hostLabel, parameters: parameters);
          }
        }
      }

      if (ind == 0) {
        await rePort(parameters: parameters);
      }
      return;
    }

    if (eventType == 'broadcast') {
      lStreams = lStreams_;
      updateLStreams(lStreams);
    } else if (eventType == 'chat') {
      if (forChatID != null) {
        lStreams = chatRefStreams;
        updateLStreams(lStreams);
      } else {
        updateShowMiniView(false);
        if (islevel != '2') {
          var host = participants.firstWhere((obj) => obj['islevel'] == '2',
              orElse: () => null);

          if (host != null) {
            dynamic streame;

            remoteProducerId = host['videoID'];
            if (islevel == '2') {
              host['stream'] = localStreamVideo;
            } else {
              streame = oldAllStreams.firstWhere(
                  (streame) => streame['producerId'] == remoteProducerId,
                  orElse: () => null);
              if (streame != null) {
                lStreams = lStreams
                    .where((stream) => stream['name'] != host['name'])
                    .toList();

                lStreams.add(streame);
              }
            }
          }
        }

        var youyou = lStreams.firstWhere(
            (obj) =>
                obj['producerId'] == 'youyou' ||
                obj['producerId'] == 'youyouyou',
            orElse: () => null);

        lStreams = lStreams
            .where((stream) =>
                stream['producerId'] != 'youyou' &&
                stream['producerId'] != 'youyouyou')
            .toList();

        if (youyou != null) {
          lStreams.add(youyou);
        }

        chatRefStreams = List.from(lStreams);

        updateLStreams(lStreams);
        updateChatRefStreams(chatRefStreams);
      }
    }

    var refLength = lStreams.length;

    var [_, rows, cols] = getEstimate(n: refLength, parameters: parameters);
    var [
      removeAltGrid,
      numtoaddd,
      numRows,
      numCols,
      remainingVideos,
      actualRows,
      lastrowcols
    ] = await checkGrid(rows, cols, refLength);

    if (chatSkip && eventType == 'chat') {
      numRows = 1;
      numCols = 1;
      actualRows = 1;
    }

    await readjust(n: lStreams.length, state: ind, parameters: parameters);

    var mainGridStreams = lStreams.sublist(0, numtoaddd);
    var altGridStreams = lStreams.sublist(numtoaddd, lStreams.length);

    if (doPaginate == true ||
        (prevDoPaginate != doPaginate) ||
        (shared || shareScreenStarted) ||
        shareEnded) {
      var lStreamsAlt = List.from(lStreams_);

      await processConsumerTransports(
          consumerTransports: consumerTransports,
          lStreams_: lStreamsAlt,
          parameters: parameters);

      try {
        await resumePauseStreams(parameters: parameters);
      } catch (error) {
        if (kDebugMode) {
          print('Error in resumePauseStreams: $error');
        }
      }

      if (shareEnded) {
        shareEnded = false;
        updateShareEnded(shareEnded);
      }
    }

    if (chatSkip && eventType == 'chat') {
      await addVideosGrid(
        mainGridStreams: mainGridStreams,
        altGridStreams: altGridStreams,
        numtoadd: numtoaddd - 1,
        numRows: numRows,
        numCols: numCols,
        remainingVideos: remainingVideos,
        actualRows: actualRows,
        lastrowcols: lastrowcols,
        removeAltGrid: removeAltGrid,
        ind: ind,
        forChat: true,
        forChatMini: true,
        forChatCard: forChatCard,
        forChatID: forChatID,
        parameters: parameters,
      );
    } else {
      await addVideosGrid(
        mainGridStreams: mainGridStreams,
        altGridStreams: altGridStreams,
        numtoadd: numtoaddd,
        numRows: numRows,
        numCols: numCols,
        remainingVideos: remainingVideos,
        actualRows: actualRows,
        lastrowcols: lastrowcols,
        removeAltGrid: removeAltGrid,
        ind: ind,
        parameters: parameters,
      );
    }

    if (updateMainWindow) {
      if (!lockScreen && !shared) {
        prepopulateUserMedia(name: hostLabel, parameters: parameters);
      } else {
        if (!firstRound) {
          prepopulateUserMedia(name: hostLabel, parameters: parameters);
        }
      }
    }

    if (ind == 0) {
      await rePort(parameters: parameters);
    }
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - Error in dispStreams: $error');
    }
  }
}
