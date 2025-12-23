import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/misc_components/share_event_modal.dart'
    show
        ShareEventModalOptions,
        ShareEventModalMeetingIdContext,
        ShareEventModalPasscodeContext,
        ShareEventModalShareButtonsContext;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../../components/menu_components/meeting_id_component.dart'
    show MeetingIdComponent, MeetingIdComponentOptions;
import '../../components/menu_components/meeting_passcode_component.dart'
    show MeetingPasscodeComponent, MeetingPasscodeComponentOptions;
import '../menu_components/modern_share_buttons_component.dart'
    show ModernShareButtonsComponent, ModernShareButtonsComponentOptions;

typedef ModernShareEventModalType = Widget Function(
    {required ShareEventModalOptions options});

/// Modern share event modal with glassmorphic design.
/// Uses the same [ShareEventModalOptions] as the original component.
class ModernShareEventModal extends StatefulWidget {
  final ShareEventModalOptions options;

  const ModernShareEventModal({super.key, required this.options});

  @override
  State<ModernShareEventModal> createState() => _ModernShareEventModalState();
}

class _ModernShareEventModalState extends State<ModernShareEventModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

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

  Widget _buildSectionLabel(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MediasfuSpacing.xs),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.75)
              : Colors.black.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      widget.options.onShareEventClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sidebar mode: render without backdrop/positioning
    if (widget.options.renderMode == ModalRenderMode.sidebar) {
      return _buildSidebarContent();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth * 0.85 > 400 ? 400.0 : screenWidth * 0.85;
    final modalHeight = MediaQuery.of(context).size.height * 0.6;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = screenWidth >= 1200;
    final shouldUseSidebar = isLandscape && isWide;
    final useHighTransparency = !shouldUseSidebar;

    // Determine background color with high transparency for modal mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = useHighTransparency
        ? (isDarkMode
            ? Colors.black.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.08))
        : (isDarkMode
            ? Colors.black.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.45));

    return Visibility(
      visible: widget.options.isShareEventModalVisible,
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
                    color: Colors.black.withValues(alpha: 0.05),
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
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: modalWidth,
                        // height: modalHeight, // Let content determine height
                        constraints: BoxConstraints(
                          maxHeight: modalHeight,
                        ),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withValues(
                                    alpha: useHighTransparency ? 0.08 : 0.1)
                                : Colors.black.withValues(
                                    alpha: useHighTransparency ? 0.05 : 0.1),
                          ),
                          boxShadow: useHighTransparency
                              ? []
                              : [
                                  BoxShadow(
                                    color: MediasfuColors.secondary
                                        .withValues(alpha: 0.2),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(isDarkMode),
                            Flexible(
                              child: SingleChildScrollView(
                                padding:
                                    const EdgeInsets.all(MediasfuSpacing.md),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMeetingIdSection(isDarkMode),
                                    if (widget.options.islevel == '2') ...[
                                      const SizedBox(
                                          height: MediasfuSpacing.md),
                                      _buildPasscodeSection(isDarkMode),
                                    ],
                                    if (widget.options.shareButtons) ...[
                                      const SizedBox(
                                          height: MediasfuSpacing.md),
                                      _buildShareButtonsSection(isDarkMode),
                                    ],
                                  ],
                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(MediasfuSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MediasfuColors.secondary,
                  MediasfuColors.secondary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: MediasfuColors.secondary.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.share_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: MediasfuSpacing.sm),
          Expanded(
            child: Text(
              'Share Event',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          IconButton(
            onPressed: _handleClose,
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingIdSection(bool isDarkMode) {
    final themeTextColor = isDarkMode ? Colors.white : Colors.black87;
    final themeLabelColor = isDarkMode ? Colors.white70 : Colors.black54;
    final themeInputBg = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF0F0F0);

    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.sm),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Meeting ID', isDarkMode),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MediasfuSpacing.sm,
              vertical: MediasfuSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: MediasfuColors.glassBorder(darkMode: isDarkMode),
              ),
            ),
            child: widget.options.meetingIdBuilder?.call(
                  ShareEventModalMeetingIdContext(
                    defaultMeetingId: MeetingIdComponent(
                      options: MeetingIdComponentOptions(
                        meetingID: widget.options.roomName,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeLabelColor,
                        ),
                        inputTextStyle: TextStyle(color: themeTextColor),
                        inputBackgroundColor: themeInputBg,
                      ),
                    ),
                    meetingId: widget.options.roomName,
                  ),
                ) ??
                MeetingIdComponent(
                  options: MeetingIdComponentOptions(
                    meetingID: widget.options.roomName,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeLabelColor,
                    ),
                    inputTextStyle: TextStyle(color: themeTextColor),
                    inputBackgroundColor: themeInputBg,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasscodeSection(bool isDarkMode) {
    final themeTextColor = isDarkMode ? Colors.white : Colors.black87;
    final themeLabelColor = isDarkMode ? Colors.white70 : Colors.black54;
    final themeInputBg = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF0F0F0);

    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.sm),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Admin Passcode', isDarkMode),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MediasfuSpacing.sm,
              vertical: MediasfuSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: MediasfuColors.glassBorder(darkMode: isDarkMode),
              ),
            ),
            child: widget.options.passcodeBuilder?.call(
                  ShareEventModalPasscodeContext(
                    defaultPasscode: MeetingPasscodeComponent(
                      options: MeetingPasscodeComponentOptions(
                        meetingPasscode: widget.options.adminPasscode,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeLabelColor,
                        ),
                        inputTextStyle: TextStyle(color: themeTextColor),
                        inputBackgroundColor: themeInputBg,
                      ),
                    ),
                    passcode: widget.options.adminPasscode,
                    isVisible: true,
                  ),
                ) ??
                MeetingPasscodeComponent(
                  options: MeetingPasscodeComponentOptions(
                    meetingPasscode: widget.options.adminPasscode,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeLabelColor,
                    ),
                    inputTextStyle: TextStyle(color: themeTextColor),
                    inputBackgroundColor: themeInputBg,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButtonsSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.sm),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Share', isDarkMode),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MediasfuSpacing.sm,
              vertical: MediasfuSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: MediasfuColors.glassBorder(darkMode: isDarkMode),
              ),
            ),
            child: widget.options.shareButtonsBuilder?.call(
                  ShareEventModalShareButtonsContext(
                    defaultShareButtons: ModernShareButtonsComponent(
                      options: ModernShareButtonsComponentOptions(
                        meetingID: widget.options.roomName,
                        eventType: widget.options.eventType,
                        localLink: widget.options.localLink,
                        compact: true,
                      ),
                    ),
                    isVisible: true,
                    meetingId: widget.options.roomName,
                    eventType: widget.options.eventType,
                    localLink: widget.options.localLink,
                  ),
                ) ??
                ModernShareButtonsComponent(
                  options: ModernShareButtonsComponentOptions(
                    meetingID: widget.options.roomName,
                    eventType: widget.options.eventType,
                    localLink: widget.options.localLink,
                    compact: true,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(MediasfuSpacing.md),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.share_rounded,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      size: 20,
                    ),
                    const SizedBox(width: MediasfuSpacing.sm),
                    Text(
                      'Share Event',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: widget.options.onShareEventClose,
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(MediasfuSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMeetingIdSection(isDarkMode),
                  if (widget.options.islevel == '2') ...[
                    const SizedBox(height: MediasfuSpacing.md),
                    _buildPasscodeSection(isDarkMode),
                  ],
                  if (widget.options.shareButtons) ...[
                    const SizedBox(height: MediasfuSpacing.md),
                    _buildShareButtonsSection(isDarkMode),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
