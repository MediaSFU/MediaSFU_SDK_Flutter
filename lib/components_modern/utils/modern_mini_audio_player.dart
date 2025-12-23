/// Modern Mini Audio Player - Glassmorphic audio player widget
///
/// This component provides a modern, visually appealing audio player with
/// glassmorphic styling, animated waveforms, and smooth transitions.
library;

import 'dart:async';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show Consumer;

import '../../types/types.dart'
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
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

typedef ModernMiniAudioPlayerType = Widget Function(
    ModernMiniAudioPlayerOptions options);

/// Parameters for `ModernMiniAudioPlayer`.
abstract class ModernMiniAudioPlayerParameters
    implements ReUpdateInterParameters {
  // Properties as abstract getters
  bool get breakOutRoomStarted;
  bool get breakOutRoomEnded;
  List<BreakoutParticipant> get limitedBreakRoom;
  bool get autoWave;
  bool get validated;

  ReUpdateInterType get reUpdateInter;
  UpdateParticipantAudioDecibelsType get updateParticipantAudioDecibels;
  void Function(List<AudioDecibels>) get updateAudioDecibels;

  // Method to retrieve updated parameters
  ModernMiniAudioPlayerParameters Function() get getUpdatedAllParams;

  ModernMiniAudioPlayerType get modernMiniAudioPlayerComponent;
}

/// Options for `ModernMiniAudioPlayer`.
class ModernMiniAudioPlayerOptions {
  final MediaStream? stream;
  final Consumer consumer;
  final String remoteProducerId;
  final ModernMiniAudioPlayerParameters parameters;
  final Widget Function(Map<String, dynamic>)? miniAudioComponent;
  final Map<String, dynamic>? miniAudioProps;

  // Modern styling options
  final bool useGlassmorphism;
  final bool showWaveformBars;
  final int waveformBarCount;
  final Color? waveformColor;
  final Color? backgroundColor;
  final bool showGlowEffect;
  final bool animateWaveform;

  ModernMiniAudioPlayerOptions({
    required this.stream,
    required this.consumer,
    required this.remoteProducerId,
    required this.parameters,
    this.miniAudioComponent,
    this.miniAudioProps,
    this.useGlassmorphism = true,
    this.showWaveformBars = true,
    this.waveformBarCount = 5,
    this.waveformColor,
    this.backgroundColor,
    this.showGlowEffect = true,
    this.animateWaveform = true,
  });
}

/// A modern Flutter widget for playing audio streams with glassmorphic styling.
///
/// The `ModernMiniAudioPlayer` widget plays an audio stream and displays beautiful
/// animated waveforms with glassmorphic effects to indicate active audio levels.
///
/// ### Features:
/// - Glassmorphic blur effect with subtle transparency
/// - Animated waveform bars that respond to audio levels
/// - Glow effects when audio is active
/// - Smooth fade transitions
/// - Customizable colors and styling
class ModernMiniAudioPlayer extends StatefulWidget {
  final ModernMiniAudioPlayerOptions options;

  const ModernMiniAudioPlayer({
    super.key,
    required this.options,
  });

  @override
  State<ModernMiniAudioPlayer> createState() => _ModernMiniAudioPlayerState();
}

