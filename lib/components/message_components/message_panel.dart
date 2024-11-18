import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/message_methods/send_message.dart'
    show sendMessage, SendMessageType, SendMessageOptions;
import '../../types/types.dart'
    show CoHostResponsibility, EventType, Message, Participant, ShowAlert;
import 'package:flutter/foundation.dart';

/// MessagePanelOptions - Encapsulates all parameters and callbacks for MessagePanel.
class MessagePanelOptions {
  final List<Message> messages;
  final int messagesLength;
  final String type; // 'direct' or 'group'
  final String username;
  final SendMessageType onSendMessagePress;
  final Color backgroundColor;
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

  MessagePanelOptions({
    required this.messages,
    required this.messagesLength,
    required this.type,
    required this.username,
    this.onSendMessagePress = sendMessage,
    this.backgroundColor = const Color(0xFFF5F5F5),
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
  });
}

typedef MessagePanelType = MessagePanel Function(MessagePanelOptions options);

/// `MessagePanel` provides a UI for displaying and sending messages in an event or chat context.
/// It includes group and direct messaging capabilities, allowing the user to reply to messages
/// or send group messages, depending on configuration.
///
/// ### Parameters:
/// - `MessagePanelOptions` `options`: Configures the message panel, including settings
///   for sending messages, message display, and message reply functionality.
///   - `messages`: List of `Message` objects to display.
///   - `type`: String representing the message type (`'direct'` or `'group'`).
///   - `onSendMessagePress`: Callback for sending a message.
///   - `backgroundColor`: Background color for the panel.
///   - `focusedInput`: Whether the input field should be focused initially.
///   - `eventType`, `member`, `islevel`: Event information and user role level.
///   - `directMessageDetails`: Details of the user to whom a direct message is addressed.
///   - `socket`: Socket instance for real-time communication.
///   - `showAlert`: Optional callback to display alerts.
///
/// ### Main Components:
/// - `MessageBubble`: Represents an individual message in the list, showing sender details,
///   timestamp, and message content. Includes a reply button for certain roles.
/// - `MessageInput`: Provides an input field for typing messages, with an optional reply mode.
///
/// ### Key Functions:
/// - `_handleSendButton`: Validates and sends the message. If a message reply is required,
///   it ensures a target message is selected.
/// - `_focusInputAndSetReplyInfo` and `_clearReplyInfoAndInput`: Manage reply information,
///   focusing the input field on specific messages or clearing it.
///
/// ### Example Usage:
/// ```dart
/// MessagePanel(
///   options: MessagePanelOptions(
///     messages: myMessages,
///     type: 'group',
///     username: 'User123',
///     onSendMessagePress: (SendMessageOptions options) {
///       // Define your send message logic here
///     },
///     member: 'User123',
///     islevel: '2',
///     roomName: 'MainRoom',
///     socket: mySocket,
///     chatSetting: 'default',
///     coHost: 'CoHostName',
///     coHostResponsibility: [CoHostResponsibility(name: 'message', value: true)],
///     eventType: EventType.chat,
///     messagesLength: myMessages.length,
///   ),
/// ),
/// ```
///
/// ### Message Components:
///
/// - **MessageBubble**: Displays individual messages, showing sender details and the option
///   to reply for certain users.
/// - **MessageInput**: Input field for composing messages. It automatically sets the placeholder text
///   based on whether it's a group or direct message, and whether a reply is active.
///
/// ### Dependencies:
/// Requires the following imports:
/// ```dart
/// import 'package:flutter/material.dart';
/// import '../../methods/message_methods/send_message.dart' show sendMessage;
/// import '../../types/types.dart' show CoHostResponsibility, EventType, Message, Participant;
/// ```

class MessagePanel extends StatefulWidget {
  final MessagePanelOptions options;

  const MessagePanel({super.key, required this.options});

  @override
  _MessagePanelState createState() => _MessagePanelState();
}

