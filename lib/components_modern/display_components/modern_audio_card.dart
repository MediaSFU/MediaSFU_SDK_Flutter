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
import '../../types/types.dart' show Participant, AudioDecibels;
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              const Color(0xFF0F3460),
            ]
          : [
              const Color(0xFFF8F9FA),
              const Color(0xFFE9ECEF),
              const Color(0xFFDEE2E6),
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(widget.options.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: MediasfuColors.primary
                        .withValues(alpha: _isHovered ? 0.25 : 0.1),
                    blurRadius: _isHovered ? 24 : 16,
                    spreadRadius: _isHovered ? 2 : 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(widget.options.borderRadius),
                child: Container(
                  decoration: BoxDecoration(
                    gradient:
                        widget.options.backgroundGradient ?? defaultGradient,
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
                      if (widget.options.showControls) _buildControlsOverlay(),

                      // Status indicator
                      if (widget.options.showStatusIndicator)
                        _buildStatusIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedAvatar() {
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
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MediasfuColors.primary,
                      MediasfuColors.secondary,
                    ],
                  ),
                  boxShadow: isSpeaking
                      ? [
                          BoxShadow(
                            color:
                                MediasfuColors.primary.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.all(3),
                child: ClipOval(
                  child: ModernMiniCard(
                    options: MiniCardOptions(
                      initials: widget.options.name.isNotEmpty
                          ? widget.options.name
                          : '?',
                      fontSize: 28,
                      imageSource: widget.options.imageSource,
                      roundedImage: true,
                      imageStyle: widget.options.imageStyle,
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
          width: 190,
          height: 190,
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
                      offset: const Offset(0, -90),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 4,
                        height: height,
                        decoration: BoxDecoration(
                          color: widget.options.barColor,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: widget.options.barColor
                                  .withValues(alpha: 0.5),
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(MediasfuSpacing.sm),
      child: BackdropFilter(
        filter: widget.options.enableGlassmorphism
            ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MediasfuSpacing.sm,
            vertical: MediasfuSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(MediasfuSpacing.sm),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
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
                    size: 14,
                  ),
                ),
              Text(
                widget.options.participant.name,
                style: TextStyle(
                  color: widget.options.textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    final position = widget.options.controlsPosition.toLowerCase();

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
        opacity: _isHovered ? 1.0 : 0.8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(MediasfuSpacing.sm),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(MediasfuSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(MediasfuSpacing.sm),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
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
    return Tooltip(
      message: tooltip,
      decoration: MediasfuColors.tooltipDecoration(darkMode: true),
      textStyle: TextStyle(
        color: MediasfuColors.tooltipText(darkMode: true),
        fontSize: 12,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? MediasfuColors.success.withValues(alpha: 0.2)
                : MediasfuColors.danger.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? MediasfuColors.success.withValues(alpha: 0.5)
                  : MediasfuColors.danger.withValues(alpha: 0.5),
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? MediasfuColors.success : MediasfuColors.danger,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final isMuted = widget.options.participant.muted ?? true;

    return Positioned(
      top: MediasfuSpacing.sm,
      right: MediasfuSpacing.sm,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          color: isMuted ? MediasfuColors.danger : MediasfuColors.success,
          size: 12,
        ),
      ),
    );
  }
}