class _ModernMiniAudioPlayerState extends State<ModernMiniAudioPlayer>
    with TickerProviderStateMixin {
  bool showWaveModal = false;
  bool isMuted = true;
  bool autoWaveCheck = false;
  bool consLow = false;
  List<String> activeSounds = [];
  late RTCVideoRenderer _rtcVideoRenderer;
  late Timer _timer;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _waveController;
  late Animation<double> _fadeAnimation;

  // Audio level for waveform visualization
  double _audioLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _rtcVideoRenderer = RTCVideoRenderer();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _initializeRenderer();
    _startAudioAnalysis();
  }

  @override
  void dispose() {
    _rtcVideoRenderer.dispose();
    _timer.cancel();
    _fadeController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _initializeRenderer() async {
    await _rtcVideoRenderer.initialize();
    if (widget.options.stream != null) {
      _rtcVideoRenderer.srcObject = widget.options.stream!;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _startAudioAnalysis() {
    if (widget.options.stream != null) {
      double averageLoudness = 127.75;
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        // Retrieve updated parameters
        final parameters = widget.options.parameters.getUpdatedAllParams();

        // Check if meeting has ended - cancel timer if so
        if (!parameters.validated) {
          timer.cancel();
          if (mounted) {
            setState(() {
              showWaveModal = false;
              isMuted = true;
              _audioLevel = 0.0;
            });
            _fadeController.reverse();
            _waveController.stop();
          }
          return;
        }

        try {
          // Get stats for the RTP Receiver
          final receiver = widget.options.consumer.rtpReceiver;
          final stats = await receiver?.getStats();

          stats?.forEach((report) {
            if (report.type == 'inbound-rtp' &&
                report.values['audioLevel'] != null) {
              // Calculate the average loudness
              averageLoudness =
                  127.5 + (report.values['audioLevel'] as double) * 127.5;
            }
          });

          // Update audio level for visualization
          if (mounted) {
            setState(() {
              _audioLevel = (averageLoudness - 127.5) / 127.5;
            });
          }
        } catch (_) {
          // Do nothing
        }

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
          if (mounted) {
            setState(() {
              isMuted = participant.muted ?? false;
            });
          }

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
            // ignore: dead_code
            final bool shouldShow = false;

            if (mounted && showWaveModal != shouldShow) {
              setState(() {
                showWaveModal = shouldShow;
              });
              // ignore: dead_code
              if (shouldShow) {
                _fadeController.forward();
                if (widget.options.animateWaveform) {
                  _waveController.repeat(reverse: true);
                }
              } else {
                _fadeController.reverse();
                _waveController.stop();
              }
            }

            if (averageLoudness > 127.5) {
              if (participant.name.isNotEmpty &&
                  !activeSounds.contains(participant.name)) {
                if (mounted) {
                  setState(() {
                    activeSounds.add(participant.name);
                  });
                }
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
                if (mounted) {
                  setState(() {
                    activeSounds.remove(participant.name);
                  });
                }
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
              final bool shouldShow = autoWave;

              if (mounted && showWaveModal != shouldShow) {
                setState(() {
                  showWaveModal = shouldShow;
                });
                if (shouldShow) {
                  _fadeController.forward();
                  if (widget.options.animateWaveform) {
                    _waveController.repeat(reverse: true);
                  }
                } else {
                  _fadeController.reverse();
                  _waveController.stop();
                }
              }

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
              if (mounted && showWaveModal) {
                setState(() {
                  showWaveModal = false;
                });
                _fadeController.reverse();
                _waveController.stop();
              }
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
          if (mounted) {
            setState(() {
              showWaveModal = false;
              isMuted = true;
            });
            _fadeController.reverse();
            _waveController.stop();
          }
        }
      });
    }
  }

  Widget _buildModernWaveform() {
    final waveColor = widget.options.waveformColor ?? MediasfuColors.primary;
    final bgColor =
        widget.options.backgroundColor ?? Colors.black.withValues(alpha: 0.3);

    if (widget.options.useGlassmorphism) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(MediasfuSpacing.md),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(MediasfuSpacing.sm),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(MediasfuSpacing.md),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: widget.options.showGlowEffect
                  ? [
                      BoxShadow(
                        color: waveColor.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: _buildWaveformBars(waveColor),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(MediasfuSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(MediasfuSpacing.md),
        boxShadow: widget.options.showGlowEffect
            ? [
                BoxShadow(
                  color: waveColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: _buildWaveformBars(waveColor),
    );
  }

  Widget _buildWaveformBars(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.options.waveformBarCount, (index) {
        // Calculate bar height based on audio level and position
        final baseHeight = 8.0 + (_audioLevel * 24);
        final variation =
            ((index % 2 == 0) ? 1.2 : 0.8) * (1 + _audioLevel * 0.5);
        final height = (baseHeight * variation).clamp(4.0, 32.0);

        return AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            final animatedHeight = widget.options.animateWaveform
                ? height *
                    (0.5 + 0.5 * (1 + (_waveController.value - 0.5).abs()))
                : height;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: MediasfuSpacing.xs / 2),
              width: 4,
              height: animatedHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: widget.options.showGlowEffect
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            );
          },
        );
      }),
    );
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
          if (!isMuted && widget.options.stream != null)
            RTCVideoView(_rtcVideoRenderer),

          // Modern waveform visualization
          if (widget.options.showWaveformBars && showWaveModal && !isMuted)
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildModernWaveform(),
            ),

          // Custom audio component if provided
          if (widget.options.miniAudioComponent != null &&
              showWaveModal &&
              !isMuted)
            FadeTransition(
              opacity: _fadeAnimation,
              child: renderMiniAudioComponent() ?? const SizedBox(),
            ),
        ],
      ),
    );
  }
}
