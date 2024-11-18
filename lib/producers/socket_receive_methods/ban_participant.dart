import 'dart:async';
import '../../types/types.dart'
    show
        Participant,
        ReorderStreamsType,
        ReorderStreamsParameters,
        ReorderStreamsOptions;

/// Parameters for banning a participant, extending `ReorderStreamsParameters` and including
/// properties like active and display names, participants, and update and reorder functions.
abstract class BanParticipantParameters implements ReorderStreamsParameters {
  // Core properties as abstract getters
  List<String> get activeNames;
  List<String> get dispActiveNames;
  List<Participant> get participants;

  // Update function as an abstract getter
  void Function(List<Participant>) get updateParticipants;

  // Mediasfu function as an abstract getter
  ReorderStreamsType get reorderStreams;

  // Allows dynamic property access if needed
  // dynamic operator [](String key);
}

/// Options for banning a participant, including their name and the required parameters.
class BanParticipantOptions {
  final String name;
  final BanParticipantParameters parameters;

  BanParticipantOptions({
    required this.name,
    required this.parameters,
  });
}

typedef BanParticipantType = Future<void> Function(
    BanParticipantOptions options);

/// Bans a participant by removing them from the active and display names lists,
/// updating the participants list, and reordering the streams if necessary.
///
/// This function checks if the participant, identified by `name` in [options],
/// is present in either `activeNames` or `dispActiveNames` within the parameters.
/// If found, the participant is removed from `participants`, the updated list is
/// saved via `updateParticipants`, and the streams are reordered.
///
/// ### Example Usage:
/// ```dart
/// final options = BanParticipantOptions(
///   name: 'JohnDoe',
///   parameters: BanParticipantParameters(
///     activeNames: ['JohnDoe', 'JaneDoe'],
///     dispActiveNames: ['JohnDoe'],
///     participants: [Participant(name: 'JohnDoe'), Participant(name: 'JaneDoe')],
///     updateParticipants: (updatedList) {
///       print('Participants updated: $updatedList');
///     },
///     reorderStreams: (options) async {
///       print('Streams reordered with options: $options');
///     },
///   ),
/// );
///
/// await banParticipant(options);
/// ```
///
/// In this example:
/// - The function removes `JohnDoe` from `activeNames`, `dispActiveNames`, and `participants`.
/// - It updates the participants list and reorders streams to reflect the change.

Future<void> banParticipant(BanParticipantOptions options) async {
  final params = options.parameters;

  // Check if the participant is in the active or display names list
  if (params.activeNames.contains(options.name) ||
      params.dispActiveNames.contains(options.name)) {
    // Filter out the banned participant from the participants list
    params.participants
        .removeWhere((participant) => participant.name == options.name);

    // Update the participants list
    params.updateParticipants(params.participants);

    // Reorder streams after participant removal
    final optionsReorder = ReorderStreamsOptions(
      screenChanged: true,
      parameters: params,
    );
    await params.reorderStreams(optionsReorder);
  }
}
