// lib/widgets/mini_audio_player.dart

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../types/types.dart'
    show
        AudioDecibels,
        BreakoutParticipant,
        EventType,
        Participant,
        ReUpdateInterOptions,
        ReUpdateInterParameters,
        ReUpdateInterType,
        UpdateParticipantAudioDecibelsOptions,
        UpdateParticipantAudioDecibelsType;

/// Parameters for `MiniAudioPlayer`.
abstract class MiniAudioPlayerParameters implements ReUpdateInterParameters {
  // Properties as abstract getters
  bool get breakOutRoomStarted;
  bool get breakOutRoomEnded;
  List<BreakoutParticipant> get limitedBreakRoom;
  bool get autoWave;

  ReUpdateInterType get reUpdateInter;
  UpdateParticipantAudioDecibelsType get updateParticipantAudioDecibels;
  void Function(List<AudioDecibels>) get updateAudioDecibels;

  // Method to retrieve updated parameters
  MiniAudioPlayerParameters Function() get getUpdatedAllParams;

  // Dynamic properties map for additional parameters
  // dynamic operator [](String key);
}

/// Options for `MiniAudioPlayer`.
class MiniAudioPlayerOptions {
  final MediaStream? stream;
  final String remoteProducerId;
  final MiniAudioPlayerParameters parameters;
  final Widget Function(Map<String, dynamic>)? miniAudioComponent;
  final Map<String, dynamic>? miniAudioProps;

  MiniAudioPlayerOptions({
    required this.stream,
    required this.remoteProducerId,
    required this.parameters,
    this.miniAudioComponent,
    this.miniAudioProps,
  });
}

/// Typedef for `MiniAudioPlayerType`.
typedef MiniAudioPlayerType = Widget Function(MiniAudioPlayerOptions options);

/// A Flutter widget for playing audio streams with optional waveform visualization.
///
/// The `MiniAudioPlayer` widget plays an audio stream and can display visual audio waveforms
/// to indicate active audio levels. It monitors audio decibels, participant status, and room
/// configurations, providing real-time visual feedback based on audio activity.
///
/// This widget supports functionalities such as muting/unmuting, waveform display toggling,
/// updating audio decibels, and managing audio activity for participants in breakout rooms.
///
/// ## Parameters:
/// - `options`: An instance of `MiniAudioPlayerOptions` containing:
///   - `stream`: A `MediaStream` object representing the audio stream.
///   - `remoteProducerId`: The ID of the audio producer.
///   - `parameters`: An instance of `MiniAudioPlayerParameters` with participant and room data.
///   - `miniAudioComponent`: A function that returns a widget for audio visualization (e.g., a waveform).
///   - `miniAudioProps`: Additional properties for customizing the audio component.
///
/// ## Example Usage:
///
/// ```dart
/// // Define options for MiniAudioPlayer
/// final miniAudioPlayerOptions = MiniAudioPlayerOptions(
///   stream: myMediaStream,
///   remoteProducerId: 'audio123',
///   parameters: myAudioPlayerParameters,
///   miniAudioComponent: (props) => MyWaveformWidget(props),
///   miniAudioProps: {
///     'waveColor': Colors.blue,
///     'backgroundColor': Colors.grey[200],
///   },
/// );
///
/// // Use MiniAudioPlayer widget in the UI
/// MiniAudioPlayer(options: miniAudioPlayerOptions);
/// ```
///
/// This example sets up `MiniAudioPlayer` with an audio stream, participant details, and a custom
/// `miniAudioComponent` to display waveforms based on the audio activity.
class MiniAudioPlayer extends StatefulWidget {
  final MiniAudioPlayerOptions options;

