import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../components/display_components/mini_card.dart';
import '../components/display_components/video_card.dart';
import '../components/display_components/audio_card.dart';
import '../types/types.dart'
    show
        Participant,
        Stream,
        UpdateMiniCardsGridType,
        EventType,
        UpdateMiniCardsGridOptions,
        UpdateMiniCardsGridParameters;

typedef UpdateOtherGridStreams = void Function(List<List<Widget>>);
typedef UpdateAddAltGrid = void Function(bool);

/// Parameters for adding videos to the grid, extending functionality from update mini-cards and audio card parameters.
///
/// This class defines the necessary parameters required to manage the addition of participant video, audio,
/// and mini-cards to the video grid, incorporating audio and video display options.
abstract class AddVideosGridParameters
    implements
        AudioCardParameters,
        VideoCardParameters,
        UpdateMiniCardsGridParameters {
  EventType get eventType;
  UpdateAddAltGrid get updateAddAltGrid;
  List<Participant> get refParticipants;
  String get islevel;
  bool get videoAlreadyOn;
  MediaStream? get localStreamVideo;
  bool get keepBackground;
  MediaStream? get virtualStream;
  bool get forceFullDisplay;
  String get member;
  List<List<Widget>> get otherGridStreams;
  UpdateOtherGridStreams get updateOtherGridStreams;
  UpdateMiniCardsGridType get updateMiniCardsGrid;

  // Method to retrieve updated parameters
  AddVideosGridParameters Function() get getUpdatedAllParams;

  // Dynamic access operator for additional properties
  // dynamic operator [](String key);
}

/// Options for adding participants and streams to the video grid.
///
/// `AddVideosGridOptions` provides configuration for managing the display of participants in both
/// the main and alternate grids, including the structure of the grid layout, participant streams,
/// and visibility of the alternate grid.
///
/// ### Example:
/// ```dart
/// final options = AddVideosGridOptions(
///   mainGridStreams: mainStreams,
///   altGridStreams: altStreams,
///   numRows: 3,
///   numCols: 2,
///   actualRows: 3,
///   lastRowCols: 1,
///   removeAltGrid: false,
///   parameters: gridParameters,
/// );
///
/// await addVideosGrid(options);
/// ```
class AddVideosGridOptions {
  final List<Stream> mainGridStreams;
  final List<Stream> altGridStreams;
  final int numRows;
  final int numCols;
  final int actualRows;
  final int lastRowCols;
  final bool removeAltGrid;
  final AddVideosGridParameters parameters;

  AddVideosGridOptions({
    required this.mainGridStreams,
    required this.altGridStreams,
    required this.numRows,
    required this.numCols,
    required this.actualRows,
    required this.lastRowCols,
    required this.removeAltGrid,
    required this.parameters,
  });
}

typedef AddVideosGridType = Future<void> Function(AddVideosGridOptions options);

/// Adds video and audio streams of participants to the main and alternate grids based on specified options.
///
/// This function manages the layout and styling of participant video, audio, and mini-cards in the main and alternate grids,
/// with customizations based on event type, background, and layout settings. It dynamically updates the UI by adding or removing
/// components in real-time, handling both the main and alternate grids.
///
/// - The function creates `VideoCard` widgets for participants with active video streams and `AudioCard` widgets for participants
///   with audio streams but without video.
/// - For participants who don’t have active audio or video, a `MiniCard` is generated, displaying participant initials.
///
/// This function is typically called when the user joins or leaves the room, changes display settings, or new streams become available.
///
/// ### Parameters:
/// - `options`: `AddVideosGridOptions` containing layout details like the number of rows and columns, lists of main and alternate
///   grid streams, flags for removing alternate grids, and other stream-related parameters.
///
/// ### Example:
/// ```dart
/// await addVideosGrid(AddVideosGridOptions(
///   mainGridStreams: [/* main stream participants */],
///   altGridStreams: [/* alternate stream participants */],
///   numRows: 2,
///   numCols: 2,
///   actualRows: 2,
///   lastRowCols: 1,
///   removeAltGrid: true,
///   parameters: gridParams,
/// ));
/// ```

