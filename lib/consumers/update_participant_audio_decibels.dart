typedef UpdateAudioDecibels = void Function(List<dynamic> audioDecibels);

/// Updates the participant's audio decibels.
///
/// This function updates the audio decibels for a participant by either adding a new entry or updating an existing entry in the `audioDecibels` list.
/// The `name` parameter specifies the name of the participant.
/// The `averageLoudness` parameter specifies the average loudness of the participant's audio.
/// The `parameters` parameter is a map that contains the `audioDecibels` list and the `updateAudioDecibels` function.
/// The `audioDecibels` list contains entries for each participant's audio decibels.
/// The `updateAudioDecibels` function is used to update the `audioDecibels` list.

void updateParticipantAudioDecibels({
  required String name,
  required double averageLoudness,
  required Map<String, dynamic> parameters,
}) {
  List<dynamic> audioDecibels = parameters['audioDecibels'];
  UpdateAudioDecibels updateAudioDecibels = parameters['updateAudioDecibels'];

  // Check if the entry already exists in audioDecibels
  int existingIndex =
      audioDecibels.indexWhere((entry) => entry['name'] == name);

  if (existingIndex != -1) {
    // Entry exists, update the averageLoudness
    audioDecibels[existingIndex]['averageLoudness'] = averageLoudness;
  } else {
    // Entry doesn't exist, add a new entry to audioDecibels
    audioDecibels.add({'name': name, 'averageLoudness': averageLoudness});
  }

  // Update the audioDecibels array
  updateAudioDecibels(audioDecibels);
}
