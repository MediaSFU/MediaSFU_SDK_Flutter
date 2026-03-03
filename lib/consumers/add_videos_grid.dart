import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
// Original component imports (commented out for testing Modern versions):
// import '../components/display_components/mini_card.dart' hide MiniCardType;
// import '../components/display_components/video_card.dart' hide VideoCardType;
// import '../components/display_components/audio_card.dart' hide AudioCardType;

// Modern component imports (using same Options types):
import '../components_modern/display_components/modern_audio_card.dart'
    show ModernAudioCard;
import '../components_modern/display_components/modern_mini_card.dart'
    show ModernMiniCard;
import '../components_modern/display_components/modern_video_card.dart'
    show ModernVideoCard;
// Still need Options from original components:
import '../components/display_components/audio_card.dart'
    show AudioCardOptions, AudioCardParameters;
import '../components/display_components/mini_card.dart' show MiniCardOptions;
import '../components/display_components/video_card.dart'
    show VideoCardOptions, VideoCardParameters;
import '../types/types.dart'
    show
        Participant,
        Stream,
        UpdateMiniCardsGridType,
        EventType,
        UpdateMiniCardsGridOptions,
        UpdateMiniCardsGridParameters,
        LiveSubtitle;
import '../types/custom_builders.dart'
    show VideoCardType, AudioCardType, MiniCardType;

typedef UpdateOtherGridStreams = void Function(List<List<Widget>>);
typedef UpdateAddAltGrid = void Function(bool);

/// A derived ValueListenable that extracts a specific speaker's subtitle from the main map.
/// This allows video cards to reactively update when their speaker's subtitle changes.
class _SpeakerSubtitleNotifier extends ValueNotifier<LiveSubtitle?> {
  final ValueListenable<Map<String, LiveSubtitle>> _source;
  final String _speakerId;

  _SpeakerSubtitleNotifier(this._source, this._speakerId) : super(null) {
    _source.addListener(_update);
    _update();
  }

  void _update() {
    final newValue = _source.value[_speakerId];
    value = newValue;
  }

