import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../methods/message_methods/send_message.dart' show sendMessage;

/// MessagePanel - A panel for displaying and interacting with messages.
///
/// This panel displays a list of messages and allows users to send new messages.
///
/// The list of messages to be displayed.
/// final List<dynamic> messages;
///
/// The number of messages.
/// final int messagesLength;
///
/// The type of the panel, e.g., 'direct' or 'group'.
/// final String type;
///
/// The username of the current user.
/// final String username;
///
/// The function called when the send message button is pressed.
/// final SendMessage onSendMessagePress;
///
/// Additional parameters for sending messages.
/// final Map<String, dynamic> parameters;
///
/// The background color of the panel.
/// final Color backgroundColor;
///
/// Whether the input field is focused.
/// final bool focusedInput;
///
/// MessageBubble - A widget for displaying a message bubble.
///
/// This widget displays a message bubble with the sender's name, timestamp,
/// and message content.
///
/// The message data to be displayed.
/// final Map<String, dynamic> message;
///
/// The username of the current user.
/// final String username;
///
/// The function called when the reply button is pressed.
/// final Function() onReply;
///
/// A notifier for reply information changes.
/// final ValueNotifier<Map<String, String>?> replyInfoNotifier;
///
/// A function to set reply information.
/// final Function(Map<String, String>?) setReplyInfo;
///
/// Whether the current user is a co-host.
/// final bool youAreCoHost;
///
/// The level of the current user.
/// final String islevel;
///
/// The type of event.
/// final String eventType;
///
/// MessageInput - A widget for entering and sending messages.
///
/// This widget displays an input field for entering messages and a send button.
///
/// The type of the panel, e.g., 'direct' or 'group'.
/// final String type;
///
/// Whether the input field is focused.
/// final bool focusedInput;
///
/// The function called when the send message button is pressed.
/// final Function() onHandleMessagePress;
///
/// Whether it's a direct message.
/// final bool isDirectMessage;
///
/// Whether the input field is focused.
/// final bool isFocused;
///
/// A notifier for direct message text changes.
/// final ValueNotifier<String> directMessageText;
///
/// A notifier for group message text changes.
/// final ValueNotifier<String> groupMessageText;
///
/// A notifier for sender ID changes.
/// final ValueNotifier<String?> senderId;
///
/// The level of the current user.
/// final String islevel;
///
/// Whether the current user is a co-host.
/// final bool youAreCoHost;
///
/// The type of event.
/// final String eventType;

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef SendMessage = Future<void> Function(
    {required Map<String, dynamic> parameters});

typedef UpdateStartDirectMessage = void Function(bool value);
typedef UpdateDirectMessageDetails = void Function(Map<String, dynamic> value);

class MessagePanel extends StatefulWidget {
  final List<dynamic> messages;
  final int messagesLength;
  final String type;
  final String username;
  final SendMessage onSendMessagePress;
  final Map<String, dynamic> parameters;
  final Color backgroundColor;
  final bool focusedInput;

