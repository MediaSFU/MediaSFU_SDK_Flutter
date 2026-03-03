import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/event_settings_components/event_settings_modal.dart'
    show EventSettingsModalOptions;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../methods/settings_methods/modify_settings.dart'
    show ModifySettingsOptions;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/widgets/modal_header.dart';
import '../core/widgets/modal_footer_button.dart';
import '../core/widgets/section_card.dart';
import '../core/widgets/animation_widgets.dart' show StaggeredAnimationList;

typedef ModernEventSettingsModalType = Widget Function(
    {required EventSettingsModalOptions options});

/// Modern event settings modal with glassmorphic design.
/// Uses the same [EventSettingsModalOptions] as the original component.
class ModernEventSettingsModal extends StatefulWidget {
  final EventSettingsModalOptions options;

  const ModernEventSettingsModal({super.key, required this.options});

  @override
  State<ModernEventSettingsModal> createState() =>
      _ModernEventSettingsModalState();
}

class _ModernEventSettingsModalState extends State<ModernEventSettingsModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  late String _audioState;
  late String _videoState;
  late String _screenshareState;
  late String _chatState;

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

    _audioState = widget.options.audioSetting;
    _videoState = widget.options.videoSetting;
    _screenshareState = widget.options.screenshareSetting;
    _chatState = widget.options.chatSetting;

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
    final settings = ModifySettingsOptions(
      audioSet: _audioState,
      videoSet: _videoState,
      screenshareSet: _screenshareState,
      chatSet: _chatState,
      socket: widget.options.socket,
      roomName: widget.options.roomName,
      showAlert: widget.options.showAlert,
      updateAudioSetting: widget.options.updateAudioSetting,
      updateVideoSetting: widget.options.updateVideoSetting,
      updateScreenshareSetting: widget.options.updateScreenshareSetting,
      updateChatSetting: widget.options.updateChatSetting,
      updateIsSettingsModalVisible: widget.options.updateIsSettingsModalVisible,
    );
    widget.options.onModifySettings(settings);
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'allow':
        return MediasfuColors.success;
      case 'disallow':
        return MediasfuColors.danger;
      case 'approval':
        return MediasfuColors.warning;
      default:
        return Colors.grey;
    }
  }

  // ignore: unused_element
  IconData _getStateIcon(String state) {
    switch (state) {
      case 'allow':
        return Icons.check_circle_rounded;
      case 'disallow':
        return Icons.cancel_rounded;
      case 'approval':
        return Icons.pending_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sidebar mode: render without backdrop/positioning
    if (widget.options.renderMode == ModalRenderMode.sidebar) {
      return _buildSidebarContent();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = screenWidth >= 1200;
    final shouldUseSidebar = isLandscape && isWide;
    final useHighTransparency = !shouldUseSidebar;

    final modalWidth = screenWidth * 0.85 > 450 ? 450.0 : screenWidth * 0.85;
    final modalHeight = MediaQuery.of(context).size.height * 0.75;

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
                                    color: MediasfuColors.secondary
                                        .withOpacity(0.2),
                                    blurRadius: 40,
                                    spreadRadius: 8,
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
                                    _buildSettingSection(
                                      icon: Icons.mic_rounded,
                                      label: 'Participants Audio',
                                      description:
                                          'Control participant audio permissions',
                                      value: _audioState,
                                      onChanged: (v) =>
                                          setState(() => _audioState = v),
                                    ),
                                    _buildSettingSection(
                                      icon: Icons.videocam_rounded,
                                      label: 'Participants Video',
                                      description:
                                          'Control participant video permissions',
                                      value: _videoState,
                                      onChanged: (v) =>
                                          setState(() => _videoState = v),
                                    ),
                                    _buildSettingSection(
                                      icon: Icons.screen_share_rounded,
                                      label: 'Participants Screenshare',
                                      description:
                                          'Control participant screen sharing permissions',
                                      value: _screenshareState,
                                      onChanged: (v) =>
                                          setState(() => _screenshareState = v),
                                    ),
                                    _buildSettingSection(
                                      icon: Icons.chat_bubble_rounded,
                                      label: 'Chat',
                                      description:
                                          'Control participant chat permissions',
                                      value: _chatState,
                                      onChanged: (v) =>
                                          setState(() => _chatState = v),
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

  Widget _buildHeader() {
    return ModalHeader(
      icon: Icons.settings_rounded,
      title: 'Event Settings',
      onClose: _handleClose,
      isDarkMode: widget.options.isDarkMode,
      gradientColors: [
        MediasfuColors.secondary,
        MediasfuColors.secondary.withOpacity(0.7),
      ],
    );
  }

  Widget _buildSettingSection({
    required IconData icon,
    required String label,
    required String description,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return SectionCard(
      isDarkMode: widget.options.isDarkMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(MediasfuSpacing.sm),
                decoration: BoxDecoration(
                  color: _getStateColor(value).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: _getStateColor(value),
                  size: 18,
                ),
              ),
              const SizedBox(width: MediasfuSpacing.sm),
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
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.options.isDarkMode
                            ? Colors.white54
                            : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: MediasfuSpacing.md),
          Row(
            children: [
              _buildStateOption(
                label: 'Disallow',
                isSelected: value == 'disallow',
                color: MediasfuColors.danger,
                onTap: () => onChanged('disallow'),
              ),
              const SizedBox(width: MediasfuSpacing.sm),
              _buildStateOption(
                label: 'Allow',
                isSelected: value == 'allow',
                color: MediasfuColors.success,
                onTap: () => onChanged('allow'),
              ),
              const SizedBox(width: MediasfuSpacing.sm),
              _buildStateOption(
                label: 'Approval',
                isSelected: value == 'approval',
                color: MediasfuColors.warning,
                onTap: () => onChanged('approval'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStateOption({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: MediasfuSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.2)
                : (widget.options.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? color
                  : (widget.options.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? color
                    : (widget.options.isDarkMode
                        ? Colors.white70
                        : Colors.black54),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
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

  /// Sidebar mode: render content without backdrop/positioning/visibility wrapper
  Widget _buildSidebarContent() {
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(MediasfuSpacing.md),
              child: StaggeredAnimationList(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: MediasfuSpacing.md,
                children: [
                  _buildSettingSection(
                    icon: Icons.mic_rounded,
                    label: 'Participants Audio',
                    description: 'Control participant audio permissions',
                    value: _audioState,
                    onChanged: (v) => setState(() => _audioState = v),
                  ),
                  _buildSettingSection(
                    icon: Icons.videocam_rounded,
                    label: 'Participants Video',
                    description: 'Control participant video permissions',
                    value: _videoState,
                    onChanged: (v) => setState(() => _videoState = v),
                  ),
                  _buildSettingSection(
                    icon: Icons.screen_share_rounded,
                    label: 'Participants Screenshare',
                    description:
                        'Control participant screen sharing permissions',
                    value: _screenshareState,
                    onChanged: (v) => setState(() => _screenshareState = v),
                  ),
                  _buildSettingSection(
                    icon: Icons.chat_bubble_rounded,
                    label: 'Chat',
                    description: 'Control participant chat permissions',
                    value: _chatState,
                    onChanged: (v) => setState(() => _chatState = v),
                  ),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }
}
