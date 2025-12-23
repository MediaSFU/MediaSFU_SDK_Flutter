import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/message_methods/send_message.dart'
    show sendMessage, SendMessageType, SendMessageOptions;
import '../../types/types.dart'
    show CoHostResponsibility, EventType, Message, Participant, ShowAlert;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

/// Configuration options for the modern message panel.
class ModernMessagePanelOptions {
  final List<Message> messages;
  final int messagesLength;
  final String type; // 'direct' or 'group'
  final String username;
  final SendMessageType onSendMessagePress;
  final Color? backgroundColor;
  final bool focusedInput;
  final ShowAlert? showAlert;
  final EventType eventType;
  final String member;
  final String islevel;
  final bool startDirectMessage;
  final Participant? directMessageDetails;
  final void Function(bool) updateStartDirectMessage;
  final void Function(Participant?) updateDirectMessageDetails;
  final List<CoHostResponsibility> coHostResponsibility;
  final String coHost;
  final String roomName;
  final io.Socket? socket;
  final String chatSetting;
  final bool youAreCoHost;

  // Modern styling options
  final bool enableGlassmorphism;
  final bool isDarkMode;
  final double borderRadius;

  ModernMessagePanelOptions({
    required this.messages,
    required this.messagesLength,
    required this.type,
    required this.username,
    this.onSendMessagePress = sendMessage,
    this.backgroundColor,
    this.focusedInput = false,
    this.showAlert,
    required this.eventType,
    required this.member,
    required this.islevel,
    required this.startDirectMessage,
    this.directMessageDetails,
    required this.updateStartDirectMessage,
    required this.updateDirectMessageDetails,
    required this.coHostResponsibility,
    required this.coHost,
    required this.roomName,
    this.socket,
    required this.chatSetting,
    required this.youAreCoHost,
    // Modern defaults
    this.enableGlassmorphism = true,
    this.isDarkMode = true,
    this.borderRadius = 16.0,
  });
}

typedef ModernMessagePanelType = ModernMessagePanel Function(
    ModernMessagePanelOptions options);

/// A modern glassmorphic message panel with smooth animations and refined styling.
///
/// Features:
/// - Glassmorphic message bubbles with blur effects
/// - Animated message appearance
/// - Modern input field with gradient accents
/// - Reply indicator with smooth transitions
/// - Dark/light mode support
class ModernMessagePanel extends StatefulWidget {
  final ModernMessagePanelOptions options;

  const ModernMessagePanel({super.key, required this.options});

  @override
  State<ModernMessagePanel> createState() => _ModernMessagePanelState();
}

