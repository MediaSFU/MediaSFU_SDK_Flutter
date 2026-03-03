import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../components/breakout_components/breakout_rooms_modal.dart'
    show BreakoutRoomsModalOptions;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../../types/types.dart' show BreakoutParticipant, Participant;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

/// Modern glassmorphic breakout rooms management modal.
///
/// Features:
/// - Frosted glass container with backdrop blur
/// - Modern room cards with participant chips
/// - Animated room creation/deletion
/// - Visual room assignment interface
/// - Status indicators for breakout session state
///
/// Uses [BreakoutRoomsModalOptions] for configuration and delegates
/// all business logic to the original breakout room methods.
class ModernBreakoutRoomsModal extends StatefulWidget {
  final BreakoutRoomsModalOptions options;

  const ModernBreakoutRoomsModal({super.key, required this.options});

  @override
  State<ModernBreakoutRoomsModal> createState() =>
      _ModernBreakoutRoomsModalState();
}

class _ModernBreakoutRoomsModalState extends State<ModernBreakoutRoomsModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late List<Participant> _participants;
  late List<List<BreakoutParticipant>> _breakoutRooms;
  late TextEditingController _numRoomsController;

  int _currentRoomIndex = 0;
  bool _editModalVisible = false;
  bool _breakOutRoomStarted = false;
  bool _breakOutRoomEnded = false;
  bool _canStartBreakout = false;
  String _newParticipantAction = 'autoAssignNewRoom';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _participants = widget.options.parameters.participants
        .where((p) => p.islevel != '2')
        .toList();
    _breakoutRooms = List.from(widget.options.parameters.breakoutRooms);
    _breakOutRoomStarted = widget.options.parameters.breakOutRoomStarted;
    _breakOutRoomEnded = widget.options.parameters.breakOutRoomEnded;
    _canStartBreakout = widget.options.parameters.canStartBreakout;
    _numRoomsController = TextEditingController();

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _numRoomsController.dispose();
    super.dispose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      widget.options.onBreakoutRoomsClose();
    });
  }

  void _showAlert(String message, String type) {
    widget.options.parameters.showAlert?.call(
      message: message,
      type: type,
      duration: 3000,
    );
  }

  void _handleEditRoom(int roomIndex) {
    setState(() {
      _currentRoomIndex = roomIndex;
      _editModalVisible = true;
      _canStartBreakout = false;
    });
  }

  void _handleDeleteRoom(int roomIndex) {
    setState(() {
      _breakoutRooms.removeAt(roomIndex);
      for (int i = 0; i < _breakoutRooms.length; i++) {
        for (var p in _breakoutRooms[i]) {
          p.breakRoom = i;
        }
      }
      _checkCanStartBreakout();
    });
    widget.options.parameters.updateBreakoutRooms(_breakoutRooms);
    _showAlert('Room ${roomIndex + 1} deleted', 'success');
  }

  void _handleAddParticipant(int roomIndex, BreakoutParticipant participant) {
    if (_breakoutRooms[roomIndex].length >=
        widget.options.parameters.itemPageLimit) {
      _showAlert('Room ${roomIndex + 1} is full', 'danger');
      return;
    }
    setState(() {
      _breakoutRooms[roomIndex].add(participant);
      _participants.firstWhere((p) => p.name == participant.name).breakRoom =
          roomIndex;
      participant.breakRoom = roomIndex;
      _checkCanStartBreakout();
    });
    widget.options.parameters.updateBreakoutRooms(_breakoutRooms);
    _showAlert('${participant.name} added to Room ${roomIndex + 1}', 'success');
  }

  void _handleRemoveParticipant(
      int roomIndex, BreakoutParticipant participant) {
    setState(() {
      _breakoutRooms[roomIndex].removeWhere((p) => p.name == participant.name);
      final idx = _participants.indexWhere((p) => p.name == participant.name);
      if (idx != -1) _participants[idx].breakRoom = null;
      participant.breakRoom = null;
      _checkCanStartBreakout();
    });
    widget.options.parameters.updateBreakoutRooms(_breakoutRooms);
    _showAlert('${participant.name} removed', 'success');
  }

  void _handleRandomAssign() {
    final numRooms = int.tryParse(_numRoomsController.text) ?? 0;
    if (numRooms <= 0 || numRooms > 10) {
      _showAlert('Enter 1-10 rooms', 'danger');
      return;
    }

    setState(() {
      final newRooms =
          List<List<BreakoutParticipant>>.generate(numRooms, (_) => []);
      final shuffled = List<Participant>.from(_participants)..shuffle();

      for (int i = 0; i < shuffled.length; i++) {
        final roomIdx = i % numRooms;
        newRooms[roomIdx].add(
            BreakoutParticipant(name: shuffled[i].name, breakRoom: roomIdx));
        shuffled[i].breakRoom = roomIdx;
      }
      _breakoutRooms = newRooms;
      _checkCanStartBreakout();
    });
    widget.options.parameters.updateBreakoutRooms(_breakoutRooms);
    _showAlert('Participants assigned randomly', 'success');
  }

  void _handleManualAssign() {
    final numRooms = int.tryParse(_numRoomsController.text) ?? 0;
    if (numRooms <= 0 || numRooms > 10) {
      _showAlert('Enter 1-10 rooms', 'danger');
      return;
    }

    setState(() {
      _breakoutRooms = List.generate(numRooms, (_) => []);
      _checkCanStartBreakout();
    });
    widget.options.parameters.updateBreakoutRooms(_breakoutRooms);
    _showAlert('$numRooms rooms created', 'success');
  }

  void _handleAddRoom() {
    if (_breakoutRooms.length >= 10) {
      _showAlert('Maximum 10 rooms allowed', 'danger');
      return;
    }
    setState(() {
      _breakoutRooms.add([]);
      _checkCanStartBreakout();
    });
    widget.options.parameters.updateBreakoutRooms(_breakoutRooms);
    _showAlert('Room added', 'success');
  }

  bool _validateRooms() {
    if (_breakoutRooms.isEmpty) return false;
    for (final room in _breakoutRooms) {
      if (room.isEmpty) return false;
      final names = room.map((p) => p.name).toSet();
      if (names.length != room.length) return false;
      if (room.length > widget.options.parameters.itemPageLimit) return false;
    }
    return true;
  }

  void _checkCanStartBreakout() {
    final valid = _validateRooms();
    if (_canStartBreakout != valid) {
      setState(() => _canStartBreakout = valid);
    }
  }

  void _handleSaveRooms() {
    if (_validateRooms()) {
      widget.options.parameters.updateBreakoutRooms(_breakoutRooms);
      widget.options.parameters.updateCanStartBreakout(true);
      setState(() => _canStartBreakout = true);
      _showAlert('Rooms saved', 'success');
    } else {
      _showAlert('Each room needs at least one participant', 'danger');
    }
  }

  void _handleStartBreakout() {
    if (widget.options.parameters.shareScreenStarted ||
        widget.options.parameters.shared) {
      _showAlert('Stop screen sharing first', 'danger');
      return;
    }

    if (!_canStartBreakout) return;

    final emitName = (_breakOutRoomStarted && !_breakOutRoomEnded)
        ? 'updateBreakout'
        : 'startBreakout';
    final roomsMap = _breakoutRooms
        .map((room) => room
            .map((p) => {'name': p.name, 'breakRoom': p.breakRoom ?? -1})
            .toList())
        .toList();

    widget.options.parameters.socket?.emitWithAck(emitName, {
      'breakoutRooms': roomsMap,
      'newParticipantAction': _newParticipantAction,
      'roomName': widget.options.parameters.roomName,
    }, ack: (response) {
      if (response['success'] == true) {
        _showAlert('Breakout rooms active', 'success');
        widget.options.parameters.updateBreakOutRoomStarted(true);
        widget.options.parameters.updateBreakOutRoomEnded(false);
        widget.options.parameters.updateMeetingDisplayType('all');
        _handleClose();
      } else {
        _showAlert(response['reason'] ?? 'Failed to start', 'danger');
      }
    });

    if (widget.options.parameters.localSocket?.id != null) {
      try {
        widget.options.parameters.localSocket?.emitWithAck(
            emitName,
            {
              'breakoutRooms': roomsMap,
              'newParticipantAction': _newParticipantAction,
              'roomName': widget.options.parameters.roomName,
            },
            ack: (_) {});
      } catch (e) {
        if (kDebugMode) print('Local socket error: $e');
      }
    }
  }

  void _handleStopBreakout() {
    widget.options.parameters.socket?.emitWithAck('stopBreakout', {
      'roomName': widget.options.parameters.roomName,
    }, ack: (response) {
      if (response['success'] == true) {
        _showAlert('Breakout rooms stopped', 'success');
        widget.options.parameters.updateBreakOutRoomStarted(false);
        widget.options.parameters.updateBreakOutRoomEnded(true);
        widget.options.parameters.updateMeetingDisplayType(
            widget.options.parameters.prevMeetingDisplayType);
        _handleClose();
      } else {
        _showAlert(response['reason'] ?? 'Failed to stop', 'danger');
      }
    });

    if (widget.options.parameters.localSocket?.id != null) {
      try {
        widget.options.parameters.localSocket?.emitWithAck(
            'stopBreakout',
            {
              'roomName': widget.options.parameters.roomName,
            },
            ack: (_) {});
      } catch (e) {
        if (kDebugMode) print('Local socket error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // For sidebar or inline mode, render content directly without modal wrapper
    if (widget.options.renderMode == ModalRenderMode.sidebar ||
        widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent(context);
    }

    if (!widget.options.isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth > 640 ? 600.0 : screenWidth * 0.95;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = screenWidth >= 1200;
    final shouldUseSidebar = isLandscape && isWide;
    final useHighTransparency = !shouldUseSidebar;

    final surfaceColor = useHighTransparency
        ? (isDark
            ? MediasfuColors.surfaceDark.withOpacity(0.05)
            : MediasfuColors.surface.withOpacity(0.08))
        : (isDark
            ? MediasfuColors.surfaceDark.withOpacity(0.94)
            : MediasfuColors.surface.withOpacity(0.96));
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = textColor.withOpacity(0.6);
    final primaryColor = MediasfuColors.primary;
    final dividerColor =
        (isDark ? Colors.white : Colors.black).withOpacity(0.08);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _handleClose,
        child: Container(
          color: Colors.black.withOpacity(0.1),
          child: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: child,
            ),
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: modalWidth,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.88,
                  ),
                  margin: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(color: dividerColor),
                          boxShadow: useHighTransparency
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: MediasfuColors.primary
                                        .withOpacity(0.15),
                                    blurRadius: 50,
                                    spreadRadius: 8,
                                  ),
                                ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(textColor, dividerColor, primaryColor),
                            Flexible(
                              child: _editModalVisible
                                  ? _buildEditRoomView(textColor, subtitleColor,
                                      primaryColor, dividerColor, isDark)
                                  : _buildMainView(textColor, subtitleColor,
                                      primaryColor, dividerColor, isDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds sidebar-optimized content for embedding in sidebar panel.
  Widget _buildSidebarContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = textColor.withOpacity(0.6);
    final primaryColor = MediasfuColors.primary;
    final dividerColor =
        (isDark ? Colors.white : Colors.black).withOpacity(0.08);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildHeader(textColor, dividerColor, primaryColor),
        Expanded(
          child: _editModalVisible
              ? _buildEditRoomView(
                  textColor, subtitleColor, primaryColor, dividerColor, isDark)
              : _buildMainView(
                  textColor, subtitleColor, primaryColor, dividerColor, isDark),
        ),
      ],
    );
  }

  Widget _buildHeader(Color textColor, Color dividerColor, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(MediasfuSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.workspaces_outlined,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: MediasfuSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editModalVisible
                      ? 'Edit Room ${_currentRoomIndex + 1}'
                      : 'Breakout Rooms',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
                if (_breakOutRoomStarted && !_breakOutRoomEnded)
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: MediasfuColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('Active',
                          style: TextStyle(
                              fontSize: 12, color: MediasfuColors.successDark)),
                    ],
                  ),
              ],
            ),
          ),
          if (_editModalVisible)
            IconButton(
              onPressed: () => setState(() => _editModalVisible = false),
              icon: Icon(Icons.arrow_back, color: textColor.withOpacity(0.6)),
              splashRadius: 20,
            ),
          IconButton(
            onPressed: _handleClose,
            icon: Icon(Icons.close, color: textColor.withOpacity(0.6)),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildMainView(Color textColor, Color subtitleColor,
      Color primaryColor, Color dividerColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room count input
          _buildSectionLabel('Number of Rooms', subtitleColor),
          const SizedBox(height: MediasfuSpacing.xs),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _numRoomsController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: '1-10',
                    hintStyle: TextStyle(color: subtitleColor),
                    filled: true,
                    fillColor: (isDark ? Colors.white : Colors.black)
                        .withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: MediasfuSpacing.md,
                        vertical: MediasfuSpacing.sm),
                  ),
                ),
              ),
              const SizedBox(width: MediasfuSpacing.sm),
              _buildActionChip(
                  'Random', Icons.shuffle, _handleRandomAssign, primaryColor),
              const SizedBox(width: MediasfuSpacing.xs),
              _buildActionChip(
                  'Manual', Icons.touch_app, _handleManualAssign, primaryColor),
            ],
          ),
          const SizedBox(height: MediasfuSpacing.md),

          // New participant action
          _buildSectionLabel('New Participant Action', subtitleColor),
          const SizedBox(height: MediasfuSpacing.xs),
          Tooltip(
            message: 'Configure how new participants are assigned to rooms',
            decoration: MediasfuColors.tooltipDecoration(darkMode: isDark),
            textStyle: TextStyle(
              color: MediasfuColors.tooltipText(darkMode: isDark),
              fontSize: 12,
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: MediasfuSpacing.md),
              decoration: MediasfuColors.dropdownDecoration(darkMode: isDark),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _newParticipantAction,
                  isExpanded: true,
                  style: MediasfuColors.dropdownTextStyle(darkMode: isDark),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark
                        ? MediasfuColors.primaryDark
                        : MediasfuColors.primary,
                  ),
                  dropdownColor:
                      MediasfuColors.dropdownBackground(darkMode: isDark),
                  onChanged: (v) => setState(() => _newParticipantAction = v!),
                  items: const [
                    DropdownMenuItem(
                        value: 'autoAssignNewRoom',
                        child: Text('Add to new room')),
                    DropdownMenuItem(
                        value: 'autoAssignAvailableRoom',
                        child: Text('Add to open room')),
                    DropdownMenuItem(
                        value: 'manualAssign', child: Text('No action')),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: MediasfuSpacing.md),

          // Rooms list
          Row(
            children: [
              Expanded(
                  child: _buildSectionLabel(
                      'Rooms (${_breakoutRooms.length})', subtitleColor)),
              TextButton.icon(
                onPressed: _handleAddRoom,
                icon: Icon(Icons.add, size: 18, color: primaryColor),
                label: Text('Add Room', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
          const SizedBox(height: MediasfuSpacing.xs),
          if (_breakoutRooms.isEmpty)
            _buildEmptyState(subtitleColor)
          else
            ...List.generate(
                _breakoutRooms.length,
                (i) => _buildRoomCard(i, textColor, subtitleColor, primaryColor,
                    dividerColor, isDark)),

          const SizedBox(height: MediasfuSpacing.lg),
          _buildFooterButtons(primaryColor),
        ],
      ),
    );
  }

  Widget _buildEditRoomView(Color textColor, Color subtitleColor,
      Color primaryColor, Color dividerColor, bool isDark) {
    final currentRoom = _breakoutRooms[_currentRoomIndex];
    final unassigned = _participants.where((p) => p.breakRoom == null).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Assigned (${currentRoom.length})', subtitleColor),
          const SizedBox(height: MediasfuSpacing.xs),
          if (currentRoom.isEmpty)
            Padding(
              padding: const EdgeInsets.all(MediasfuSpacing.md),
              child: Text('No participants assigned',
                  style: TextStyle(
                      color: subtitleColor, fontStyle: FontStyle.italic)),
            )
          else
            Wrap(
              spacing: MediasfuSpacing.xs,
              runSpacing: MediasfuSpacing.xs,
              children: currentRoom
                  .map((p) => _buildParticipantChip(
                        p.name,
                        onRemove: () =>
                            _handleRemoveParticipant(_currentRoomIndex, p),
                        textColor: textColor,
                        primaryColor: primaryColor,
                        isDark: isDark,
                      ))
                  .toList(),
            ),
          const SizedBox(height: MediasfuSpacing.md),
          Divider(color: dividerColor),
          const SizedBox(height: MediasfuSpacing.md),
          _buildSectionLabel(
              'Unassigned (${unassigned.length})', subtitleColor),
          const SizedBox(height: MediasfuSpacing.xs),
          if (unassigned.isEmpty)
            Padding(
              padding: const EdgeInsets.all(MediasfuSpacing.md),
              child: Text('All participants assigned',
                  style: TextStyle(
                      color: subtitleColor, fontStyle: FontStyle.italic)),
            )
          else
            Wrap(
              spacing: MediasfuSpacing.xs,
              runSpacing: MediasfuSpacing.xs,
              children: unassigned
                  .map((p) => _buildParticipantChip(
                        p.name,
                        onAdd: () => _handleAddParticipant(_currentRoomIndex,
                            BreakoutParticipant(name: p.name)),
                        textColor: textColor,
                        primaryColor: primaryColor,
                        isDark: isDark,
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, Color color) {
    return Text(text,
        style:
            TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color));
  }

  Widget _buildActionChip(
      String label, IconData icon, VoidCallback onPressed, Color primaryColor) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: MediasfuSpacing.sm, vertical: MediasfuSpacing.xs),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: primaryColor),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: primaryColor,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.lg),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.workspaces_outline,
                size: 48, color: subtitleColor.withOpacity(0.5)),
            const SizedBox(height: MediasfuSpacing.sm),
            Text('No rooms created', style: TextStyle(color: subtitleColor)),
            const SizedBox(height: MediasfuSpacing.xs),
            Text('Enter a number and tap Random or Manual',
                style: TextStyle(
                    fontSize: 12, color: subtitleColor.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(int index, Color textColor, Color subtitleColor,
      Color primaryColor, Color dividerColor, bool isDark) {
    final room = _breakoutRooms[index];
    return Container(
      margin: const EdgeInsets.only(bottom: MediasfuSpacing.sm),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: MediasfuSpacing.md, vertical: MediasfuSpacing.sm),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: primaryColor.withOpacity(0.15),
                  child: Text('${index + 1}',
                      style: TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: MediasfuSpacing.sm),
                Expanded(
                  child: Text('Room ${index + 1}',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: textColor)),
                ),
                Text('${room.length} participant${room.length != 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 12, color: subtitleColor)),
                const SizedBox(width: MediasfuSpacing.sm),
                IconButton(
                  onPressed: () => _handleEditRoom(index),
                  icon:
                      Icon(Icons.edit_outlined, size: 18, color: primaryColor),
                  splashRadius: 18,
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _handleDeleteRoom(index),
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: MediasfuColors.danger),
                  splashRadius: 18,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
          if (room.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(MediasfuSpacing.md, 0,
                  MediasfuSpacing.md, MediasfuSpacing.sm),
              child: Wrap(
                spacing: MediasfuSpacing.xs,
                runSpacing: MediasfuSpacing.xs,
                children: room
                    .map((p) => Chip(
                          label: Text(p.name,
                              style: TextStyle(fontSize: 12, color: textColor)),
                          backgroundColor:
                              (isDark ? Colors.white : Colors.black)
                                  .withOpacity(0.05),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          deleteIcon:
                              Icon(Icons.close, size: 14, color: subtitleColor),
                          onDeleted: () => _handleRemoveParticipant(index, p),
                        ))
                    .toList(),
              ),
            ),
          if (room.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(MediasfuSpacing.md, 0,
                  MediasfuSpacing.md, MediasfuSpacing.sm),
              child: Text('Tap edit to assign participants',
                  style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                      fontStyle: FontStyle.italic)),
            ),
        ],
      ),
    );
  }

  Widget _buildParticipantChip(String name,
      {VoidCallback? onAdd,
      VoidCallback? onRemove,
      required Color textColor,
      required Color primaryColor,
      required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: MediasfuSpacing.sm, vertical: MediasfuSpacing.xs),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: primaryColor.withOpacity(0.2),
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                    fontSize: 10,
                    color: primaryColor,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: MediasfuSpacing.xs),
          Text(name, style: TextStyle(fontSize: 13, color: textColor)),
          const SizedBox(width: MediasfuSpacing.xs),
          if (onAdd != null)
            InkWell(
              onTap: onAdd,
              child: Icon(Icons.add_circle_outline,
                  size: 18, color: MediasfuColors.successDark),
            ),
          if (onRemove != null)
            InkWell(
              onTap: onRemove,
              child: Icon(Icons.remove_circle_outline,
                  size: 18, color: MediasfuColors.danger),
            ),
        ],
      ),
    );
  }

  Widget _buildFooterButtons(Color primaryColor) {
    final showStart =
        (!_breakOutRoomStarted || _breakOutRoomEnded) && _canStartBreakout;
    final showUpdate =
        _breakOutRoomStarted && !_breakOutRoomEnded && _canStartBreakout;
    final showStop = _breakOutRoomStarted && !_breakOutRoomEnded;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _handleSaveRooms,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: MediasfuSpacing.sm),
            ),
          ),
        ),
        const SizedBox(width: MediasfuSpacing.sm),
        if (showStart)
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _handleStartBreakout,
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Start Breakout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: MediasfuSpacing.sm),
              ),
            ),
          ),
        if (showUpdate)
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _handleStartBreakout,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: MediasfuSpacing.sm),
              ),
            ),
          ),
        if (showStop) ...[
          const SizedBox(width: MediasfuSpacing.sm),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleStopBreakout,
              icon: const Icon(Icons.stop, size: 18),
              label: const Text('Stop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MediasfuColors.dangerDark,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: MediasfuSpacing.sm),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
