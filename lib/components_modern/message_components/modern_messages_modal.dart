import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../components/message_components/messages_modal.dart'
    show MessagesModalOptions;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import 'modern_message_panel.dart'
    show ModernMessagePanel, ModernMessagePanelOptions;
import '../../types/types.dart' show EventType, Message;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

typedef ModernMessagesModalType = ModernMessagesModal Function({
  required MessagesModalOptions options,
});

/// Modern tabbed chat interface with glassmorphic design.
/// Uses the same [MessagesModalOptions] as the original component.
class ModernMessagesModal extends StatefulWidget {
  final MessagesModalOptions options;

  const ModernMessagesModal({super.key, required this.options});

  @override
  State<ModernMessagesModal> createState() => _ModernMessagesModalState();
}

class _ModernMessagesModalState extends State<ModernMessagesModal>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<String> activeTab;
  late List<Message> directMessages;
  late List<Message> groupMessages;
  late ValueNotifier<bool> focusedInput;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    activeTab = ValueNotifier(widget.options.eventType == EventType.webinar ||
            widget.options.eventType == EventType.conference
        ? 'direct'
        : 'group');
    _populateMessages();
    focusedInput = ValueNotifier(widget.options.startDirectMessage &&
        widget.options.directMessageDetails != null &&
        (widget.options.eventType == EventType.webinar ||
            widget.options.eventType == EventType.conference));

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
  void didUpdateWidget(ModernMessagesModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.messages != widget.options.messages) {
      _populateMessages();
    }
  }

  void _populateMessages() {
    final chatValue = widget.options.coHostResponsibility
        .any((item) => item.name == 'chat' && item.value);

    directMessages = widget.options.messages
        .where((message) =>
            !message.group &&
            (message.sender == widget.options.member ||
                message.receivers.contains(widget.options.member) ||
                widget.options.islevel == '2' ||
                (widget.options.coHost == widget.options.member && chatValue)))
        .toList();

    groupMessages =
        widget.options.messages.where((message) => message.group).toList();
  }

  @override
  void dispose() {
    activeTab.dispose();
    focusedInput.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For sidebar or inline mode, render content directly without modal wrapper
    if (widget.options.renderMode == ModalRenderMode.sidebar ||
        widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = screenWidth >= 1200;
    final shouldUseSidebar = isLandscape && isWide;

    final useHighTransparency = !shouldUseSidebar;

    final modalWidth = screenWidth * 0.85 > 450 ? 450.0 : screenWidth * 0.85;
    final modalHeight = kIsWeb ? screenHeight * 0.75 : screenHeight * 0.6;

    return Visibility(
      visible: widget.options.isMessagesModalVisible,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Backdrop
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.options.onMessagesClose,
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
                      filter: widget.options.enableGlassmorphism
                          ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                          : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: Container(
                        width: modalWidth,
                        height: modalHeight,
                        decoration: BoxDecoration(
                          // For live events (webinar/chat) on smaller screens, use ~95% transparency
                          // so users can still see the video feed behind the messages
                          color: useHighTransparency
                              ? (widget.options.isDarkMode
                                  ? Colors.black.withValues(alpha: 0.05)
                                  : Colors.white.withValues(alpha: 0.08))
                              : (widget.options.isDarkMode
                                  ? Colors.black.withValues(alpha: 0.7)
                                  : Colors.white.withValues(alpha: 0.9)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.options.isDarkMode
                                ? Colors.white.withValues(
                                    alpha: useHighTransparency ? 0.08 : 0.15)
                                : Colors.black.withValues(
                                    alpha: useHighTransparency ? 0.05 : 0.1),
                          ),
                          boxShadow: useHighTransparency
                              ? [] // No shadow for high transparency mode
                              : [
                                  BoxShadow(
                                    color: MediasfuColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                  BoxShadow(
                                    color: MediasfuColors.secondary
                                        .withValues(alpha: 0.15),
                                    blurRadius: 60,
                                    spreadRadius: 10,
                                    offset: const Offset(10, 20),
                                  ),
                                ],
                        ),
                        child: Column(
                          children: [
                            _buildHeader(),
                            Expanded(child: _buildTabContent()),
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
        Expanded(child: _buildTabContent()),
      ],
    );
  }

  Widget _buildHeader() {
    final showTabs = widget.options.eventType == EventType.webinar ||
        widget.options.eventType == EventType.conference;

    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.options.isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Title with glow
          Container(
            padding: const EdgeInsets.all(MediasfuSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MediasfuColors.primary,
                  MediasfuColors.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: MediasfuColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: MediasfuSpacing.sm),
          Text(
            'Messages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.options.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const Spacer(),

          // Tabs
          if (showTabs) ...[
            _buildTabButton('Direct', 'direct'),
            const SizedBox(width: MediasfuSpacing.xs),
            _buildTabButton('Group', 'group'),
            const SizedBox(width: MediasfuSpacing.sm),
          ],

          // Close button
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, String tab) {
    return ValueListenableBuilder<String>(
      valueListenable: activeTab,
      builder: (context, value, child) {
        final isActive = value == tab;
        final tooltipMessage = tab == 'direct'
            ? 'Direct Messages - Private one-on-one conversations'
            : 'Group Messages - Messages visible to all participants';
        return Tooltip(
          message: tooltipMessage,
          decoration: MediasfuColors.tooltipDecoration(
              darkMode: widget.options.isDarkMode),
          textStyle: TextStyle(
            color:
                MediasfuColors.tooltipText(darkMode: widget.options.isDarkMode),
            fontSize: 12,
          ),
          child: GestureDetector(
            onTap: () => activeTab.value = tab,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: MediasfuSpacing.md,
                vertical: MediasfuSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          MediasfuColors.primary,
                          MediasfuColors.secondary,
                        ],
                      )
                    : null,
                color: isActive
                    ? null
                    : (widget.options.isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isActive
                      ? Colors.white
                      : (widget.options.isDarkMode
                          ? Colors.white70
                          : Colors.black54),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCloseButton() {
    return Tooltip(
      message: 'Close messages panel',
      decoration:
          MediasfuColors.tooltipDecoration(darkMode: widget.options.isDarkMode),
      textStyle: TextStyle(
        color: MediasfuColors.tooltipText(darkMode: widget.options.isDarkMode),
        fontSize: 12,
      ),
      child: GestureDetector(
        onTap: () {
          _animationController.reverse().then((_) {
            widget.options.onMessagesClose();
          });
        },
        child: Container(
          padding: const EdgeInsets.all(MediasfuSpacing.sm),
          decoration: BoxDecoration(
            color: widget.options.isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.close_rounded,
            color: widget.options.isDarkMode ? Colors.white70 : Colors.black54,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return ValueListenableBuilder<String>(
      valueListenable: activeTab,
      builder: (context, value, child) {
        final isDirectTab = value == 'direct' &&
            (widget.options.eventType == EventType.webinar ||
                widget.options.eventType == EventType.conference);

        final optionsPanel = ModernMessagePanelOptions(
          messages: isDirectTab ? directMessages : groupMessages,
          messagesLength: widget.options.messages.length,
          type: isDirectTab ? 'direct' : 'group',
          onSendMessagePress: widget.options.onSendMessagePress,
          username: widget.options.member,
          backgroundColor: widget.options.isDarkMode
              ? const Color(0xFF1A1A2E)
              : Colors.white,
          focusedInput: focusedInput.value,
          showAlert: widget.options.showAlert,
          eventType: widget.options.eventType,
          member: widget.options.member,
          islevel: widget.options.islevel,
          coHostResponsibility: widget.options.coHostResponsibility,
          coHost: widget.options.coHost,
          directMessageDetails: widget.options.directMessageDetails,
          updateStartDirectMessage: widget.options.updateStartDirectMessage,
          updateDirectMessageDetails: widget.options.updateDirectMessageDetails,
          roomName: widget.options.roomName,
          socket: widget.options.socket,
          chatSetting: widget.options.chatSetting,
          startDirectMessage: widget.options.startDirectMessage,
          youAreCoHost: widget.options.coHost == widget.options.member,
          enableGlassmorphism: true,
          isDarkMode: widget.options.isDarkMode,
        );

        return Padding(
          padding: const EdgeInsets.all(MediasfuSpacing.sm),
          child: ModernMessagePanel(options: optionsPanel),
        );
      },
    );
  }
}
