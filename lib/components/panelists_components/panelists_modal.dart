import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show Participant, ShowAlert;
import '../../methods/panelists_methods/update_panelists.dart'
    show
        updatePanelists,
        UpdatePanelistsOptions,
        addPanelist,
        AddPanelistOptions,
        removePanelist,
        RemovePanelistOptions;
import '../../methods/panelists_methods/focus_panelists.dart'
    show
        focusPanelists,
        FocusPanelistsOptions,
        unfocusPanelists,
        UnfocusPanelistsOptions;

/// Options class for configuring the PanelistsModal.
class PanelistsModalOptions {
  final Color backgroundColor;
  final bool isPanelistsModalVisible;
  final VoidCallback onPanelistsClose;
  // Core properties
  final io.Socket? socket;
  final String roomName;
  final String member;
  final String islevel;
  final List<Participant> participants;
  final int itemPageLimit;
  final ShowAlert? showAlert;
  // Panelists state
  final List<Participant> panelists;
  final bool panelistsFocused;
  final bool muteOthersMic;
  final bool muteOthersCamera;
  // Update functions
  final void Function(List<Participant>)? updatePanelists;
  final void Function(bool)? updatePanelistsFocused;
  final void Function(bool)? updateMuteOthersMic;
  final void Function(bool)? updateMuteOthersCamera;
  final String? position;

  PanelistsModalOptions({
    this.backgroundColor = const Color(0xFF83C0E9),
    required this.isPanelistsModalVisible,
    required this.onPanelistsClose,
    this.socket,
    required this.roomName,
    required this.member,
    required this.islevel,
    required this.participants,
    required this.itemPageLimit,
    this.showAlert,
    required this.panelists,
    this.panelistsFocused = false,
    this.muteOthersMic = false,
    this.muteOthersCamera = false,
    this.updatePanelists,
    this.updatePanelistsFocused,
    this.updateMuteOthersMic,
    this.updateMuteOthersCamera,
    this.position,
  });
}

typedef PanelistsModalType = Widget Function(
    {required PanelistsModalOptions options});

/// PanelistsModal - Modal for managing panelists in a meeting.
///
/// Features:
/// - Select participants as panelists (up to itemPageLimit)
/// - Focus mode to display only panelists on the grid
/// - Option to mute non-panelists' mic and camera when focusing
/// - Search and filter available participants
///
/// Example:
/// ```dart
/// PanelistsModal(
///   options: PanelistsModalOptions(
///     isVisible: isPanelistsModalVisible,
///     onClose: () => setState(() => isPanelistsModalVisible = false),
///     parameters: parameters,
///   ),
/// )
/// ```
class PanelistsModal extends StatefulWidget {
  final PanelistsModalOptions options;

  const PanelistsModal({
    super.key,
    required this.options,
  });

  @override
  State<PanelistsModal> createState() => _PanelistsModalState();
}

class _PanelistsModalState extends State<PanelistsModal> {
  String _searchQuery = '';
  bool _muteOthersMicLocal = false;
  bool _muteOthersCameraLocal = false;
  bool _focusEnabledLocal = false;

  PanelistsModalOptions get options => widget.options;

  @override
  void initState() {
    super.initState();
    _syncLocalState();
  }

  @override
  void didUpdateWidget(covariant PanelistsModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncLocalState();
  }

  void _syncLocalState() {
    _muteOthersMicLocal = options.muteOthersMic;
    _muteOthersCameraLocal = options.muteOthersCamera;
    _focusEnabledLocal = options.panelistsFocused;
  }