  @override
  void dispose() {
    _source.removeListener(_update);
    super.dispose();
  }
}

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
  bool get selfViewForceFull;
  String get member;
  List<List<Widget>> get otherGridStreams;
  UpdateOtherGridStreams get updateOtherGridStreams;
  UpdateMiniCardsGridType get updateMiniCardsGrid;
  void Function(bool) get updateSelfViewForceFull;

  // Custom component builders
  VideoCardType? get customVideoCard;
  AudioCardType? get customAudioCard;
  MiniCardType? get customMiniCard;

  // Theme support
  bool get isDarkModeValue;

  // Live subtitles support
  /// Whether to show subtitles on video cards
  bool get showSubtitlesOnCards;

  /// Reactive notifier for whether to show subtitles on cards
  ValueListenable<bool>? get showSubtitlesOnCardsNotifier;

  /// Per-speaker live subtitle data: Map<speakerId, LiveSubtitle>
  ValueListenable<Map<String, LiveSubtitle>> get liveSubtitles;

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

    // Extract custom component builders
    final customVideoCard = parameters.customVideoCard;
    final customAudioCard = parameters.customAudioCard;
    final customMiniCard = parameters.customMiniCard;

    // Extract theme value
    final isDarkModeValue = parameters.isDarkModeValue;

    // Extract subtitle settings
    final showSubtitlesOnCards = parameters.showSubtitlesOnCards;
    final showSubtitlesOnCardsNotifier =
        parameters.showSubtitlesOnCardsNotifier;
    final liveSubtitles = parameters.liveSubtitles;

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

          // Use custom AudioCard builder if available
          if (customAudioCard != null) {
            newComponents[0].add(customAudioCard(
              name: participant.name ?? "",
              barColor: true, // This maps to the red color
              textColor: Colors.white,
              imageSource: "", // You may need to add actual image source
              roundedImage: 1.0,
              imageStyle: Colors.transparent,
              parameters: parameters,
            ));
          } else {
            // Create per-speaker subtitle notifier for audio card
            // Try participant.id first, fall back to name for matching
            final subtitleKey = actualParticipant.id?.isNotEmpty == true
                ? actualParticipant.id!
                : actualParticipant.name;
            final audioSubtitleNotifier = _SpeakerSubtitleNotifier(
              liveSubtitles,
              subtitleKey,
            );
            newComponents[0].add(ModernAudioCard(
                options: AudioCardOptions(
              name: participant.name ?? "",
              barColor: Colors.red,
              textColor: isDarkModeValue ? Colors.white : Colors.black,
              customStyle: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: eventType != EventType.broadcast
                      ? (isDarkModeValue ? Colors.white24 : Colors.black)
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
              isDarkMode: isDarkModeValue,
              liveSubtitle: audioSubtitleNotifier,
              showSubtitles: showSubtitlesOnCards,
              showSubtitlesNotifier: showSubtitlesOnCardsNotifier,
            )));
          }
        } else {
          // Use custom MiniCard builder if available
          if (customMiniCard != null) {
            newComponents[0].add(customMiniCard(
              initials: participant.name ?? "",
              fontSize: "20",
              customStyle: false,
              name: participant.name ?? "",
              showVideoIcon: false,
              showAudioIcon: false,
              imageSource: "",
              roundedImage: 1.0,
              imageStyle: Colors.transparent,
              parameters: parameters,
            ));
          } else {
            newComponents[0].add(
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkModeValue
                        ? [const Color(0xFF1a1d2e), const Color(0xFF151827)]
                        : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: ModernMiniCard(
                      options: MiniCardOptions(
                    initials: participant.name ?? "",
                    fontSize: 20,
                    size: 80,
                    isDarkMode: isDarkModeValue,
                    roundedImage: true,
                    showBorder: eventType != EventType.broadcast,
                    showGradientBackground: true,
                  )),
                ),
              ),
            );
          }
        }
      } else {
        if (remoteProducerId == 'youyou' || remoteProducerId == 'youyouyou') {
          String name = 'You';
          if (islevel == '2' && eventType != EventType.chat) {
            name = 'You (Host)';
          }

          if (!videoAlreadyOn) {
            // Use custom MiniCard builder if available
            if (customMiniCard != null) {
              newComponents[0].add(customMiniCard(
                initials: name,
                fontSize: "20",
                customStyle: false,
                name: name,
                showVideoIcon: false,
                showAudioIcon: false,
                imageSource: "",
                roundedImage: 1.0,
                imageStyle: Colors.transparent,
                parameters: parameters,
              ));
            } else {
              newComponents[0].add(
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkModeValue
                          ? [const Color(0xFF1a1d2e), const Color(0xFF151827)]
                          : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: ModernMiniCard(
                        options: MiniCardOptions(
                      initials: name,
                      fontSize: 20,
                      size: 80,
                      isDarkMode: isDarkModeValue,
                      roundedImage: true,
                      showBorder: eventType != EventType.broadcast,
                      showGradientBackground: true,
                    )),
                  ),
                ),
              );
            }
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

            // Use custom VideoCard builder if available
            if (customVideoCard != null) {
              newComponents[0].add(customVideoCard(
                participant: actualParticipant,
                stream: participant,
                width: 100.0, // You may need to calculate actual width
                height: 100.0, // You may need to calculate actual height
                imageSize: null,
                doMirror: "true",
                showControls: false,
                showInfo: false,
                name: participant.name ?? '',
                backgroundColor: Colors.transparent,
                onVideoPress: null,
                parameters: parameters,
              ));
            } else {
              // For self-view: use selfViewForceFull to override forceFullDisplay
              // If selfViewForceFull is true, show full (forceFullDisplay=false)
              // If selfViewForceFull is false, use normal forceFullDisplay
              final selfViewForceFullDisplay = parameters.selfViewForceFull
                  ? false
                  : (eventType == EventType.webinar ? false : forceFullDisplay);

              newComponents[0].add(
                ModernVideoCard(
                    options: VideoCardOptions(
                  videoStream: participant.stream,
                  remoteProducerId: participant.stream?.id ?? '',
                  eventType: eventType,
                  forceFullDisplay: selfViewForceFullDisplay,
                  participant: actualParticipant,
                  backgroundColor: Colors.transparent,
                  showControls: false,
                  showInfo: false,
                  name: participant.name ?? '',
                  doMirror: true,
                  parameters: parameters,
                  isDarkMode: isDarkModeValue,
                  showSubtitles: showSubtitlesOnCards,
                  showSubtitlesNotifier: showSubtitlesOnCardsNotifier,
                  liveSubtitle: () {
                    final subtitleKey = actualParticipant.id?.isNotEmpty == true
                        ? actualParticipant.id!
                        : actualParticipant.name;
                    return _SpeakerSubtitleNotifier(liveSubtitles, subtitleKey);
                  }(),
                  onToggleSelfViewFit: () {
                    parameters
                        .updateSelfViewForceFull(!parameters.selfViewForceFull);
                  },
                )),
              );
            }
          }
        } else {
          Participant? participant_ = refParticipants.firstWhere(
            (obj) => obj.videoID == remoteProducerId,
            orElse: () =>
                Participant(id: '', name: '', videoID: '', audioID: ''),
          );

          if (participant_.name.isNotEmpty) {
            // Use custom VideoCard builder if available
            if (customVideoCard != null) {
              newComponents[0].add(customVideoCard(
                participant: participant_,
                stream: participant,
                width: 100.0, // You may need to calculate actual width
                height: 100.0, // You may need to calculate actual height
                imageSize: null,
                doMirror: "false",
                showControls: eventType != EventType.chat,
                showInfo: true,
                name: participant_.name,
                backgroundColor: Colors.transparent,
                onVideoPress: null,
                parameters: parameters,
              ));
            } else {
              newComponents[0].add(ModernVideoCard(
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
                  isDarkMode: isDarkModeValue,
                  showSubtitles: showSubtitlesOnCards,
                  showSubtitlesNotifier: showSubtitlesOnCardsNotifier,
                  liveSubtitle: () {
                    final subtitleKey = participant_.id?.isNotEmpty == true
                        ? participant_.id!
                        : participant_.name;
                    return _SpeakerSubtitleNotifier(liveSubtitles, subtitleKey);
                  }(),
                ),
              ));
            }
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

            // Use custom AudioCard builder if available
            if (customAudioCard != null) {
              newComponents[1].add(customAudioCard(
                name: participant.name ?? "",
                barColor: true, // This maps to the red color
                textColor: Colors.white,
                imageSource: "", // You may need to add actual image source
                roundedImage: 1.0,
                imageStyle: Colors.transparent,
                parameters: parameters,
              ));
            } else {
              // Create per-speaker subtitle notifier for audio card
              final subtitleKey = actualParticipant.id?.isNotEmpty == true
                  ? actualParticipant.id!
                  : actualParticipant.name;
              final audioSubtitleNotifier2 = _SpeakerSubtitleNotifier(
                liveSubtitles,
                subtitleKey,
              );
              newComponents[1].add(
                ModernAudioCard(
                    options: AudioCardOptions(
                  name: participant.name ?? "",
                  barColor: Colors.red,
                  textColor: isDarkModeValue ? Colors.white : Colors.black,
                  customStyle: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: eventType != EventType.broadcast
                          ? (isDarkModeValue ? Colors.white24 : Colors.black)
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
                  isDarkMode: isDarkModeValue,
                  liveSubtitle: audioSubtitleNotifier2,
                  showSubtitles: showSubtitlesOnCards,
                  showSubtitlesNotifier: showSubtitlesOnCardsNotifier,
                )),
              );
            }
          } else {
            // Use custom MiniCard builder if available
            if (customMiniCard != null) {
              newComponents[1].add(customMiniCard(
                initials: participant.name ?? "",
                fontSize: "20",
                customStyle: false,
                name: participant.name ?? "",
                showVideoIcon: false,
                showAudioIcon: false,
                imageSource: "",
                roundedImage: 1.0,
                imageStyle: Colors.transparent,
                parameters: parameters,
              ));
            } else {
              newComponents[1].add(
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkModeValue
                          ? [const Color(0xFF1a1d2e), const Color(0xFF151827)]
                          : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: ModernMiniCard(
                        options: MiniCardOptions(
                      initials: participant.name ?? "",
                      fontSize: 20,
                      size: 80,
                      isDarkMode: isDarkModeValue,
                      roundedImage: true,
                      showBorder: eventType != EventType.broadcast,
                      showGradientBackground: true,
                    )),
                  ),
                ),
              );
            }
          }
        } else {
          Participant? participant_ = refParticipants.firstWhere(
            (obj) => obj.videoID == remoteProducerId,
            orElse: () =>
                Participant(id: '', name: '', videoID: '', audioID: ''),
          );

          if (participant_.name.isNotEmpty) {
            // Use custom VideoCard builder if available
            if (customVideoCard != null) {
              newComponents[1].add(customVideoCard(
                participant: participant_,
                stream: participant,
                width: 100.0, // You may need to calculate actual width
                height: 100.0, // You may need to calculate actual height
                imageSize: null,
                doMirror: "false",
                showControls: eventType != EventType.chat,
                showInfo: true,
                name: participant_.name,
                backgroundColor: Colors.transparent,
                onVideoPress: null,
                parameters: parameters,
              ));
            } else {
              newComponents[1].add(
                ModernVideoCard(
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
                  isDarkMode: isDarkModeValue,
                  showSubtitles: showSubtitlesOnCards,
                  showSubtitlesNotifier: showSubtitlesOnCardsNotifier,
                  liveSubtitle: () {
                    final subtitleKey = participant_.id?.isNotEmpty == true
                        ? participant_.id!
                        : participant_.name;
                    return _SpeakerSubtitleNotifier(liveSubtitles, subtitleKey);
                  }(),
                )),
              );
            }
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
