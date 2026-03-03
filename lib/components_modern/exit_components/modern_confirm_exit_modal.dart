import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/exit_components/confirm_exit_modal.dart'
    show ConfirmExitModalOptions;
import '../../methods/exit_methods/confirm_exit.dart' show ConfirmExitOptions;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

/// Modern glassmorphic confirm exit modal with smooth animations.
///
/// Displays a warning dialog for exiting/ending a meeting with:
/// - Glassmorphic frosted container
/// - Animated icon with pulse effect
/// - Context-aware messaging (host vs participant)
/// - Primary action buttons with danger styling
///
/// The modal uses the existing [ConfirmExitModalOptions] for configuration
/// and delegates all business logic to the original exit methods.
class ModernConfirmExitModal extends StatefulWidget {
  final ConfirmExitModalOptions options;

  const ModernConfirmExitModal({super.key, required this.options});

  @override
  State<ModernConfirmExitModal> createState() => _ModernConfirmExitModalState();
}

class _ModernConfirmExitModalState extends State<ModernConfirmExitModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant ModernConfirmExitModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset loading state when modal is re-opened or room changes
    if ((!oldWidget.options.isVisible && widget.options.isVisible) ||
        oldWidget.options.roomName != widget.options.roomName) {
      _isExiting = false;
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleExit() async {
    if (_isExiting) return;
    setState(() => _isExiting = true);

    try {
      final exitOptions = ConfirmExitOptions(
        member: widget.options.member,
        ban: widget.options.ban,
        socket: widget.options.socket,
        roomName: widget.options.roomName,
      );
      await widget.options.exitEventOnConfirm(exitOptions);
      widget.options.onClose();
    } catch (e) {
      setState(() => _isExiting = false);
    }
  }

  void _handleCancel() {
    _animationController.reverse().then((_) {
      widget.options.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.options.isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isHost = widget.options.islevel == '2';

    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = screenWidth >= 1200;
    final shouldUseSidebar = isLandscape && isWide;
    final useHighTransparency = !shouldUseSidebar;

    final surfaceColor = useHighTransparency
        ? (isDark
            ? MediasfuColors.surfaceDark.withOpacity(0.05)
            : MediasfuColors.surface.withOpacity(0.08))
        : (isDark
            ? MediasfuColors.surfaceDark.withOpacity(0.9)
            : MediasfuColors.surface.withOpacity(0.95));

    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor =
        isDark ? Colors.white70 : Colors.black87.withOpacity(0.7);
    final dangerColor = MediasfuColors.danger;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _handleCancel,
        child: Container(
          color: Colors.black.withOpacity(0.15),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent dismissal when tapping modal
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 360),
                  margin: const EdgeInsets.all(24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black)
                                .withOpacity(0.1),
                            width: 1,
                          ),
                          boxShadow: useHighTransparency
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 40,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header with warning icon
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(MediasfuSpacing.lg),
                              decoration: BoxDecoration(
                                color: dangerColor.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16.0),
                                  topRight: Radius.circular(16.0),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Animated warning icon
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value,
                                        child: Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                dangerColor.withOpacity(0.15),
                                          ),
                                          child: Icon(
                                            isHost
                                                ? Icons.warning_rounded
                                                : Icons.exit_to_app_rounded,
                                            color: dangerColor,
                                            size: 32,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: MediasfuSpacing.md),
                                  Text(
                                    isHost ? 'End Meeting' : 'Leave Meeting',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(MediasfuSpacing.lg),
                              child: Column(
                                children: [
                                  Text(
                                    isHost
                                        ? 'Are you sure you want to end this meeting? This will disconnect all participants.'
                                        : 'Are you sure you want to leave this meeting?',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: subtitleColor,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (isHost) ...[
                                    const SizedBox(height: MediasfuSpacing.md),
                                    Container(
                                      padding: const EdgeInsets.all(
                                          MediasfuSpacing.sm),
                                      decoration: BoxDecoration(
                                        color: dangerColor.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color: dangerColor.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: dangerColor,
                                            size: 18,
                                          ),
                                          const SizedBox(
                                              width: MediasfuSpacing.xs),
                                          Expanded(
                                            child: Text(
                                              'This action cannot be undone',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: dangerColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: MediasfuSpacing.lg),
                                  // Action buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildButton(
                                          onPressed: _handleCancel,
                                          label: 'Cancel',
                                          backgroundColor: isDark
                                              ? Colors.white.withOpacity(0.1)
                                              : Colors.black.withOpacity(0.05),
                                          textColor: textColor,
                                        ),
                                      ),
                                      const SizedBox(width: MediasfuSpacing.md),
                                      Expanded(
                                        child: _buildButton(
                                          onPressed:
                                              _isExiting ? null : _handleExit,
                                          label:
                                              isHost ? 'End Meeting' : 'Leave',
                                          backgroundColor: dangerColor,
                                          textColor: Colors.white,
                                          isLoading: _isExiting,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback? onPressed,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: MediasfuSpacing.md,
            vertical: MediasfuSpacing.sm + 4,
          ),
          decoration: BoxDecoration(
            color: onPressed == null
                ? backgroundColor.withOpacity(0.5)
                : backgroundColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