  /// Get list of non-host participants excluding current panelists.
  List<Participant> get _availableParticipants {
    return options.participants.where((p) {
      // Exclude host (isLevel 2)
      if (p.islevel == "2") return false;
      // Exclude current panelists
      if (options.panelists.any((pan) => pan.id == p.id)) return false;
      // Filter by search
      if (_searchQuery.isNotEmpty) {
        return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();
  }

  /// Handle adding a panelist.
  Future<void> _handleAddPanelist(Participant participant) async {
    if (options.socket == null) return;

    final success = await addPanelist(AddPanelistOptions(
      socket: options.socket!,
      participant: participant,
      currentPanelists: options.panelists,
      maxPanelists: options.itemPageLimit,
      roomName: options.roomName,
      member: options.member,
      islevel: options.islevel,
      showAlert: options.showAlert,
    ));

    if (success) {
      // Optimistically update local state
      final updatedPanelists = [...options.panelists, participant];
      if (options.updatePanelists != null) {
        options.updatePanelists!(updatedPanelists);
        setState(() {});
      }
    }
  }

  /// Handle removing a panelist.
  Future<void> _handleRemovePanelist(Participant participant) async {
    if (options.socket == null) return;

    await removePanelist(RemovePanelistOptions(
      socket: options.socket!,
      participant: participant,
      roomName: options.roomName,
      member: options.member,
      islevel: options.islevel,
      showAlert: options.showAlert,
    ));

    // Optimistically update local state
    final updatedPanelists =
        options.panelists.where((p) => p.id != participant.id).toList();

    options.updatePanelists?.call(updatedPanelists);
    setState(() {});
  }

  /// Handle toggling focus mode.
  Future<void> _handleToggleFocus() async {
    if (options.socket == null) return;

    final newFocusState = !_focusEnabledLocal;

    if (newFocusState) {
      // Enable focus
      await focusPanelists(FocusPanelistsOptions(
        socket: options.socket!,
        roomName: options.roomName,
        member: options.member,
        islevel: options.islevel,
        focusEnabled: true,
        muteOthersMic: _muteOthersMicLocal,
        muteOthersCamera: _muteOthersCameraLocal,
        showAlert: options.showAlert,
      ));
    } else {
      // Disable focus
      await unfocusPanelists(UnfocusPanelistsOptions(
        socket: options.socket!,
        roomName: options.roomName,
        member: options.member,
        islevel: options.islevel,
        showAlert: options.showAlert,
      ));
    }

    setState(() {
      _focusEnabledLocal = newFocusState;
    });

    options.updatePanelistsFocused?.call(newFocusState);
    options.updateMuteOthersMic
        ?.call(newFocusState ? _muteOthersMicLocal : false);
    options.updateMuteOthersCamera
        ?.call(newFocusState ? _muteOthersCameraLocal : false);
  }

  /// Update focus options (called when already focused).
  Future<void> _handleUpdateFocusOptions() async {
    if (options.socket == null || !_focusEnabledLocal) return;

    await focusPanelists(FocusPanelistsOptions(
      socket: options.socket!,
      roomName: options.roomName,
      member: options.member,
      islevel: options.islevel,
      focusEnabled: true,
      muteOthersMic: _muteOthersMicLocal,
      muteOthersCamera: _muteOthersCameraLocal,
      showAlert: options.showAlert,
    ));

    options.updateMuteOthersMic?.call(_muteOthersMicLocal);
    options.updateMuteOthersCamera?.call(_muteOthersCameraLocal);
  }

  /// Clear all panelists.
  Future<void> _handleClearAll() async {
    if (options.socket == null) return;

    // If focused, unfocus first
    if (_focusEnabledLocal) {
      await unfocusPanelists(UnfocusPanelistsOptions(
        socket: options.socket!,
        roomName: options.roomName,
        member: options.member,
        islevel: options.islevel,
        showAlert: options.showAlert,
      ));
      setState(() {
        _focusEnabledLocal = false;
      });
      options.updatePanelistsFocused?.call(false);
    }

    // Clear panelists via socket
    await updatePanelists(UpdatePanelistsOptions(
      socket: options.socket!,
      panelists: [],
      roomName: options.roomName,
      member: options.member,
      islevel: options.islevel,
      showAlert: options.showAlert,
    ));

    if (options.updatePanelists != null) {
      options.updatePanelists!([]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.options.isPanelistsModalVisible) return const SizedBox.shrink();

    final isHost = options.islevel == "2";

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          color: widget.options.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Panelists Section
                    _buildCurrentPanelistsSection(),

                    const SizedBox(height: 16),

                    // Focus Options Section
                    if (isHost) _buildFocusOptionsSection(),

                    const SizedBox(height: 16),

                    // Available Participants Section
                    if (isHost) _buildAvailableParticipantsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.people_outline, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                'Panelists (${options.panelists.length}/${options.itemPageLimit})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.options.onPanelistsClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPanelistsSection() {
    final panelists = options.panelists;
    final isHost = options.islevel == "2";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Panelists',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (isHost && panelists.isNotEmpty)
                TextButton.icon(
                  onPressed: _handleClearAll,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (panelists.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No panelists selected',
                  style: TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: panelists.map((panelist) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      panelist.name.isNotEmpty
                          ? panelist.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                  label: Text(panelist.name),
                  deleteIcon: isHost ? const Icon(Icons.close, size: 18) : null,
                  onDeleted:
                      isHost ? () => _handleRemovePanelist(panelist) : null,
                  backgroundColor: Colors.blue[50],
                  side: BorderSide(color: Colors.blue[200]!),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFocusOptionsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _focusEnabledLocal ? Colors.green[400]! : Colors.grey[300]!,
          width: _focusEnabledLocal ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _focusEnabledLocal ? Icons.visibility : Icons.visibility_off,
                color: _focusEnabledLocal ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Focus Mode',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Switch(
                value: _focusEnabledLocal,
                onChanged: options.panelists.isNotEmpty
                    ? (_) => _handleToggleFocus()
                    : null,
                activeThumbColor: Colors.green,
              ),
            ],
          ),
          if (options.panelists.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Add panelists to enable focus mode',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),

          // Mute options
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  value: _muteOthersMicLocal,
                  onChanged: (value) {
                    setState(() {
                      _muteOthersMicLocal = value ?? false;
                    });
                    if (_focusEnabledLocal) {
                      _handleUpdateFocusOptions();
                    }
                  },
                  title: const Text(
                    'Mute Others\' Mic',
                    style: TextStyle(fontSize: 13),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  value: _muteOthersCameraLocal,
                  onChanged: (value) {
                    setState(() {
                      _muteOthersCameraLocal = value ?? false;
                    });
                    if (_focusEnabledLocal) {
                      _handleUpdateFocusOptions();
                    }
                  },
                  title: const Text(
                    'Mute Others\' Camera',
                    style: TextStyle(fontSize: 13),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ),

          if (_focusEnabledLocal)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Focus mode active - Only panelists visible',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvailableParticipantsSection() {
    final availableParticipants = _availableParticipants;
    final canAddMore = options.panelists.length < options.itemPageLimit;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Panelists',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Search box
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search participants...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),

          if (!canAddMore)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[700], size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Maximum panelists reached',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
            ),

          // Participant list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: availableParticipants.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No participants available',
                        style: TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableParticipants.length,
                    itemBuilder: (context, index) {
                      final participant = availableParticipants[index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 0),
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[200],
                          child: Text(
                            participant.name.isNotEmpty
                                ? participant.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        title: Text(
                          participant.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          _getLevelLabel(participant.islevel ?? "0"),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            color: canAddMore ? Colors.green : Colors.grey,
                          ),
                          onPressed: canAddMore
                              ? () => _handleAddPanelist(participant)
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getLevelLabel(String level) {
    switch (level) {
      case "2":
        return "Host";
      case "1":
        return "Elevated";
      default:
        return "Participant";
    }
  }
}
