import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/recording_components/recording_modal.dart'
    show RecordingModalOptions;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import 'modern_standard_panel_component.dart'
    show ModernStandardPanelComponent, ModernStandardPanelComponentOptions;
import 'modern_advanced_panel_component.dart'
    show ModernAdvancedPanelComponent, ModernAdvancedPanelComponentOptions;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../methods/recording_methods/confirm_recording.dart'
    show ConfirmRecordingOptions;
import '../../methods/recording_methods/start_recording.dart'
    show StartRecordingOptions;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/widgets/modal_header.dart';

typedef ModernRecordingModalType = Widget Function(
    {required RecordingModalOptions options});

/// Modern recording settings modal with glassmorphic design.
/// Uses the same [RecordingModalOptions] as the original component.
class ModernRecordingModal extends StatefulWidget {
  final RecordingModalOptions options;

  const ModernRecordingModal({super.key, required this.options});

  @override
  State<ModernRecordingModal> createState() => _ModernRecordingModalState();
}

class _ModernRecordingModalState extends State<ModernRecordingModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _selectedTabIndex = 0;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      widget.options.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    // For sidebar or inline mode, render content directly without modal wrapper
    if (widget.options.renderMode == ModalRenderMode.sidebar ||
        widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent();
    }

    final mediaSize = MediaQuery.of(context).size;
    final modalWidth = math.min(mediaSize.width * 0.9, 500.0);
    final modalHeight = mediaSize.height * 0.8;

    final screenWidth = mediaSize.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = screenWidth >= 1200;
    final shouldUseSidebar = isLandscape && isWide;
    final useHighTransparency = !shouldUseSidebar;

    final positionData = getModalPosition(GetModalPositionOptions(
      position: widget.options.position,
      modalWidth: modalWidth,
      modalHeight: modalHeight,
      context: context,
    ));

    return Visibility(
      visible: widget.options.isRecordingModalVisible,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Backdrop
            Positioned.fill(
              child: GestureDetector(
                onTap: _handleClose,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    color: Colors.black.withOpacity(0.05),
                  ),
                ),
              ),
            ),

            // Modal
            Positioned(
              top: positionData['top'],
              right: positionData['right'],
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: widget.options.enableGlassmorphism
                          ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                          : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: Container(
                        width: modalWidth,
                        height: modalHeight,
                        decoration: BoxDecoration(
                          color: useHighTransparency
                              ? (widget.options.isDarkMode
                                  ? Colors.black.withOpacity(0.05)
                                  : Colors.white.withOpacity(0.08))
                              : (widget.options.isDarkMode
                                  ? Colors.black.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.9)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.options.isDarkMode
                                ? Colors.white.withOpacity(
                                    useHighTransparency ? 0.08 : 0.15)
                                : Colors.black.withOpacity(
                                    useHighTransparency ? 0.05 : 0.1),
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
                          children: [
                            _buildHeader(),
                            _buildTabBar(),
                            Expanded(child: _buildTabContent()),
                            _buildFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds sidebar-optimized content for embedding in sidebar panel.
  Widget _buildSidebarContent() {
    return Column(
      children: [
        _buildHeader(),
        _buildTabBar(),
        Expanded(child: _buildTabContent()),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return ModalHeader(
      icon: Icons.fiber_manual_record_rounded,
      title: 'Recording Settings',
      onClose: _handleClose,
      isDarkMode: widget.options.isDarkMode,
      gradientColors: [
        MediasfuColors.danger,
        MediasfuColors.danger.withOpacity(0.7),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.md,
        vertical: MediasfuSpacing.sm,
      ),
      child: Row(
        children: [
          _buildTab('Basic', 0),
          const SizedBox(width: MediasfuSpacing.sm),
          _buildTab('Advanced', 1),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: MediasfuSpacing.lg,
          vertical: MediasfuSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    MediasfuColors.danger,
                    MediasfuColors.danger.withOpacity(0.7),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : (widget.options.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (widget.options.isDarkMode ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Padding(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      child: SingleChildScrollView(
        child: _selectedTabIndex == 0
            ? ModernStandardPanelComponent(
                options: ModernStandardPanelComponentOptions(
                  parameters: widget.options.parameters,
                  enableGlassmorphism: widget.options.enableGlassmorphism,
                  isDarkMode: widget.options.isDarkMode,
                ),
              )
            : ModernAdvancedPanelComponent(
                options: ModernAdvancedPanelComponentOptions(
                  parameters: widget.options.parameters,
                  enableGlassmorphism: widget.options.enableGlassmorphism,
                  isDarkMode: widget.options.isDarkMode,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: widget.options.isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: 'Confirm Settings',
              icon: Icons.check_rounded,
              isPrimary: false,
              isSuccess: _isConfirmed,
              onTap: () {
                widget.options.confirmRecording(
                  ConfirmRecordingOptions(
                      parameters: widget.options.parameters),
                );
                setState(() => _isConfirmed = true);
              },
            ),
          ),
          const SizedBox(width: MediasfuSpacing.md),
          Expanded(
            child: _buildActionButton(
              label: 'Start Recording',
              icon: Icons.fiber_manual_record_rounded,
              isPrimary: true,
              isEnabled: _isConfirmed,
              onTap: _isConfirmed
                  ? () {
                      widget.options.startRecording(
                        StartRecordingOptions(
                            parameters: widget.options.parameters),
                      );
                      _handleClose();
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    bool isEnabled = true,
    bool isSuccess = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: MediasfuSpacing.md,
          vertical: MediasfuSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary && isEnabled
              ? LinearGradient(
                  colors: [
                    MediasfuColors.danger,
                    MediasfuColors.danger.withOpacity(0.7),
                  ],
                )
              : (isSuccess
                  ? LinearGradient(
                      colors: [
                        MediasfuColors.success,
                        MediasfuColors.success.withOpacity(0.8),
                      ],
                    )
                  : null),
          color: !isPrimary && !isSuccess
              ? (widget.options.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05))
              : (isEnabled ? null : Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          border: !isPrimary && !isSuccess
              ? Border.all(
                  color: MediasfuColors.primary.withOpacity(0.3),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : icon,
              color: isPrimary && isEnabled
                  ? Colors.white
                  : (isSuccess
                      ? Colors.white
                      : (isEnabled ? MediasfuColors.primary : Colors.grey)),
              size: 18,
            ),
            const SizedBox(width: MediasfuSpacing.xs),
            Text(
              isSuccess ? 'Confirmed!' : label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isPrimary && isEnabled
                    ? Colors.white
                    : (isSuccess
                        ? Colors.white
                        : (isEnabled
                            ? (widget.options.isDarkMode
                                ? Colors.white
                                : Colors.black87)
                            : Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
