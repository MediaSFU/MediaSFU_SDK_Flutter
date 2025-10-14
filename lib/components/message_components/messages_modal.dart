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

/// Configuration for the messages modal enabling direct-message and group-chat workflows.
///
/// * **onMessagesClose** - Callback when user closes the chat interface.
/// * **onSendMessagePress** - Override for `sendMessage`; receives {message, sender, receivers, group, socket, islevel}. Return `true` if send succeeded.
/// * **messages** - Full list of `Message` objects; modal filters by `group`, `sender`, `receivers` based on `eventType` and selected tab.
/// * **position** - Modal placement via `getModalPosition` (e.g., 'topRight').
/// * **backgroundColor** / **activeTabBackgroundColor** - Theming for modal body and active tab indicator.
/// * **eventType** - Determines tab visibility: `EventType.conference`/`EventType.webinar` show both direct/group tabs; `EventType.chat`/`EventType.broadcast` show group-only.
/// * **member** / **islevel** - Current user's name and privilege level (`'2'` = host, `'1'` = moderator, `'0'` = participant).
/// * **coHostResponsibility** - List of `CoHostResponsibility` objects; if `name == 'chat'` and `value == true`, co-host can see all messages.
/// * **coHost** - Co-host username; if `member == coHost`, grant elevated permissions.
/// * **startDirectMessage** / **directMessageDetails** - When initiating a DM from ParticipantsModal, set `startDirectMessage = true` and populate `directMessageDetails` with target `Participant`.
/// * **updateStartDirectMessage** / **updateDirectMessageDetails** - Callbacks to reset DM state after modal opens.
/// * **roomName** - Session identifier for outbound messages.
/// * **socket** - Socket.IO client for real-time `sendMessage` emissions.
/// * **chatSetting** - Permission string: `'disallow'` blocks sends; `'allow'` permits all; role-based checks apply otherwise.
/// * **showAlert** - Optional `ShowAlert` callback for validation/error messages.
///
/// ### Usage
/// 1. `_populateMessages` splits `messages` into `directMessages` and `groupMessages` based on sender/receiver logic and `eventType`.
/// 2. Tab selection switches between these lists, with direct-message tab hidden for `EventType.chat`/`broadcast`.
/// 3. `MessagePanel` renders the active list with reply/input affordances.
/// 4. Override this modal via `MediasfuUICustomOverrides.messagesModal` to inject custom filtering, message encryption, or alternative send logic.
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

/// Tabbed chat interface distinguishing direct messages from group broadcast.
///
/// * Splits `messages` into `directMessages` (sender/receiver match current user)
///   and `groupMessages` (group == true) via `_populateMessages`.
/// * Shows two tabs (Direct / Group) for `EventType.conference`/`EventType.webinar`;
///   shows group-only for `EventType.chat`/`EventType.broadcast`.
/// * Auto-selects Direct tab when `startDirectMessage` is true and `directMessageDetails`
///   is populated (DM initiated from ParticipantsModal).
/// * `_handleSendButton` validates message length, constructs `receivers` array for
///   direct mode (or `group: true` for group mode), invokes `onSendMessagePress`,
///   then emits to socket if send succeeds.
/// * Permission-checks `chatSetting`: blocks send if `'disallow'`; ignores send for
///   participants when setting is role-restricted.
/// * Positions via `getModalPosition` using `options.position`.
///
/// Override via `MediasfuUICustomOverrides.messagesModal` to inject end-to-end
/// encryption wrappers, message moderation hooks, or custom tab layouts.
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
              color: Colors.black.withAlpha((0.5 * 255).toInt()),
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