  const MiniAudioPlayer({
    super.key,
    required this.options,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MiniAudioPlayerState createState() => _MiniAudioPlayerState();
}

class _MiniAudioPlayerState extends State<MiniAudioPlayer> {
  bool showWaveModal = false;
  bool isMuted = true;
  bool autoWaveCheck = false;
  bool consLow = false;
  List<String> activeSounds = [];
  late RTCVideoRenderer _rtcVideoRenderer;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _rtcVideoRenderer = RTCVideoRenderer();
    _initializeRenderer();
    _startAudioAnalysis();
  }

  @override
  void dispose() {
    _rtcVideoRenderer.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _initializeRenderer() async {
    await _rtcVideoRenderer.initialize();
    if (widget.options.stream != null) {
      _rtcVideoRenderer.srcObject = widget.options.stream!;
    }
    setState(() {});
  }

  void _startAudioAnalysis() {
    if (widget.options.stream != null) {
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        const averageLoudness = 127.75;

        // Retrieve updated parameters
        final parameters = widget.options.parameters.getUpdatedAllParams();

        // Destructure parameters
        final String meetingDisplayType = parameters.meetingDisplayType;
        final bool shared = parameters.shared;
        final bool shareScreenStarted = parameters.shareScreenStarted;
        final List<String> dispActiveNames =
            List<String>.from(parameters.dispActiveNames);
        String adminNameStream = parameters.adminNameStream;
        final List<Participant> participants = parameters.participants;
        final bool autoWave = parameters.autoWave;
        final void Function(List<String>) updateActiveSounds =
            parameters.updateActiveSounds;
        final List<List<dynamic>> paginatedStreams =
            parameters.paginatedStreams;
        final int currentUserPage = parameters.currentUserPage;
        final bool breakOutRoomStarted = parameters.breakOutRoomStarted;
        final bool breakOutRoomEnded = parameters.breakOutRoomEnded;
        final List<BreakoutParticipant> limitedBreakRoom =
            parameters.limitedBreakRoom;

        // Find the participant by remoteProducerId
        Participant? participant = participants.firstWhereOrNull(
            (obj) => obj.audioID == widget.options.remoteProducerId);

        bool audioActiveInRoom = true;
        if (participant != null) {
          if (breakOutRoomStarted && !breakOutRoomEnded) {
            if (participant.name.isNotEmpty &&
                !limitedBreakRoom
                    .map((obj) => obj.name)
                    .contains(participant.name)) {
              audioActiveInRoom = false;
            }
          }
        }

        bool autoWaveCheck = meetingDisplayType != 'video';
        if (shared || shareScreenStarted) {
          autoWaveCheck = false;
        }

        if (participant != null) {
          setState(() {
            isMuted = participant.muted ?? false;
          });

          // Update participant audio decibels
          if (parameters.eventType != EventType.chat &&
              parameters.eventType != EventType.broadcast) {
            parameters.updateParticipantAudioDecibels(
              UpdateParticipantAudioDecibelsOptions(
                name: participant.name,
                averageLoudness: averageLoudness,
                audioDecibels: parameters.audioDecibels,
                updateAudioDecibels: parameters.updateAudioDecibels,
              ),
            );
          }

          // Check if participant is on the current page
          final inPage = paginatedStreams.length > currentUserPage
              ? paginatedStreams[currentUserPage]
                  .indexWhere((obj) => obj.name == participant.name)
              : -1;

          if (!dispActiveNames.contains(participant.name) && inPage == -1) {
            autoWaveCheck = false;
            if (adminNameStream.isEmpty) {
              final adminParticipant =
                  participants.firstWhereOrNull((obj) => obj.islevel == '2');
              adminNameStream =
                  adminParticipant != null ? adminParticipant.name : '';
            }

            if (participant.name == adminNameStream &&
                adminNameStream.isNotEmpty) {
              autoWaveCheck = true;
            }
          } else {
            autoWaveCheck = true;
          }

          if (participant.videoID.isNotEmpty ||
              autoWaveCheck ||
              (breakOutRoomStarted &&
                  !breakOutRoomEnded &&
                  audioActiveInRoom)) {
            setState(() {
              showWaveModal = false;
            });

            if (averageLoudness > 127.5) {
              if (participant.name.isNotEmpty &&
                  !activeSounds.contains(participant.name)) {
                setState(() {
                  activeSounds.add(participant.name);
                });
                consLow = false;

                if (!(shared || shareScreenStarted) ||
                    participant.videoID.isNotEmpty) {
                  if (parameters.eventType != EventType.chat &&
                      parameters.eventType != EventType.broadcast &&
                      participant.name.isNotEmpty) {
                    final optionsReUpdate = ReUpdateInterOptions(
                      name: participant.name,
                      add: true,
                      average: averageLoudness,
                      parameters: parameters,
                    );
                    widget.options.parameters.reUpdateInter(
                      optionsReUpdate,
                    );
                  }
                }
              }
            } else {
              if (participant.name.isNotEmpty &&
                  activeSounds.contains(participant.name) &&
                  consLow) {
                setState(() {
                  activeSounds.remove(participant.name);
                });
                if (parameters.eventType != EventType.chat &&
                    parameters.eventType != EventType.broadcast &&
                    participant.name.isNotEmpty) {
                  final optionsReUpdate = ReUpdateInterOptions(
                    name: participant.name,
                    average: averageLoudness,
                    parameters: parameters,
                  );
                  widget.options.parameters.reUpdateInter(
                    optionsReUpdate,
                  );
                }
              } else {
                consLow = true;
              }
            }
          } else {
            if (averageLoudness > 127.5) {
              setState(() {
                showWaveModal = autoWave;
              });

              if (!activeSounds.contains(participant.name)) {
                activeSounds.add(participant.name);
              }

              if ((shareScreenStarted || shared) &&
                  participant.videoID.isEmpty) {
                /* empty */
              } else {
                if (parameters.eventType != EventType.chat &&
                    parameters.eventType != EventType.broadcast &&
                    participant.name.isNotEmpty) {
                  final optionsReUpdate = ReUpdateInterOptions(
                    name: participant.name,
                    add: true,
                    average: averageLoudness,
                    parameters: parameters,
                  );
                  widget.options.parameters.reUpdateInter(
                    optionsReUpdate,
                  );
                }
              }
            } else {
              setState(() {
                showWaveModal = false;
              });
              if (participant.name.isNotEmpty &&
                  activeSounds.contains(participant.name)) {
                activeSounds.remove(participant.name);
              }

              if ((shareScreenStarted || shared) &&
                  participant.videoID.isEmpty) {
                /* empty */
              } else {
                if (parameters.eventType != EventType.chat &&
                    parameters.eventType != EventType.broadcast &&
                    participant.name.isNotEmpty) {
                  final optionsReUpdate = ReUpdateInterOptions(
                    name: participant.name,
                    average: averageLoudness,
                    parameters: parameters,
                  );
                  widget.options.parameters.reUpdateInter(
                    optionsReUpdate,
                  );
                }
              }
            }
          }

          // Update active sounds
          updateActiveSounds(activeSounds);
        } else {
          setState(() {
            showWaveModal = false;
            isMuted = true;
          });
        }
      });
    }
  }

  Widget? renderMiniAudioComponent() {
    if (widget.options.miniAudioComponent != null) {
      return widget.options.miniAudioComponent!({
        'showWaveform': showWaveModal,
        'visible': showWaveModal && !isMuted,
        ...?widget.options.miniAudioProps,
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Display RTCVideoView with RTCVideoRenderer
          !isMuted && widget.options.stream != null
              ? RTCVideoView(_rtcVideoRenderer)
              : const SizedBox(),
          if (widget.options.miniAudioComponent != null &&
              showWaveModal &&
              !isMuted)
            renderMiniAudioComponent() ?? const SizedBox(),
        ],
      ),
    );
  }
}
