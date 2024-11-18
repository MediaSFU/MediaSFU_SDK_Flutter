// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show
        Stream,
        Participant,
        TransportType,
        PrepopulateUserMediaParameters,
        PrepopulateUserMediaType,
        RePortParameters,
        RePortType,
        ProcessConsumerTransportsParameters,
        ProcessConsumerTransportsType,
        ResumePauseStreamsParameters,
        ResumePauseStreamsType,
        ReadjustParameters,
        ReadjustType,
        AddVideosGridType,
        AddVideosGridParameters,
        GetEstimateType,
        CheckGridType,
        ResumePauseAudioStreamsParameters,
        ResumePauseAudioStreamsType,
        GetEstimateParameters,
        EventType,
        MediaStream,
        AddVideosGridOptions,
        GetEstimateOptions,
        CheckGridOptions,
        RePortOptions,
        PrepopulateUserMediaOptions,
        ProcessConsumerTransportsOptions,
        ResumePauseStreamsOptions,
        ResumePauseAudioStreamsOptions,
        ReadjustOptions;

/// Parameters required for displaying streams.
/// Extends multiple parameter interfaces from your TypeScript definitions.
abstract class DispStreamsParameters
    implements
        PrepopulateUserMediaParameters,
        RePortParameters,
        ProcessConsumerTransportsParameters,
        ResumePauseStreamsParameters,
        ReadjustParameters,
        ResumePauseAudioStreamsParameters,
        GetEstimateParameters,
        AddVideosGridParameters {
  // Properties as abstract getters
  List<TransportType> get consumerTransports;
  List<Stream> get streamNames;
  List<Stream> get audStreamNames;
  List<Participant> get participants;
  List<Participant> get refParticipants;
  String get recordingDisplayType; // 'video' | 'media' | 'all'
  bool get recordingVideoOptimized;
  String get meetingDisplayType;
  bool get meetingVideoOptimized;
  int get currentUserPage;
  String get hostLabel;
  double get mainHeightWidth;
  double get prevMainHeightWidth;
  bool get prevDoPaginate;
  bool get doPaginate;
  bool get firstAll;
  bool get shared;
  bool get shareScreenStarted;
  bool get shareEnded;
  List<Stream> get oldAllStreams; // List<Stream | Participant>
  bool get updateMainWindow;
  List<String> get activeNames;
  List<String> get dispActiveNames;
  List<String> get pDispActiveNames;
  int get nForReadjustRecord;
  bool get firstRound;
  bool get lockScreen;
  List<Stream> get chatRefStreams; // List<Stream | Participant>
  EventType get eventType;
  String get islevel;
  MediaStream? get localStreamVideo;
  bool get breakOutRoomStarted;
  bool get breakOutRoomEnded;
  bool get keepBackground;
  MediaStream? get virtualStream;

  // Update functions as abstract getters
  void Function(List<String>) get updateActiveNames;
  void Function(List<String>) get updateDispActiveNames;
  void Function(List<Stream>) get updateLStreams;
  void Function(List<Stream>) get updateChatRefStreams;
  void Function(int) get updateNForReadjustRecord;
  void Function(bool) get updateUpdateMainWindow;
  void Function(bool) get updateShowMiniView;
  void Function(bool) get updateShareEnded;

  // Mediasfu functions as abstract getters
  PrepopulateUserMediaType get prepopulateUserMedia;
  RePortType get rePort;
  ProcessConsumerTransportsType get processConsumerTransports;
  ResumePauseStreamsType get resumePauseStreams;
  ReadjustType get readjust;
  AddVideosGridType get addVideosGrid;
  GetEstimateType get getEstimate;
  CheckGridType get checkGrid;
  ResumePauseAudioStreamsType get resumePauseAudioStreams;

  // Method for getting updated parameters
  DispStreamsParameters Function() get getUpdatedAllParams;

  // Dynamic access operator for additional properties
  //dynamic operator [](String key);
}

/// Options for the dispStreams function.
class DispStreamsOptions {
  List<Stream> lStreams; // List<Stream | Participant>
  int ind;
  bool auto;
  bool ChatSkip;
  dynamic forChatCard;
  dynamic forChatID;
  DispStreamsParameters parameters;
  int breakRoom;
  bool inBreakRoom;

