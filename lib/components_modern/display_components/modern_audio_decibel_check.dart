import 'dart:async';
import 'package:flutter/material.dart';
import '../../components/display_components/audio_decibel_check.dart'
    show AudioDecibelCheckParameters;
import '../../types/types.dart' show AudioDecibels, Participant;

/// Configuration options for the `ModernAudioDecibelCheck` widget.
///
/// This component monitors audio levels and triggers visual feedback
/// through callback functions. It's a utility widget that doesn't render
/// visible content but manages audio state detection.
/// Uses the same [AudioDecibelCheckParameters] as the original component.
class ModernAudioDecibelCheckOptions {
  final Function animateWaveform;
  final Function resetWaveform;
  final String name;
  final Participant participant;
  final AudioDecibelCheckParameters parameters;
  final Function onShowWaveformChanged;

  // Modern options for fine-tuning
  final Duration checkInterval;
  final double loudnessThreshold;
  final bool enableDebounce;
  final Duration debounceDelay;

  const ModernAudioDecibelCheckOptions({
    required this.animateWaveform,
    required this.resetWaveform,
    required this.name,
    required this.participant,
    required this.parameters,
    required this.onShowWaveformChanged,
    this.checkInterval = const Duration(seconds: 1),
    this.loudnessThreshold = 127.5,
    this.enableDebounce = true,
    this.debounceDelay = const Duration(milliseconds: 200),
  });
}

typedef ModernAudioDecibelCheckType = Future<void> Function({
  required ModernAudioDecibelCheckOptions options,
});

/// ModernAudioDecibelCheck - A utility widget that periodically checks audio
/// decibel levels and adjusts waveform visibility through callbacks.
///
/// This is a non-visual component that monitors audio levels and triggers
/// state changes in parent widgets. It uses optimized polling with optional
/// debouncing to prevent rapid state changes.
///
/// Features:
/// - Configurable check interval for polling audio levels
/// - Adjustable loudness threshold for triggering waveform animation
/// - Optional debouncing to smooth out rapid changes
/// - Automatic cleanup on widget disposal
///
/// Example:
/// ```dart
/// ModernAudioDecibelCheck(
///   options: ModernAudioDecibelCheckOptions(
///     animateWaveform: () => print("Waveform animation triggered"),
///     resetWaveform: () => print("Waveform animation reset"),
///     name: "ParticipantName",
///     participant: myParticipant,
///     parameters: myParameters,
///     onShowWaveformChanged: (visible) => setState(() => _showWaveform = visible),
///     checkInterval: Duration(milliseconds: 500),
///     loudnessThreshold: 130.0,
///   ),
/// );
/// ```
class ModernAudioDecibelCheck extends StatefulWidget {
  final ModernAudioDecibelCheckOptions options;

  const ModernAudioDecibelCheck({super.key, required this.options});

  @override
  State<ModernAudioDecibelCheck> createState() =>
      _ModernAudioDecibelCheckState();
}

class _ModernAudioDecibelCheckState extends State<ModernAudioDecibelCheck> {
  Timer? _timer;
  Timer? _debounceTimer;
  bool _lastWaveformState = false;

  @override
  void initState() {
    super.initState();
    _setupAudioDecibelCheck();
  }

  @override
  void didUpdateWidget(covariant ModernAudioDecibelCheck oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart timer if interval changed
    if (oldWidget.options.checkInterval != widget.options.checkInterval) {
      _timer?.cancel();
      _setupAudioDecibelCheck();
    }
  }

  void _setupAudioDecibelCheck() {
    _timer = Timer.periodic(widget.options.checkInterval, (timer) {
      _checkAudioDecibels();
    });
  }

  void _checkAudioDecibels() {
    // Get the updated parameters
    var parameters = widget.options.parameters;
    final updatedParams = parameters.getUpdatedAllParams();

    final audioDecibels = updatedParams.audioDecibels;
    final participants = updatedParams.participants;

    // Find the existing audio entry based on the name
    final existingEntry = audioDecibels.firstWhere(
      (entry) => entry.name == widget.options.name,
      orElse: () => AudioDecibels(name: '', averageLoudness: 0),
    );

    // Find the participant based on the name
    final participant = participants.firstWhere(
      (p) => p.name == widget.options.name,
      orElse: () =>
          Participant(name: '', audioID: '', videoID: '', isBanned: false),
    );

    // Determine if waveform should be shown
    final bool shouldShowWaveform = existingEntry.name.isNotEmpty &&
        existingEntry.averageLoudness > widget.options.loudnessThreshold &&
        participant.name.isNotEmpty &&
        !(participant.muted ?? true);

    // Apply debouncing if enabled
    if (widget.options.enableDebounce) {
      _applyDebouncedChange(shouldShowWaveform);
    } else {
      _applyChange(shouldShowWaveform);
    }
  }

  void _applyDebouncedChange(bool shouldShowWaveform) {
    // Only debounce if the state is changing
    if (shouldShowWaveform != _lastWaveformState) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.options.debounceDelay, () {
        _applyChange(shouldShowWaveform);
      });
    }
  }

  void _applyChange(bool shouldShowWaveform) {
    if (shouldShowWaveform != _lastWaveformState) {
      _lastWaveformState = shouldShowWaveform;
      widget.options.onShowWaveformChanged(shouldShowWaveform);

      if (shouldShowWaveform) {
        widget.options.animateWaveform();
      } else {
        widget.options.resetWaveform();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This is a utility widget - it doesn't render anything visible
    return const SizedBox.shrink();
  }
}
