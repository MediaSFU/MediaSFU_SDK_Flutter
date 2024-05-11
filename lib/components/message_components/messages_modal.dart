// ignore_for_file: empty_catches

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../methods/utils/get_modal_position.dart' show getModalPosition;
import './message_panel.dart' show MessagePanel;
import '../../methods/message_methods/send_message.dart' show sendMessage;

/// MessagesModal - A modal for displaying and interacting with messages.
///
/// This modal displays messages in tabs (direct and group) and allows users
/// to send new messages.
///
/// Whether the messages modal is visible.
/// final bool isMessagesModalVisible;
///
/// Callback function called when the messages modal is closed.
/// final VoidCallback onMessagesClose;
///
/// Function called when the send message button is pressed.
/// final SendMessage onSendMessagePress;
///
/// Additional parameters for sending messages.
/// final Map<String, dynamic> parameters;
///
/// The list of messages to be displayed.
/// final List<dynamic> messages;
///
/// The position of the modal, e.g., 'topRight'.
/// final String position;
///
/// The background color of the modal.
/// final Color backgroundColor;
///
/// The background color of the active tab.
/// final Color activeTabBackgroundColor;
///
/// _MessagesModalState - State class for MessagesModal.
///
/// This state class manages the active tab and the display of direct and group messages.
///
/// activeTab - A notifier for the active tab.
///
/// directMessages - A list of direct messages.
///
/// groupMessages - A list of group messages.

typedef SendMessage = Future<void> Function(
    {required Map<String, dynamic> parameters});

class MessagesModal extends StatefulWidget {
  final bool isMessagesModalVisible;
  final VoidCallback onMessagesClose;
  final SendMessage onSendMessagePress;
  final Map<String, dynamic> parameters;
  final List<dynamic> messages;
  final String position;
  final Color backgroundColor;
  final Color activeTabBackgroundColor;

  const MessagesModal({
    super.key,
    required this.isMessagesModalVisible,
    required this.onMessagesClose,
    this.onSendMessagePress = sendMessage,
    required this.parameters,
    required this.messages,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.activeTabBackgroundColor = const Color.fromARGB(255, 150, 231, 236),
  });

  @override
  // ignore: library_private_types_in_public_api
  _MessagesModalState createState() => _MessagesModalState();
}

class _MessagesModalState extends State<MessagesModal> {
  late ValueNotifier<String> activeTab;
  late List<dynamic> directMessages;
  late List<dynamic> groupMessages;
  late String position;

  @override
  void initState() {
    super.initState();
    activeTab = ValueNotifier<String>(
        widget.parameters['eventType'] == 'webinar' ||
                widget.parameters['eventType'] == 'conference'
            ? 'direct'
            : 'group');
    directMessages = [];
    groupMessages = [];
    populateMessages();
  }

  @override
  void didUpdateWidget(covariant MessagesModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages != widget.messages) {
      populateMessages();
    }

    if (widget.parameters['startDirectMessage'] !=
        oldWidget.parameters['startDirectMessage']) {
      if (widget.parameters['startDirectMessage'] &&
          widget.parameters['directMessageDetails'] != null) {
        if (widget.parameters['eventType'] == 'webinar' ||
            widget.parameters['eventType'] == 'conference') {
          activeTab.value = 'direct';
        } else {
          if (widget.parameters['eventType'] == 'broadcast' ||
              widget.parameters['eventType'] == 'chat') {
            activeTab.value = 'group';
          }
        }
      }
    }
  }

  void populateMessages() {
    var chatValue = false;
    try {
      chatValue = widget.parameters['coHostResponsibility']
          .firstWhere((item) => item['name'] == 'chat')['value'];
    } catch (error) {}

    var directMsgs =
        widget.messages.where((message) => !message['group']).toList();
    directMsgs = directMsgs
        .where((message) =>
            message['sender'] == widget.parameters['member'] ||
            message['receivers'].contains(widget.parameters['member']) ||
            (widget.parameters['islevel'] == '2' ||
                (widget.parameters['coHost'] == widget.parameters['member'] &&
                    chatValue == true)))
        .toList();
    var groupMsgs =
        widget.messages.where((message) => message['group']).toList();
    setState(() {
      directMessages = directMsgs;
      groupMessages = groupMsgs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var modalWidth = 0.8 * screenWidth;
    if (modalWidth > 400) {
      modalWidth = 400;
    }
    final modalHeight = kIsWeb
        ? MediaQuery.of(context).size.height * 0.7
        : MediaQuery.of(context).size.height * 0.5;

    return Visibility(
      visible: widget.isMessagesModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(
                widget.position, context, modalWidth, modalHeight)['top'],
            right: getModalPosition(
                widget.position, context, modalWidth, modalHeight)['right'],
            child: GestureDetector(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: modalWidth,
                    height: modalHeight,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.parameters['eventType'] == 'webinar' ||
                                widget.parameters['eventType'] ==
                                    'conference') ...[
                              buildTab('Direct', 'direct'),
                              buildTab('Group', 'group'),
                            ],
                            IconButton(
                              onPressed: widget.onMessagesClose,
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: buildTabContent(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildTab(String text, String tab) {
    return ValueListenableBuilder<String>(
      valueListenable: activeTab,
      builder: (context, value, child) {
        return InkWell(
          onTap: () {
            activeTab.value = tab;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: value == tab
                  ? widget.activeTabBackgroundColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: value == tab ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTabContent() {
    return ValueListenableBuilder<String>(
      valueListenable: activeTab,
      builder: (context, value, child) {
        if (value == 'direct' &&
            (widget.parameters['eventType'] == 'webinar' ||
                widget.parameters['eventType'] == 'conference')) {
          return MessagePanel(
            messages: directMessages,
            messagesLength: widget.messages.length,
            type: 'direct',
            onSendMessagePress: widget.onSendMessagePress,
            username: widget.parameters['member'],
            parameters: widget.parameters,
            backgroundColor: widget.backgroundColor,
            focusedInput: false, // focusedInput is not used in direct messages
          );
        } else {
          return MessagePanel(
            messages: groupMessages,
            messagesLength: widget.messages.length,
            type: 'group',
            onSendMessagePress: widget.onSendMessagePress,
            username: widget.parameters['member'],
            parameters: widget.parameters,
            backgroundColor: widget.backgroundColor,
            focusedInput: false,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    activeTab.dispose();
    super.dispose();
  }
}
