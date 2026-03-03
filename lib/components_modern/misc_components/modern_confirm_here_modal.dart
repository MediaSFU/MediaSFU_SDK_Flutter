import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../components/misc_components/confirm_here_modal.dart'
    show
        ConfirmHereModalBodyContext,
        ConfirmHereModalButtonContext,
        ConfirmHereModalContentContext,
        ConfirmHereModalCountdownContext,
        ConfirmHereModalLoaderContext,
        ConfirmHereModalMessageContext,
        ConfirmHereModalOptions,
        ConfirmHereModalOverlayContext;
import '../../methods/utils/get_modal_position.dart'
    show GetModalPositionOptions, getModalPosition;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/theme/mediasfu_typography.dart';
import '../core/widgets/glassmorphic_container.dart';

/// Modern redesigned ConfirmHereModal with glassmorphic styling and circular countdown.
/// Retains all business logic from the original component.
class ModernConfirmHereModal extends StatefulWidget {
  final ConfirmHereModalOptions options;

  const ModernConfirmHereModal({super.key, required this.options});

  @override
  State<ModernConfirmHereModal> createState() => _ModernConfirmHereModalState();
}

class _ModernConfirmHereModalState extends State<ModernConfirmHereModal>
    with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // STATE (copied from original)
  // ─────────────────────────────────────────────────────────────────────────
  Timer? countdownTimer;
  late int counter;
  bool _doNotShowAgain = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    counter = widget.options.countdownDuration;
    if (widget.options.isConfirmHereModalVisible) {
      startCountdown();
    }
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant ModernConfirmHereModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.isConfirmHereModalVisible !=
        oldWidget.options.isConfirmHereModalVisible) {
      if (widget.options.isConfirmHereModalVisible) {
        startCountdown();
      } else {
        stopCountdown();
      }
    }
    if (widget.options.countdownDuration !=
        oldWidget.options.countdownDuration) {
      counter = widget.options.countdownDuration;
      if (widget.options.isConfirmHereModalVisible) {
        startCountdown();
      }
    }
  }

  @override
  void dispose() {
    stopCountdown();
    _pulseController.dispose();
    super.dispose();
  }

  void startCountdown() {
    stopCountdown(resetCounter: false);
    counter = widget.options.countdownDuration;
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        counter--;
      });
      if (counter <= 0) {
        _handleTimeout();
      }
    });
  }

  void stopCountdown({bool resetCounter = true}) {
    countdownTimer?.cancel();
    countdownTimer = null;
    if (resetCounter) {
      counter = widget.options.countdownDuration;
    }
  }

  void _handleTimeout() {
    stopCountdown();
    widget.options.onConfirmHereClose();
    widget.options.socket?.emit('disconnectUser', {
      'member': widget.options.member,
      'roomName': widget.options.roomName,
      'ban': false,
    });
    try {
      final localSocket = widget.options.localSocket;
      if (localSocket != null && localSocket.id != null) {
        localSocket.emit('disconnectUser', {
          'member': widget.options.member,
          'roomName': widget.options.roomName,
          'ban': false,
        });
      }
    } catch (_) {}
  }

  void _confirmAndClose() {
    stopCountdown();
    if (_doNotShowAgain) {
      widget.options.onSuppressConfirmHere?.call();
    }
    widget.options.onConfirmHereClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MODERN UI BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = MediasfuTypography.textTheme(darkMode: isDark);
    final screenSize = MediaQuery.of(context).size;

    final screenWidth = screenSize.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = screenWidth >= 1200;
    final shouldUseSidebar = isLandscape && isWide;
    final useHighTransparency = !shouldUseSidebar;

    final double modalWidth =
        screenSize.width * 0.85 > 360 ? 360 : screenSize.width * 0.85;
    final double modalHeight = 340;

    final position = getModalPosition(GetModalPositionOptions(
      position: widget.options.position,
      modalWidth: modalWidth,
      modalHeight: modalHeight,
      context: context,
    ));

    final double progress = counter / widget.options.countdownDuration;

    // Build loader (circular progress with glow)
    final Widget defaultLoader = ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: MediasfuColors.primary.withOpacity(0.3 * progress),
              blurRadius: 20,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background track
            CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 6,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            // Progress ring with gradient effect
            ShaderMask(
              shaderCallback: (bounds) =>
                  MediasfuColors.brandGradient(darkMode: isDark)
                      .createShader(bounds),
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            Center(
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    MediasfuColors.brandGradient(darkMode: isDark)
                        .createShader(bounds),
                child: Text(
                  '$counter',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final Widget resolvedLoader = widget.options.loaderBuilder?.call(
          ConfirmHereModalLoaderContext(
            defaultLoader: defaultLoader,
            counter: counter,
            totalDuration: widget.options.countdownDuration,
          ),
        ) ??
        defaultLoader;

    // Heading / description
    final Widget heading = widget.options.heading ??
        Text(
          'Are you still there?',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textAlign: TextAlign.center,
        );

    final Widget description = widget.options.description ??
        Text(
          'Please confirm if you are still present.',
          style: textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        );

    final Widget defaultMessage = Column(
      mainAxisSize: MainAxisSize.min,
      children: [heading, const SizedBox(height: 8), description],
    );

    final Widget resolvedMessage = widget.options.messageBuilder?.call(
          ConfirmHereModalMessageContext(
            defaultMessage: defaultMessage,
            heading: heading,
            description: description,
            counter: counter,
            totalDuration: widget.options.countdownDuration,
          ),
        ) ??
        defaultMessage;

    // Countdown label (hidden if custom loader shows count)
    final Widget defaultCountdown = const SizedBox.shrink();
    final Widget resolvedCountdown = widget.options.countdownBuilder?.call(
          ConfirmHereModalCountdownContext(
            defaultCountdown: defaultCountdown,
            counter: counter,
            totalDuration: widget.options.countdownDuration,
          ),
        ) ??
        defaultCountdown;

    // Confirm button with glow effect
    final Widget defaultButton = widget.options.confirmButton ??
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999),
            gradient: MediasfuColors.brandGradient(darkMode: isDark),
            boxShadow: [
              BoxShadow(
                color: MediasfuColors.primary.withOpacity(0.5),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _confirmAndClose,
              borderRadius: BorderRadius.circular(9999),
              child: Padding(
                padding: MediasfuSpacing.insetSymmetric(
                  horizontal: MediasfuSpacing.xl,
                  vertical: MediasfuSpacing.md,
                ),
                child: Text(
                  "I'm Here",
                  style: MediasfuTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );

    final Widget resolvedButton = widget.options.buttonBuilder?.call(
          ConfirmHereModalButtonContext(
            defaultButton: defaultButton,
            onConfirm: _confirmAndClose,
          ),
        ) ??
        defaultButton;

    // "Don't show again" checkbox
    final Widget suppressCheckbox = widget.options.onSuppressConfirmHere != null
        ? GestureDetector(
            onTap: () => setState(() {
              _doNotShowAgain = !_doNotShowAgain;
            }),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _doNotShowAgain,
                    onChanged: (v) =>
                        setState(() => _doNotShowAgain = v ?? false),
                    activeColor: MediasfuColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Don't show again this session",
                  style: textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();

    // Body
    final Widget defaultBody = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        resolvedLoader,
        const SizedBox(height: MediasfuSpacing.lg),
        resolvedMessage,
        resolvedCountdown,
        const SizedBox(height: MediasfuSpacing.md),
        suppressCheckbox,
        const SizedBox(height: MediasfuSpacing.md),
        resolvedButton,
      ],
    );

    final Widget resolvedBody = widget.options.bodyBuilder?.call(
          ConfirmHereModalBodyContext(
            defaultBody: defaultBody,
            counter: counter,
            totalDuration: widget.options.countdownDuration,
          ),
        ) ??
        defaultBody;

    final Widget defaultContent = Center(child: resolvedBody);
    final Widget resolvedContent = widget.options.contentBuilder?.call(
          ConfirmHereModalContentContext(
            defaultContent: defaultContent,
            counter: counter,
            totalDuration: widget.options.countdownDuration,
          ),
        ) ??
        defaultContent;

    // Overlay
    Widget? overlayBg;
    if (widget.options.overlayBuilder != null) {
      overlayBg = widget.options.overlayBuilder!(
        ConfirmHereModalOverlayContext(defaultOverlay: const SizedBox.shrink()),
      );
    }

    return Visibility(
      visible: widget.options.isConfirmHereModalVisible,
      child: Stack(
        children: [
          // Frosted backdrop - semi-transparent to see content underneath
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child:
                  overlayBg ?? Container(color: Colors.black.withOpacity(0.05)),
            ),
          ),
          // Modal
          Positioned(
            top: position['top'],
            right: position['right'],
            child: GlassmorphicContainer(
              padding: MediasfuSpacing.insetAll(MediasfuSpacing.lg),
              gradient: useHighTransparency
                  ? LinearGradient(
                      colors: [
                        isDark
                            ? Colors.black.withOpacity(0.05)
                            : Colors.white.withOpacity(0.08),
                        isDark
                            ? Colors.black.withOpacity(0.05)
                            : Colors.white.withOpacity(0.08),
                      ],
                    )
                  : null,
              child: SizedBox(
                width: modalWidth,
                child: resolvedContent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Convenience builder conforming to ConfirmHereModalType signature.
Widget modernConfirmHereModalBuilder(
    {required ConfirmHereModalOptions options}) {
  return ModernConfirmHereModal(options: options);
}
