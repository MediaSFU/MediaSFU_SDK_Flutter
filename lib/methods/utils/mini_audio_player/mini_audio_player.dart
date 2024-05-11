// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';

/// A widget that displays a mini audio player with video and audio streams.
///
/// The [MiniAudioPlayer] widget is used to render a mini audio player in a Flutter application.
/// It supports displaying a video stream using the [RTCVideoRenderer] and an audio waveform using
/// a custom [MiniAudioComponent]. The widget also provides functionality for muting/unmuting the audio,
/// updating the active sounds, and updating the participant audio decibels.
///
/// The [MiniAudioPlayer] widget requires a [MediaStream] for the video stream, a [remoteProducerId]
/// for identifying the remote producer, a [parameters] map for passing additional parameters,
/// a [MiniAudioComponent] function for rendering the audio waveform, and optional [miniAudioProps]
/// for passing additional props to the [MiniAudioComponent].
///
/// Example usage:
///
/// ```dart
/// MiniAudioPlayer(
///   stream: mediaStream,
///   remoteProducerId: 'remoteProducerId',
///   parameters: {
///     'reUpdateInter': reUpdateInter,
///     'getUpdatedAllParams': getUpdatedAllParams,
///     'meetingDisplayType': 'video',
///     // Add other parameters as needed
///   },
///   MiniAudioComponent: (props) {
///     return CustomMiniAudioComponent(
///       showWaveform: props['showWaveform'],
///       visible: props['visible'],
///       // Add other props as needed
///     );
///   },
///   miniAudioProps: {
///     'customProp': 'value',
///   },
/// )
/// ```

typedef UpdateActiveSounds = void Function(List<String> activeSounds);
typedef ReUpdateInter = Future<void> Function({
  required String name,
  bool add,
  bool force,
  double average,
  required Map<String, dynamic> parameters,
});
typedef UpdateParticipantAudioDecibels = void Function({
  required String name,
  required double averageLoudness,
  required Map<String, dynamic> parameters,
});
typedef GetUpdatedAllParams = Map<String, dynamic> Function();

class MiniAudioPlayer extends StatefulWidget {
  final MediaStream? stream;
  final String? remoteProducerId;
  final Map<String, dynamic> parameters;
  final Function(dynamic)? MiniAudioComponent; // Update to accept a function
  final Map<String, dynamic>? miniAudioProps;

