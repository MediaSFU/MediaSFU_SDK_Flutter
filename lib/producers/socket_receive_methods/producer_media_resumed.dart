import 'dart:async';
import '../../types/types.dart'
    show
        Participant,
        PrepopulateUserMediaType,
        ReorderStreamsType,
        PrepopulateUserMediaParameters,
        ReorderStreamsParameters,
        PrepopulateUserMediaOptions,
        ReorderStreamsOptions;

abstract class ProducerMediaResumedParameters
    implements PrepopulateUserMediaParameters, ReorderStreamsParameters {
  String get meetingDisplayType;
  List<Participant> get participants;
  bool get shared;
  bool get shareScreenStarted;
  bool get mainScreenFilled;
  String get hostLabel;

  // Update function as an abstract getter
  void Function(bool) get updateUpdateMainWindow;

  // Mediasfu functions as abstract getters
  ReorderStreamsType get reorderStreams;
  PrepopulateUserMediaType get prepopulateUserMedia;

  // Method to retrieve updated parameters as an abstract getter
  ProducerMediaResumedParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

class ProducerMediaResumedOptions {
  final String name;
  final String kind;
  final ProducerMediaResumedParameters parameters;

  ProducerMediaResumedOptions({
    required this.name,
    required this.kind,
    required this.parameters,
  });
}

typedef ProducerMediaResumedType = Future<void> Function(
    ProducerMediaResumedOptions options);

/// Resumes media for a specified participant in a meeting.
///
/// This function manages media resumption for a participant by optimizing the display and handling any
/// prepopulated media or screen reordering as necessary. It first verifies the participant's status,
/// checks if the main screen is filled, and then performs actions based on the meeting display type and
/// participant's interest level.
///
/// - If the participant is a key user (e.g., a high-interest level) and the main screen is not filled,
///   the media is prepopulated, optimizing their display.
/// - If the display type is 'media' and the participant has no active video, the function reorders the
///   stream list to adjust the meeting view appropriately.
///
/// Parameters:
/// - [options] (`ProducerMediaResumedOptions`): Contains the participant's name, media type, and additional
///   configuration parameters for managing resumption.
///
/// Example usage:
/// ```dart
/// final parameters = ProducerMediaResumedParameters(
///   meetingDisplayType: "media",
///   participants: [Participant(name: "John Doe", islevel: "2", videoID: "vid123")],
///   shared: false,
///   shareScreenStarted: false,
///   mainScreenFilled: false,
///   hostLabel: "Host",
///   updateUpdateMainWindow: (update) => print("Main window updated: $update"),
///   reorderStreams: ({required bool add, required bool screenChanged, required Map<String, dynamic> parameters}) async {
///     print("Reordered streams");
///   },
///   prepopulateUserMedia: ({required String name, required Map<String, dynamic> parameters}) {
///     print("Prepopulating media for $name");
///   },
/// );
///
/// final options = ProducerMediaResumedOptions(
///   name: "John Doe",
///   kind: "audio",
///   parameters: parameters,
/// );
///
/// await producerMediaResumed(options);
/// ```

Future<void> producerMediaResumed(ProducerMediaResumedOptions options) async {
  final parameters = options.parameters;

  final participant = parameters.participants.firstWhere(
    (obj) => obj.name == options.name,
    orElse: () => Participant(name: '', islevel: '', videoID: '', audioID: ''),
  );

  if (participant.name.isNotEmpty &&
      !parameters.mainScreenFilled &&
      participant.islevel == '2') {
    parameters.updateUpdateMainWindow(true);
    final optionsPrepopulate = PrepopulateUserMediaOptions(
      name: parameters.hostLabel,
      parameters: parameters,
    );
    parameters.prepopulateUserMedia(optionsPrepopulate);
    parameters.updateUpdateMainWindow(false);
  }

  bool hasVideo = false;
  if (parameters.meetingDisplayType == 'media') {
    hasVideo = participant.videoID.isNotEmpty && participant.videoID != "";
    if (!hasVideo && !(parameters.shareScreenStarted || parameters.shared)) {
      final optionsReorder = ReorderStreamsOptions(
        add: false,
        screenChanged: true,
        parameters: parameters,
      );
      await parameters.reorderStreams(
        optionsReorder,
      );
    }
  }
}