  DispStreamsOptions({
    required this.lStreams,
    required this.ind,
    this.auto = false,
    this.ChatSkip = false,
    this.forChatCard,
    this.forChatID,
    required this.parameters,
    this.breakRoom = -1,
    this.inBreakRoom = false,
  });
}

/// Function type definition for displaying streams.
typedef DispStreamsType = Future<void> Function(DispStreamsOptions options);

/// Displays streams in the media application based on a range of parameters and conditions.
///
/// This function:
/// - **Filters Streams**: Excludes specific streams (like 'youyou') based on preset rules.
/// - **Updates Active Names**: Populates lists of active and displayed names based on stream conditions.
/// - **Prepopulates User Media**: Uses `prepopulateUserMedia` to update the UI and manage media layout.
/// - **Reorders Streams**: Adds streams to a grid layout and updates based on the current event type (broadcast, chat).
/// - **Resumes or Pauses Streams**: Adjusts the state of media streams depending on room settings, like breakout room status.
///
/// ### Parameters:
/// - `options` (`DispStreamsOptions`): Contains parameters needed for stream display.
///   - `lStreams`: The list of streams to be displayed, filtered and updated based on conditions.
///   - `ind`: An index value for determining the stream arrangement or pagination.
///   - `auto`: A boolean that determines if auto-adjustments should be applied.
///   - `ChatSkip`: A flag indicating if chat-specific processing should be skipped.
///   - `forChatCard`, `forChatID`: Optional dynamic parameters for chat-specific configurations.
///   - `parameters`: The main set of parameters for configuring media stream display settings.
///   - `breakRoom`: Integer representing a specific breakout room.
///   - `inBreakRoom`: Indicates if the user is currently in a breakout room.
///
/// ### Behavior:
/// - **Event-Driven Display**: Distinguishes between broadcast and chat events to organize streams differently.
/// - **Grid Layout Adjustment**: Calculates grid layouts using `getEstimate` and `checkGrid` functions.
/// - **Breakout Room Management**: Handles stream resume/pause differently if in a breakout room.
///
/// ### Error Handling:
/// - Prints errors in debug mode if any function calls fail, particularly in media state transitions and stream handling.
///
/// ### Example Usage:
/// ```dart
/// final options = DispStreamsOptions(
///   lStreams: [/* Streams list */],
///   ind: 0,
///   auto: true,
///   ChatSkip: false,
///   forChatCard: null,
///   forChatID: null,
///   parameters: parameters,  // Instance of DispStreamsParameters
///   breakRoom: -1,
///   inBreakRoom: false,
/// );
///
/// dispStreams(options).then((_) {
///   print("Streams displayed successfully");
/// }).catchError((error) {
///   print("Error displaying streams: $error");
/// });
/// ```
///
/// ### Notes:
/// - **Handles a wide variety of media conditions**: This function is intended to adapt to both participant and broadcast layouts, as well as chat-focused or mixed-media environments.
/// - **Callback and Async Functionality**: Various callback functions and async operations are included to ensure responsive media state updates.

