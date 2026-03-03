import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/types.dart'
    show
        ShowAlert,
        Participant,
        WhiteboardUser,
        EventType,
        OnScreenChangesType,
        CaptureCanvasStreamType,
        PrepopulateUserMediaType,
        RePortType;
import '../../types/modal_style_options.dart' show ModalRenderMode;

/// Parameters for the ConfigureWhiteboardModal widget.
abstract class ConfigureWhiteboardModalParameters {
  List<Participant> get participants;
  ShowAlert? get showAlert;
  io.Socket? get socket;
  int get itemPageLimit;
  String get islevel;
  String get roomName;
  EventType get eventType;
  bool get shareScreenStarted;
  bool get shared;
  bool get breakOutRoomStarted;
  bool get breakOutRoomEnded;
  bool get recordStarted;
  bool get recordResumed;
  bool get recordPaused;
  bool get recordStopped;
  String get recordingMediaOptions;
  bool get canStartWhiteboard;
  bool get whiteboardStarted;
  bool get whiteboardEnded;
  String get hostLabel;

  void Function(bool) get updateWhiteboardStarted;
  void Function(bool) get updateWhiteboardEnded;
  void Function(List<WhiteboardUser>) get updateWhiteboardUsers;
  void Function(bool) get updateCanStartWhiteboard;
  void Function(bool) get updateIsConfigureWhiteboardModalVisible;

  // Mediasfu functions
  OnScreenChangesType get onScreenChanges;
  CaptureCanvasStreamType? get captureCanvasStream;
  PrepopulateUserMediaType get prepopulateUserMedia;
  RePortType get rePort;

  ConfigureWhiteboardModalParameters Function() get getUpdatedAllParams;
}

/// Options for the ConfigureWhiteboardModal widget.
class ConfigureWhiteboardModalOptions {
  final bool isVisible;
  final VoidCallback onClose;
  final ConfigureWhiteboardModalParameters parameters;
  final Color backgroundColor;
  final String position;
  final ModalRenderMode renderMode;
  final bool isDarkMode;
  final bool enableGlassmorphism;

  ConfigureWhiteboardModalOptions({
    required this.isVisible,
    required this.onClose,
    required this.parameters,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.position = 'topRight',
    this.renderMode = ModalRenderMode.modal,
    this.isDarkMode = false,
    this.enableGlassmorphism = true,
  });
}

/// Type definition for ConfigureWhiteboardModal widget builder.
typedef ConfigureWhiteboardModalType = Widget Function(
    {required ConfigureWhiteboardModalOptions options});

/// ConfigureWhiteboardModal - Modal for configuring and managing whiteboard sessions.
///
/// This component provides an interface for host-controlled whiteboard management, including
/// participant selection, access control, and session lifecycle management.
///
/// Features:
/// - Participant management with dual-list interface
/// - Session control (start, stop, update)
/// - Access validation for host permissions
/// - Screen share and recording compatibility checks
///
/// Example:
/// ```dart
/// ConfigureWhiteboardModal(
///   options: ConfigureWhiteboardModalOptions(
///     isVisible: true,
///     onClose: () => setState(() => _isVisible = false),
///     parameters: whiteboardParams,
///   ),
/// )
/// ```
class ConfigureWhiteboardModal extends StatefulWidget {
  final ConfigureWhiteboardModalOptions options;

  const ConfigureWhiteboardModal({super.key, required this.options});

  @override
  State<ConfigureWhiteboardModal> createState() =>
      _ConfigureWhiteboardModalState();
}

class _ConfigureWhiteboardModalState extends State<ConfigureWhiteboardModal> {
  List<Participant> _assignedParticipants = [];
  List<Participant> _pendingParticipants = [];
  bool _isEditing = false;

  ConfigureWhiteboardModalParameters get _params => widget.options.parameters;

  @override
  void initState() {
    super.initState();
    _initializeParticipants();
  }

