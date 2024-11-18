import '../types/types.dart' show AudioDecibels;

/// Represents the options for updating the audio decibels of a participant.
class UpdateParticipantAudioDecibelsOptions {
  final String name;
  final double averageLoudness;
  final List<AudioDecibels> audioDecibels;
  final Function(List<AudioDecibels>) updateAudioDecibels;

  UpdateParticipantAudioDecibelsOptions({
    required this.name,
    required this.averageLoudness,
    required this.audioDecibels,
    required this.updateAudioDecibels,
  });
}

typedef UpdateParticipantAudioDecibelsType = void Function(
    UpdateParticipantAudioDecibelsOptions options);

/// Updates the audio decibels for a participant.
///
/// This function either updates an existing entry or adds a new entry for the participant's audio decibels in the `audioDecibels` list.
/// - [options]: An instance of [UpdateParticipantAudioDecibelsOptions] containing all the necessary parameters.
void updateParticipantAudioDecibels(
    UpdateParticipantAudioDecibelsOptions options) {
  // Check if the entry already exists in audioDecibels
  AudioDecibels existingEntry = options.audioDecibels.firstWhere(
    (entry) => entry.name == options.name,
    orElse: () => AudioDecibels(name: options.name, averageLoudness: 0),
  );

  if (options.audioDecibels.contains(existingEntry)) {
    // Entry exists, update the averageLoudness
    existingEntry.averageLoudness = options.averageLoudness;
  } else {
    // Entry doesn't exist, add a new entry to audioDecibels
    options.audioDecibels.add(AudioDecibels(
        name: options.name, averageLoudness: options.averageLoudness));
  }

  // Update the audioDecibels array
  options.updateAudioDecibels(options.audioDecibels);
}