Future<void> dispStreams(DispStreamsOptions options) async {
  try {
    // Retrieve updated parameters
    var lStreams = options.lStreams;
    DispStreamsParameters parameters = options.parameters.getUpdatedAllParams();

    // Destructure necessary properties
    List<TransportType> consumerTransports = parameters.consumerTransports;
    List<Stream> streamNames = parameters.streamNames;
    List<Stream> audStreamNames = parameters.audStreamNames;
    List<Participant> participants = parameters.participants;
    List<Participant> refParticipants = parameters.refParticipants;
    String recordingDisplayType = parameters.recordingDisplayType;
    bool recordingVideoOptimized = parameters.recordingVideoOptimized;
    String meetingDisplayType = parameters.meetingDisplayType;
    bool meetingVideoOptimized = parameters.meetingVideoOptimized;
    int currentUserPage = parameters.currentUserPage;
    String hostLabel = parameters.hostLabel;
    double mainHeightWidth = parameters.mainHeightWidth;
    double prevMainHeightWidth = parameters.prevMainHeightWidth;
    bool prevDoPaginate = parameters.prevDoPaginate;
    bool doPaginate = parameters.doPaginate;
    bool firstAll = parameters.firstAll;
    bool shared = parameters.shared;
    bool shareScreenStarted = parameters.shareScreenStarted;
    bool shareEnded = parameters.shareEnded;
    List<Stream> oldAllStreams = parameters.oldAllStreams;
    bool updateMainWindow = parameters.updateMainWindow;
    List<String> activeNames = List.from(parameters.activeNames);
    List<String> dispActiveNames = List.from(parameters.dispActiveNames);
    List<String> pDispActiveNames = List.from(parameters.pDispActiveNames);
    int nForReadjustRecord = parameters.nForReadjustRecord;
    bool firstRound = parameters.firstRound;
    bool lockScreen = parameters.lockScreen;
    List<Stream> chatRefStreams = List.from(parameters.chatRefStreams);
    EventType eventType = parameters.eventType;
    String islevel = parameters.islevel;
    MediaStream? localStreamVideo = parameters.localStreamVideo;

    bool breakOutRoomStarted = parameters.breakOutRoomStarted;
    bool breakOutRoomEnded = parameters.breakOutRoomEnded;
    bool keepBackground = parameters.keepBackground;
    MediaStream? virtualStream = parameters.virtualStream;

    // Update functions
    void Function(List<String>) updateActiveNames =
        parameters.updateActiveNames;
    void Function(List<String>) updateDispActiveNames =
        parameters.updateDispActiveNames;
    void Function(List<Stream>) updateLStreams = parameters.updateLStreams;
    void Function(List<Stream>) updateChatRefStreams =
        parameters.updateChatRefStreams;
    void Function(int) updateNForReadjustRecord =
        parameters.updateNForReadjustRecord;
    void Function(bool) updateUpdateMainWindow =
        parameters.updateUpdateMainWindow;
    void Function(bool) updateShowMiniView = parameters.updateShowMiniView;

    // mediasfu functions
    PrepopulateUserMediaType prepopulateUserMedia =
        parameters.prepopulateUserMedia;
    RePortType rePort = parameters.rePort;
    ProcessConsumerTransportsType processConsumerTransports =
        parameters.processConsumerTransports;
    ResumePauseStreamsType resumePauseStreams = parameters.resumePauseStreams;
    ReadjustType readjust = parameters.readjust;
    AddVideosGridType addVideosGrid = parameters.addVideosGrid;
    GetEstimateType getEstimate = parameters.getEstimate;
    CheckGridType checkGrid = parameters.checkGrid;
    ResumePauseAudioStreamsType resumePauseAudioStreams =
        parameters.resumePauseAudioStreams;

    bool proceed = true;
    String? remoteProducerId;

    // Filter out 'youyou' and 'youyouyou' streams
    List<Stream> lStreams_ = options.lStreams.where((stream) {
      String? producerId = stream.producerId;
      String? id = stream.id;
      String? name = stream.name;
      return producerId != 'youyou' &&
          producerId != 'youyouyou' &&
          id != 'youyou' &&
          id != 'youyouyou' &&
          name != 'youyou' &&
          name != 'youyouyou';
    }).toList();

    if (eventType == EventType.chat) {
      proceed = true;
    } else if (options.ind == 0 ||
        (islevel != '2' && currentUserPage == options.ind)) {
      proceed = false;

      // Populate activeNames based on lStreams_
      for (var stream in lStreams_) {
        bool checker = false;
        int checkLevel = 0;

        if (recordingDisplayType == 'video') {
          if (recordingVideoOptimized) {
            if (stream.containsKey('producerId') && stream.producerId != '') {
              checker = true;
              checkLevel = 0;
            }
          } else {
            if ((stream.containsKey('producerId') && stream.producerId != '') ||
                (stream.containsKey('audioID') &&
                    stream.audioID != null &&
                    stream.audioID != '')) {
              checker = true;
              checkLevel = 1;
            }
          }
        } else if (recordingDisplayType == 'media') {
          if ((stream.containsKey('producerId') && stream.producerId != '') ||
              (stream.containsKey('audioID') &&
                  stream.audioID != null &&
                  stream.audioID != '')) {
            checker = true;
            checkLevel = 1;
          }
        } else {
          if (((stream.containsKey('producerId') && stream.producerId != '') ||
              (stream.containsKey('audioID') &&
                  stream.audioID != null &&
                  stream.audioID != '') ||
              (stream.containsKey('name') &&
                  stream.name != null &&
                  stream.name != ''))) {
            checker = true;
            checkLevel = 2;
          }
        }

        Stream? participant;

        if (checker) {
          if (checkLevel == 0) {
            if (stream.containsKey('producerId') && stream.producerId != '') {
              participant = streamNames.firstWhereOrNull(
                (obj) => obj.producerId == stream.producerId,
              );
            }
          } else if (checkLevel == 1) {
            if (stream.containsKey('producerId') && stream.producerId != '') {
              participant = streamNames.firstWhereOrNull(
                (obj) => obj.producerId == stream.producerId,
              );
            }
            if (participant == null) {
              if (stream.containsKey('audioID') &&
                  stream.audioID != null &&
                  stream.audioID != '') {
                participant = audStreamNames.firstWhereOrNull(
                  (obj) => obj.producerId == stream.audioID,
                );
                if (participant == null) {
                  final participantStream = refParticipants.firstWhereOrNull(
                    (obj) => obj.audioID == stream.audioID,
                  );
                  if (participantStream != null) {
                    participant = Stream.fromMap(participantStream.toMap());
                  }
                }
              }
            }
          } else if (checkLevel == 2) {
            if (stream.containsKey('producerId') && stream.producerId != '') {
              participant = streamNames.firstWhereOrNull(
                (obj) => obj.producerId == stream.producerId,
              );
            }
            if (participant == null) {
              if (stream.containsKey('audioID') &&
                  stream.audioID != null &&
                  stream.audioID != '') {
                participant = audStreamNames.firstWhereOrNull(
                  (obj) => obj.producerId == stream.audioID,
                );

                if (participant == null) {
                  final participantStream = refParticipants.firstWhereOrNull(
                    (obj) => obj.audioID == stream.audioID,
                  );
                  if (participantStream != null) {
                    participant = Stream.fromMap(participantStream.toMap());
                  }
                }
              }
            }
            if (participant == null) {
              if (stream.containsKey('name') &&
                  stream.name != null &&
                  stream.name != '') {
                final participantStream = refParticipants.firstWhereOrNull(
                  (obj) => obj.name == stream.name,
                );
                if (participantStream != null) {
                  participant = Stream.fromMap(participantStream.toMap());
                }
              }
            }
          }

          if (participant != null &&
              participant.name!.isNotEmpty &&
              participant.name != 'none') {
            if (!activeNames.contains(participant.name)) {
              activeNames.add(participant.name!);
            }
          }
        }
      }

      parameters.updateActiveNames(activeNames);

      // Populate dispActiveNames based on lStreams_
      for (var stream in lStreams_) {
        bool dispChecker = false;
        int dispCheckLevel = 0;

        if (meetingDisplayType == 'video') {
          if (meetingVideoOptimized) {
            if (stream.containsKey('producerId') && stream.producerId != '') {
              dispChecker = true;
              dispCheckLevel = 0;
            }
          } else {
            if ((stream.containsKey('producerId') && stream.producerId != '') ||
                (stream.containsKey('audioID') &&
                    stream.audioID != null &&
                    stream.audioID != '')) {
              dispChecker = true;
              dispCheckLevel = 1;
            }
          }
        } else if (meetingDisplayType == 'media') {
          if ((stream.containsKey('producerId') && stream.producerId != '') ||
              (stream.containsKey('audioID') &&
                  stream.audioID != null &&
                  stream.audioID != '')) {
            dispChecker = true;
            dispCheckLevel = 1;
          }
        } else {
          if (((stream.containsKey('producerId') && stream.producerId != '') ||
              (stream.containsKey('audioID') &&
                  stream.audioID != null &&
                  stream.audioID != '') ||
              (stream.containsKey('name') &&
                  stream.name != null &&
                  stream.name != ''))) {
            dispChecker = true;
            dispCheckLevel = 2;
          }
        }

        Stream? participant_;

        if (dispChecker) {
          if (dispCheckLevel == 0) {
            if (stream.containsKey('producerId') && stream.producerId != '') {
              participant_ = streamNames.firstWhereOrNull(
                (obj) => obj.producerId == stream.producerId,
              );
            }
          } else if (dispCheckLevel == 1) {
            if (stream.containsKey('producerId') && stream.producerId != '') {
              participant_ = streamNames.firstWhereOrNull(
                (obj) => obj.producerId == stream.producerId,
              );
            }
            if (participant_ == null) {
              if (stream.containsKey('audioID') &&
                  stream.audioID != null &&
                  stream.audioID != '') {
                participant_ = audStreamNames.firstWhereOrNull(
                  (obj) => obj.producerId == stream.audioID,
                );
                if (participant_ == null) {
                  final participantStream = refParticipants.firstWhereOrNull(
                    (obj) => obj.audioID == stream.audioID,
                  );
                  if (participantStream != null) {
                    participant_ = Stream.fromMap(participantStream.toMap());
                  }
                }
              }
            }
          } else if (dispCheckLevel == 2) {
            if (stream.containsKey('producerId') && stream.producerId != '') {
              participant_ = streamNames.firstWhereOrNull(
                (obj) => obj.producerId == stream.producerId,
              );
            }
            if (participant_ == null) {
              if (stream.containsKey('audioID') &&
                  stream.audioID != null &&
                  stream.audioID != '') {
                participant_ = audStreamNames.firstWhereOrNull(
                  (obj) => obj.producerId == stream.audioID,
                );
                if (participant_ == null) {
                  final participantStream = refParticipants.firstWhereOrNull(
                    (obj) => obj.audioID == stream.audioID,
                  );
                  if (participantStream != null) {
                    participant_ = Stream.fromMap(participantStream.toMap());
                  }
                }
              }
              if (participant_ == null) {
                if (stream.containsKey('name') &&
                    stream.name != null &&
                    stream.name != '') {
                  final participantStream = refParticipants.firstWhereOrNull(
                    (obj) => obj.name == stream.name,
                  );
                }
              }
            }
          }
        }

        if (participant_ != null) {
          if (!dispActiveNames.contains(participant_.name)) {
            dispActiveNames.add(participant_.name!);
            if (!pDispActiveNames.contains(participant_.name)) {
              proceed = true;
            }
          }
        }
      }

      parameters.updateDispActiveNames(dispActiveNames);

      if (lStreams_.isEmpty && (shareScreenStarted || shared || !firstAll)) {
        proceed = true;
      }

      if (shareScreenStarted || shared) {
        // Additional logic if needed
      } else {
        if (prevMainHeightWidth != mainHeightWidth) {
          updateMainWindow = true;
          updateUpdateMainWindow(updateMainWindow);
        }
      }

      nForReadjustRecord = activeNames.length;
      updateNForReadjustRecord(nForReadjustRecord);
    }

    if (!proceed && options.auto) {
      final optionsPrepopulate = PrepopulateUserMediaOptions(
        name: hostLabel,
        parameters: parameters,
      );
      if (updateMainWindow && !lockScreen && !shared) {
        await prepopulateUserMedia(optionsPrepopulate);
      } else if (!firstRound) {
        await prepopulateUserMedia(optionsPrepopulate);
      }

      if (options.ind == 0 && eventType != EventType.chat) {
        final optionsRePort = RePortOptions(
          parameters: parameters,
        );
        await rePort(optionsRePort);
      }
      return;
    }

    if (eventType == EventType.broadcast) {
      lStreams = List.from(lStreams_);
      updateLStreams(lStreams);
    } else if (eventType == EventType.chat) {
      if (options.forChatID != null) {
        lStreams = List.from(chatRefStreams);
        updateLStreams(lStreams);
      } else {
        updateShowMiniView(false);

        if (islevel != '2') {
          Participant? host =
              participants.firstWhereOrNull((obj) => obj.islevel == '2');

          if (host != null) {
            Stream? streame;

            remoteProducerId = host.videoID;
            if (islevel == '2') {
              host['stream'] = keepBackground && virtualStream != null
                  ? virtualStream
                  : localStreamVideo;
            } else {
              streame = oldAllStreams.firstWhereOrNull(
                (streame) => streame.producerId == remoteProducerId,
              );
              if (streame != null) {
                lStreams = lStreams
                    .where((stream) => stream.name != host.name)
                    .toList();
                lStreams.add(streame);
              }
            }
          }
        }

        Stream? youyou = lStreams.firstWhereOrNull((obj) =>
            obj.producerId == 'youyou' || obj.producerId == 'youyouyou');

        lStreams = lStreams
            .where((stream) =>
                stream.producerId != 'youyou' &&
                stream.producerId != 'youyouyou')
            .toList();

        if (youyou != null) {
          lStreams.add(youyou);
        }

        chatRefStreams = List.from(lStreams);

        updateLStreams(lStreams);
        updateChatRefStreams(chatRefStreams);
      }
    }

    int refLength = lStreams.length;

    List<int> estimate =
        getEstimate(GetEstimateOptions(n: refLength, parameters: parameters));
    List<dynamic> gridCheckResult = await checkGrid(CheckGridOptions(
        rows: estimate[1], cols: estimate[2], actives: refLength));
    bool removeAltGrid = gridCheckResult[0];
    int numtoaddd = gridCheckResult[1];
    int numRows = gridCheckResult[2];
    int numCols = gridCheckResult[3];
    int actualRows = gridCheckResult[5];
    int lastrowcols = gridCheckResult[6];

    if (options.ChatSkip && eventType == EventType.chat) {
      numRows = 1;
      numCols = 1;
      actualRows = 1;
    }

    final optionsReadjust = ReadjustOptions(
      n: lStreams.length,
      state: options.ind,
      parameters: parameters,
    );
    await readjust(options: optionsReadjust);

    List<Stream> mainGridStreams = lStreams.sublist(0, numtoaddd);
    List<Stream> altGridStreams = lStreams.sublist(numtoaddd);

    if (doPaginate ||
        prevDoPaginate != doPaginate ||
        shared ||
        shareScreenStarted ||
        shareEnded) {
      List<Stream> lStreamsAlt = List.from(lStreams_);
      final optionsProcessConsumer = ProcessConsumerTransportsOptions(
        consumerTransports: consumerTransports,
        lStreams_: lStreamsAlt,
        parameters: parameters,
      );
      await processConsumerTransports(optionsProcessConsumer);

      try {
        if (breakOutRoomStarted && !breakOutRoomEnded) {
          final optionsResumePause = ResumePauseAudioStreamsOptions(
            inBreakRoom: options.inBreakRoom,
            breakRoom: options.breakRoom,
            parameters: parameters,
          );
          await resumePauseAudioStreams(options: optionsResumePause);
        } else {
          final optionsResumePause = ResumePauseStreamsOptions(
            parameters: parameters,
          );
          await resumePauseStreams(options: optionsResumePause);
        }
      } catch (error) {
        if (kDebugMode) {
          print('Error in resumePauseAudioStreams: $error');
        }
      }

      try {
        if (!breakOutRoomStarted ||
            (breakOutRoomStarted && breakOutRoomEnded)) {
          final optionsResumePause =
              ResumePauseStreamsOptions(parameters: parameters);
          await resumePauseStreams(options: optionsResumePause);
        }
      } catch (error) {
        if (kDebugMode) {
          print('Error in resumePauseStreams: $error');
        }
      }

      if (shareEnded) {
        shareEnded = false;
        parameters.updateShareEnded(shareEnded);
      }
    }

    if (options.ChatSkip && eventType == EventType.chat) {
      final optionsVideosGrid = AddVideosGridOptions(
        mainGridStreams: mainGridStreams,
        altGridStreams: altGridStreams,
        numRows: numRows,
        numCols: numCols,
        actualRows: actualRows,
        lastRowCols: lastrowcols,
        removeAltGrid: removeAltGrid,
        parameters: parameters,
      );
      await addVideosGrid(optionsVideosGrid);
    } else {
      final optionsVideosGrid = AddVideosGridOptions(
        mainGridStreams: mainGridStreams,
        altGridStreams: altGridStreams,
        numRows: numRows,
        numCols: numCols,
        actualRows: actualRows,
        lastRowCols: lastrowcols,
        removeAltGrid: removeAltGrid,
        parameters: parameters,
      );
      await addVideosGrid(optionsVideosGrid);
    }

    if (updateMainWindow) {
      if (!lockScreen && !shared) {
        final optionsPrePopulate = PrepopulateUserMediaOptions(
          name: hostLabel,
          parameters: parameters,
        );
        await prepopulateUserMedia(optionsPrePopulate);
      } else {
        final optionsPrePopulate = PrepopulateUserMediaOptions(
          name: hostLabel,
          parameters: parameters,
        );
        if (!firstRound) {
          await prepopulateUserMedia(optionsPrePopulate);
        }
      }
    }

    if (options.ind == 0 && eventType != EventType.chat) {
      final optionsRePort = RePortOptions(parameters: parameters);
      await rePort(optionsRePort);
    }
  } catch (error) {
    if (kDebugMode) {
      print('dispStreams error: $error');
    }
  }
}
