import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../components/display_components/mini_card.dart' show MiniCard;
import '../components/display_components/video_card.dart' show VideoCard;
import '../components/display_components/audio_card.dart' show AudioCard;

/// Adds video components to the main and alternate video grids based on the provided parameters.
/// Returns a Future that completes once the operation is complete.
///
/// Parameters:
/// - mainGridStreams: A list of dynamic objects representing the main video grid streams.
/// - altGridStreams: A list of dynamic objects representing the alternate video grid streams.
/// - numtoadd: The number of videos to add.
/// - numRows: The number of rows in the grid.
/// - numCols: The number of columns in the grid.
/// - remainingVideos: The number of remaining videos.
/// - actualRows: The actual number of rows in the grid.
/// - lastrowcols: The number of columns in the last row of the grid.
/// - removeAltGrid: A boolean value indicating whether to remove the alternate video grid.
/// - ind: The index of the grid.
/// - forChat: A boolean value indicating whether the videos are for chat.
/// - forChatMini: A boolean value indicating whether the videos are for mini chat.
/// - forChatCard: A dynamic object representing the chat card.
/// - forChatID: The ID of the chat.
/// - parameters: A map of additional parameters.
///
/// Throws:
/// - Exception: If an error occurs during the operation.
///
/// Example usage:
/// ```dart
/// await addVideosGrid(
///   mainGridStreams: mainGridStreams,
///   altGridStreams: altGridStreams,
///   numtoadd: 4,
///   numRows: 2,
///   numCols: 2,
///   remainingVideos: 0,
///   actualRows: 2,
///   lastrowcols: 2,
///   removeAltGrid: false,
///   ind: 0,
///   forChat: false,
///   forChatMini: false,
///   forChatCard: null,
///   forChatID: null,
///   parameters: {},
/// );
/// ```

typedef GetUpdatedAllParams = Map<String, dynamic> Function();

typedef UpdateMiniCardsGrid = Future<void> Function(
    {required int rows,
    required int cols,
    bool defal,
    int actualRows,
    int ind,
    required Map<String, dynamic> parameters});

