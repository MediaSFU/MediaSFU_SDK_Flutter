import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show Participant, ShowAlert;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../../methods/permissions_methods/update_participant_permission.dart';
import '../../methods/permissions_methods/update_permission_config.dart';
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/theme/mediasfu_typography.dart';
import '../core/widgets/glassmorphic_container.dart';
import '../core/widgets/premium_button.dart';

// ============================================================================
// OPTIONS CLASS
// ============================================================================

/// Options for the ModernPermissionsModal widget
class ModernPermissionsModalOptions {
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
  final bool isDarkMode;
  final bool enableGlassmorphism;
  final bool enableGlow;
  final ModalRenderMode renderMode;
  // Event settings for initial values when permissionConfig is not set
  final String? audioSetting;
  final String? videoSetting;
  final String? screenshareSetting;
  final String? chatSetting;

  ModernPermissionsModalOptions({
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
    this.isDarkMode = true,
    this.enableGlassmorphism = true,
    this.enableGlow = true,
    this.renderMode = ModalRenderMode.modal,
    this.audioSetting,
    this.videoSetting,
    this.screenshareSetting,
    this.chatSetting,
  });
}

typedef ModernPermissionsModalType = Widget Function(
    {required ModernPermissionsModalOptions options});

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

Color _getLevelColor(String level, bool isDarkMode) {
  switch (level) {
    case "2":
      return MediasfuColors.success;
    case "1":
      return MediasfuColors.secondary;
    case "0":
      return isDarkMode
          ? MediasfuColors.textMutedDark
          : MediasfuColors.textMuted;
    default:
      return MediasfuColors.textMutedDark;
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
      return MediasfuColors.success;
    case 'approval':
      return MediasfuColors.warning;
    case 'disallow':
      return MediasfuColors.danger;
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

/// ModernPermissionsModal - Premium styled modal for managing participant permissions.
///
/// Features two tabs:
/// 1. User Permissions - Update individual/bulk participant permission levels
/// 2. Level Config - Configure what each permission level can do
class ModernPermissionsModal extends StatefulWidget {
  final ModernPermissionsModalOptions options;

  const ModernPermissionsModal({super.key, required this.options});

  @override
  State<ModernPermissionsModal> createState() => _ModernPermissionsModalState();
}

class _ModernPermissionsModalState extends State<ModernPermissionsModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  int _activeTab = 0; // 0 = users, 1 = config
  String _searchFilter = '';
  final Set<String> _selectedParticipants = {};
  String? _expandedLevel;
  late PermissionConfig _localConfig;

  // Loading states for visual feedback
  bool _isUpdatingConfig = false;
  bool _isUpdatingParticipants = false;
  String? _updatingParticipantId;

  bool get isDarkMode => widget.options.isDarkMode;
  bool get isSidebarMode =>
      widget.options.renderMode == ModalRenderMode.sidebar ||
      widget.options.renderMode == ModalRenderMode.inline;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Use permissionConfig if set, otherwise derive from event settings
    _localConfig = widget.options.permissionConfig ??
        getPermissionConfigFromEventSettings(
          audioSetting: widget.options.audioSetting ?? 'approval',
          videoSetting: widget.options.videoSetting ?? 'approval',
          screenshareSetting: widget.options.screenshareSetting ?? 'disallow',
          chatSetting: widget.options.chatSetting ?? 'allow',
        );
    _expandedLevel = 'level0';

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ModernPermissionsModal oldWidget) {
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

  void _handleClose() {
    if (isSidebarMode) {
      widget.options.onPermissionsClose();
    } else {
      _animationController.reverse().then((_) {
        widget.options.onPermissionsClose();
      });
    }
  }

  List<Participant> get _filteredParticipants {
    return widget.options.participants
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

    setState(() => _isUpdatingParticipants = true);
    try {
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
    } finally {
      setState(() => _isUpdatingParticipants = false);
    }
  }

  Future<void> _handleSingleUpdate(
      Participant participant, String newLevel) async {
    setState(() => _updatingParticipantId = participant.id);
    try {
      await updateParticipantPermission(UpdateParticipantPermissionOptions(
        socket: widget.options.socket!,
        participant: participant,
        newLevel: newLevel,
        member: widget.options.member,
        islevel: widget.options.islevel,
        roomName: widget.options.roomName,
        showAlert: widget.options.showAlert,
      ));
    } finally {
      setState(() => _updatingParticipantId = null);
    }
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
    setState(() => _isUpdatingConfig = true);
    try {
      await updatePermissionConfig(UpdatePermissionConfigOptions(
        socket: widget.options.socket!,
        config: _localConfig,
        member: widget.options.member,
        islevel: widget.options.islevel,
        roomName: widget.options.roomName,
        showAlert: widget.options.showAlert,
      ));
      widget.options.updatePermissionConfig?.call(_localConfig);
    } finally {
      setState(() => _isUpdatingConfig = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.options.isPermissionsModalVisible) {
      return const SizedBox.shrink();
    }

    final content = _buildContent();

    // For sidebar/inline mode, render content directly without modal wrapper
    if (isSidebarMode) {
      return content;
    }

    final mediaSize = MediaQuery.of(context).size;
    final modalWidth = math.min(mediaSize.width * 0.9, 460.0);
    final modalHeight = mediaSize.height * 0.8;

    final positionData = getModalPosition(
      GetModalPositionOptions(
        position: widget.options.position,
        modalWidth: modalWidth,
        modalHeight: modalHeight,
        context: context,
      ),
    );

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: _handleClose,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),
          ),

          // Modal
          Positioned(
            top: positionData['top'],
            right: positionData['right'],
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SizedBox(
                  width: modalWidth,
                  height: modalHeight,
                  child: content,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final containerChild = Column(
      children: [
        _buildHeader(),
        _buildTabs(),
        Expanded(
          child: _activeTab == 0 ? _buildUsersTab() : _buildConfigTab(),
        ),
      ],
    );

    // For sidebar mode, use simpler container without blur
    if (isSidebarMode) {
      return Container(
        decoration: BoxDecoration(
          color:
              isDarkMode ? MediasfuColors.surfaceDark : MediasfuColors.surface,
        ),
        child: containerChild,
      );
    }

    // For modal mode, use glassmorphic container
    return GlassmorphicContainer(
      borderRadius: MediasfuSpacing.lg,
      blur: widget.options.enableGlassmorphism ? 20 : 0,
      padding: EdgeInsets.zero,
      child: containerChild,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.md,
        vertical: MediasfuSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: MediasfuColors.simpleBrandGradient(darkMode: isDarkMode),
        borderRadius: isSidebarMode
            ? BorderRadius.zero
            : BorderRadius.only(
                topLeft: Radius.circular(MediasfuSpacing.lg),
                topRight: Radius.circular(MediasfuSpacing.lg),
              ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
            size: 22,
          ),
          SizedBox(width: MediasfuSpacing.sm),
          Expanded(
            child: Text(
              'Permissions',
              style: MediasfuTypography.getTitleMedium(true).copyWith(
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: _handleClose,
            child: Container(
              padding: EdgeInsets.all(MediasfuSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(MediasfuSpacing.xs),
              ),
              child: Icon(Icons.close, color: Colors.white, size: 18),
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
            color: MediasfuColors.glassBorder(darkMode: isDarkMode),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab(0, Icons.people, 'User Permissions')),
          Expanded(child: _buildTab(1, Icons.settings, 'Level Config')),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediasfuSpacing.md,
          vertical: MediasfuSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? (isDarkMode
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.04))
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isActive ? MediasfuColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? MediasfuColors.primary
                  : (isDarkMode
                      ? MediasfuColors.textSecondaryDark
                      : MediasfuColors.textSecondary),
            ),
            SizedBox(width: MediasfuSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? MediasfuColors.primary
                    : (isDarkMode
                        ? MediasfuColors.textSecondaryDark
                        : MediasfuColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediasfuSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndActions(),
          SizedBox(height: MediasfuSpacing.md),
          ..._buildParticipantLists(),
        ],
      ),
    );
  }

  Widget _buildSearchAndActions() {
    return Column(
      children: [
        // Search input
        Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(MediasfuSpacing.sm),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.12)
                  : Colors.black.withOpacity(0.12),
            ),
          ),
          child: TextField(
            onChanged: (value) => setState(() => _searchFilter = value),
            style: TextStyle(
              color: isDarkMode
                  ? MediasfuColors.textPrimaryDark
                  : MediasfuColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Search participants...',
              hintStyle: TextStyle(
                color: isDarkMode
                    ? MediasfuColors.textMutedDark
                    : MediasfuColors.textMuted,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: MediasfuSpacing.md,
                vertical: MediasfuSpacing.sm,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDarkMode
                    ? MediasfuColors.textMutedDark
                    : MediasfuColors.textMuted,
                size: 20,
              ),
            ),
          ),
        ),

        if (_isHost) ...[
          SizedBox(height: MediasfuSpacing.sm),
          Wrap(
            spacing: MediasfuSpacing.xs,
            runSpacing: MediasfuSpacing.xs,
            children: [
              _buildActionChip(
                onTap: _handleSelectAll,
                label:
                    _selectedParticipants.length == _filteredParticipants.length
                        ? 'Deselect All'
                        : 'Select All',
                isOutlined: true,
              ),
              if (_selectedParticipants.isNotEmpty) ...[
                Text(
                  '${_selectedParticipants.length} selected →',
                  style: TextStyle(
                    color: isDarkMode
                        ? MediasfuColors.textMutedDark
                        : MediasfuColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                _buildActionChip(
                  onTap: _isUpdatingParticipants
                      ? null
                      : () => _handleBulkUpdate("1"),
                  label: 'Set Elevated',
                  color: MediasfuColors.secondary,
                  isLoading: _isUpdatingParticipants,
                ),
                _buildActionChip(
                  onTap: _isUpdatingParticipants
                      ? null
                      : () => _handleBulkUpdate("0"),
                  label: 'Set Basic',
                  color: MediasfuColors.textMutedDark,
                  isLoading: _isUpdatingParticipants,
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionChip({
    required VoidCallback? onTap,
    required String label,
    Color? color,
    bool isOutlined = false,
    bool isLoading = false,
  }) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediasfuSpacing.sm,
            vertical: MediasfuSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isOutlined
                ? Colors.transparent
                : (color ?? MediasfuColors.primary),
            borderRadius: BorderRadius.circular(MediasfuSpacing.xs),
            border: isOutlined
                ? Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.2),
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOutlined
                          ? (isDarkMode
                              ? MediasfuColors.textPrimaryDark
                              : MediasfuColors.textPrimary)
                          : Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: MediasfuSpacing.xs),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isOutlined
                      ? (isDarkMode
                          ? MediasfuColors.textPrimaryDark
                          : MediasfuColors.textPrimary)
                      : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildParticipantLists() {
    return ['1', '0'].map((level) {
      final participants = _participantsByLevel[level] ?? [];
      return Container(
        margin: EdgeInsets.only(bottom: MediasfuSpacing.md),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.02),
          borderRadius: BorderRadius.circular(MediasfuSpacing.sm),
          border: Border.all(
            color: MediasfuColors.glassBorder(darkMode: isDarkMode),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediasfuSpacing.md,
                vertical: MediasfuSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(MediasfuSpacing.sm),
                  topRight: Radius.circular(MediasfuSpacing.sm),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getLevelColor(level, isDarkMode),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: MediasfuSpacing.sm),
                  Text(
                    _getLevelLabel(level),
                    style:
                        MediasfuTypography.getBodyMedium(isDarkMode).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: MediasfuSpacing.xs),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediasfuSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.15)
                          : Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      '${participants.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? MediasfuColors.textPrimaryDark
                            : MediasfuColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Participants list
            if (participants.isEmpty)
              Padding(
                padding: EdgeInsets.all(MediasfuSpacing.md),
                child: Center(
                  child: Text(
                    'No participants at this level',
                    style: TextStyle(
                      color: isDarkMode
                          ? MediasfuColors.textMutedDark
                          : MediasfuColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            else
              ...participants.map((p) => _buildParticipantItem(p)),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildParticipantItem(Participant participant) {
    final isSelected = _selectedParticipants.contains(participant.id ?? '');
    final isUpdating = _updatingParticipantId == participant.id;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.sm,
        vertical: MediasfuSpacing.xs,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.sm,
        vertical: MediasfuSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? MediasfuColors.primary.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(MediasfuSpacing.xs),
        border: Border.all(
          color: isSelected
              ? MediasfuColors.primary.withOpacity(0.5)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          if (_isHost)
            Checkbox(
              value: isSelected,
              onChanged: (_) => _handleParticipantSelect(participant.id ?? ''),
              activeColor: MediasfuColors.primary,
              side: BorderSide(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.4)
                    : Colors.black.withOpacity(0.4),
              ),
            ),
          Expanded(
            child: Text(
              participant.name,
              style: MediasfuTypography.getBodyMedium(isDarkMode),
            ),
          ),
          if (_isHost)
            isUpdating
                ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediasfuSpacing.md,
                      vertical: MediasfuSpacing.xs,
                    ),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDarkMode
                              ? MediasfuColors.textSecondaryDark
                              : MediasfuColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediasfuSpacing.sm,
                      vertical: MediasfuSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(MediasfuSpacing.xs),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.15),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: participant.islevel ?? '0',
                        isDense: true,
                        dropdownColor:
                            isDarkMode ? const Color(0xFF1e293b) : Colors.white,
                        style: TextStyle(
                          color: isDarkMode
                              ? MediasfuColors.textPrimaryDark
                              : MediasfuColors.textPrimary,
                          fontSize: 12,
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode
                              ? MediasfuColors.textSecondaryDark
                              : MediasfuColors.textSecondary,
                          size: 18,
                        ),
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
      padding: EdgeInsets.all(MediasfuSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configure what each permission level can do. Host (level 2) always has full permissions.',
            style: TextStyle(
              color: isDarkMode
                  ? MediasfuColors.textSecondaryDark
                  : MediasfuColors.textSecondary,
              fontSize: 13,
            ),
          ),
          SizedBox(height: MediasfuSpacing.md),
          _buildConfigSection('level0', 'Basic (Level 0)', _localConfig.level0),
          SizedBox(height: MediasfuSpacing.sm),
          _buildConfigSection(
              'level1', 'Elevated (Level 1)', _localConfig.level1),
          if (_isHost) ...[
            SizedBox(height: MediasfuSpacing.md),
            PremiumButton(
              fullWidth: true,
              variant: PremiumButtonVariant.gradient,
              isDarkMode: isDarkMode,
              onPressed: _isUpdatingConfig ? null : _handleSaveConfig,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isUpdatingConfig) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: MediasfuSpacing.sm),
                    Text('Saving...'),
                  ] else
                    Text('Save Configuration'),
                ],
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
        border:
            Border.all(color: MediasfuColors.glassBorder(darkMode: isDarkMode)),
        borderRadius: BorderRadius.circular(MediasfuSpacing.sm),
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
              padding: EdgeInsets.symmetric(
                horizontal: MediasfuSpacing.md,
                vertical: MediasfuSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(MediasfuSpacing.sm),
                  topRight: Radius.circular(MediasfuSpacing.sm),
                  bottomLeft: isExpanded
                      ? Radius.zero
                      : Radius.circular(MediasfuSpacing.sm),
                  bottomRight: isExpanded
                      ? Radius.zero
                      : Radius.circular(MediasfuSpacing.sm),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getLevelColor(
                          levelKey == 'level0' ? '0' : '1', isDarkMode),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: MediasfuSpacing.sm),
                  Text(
                    title,
                    style:
                        MediasfuTypography.getBodyMedium(isDarkMode).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isDarkMode
                        ? MediasfuColors.textSecondaryDark
                        : MediasfuColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.all(MediasfuSpacing.md),
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
      padding: EdgeInsets.symmetric(vertical: MediasfuSpacing.sm),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getCapabilityIcon(capability),
            color: isDarkMode
                ? MediasfuColors.textSecondaryDark
                : MediasfuColors.textSecondary,
            size: 18,
          ),
          SizedBox(width: MediasfuSpacing.sm),
          Expanded(
            child: Text(
              _getCapabilityLabel(capability),
              style: MediasfuTypography.getBodyMedium(isDarkMode),
            ),
          ),
          if (_isHost)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediasfuSpacing.sm,
                vertical: MediasfuSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(MediasfuSpacing.xs),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.15),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isDense: true,
                  dropdownColor:
                      isDarkMode ? const Color(0xFF1e293b) : Colors.white,
                  style: TextStyle(
                    color: isDarkMode
                        ? MediasfuColors.textPrimaryDark
                        : MediasfuColors.textPrimary,
                    fontSize: 12,
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: isDarkMode
                        ? MediasfuColors.textSecondaryDark
                        : MediasfuColors.textSecondary,
                    size: 18,
                  ),
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
                SizedBox(width: MediasfuSpacing.xs),
                Text(
                  value[0].toUpperCase() + value.substring(1),
                  style: TextStyle(
                    color: isDarkMode
                        ? MediasfuColors.textSecondaryDark
                        : MediasfuColors.textSecondary,
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