  const MessagePanel({
    super.key,
    required this.messages,
    required this.messagesLength,
    required this.type,
    required this.username,
    this.onSendMessagePress = sendMessage,
    required this.parameters,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.focusedInput = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MessagePanelState createState() => _MessagePanelState();
}

class _MessagePanelState extends State<MessagePanel> {
  final ValueNotifier<Map<String, String>?> _replyInfoNotifier =
      ValueNotifier(null);

  void _setReplyInfo(Map<String, String>? info) {
    _replyInfoNotifier.value = info;
  }

  void openReplyInput(String senderId) {
    _setReplyInfo({
      'text': 'Replying to: ',
      'username': senderId,
    });
    _senderId.value = senderId;
  }

  void handleSendButton() async {
    // Accessing necessary variables from parameters
    final ShowAlert? showAlert = widget.parameters['showAlert'];
    final String islevel = widget.parameters['islevel'];
    final UpdateStartDirectMessage updateStartDirectMessage =
        widget.parameters['updateStartDirectMessage'];
    final UpdateDirectMessageDetails updateDirectMessageDetails =
        widget.parameters['updateDirectMessageDetails'];

    // Logic for handling send button press
    final ValueNotifier<String> directMessageText =
        widget.type == 'direct' ? _directMessageText : _groupMessageText;
    final String message = directMessageText.value;

    if (message.isEmpty) {
      if (showAlert != null) {
        showAlert(
          message: 'Please enter a message',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    if (message.length > 350) {
      if (showAlert != null) {
        showAlert(
          message: 'Message is too long',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    if (message.trim().isEmpty) {
      if (showAlert != null) {
        showAlert(
          message: 'Message is not valid.',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    if (widget.type == 'direct' && _senderId.value == null && islevel == '2') {
      if (showAlert != null) {
        showAlert(
          message: 'Please select a message to reply to',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    await widget.onSendMessagePress(
      parameters: {
        ...widget.parameters,
        'message': message,
        'receivers': widget.type == 'direct' ? [_senderId.value] : [],
        'group': widget.type == 'group' ? true : false,
        'type': widget.type,
        'messagesLength': widget.messagesLength,
      },
    );

    directMessageText.value = '';
    _groupMessageText.value = '';
    _directMessageText.value = '';

    _clearReplyInfoAndInput();

    if (_replyInfoNotifier.value != null) {
      _replyInfoNotifier.value = null;
      _senderId.value = null;
    }

    if (widget.parameters['startDirectMessage'] &&
        widget.parameters['directMessageDetails'] != null) {
      updateDirectMessageDetails({});
      updateStartDirectMessage(false);
    }
  }

  void _focusInputAndSetReplyInfo(Map<String, dynamic> directMessageDetails) {
    if (widget.parameters['startDirectMessage']) {
      _setReplyInfo({
        'text': 'Replying to: ',
        'username': directMessageDetails['name'],
      });
      _senderId.value = directMessageDetails['name'];
    }
  }

  void _clearReplyInfoAndInput() {
    _setReplyInfo(null);
    _senderId.value = null;
  }

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
    _handleEffect();
  }

  void _handleEffect() {
    final startDirectMessage = widget.parameters['startDirectMessage'];
    final directMessageDetails = widget.parameters['directMessageDetails'];

    if (startDirectMessage && directMessageDetails != null) {
      _focusInputAndSetReplyInfo(directMessageDetails);
    } else {
      _clearReplyInfoAndInput();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              final message = widget.messages[index];
              return MessageBubble(
                message: message,
                username: widget.username,
                onReply: () => openReplyInput(message['sender']),
                replyInfoNotifier: _replyInfoNotifier,
                setReplyInfo: _setReplyInfo,
                youAreCoHost: widget.parameters['youAreCoHost'] ?? false,
                islevel: widget.parameters['islevel'] ?? '1',
                eventType: widget.parameters['eventType'] ?? '',
              );
            },
          ),
        ),
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
                      replyInfo['text']! + replyInfo['username']!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : const SizedBox();
          },
        ),
        ValueListenableBuilder<Map<String, String>?>(
          valueListenable: _replyInfoNotifier,
          builder: (context, replyInfo, _) {
            return MessageInput(
              type: widget.type,
              focusedInput: widget.focusedInput,
              onHandleMessagePress: handleSendButton,
              isDirectMessage: widget.type == 'direct',
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
}

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final String username;
  final Function() onReply;
  final ValueNotifier<Map<String, String>?> replyInfoNotifier;
  final Function(Map<String, String>?) setReplyInfo;
  final bool youAreCoHost;
  final String islevel;
  final String eventType;

  const MessageBubble({
    super.key,
    required this.message,
    required this.username,
    required this.onReply,
    required this.replyInfoNotifier,
    required this.setReplyInfo,
    this.youAreCoHost = false,
    this.islevel = '1',
    this.eventType = '',
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelfMessage = message['sender'] == username;
    final bool isGroupMessage = message['group'] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment:
            isSelfMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isSelfMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isGroupMessage
                    ? !isSelfMessage
                        ? '${message['sender']} - ${message['timestamp']}'
                        : '${message['timestamp']}'
                    : !isSelfMessage
                        ? '${message['sender']} - ${message['timestamp']}'
                        : (youAreCoHost || islevel == '2')
                            ? 'To: ${message['sender']} - ${message['timestamp']}'
                            : '${message['timestamp']}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              !isGroupMessage &&
                      !isSelfMessage &&
                      (youAreCoHost || islevel == '2')
                  ? IconButton(
                      icon: const Icon(Icons.reply),
                      onPressed: onReply,
                    )
                  : Container(),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelfMessage ? Colors.blue[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message['message'],
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

class MessageInput extends StatelessWidget {
  final String type;
  final bool focusedInput;
  final Function() onHandleMessagePress;
  final bool isDirectMessage;
  final bool isFocused;
  final ValueNotifier<String> directMessageText;
  final ValueNotifier<String> groupMessageText;
  final ValueNotifier<String?> senderId;
  final String islevel;
  final bool youAreCoHost;
  final String eventType;

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
    this.eventType = '',
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
                        ? 'Send a direct message'
                        : (islevel == '2' || youAreCoHost)
                            ? 'Select a message to reply to'
                            : 'Send a direct message'
                    : eventType == 'group'
                        ? 'Send a message to the group'
                        : 'Send a message',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                onHandleMessagePress();
                //clear the text field
                _textEditingController.clear();
              }),
        ],
      ),
    );
  }
}