Future<void> addVideosGrid(AddVideosGridOptions options) async {
  try {
    // Retrieve updated parameters
    AddVideosGridParameters parameters =
        options.parameters.getUpdatedAllParams();

    // Extract all necessary properties from parameters
    final eventType = parameters.eventType;
    final updateAddAltGrid = parameters.updateAddAltGrid;
    List<Participant> refParticipants = List.from(parameters.refParticipants);
    final islevel = parameters.islevel;
    final videoAlreadyOn = parameters.videoAlreadyOn;
    final localStreamVideo = parameters.localStreamVideo;
    final keepBackground = parameters.keepBackground;
    final virtualStream = parameters.virtualStream;
    final forceFullDisplay = parameters.forceFullDisplay;
    final member = parameters.member;
    List<List<Widget>> otherGridStreams =
        List.from(parameters.otherGridStreams);
    final updateOtherGridStreams = parameters.updateOtherGridStreams;
    final updateMiniCardsGrid = parameters.updateMiniCardsGrid;

    // Initialize new components
    List<List<Widget>> newComponents = [[], []];
    Stream participant;
    String remoteProducerId = "";

    // Update number to add based on mainGridStreams length
    int numToAdd = options.mainGridStreams.length;

    if (options.removeAltGrid) {
      updateAddAltGrid(false);
    }

    // Add participants to the main grid
    for (int i = 0; i < numToAdd; i++) {
      participant = options.mainGridStreams[i];
      remoteProducerId = participant.producerId;

      bool pseudoName = remoteProducerId.isEmpty;

      if (pseudoName) {
        remoteProducerId = participant.name ?? '';

        if (participant.audioID != null && participant.audioID!.isNotEmpty) {
          final actualParticipant = refParticipants.firstWhere(
            (obj) => obj.audioID == participant.audioID,
            orElse: () =>
                Participant(id: '', name: '', videoID: '', audioID: ''),
          );
          newComponents[0].add(AudioCard(
              options: AudioCardOptions(
            name: participant.name ?? "",
            barColor: Colors.red,
            textColor: Colors.white,
            customStyle: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: eventType != EventType.broadcast
                    ? Colors.black
                    : Colors.transparent,
                width: eventType != EventType.broadcast ? 2.0 : 0.0,
              ),
            ),
            controlsPosition: 'topLeft',
            infoPosition: 'topRight',
            roundedImage: true,
            parameters: parameters,
            backgroundColor: Colors.transparent,
            showControls: eventType != EventType.chat,
            participant: actualParticipant,
          )));
        } else {
          newComponents[0].add(
            MiniCard(
                options: MiniCardOptions(
              initials: participant.name ?? "",
              fontSize: 20,
              customStyle: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: eventType != EventType.broadcast
                      ? Colors.black
                      : Colors.transparent,
                  width: eventType != EventType.broadcast ? 2.0 : 0.0,
                ),
              ),
            )),
          );
        }
      } else {
        if (remoteProducerId == 'youyou' || remoteProducerId == 'youyouyou') {
          String name = 'You';
          if (islevel == '2' && eventType != EventType.chat) {
            name = 'You (Host)';
          }

          if (!videoAlreadyOn) {
            newComponents[0].add(
              MiniCard(
                  options: MiniCardOptions(
                initials: name,
                fontSize: 20,
                customStyle: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: eventType != EventType.broadcast
                        ? Colors.black
                        : Colors.transparent,
                    width: eventType != EventType.broadcast ? 2.0 : 0.0,
                  ),
                ),
              )),
            );
          } else {
            participant = Stream(
              id: 'youyouyou',
              stream: keepBackground && virtualStream != null
                  ? virtualStream
                  : localStreamVideo,
              name: 'youyouyou',
              producerId: 'youyouyou',
            );

            final actualParticipant = refParticipants.firstWhere(
              (obj) => obj.name == member,
              orElse: () =>
                  Participant(id: '', name: '', videoID: '', audioID: ''),
            );

            newComponents[0].add(
              VideoCard(
                  options: VideoCardOptions(
                videoStream: participant.stream,
                remoteProducerId: participant.stream?.id ?? '',
                eventType: eventType,
                forceFullDisplay:
                    eventType == EventType.webinar ? false : forceFullDisplay,
                participant: actualParticipant,
                backgroundColor: Colors.transparent,
                showControls: false,
                showInfo: false,
                name: participant.name ?? '',
                doMirror: true,
                parameters: parameters,
              )),
            );
          }
        } else {
          Participant? participant_ = refParticipants.firstWhere(
            (obj) => obj.videoID == remoteProducerId,
            orElse: () =>
                Participant(id: '', name: '', videoID: '', audioID: ''),
          );

          if (participant_.name.isNotEmpty) {
            newComponents[0].add(VideoCard(
              options: VideoCardOptions(
                videoStream: participant.stream,
                remoteProducerId: remoteProducerId,
                eventType: eventType,
                forceFullDisplay: forceFullDisplay,
                participant: participant_,
                backgroundColor: Colors.transparent,
                showControls: eventType != EventType.chat,
                showInfo: true,
                name: participant_.name,
                doMirror: false,
                parameters: parameters,
              ),
            ));
          }
        }
      }

      // Update grids at the end of the loop
      if (i == numToAdd - 1) {
        otherGridStreams[0] = List<Widget>.from(newComponents[0]);
        final optionsUpdate = UpdateMiniCardsGridOptions(
            rows: options.numRows,
            cols: options.numCols,
            defal: true,
            actualRows: options.actualRows,
            parameters: parameters);
        await updateMiniCardsGrid(
          optionsUpdate,
        );
        updateOtherGridStreams(otherGridStreams);
        await updateMiniCardsGrid(
          optionsUpdate,
        );
      }
    }

    // Handle the alternate grid streams
    if (!options.removeAltGrid) {
      for (int i = 0; i < options.altGridStreams.length; i++) {
        participant = options.altGridStreams[i];
        remoteProducerId = participant.producerId;

        bool pseudoName = remoteProducerId.isEmpty;

        if (pseudoName) {
          remoteProducerId = participant.name ?? '';

          if (participant.audioID != null && participant.audioID!.isNotEmpty) {
            final actualParticipant = refParticipants.firstWhere(
              (obj) => obj.audioID == participant.audioID,
              orElse: () =>
                  Participant(id: '', name: '', videoID: '', audioID: ''),
            );
            newComponents[1].add(
              AudioCard(
                  options: AudioCardOptions(
                name: participant.name ?? "",
                barColor: Colors.red,
                textColor: Colors.white,
                customStyle: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: eventType != EventType.broadcast
                        ? Colors.black
                        : Colors.transparent,
                    width: eventType != EventType.broadcast ? 2.0 : 0.0,
                  ),
                ),
                controlsPosition: 'topLeft',
                infoPosition: 'topRight',
                roundedImage: true,
                parameters: parameters,
                backgroundColor: Colors.transparent,
                showControls: eventType != EventType.chat,
                participant: actualParticipant,
              )),
            );
          } else {
            newComponents[1].add(
              MiniCard(
                  options: MiniCardOptions(
                initials: participant.name ?? "",
                fontSize: 20,
                customStyle: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: eventType != EventType.broadcast
                        ? Colors.black
                        : Colors.transparent,
                    width: eventType != EventType.broadcast ? 2.0 : 0.0,
                  ),
                ),
              )),
            );
          }
        } else {
          Participant? participant_ = refParticipants.firstWhere(
            (obj) => obj.videoID == remoteProducerId,
            orElse: () =>
                Participant(id: '', name: '', videoID: '', audioID: ''),
          );

          if (participant_.name.isNotEmpty) {
            newComponents[1].add(
              VideoCard(
                  options: VideoCardOptions(
                videoStream: participant.stream,
                remoteProducerId: remoteProducerId,
                eventType: eventType,
                forceFullDisplay: forceFullDisplay,
                participant: participant_,
                backgroundColor: Colors.transparent,
                showControls: eventType != EventType.chat,
                showInfo: true,
                name: participant_.name,
                doMirror: false,
                parameters: parameters,
              )),
            );
          }
        }

        // Update alternate grid at the end of the loop
        if (i == options.altGridStreams.length - 1) {
          otherGridStreams[1] = List<Widget>.from(newComponents[1]);

          final optionsUpdate = UpdateMiniCardsGridOptions(
              rows: options.numRows,
              cols: options.numCols,
              defal: false,
              actualRows: options.actualRows,
              parameters: parameters);

          await updateMiniCardsGrid(
            optionsUpdate,
          );
          updateOtherGridStreams(otherGridStreams);
          await updateMiniCardsGrid(
            optionsUpdate,
          );
        }
      }
    } else {
      // Remove alternate grid
      parameters.updateAddAltGrid(false);
      otherGridStreams[1] = <Widget>[]; // Clear the alternate grid

      final optionsUpdate = UpdateMiniCardsGridOptions(
          rows: 0,
          cols: 0,
          defal: false,
          actualRows: options.actualRows,
          parameters: parameters);
      await updateMiniCardsGrid(
        optionsUpdate,
      );
      updateOtherGridStreams(otherGridStreams);
      await updateMiniCardsGrid(
        optionsUpdate,
      );
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error in addVideosGrid: $error');
    }
  }
}