  const MiniAudioPlayer({
    super.key,
    required this.stream,
    required this.remoteProducerId,
    required this.parameters,
    required this.MiniAudioComponent,
    required this.miniAudioProps,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MiniAudioPlayerState createState() => _MiniAudioPlayerState();
}

class _MiniAudioPlayerState extends State<MiniAudioPlayer> {
  late bool showWaveModal;
  late bool isMuted;
  late bool autoWaveCheck;
  late List<String> activeSounds;
  late RTCVideoRenderer _rtcVideoRenderer;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    showWaveModal = false;
    isMuted = false;
    autoWaveCheck = false;
    activeSounds = [];
    _rtcVideoRenderer = RTCVideoRenderer();
    _initRenderers();
    initializeAudioAnalysis();
  }

  @override
  void dispose() {
    _rtcVideoRenderer.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _initRenderers() async {
    await _rtcVideoRenderer.initialize();
    if (widget.stream != null) {
      _rtcVideoRenderer.srcObject = widget.stream!;
    }
  }

  void initializeAudioAnalysis() {
    if (widget.stream != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        const averageLoudness =
            127.75; // Get the average loudness of the audio stream

        ReUpdateInter reUpdateInter = widget.parameters['reUpdateInter'];

        GetUpdatedAllParams getUpdatedAllParams =
            widget.parameters['getUpdatedAllParams'];
        final parameters = getUpdatedAllParams();

        final String meetingDisplayType =
            parameters['meetingDisplayType'] ?? '';
        final bool shared = parameters['shared'] ?? false;
        final bool shareScreenStarted =
            parameters['shareScreenStarted'] ?? false;
        final List<String> dispActiveNames =
            parameters['dispActiveNames'] ?? [];
        String adminNameStream = parameters['adminNameStream'] ?? '';
        final List<dynamic> participants = parameters['participants'] ?? [];
        final bool autoWave = parameters['autoWave'] ?? false;
        final UpdateActiveSounds updateActiveSounds =
            parameters['updateActiveSounds'];
        final List<dynamic> paginatedStreams =
            parameters['paginatedStreams'] ?? [];
        final int currentUserPage = parameters['currentUserPage'] ?? 0;

        final participant = participants.firstWhere(
            (obj) => obj['audioID'] == widget.remoteProducerId,
            orElse: () => null);

        if (meetingDisplayType != 'video') {
          autoWaveCheck = true;
        }
        if (shared || shareScreenStarted) {
          autoWaveCheck = false;
        }

        if (participant != null) {
          if (!participant['muted']) {
            isMuted = false;
          } else {
            isMuted = true;
          }

          UpdateParticipantAudioDecibels updateParticipantAudioDecibels =
              parameters['updateParticipantAudioDecibels'];

          updateParticipantAudioDecibels(
            name: participant['name'],
            averageLoudness: averageLoudness,
            parameters: parameters,
          );
          final inPage = paginatedStreams[currentUserPage]
              .indexWhere((obj) => obj['name'] == participant['name']);

          if (!dispActiveNames.contains(participant['name']) && inPage == -1) {
            autoWaveCheck = false;

            if (adminNameStream.isEmpty) {
              adminNameStream = participants
                      .firstWhere((obj) => obj['islevel'] == '2')['name'] ??
                  '';
            }

            if (participant['name'] == adminNameStream &&
                adminNameStream.isNotEmpty) {
              autoWaveCheck = true;
            }
          } else {
            autoWaveCheck = true;
          }

          if (participant['videoID'].isNotEmpty || autoWaveCheck) {
            setState(() {
              showWaveModal = false;
            });

            if (averageLoudness > 127.5) {
              if (!activeSounds.contains(participant['name'])) {
                setState(() {
                  activeSounds.add(participant['name']);
                });
                reUpdateInter(
                  name: participant['name'],
                  add: true,
                  average: averageLoudness,
                  parameters: parameters,
                );
              }
            } else {
              if (activeSounds.contains(participant['name'])) {
                setState(() {
                  activeSounds.remove(participant['name']);
                });
                reUpdateInter(
                  name: participant['name'],
                  average: averageLoudness,
                  parameters: parameters,
                );
              }
            }
          } else {
            if (averageLoudness > 127.5) {
              if (!autoWave) {
                setState(() {
                  showWaveModal = false;
                });
              } else {
                setState(() {
                  showWaveModal = true;
                });
              }
              if (!activeSounds.contains(participant['name'])) {
                activeSounds.add(participant['name']);
                reUpdateInter(
                  name: participant['name'],
                  add: true,
                  average: averageLoudness,
                  parameters: parameters,
                );
              }
            } else {
              setState(() {
                showWaveModal = false;
              });
              if (activeSounds.contains(participant['name'])) {
                activeSounds.remove(participant['name']);
                reUpdateInter(
                  name: participant['name'],
                  average: averageLoudness,
                  parameters: parameters,
                );
              }
            }
          }

          updateActiveSounds(activeSounds);
        } else {
          showWaveModal = false;
          isMuted = true;
        }

        setState(() {}); // Update UI
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Display RTCVideoView with RTCVideoRenderer
            !isMuted && widget.stream != null
                ? RTCVideoView(_rtcVideoRenderer)
                : const SizedBox(),
            // Render MiniAudioComponent
            widget.MiniAudioComponent != null && showWaveModal && !isMuted
                ? renderMiniAudioComponent() ?? const SizedBox()
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget? renderMiniAudioComponent() {
    if (widget.MiniAudioComponent != null) {
      return widget.MiniAudioComponent!({
        'showWaveform': showWaveModal,
        'visible': showWaveModal == true && !isMuted ? true : false,
        // Pass other MiniAudioComponent props as needed
        ...(widget.miniAudioProps ?? {}),
      });
    }
    return null;
  }
}
