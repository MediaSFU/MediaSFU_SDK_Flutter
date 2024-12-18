// ignore_for_file: unused_local_variable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../methods/utils/mini_audio_player/mini_audio_player.dart'
    show MiniAudioPlayer;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show Consumer;
import '../components/display_components/mini_audio.dart'
    show MiniAudio, MiniAudioOptions;
import '../types/types.dart'
    show
        ReorderStreamsType,
        ReorderStreamsParameters,
        Participant,
        PrepopulateUserMediaType,
        PrepopulateUserMediaParameters,
        Stream,
        MiniAudioPlayerParameters,
        EventType,
        ReorderStreamsOptions,
        PrepopulateUserMediaOptions,
        MiniAudioPlayerOptions;

/// Abstract class defining parameters for handling the resumption of audio and video streams in a media session.
///
/// Extends functionalities of [ReorderStreamsParameters], [PrepopulateUserMediaParameters], and [MiniAudioPlayerParameters]
/// to provide comprehensive controls for managing audio and video streams, including real-time media updates, stream organization,
/// and state management.
abstract class ConsumerResumeParameters
    implements
        ReorderStreamsParameters,
        PrepopulateUserMediaParameters,
        MiniAudioPlayerParameters {
  MediaStream? get nStream;
  List<Stream> get allAudioStreams; // Use List<Stream> or List<Participant>
  List<Stream> get allVideoStreams;
  List<Stream> get streamNames;
  List<Stream> get audStreamNames;
  bool get updateMainWindow;
  bool get shared;
  bool get shareScreenStarted;
  String get screenId;
  List<Participant> get participants;
  EventType get eventType;
  String get meetingDisplayType;
  bool get mainScreenFilled;
  bool get firstRound;
  bool get lockScreen;
  List<Stream> get oldAllStreams;
  String get adminVidID;
  double get mainHeightWidth;
  String get member;
  List<Widget> get audioOnlyStreams;
  bool get gotAllVids;
  bool get deferReceive;
  bool get firstAll;
  List<Stream> get remoteScreenStream;
  String get hostLabel;
  bool get whiteboardStarted;
  bool get whiteboardEnded;

  void Function(bool value) get updateUpdateMainWindow;
  void Function(List<Stream> value) get updateAllAudioStreams;
  void Function(List<Stream> value) get updateAllVideoStreams;
  void Function(List<Stream> value) get updateStreamNames;
  void Function(List<Stream> value) get updateAudStreamNames;
  void Function(MediaStream value) get updateNStream;
  void Function(double value) get updateMainHeightWidth;
  void Function(bool value) get updateLockScreen;
  void Function(bool value) get updateFirstAll;
  void Function(List<Stream> value) get updateRemoteScreenStream;
  void Function(List<Stream> value) get updateOldAllStreams;
  void Function(List<Widget> value) get updateAudioOnlyStreams;
  void Function(bool value) get updateShareScreenStarted;
  void Function(bool value) get updateGotAllVids;
  void Function(String value) get updateScreenId;
  void Function(bool value) get updateDeferReceive;

  // Mediasfu functions
  ReorderStreamsType get reorderStreams;
  PrepopulateUserMediaType get prepopulateUserMedia;
  ConsumerResumeParameters Function() get getUpdatedAllParams;

  // Stream operator [](String key);
}

/// Configuration options for the `consumerResume` function, used to manage the resumption of audio or video streams.
///
/// ### Example Usage:
/// ```dart
/// final options = ConsumerResumeOptions(
///   stream: myMediaStream,
///   kind: 'audio',
///   remoteProducerId: 'producerId123',
///   parameters: myConsumerResumeParameters,
///   nsock: mySocket,
/// );
///
/// await consumerResume(options);
/// ```
class ConsumerResumeOptions {
  final MediaStream stream;
  final String kind;
  final String remoteProducerId;
  final ConsumerResumeParameters parameters;
  final io.Socket nsock;
  final Consumer consumer;

  ConsumerResumeOptions({
    required this.stream,
    required this.kind,
    required this.remoteProducerId,
    required this.parameters,
    required this.nsock,
    required this.consumer,
  });
}

typedef ConsumerResumeType = Future<void> Function(
    ConsumerResumeOptions options);

