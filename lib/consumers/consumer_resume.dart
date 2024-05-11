// ignore_for_file: empty_catches

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../methods/utils/mini_audio_player/mini_audio_player.dart'
    show MiniAudioPlayer;
import '../components/display_components/mini_audio.dart' show MiniAudio;

/// Resumes the consumer and prepares it for use.
///
/// This function is responsible for resuming the consumer and updating its parameters based on the provided [stream], [kind], [remoteProducerId], [parameters], and [nsock].
/// It performs various operations such as updating the audio and video streams, updating the screen share status, creating a mini audio player track, and updating the UI.
///
/// Parameters:
/// - [stream]: The media stream for the consumer.
/// - [kind]: The kind of media (e.g., audio, video).
/// - [remoteProducerId]: The ID of the remote producer.
/// - [parameters]: A map containing various parameters related to the consumer.
/// - [nsock]: The socket for the consumer.
///
/// Returns: A [Future] that completes when the consumer has been resumed.

// Typedefs
typedef GetUpdatedAllparameters = Map<String, dynamic> Function();

typedef RemoteScreenStream = List<dynamic>;

typedef PrepopulateUserMedia = List<dynamic> Function(
    {required String name, required Map<String, dynamic> parameters});
typedef ReorderStreams = Future<void> Function(
    {bool add, bool screenChanged, required Map<String, dynamic> parameters});
typedef GetVideos = Future<void> Function(
    {required Map<String, dynamic> parameters});
typedef RePort = Future<void> Function(
    {bool restart, required Map<String, dynamic> parameters});
typedef UpdateMainWindowFunction = void Function(bool);
typedef UpdateActiveNamesFunction = void Function(List<String>);
typedef UpdateAllAudioStreamsFunction = void Function(List<dynamic>);
typedef UpdateAllVideoStreamsFunction = void Function(List<dynamic>);
typedef UpdateSharedFunction = void Function(bool);
typedef UpdateShareScreenStartedFunction = void Function(bool);
typedef UpdateUpdateMainWindowFunction = void Function(bool);
typedef UpdateNewLimitedStreamsFunction = void Function(List<dynamic>);
typedef UpdateNewLimitedStreamsIDsFunction = void Function(List<dynamic>);
typedef UpdateOldAllStreamsFunction = void Function(List<dynamic>);
typedef UpdateDeferReceiveFunction = void Function(bool);
typedef UpdateMainHeightWidthFunction = void Function(double);
typedef UpdateShareEndedFunction = void Function(bool);
typedef UpdateLockScreenFunction = void Function(bool);
typedef UpdateFirstAllFunction = void Function(bool);
typedef UpdateFirstRoundFunction = void Function(bool);
typedef UpdateGotAllVidsFunction = void Function(bool);
typedef UpdateEventTypeFunction = void Function(String);
typedef UpdateNStreamFunction = void Function(MediaStream);
typedef UpdateAudioOnlyStreamsFunction = void Function(List<dynamic>);
typedef UpdateStreamNamesFunction = void Function(List<dynamic>);
typedef UpdateAudStreamNamesFunction = void Function(List<dynamic>);
typedef UpdateRemoteScreenStreamFunction = void Function(List<dynamic>);
typedef UpdateScreenIdFunction = void Function(String);
typedef UpdateAdminIDStreamFunction = void Function(String);
typedef UpdateAdminNameStreamFunction = void Function(String);
typedef UpdateScreenShareIDStreamFunction = void Function(String);
typedef UpdateScreenShareNameStreamFunction = void Function(String);

