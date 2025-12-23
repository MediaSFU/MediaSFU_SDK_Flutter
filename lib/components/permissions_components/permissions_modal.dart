import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show Participant, ShowAlert;
import '../../methods/permissions_methods/update_participant_permission.dart';
import '../../methods/permissions_methods/update_permission_config.dart';

// ============================================================================
// TYPES & INTERFACES
// ============================================================================

/// Options for the PermissionsModal widget
class PermissionsModalOptions {
  final bool isPermissionsModalVisible;
  final VoidCallback onPermissionsClose;
  final List<Participant> participants;
  final String member;
  final String islevel;
  final io.Socket? socket;
  final String roomName;
  final ShowAlert? showAlert;
  final PermissionConfig? permissionConfig;
  final void Function(PermissionConfig)? updatePermissionConfig;
  final Color? backgroundColor;
  final String position;
  // Event settings for initial values when permissionConfig is not set
  final String? audioSetting;
  final String? videoSetting;
  final String? screenshareSetting;
  final String? chatSetting;

  PermissionsModalOptions({
    required this.isPermissionsModalVisible,
    required this.onPermissionsClose,
    required this.participants,
    required this.member,
    required this.islevel,
    this.socket,
    required this.roomName,
    this.showAlert,
    this.permissionConfig,
    this.updatePermissionConfig,
    this.backgroundColor,
    this.position = 'topRight',
    this.audioSetting,
    this.videoSetting,
    this.screenshareSetting,
    this.chatSetting,
  });
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

String _getLevelLabel(String level) {
  switch (level) {
    case "2":
      return "Host";
    case "1":
      return "Elevated";
    case "0":
      return "Basic";
    default:
      return "Unknown";
  }
}

Color _getLevelColor(String level) {
  switch (level) {
    case "2":
      return const Color(0xFF22c55e); // green
    case "1":
      return const Color(0xFF3b82f6); // blue
    case "0":
      return const Color(0xFF6b7280); // gray
    default:
      return const Color(0xFF6b7280);
  }
}

IconData _getCapabilityIcon(String capability) {
  switch (capability) {
    case 'useMic':
      return Icons.mic;
    case 'useCamera':
      return Icons.videocam;
    case 'useScreen':
      return Icons.screen_share;
    case 'useChat':
      return Icons.chat;
    default:
      return Icons.help_outline;
  }
}

String _getCapabilityLabel(String capability) {
  switch (capability) {
    case 'useMic':
      return 'Microphone';
    case 'useCamera':
      return 'Camera';
    case 'useScreen':
      return 'Screen Share';
    case 'useChat':
      return 'Chat';
    default:
      return capability;
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'allow':
      return const Color(0xFF22c55e);
    case 'approval':
      return const Color(0xFFf59e0b);
    case 'disallow':
      return const Color(0xFFef4444);
    default:
      return Colors.grey;
  }
}

IconData _getStatusIcon(String status) {
  switch (status) {
    case 'allow':
      return Icons.check;
    case 'approval':
      return Icons.schedule;
    case 'disallow':
      return Icons.block;
    default:
      return Icons.help_outline;
  }
}

// ============================================================================
// MAIN WIDGET
// ============================================================================

/// PermissionsModal - Modal for managing participant permissions.
///
/// Features two tabs:
/// 1. Permission Config - Configure what each permission level can do
/// 2. User Permissions - Update individual/bulk participant permission levels
class PermissionsModal extends StatefulWidget {
  final PermissionsModalOptions options;

  const PermissionsModal({super.key, required this.options});

