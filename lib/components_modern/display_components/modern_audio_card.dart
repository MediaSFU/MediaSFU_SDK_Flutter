import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/display_components/audio_card.dart'
    show AudioCardOptions;
import '../../components/display_components/mini_card.dart'
    show MiniCardOptions;
import 'modern_mini_card.dart' show ModernMiniCard;
import '../../consumers/control_media.dart' show ControlMediaOptions;
import '../../types/types.dart' show Participant, AudioDecibels, LiveSubtitle;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

typedef ModernAudioCardType = Widget Function(
    {required AudioCardOptions options});

/// A modern audio-only participant card with glassmorphic design,
/// animated waveform visualization, and smooth animations.
/// Uses the same [AudioCardOptions] as the original component.
class ModernAudioCard extends StatefulWidget {
  final AudioCardOptions options;

  const ModernAudioCard({super.key, required this.options});

  @override
  State<ModernAudioCard> createState() => _ModernAudioCardState();
}

class _ModernAudioCardState extends State<ModernAudioCard>
    with TickerProviderStateMixin {
  late List<AnimationController> waveformAnimations;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  ValueNotifier<bool> showWaveform = ValueNotifier<bool>(false);
  Timer? _waveformTimer;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    waveformAnimations = List.generate(
      9,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    _animateWaveform();
    showWaveform.value = true;
    _animateWaveformChecker();
  }

  void _animateWaveformChecker() {
    _waveformTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final audioDecibels =
          widget.options.parameters.getUpdatedAllParams().audioDecibels;
      final participants =
          widget.options.parameters.getUpdatedAllParams().participants;

      final existingEntry = audioDecibels.firstWhere(
        (entry) => entry.name == widget.options.name,
        orElse: () => AudioDecibels(name: '', averageLoudness: 0),
      );

      Participant? participant = participants.firstWhere(
        (participant) => participant.name == widget.options.name,
        orElse: () => Participant(
          id: '',
          name: '',
          muted: true,
          videoID: "",
          audioID: "",
        ),
      );

      if (existingEntry.name.isNotEmpty &&
          existingEntry.averageLoudness > 127.5 &&
          participant.name.isNotEmpty &&
          !participant.muted!) {
        showWaveform.value = true;
        if (!_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        }
      } else {
        showWaveform.value = false;
        if (_pulseController.isAnimating) {
          _pulseController.stop();
          _pulseController.reset();
        }
      }
    });
  }

  void _animateWaveform() {
    for (int i = 0; i < waveformAnimations.length; i++) {
      Future.delayed(Duration(milliseconds: i * 40), () {
        if (mounted) {
          waveformAnimations[i].repeat(reverse: true);
        }
      });
    }
  }

  void _resetWaveform() {
    for (var controller in waveformAnimations) {
      controller.reset();
    }
  }

  @override
  void dispose() {
    _waveformTimer?.cancel();
    for (var controller in waveformAnimations) {
      controller.dispose();
    }
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    if (!widget.options.participant.muted!) {
      final optionsControl = ControlMediaOptions(
        participantId: widget.options.participant.id!,
        participantName: widget.options.participant.name,
        type: 'audio',
        socket: widget.options.parameters.socket,
        roomName: widget.options.parameters.roomName,
        coHostResponsibility: widget.options.parameters.coHostResponsibility,
        showAlert: widget.options.parameters.showAlert,
        coHost: widget.options.parameters.coHost,
        participants: widget.options.parameters.participants,
        member: widget.options.parameters.member,
        islevel: widget.options.parameters.islevel,
      );
      await widget.options.controlUserMedia(optionsControl);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Suppress unused variable warnings
    _resetWaveform;

    final isDark = widget.options.isDarkMode;
    final defaultGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF1a1d2e),
              const Color(0xFF151827),
            ]
          : [
              const Color(0xFFF8F9FA),
              const Color(0xFFE9ECEF),
            ],
    );

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _scaleController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _scaleController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ValueListenableBuilder<bool>(
              valueListenable: showWaveform,
              builder: (context, isSpeaking, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(widget.options.borderRadius),
                    border: isSpeaking
                        ? Border.all(
                            color: MediasfuColors.success,
                            width: 2.5,
                          )
                        : Border.all(
                            color: Colors.transparent,
                            width: 2.5,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: isSpeaking
                            ? MediasfuColors.success.withOpacity(0.15)
                            : Colors.black.withOpacity(isDark
                                ? (_isHovered ? 0.5 : 0.35)
                                : (_isHovered ? 0.18 : 0.10)),
                        blurRadius: isSpeaking ? 16 : (_isHovered ? 16 : 8),
                        spreadRadius: isSpeaking ? 1 : 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(widget.options.borderRadius),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: widget.options.backgroundGradient ??
                            defaultGradient,
                      ),
                      child: Stack(
                        children: [
                          // Avatar with pulse animation
                          Positioned.fill(
                            child: Center(
                              child: _buildAnimatedAvatar(),
                            ),
                          ),

                          // Waveform ring animation
                          Positioned.fill(
                            child: Center(
                              child: _buildWaveformRing(),
                            ),
                          ),

                          // Info overlay (name)
                          _buildInfoOverlay(),

                          // Controls
                          if (widget.options.showControls)
                            _buildControlsOverlay(),

                          // Status indicator — labeled pill
                          if (widget.options.showStatusIndicator)
                            _buildStatusIndicator(),

                          // Live subtitle overlay - use notifier for reactive updates if available
                          if (widget.options.liveSubtitle != null)
                            widget.options.showSubtitlesNotifier != null
                                ? ValueListenableBuilder<bool>(
                                    valueListenable:
                                        widget.options.showSubtitlesNotifier!,
                                    builder: (context, showSubtitles, _) {
                                      if (showSubtitles) {
                                        return _buildSubtitleOverlay();
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  )
                                : (widget.options.showSubtitles
                                    ? _buildSubtitleOverlay()
                                    : const SizedBox.shrink()),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedAvatar() {
    final isDark = widget.options.isDarkMode;
    return ValueListenableBuilder<bool>(
      valueListenable: showWaveform,
      builder: (context, isSpeaking, _) {
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final scale = isSpeaking ? _pulseAnimation.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF4f46e5),
                            MediasfuColors.secondary,
                          ]
                        : [
                            const Color(0xFF818CF8),
                            const Color(0xFFA5B4FC),
                          ],
                  ),
                  boxShadow: isSpeaking
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.all(2.5),
                child: ClipOval(
                  child: ModernMiniCard(
                    options: MiniCardOptions(
                      initials: widget.options.name.isNotEmpty
                          ? widget.options.name
                          : '?',
                      fontSize: 22,
                      imageSource: widget.options.imageSource,
                      roundedImage: true,
                      imageStyle: widget.options.imageStyle,
                      isDarkMode: isDark,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWaveformRing() {
    return ValueListenableBuilder<bool>(
      valueListenable: showWaveform,
      builder: (context, isVisible, _) {
        if (!isVisible) return const SizedBox();

        return SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(9, (index) {
              final angle = (index * 40) * (pi / 180);
              return AnimatedBuilder(
                animation: waveformAnimations[index],
                builder: (context, child) {
                  final height = 8 + Random().nextDouble() * 20;
                  return Transform.rotate(
                    angle: angle,
                    child: Transform.translate(
                      offset: const Offset(0, -55),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 4,
                        height: height,
                        decoration: BoxDecoration(
                          color: widget.options.barColor,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: widget.options.barColor.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildInfoOverlay() {
    final position = widget.options.infoPosition.toLowerCase();

    return Positioned(
      top: position.contains('top') ? MediasfuSpacing.sm : null,
      left: position.contains('left') ? MediasfuSpacing.sm : null,
      bottom: position.contains('bottom') ? MediasfuSpacing.sm : null,
      right: position.contains('right') ? MediasfuSpacing.sm : null,
      child: widget.options.videoInfoComponent ?? _buildDefaultInfoOverlay(),
    );
  }

  Widget _buildDefaultInfoOverlay() {
    if (!widget.options.showInfo) return const SizedBox();
    final isDark = widget.options.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.sm + 2,
        vertical: MediasfuSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: isDark
              ? [
                  Colors.black.withOpacity(0.45),
                  Colors.transparent,
                ]
              : [
                  Colors.black.withOpacity(0.18),
                  Colors.transparent,
                ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.options.participant.muted ?? false)
            Padding(
              padding: const EdgeInsets.only(right: MediasfuSpacing.xs),
              child: Icon(
                Icons.mic_off_rounded,
                color: MediasfuColors.danger,
                size: 13,
              ),
            ),
          Flexible(
            child: Text(
              widget.options.participant.name,
              style: TextStyle(
                color:
                    isDark ? widget.options.textColor : const Color(0xFF1F2937),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                shadows: isDark
                    ? [
                        Shadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    final position = widget.options.controlsPosition.toLowerCase();
    final isDark = widget.options.isDarkMode;

    if (widget.options.videoControlsComponent != null) {
      return Positioned(
        top: position.contains('top') ? MediasfuSpacing.sm : null,
        left: position.contains('left') ? MediasfuSpacing.sm : null,
        bottom: position.contains('bottom') ? MediasfuSpacing.sm : null,
        right: position.contains('right') ? MediasfuSpacing.sm : null,
        child: widget.options.videoControlsComponent!,
      );
    }

    return Positioned(
      top: position.contains('top') ? MediasfuSpacing.sm : null,
      left: position.contains('left') ? MediasfuSpacing.sm : null,
      bottom: position.contains('bottom') ? MediasfuSpacing.sm : null,
      right: position.contains('right') ? MediasfuSpacing.sm : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isHovered ? 1.0 : 0.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlButton(
                    icon: widget.options.participant.muted!
                        ? Icons.mic_off_rounded
                        : Icons.mic_rounded,
                    isActive: !widget.options.participant.muted!,
                    onTap: _toggleAudio,
                    tooltip: widget.options.participant.muted!
                        ? 'Participant is muted (cannot unmute remotely)'
                        : 'Tap to mute this participant',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    final isDark = widget.options.isDarkMode;
    return Tooltip(
      message: tooltip,
      decoration: MediasfuColors.tooltipDecoration(darkMode: isDark),
      textStyle: TextStyle(
        color: MediasfuColors.tooltipText(darkMode: isDark),
        fontSize: 12,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.55)
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? MediasfuColors.success : MediasfuColors.danger,
            size: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final isMuted = widget.options.participant.muted ?? true;
    final isDark = widget.options.isDarkMode;

    return Positioned(
      top: 6,
      right: 6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  color:
                      isMuted ? MediasfuColors.danger : MediasfuColors.success,
                  size: 11,
                ),
                const SizedBox(width: 4),
                Text(
                  isMuted ? 'Muted' : 'Live',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.6)
                        : Colors.black.withOpacity(0.55),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the live subtitle overlay for translated speech
  Widget _buildSubtitleOverlay() {
    return ValueListenableBuilder<LiveSubtitle?>(
      valueListenable: widget.options.liveSubtitle!,
      builder: (context, subtitle, _) {
        if (subtitle == null || subtitle.isExpired) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: MediasfuSpacing.md,
          left: MediasfuSpacing.sm,
          right: MediasfuSpacing.sm,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(MediasfuSpacing.sm),
              child: BackdropFilter(
                filter: widget.options.enableGlassmorphism
                    ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                    : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MediasfuSpacing.md,
                    vertical: MediasfuSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(MediasfuSpacing.sm),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: Text(
                    subtitle.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
