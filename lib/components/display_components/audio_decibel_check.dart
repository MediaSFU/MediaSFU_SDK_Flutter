import 'package:flutter/material.dart';
import 'dart:async';
import '../../types/types.dart' show AudioDecibels, Participant;

/// Abstract class for audio decibel check parameters.
abstract class AudioDecibelCheckParameters {
  List<AudioDecibels> get audioDecibels;
  List<Participant> get participants;

  AudioDecibelCheckParameters Function() get getUpdatedAllParams;
  dynamic Function() get getCurrentParams;

  // dynamic operator [](String key);
}

/// Configuration options for the `AudioDecibelCheck` widget.
///
/// Example:
/// ```dart
/// AudioDecibelCheck(
///   options: AudioDecibelCheckOptions(
///     animateWaveform: () => print("Animate waveform"),
///     resetWaveform: () => print("Reset waveform"),
///     name: "John Doe",
///     participant: participant,
///     parameters: parameters,
///     onShowWaveformChanged: (isVisible) => print("Show waveform: $isVisible"),
///   ),
/// );
/// ```

class AudioDecibelCheckOptions {
  final Function animateWaveform;
  final Function resetWaveform;
  final String name;
  final Participant participant;
  final AudioDecibelCheckParameters parameters;
  final Function onShowWaveformChanged;

  const AudioDecibelCheckOptions({
    required this.animateWaveform,
    required this.resetWaveform,
    required this.name,
    required this.participant,
    required this.parameters,
    required this.onShowWaveformChanged,
  });
}

typedef AudioDecibelCheckType = Future<void> Function({
  required AudioDecibelCheckOptions options,
});

/// AudioDecibelCheck - A widget that periodically checks audio decibel levels and adjusts waveform visibility.
///
/// Example:
/// ```dart
/// AudioDecibelCheck(
///   options: AudioDecibelCheckOptions(
///     animateWaveform: () => print("Waveform animation triggered"),
///     resetWaveform: () => print("Waveform animation reset"),
///     name: "ParticipantName",
///     participant: myParticipant,
///     parameters: myParameters,
///     onShowWaveformChanged: (visible) => print("Waveform visibility: $visible"),
///   ),
/// );
/// ```
class AudioDecibelCheck extends StatefulWidget {
  final AudioDecibelCheckOptions options;

  const AudioDecibelCheck({super.key, required this.options});

  @override
  // ignore: library_private_types_in_public_api
  _AudioDecibelCheckState createState() => _AudioDecibelCheckState();
}

class _AudioDecibelCheckState extends State<AudioDecibelCheck> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupAudioDecibelCheck();
  }

  void _setupAudioDecibelCheck() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkAudioDecibels();
    });
  }

  void _checkAudioDecibels() {
    final updatedParams = widget.options.parameters.getCurrentParams()
        as AudioDecibelCheckParameters;

    final audioDecibels = updatedParams.audioDecibels;
    final participants = updatedParams.participants;

    // Find the existing audio entry and participant based on the name.
    final existingEntry = audioDecibels.firstWhere(
      (entry) => entry.name == widget.options.name,
      orElse: () => AudioDecibels(name: '', averageLoudness: 0),
    );
    final participant = participants.firstWhere(
      (participant) => participant.name == widget.options.name,
      orElse: () =>
          Participant(name: '', audioID: '', videoID: '', isBanned: false),
    );

    // Check conditions and animate/reset the waveform accordingly.
    if (existingEntry.name.isNotEmpty &&
        existingEntry.averageLoudness > 127.5 &&
        participant.name.isNotEmpty &&
        !participant.muted!) {
      widget.options.onShowWaveformChanged(true);
    } else {
      widget.options.onShowWaveformChanged(false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return a SizedBox since this widget doesn't render anything directly.
    return const SizedBox();
  }
}