  @override
  State<PermissionsModal> createState() => _PermissionsModalState();
}

class _PermissionsModalState extends State<PermissionsModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchFilter = '';
  final Set<String> _selectedParticipants = {};
  String? _expandedLevel;
  late PermissionConfig _localConfig;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Use permissionConfig if set, otherwise derive from event settings
    _localConfig = widget.options.permissionConfig ??
        getPermissionConfigFromEventSettings(
          audioSetting: widget.options.audioSetting ?? 'approval',
          videoSetting: widget.options.videoSetting ?? 'approval',
          screenshareSetting: widget.options.screenshareSetting ?? 'disallow',
          chatSetting: widget.options.chatSetting ?? 'allow',
        );
    _expandedLevel = 'level0';
  }

  @override
  void didUpdateWidget(covariant PermissionsModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update localConfig if permissionConfig or event settings changed
    if (widget.options.permissionConfig != null) {
      if (widget.options.permissionConfig !=
          oldWidget.options.permissionConfig) {
        _localConfig = widget.options.permissionConfig!;
      }
    } else if (widget.options.audioSetting != oldWidget.options.audioSetting ||
        widget.options.videoSetting != oldWidget.options.videoSetting ||
        widget.options.screenshareSetting !=
            oldWidget.options.screenshareSetting ||
        widget.options.chatSetting != oldWidget.options.chatSetting) {
      _localConfig = getPermissionConfigFromEventSettings(
        audioSetting: widget.options.audioSetting ?? 'approval',
        videoSetting: widget.options.videoSetting ?? 'approval',
        screenshareSetting: widget.options.screenshareSetting ?? 'disallow',
        chatSetting: widget.options.chatSetting ?? 'allow',
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Participant> get _participants {
    return widget.options.participants;
  }

  List<Participant> get _filteredParticipants {
    return _participants
        .where((p) => p.islevel != "2") // Exclude host
        .where((p) =>
            _searchFilter.isEmpty ||
            (p.name.toLowerCase().contains(_searchFilter.toLowerCase())))
        .toList();
  }

  Map<String, List<Participant>> get _participantsByLevel {
    final grouped = <String, List<Participant>>{"1": [], "0": []};
    for (final p in _filteredParticipants) {
      final level = p.islevel ?? "0";
      if (grouped.containsKey(level)) {
        grouped[level]!.add(p);
      }
    }
    return grouped;
  }

  bool get _isHost => widget.options.islevel == "2";

  void _handleParticipantSelect(String participantId) {
    setState(() {
      if (_selectedParticipants.contains(participantId)) {
        _selectedParticipants.remove(participantId);
      } else {
        _selectedParticipants.add(participantId);
      }
    });
  }

  void _handleSelectAll() {
    setState(() {
      if (_selectedParticipants.length == _filteredParticipants.length) {
        _selectedParticipants.clear();
      } else {
        _selectedParticipants.clear();
        _selectedParticipants
            .addAll(_filteredParticipants.map((p) => p.id ?? ''));
      }
    });
  }

  Future<void> _handleBulkUpdate(String newLevel) async {
    final selectedList = _filteredParticipants
        .where((p) => _selectedParticipants.contains(p.id ?? ''))
        .toList();

    if (selectedList.isEmpty) {
      widget.options.showAlert?.call(
        message: "Please select participants to update",
        type: "danger",
        duration: 3000,
      );
      return;
    }

    await bulkUpdateParticipantPermissions(
        BulkUpdateParticipantPermissionsOptions(
      socket: widget.options.socket!,
      participants: selectedList,
      newLevel: newLevel,
      member: widget.options.member,
      islevel: widget.options.islevel,
      roomName: widget.options.roomName,
      showAlert: widget.options.showAlert,
      maxBatchSize: 50,
    ));

    setState(() {
      _selectedParticipants.clear();
    });
  }

  Future<void> _handleSingleUpdate(
      Participant participant, String newLevel) async {
    await updateParticipantPermission(UpdateParticipantPermissionOptions(
      socket: widget.options.socket!,
      participant: participant,
      newLevel: newLevel,
      member: widget.options.member,
      islevel: widget.options.islevel,
      roomName: widget.options.roomName,
      showAlert: widget.options.showAlert,
    ));
  }

  void _handleConfigChange(String levelKey, String capability, String value) {
    setState(() {
      if (levelKey == 'level0') {
        _localConfig = _localConfig.copyWith(
          level0:
              _getUpdatedCapabilities(_localConfig.level0, capability, value),
        );
      } else {
        _localConfig = _localConfig.copyWith(
          level1:
              _getUpdatedCapabilities(_localConfig.level1, capability, value),
        );
      }
    });
  }

  PermissionCapabilities _getUpdatedCapabilities(
      PermissionCapabilities current, String capability, String value) {
    switch (capability) {
      case 'useMic':
        return current.copyWith(useMic: value);
      case 'useCamera':
        return current.copyWith(useCamera: value);
      case 'useScreen':
        return current.copyWith(useScreen: value);
      case 'useChat':
        return current.copyWith(useChat: value);
      default:
        return current;
    }
  }

  Future<void> _handleSaveConfig() async {
    await updatePermissionConfig(UpdatePermissionConfigOptions(
      socket: widget.options.socket!,
      config: _localConfig,
      member: widget.options.member,
      islevel: widget.options.islevel,
      roomName: widget.options.roomName,
      showAlert: widget.options.showAlert,
    ));
    widget.options.updatePermissionConfig?.call(_localConfig);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.options.isPermissionsModalVisible) {
      return const SizedBox.shrink();
    }

    final bgColor = widget.options.backgroundColor ?? const Color(0xFF1e293b);
    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth > 500 ? 450.0 : screenWidth * 0.9;

    return Positioned(
      top: 10,
      right: 10,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: modalWidth,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildTabs(),
              Flexible(
                child: _tabController.index == 0
                    ? _buildUsersTab()
                    : _buildConfigTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3b82f6), Color(0xFF2563eb)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          const Text(
            'Permissions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: widget.options.onPermissionsClose,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        indicatorColor: const Color(0xFF3b82f6),
        labelColor: const Color(0xFF3b82f6),
        unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
        tabs: const [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people, size: 16),
                SizedBox(width: 8),
                Text('User Permissions'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings, size: 16),
                SizedBox(width: 8),
                Text('Level Config'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndActions(),
          const SizedBox(height: 16),
          ..._buildParticipantLists(),
        ],
      ),
    );
  }

  Widget _buildSearchAndActions() {
    return Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => _searchFilter = value),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search participants...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3b82f6)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        if (_isHost) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton(
                onTap: _handleSelectAll,
                label:
                    _selectedParticipants.length == _filteredParticipants.length
                        ? 'Deselect All'
                        : 'Select All',
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                borderColor: Colors.white.withValues(alpha: 0.2),
              ),
              if (_selectedParticipants.isNotEmpty) ...[
                Text(
                  '${_selectedParticipants.length} selected →',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                _buildActionButton(
                  onTap: () => _handleBulkUpdate("1"),
                  label: 'Set Elevated',
                  backgroundColor: const Color(0xFF3b82f6),
                ),
                _buildActionButton(
                  onTap: () => _handleBulkUpdate("0"),
                  label: 'Set Basic',
                  backgroundColor: const Color(0xFF6b7280),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required String label,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  List<Widget> _buildParticipantLists() {
    return ['1', '0'].map((level) {
      final participants = _participantsByLevel[level] ?? [];
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getLevelColor(level),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getLevelLabel(level),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${participants.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (participants.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                child: Text(
                  'No participants at this level',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                ),
              )
            else
              ...participants.map((p) => _buildParticipantItem(p, level)),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildParticipantItem(Participant participant, String level) {
    final isSelected = _selectedParticipants.contains(participant.id ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF3b82f6).withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF3b82f6).withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          if (_isHost)
            Checkbox(
              value: isSelected,
              onChanged: (_) => _handleParticipantSelect(participant.id ?? ''),
              activeColor: const Color(0xFF3b82f6),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
            ),
          Expanded(
            child: Text(
              participant.name,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          if (_isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: participant.islevel ?? '0',
                  isDense: true,
                  dropdownColor: const Color(0xFF1e293b),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Colors.white, size: 18),
                  items: const [
                    DropdownMenuItem(value: '0', child: Text('Basic')),
                    DropdownMenuItem(value: '1', child: Text('Elevated')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _handleSingleUpdate(participant, value);
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfigTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configure what each permission level can do. Host (level 2) always has full permissions.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          _buildConfigSection('level0', 'Basic (Level 0)', _localConfig.level0),
          const SizedBox(height: 12),
          _buildConfigSection(
              'level1', 'Elevated (Level 1)', _localConfig.level1),
          if (_isHost) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSaveConfig,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3b82f6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Configuration',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfigSection(
      String levelKey, String title, PermissionCapabilities capabilities) {
    final isExpanded = _expandedLevel == levelKey;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedLevel = isExpanded ? null : levelKey;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10),
                  topRight: const Radius.circular(10),
                  bottomLeft:
                      isExpanded ? Radius.zero : const Radius.circular(10),
                  bottomRight:
                      isExpanded ? Radius.zero : const Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getLevelColor(levelKey == 'level0' ? '0' : '1'),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCapabilityRow('useMic',
                      _getCapabilityValue(capabilities, 'useMic'), levelKey),
                  _buildCapabilityRow('useCamera',
                      _getCapabilityValue(capabilities, 'useCamera'), levelKey),
                  _buildCapabilityRow('useScreen',
                      _getCapabilityValue(capabilities, 'useScreen'), levelKey),
                  _buildCapabilityRow('useChat',
                      _getCapabilityValue(capabilities, 'useChat'), levelKey,
                      isChat: true),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getCapabilityValue(
      PermissionCapabilities capabilities, String capability) {
    switch (capability) {
      case 'useMic':
        return capabilities.useMic;
      case 'useCamera':
        return capabilities.useCamera;
      case 'useScreen':
        return capabilities.useScreen;
      case 'useChat':
        return capabilities.useChat;
      default:
        return 'allow';
    }
  }

  Widget _buildCapabilityRow(String capability, String value, String levelKey,
      {bool isChat = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getCapabilityIcon(capability),
            color: Colors.white.withValues(alpha: 0.6),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _getCapabilityLabel(capability),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          if (_isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isDense: true,
                  dropdownColor: const Color(0xFF1e293b),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Colors.white, size: 18),
                  items: [
                    const DropdownMenuItem(
                        value: 'allow', child: Text('Allow')),
                    if (!isChat)
                      const DropdownMenuItem(
                          value: 'approval', child: Text('Approval')),
                    const DropdownMenuItem(
                        value: 'disallow', child: Text('Disallow')),
                  ],
                  onChanged: (newValue) {
                    if (newValue != null) {
                      _handleConfigChange(levelKey, capability, newValue);
                    }
                  },
                ),
              ),
            )
          else
            Row(
              children: [
                Icon(_getStatusIcon(value),
                    color: _getStatusColor(value), size: 16),
                const SizedBox(width: 6),
                Text(
                  value[0].toUpperCase() + value.substring(1),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