class _MessagePanelState extends State<MessagePanel> {
  final ValueNotifier<Map<String, String>?> _replyInfoNotifier =
      ValueNotifier(null);
  final ValueNotifier<String?> _senderId = ValueNotifier(null);
  final ValueNotifier<String> _directMessageText = ValueNotifier('');
  final ValueNotifier<String> _groupMessageText = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    _handleEffect();
  }

  @override
  void didUpdateWidget(covariant MessagePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.startDirectMessage !=
            widget.options.startDirectMessage ||
        oldWidget.options.directMessageDetails !=
            widget.options.directMessageDetails) {
      _handleEffect();
    }
  }

  /// Handles initial setup and updates based on direct message flags.
  void _handleEffect() {
    if (widget.options.startDirectMessage &&
        widget.options.directMessageDetails != null &&
        widget.options.directMessageDetails!.name.isNotEmpty) {
      _focusInputAndSetReplyInfo(widget.options.directMessageDetails!);
    } else {
      _clearReplyInfoAndInput();
    }
  }

  /// Focuses the input field and sets reply information.
  void _focusInputAndSetReplyInfo(Participant directMessageDetails) {
    if (directMessageDetails.name.isEmpty) {
      return;
    }
    _replyInfoNotifier.value = {
      'text': 'Replying to: ',
      'username': directMessageDetails.name,
    };
    _senderId.value = directMessageDetails.name;
  }

  /// Clears reply information and input fields.
  void _clearReplyInfoAndInput() {
    _replyInfoNotifier.value = null;
    _senderId.value = null;
    _directMessageText.value = '';
    _groupMessageText.value = '';
  }

  /// Handles the send button press.
  Future<void> _handleSendButton() async {
    final String message = widget.options.type == 'direct'
        ? _directMessageText.value
        : _groupMessageText.value;

    // Accessing necessary variables from parameters
    final ShowAlert? showAlert = widget.options.showAlert;
    final String islevel = widget.options.islevel;
    final void Function(bool) updateStartDirectMessage =
        widget.options.updateStartDirectMessage;
    final void Function(Participant?) updateDirectMessageDetails =
        widget.options.updateDirectMessageDetails;

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
      group: widget.options.type == 'group' ? true : false,
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
    if (widget.options.type == 'direct') {
      _directMessageText.value = '';
    } else {
      _groupMessageText.value = '';
    }

    // Clear reply info
    _clearReplyInfoAndInput();

    // Update direct message state if necessary
    if (widget.options.startDirectMessage &&
        widget.options.directMessageDetails != null) {
      updateStartDirectMessage(false);
      updateDirectMessageDetails(
          Participant(name: '', audioID: '', videoID: ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Messages List
        Expanded(
          child: ListView.builder(
            itemCount: widget.options.messages.length,
            itemBuilder: (context, index) {
              final message = widget.options.messages[index];
              return MessageBubble(
                message: message,
                username: widget.options.username,
                onReply: () => _openReplyInput(message.sender),
                replyInfoNotifier: _replyInfoNotifier,
                setReplyInfo: _setReplyInfo,
                youAreCoHost: widget.options.youAreCoHost,
                islevel: widget.options.islevel,
                eventType: widget.options.eventType,
              );
            },
          ),
        ),

        // Reply Info
        ValueListenableBuilder<Map<String, String>?>(
          valueListenable: _replyInfoNotifier,
          builder: (context, replyInfo, _) {
            return replyInfo != null
                ? Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${replyInfo['text']} ${replyInfo['username']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : const SizedBox();
          },
        ),

        // Message Input
        ValueListenableBuilder<Map<String, String>?>(
          valueListenable: _replyInfoNotifier,
          builder: (context, replyInfo, _) {
            return MessageInput(
              type: widget.options.type,
              focusedInput: widget.options.focusedInput,
              onHandleMessagePress: _handleSendButton,
              isDirectMessage: widget.options.type == 'direct',
              isFocused: replyInfo != null,
              directMessageText: _directMessageText,
              groupMessageText: _groupMessageText,
              senderId: _senderId,
            );
          },
        ),
      ],
    );
  }

  /// Opens the reply input for a specific sender.
  void _openReplyInput(String senderId) {
    _replyInfoNotifier.value = {
      'text': 'Replying to: ',
      'username': senderId,
    };
    _senderId.value = senderId;
  }

  /// Sets the reply information.
  void _setReplyInfo(Map<String, String>? info) {
    _replyInfoNotifier.value = info;
  }

  @override
  void dispose() {
    _replyInfoNotifier.dispose();
    _senderId.dispose();
    _directMessageText.dispose();
    _groupMessageText.dispose();
    super.dispose();
  }
}

/// MessageBubble - Displays individual messages with optional reply functionality.
class MessageBubble extends StatelessWidget {
  final Message message;
  final String username;
  final VoidCallback onReply;
  final ValueNotifier<Map<String, String>?> replyInfoNotifier;
  final Function(Map<String, String>?) setReplyInfo;
  final bool youAreCoHost;
  final String islevel;
  final EventType eventType;

  const MessageBubble({
    super.key,
    required this.message,
    required this.username,
    required this.onReply,
    required this.replyInfoNotifier,
    required this.setReplyInfo,
    this.youAreCoHost = false,
    this.islevel = '1',
    this.eventType = EventType.none,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelfMessage = message.sender == username;
    final bool isGroupMessage = message.group;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        crossAxisAlignment:
            isSelfMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender and Timestamp Row
          Row(
            mainAxisAlignment:
                isSelfMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isGroupMessage)
                !isSelfMessage
                    ? Text(
                        '${message.sender} - ${message.timestamp}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      )
                    : Text(
                        message.timestamp,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      )
              else
                Row(
                  children: [
                    if (!isSelfMessage)
                      Text(
                        '${message.sender} - ${message.timestamp}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      )
                    else
                      islevel == '2' ||
                              (youAreCoHost && message.sender == username)
                          ? Text(
                              'To: ${message.receivers.join(", ")} - ${message.timestamp}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            )
                          : Text(
                              message.timestamp,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                    if (!isGroupMessage &&
                        !isSelfMessage &&
                        (youAreCoHost || islevel == '2'))
                      IconButton(
                        icon: const Icon(Icons.reply,
                            size: 12, color: Colors.black),
                        onPressed: onReply,
                      ),
                  ],
                ),
            ],
          ),

          // Message Bubble
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelfMessage ? Colors.blue[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message.message,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// MessageInput - Provides an input field and send button for composing messages.
class MessageInput extends StatelessWidget {
  final String type; // 'direct' or 'group'
  final bool focusedInput;
  final VoidCallback onHandleMessagePress;
  final bool isDirectMessage;
  final bool isFocused;
  final ValueNotifier<String> directMessageText;
  final ValueNotifier<String> groupMessageText;
  final ValueNotifier<String?> senderId;
  final String islevel;
  final bool youAreCoHost;
  final EventType eventType;

  MessageInput({
    super.key,
    required this.type,
    required this.focusedInput,
    required this.onHandleMessagePress,
    required this.isDirectMessage,
    required this.isFocused,
    required this.directMessageText,
    required this.groupMessageText,
    required this.senderId,
    this.islevel = '1',
    this.youAreCoHost = false,
    this.eventType = EventType.none,
  });

  // Controller to clear text field
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: const Border(
          top: BorderSide(color: Colors.grey),
        ),
      ),
      child: Row(
        children: [
          // Message Input Field
          Expanded(
            child: TextField(
              controller: _textEditingController,
              focusNode: FocusNode(), // Ensure focus node is properly handled
              onTap: () {
                if (!kIsWeb) {
                  // Set focus explicitly to ensure keyboard shows up
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              },
              onChanged: (value) {
                if (isDirectMessage) {
                  directMessageText.value = value;
                } else {
                  groupMessageText.value = value;
                }
              },
              decoration: InputDecoration(
                hintText: isDirectMessage
                    ? isFocused
                        ? 'Send a direct message to ${senderId.value}'
                        : (islevel == '2' || youAreCoHost)
                            ? 'Select a message to reply to'
                            : 'Send a direct message'
                    : eventType == EventType.chat
                        ? 'Send a message'
                        : 'Send a message to everyone',
                border: InputBorder.none,
              ),
              maxLength: 350,
            ),
          ),
          // Send Button
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              onHandleMessagePress();
              // Clear the text field after sending
              _textEditingController.clear();
            },
          ),
        ],
      ),
    );
  }
}
