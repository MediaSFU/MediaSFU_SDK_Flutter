import 'package:flutter/material.dart';
import 'dart:async';

/// AudioDecibelCheck - A widget for periodically checking audio decibel levels and updating UI.
///
/// This widget periodically checks the audio decibel levels and updates the UI accordingly,
/// such as animating or resetting the waveform display based on the audio intensity.
///
/// Required parameters:
/// - [animateWaveform]: A function to animate the audio waveform display.
/// - [resetWaveform]: A function to reset the audio waveform display.
/// - [name]: The name of the participant associated with the audio.
/// - [participant]: Information about the participant associated with the audio.
/// - [parameters]: Additional parameters for customizing the audio check behavior.
/// - [onShowWaveformChanged]: A callback function to handle changes in the waveform display state.
///
/// Example:
/// ```dart
/// AudioDecibelCheck(
///   animateWaveform: animateWaveformFunction,
///   resetWaveform: resetWaveformFunction,
///   name: 'John Doe',
///   participant: participantData,
///   parameters: additionalParameters,
///   onShowWaveformChanged: (showWaveform) {
///     // Logic to handle changes in waveform display state
///   },
/// );
/// ```

typedef GetUpdatedAllParams = Map<String, dynamic> Function();

class AudioDecibelCheck extends StatefulWidget {
  final Function animateWaveform;
  final Function resetWaveform;
  final String name;
  final Map<String, dynamic> participant;
  final Map<String, dynamic> parameters;
  final Function onShowWaveformChanged;

  const AudioDecibelCheck({
    super.key,
    required this.animateWaveform,
    required this.resetWaveform,
    required this.name,
    required this.participant,
    required this.parameters,
    required this.onShowWaveformChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AudioDecibelCheckState createState() => _AudioDecibelCheckState();
}

class _AudioDecibelCheckState extends State<AudioDecibelCheck> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _setupAudioDecibelCheck();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupAudioDecibelCheck();
  }

  void _setupAudioDecibelCheck() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkAudioDecibels();
    });
  }

  void _checkAudioDecibels() {
    // Get the updated parameters from the widget.
    var parameters = widget.parameters;
    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];

    parameters = getUpdatedAllParams();
    // final Function animateWaveform = widget.animateWaveform;
    // final Function resetWaveform = widget.resetWaveform;

    // Get the updated parameters from the getUpdatedAllParams function.
    final updatedParams = getUpdatedAllParams();

    final audioDecibels = updatedParams['audioDecibels'];
    final participants = updatedParams['participants'];

    // Find the existing audio entry and participant based on the name.
    final existingEntry = audioDecibels?.firstWhere(
      (entry) => entry['name'] == widget.name,
      orElse: () => null,
    );
    final participant = participants?.firstWhere(
      (participant) => participant['name'] == widget.name,
      orElse: () => null,
    );

    // Check conditions and animate/reset the waveform accordingly.
    if (existingEntry != null &&
        existingEntry['averageLoudness'] > 127.5 &&
        participant != null &&
        !participant['muted']) {
      widget.onShowWaveformChanged(true);
    } else {
      widget.onShowWaveformChanged(false);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return a SizedBox since this widget doesn't render anything directly.
    return const SizedBox();
  }
}