  @override
  void didUpdateWidget(ConfigureWhiteboardModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.isVisible && !oldWidget.options.isVisible) {
      _initializeParticipants();
    }
  }

  void _initializeParticipants() {
    // Get all non-host participants (like React's filtering)
    final allParticipants =
        _params.participants.where((p) => p.islevel != '2').toList();

    // Separate into assigned (useBoard: true) and pending (useBoard: false/null)
    // This preserves existing whiteboard assignments like React does
    final assigned = allParticipants.where((p) => p.useBoard == true).toList();
    final pending = allParticipants.where((p) => p.useBoard != true).toList();

    setState(() {
      _assignedParticipants = assigned;
      _pendingParticipants = pending;
    });

    // Check if we can start whiteboard (validate limit)
    _checkCanStartWhiteboard();
  }

  void _checkCanStartWhiteboard() {
    final isValid = _assignedParticipants.length <= _params.itemPageLimit;
    _params.updateCanStartWhiteboard(isValid);
  }

  void _addParticipant(Participant participant) {
    setState(() {
      _pendingParticipants.remove(participant);
      _assignedParticipants.add(participant);
      _isEditing = true;
    });
    _checkCanStartWhiteboard();
  }

  void _removeParticipant(Participant participant) {
    setState(() {
      _assignedParticipants.remove(participant);
      _pendingParticipants.add(participant);
      _isEditing = true;
    });
    _checkCanStartWhiteboard();
  }

  void _saveAssignments() {
    // Validate whiteboard limit
    if (_assignedParticipants.length > _params.itemPageLimit) {
      _params.showAlert?.call(
        message: 'Participant limit exceeded',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    // If whiteboard is already running, emit 'updateWhiteboard' to sync user changes to backend
    // This matches React behavior: it uses updateWhiteboard to push user access changes
    if (_params.whiteboardStarted && !_params.whiteboardEnded) {
      final whiteboardUsers = _assignedParticipants
          .map((p) => {'name': p.name, 'useBoard': true})
          .toList();

      _params.socket?.emitWithAck(
        'updateWhiteboard',
        {
          'whiteboardUsers': whiteboardUsers,
          'roomName': _params.roomName,
        },
        ack: (response) {
          if (response != null && response['success'] == true) {
            _params.updateWhiteboardUsers(
              whiteboardUsers
                  .map((u) => WhiteboardUser(
                        name: u['name'] as String,
                        useBoard: u['useBoard'] as bool,
                      ))
                  .toList(),
            );
            _params.showAlert?.call(
              message: 'Whiteboard users updated',
              type: 'success',
              duration: 3000,
            );
          } else {
            _params.showAlert?.call(
              message:
                  response?['reason'] ?? 'Failed to update whiteboard users',
              type: 'danger',
              duration: 3000,
            );
          }
        },
      );
    } else {
      // If whiteboard not running, just update local state
      final whiteboardUsers = _assignedParticipants
          .map((p) => WhiteboardUser(name: p.name, useBoard: true))
          .toList();
      _params.updateWhiteboardUsers(whiteboardUsers);
      _params.showAlert?.call(
        message: 'Whiteboard saved successfully',
        type: 'success',
        duration: 3000,
      );
    }

    _checkCanStartWhiteboard();

    setState(() {
      _isEditing = false;
    });
  }

  bool _validateStartWhiteboard() {
    // Check if screen sharing is active
    if (_params.shareScreenStarted || _params.shared) {
      _params.showAlert?.call(
        message: 'Cannot start whiteboard while screen sharing is active',
        type: 'danger',
        duration: 3000,
      );
      return false;
    }

    // Check if breakout rooms are active
    if (_params.breakOutRoomStarted && !_params.breakOutRoomEnded) {
      _params.showAlert?.call(
        message: 'Cannot start whiteboard while breakout rooms are active',
        type: 'danger',
        duration: 3000,
      );
      return false;
    }

    return true;
  }

  void _startWhiteboard() async {
    if (!_validateStartWhiteboard()) return;

    // Check if socket is available
    if (_params.socket == null) {
      _params.showAlert?.call(
        message: 'Socket connection not available',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    // Prepare whiteboard users - filter only those with useBoard true
    // Note: Don't add host manually - backend handles host (islevel == "2") automatically
    final whiteboardUsers = _assignedParticipants
        .map((p) => {'name': p.name, 'useBoard': true})
        .toList();

    // Determine emit name based on current state
    final emitName = (_params.whiteboardStarted && !_params.whiteboardEnded)
        ? 'updateWhiteboard'
        : 'startWhiteboard';

    _params.socket!.emitWithAck(
      emitName,
      {
        'whiteboardUsers': whiteboardUsers,
        'roomName': _params.roomName,
      },
      ack: (response) {
        if (response != null && response['success'] == true) {
          _params.updateWhiteboardStarted(true);
          _params.updateWhiteboardEnded(false);
          _params.updateWhiteboardUsers(
            whiteboardUsers
                .map((u) => WhiteboardUser(
                      name: u['name'] as String,
                      useBoard: u['useBoard'] as bool,
                    ))
                .toList(),
          );
          _params.updateCanStartWhiteboard(false);

          _params.showAlert?.call(
            message: 'Whiteboard active',
            type: 'success',
            duration: 3000,
          );

          widget.options.onClose();
        } else {
          _params.showAlert?.call(
            message: response?['reason'] ?? 'Failed to start whiteboard',
            type: 'danger',
            duration: 3000,
          );
        }
      },
    );
  }

  void _stopWhiteboard() {
    _params.socket?.emitWithAck(
      'stopWhiteboard',
      {'roomName': _params.roomName},
      ack: (response) {
        if (response != null && response['success'] == true) {
          _params.updateWhiteboardStarted(false);
          _params.updateWhiteboardEnded(true);
          _params.updateCanStartWhiteboard(true);

          _params.showAlert?.call(
            message: 'Whiteboard stopped successfully',
            type: 'success',
            duration: 3000,
          );

          widget.options.onClose();
        } else {
          _params.showAlert?.call(
            message: response?['reason'] ?? 'Failed to stop whiteboard',
            type: 'danger',
            duration: 3000,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.options.isVisible) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;
    final modalWidth = screenSize.width > 600 ? 520.0 : screenSize.width * 0.92;
    final modalHeight = screenSize.height * 0.75;

    final positionResult = getModalPosition(GetModalPositionOptions(
      position: widget.options.position,
      modalWidth: modalWidth,
      modalHeight: modalHeight,
      context: context,
    ));

    return Stack(
      children: [
        // Overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.options.onClose,
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ),

        // Modal
        Positioned(
          top: positionResult['top'],
          right: positionResult['right'],
          left: positionResult['left'],
          bottom: positionResult['bottom'],
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: modalWidth,
              height: modalHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Status indicator
                  if (_params.whiteboardStarted && !_params.whiteboardEnded)
                    _buildStatusBanner(),

                  // Body
                  Expanded(
                    child: _buildBody(),
                  ),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final isActive = _params.whiteboardStarted && !_params.whiteboardEnded;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const FaIcon(
              FontAwesomeIcons.chalkboard,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configure Whiteboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isActive ? 'Session active' : 'Manage participant access',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
            onPressed: widget.options.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF10B981).withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Whiteboard is currently active',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF059669),
            ),
          ),
          const Spacer(),
          Text(
            '${_assignedParticipants.length} participant${_assignedParticipants.length != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.blue[600]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Assign participants who can draw on the whiteboard. Limit: ${_params.itemPageLimit} participants.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Participant lists - responsive layout
              Expanded(
                child: isNarrow
                    ? _buildNarrowParticipantLists()
                    : _buildWideParticipantLists(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Wide layout with side-by-side participant cards
  Widget _buildWideParticipantLists() {
    return Row(
      children: [
        // Assigned participants
        Expanded(
          child: _buildParticipantCard(
            title: 'Assigned',
            subtitle: 'Can draw',
            icon: FontAwesomeIcons.userCheck,
            iconColor: const Color(0xFF10B981),
            participants: _assignedParticipants,
            onAction: _removeParticipant,
            actionIcon: FontAwesomeIcons.xmark,
            actionColor: const Color(0xFFEF4444),
            actionBgColor: const Color(0xFFFEE2E2),
            emptyMessage: 'No participants assigned',
            emptyIcon: FontAwesomeIcons.userPlus,
            headerColor: const Color(0xFFECFDF5),
            borderColor: const Color(0xFFD1FAE5),
          ),
        ),
        const SizedBox(width: 12),
        // Available participants
        Expanded(
          child: _buildParticipantCard(
            title: 'Available',
            subtitle: 'View only',
            icon: FontAwesomeIcons.users,
            iconColor: const Color(0xFF6366F1),
            participants: _pendingParticipants,
            onAction: _addParticipant,
            actionIcon: FontAwesomeIcons.plus,
            actionColor: const Color(0xFF10B981),
            actionBgColor: const Color(0xFFD1FAE5),
            emptyMessage: 'All participants assigned',
            emptyIcon: FontAwesomeIcons.checkDouble,
            headerColor: const Color(0xFFEEF2FF),
            borderColor: const Color(0xFFE0E7FF),
          ),
        ),
      ],
    );
  }

  // State for tab selection in narrow mode
  int _selectedParticipantTab = 0;

  /// Narrow layout with tabs for participant lists
  Widget _buildNarrowParticipantLists() {
    return Column(
      children: [
        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedParticipantTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedParticipantTab == 0
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _selectedParticipantTab == 0
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.userCheck,
                          size: 12,
                          color: _selectedParticipantTab == 0
                              ? const Color(0xFF10B981)
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Assigned (${_assignedParticipants.length})',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _selectedParticipantTab == 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: _selectedParticipantTab == 0
                                ? const Color(0xFF10B981)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedParticipantTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedParticipantTab == 1
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _selectedParticipantTab == 1
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.users,
                          size: 12,
                          color: _selectedParticipantTab == 1
                              ? const Color(0xFF6366F1)
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Available (${_pendingParticipants.length})',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _selectedParticipantTab == 1
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: _selectedParticipantTab == 1
                                ? const Color(0xFF6366F1)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Tab content
        Expanded(
          child: _selectedParticipantTab == 0
              ? _buildParticipantCard(
                  title: 'Assigned',
                  subtitle: 'Can draw',
                  icon: FontAwesomeIcons.userCheck,
                  iconColor: const Color(0xFF10B981),
                  participants: _assignedParticipants,
                  onAction: _removeParticipant,
                  actionIcon: FontAwesomeIcons.xmark,
                  actionColor: const Color(0xFFEF4444),
                  actionBgColor: const Color(0xFFFEE2E2),
                  emptyMessage: 'No participants assigned',
                  emptyIcon: FontAwesomeIcons.userPlus,
                  headerColor: const Color(0xFFECFDF5),
                  borderColor: const Color(0xFFD1FAE5),
                )
              : _buildParticipantCard(
                  title: 'Available',
                  subtitle: 'View only',
                  icon: FontAwesomeIcons.users,
                  iconColor: const Color(0xFF6366F1),
                  participants: _pendingParticipants,
                  onAction: _addParticipant,
                  actionIcon: FontAwesomeIcons.plus,
                  actionColor: const Color(0xFF10B981),
                  actionBgColor: const Color(0xFFD1FAE5),
                  emptyMessage: 'All participants assigned',
                  emptyIcon: FontAwesomeIcons.checkDouble,
                  headerColor: const Color(0xFFEEF2FF),
                  borderColor: const Color(0xFFE0E7FF),
                ),
        ),
      ],
    );
  }

  Widget _buildParticipantCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<Participant> participants,
    required Function(Participant) onAction,
    required IconData actionIcon,
    required Color actionColor,
    required Color actionBgColor,
    required String emptyMessage,
    required IconData emptyIcon,
    required Color headerColor,
    required Color borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: FaIcon(icon, size: 12, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${participants.length}',
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: participants.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: FaIcon(
                            emptyIcon,
                            size: 20,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          emptyMessage,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: participants.length,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final participant = participants[index];
                      return _buildParticipantTile(
                        participant: participant,
                        onAction: onAction,
                        actionIcon: actionIcon,
                        actionColor: actionColor,
                        actionBgColor: actionBgColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantTile({
    required Participant participant,
    required Function(Participant) onAction,
    required IconData actionIcon,
    required Color actionColor,
    required Color actionBgColor,
  }) {
    final initials = participant.name.isNotEmpty
        ? participant.name.substring(0, 1).toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              participant.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => onAction(participant),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: actionBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FaIcon(
                actionIcon,
                size: 12,
                color: actionColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final isActive = _params.whiteboardStarted && !_params.whiteboardEnded;
    final canStart = _params.canStartWhiteboard && !isActive;
    final limitExceeded = _assignedParticipants.length > _params.itemPageLimit;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning if limit exceeded
          if (limitExceeded)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 16, color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Participant limit exceeded (max ${_params.itemPageLimit})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              // Save button (when editing and whiteboard not active)
              if (_isEditing && !isActive)
                Expanded(
                  child: _buildActionButton(
                    icon: FontAwesomeIcons.floppyDisk,
                    label: 'Save',
                    color: const Color(0xFF3B82F6),
                    onPressed: limitExceeded ? null : _saveAssignments,
                  ),
                ),

              if (_isEditing && !isActive) const SizedBox(width: 10),

              // Start button (when can start and not active)
              if (canStart)
                Expanded(
                  child: _buildActionButton(
                    icon: FontAwesomeIcons.play,
                    label: 'Start Whiteboard',
                    color: const Color(0xFF10B981),
                    onPressed: limitExceeded ? null : _startWhiteboard,
                  ),
                ),

              // Active session buttons
              if (isActive) ...[
                Expanded(
                  child: _buildActionButton(
                    icon: FontAwesomeIcons.arrowsRotate,
                    label: 'Update',
                    color: const Color(0xFFF59E0B),
                    onPressed: limitExceeded ? null : _saveAssignments,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionButton(
                    icon: FontAwesomeIcons.stop,
                    label: 'Stop',
                    color: const Color(0xFFEF4444),
                    onPressed: _stopWhiteboard,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isDisabled
              ? null
              : LinearGradient(
                  colors: [color, color.withOpacity(0.85)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
          color: isDisabled ? Colors.grey[300] : null,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 14,
              color: isDisabled ? Colors.grey[500] : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDisabled ? Colors.grey[500] : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