/// Adds video components to the main and alternate video grids based on the provided parameters.
/// Returns a Future that completes once the operation is complete.
Future<void> addVideosGrid({
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
  bool forChat = false,
  bool forChatMini = false,
  dynamic forChatCard,
  String? forChatID,
  required Map<String, dynamic> parameters,
}) async {
  try {
    // Destructure parameters
    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
    parameters = getUpdatedAllParams();

    List<dynamic> refParticipants = parameters['refParticipants'];
    dynamic localStreamVideo = parameters['localStreamVideo'];
    String eventType = parameters['eventType'];
    String islevel = parameters['islevel'];
    bool videoAlreadyOn = parameters['videoAlreadyOn'];
    bool forceFullDisplay = parameters['forceFullDisplay'];
    List<dynamic> otherGridStreams = parameters['otherGridStreams'];

    // Functions update
    void Function(List<dynamic>) updateOtherGridStreams =
        parameters['updateOtherGridStreams'];
    void Function(bool) updateAddAltGrid = parameters['updateAddAltGrid'];

    // mediasfu functions
    UpdateMiniCardsGrid updateMiniCardsGrid = parameters['updateMiniCardsGrid'];

    String name;

    // Function to add videos to the grid
    List<List<Widget>> newComponents = [[], []];

    if (removeAltGrid) {
      updateAddAltGrid(false);
    }

    // Take the first numtoadd participants with video on - perfect fit
    for (int i = 0; i < numtoadd; i++) {
      dynamic participant = mainGridStreams[i];
      String? remoteProducerId = participant['producerId'];

      bool pseudoName;

      // Check if there is a 'name' property in the participant object and if it is null
      if (participant.containsKey('producerId') &&
          participant['producerId'] != null &&
          participant['producerId'] != "") {
        // Actual video
        pseudoName = false;
      } else {
        pseudoName = true;
      }

      if (pseudoName) {
        // Pseudo name
        remoteProducerId = participant['name'];

        if (participant.containsKey('audioID') &&
            participant['audioID'] != null &&
            participant['audioID'] != "") {
          newComponents[0].add(AudioCard(
            name: participant['name'],
            barColor: const Color.fromARGB(255, 248, 13, 13),
            textColor: const Color.fromARGB(255, 15, 14, 14),
            customStyle: const BoxDecoration(
                // backgroundColor: Colors.transparent,
                ),
            controlsPosition: 'topLeft',
            infoPosition: 'topRight',
            roundedImage: true,
            parameters: parameters,
            participant: participant,
          ));
        } else {
          newComponents[0].add(MiniCard(
            initials: participant['name'],
            fontSize: 18,
            customStyle: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
            ),
          ));
        }
      } else {
        // Actual video
        dynamic participant_;
        if (remoteProducerId == 'youyou' || remoteProducerId == 'youyouyou') {
          if (!videoAlreadyOn) {
            name = 'You';
            if (islevel == '2' && eventType != 'chat') {
              name = 'You (Host)';
            }
            newComponents[0].add(MiniCard(
              initials: name,
              fontSize: 18,
              customStyle: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
            ));
          } else {
            participant = {
              'id': 'youyouyou',
              'stream': localStreamVideo,
              'name': 'youyouyou'
            };
            participant_ = {
              'id': 'youyou',
              'videoID': 'youyou',
              'name': 'youyouyou',
              'stream': localStreamVideo
            };

            participant['muted'] = true;
            remoteProducerId = 'youyouyou';
            newComponents[0].add(VideoCard(
              videoStream: localStreamVideo,
              remoteProducerId:
                  localStreamVideo != null ? localStreamVideo!.id : 'youyou',
              eventType: eventType,
              forceFullDisplay:
                  eventType == 'webinar' ? false : forceFullDisplay,
              participant: participant,
              backgroundColor: Colors.transparent,
              showControls: false,
              showInfo: false,
              name: participant['name'],
              doMirror: true,
              parameters: parameters,
            ));
          }
        } else {
          participant_ = refParticipants.firstWhere(
              (obj) => obj['videoID'] == remoteProducerId,
              orElse: () => null);
          if (participant_ != null) {
            newComponents[0].add(VideoCard(
              videoStream: participant['stream'],
              remoteProducerId: remoteProducerId,
              eventType: eventType,
              forceFullDisplay: forceFullDisplay,
              participant: participant_,
              backgroundColor: Colors.transparent,
              showControls: true,
              showInfo: true,
              name: participant_['name'],
              doMirror: false,
              parameters: parameters,
            ));
          }
        }
      }

      if (i == numtoadd - 1) {
        otherGridStreams[0] = List<Widget>.from(newComponents[0]);
        await updateMiniCardsGrid(
            rows: numRows,
            cols: numCols,
            defal: true,
            actualRows: actualRows,
            ind: ind,
            parameters: parameters);
        updateOtherGridStreams(otherGridStreams);
        await updateMiniCardsGrid(
            rows: numRows,
            cols: numCols,
            defal: true,
            actualRows: actualRows,
            ind: ind,
            parameters: parameters);
      }
    }

    // If we have more than 4 videos, we need to add a new row
    numtoadd = altGridStreams.length;

    if (!removeAltGrid) {
      for (int i = 0; i < numtoadd; i++) {
        dynamic participant = altGridStreams[i];
        String? remoteProducerId = participant['producerId'];
        bool pseudoName;
        dynamic participant_;

        // Check if there is a 'name' property in the participant object and if it is null
        if (participant.containsKey('producerId') &&
            participant['producerId'] != null &&
            participant['producerId'] != "") {
          // Actual video
          pseudoName = false;
        } else {
          pseudoName = true;
        }

        if (pseudoName) {
          // Pseudo name
          participant_ = participant;
          remoteProducerId = participant['name'];

          if (participant.containsKey('audioID') &&
              participant['audioID'] != null &&
              participant['audioID'] != "") {
            newComponents[1].add(AudioCard(
              name: participant['name'],
              barColor: const Color.fromARGB(255, 247, 17, 17),
              textColor: const Color.fromARGB(255, 11, 11, 11),
              customStyle: const BoxDecoration(),
              controlsPosition: 'topLeft',
              infoPosition: 'topRight',
              roundedImage: true,
              parameters: parameters,
              participant: participant,
            ));
          } else {
            newComponents[1].add(MiniCard(
              initials: participant['name'],
              fontSize: 18,
              customStyle: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
            ));
          }
        } else {
          // Actual video
          participant_ = refParticipants.firstWhere(
              (obj) => obj['videoID'] == remoteProducerId,
              orElse: () => null);
          if (participant_ != null) {
            newComponents[1].add(VideoCard(
              videoStream: participant['stream'],
              remoteProducerId: remoteProducerId,
              eventType: eventType,
              forceFullDisplay: forceFullDisplay,
              participant: participant_,
              backgroundColor: Colors.transparent,
              showControls: true,
              showInfo: true,
              name: participant_['name'],
              doMirror: false,
              parameters: parameters,
            ));
          }
        }

        // If is the last one, updateMiniCardsGrid(activeVideos); compare with actives-numtoadd
        if (i == numtoadd - 1) {
          otherGridStreams[1] = List<Widget>.from(newComponents[1]);
          await updateMiniCardsGrid(
              rows: 1,
              cols: lastrowcols,
              defal: false,
              actualRows: actualRows,
              ind: ind,
              parameters: parameters);
          updateOtherGridStreams(otherGridStreams);
          await updateMiniCardsGrid(
              rows: 1,
              cols: lastrowcols,
              defal: false,
              actualRows: actualRows,
              ind: ind,
              parameters: parameters);
        }
      }
    } else {
      updateAddAltGrid(false);
      otherGridStreams[1] = <Widget>[]; // Clear the alternate grid
      await updateMiniCardsGrid(
          rows: 0,
          cols: 0,
          defal: false,
          actualRows: actualRows,
          ind: ind,
          parameters: parameters);
      updateOtherGridStreams(otherGridStreams);
      await updateMiniCardsGrid(
          rows: 0,
          cols: 0,
          defal: false,
          actualRows: actualRows,
          ind: ind,
          parameters: parameters);
    }
  } catch (error) {
    if (kDebugMode) {
      // print('Error in addVideosGrid: $error');
    }
  }
}
