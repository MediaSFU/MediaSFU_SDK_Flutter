import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../components/display_components/video_card.dart'
    show VideoCardOptions;
import 'modern_card_video_display.dart'
    show ModernCardVideoDisplay, ModernCardVideoDisplayOptions;
import 'modern_audio_decibel_check.dart'
    show ModernAudioDecibelCheck, ModernAudioDecibelCheckOptions;
import '../../consumers/control_media.dart' show ControlMediaOptions;
import '../../types/types.dart' show LiveSubtitle;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

typedef ModernVideoCardType = Widget Function(
    {required VideoCardOptions options});

/// A modern video card with glassmorphic overlays, smooth animations,
/// and an enhanced visual design.
/// Uses the same [VideoCardOptions] as the original component.
class ModernVideoCard extends StatefulWidget {
  final VideoCardOptions options;

  const ModernVideoCard({super.key, required this.options});

  @override
  State<ModernVideoCard> createState() => _ModernVideoCardState();
}

class _ModernVideoCardState extends State<ModernVideoCard>
    with TickerProviderStateMixin {
  late List<AnimationController> waveformAnimations;
  late AnimationController _pulseController;
  late AnimationController _hoverController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _hoverAnimation;
  ValueNotifier<bool> showWaveform = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showCropIndicator = ValueNotifier<bool>(true);
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    waveformAnimations = List.generate(
      9,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );

    animateWaveform();
    _pulseController.repeat(reverse: true);
  }

  void animateWaveform() {
    for (int i = 0; i < waveformAnimations.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) {
          waveformAnimations[i].repeat(reverse: true);
        }
      });
    }
  }

  void resetWaveform() {
    for (var controller in waveformAnimations) {
      controller.reset();
    }
  }

  void updateShowWaveform(bool value) {
    showWaveform.value = value;
  }

  @override
  void dispose() {
    for (var controller in waveformAnimations) {
      controller.dispose();
    }
    _pulseController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  Future<void> toggleAudio() async {
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

  Future<void> toggleVideo() async {
    if (widget.options.participant.videoOn ?? false) {
      final optionsControl = ControlMediaOptions(
        participantId: widget.options.participant.id!,
        participantName: widget.options.participant.name,
        type: 'video',
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
    try {
      return MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _hoverController.reverse();
        },
        child: AnimatedBuilder(
          animation: _hoverAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _hoverAnimation.value,
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
                              : Colors.black
                                  .withOpacity(_isHovered ? 0.5 : 0.35),
                          blurRadius: isSpeaking ? 16 : (_isHovered ? 16 : 8),
                          spreadRadius: isSpeaking ? 1 : 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(widget.options.borderRadius),
                      child: Stack(
                        children: [
                          // Video display
                          Positioned.fill(child: _buildVideoDisplay()),

                          // Gradient overlay — steeper at bottom for name legibility
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.55),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ),

                          // Info overlay (name badge + waveform)
                          _buildInfoOverlay(),

                          // Controls
                          if (widget.options.showControls)
                            _buildControlsOverlay(),

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

                          // Audio decibel check
                          _buildAudioDecibelCheck(),

                          // ForceFullDisplay indicator for user's own video
                          _buildForceFullDisplayIndicator(),

                          // Self-awareness indicator for webinar selfview
                          _buildSelfAwarenessIndicator(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        print('Error in ModernVideoCard: $error');
      }
      return ErrorWidget(error.toString());
    }
  }

  Widget _buildVideoDisplay() {
    return ModernCardVideoDisplay(
      options: ModernCardVideoDisplayOptions(
        remoteProducerId: widget.options.remoteProducerId,
        eventType: widget.options.eventType,
        forceFullDisplay: widget.options.forceFullDisplay,
        videoStream: widget.options.videoStream,
        backgroundColor: widget.options.backgroundColor,
        doMirror: widget.options.doMirror,
        borderRadius: widget.options.borderRadius,
        enableGlassmorphism: widget.options.enableGlassmorphism,
        isDarkMode: widget.options.isDarkMode,
      ),
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.options.participant.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: MediasfuSpacing.xs),
        _buildWaveformIndicator(),
      ],
    );
  }

  Widget _buildWaveformIndicator() {
    return ValueListenableBuilder<bool>(
      valueListenable: showWaveform,
      builder: (context, isVisible, child) {
        if (!isVisible) return const SizedBox(width: 0);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return AnimatedBuilder(
              animation: waveformAnimations[index],
              builder: (context, child) {
                final double height =
                    isVisible ? 4 + Random().nextDouble() * 10 : 2;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: height,
                  width: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: widget.options.barColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            );
          }),
        );
      },
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
        opacity: _isHovered ? 1.0 : 0.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
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
                    onTap: toggleAudio,
                    tooltip: widget.options.participant.muted!
                        ? 'Participant is muted (cannot unmute remotely)'
                        : 'Tap to mute this participant',
                  ),
                  const SizedBox(width: MediasfuSpacing.xs),
                  _buildControlButton(
                    icon: widget.options.participant.videoOn ?? true
                        ? Icons.videocam_rounded
                        : Icons.videocam_off_rounded,
                    isActive: widget.options.participant.videoOn ?? true,
                    onTap: toggleVideo,
                    tooltip: widget.options.participant.videoOn ?? true
                        ? 'Tap to turn off participant\'s camera'
                        : 'Camera is off (cannot turn on remotely)',
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
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
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

  /// Builds the live subtitle overlay displaying translated/transcribed text
  Widget _buildSubtitleOverlay() {
    return ValueListenableBuilder<LiveSubtitle?>(
      valueListenable: widget.options.liveSubtitle!,
      builder: (context, subtitle, _) {
        // Don't show if no subtitle or expired
        if (subtitle == null || subtitle.text.isEmpty || subtitle.isExpired) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: widget.options.showControls
              ? MediasfuSpacing.xl + 8
              : MediasfuSpacing.md,
          left: MediasfuSpacing.sm,
          right: MediasfuSpacing.sm,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: MediasfuSpacing.sm,
                      vertical: MediasfuSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      subtitle.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
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
          ),
        );
      },
    );
  }

  Widget _buildAudioDecibelCheck() {
    return ModernAudioDecibelCheck(
      options: ModernAudioDecibelCheckOptions(
        animateWaveform: animateWaveform,
        resetWaveform: resetWaveform,
        name: widget.options.name,
        participant: widget.options.participant,
        parameters: widget.options.parameters,
        onShowWaveformChanged: updateShowWaveform,
      ),
    );
  }

  /// Builds a dismissible indicator shown on the user's own video card
  /// when forceFullDisplay is enabled, alerting them that the displayed
  /// area may be cropped differently than what others see.
  Widget _buildForceFullDisplayIndicator() {
    // Only show for user's own video when forceFullDisplay is enabled
    final isOwnVideo =
        widget.options.participant.name == widget.options.parameters.member;
    final forceFullDisplay = widget.options.forceFullDisplay;

    if (!isOwnVideo || !forceFullDisplay) {
      return const SizedBox.shrink();
    }

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return ValueListenableBuilder<bool>(
          valueListenable: _showCropIndicator,
          builder: (context, showIndicator, _) {
            if (!showIndicator) return const SizedBox.shrink();

            final hasToggleAction = widget.options.onToggleSelfViewFit != null;

            return Positioned(
              bottom: MediasfuSpacing.sm,
              left: MediasfuSpacing.sm,
              right: MediasfuSpacing.sm,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: MediasfuSpacing.sm,
                          vertical: MediasfuSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: MediasfuColors.warning.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Warning icon
                            Icon(
                              Icons.crop_rounded,
                              color: MediasfuColors.warning,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            // Text
                            Flexible(
                              child: Text(
                                hasToggleAction
                                    ? 'Cropped - others see more.'
                                    : 'Cropped view - others see more of your video.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Action button (if callback provided)
                            if (hasToggleAction) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  widget.options.onToggleSelfViewFit?.call();
                                  _showCropIndicator.value = false;
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: MediasfuColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Full View',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 6),
                            // Dismiss button
                            GestureDetector(
                              onTap: () => _showCropIndicator.value = false,
                              child: Icon(
                                Icons.close,
                                color: Colors.white.withOpacity(0.6),
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  /// Builds a self-awareness indicator for webinar selfview
  /// showing users the full capture area visible to others.
  Widget _buildSelfAwarenessIndicator() {
    // Only show for user's own video in webinar mode (not when forceFullDisplay)
    final isOwnVideo =
        widget.options.participant.name == widget.options.parameters.member;
    final isWebinar = widget.options.eventType.toString().contains('webinar');
    final forceFullDisplay = widget.options.forceFullDisplay;

    // Show for own video in webinar when not cropped
    if (!isOwnVideo || !isWebinar || forceFullDisplay) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: MediasfuSpacing.sm,
      left: MediasfuSpacing.sm,
      right: MediasfuSpacing.sm,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MediasfuSpacing.sm,
                  vertical: MediasfuSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: MediasfuColors.primary.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Video icon
                    Icon(
                      Icons.videocam_rounded,
                      color: MediasfuColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    // Text
                    Flexible(
                      child: Text(
                        'Full capture area - this is exactly what others see',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