Future<void> consumerResume({
  required MediaStream stream,
  required String kind,
  required String remoteProducerId,
  required Map<String, dynamic> parameters,
  required io.Socket nsock,
}) async {
  try {
    // Consumer resumed and ready to be used
    GetUpdatedAllparameters getUpdatedAllParams =
        parameters['getUpdatedAllParams'];
    parameters = getUpdatedAllParams();

    // Destructuring parameters
    MediaStream? nStream = parameters['nStream'];
    List<dynamic> allAudioStreams = parameters['allAudioStreams'];
    List<dynamic> allVideoStreams = parameters['allVideoStreams'];
    List<dynamic> streamNames = parameters['streamNames'];
    List<dynamic> audStreamNames = parameters['audStreamNames'];
    bool mainScreenFilled = parameters['mainScreenFilled'] ?? false;
    bool shareScreenStarted = parameters['shareScreenStarted'] ?? false;
    String screenId = parameters['screenId'];
    List<dynamic> participants = parameters['participants'];
    String eventType = parameters['eventType'];
    String meetingDisplayType = parameters['meetingDisplayType'];
    bool lockScreen = parameters['lockScreen'] ?? false;
    bool firstAll = parameters['firstAll'] ?? false;
    List<dynamic> oldAllStreams = parameters['oldAllStreams'];
    String adminIDStream = parameters['adminIDStream'];
    String adminNameStream = parameters['adminNameStream'];
    String screenShareIDStream = parameters['screenShareIDStream'];
    String screenShareNameStream = parameters['screenShareNameStream'];
    String adminVidID = parameters['adminVidID'];
    List<dynamic> audioOnlyStreams = parameters['audioOnlyStreams'];
    bool gotAllVids = parameters['gotAllVids'];
    bool deferReceive = parameters['deferReceive'];
    RemoteScreenStream? remoteScreenStream = parameters['remoteScreenStream'];
    String hostLabel = parameters['hostLabel'];
    bool updateMainWindow = parameters['updateMainWindow'];
    double mainHeightWidth = parameters['mainHeightWidth'];

    UpdateNStreamFunction updateNStream = parameters['updateNStream'];
    UpdateAudioOnlyStreamsFunction updateAudioOnlyStreams =
        parameters['updateAudioOnlyStreams'];
    UpdateAllAudioStreamsFunction updateAllAudioStreams =
        parameters['updateAllAudioStreams'];
    UpdateStreamNamesFunction updateStreamNames =
        parameters['updateStreamNames'];
    UpdateAudStreamNamesFunction updateAudStreamNames =
        parameters['updateAudStreamNames'];
    UpdateUpdateMainWindowFunction updateUpdateMainWindow =
        parameters['updateUpdateMainWindow'];
    UpdateAllVideoStreamsFunction updateAllVideoStreams =
        parameters['updateAllVideoStreams'];
    UpdateMainHeightWidthFunction updateMainHeightWidth =
        parameters['updateMainHeightWidth'];
    UpdateLockScreenFunction updateLockScreen = parameters['updateLockScreen'];
    UpdateFirstAllFunction updateFirstAll = parameters['updateFirstAll'];
    UpdateRemoteScreenStreamFunction updateRemoteScreenStream =
        parameters['updateRemoteScreenStream'];
    UpdateOldAllStreamsFunction updateOldAllStreams =
        parameters['updateOldAllStreams'];
    UpdateShareScreenStartedFunction updateShareScreenStarted =
        parameters['updateShareScreenStarted'];
    UpdateGotAllVidsFunction updateGotAllVids = parameters['updateGotAllVids'];
    UpdateScreenIdFunction updateScreenId = parameters['updateScreenId'];
    UpdateDeferReceiveFunction updateDeferReceive =
        parameters['updateDeferReceive'];
    UpdateAdminIDStreamFunction updateAdminIDStream =
        parameters['updateAdminIDStream'];
    UpdateAdminNameStreamFunction updateAdminNameStream =
        parameters['updateAdminNameStream'];
    UpdateScreenShareIDStreamFunction updateScreenShareIDStream =
        parameters['updateScreenShareIDStream'];
    UpdateScreenShareNameStreamFunction updateScreenShareNameStream =
        parameters['updateScreenShareNameStream'];

    // mediasfu functions
    ReorderStreams reorderStreams = parameters['reorderStreams'];
    PrepopulateUserMedia prepopulateUserMedia =
        parameters['prepopulateUserMedia'];

    if (kind == 'audio') {
      // Audio resumed

      // Check if the participant with audioID == remoteProducerId has a valid videoID
      dynamic participant = participants.firstWhere(
          (participant) => participant['audioID'] == remoteProducerId,
          orElse: () => null);
      String name = participant != null ? participant['name'] : '';

      if (name == hostLabel) {
        return;
      }

      // Find any participants with ScreenID not null and ScreenOn == true
      dynamic screenParticipantAlt = participants.firstWhere(
          (participant) =>
              participant['ScreenID'] != null &&
              participant['ScreenOn'] == true &&
              participant['ScreenID'] != "",
          orElse: () => null);
      if (screenParticipantAlt != null) {
        screenId = screenParticipantAlt['ScreenID'];
        updateScreenId(screenId);
        if (!shareScreenStarted) {
          shareScreenStarted = true;
          updateShareScreenStarted(shareScreenStarted);
        }
      } else {
        screenId = "";
        updateScreenId(screenId);
        updateShareScreenStarted(false);
      }

      // Media display and UI update to prioritize audio/video
      nStream = stream;
      updateNStream(nStream);

      // Create MiniAudioPlayer track
      Widget nTrack = MiniAudioPlayer(
        stream: nStream,
        remoteProducerId: remoteProducerId,
        parameters: parameters,
        MiniAudioComponent: (props) => MiniAudio(
          name: name,
          showWaveform: true,
        ),
        miniAudioProps: {
          'customStyle': const {
            'backgroundColor': Color.fromARGB(255, 23, 23, 23)
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

      // Add to audioOnlyStreams array
      audioOnlyStreams.add(nTrack);
      updateAudioOnlyStreams(audioOnlyStreams);

      // Add to allAudioStreams array; add producerId, stream
      allAudioStreams.add({'producerId': remoteProducerId, 'stream': nStream});
      updateAllAudioStreams(allAudioStreams);

      try {
        name = participant['name'];
      } catch (error) {}

      if (name != '') {
        // Add to audStreamNames array; add producerId, name
        audStreamNames.add({'producerId': remoteProducerId, 'name': name});
        updateAudStreamNames(audStreamNames);

        if (!mainScreenFilled && participant['islevel'] == '2') {
          updateMainWindow = true;
          updateUpdateMainWindow(updateMainWindow);
          prepopulateUserMedia(
            name: hostLabel,
            parameters: {
              ...parameters,
              'audStreamNames': audStreamNames,
              'allAudioStreams': allAudioStreams
            },
          );
          updateMainWindow = false;
          updateUpdateMainWindow(updateMainWindow);
        }
      } else {
        return;
      }

      // Checks for display type and updates the UI
      bool checker;
      bool altChecker = false;

      if (meetingDisplayType == 'video') {
        checker =
            participant['videoID'] != null && participant['videoID'] != '';
      } else {
        checker = true;
        altChecker = true;
      }

      if (checker) {
        if (shareScreenStarted || shareScreenStarted) {
          if (!altChecker) {
            await reorderStreams(parameters: {
              ...parameters,
              'audStreamNames': audStreamNames,
              'allAudioStreams': allAudioStreams
            });

            if (!kIsWeb) {
              await Future.delayed(const Duration(milliseconds: 1000));
              await reorderStreams(parameters: {
                ...parameters,
                'audStreamNames': audStreamNames,
                'allAudioStreams': allAudioStreams
              });
            }
          }
        } else {
          if (altChecker && meetingDisplayType != 'video') {
            await reorderStreams(add: false, screenChanged: true, parameters: {
              ...parameters,
              'audStreamNames': audStreamNames,
              'allAudioStreams': allAudioStreams
            });
            if (!kIsWeb) {
              await Future.delayed(const Duration(milliseconds: 1000));
              await reorderStreams(
                  add: false,
                  screenChanged: true,
                  parameters: {
                    ...parameters,
                    'audStreamNames': audStreamNames,
                    'allAudioStreams': allAudioStreams
                  });
            }
          }
        }
      }
    } else {
      // Video resumed
      nStream = stream;
      updateNStream(nStream);

      // Find any participants with ScreenID not null and ScreenOn == true
      dynamic screenParticipantAlt = participants.firstWhere(
          (participant) =>
              participant['ScreenID'] != null &&
              participant['ScreenOn'] == true &&
              participant['ScreenID'] != "",
          orElse: () => null);
      if (screenParticipantAlt != null) {
        screenId = screenParticipantAlt['ScreenID'];
        updateScreenId(screenId);
        if (!shareScreenStarted) {
          shareScreenStarted = true;
          updateShareScreenStarted(shareScreenStarted);
        }
      } else {
        screenId = "";
        updateScreenId(screenId);
        updateShareScreenStarted(false);
      }

      // Check for display type and update the UI
      if (remoteProducerId == screenId) {
        // Put on main screen for screen share
        updateMainWindow = true;
        updateUpdateMainWindow(updateMainWindow);
        remoteScreenStream = [
          {'producerId': remoteProducerId, 'stream': nStream}
        ];

        updateRemoteScreenStream(remoteScreenStream);

        if (eventType == 'conference') {
          if (shareScreenStarted || shareScreenStarted) {
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
          prepopulateUserMedia(name: hostLabel, parameters: parameters);
          await reorderStreams(add: false, screenChanged: true, parameters: {
            ...parameters,
            'remoteScreenStream': remoteScreenStream,
            'allVideoStreams': allVideoStreams
          });
          if (!kIsWeb) {
            await Future.delayed(const Duration(milliseconds: 1000));
            prepopulateUserMedia(name: hostLabel, parameters: parameters);
            await reorderStreams(add: false, screenChanged: true, parameters: {
              ...parameters,
              'remoteScreenStream': remoteScreenStream,
              'allVideoStreams': allVideoStreams
            });
          }
        } else {
          if (!firstAll) {
            prepopulateUserMedia(name: hostLabel, parameters: {
              ...parameters,
              'remoteScreenStream': remoteScreenStream,
              'allVideoStreams': allVideoStreams
            });
            await reorderStreams(add: false, screenChanged: true, parameters: {
              ...parameters,
              'remoteScreenStream': remoteScreenStream,
              'allVideoStreams': allVideoStreams
            });

            if (!kIsWeb) {
              await Future.delayed(const Duration(milliseconds: 1000));
              prepopulateUserMedia(name: hostLabel, parameters: {
                ...parameters,
                'remoteScreenStream': remoteScreenStream,
                'allVideoStreams': allVideoStreams
              });
              await reorderStreams(
                  add: false,
                  screenChanged: true,
                  parameters: {
                    ...parameters,
                    'remoteScreenStream': remoteScreenStream,
                    'allVideoStreams': allVideoStreams
                  });
            }
          }
        }

        lockScreen = true;
        updateLockScreen(lockScreen);
        firstAll = true;
        updateFirstAll(firstAll);
      } else {
        // Non-screen share video resumed

        // Operations to add video to the UI (either main screen or mini screen)

        // Get the name of the participant with videoID == remoteProducerId
        dynamic participant = participants.firstWhere(
            (participant) => participant['videoID'] == remoteProducerId,
            orElse: () => null);

        if (participant != null &&
            participant['name'] != null &&
            participant['name'] != '' &&
            participant['name'] != hostLabel) {
          allVideoStreams.add({
            'producerId': remoteProducerId,
            'stream': nStream,
            'socket_': nsock
          });
          updateAllVideoStreams(allVideoStreams);
        }

        // ignore: unused_local_variable
        dynamic admin = participants.firstWhere(
            (participant) =>
                participant['isAdmin'] == true && participant['islevel'] == '2',
            orElse: () => null);

        if (participant != null) {
          String name = participant['name'];
          streamNames.add({'producerId': remoteProducerId, 'name': name});
          updateStreamNames(streamNames);
        }

        // If not screenshare, filter out the stream that belongs to the participant with isAdmin = true and islevel == '2' (host)
        // Find the ID of the participant with isAdmin = true and islevel == '2'
        if (!shareScreenStarted) {
          dynamic admin = participants.firstWhere(
              (participant) =>
                  participant['isAdmin'] == true &&
                  participant['islevel'] == '2',
              orElse: () => null);
          // Remove video stream with producerId == admin.id
          // Get the videoID of the admin

          if (admin != null) {
            adminVidID = admin['videoID'];

            // ignore: unnecessary_null_comparison
            if (adminVidID != null && adminVidID != '') {
              List<dynamic> oldAllStreams_ = [];
              // Check if the length of allVideoStreams is > 0
              if (oldAllStreams.isNotEmpty) {
                oldAllStreams_ = oldAllStreams;
              }

              oldAllStreams = allVideoStreams
                  .where((streame) => streame['producerId'] == adminVidID)
                  .toList();
              updateOldAllStreams(oldAllStreams);

              if (oldAllStreams.isEmpty) {
                oldAllStreams = oldAllStreams_;
                updateOldAllStreams(oldAllStreams);
              }

              allVideoStreams = allVideoStreams
                  .where((streame) => streame['producerId'] != adminVidID)
                  .toList();
              updateAllVideoStreams(allVideoStreams);

              adminIDStream = adminVidID;
              adminNameStream = admin['name'];
              updateAdminIDStream(adminIDStream);
              updateAdminNameStream(adminNameStream);

              if (remoteProducerId == adminVidID) {
                updateMainWindow = true;
              }
            }

            gotAllVids = true;
            updateGotAllVids(gotAllVids);
          }
        } else {
          // Check if the videoID is either that of the admin or that of the screen participant
          dynamic admin = participants.firstWhere(
              (participant) => participant['islevel'] == '2',
              orElse: () => null);
          dynamic screenParticipant = participants.firstWhere(
              (participant) => participant['ScreenID'] == screenId,
              orElse: () => null);

          // See if producerId is that of admin videoID or screenParticipant videoID
          dynamic adminVidID;
          if (admin != null) {
            adminVidID = admin['videoID'];
          }

          dynamic screenParticipantVidID;
          if (screenParticipant != null) {
            screenParticipantVidID = screenParticipant['videoID'];
          }

          if (adminVidID != null && adminVidID != '') {
            adminIDStream = adminVidID;
            adminNameStream = admin['name'];
          }

          if (screenParticipantVidID != null && screenParticipantVidID != '') {
            screenShareIDStream = screenParticipantVidID;
            screenShareNameStream = screenParticipant['name'];
            updateScreenShareIDStream(screenShareIDStream);
            updateScreenShareNameStream(screenShareNameStream);
          }

          if ((adminVidID != null && adminVidID != '') ||
              (screenParticipantVidID != null &&
                  screenParticipantVidID != '')) {
            if (adminVidID == remoteProducerId ||
                screenParticipantVidID == remoteProducerId) {
              await reorderStreams(parameters: {
                ...parameters,
                'allVideoStreams': allVideoStreams
              });
              return;
            }
          }
        }

        // Update the UI
        if (lockScreen || shareScreenStarted) {
          deferReceive = true;
          updateDeferReceive(deferReceive);
          if (!firstAll) {
            await reorderStreams(add: false, screenChanged: true, parameters: {
              ...parameters,
              'allVideoStreams': allVideoStreams
            });

            if (!kIsWeb) {
              await Future.delayed(const Duration(milliseconds: 1000));
              await reorderStreams(
                  add: false,
                  screenChanged: true,
                  parameters: {
                    ...parameters,
                    'allVideoStreams': allVideoStreams
                  });
            }
          }
        } else {
          await reorderStreams(
              add: false,
              screenChanged: true,
              parameters: {...parameters, 'allVideoStreams': allVideoStreams});

          if (!kIsWeb) {
            await Future.delayed(const Duration(milliseconds: 1000));
            await reorderStreams(add: false, screenChanged: true, parameters: {
              ...parameters,
              'allVideoStreams': allVideoStreams
            });
          }
        }
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - consumerResumed error $error');
    }
    // throw error;
  }
}
