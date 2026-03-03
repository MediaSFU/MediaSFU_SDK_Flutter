import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/display_settings_components/display_settings_modal.dart'
    show DisplaySettingsModalOptions;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../../types/types.dart' show ModifyDisplaySettingsOptions;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/widgets/modal_header.dart';
import '../core/widgets/modal_footer_button.dart';
import '../core/widgets/modern_switch.dart';
import '../core/widgets/section_card.dart';
import '../core/widgets/animation_widgets.dart' show StaggeredAnimationList;

typedef ModernDisplaySettingsModalType = Widget Function(
    {required DisplaySettingsModalOptions options});

/// Modern display settings modal with glassmorphic design.
/// Uses the same [DisplaySettingsModalOptions] as the original component.
class ModernDisplaySettingsModal extends StatefulWidget {
  final DisplaySettingsModalOptions options;

  const ModernDisplaySettingsModal({super.key, required this.options});

  @override
  State<ModernDisplaySettingsModal> createState() =>
      _ModernDisplaySettingsModalState();
}

class _ModernDisplaySettingsModalState extends State<ModernDisplaySettingsModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  late String _meetingDisplayType;
  late bool _autoWave;
  late bool _forceFullDisplay;
  late bool _meetingVideoOptimized;

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

    _meetingDisplayType = widget.options.parameters.meetingDisplayType;
    _autoWave = widget.options.parameters.autoWave;
    _forceFullDisplay = widget.options.parameters.forceFullDisplay;
    _meetingVideoOptimized = widget.options.parameters.meetingVideoOptimized;

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

  void _handleSave() {
    widget.options.parameters.updateMeetingDisplayType(_meetingDisplayType);
    widget.options.parameters.updateAutoWave(_autoWave);
    widget.options.parameters.updateForceFullDisplay(_forceFullDisplay);
    widget.options.parameters
        .updateMeetingVideoOptimized(_meetingVideoOptimized);

    final optionsModify = ModifyDisplaySettingsOptions(
      parameters: widget.options.parameters,
    );
    widget.options.onModifySettings(optionsModify);
  }

  String _getDisplayLabel(String value) {
    switch (value) {
      case 'video':
        return 'Video Participants Only';
      case 'media':
        return 'Media Participants Only';
      case 'all':
        return 'Show All Participants';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    // For sidebar or inline mode, render content directly without modal wrapper
    if (widget.options.renderMode == ModalRenderMode.sidebar ||
        widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = screenWidth >= 1200;
    final shouldUseSidebar = isLandscape && isWide;
    final useHighTransparency = !shouldUseSidebar;

    final modalWidth = screenWidth * 0.85 > 420 ? 420.0 : screenWidth * 0.85;
    final modalHeight = MediaQuery.of(context).size.height * 0.65;

    return Visibility(
      visible: widget.options.isVisible,
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
              top: getModalPosition(GetModalPositionOptions(
                position: widget.options.position,
                modalWidth: modalWidth,
                modalHeight: modalHeight,
                context: context,
              ))['top'],
              right: getModalPosition(GetModalPositionOptions(
                position: widget.options.position,
                modalWidth: modalWidth,
                modalHeight: modalHeight,
                context: context,
              ))['right'],
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
                                    useHighTransparency ? 0.08 : 0.1)
                                : Colors.black.withOpacity(
                                    useHighTransparency ? 0.05 : 0.1),
                          ),
                          boxShadow: useHighTransparency
                              ? []
                              : [
                                  BoxShadow(
                                    color: MediasfuColors.info.withOpacity(0.3),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                  BoxShadow(
                                    color: MediasfuColors.primary
                                        .withOpacity(0.15),
                                    blurRadius: 60,
                                    spreadRadius: 10,
                                    offset: const Offset(10, 20),
                                  ),
                                ],
                        ),
                        child: Column(
                          children: [
                            _buildHeader(),
                            Expanded(
                              child: SingleChildScrollView(
                                padding:
                                    const EdgeInsets.all(MediasfuSpacing.md),
                                child: StaggeredAnimationList(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  spacing: MediasfuSpacing.md,
                                  children: [
                                    _buildDropdownSection(),
                                    _buildToggleSection(
                                      icon: Icons.graphic_eq_rounded,
                                      label: 'Display Audiographs',
                                      description:
                                          'Show waveform visualizations for audio-only participants',
                                      value: _autoWave,
                                      onChanged: (v) =>
                                          setState(() => _autoWave = v),
                                    ),
                                    _buildToggleSection(
                                      icon: Icons.fullscreen_rounded,
                                      label: 'Force Full Display',
                                      description:
                                          'Prevent tiles from collapsing for inactive participants',
                                      value: _forceFullDisplay,
                                      onChanged: (v) =>
                                          setState(() => _forceFullDisplay = v),
                                    ),
                                    _buildToggleSection(
                                      icon: Icons.video_camera_front_rounded,
                                      label: 'Force Video Participants',
                                      description:
                                          'Prioritize video tiles in grid layout',
                                      value: _meetingVideoOptimized,
                                      onChanged: (v) => setState(
                                          () => _meetingVideoOptimized = v),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MediasfuSpacing.md),
            child: StaggeredAnimationList(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: MediasfuSpacing.md,
              children: [
                _buildDropdownSection(),
                _buildToggleSection(
                  icon: Icons.graphic_eq_rounded,
                  label: 'Display Audiographs',
                  description:
                      'Show waveform visualizations for audio-only participants',
                  value: _autoWave,
                  onChanged: (v) => setState(() => _autoWave = v),
                ),
                _buildToggleSection(
                  icon: Icons.fullscreen_rounded,
                  label: 'Force Full Display',
                  description:
                      'Prevent tiles from collapsing for inactive participants',
                  value: _forceFullDisplay,
                  onChanged: (v) => setState(() => _forceFullDisplay = v),
                ),
                _buildToggleSection(
                  icon: Icons.video_camera_front_rounded,
                  label: 'Force Video Participants',
                  description: 'Prioritize video tiles in grid layout',
                  value: _meetingVideoOptimized,
                  onChanged: (v) => setState(() => _meetingVideoOptimized = v),
                ),
              ],
            ),
          ),
        ),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return ModalHeader(
      icon: Icons.display_settings_rounded,
      title: 'Display Settings',
      onClose: _handleClose,
      isDarkMode: widget.options.isDarkMode,
      gradientColors: [
        MediasfuColors.info,
        MediasfuColors.info.withOpacity(0.7),
      ],
    );
  }

  Widget _buildDropdownSection() {
    return SectionCard(
      isDarkMode: widget.options.isDarkMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                color: MediasfuColors.primary,
                size: 20,
              ),
              const SizedBox(width: MediasfuSpacing.sm),
              Text(
                'Display Option',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      widget.options.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: MediasfuSpacing.sm),
          Tooltip(
            message: 'Select what type of content to display',
            decoration: MediasfuColors.tooltipDecoration(
                darkMode: widget.options.isDarkMode),
            textStyle: TextStyle(
              color: MediasfuColors.tooltipText(
                  darkMode: widget.options.isDarkMode),
              fontSize: 12,
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: MediasfuSpacing.md),
              decoration: MediasfuColors.dropdownDecoration(
                  darkMode: widget.options.isDarkMode),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _meetingDisplayType,
                  isExpanded: true,
                  dropdownColor: MediasfuColors.dropdownBackground(
                      darkMode: widget.options.isDarkMode),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: widget.options.isDarkMode
                        ? MediasfuColors.primaryDark
                        : MediasfuColors.primary,
                  ),
                  items: ['video', 'media', 'all'].map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(
                        _getDisplayLabel(option),
                        style: TextStyle(
                          color: widget.options.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _meetingDisplayType = value);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSection({
    required IconData icon,
    required String label,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SectionCard(
      isDarkMode: widget.options.isDarkMode,
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? MediasfuColors.primary : Colors.grey,
            size: 22,
          ),
          const SizedBox(width: MediasfuSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: widget.options.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.options.isDarkMode
                        ? Colors.white54
                        : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          ModernSwitch(
            value: value,
            onChanged: onChanged,
            isDarkMode: widget.options.isDarkMode,
            semanticLabel: '$label toggle',
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return ModalFooterButton(
      label: 'Save Settings',
      onPressed: _handleSave,
      isDarkMode: widget.options.isDarkMode,
    );
  }
}
