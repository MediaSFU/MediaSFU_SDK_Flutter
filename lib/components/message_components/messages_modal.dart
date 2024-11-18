import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import './message_panel.dart' show MessagePanel, MessagePanelOptions;
import '../../methods/message_methods/send_message.dart'
    show sendMessage, SendMessageType;
import '../../types/types.dart'
    show CoHostResponsibility, EventType, Message, Participant, ShowAlert;

class MessagesModalOptions {
  final bool isMessagesModalVisible;
  final VoidCallback onMessagesClose;
  final SendMessageType onSendMessagePress;
  final List<Message> messages;
  final String position;
  final Color backgroundColor;
  final Color activeTabBackgroundColor;
  final EventType eventType;
  final String member;
  final String islevel;
  final List<CoHostResponsibility> coHostResponsibility;
  final String coHost;
  final bool startDirectMessage;
  final Participant? directMessageDetails;
  final Function(bool) updateStartDirectMessage;
  final Function(Participant?) updateDirectMessageDetails;
  final String roomName;
  final io.Socket? socket;
  final String chatSetting;
  final ShowAlert? showAlert;

  MessagesModalOptions({
    required this.isMessagesModalVisible,
    required this.onMessagesClose,
    this.onSendMessagePress = sendMessage,
    required this.messages,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.activeTabBackgroundColor = const Color.fromARGB(255, 150, 231, 236),
    required this.eventType,
    required this.member,
    required this.islevel,
    required this.coHostResponsibility,
    required this.coHost,
    required this.startDirectMessage,
    this.directMessageDetails,
    required this.updateStartDirectMessage,
    required this.updateDirectMessageDetails,
    required this.roomName,
    this.socket,
    required this.chatSetting,
    this.showAlert,
  });
}

typedef MessagesModalType = MessagesModal Function({
  required MessagesModalOptions options,
});

/// `MessagesModal` displays a modal interface for managing direct and group messages within an event.
/// It provides separate tabs for viewing and sending direct or group messages, configurable based on the event type.
///
/// ### Parameters:
/// - `MessagesModalOptions` `options`: Configuration for the modal, including:
///   - `isMessagesModalVisible`: Whether the modal is visible.
///   - `onMessagesClose`: Callback to close the modal.
///   - `onSendMessagePress`: Function to handle sending a message.
///   - `messages`: List of `Message` objects to display.
///   - `position`: Modal position on the screen (e.g., `'topRight'`).
///   - `backgroundColor`: Modal background color.
///   - `activeTabBackgroundColor`: Background color for the active tab.
///   - `eventType`, `member`, `islevel`: Event and user role information for filtering messages.
///   - `coHost`, `coHostResponsibility`: Co-host settings and responsibilities.
///   - `directMessageDetails`: Participant details for direct messages.
///   - `updateStartDirectMessage` and `updateDirectMessageDetails`: Functions to manage direct messaging state.
///   - `socket`: Socket instance for real-time updates.
///   - `showAlert`: Optional callback for displaying alerts.
///
/// ### Key Functions:
/// - `_populateMessages`: Populates lists for `directMessages` and `groupMessages` based on event type, user roles, and responsibilities.
/// - `_buildTabContent`: Displays content in the active tab, showing either direct or group messages depending on the selected tab.
/// - `_handleSendButton`: Validates and sends messages, clearing the input and updating the reply state as needed.
///
/// ### Example Usage:
/// ```dart
/// MessagesModal(
///   options: MessagesModalOptions(
///     isMessagesModalVisible: true,
///     onMessagesClose: () => print("Modal closed"),
///     messages: messageList,
///     eventType: EventType.chat,
///     member: 'user123',
///     islevel: '1',
///     coHostResponsibility: [CoHostResponsibility(name: 'chat', value: true)],
///     coHost: 'host123',
///     startDirectMessage: false,
///     directMessageDetails: null,
///     updateStartDirectMessage: (value) => print("Direct message started: $value"),
///     updateDirectMessageDetails: (participant) => print("Direct message to: ${participant?.name}"),
///     roomName: 'MainRoom',
///     socket: socketInstance,
///     chatSetting: 'enabled',
///     showAlert: (options) => print("Alert: ${options.message}"),
///   ),
/// );
/// ```
///
/// ### Modal Content:
/// - **Header with Tabs**: Contains tabs for switching between direct and group messaging, shown only in webinar or conference mode.
/// - **Tab Content**: Displays a list of messages and input field, with different messages shown based on active tab.
///
/// ### Dependencies:
/// - `socket_io_client` for real-time message handling.
/// - `MessagePanel` component to display and manage messages within each tab.
///
/// This modal is particularly useful in events or group settings, where real-time messaging and role-based message visibility are important.

class MessagesModal extends StatefulWidget {
  final MessagesModalOptions options;

  const MessagesModal({super.key, required this.options});

  @override
  _MessagesModalState createState() => _MessagesModalState();
}

class _MessagesModalState extends State<MessagesModal> {
  late ValueNotifier<String> activeTab;
  late List<Message> directMessages;
  late List<Message> groupMessages;
  late ValueNotifier<bool> focusedInput;

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
                widget.options.eventType == EventType.conference)
        ? true
        : false);
  }

  @override
  void didUpdateWidget(MessagesModal oldWidget) {
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth * 0.8 > 400 ? 400.0 : screenWidth * 0.8;
    final modalHeight = kIsWeb
        ? MediaQuery.of(context).size.height * 0.7
        : MediaQuery.of(context).size.height * 0.5;

    return Visibility(
      visible: widget.options.isMessagesModalVisible,
      child: Stack(
        children: [
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
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: modalWidth,
                  height: modalHeight,
                  decoration: BoxDecoration(
                    color: widget.options.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const Divider(),
                      Expanded(child: _buildTabContent()),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.options.eventType == EventType.webinar ||
            widget.options.eventType == EventType.conference) ...[
          _buildTabButton('Direct', 'direct'),
          _buildTabButton('Group', 'group'),
        ],
        IconButton(
          onPressed: widget.options.onMessagesClose,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildTabButton(String text, String tab) {
    return ValueListenableBuilder<String>(
      valueListenable: activeTab,
      builder: (context, value, child) {
        return InkWell(
          onTap: () => activeTab.value = tab,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: value == tab
                  ? widget.options.activeTabBackgroundColor
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

  Widget _buildTabContent() {
    return ValueListenableBuilder<String>(
      valueListenable: activeTab,
      builder: (context, value, child) {
        final isDirectTab = value == 'direct' &&
            (widget.options.eventType == EventType.webinar ||
                widget.options.eventType == EventType.conference);
        final optionsPanel = MessagePanelOptions(
          messages: isDirectTab ? directMessages : groupMessages,
          messagesLength: widget.options.messages.length,
          type: isDirectTab ? 'direct' : 'group',
          onSendMessagePress: widget.options.onSendMessagePress,
          username: widget.options.member,
          backgroundColor: widget.options.backgroundColor,
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
        );
        return MessagePanel(
          options: optionsPanel,
        );
      },
    );
  }

  @override
  void dispose() {
    activeTab.dispose();
    super.dispose();
  }
}