/// Handles the resumption of a media stream (either audio or video) by managing the socket
/// connections, updating the UI, and reordering streams as necessary.
///
/// This function performs comprehensive handling of media streams by leveraging socket connections,
/// organizing UI components, and performing real-time updates to the video and audio grids.
///
/// - **Audio Resumption:** Adds the resumed audio to the list of active audio streams, updates the UI with
///   an audio-only component, and triggers a reordering of streams if required.
/// - **Video Resumption:** Adds the resumed video to the list of active video streams, manages screen sharing
///   updates (if applicable), and reorders streams based on the screen sharing state or participant role.
///
/// ### Parameters:
/// - `options` (`ConsumerResumeOptions`): Contains the details of the stream to be resumed:
///   - `stream` (`MediaStream`): The media stream that is being resumed.
///   - `kind` (`String`): The type of the media stream, either 'audio' or 'video'.
///   - `remoteProducerId` (`String`): The producer ID of the remote media stream.
///   - `parameters` (`ConsumerResumeParameters`): Parameters for managing state updates and triggering functions.
///   - `nsock` (`io.Socket`): The socket connection for managing real-time events.
///   - `consumer` (`Consumer`): The consumer object associated with the media stream.
///
/// ### Example Usage:
/// ```dart
/// await consumerResume(ConsumerResumeOptions(
///   stream: myMediaStream,
///   kind: 'audio',
///   remoteProducerId: 'producerId123',
///   parameters: consumerResumeParams,
///   nsock: socket,
///   consumer: myConsumer,
/// ));
/// ```
///
/// ### Returns:
/// - A `Future<void>` that completes when the handling of the resumed media stream is finished.

