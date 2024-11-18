import 'dart:async';
import '../../types/types.dart'
    show
        Participant,
        PrepopulateUserMediaType,
        ReorderStreamsType,
        ReUpdateInterParameters,
        ReUpdateInterType,
        ReorderStreamsParameters,
        PrepopulateUserMediaParameters,
        PrepopulateUserMediaOptions,
        ReUpdateInterOptions,
        ReorderStreamsOptions;

/// Defines the parameters required for pausing media of a producer.
abstract class ProducerMediaPausedParameters
    implements
        PrepopulateUserMediaParameters,
        ReorderStreamsParameters,
        ReUpdateInterParameters {
  final List<String> activeSounds;
  final String meetingDisplayType;
  final bool meetingVideoOptimized;
  final List<Participant> participants;
  final List<String> oldSoundIds;
  final bool shared;
  final bool shareScreenStarted;
  final bool updateMainWindow;
  final String hostLabel;
  final String islevel;

  // Callback functions
  final void Function(List<String>) updateActiveSounds;
  final void Function(bool) updateUpdateMainWindow;

  // mediasfu functions
  final ReorderStreamsType reorderStreams;
  final PrepopulateUserMediaType prepopulateUserMedia;
  final ReUpdateInterType reUpdateInter;

  /// Function to retrieve updated parameters
  final ProducerMediaPausedParameters Function() getUpdatedAllParams;

  ProducerMediaPausedParameters({
    required this.activeSounds,
    required this.meetingDisplayType,
    required this.meetingVideoOptimized,
    required this.participants,
    required this.oldSoundIds,
    required this.shared,
    required this.shareScreenStarted,
    required this.updateMainWindow,
    required this.hostLabel,
    required this.islevel,
    required this.updateActiveSounds,
    required this.updateUpdateMainWindow,
    required this.reorderStreams,
    required this.prepopulateUserMedia,
    required this.reUpdateInter,
    required this.getUpdatedAllParams,
  });

  // dynamic operator [](String key);
}

/// Encapsulates the options for pausing a producer's media.
class ProducerMediaPausedOptions {
  final String producerId;
  final String kind; // 'audio', 'video', 'screenshare', or 'screen'
  final String name;
  final ProducerMediaPausedParameters parameters;

  ProducerMediaPausedOptions({
    required this.producerId,
    required this.kind,
    required this.name,
    required this.parameters,
  });
}

typedef ProducerMediaPausedType = Future<void> Function(
    ProducerMediaPausedOptions options);

/// Pauses the media for a producer based on specified parameters.
///
/// This function handles media pausing operations and UI updates based on the media type,
/// participant properties, and meeting settings.
///
/// [options] - The `ProducerMediaPausedOptions` instance containing the producer's ID, media kind, name, and parameters.
///
/// Example:
/// ```dart
/// final options = ProducerMediaPausedOptions(
///   producerId: 'abc123',
///   kind: 'audio',
///   name: 'Participant1',
///   parameters: ProducerMediaPausedParameters(
///     activeSounds: [],
///     meetingDisplayType: 'media',
///     meetingVideoOptimized: false,
///     participants: [Participant(name: 'Participant1', islevel: '2', muted: true, videoID: null)],
///     oldSoundIds: ['Participant1'],
///     shared: false,
///     shareScreenStarted: false,
///     updateMainWindow: false,
///     hostLabel: 'Host',
///     islevel: '1',
///     updateActiveSounds: (sounds) => print("Active sounds updated: $sounds"),
///     updateUpdateMainWindow: (update) => print("Main window updated: $update"),
///     reorderStreams: (params) async => print("Reordered streams: $params"),
///     prepopulateUserMedia: (params) async => print("Prepopulated user media: $params"),
///     reUpdateInter: (params) async => print("Re-updated interface: $params"),
///     getUpdatedAllParams: () => ProducerMediaPausedParameters(...),
///   ),
/// );
///
/// await producerMediaPaused(options);
/// ```
Future<void> producerMediaPaused(ProducerMediaPausedOptions options) async {
  // Retrieve updated parameters if necessary
  final parameters = options.parameters.getUpdatedAllParams();

  final activeSounds = parameters.activeSounds;
  final meetingDisplayType = parameters.meetingDisplayType;
  final meetingVideoOptimized = parameters.meetingVideoOptimized;
  final participants = parameters.participants;
  final oldSoundIds = parameters.oldSoundIds;
  final shared = parameters.shared;
  final shareScreenStarted = parameters.shareScreenStarted;
  final hostLabel = parameters.hostLabel;
  final islevel = parameters.islevel;

  // Callback functions
  final updateActiveSounds = parameters.updateActiveSounds;
  final updateUpdateMainWindow = parameters.updateUpdateMainWindow;

  // mediasfu functions
  final reorderStreams = parameters.reorderStreams;
  final prepopulateUserMedia = parameters.prepopulateUserMedia;
  final reUpdateInter = parameters.reUpdateInter;

  // Iterate through participants and update UI based on media settings and participant state
  for (final participant in participants) {
    if (participant.muted!) {
      if (participant.islevel == '2' &&
          participant.videoID.isNotEmpty &&
          !shared &&
          !shareScreenStarted &&
          islevel != '2') {
        updateUpdateMainWindow(true);
        final optionsPrepopulate = PrepopulateUserMediaOptions(
          name: hostLabel,
          parameters: parameters,
        );
        await prepopulateUserMedia(optionsPrepopulate);
        updateUpdateMainWindow(false);
      }

      if (shareScreenStarted || shared) {
        if (activeSounds.contains(participant.name)) {
          activeSounds.remove(participant.name);
          updateActiveSounds(activeSounds);
        }

        final optionsReUpdate = ReUpdateInterOptions(
          name: participant.name,
          add: false,
          force: true,
          parameters: parameters,
        );
        await reUpdateInter(optionsReUpdate);
      }
    }
  }

  // Update UI based on display type and video optimization settings
  if (meetingDisplayType == 'media' ||
      (meetingDisplayType == 'video' && !meetingVideoOptimized)) {
    final participant = participants.firstWhere((p) => p.name == options.name,
        orElse: () => Participant(
            name: '', islevel: '', videoID: '', audioID: '', muted: false));
    final hasVideo = participant.videoID.isNotEmpty;

    if (!hasVideo && !(shareScreenStarted || shared)) {
      final optionsReorder = ReorderStreamsOptions(
        add: false,
        screenChanged: true,
        parameters: parameters,
      );
      await reorderStreams(
        optionsReorder,
      );
    }
  }

  // Handle audio-specific media pausing
  if (options.kind == 'audio') {
    final participant = participants.firstWhere(
      (p) => p.audioID == options.producerId || p.name == options.name,
      orElse: () => Participant(
          name: '', islevel: '', videoID: '', audioID: '', muted: false),
    );

    if (participant.name.isNotEmpty && oldSoundIds.contains(participant.name)) {
      final optionsReUpdate = ReUpdateInterOptions(
        name: participant.name,
        add: false,
        force: true,
        parameters: parameters,
      );
      await reUpdateInter(optionsReUpdate);
    }
  }
}
