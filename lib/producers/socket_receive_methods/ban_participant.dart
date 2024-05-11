/// Typedef for the function that reorders streams.
///
/// The [add] parameter indicates whether the streams should be added or removed.
/// The [screenChanged] parameter indicates whether the screen has changed.
/// The [parameters] parameter is a map of additional parameters.
typedef ReorderStreams = Future<void> Function({
  bool add,
  bool screenChanged,
  required Map<String, dynamic> parameters,
});

/// Typedef for the function that updates participants.
///
/// The [participants] parameter is a list of participants to be updated.
typedef UpdateParticipants = void Function(List<dynamic> participants);

/// Bans a participant from the active or display names array.
///
/// The [name] parameter is the name of the participant to be banned.
/// The [parameters] parameter is a map of additional parameters.
void banParticipant({
  required String name,
  required Map<String, dynamic> parameters,
}) {
  List<String> activeNames = parameters['activeNames'] ?? [];
  List<String> dispActiveNames =
      parameters['dispActiveNames'] ?? []; // display names
  List<dynamic> participants = parameters['participants'];
  UpdateParticipants updateParticipants = parameters['updateParticipants'];

  // mediasfu functions
  ReorderStreams reorderStreams = parameters['reorderStreams'];

  // Check if the participant is in the active or display names array
  if (activeNames.contains(name) || dispActiveNames.contains(name)) {
    // Filter out the banned participant from the participants array
    participants.removeWhere((participant) => participant['name'] == name);
    // Update the participants array
    updateParticipants(participants);
    // Reorder streams after participant removal
    reorderStreams(add: false, screenChanged: true, parameters: parameters);
  }
}