Future<void> consumerResume(ConsumerResumeOptions options) async {
  try {
    // Destructure options for easy access
    final MediaStream stream = options.stream;
    final String kind = options.kind;
    final String remoteProducerId = options.remoteProducerId;
    final ConsumerResumeParameters parameters = options.parameters;
    final io.Socket nsock = options.nsock;
    final Consumer consumer = options.consumer;

    // Refresh parameters using the latest state
    final ConsumerResumeParameters updatedParams =
        parameters.getUpdatedAllParams();

    // Destructure updatedParams using getters
    final MediaStream? nStream = updatedParams.nStream;
    List<Stream> allAudioStreams = updatedParams.allAudioStreams;
    List<Stream> allVideoStreams = updatedParams.allVideoStreams;
    final List<Stream> streamNames = updatedParams.streamNames;
    final List<Stream> audStreamNames = updatedParams.audStreamNames;
    final bool mainScreenFilled = updatedParams.mainScreenFilled;
    bool shareScreenStarted = updatedParams.shareScreenStarted;
    String screenId = updatedParams.screenId;
    final List<Participant> participants = updatedParams.participants;
    final EventType eventType = updatedParams.eventType;
    final String meetingDisplayType = updatedParams.meetingDisplayType;
    final bool lockScreen = updatedParams.lockScreen;
    final bool firstAll = updatedParams.firstAll;
    List<Stream> oldAllStreams = updatedParams.oldAllStreams;
    String adminVidID = updatedParams.adminVidID;
    double mainHeightWidth = updatedParams.mainHeightWidth;
    final String member = updatedParams.member;
    List<Widget> audioOnlyStreams = updatedParams.audioOnlyStreams;
    final bool gotAllVids = updatedParams.gotAllVids;
    final bool deferReceive = updatedParams.deferReceive;
    final bool firstRound = updatedParams.firstRound;
    List<Stream> remoteScreenStream = updatedParams.remoteScreenStream;
    final String hostLabel = updatedParams.hostLabel;
    final bool whiteboardStarted = updatedParams.whiteboardStarted;
    final bool whiteboardEnded = updatedParams.whiteboardEnded;

    // Update functions
    final Function(bool) updateUpdateMainWindow =
        updatedParams.updateUpdateMainWindow;
    final Function(List<Stream>) updateAllAudioStreams =
        updatedParams.updateAllAudioStreams;
    final Function(List<Stream>) updateAllVideoStreams =
        updatedParams.updateAllVideoStreams;
    final Function(List<Stream>) updateStreamNames =
        updatedParams.updateStreamNames;
    final Function(List<Stream>) updateAudStreamNames =
        updatedParams.updateAudStreamNames;
    final Function(MediaStream) updateNStream = updatedParams.updateNStream;
    final Function(double) updateMainHeightWidth =
        updatedParams.updateMainHeightWidth;
    final Function(bool) updateLockScreen = updatedParams.updateLockScreen;
    final Function(bool) updateFirstAll = updatedParams.updateFirstAll;
    final Function(List<Stream>) updateRemoteScreenStream =
        updatedParams.updateRemoteScreenStream;
    final Function(List<Stream>) updateOldAllStreams =
        updatedParams.updateOldAllStreams;
    final Function(List<Widget>) updateAudioOnlyStreams =
        updatedParams.updateAudioOnlyStreams;
    final Function(bool) updateShareScreenStarted =
        updatedParams.updateShareScreenStarted;
    final Function(bool) updateGotAllVids = updatedParams.updateGotAllVids;
    final Function(String) updateScreenId = updatedParams.updateScreenId;
    final Function(bool) updateDeferReceive = updatedParams.updateDeferReceive;

    // Mediasfu functions
    final ReorderStreamsType reorderStreams = updatedParams.reorderStreams;
    final PrepopulateUserMediaType prepopulateUserMedia =
        updatedParams.prepopulateUserMedia;

    if (kind == 'audio') {
      // ----- Handling Audio Resumption -----

      // Find participant with audioID == remoteProducerId
      Participant? participant;
      try {
        participant =
            participants.firstWhere((p) => p.audioID == remoteProducerId);
      } catch (e) {
        participant = null;
      }

      String name = participant?.name ?? '';

      // If the participant is the host, no action is needed
      if (name == hostLabel) {
        return;
      }

      // Find any participant currently sharing the screen
      Participant? screenParticipantAlt;
      try {
        screenParticipantAlt = participants.firstWhere(
          (p) =>
              p.ScreenID != null &&
              p.ScreenOn == true &&
              p.ScreenID!.isNotEmpty,
        );
      } catch (e) {
        screenParticipantAlt = null;
      }

      if (screenParticipantAlt != null) {
        screenId = screenParticipantAlt.ScreenID!;
        updateScreenId(screenId);
        if (!shareScreenStarted) {
          updateShareScreenStarted(true);
        }
      } else if (whiteboardStarted && !whiteboardEnded) {
        // Whiteboard is active; no changes to screen sharing
      } else {
        // No screen sharing; reset screen ID and share screen status
        screenId = "";
        updateScreenId(screenId);
        updateShareScreenStarted(false);
      }

      // Update the main media stream
      final nStream = stream;
      updateNStream(nStream);

      // Create a MiniAudioPlayer widget
      final optionsMiniAudio = MiniAudioPlayerOptions(
        stream: nStream,
        consumer: consumer,
        remoteProducerId: remoteProducerId,
        parameters: updatedParams,
        miniAudioComponent: (props) => MiniAudio(
            options: MiniAudioOptions(
          name: name,
          showWaveform: true,
        )),
        miniAudioProps: {
          'customStyle': const {
            'backgroundColor': Color.fromARGB(255, 23, 23, 23),
          },
          'name': name,
          'showWaveform': true,
          'overlayPosition': 'topRight',
          'barColor': Colors.white,
          'textColor': Colors.white,
          'imageSource': 'https://mediasfu.com/images/logo192.png',
          'roundedImage': true,
          'imageStyle': const {},
        },
      );
      final Widget nTrack = MiniAudioPlayer(
        options: optionsMiniAudio,
      );

      // Add the MiniAudioPlayer to audio-only streams
      audioOnlyStreams.add(nTrack);
      updateAudioOnlyStreams(audioOnlyStreams);

      // Add the new audio stream to allAudioStreams
      allAudioStreams
          .add(Stream(producerId: remoteProducerId, stream: nStream));
      updateAllAudioStreams(allAudioStreams);

      if (name.isNotEmpty) {
        // Add to audStreamNames
        final newAudioStream = Stream.fromMap({
          'producerId': remoteProducerId,
          'name': name,
        });

        audStreamNames.add(newAudioStream);
        updateAudStreamNames(audStreamNames);

        // If the main screen is not filled and the participant is at level 2, prepopulate user media
        if (!mainScreenFilled && participant!.islevel == '2') {
          updateUpdateMainWindow(true);
          var paramsPrepopulate = updatedParams;
          paramsPrepopulate.updateAllAudioStreams(allAudioStreams);
          paramsPrepopulate.updateAudStreamNames(audStreamNames);

          final optionsPrepopulate = PrepopulateUserMediaOptions(
            name: hostLabel,
            parameters: paramsPrepopulate,
          );
          await prepopulateUserMedia(
            optionsPrepopulate,
          );
          updateUpdateMainWindow(false);
        }
      } else {
        return;
      }

      // Determine display type and update UI accordingly
      bool checker;
      bool altChecker = false;

      if (meetingDisplayType == 'video') {
        checker =
            participant!.name.isNotEmpty && participant.videoID.isNotEmpty;
      } else {
        checker = true;
        altChecker = true;
      }

      if (checker) {
        if (shareScreenStarted) {
          if (!altChecker) {
            // Reorder streams based on updated parameters
            final optionsReorder = ReorderStreamsOptions(
              parameters: updatedParams,
            );
            await reorderStreams(
              optionsReorder,
            );

            if (!kIsWeb) {
              await Future.delayed(const Duration(milliseconds: 1000));
              await reorderStreams(
                optionsReorder,
              );
            }
          }
        } else {
          if (altChecker && meetingDisplayType != 'video') {
            final optionsReorder = ReorderStreamsOptions(
              add: false,
              screenChanged: true,
              parameters: updatedParams,
            );
            await reorderStreams(
              optionsReorder,
            );
            if (!kIsWeb) {
              await Future.delayed(const Duration(milliseconds: 1000));
              await reorderStreams(
                optionsReorder,
              );
            }
          }
        }
      }
    } else if (kind == 'video') {
      // ----- Handling Video Resumption -----

      // Update the main media stream
      final nStream = stream;
      updateNStream(nStream);

      // Find any participant currently sharing the screen
      Participant? screenParticipantAlt;
      try {
        screenParticipantAlt = participants.firstWhere(
          (p) =>
              p.ScreenID != null &&
              p.ScreenOn == true &&
              p.ScreenID!.isNotEmpty,
        );
      } catch (e) {
        screenParticipantAlt = null;
      }

      if (screenParticipantAlt != null) {
        screenId = screenParticipantAlt.ScreenID!;
        updateScreenId(screenId);
        if (!shareScreenStarted) {
          shareScreenStarted = true;
          updateShareScreenStarted(true);
        }
      } else if (whiteboardStarted && !whiteboardEnded) {
        // Whiteboard is active; no changes to screen sharing
      } else {
        // No screen sharing; reset screen ID and share screen status
        screenId = "";
        updateScreenId(screenId);
        updateShareScreenStarted(false);
      }

      // Check if the resumed video is a screen share
      if (remoteProducerId == screenId) {
        // Manage screen sharing on the main screen
        updateUpdateMainWindow(true);
        final newRemoteScreen = Stream(
            producerId: remoteProducerId, stream: nStream, socket_: nsock);

        remoteScreenStream = [
          newRemoteScreen,
        ];
        updateRemoteScreenStream(remoteScreenStream);

        if (eventType == EventType.conference) {
          if (shareScreenStarted) {
            if (mainHeightWidth == 0) {
              updateMainHeightWidth(84);
            }
          } else {
            if (mainHeightWidth > 0) {
              updateMainHeightWidth(0);
            }
          }
        }

        if (!lockScreen) {
          final optionsPrepopulate = PrepopulateUserMediaOptions(
            name: hostLabel,
            parameters: updatedParams,
          );
          await prepopulateUserMedia(
            optionsPrepopulate,
          );
          final optionsReorder = ReorderStreamsOptions(
            add: false,
            screenChanged: true,
            parameters: updatedParams,
          );
          await reorderStreams(
            optionsReorder,
          );

          if (!kIsWeb) {
            await Future.delayed(const Duration(milliseconds: 1000));
            final optionsPrepopulate = PrepopulateUserMediaOptions(
              name: hostLabel,
              parameters: updatedParams,
            );
            final optionsReorder = ReorderStreamsOptions(
              add: false,
              screenChanged: true,
              parameters: updatedParams,
            );
            await prepopulateUserMedia(
              optionsPrepopulate,
            );
            await reorderStreams(
              optionsReorder,
            );
          }
        } else {
          if (!firstAll) {
            final optionsPrepopulate = PrepopulateUserMediaOptions(
              name: hostLabel,
              parameters: updatedParams,
            );
            final optionsReorder = ReorderStreamsOptions(
              add: false,
              screenChanged: true,
              parameters: updatedParams,
            );
            await prepopulateUserMedia(
              optionsPrepopulate,
            );
            await reorderStreams(
              optionsReorder,
            );

            if (!kIsWeb) {
              await Future.delayed(const Duration(milliseconds: 1000));
              await prepopulateUserMedia(
                optionsPrepopulate,
              );
              await reorderStreams(
                optionsReorder,
              );
            }
          }
        }

        // Update lock screen and firstAll flags
        updateLockScreen(true);
        updateFirstAll(true);
      } else {
        // Non-screen share video resumed

        // Find the participant associated with the resumed video
        Participant? participant;
        try {
          participant =
              participants.firstWhere((p) => p.videoID == remoteProducerId);
        } catch (e) {
          participant = null;
        }

        if (participant != null &&
            participant.name.isNotEmpty &&
            participant.name != hostLabel) {
          // Add the new video stream to allVideoStreams
          allVideoStreams.add(
            Stream(
                producerId: remoteProducerId, stream: nStream, socket_: nsock),
          );
          updateAllVideoStreams(allVideoStreams);
        }

        // Find the admin participant

        if (participant != null) {
          final String name = participant.name;
          // Add to streamNames
          final newStreamName = Stream(
            producerId: remoteProducerId,
            name: name,
          );
          streamNames.add(newStreamName);
          updateStreamNames(streamNames);
        }

        // If not screenshare, filter out admin streams
        if (!shareScreenStarted) {
          Participant? admin = participants.firstWhere(
            (p) => (p.isAdmin == true || p.isHost == true) && p.islevel == '2',
            orElse: () => Participant(
              audioID: '',
              videoID: '',
              name: '',
              isAdmin: false,
              islevel: '0',
            ),
          );

          if (admin.videoID.isNotEmpty) {
            final String adminVidID = admin.videoID;
            if (adminVidID.isNotEmpty) {
              // Backup oldAllStreams
              List<Stream> oldAllStreams_ = [];
              if (oldAllStreams.isNotEmpty) {
                oldAllStreams_ = oldAllStreams;
              }

              // Filter oldAllStreams for adminVidID
              oldAllStreams = allVideoStreams
                  .where((s) => s.producerId == adminVidID)
                  .toList();
              updateOldAllStreams(oldAllStreams);

              if (oldAllStreams.isEmpty) {
                oldAllStreams = oldAllStreams_;
                updateOldAllStreams(oldAllStreams);
              }

              // Remove adminVidID streams from allVideoStreams
              allVideoStreams = allVideoStreams
                  .where((s) => s.producerId != adminVidID)
                  .toList();
              updateAllVideoStreams(allVideoStreams);

              // If the resumed producer is the admin, update main window
              if (remoteProducerId == adminVidID) {
                updateUpdateMainWindow(true);
              }
            }

            // Update gotAllVids flag
            updateGotAllVids(true);
          }
        } else {
          // Check if the videoID is either that of the admin or that of the screen participant
          Participant? admin = participants.firstWhere(
            (p) => p.islevel == '2',
            orElse: () => Participant(
              audioID: '',
              videoID: '',
              name: '',
              isAdmin: false,
              islevel: '0',
            ),
          );

          Participant? screenParticipant = participants.firstWhere(
            (p) => p.ScreenID == screenId,
            orElse: () => Participant(
              audioID: '',
              videoID: '',
              name: '',
              isAdmin: false,
              islevel: '0',
            ),
          );

          String? adminVidID;
          if (admin.name.isNotEmpty) {
            adminVidID = admin.videoID;
          }

          String? screenParticipantVidID;
          if (screenParticipant.name.isNotEmpty) {
            screenParticipantVidID = screenParticipant.videoID;
          }

          if ((adminVidID != null && adminVidID.isNotEmpty) ||
              (screenParticipantVidID != null &&
                  screenParticipantVidID.isNotEmpty)) {
            if (adminVidID == remoteProducerId ||
                screenParticipantVidID == remoteProducerId) {
              final optionsReorder = ReorderStreamsOptions(
                parameters: updatedParams,
              );
              await reorderStreams(
                optionsReorder,
              );
              return;
            }
          }
        }

        // Update the UI based on lockScreen and shareScreenStarted flags
        if (lockScreen || shareScreenStarted) {
          updateDeferReceive(true);
          if (!firstAll) {
            final optionsReorder = ReorderStreamsOptions(
              add: false,
              screenChanged: true,
              parameters: updatedParams,
            );
            await reorderStreams(
              optionsReorder,
            );

            if (!kIsWeb) {
              await Future.delayed(const Duration(milliseconds: 1000));
              await reorderStreams(
                optionsReorder,
              );
            }
          }
        } else {
          await reorderStreams(
            ReorderStreamsOptions(
              parameters: updatedParams,
            ),
          );

          if (!kIsWeb) {
            await Future.delayed(const Duration(milliseconds: 1000));
            await reorderStreams(
              ReorderStreamsOptions(
                screenChanged: true,
                parameters: updatedParams,
              ),
            );
          }
        }
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - consumerResumed error: $error');
    }
    // Optionally, you can rethrow the error or handle it as needed
    // throw error;
  }
}