class _ModernMessagePanelState extends State<ModernMessagePanel>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<Map<String, String>?> _replyInfoNotifier =
      ValueNotifier(null);
  final ValueNotifier<String?> _senderId = ValueNotifier(null);
  final ValueNotifier<String> _directMessageText = ValueNotifier('');
  final ValueNotifier<String> _groupMessageText = ValueNotifier('');
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _handleEffect();
  }

  @override
  void didUpdateWidget(covariant ModernMessagePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.startDirectMessage !=
            widget.options.startDirectMessage ||
        oldWidget.options.directMessageDetails !=
            widget.options.directMessageDetails) {
      _handleEffect();
    }

    // Auto-scroll when new messages arrive
    if (oldWidget.options.messages.length < widget.options.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _handleEffect() {
    if (widget.options.startDirectMessage &&
        widget.options.directMessageDetails != null &&
        widget.options.directMessageDetails!.name.isNotEmpty) {
      _focusInputAndSetReplyInfo(widget.options.directMessageDetails!);
    } else {
      _clearReplyInfoAndInput();
    }
  }

  void _focusInputAndSetReplyInfo(Participant directMessageDetails) {
    if (directMessageDetails.name.isEmpty) return;
    _replyInfoNotifier.value = {
      'text': 'Replying to: ',
      'username': directMessageDetails.name,
    };
    _senderId.value = directMessageDetails.name;
  }

  void _clearReplyInfoAndInput() {
    _replyInfoNotifier.value = null;
    _senderId.value = null;
    _directMessageText.value = '';
    _groupMessageText.value = '';
    _textController.clear();
  }

  Future<void> _handleSendButton() async {
    final String message = widget.options.type == 'direct'
        ? _directMessageText.value
        : _groupMessageText.value;

    final ShowAlert? showAlert = widget.options.showAlert;
    final String islevel = widget.options.islevel;

    // Validation
    if (message.isEmpty) {
      showAlert?.call(
        message: 'Please enter a message',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    if (message.length > 350) {
      showAlert?.call(
        message: 'Message is too long',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    if (message.trim().isEmpty) {
      showAlert?.call(
        message: 'Message is not valid.',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    if (widget.options.type == 'direct' &&
        _senderId.value == null &&
        islevel == '2') {
      showAlert?.call(
        message: 'Please select a message to reply to',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    // Send the message
    await widget.options.onSendMessagePress(SendMessageOptions(
      message: message,
      receivers: widget.options.type == 'direct' && _senderId.value != null
          ? [_senderId.value!]
          : [],
      group: widget.options.type == 'group',
      messagesLength: widget.options.messagesLength,
      member: widget.options.member,
      sender: widget.options.username,
      islevel: widget.options.islevel,
      showAlert: widget.options.showAlert,
      coHostResponsibility: widget.options.coHostResponsibility,
      coHost: widget.options.coHost,
      roomName: widget.options.roomName,
      socket: widget.options.socket,
      chatSetting: widget.options.chatSetting,
    ));

    // Clear message text
    _textController.clear();
    if (widget.options.type == 'direct') {
      _directMessageText.value = '';
    } else {
      _groupMessageText.value = '';
    }

    _clearReplyInfoAndInput();

    if (widget.options.startDirectMessage &&
        widget.options.directMessageDetails != null) {
      widget.options.updateStartDirectMessage(false);
      widget.options.updateDirectMessageDetails(
          Participant(name: '', audioID: '', videoID: ''));
    }
  }

  void _openReplyInput(String senderId) {
    _replyInfoNotifier.value = {
      'text': 'Replying to: ',
      'username': senderId,
    };
    _senderId.value = senderId;
  }

  @override
  void dispose() {
    _replyInfoNotifier.dispose();
    _senderId.dispose();
    _directMessageText.dispose();
    _groupMessageText.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.options.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: widget.options.backgroundColor ??
            (isDark ? const Color(0xFF1A1A2E) : Colors.grey[100]),
        borderRadius: BorderRadius.circular(widget.options.borderRadius),
      ),
      child: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(MediasfuSpacing.md),
              itemCount: widget.options.messages.length,
              itemBuilder: (context, index) {
                final message = widget.options.messages[index];
                return _ModernMessageBubble(
                  message: message,
                  username: widget.options.username,
                  onReply: () => _openReplyInput(message.sender),
                  youAreCoHost: widget.options.youAreCoHost,
                  islevel: widget.options.islevel,
                  eventType: widget.options.eventType,
                  enableGlassmorphism: widget.options.enableGlassmorphism,
                  isDarkMode: isDark,
                );
              },
            ),
          ),

          // Reply Info
          ValueListenableBuilder<Map<String, String>?>(
            valueListenable: _replyInfoNotifier,
            builder: (context, replyInfo, _) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: replyInfo != null ? 40 : 0,
                child: replyInfo != null
                    ? _buildReplyIndicator(replyInfo, isDark)
                    : const SizedBox(),
              );
            },
          ),

          // Message Input
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  Widget _buildReplyIndicator(Map<String, String> replyInfo, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: MediasfuSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.md,
        vertical: MediasfuSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MediasfuColors.primary.withValues(alpha: 0.2),
            MediasfuColors.secondary.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: MediasfuColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            size: 16,
            color: MediasfuColors.primary,
          ),
          const SizedBox(width: MediasfuSpacing.xs),
          Expanded(
            child: Text(
              '${replyInfo['text']}${replyInfo['username']}',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: _clearReplyInfoAndInput,
            child: Icon(
              Icons.close,
              size: 18,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    final isDirectMessage = widget.options.type == 'direct';

    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: widget.options.enableGlassmorphism
                  ? BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: _buildTextField(isDark, isDirectMessage),
                    )
                  : _buildTextField(isDark, isDirectMessage),
            ),
          ),
          const SizedBox(width: MediasfuSpacing.sm),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildTextField(bool isDark, bool isDirectMessage) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        controller: _textController,
        onChanged: (value) {
          if (isDirectMessage) {
            _directMessageText.value = value;
          } else {
            _groupMessageText.value = value;
          }
        },
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
        maxLength: 350,
        maxLines: 3,
        minLines: 1,
        decoration: InputDecoration(
          hintText: _getHintText(isDirectMessage),
          hintStyle: TextStyle(
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: MediasfuSpacing.md,
            vertical: MediasfuSpacing.sm,
          ),
          counterText: '',
        ),
      ),
    );
  }

  String _getHintText(bool isDirectMessage) {
    if (isDirectMessage) {
      if (_senderId.value != null) {
        return 'Send a direct message to ${_senderId.value}';
      }
      return (widget.options.islevel == '2' || widget.options.youAreCoHost)
          ? 'Select a message to reply to'
          : 'Send a direct message';
    }
    return widget.options.eventType == EventType.chat
        ? 'Send a message'
        : 'Send a message to everyone';
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _handleSendButton,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient:
              MediasfuColors.brandGradient(darkMode: widget.options.isDarkMode),
          shape: BoxShape.circle,
          boxShadow: MediasfuColors.glowShadow(
            MediasfuColors.primary,
            intensity: 0.4,
          ),
        ),
        child: const Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

/// Modern message bubble with glassmorphic styling
class _ModernMessageBubble extends StatelessWidget {
  final Message message;
  final String username;
  final VoidCallback onReply;
  final bool youAreCoHost;
  final String islevel;
  final EventType eventType;
  final bool enableGlassmorphism;
  final bool isDarkMode;

  const _ModernMessageBubble({
    required this.message,
    required this.username,
    required this.onReply,
    this.youAreCoHost = false,
    this.islevel = '1',
    this.eventType = EventType.none,
    this.enableGlassmorphism = true,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelfMessage = message.sender == username;
    final bool isGroupMessage = message.group;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MediasfuSpacing.xs),
      child: Column(
        crossAxisAlignment:
            isSelfMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender and Timestamp Row
          _buildHeader(isSelfMessage, isGroupMessage),
          const SizedBox(height: 4),
          // Message Bubble
          _buildMessageBubble(isSelfMessage),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSelfMessage, bool isGroupMessage) {
    final showReplyButton =
        !isGroupMessage && !isSelfMessage && (youAreCoHost || islevel == '2');

    return Row(
      mainAxisAlignment:
          isSelfMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (isGroupMessage)
          Text(
            isSelfMessage
                ? message.timestamp
                : '${message.sender} • ${message.timestamp}',
            style: TextStyle(
              fontSize: 11,
              color: (isDarkMode ? Colors.white : Colors.black)
                  .withValues(alpha: 0.5),
            ),
          )
        else
          Row(
            children: [
              Text(
                isSelfMessage
                    ? (islevel == '2' ||
                            (youAreCoHost && message.sender == username))
                        ? 'To: ${message.receivers.join(", ")} • ${message.timestamp}'
                        : message.timestamp
                    : '${message.sender} • ${message.timestamp}',
                style: TextStyle(
                  fontSize: 11,
                  color: (isDarkMode ? Colors.white : Colors.black)
                      .withValues(alpha: 0.5),
                ),
              ),
              if (showReplyButton) ...[
                const SizedBox(width: MediasfuSpacing.xs),
                GestureDetector(
                  onTap: onReply,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: MediasfuColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.reply,
                      size: 14,
                      color: MediasfuColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildMessageBubble(bool isSelfMessage) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
        bottomLeft: Radius.circular(isSelfMessage ? 16 : 4),
        bottomRight: Radius.circular(isSelfMessage ? 4 : 16),
      ),
      child: enableGlassmorphism
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: _buildBubbleContent(isSelfMessage),
            )
          : _buildBubbleContent(isSelfMessage),
    );
  }

  Widget _buildBubbleContent(bool isSelfMessage) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.md,
        vertical: MediasfuSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: isSelfMessage
            ? MediasfuColors.brandGradient(darkMode: isDarkMode)
            : null,
        color: isSelfMessage
            ? null
            : (isDarkMode ? Colors.white : Colors.black)
                .withValues(alpha: 0.08),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isSelfMessage ? 18 : 4),
          bottomRight: Radius.circular(isSelfMessage ? 4 : 18),
        ),
        border: isSelfMessage
            ? null
            : Border.all(
                color: (isDarkMode ? Colors.white : Colors.black)
                    .withValues(alpha: 0.1),
              ),
        boxShadow: isSelfMessage
            ? [
                BoxShadow(
                  color: MediasfuColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      constraints: const BoxConstraints(maxWidth: 280),
      child: Text(
        message.message,
        style: TextStyle(
          color: isSelfMessage
              ? Colors.white
              : (isDarkMode ? Colors.white : Colors.black87),
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}
