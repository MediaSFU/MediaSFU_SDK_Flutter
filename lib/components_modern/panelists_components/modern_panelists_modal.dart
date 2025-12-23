import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show Participant, ShowAlert;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../../methods/panelists_methods/update_panelists.dart';
import '../../methods/panelists_methods/focus_panelists.dart';
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

/// Options for the ModernPanelistsModal widget
class ModernPanelistsModalOptions {
  final bool isPanelistsModalVisible;
  final VoidCallback onPanelistsClose;
  final List<Participant> participants;
  final List<Participant> panelists;
  final String member;
  final String islevel;
  final io.Socket? socket;
  final String roomName;
  final ShowAlert? showAlert;
  final int itemPageLimit;
  final bool panelistsFocused;
  final bool muteOthersMic;
  final bool muteOthersCamera;
  final void Function(List<Participant>)? updatePanelists;
  final void Function(bool)? updatePanelistsFocused;
  final void Function(bool)? updateMuteOthersMic;
  final void Function(bool)? updateMuteOthersCamera;
  final Color? backgroundColor;
  final String position;
  final bool isDarkMode;
  final bool enableGlassmorphism;
  final bool enableGlow;
  final ModalRenderMode renderMode;

  ModernPanelistsModalOptions({
    required this.isPanelistsModalVisible,
    required this.onPanelistsClose,
    required this.participants,
    required this.panelists,
    required this.member,
    required this.islevel,
    this.socket,
    required this.roomName,
    this.showAlert,
    required this.itemPageLimit,
    this.panelistsFocused = false,
    this.muteOthersMic = false,
    this.muteOthersCamera = false,
    this.updatePanelists,
    this.updatePanelistsFocused,
    this.updateMuteOthersMic,
    this.updateMuteOthersCamera,
    this.backgroundColor,
    this.position = 'topRight',
    this.isDarkMode = true,
    this.enableGlassmorphism = true,
    this.enableGlow = true,
    this.renderMode = ModalRenderMode.modal,
  });
}

typedef ModernPanelistsModalType = Widget Function(
    {required ModernPanelistsModalOptions options});

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
      return "Participant";
  }
}

// ============================================================================
// MAIN WIDGET
// ============================================================================

/// ModernPanelistsModal - Premium styled modal for managing panelists.
///
/// Features:
/// - Select participants as panelists (up to itemPageLimit)
/// - Focus mode to display only panelists on the grid
/// - Option to mute non-panelists' mic and camera when focusing
/// - Search and filter available participants
class ModernPanelistsModal extends StatefulWidget {
  final ModernPanelistsModalOptions options;

  const ModernPanelistsModal({super.key, required this.options});

  @override
  State<ModernPanelistsModal> createState() => _ModernPanelistsModalState();
}

class _ModernPanelistsModalState extends State<ModernPanelistsModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  String _searchQuery = '';
  bool _muteOthersMicLocal = false;
  bool _muteOthersCameraLocal = false;
  bool _focusEnabledLocal = false;

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

    _syncLocalState();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant ModernPanelistsModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncLocalState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _syncLocalState() {
    _muteOthersMicLocal = widget.options.muteOthersMic;
    _muteOthersCameraLocal = widget.options.muteOthersCamera;
    _focusEnabledLocal = widget.options.panelistsFocused;
  }

  void _handleClose() {
    if (isSidebarMode) {
      widget.options.onPanelistsClose();
    } else {
      _animationController.reverse().then((_) {
        widget.options.onPanelistsClose();
      });
    }
  }

  bool get _isHost => widget.options.islevel == "2";

  List<Participant> get _availableParticipants {
    return widget.options.participants.where((p) {
      // Exclude host (isLevel 2)
      if (p.islevel == "2") return false;
      // Exclude current panelists
      if (widget.options.panelists.any((pan) => pan.id == p.id)) return false;
      // Filter by search
      if (_searchQuery.isNotEmpty) {
        return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();
  }

  Future<void> _handleAddPanelist(Participant participant) async {
    if (widget.options.socket == null) return;

    final success = await addPanelist(AddPanelistOptions(
      socket: widget.options.socket!,
      participant: participant,
      currentPanelists: widget.options.panelists,
      maxPanelists: widget.options.itemPageLimit,
      roomName: widget.options.roomName,
      member: widget.options.member,
      islevel: widget.options.islevel,
      showAlert: widget.options.showAlert,
    ));

    if (success) {
      final updatedPanelists = [...widget.options.panelists, participant];
      widget.options.updatePanelists?.call(updatedPanelists);
      setState(() {});
    }
  }

  Future<void> _handleRemovePanelist(Participant participant) async {
    if (widget.options.socket == null) return;

    await removePanelist(RemovePanelistOptions(
      socket: widget.options.socket!,
      participant: participant,
      roomName: widget.options.roomName,
      member: widget.options.member,
      islevel: widget.options.islevel,
      showAlert: widget.options.showAlert,
    ));

    final updatedPanelists =
        widget.options.panelists.where((p) => p.id != participant.id).toList();
    widget.options.updatePanelists?.call(updatedPanelists);
    setState(() {});
  }

  Future<void> _handleToggleFocus() async {
    if (widget.options.socket == null) return;

    final newFocusState = !_focusEnabledLocal;

    if (newFocusState) {
      await focusPanelists(FocusPanelistsOptions(
        socket: widget.options.socket!,
        roomName: widget.options.roomName,
        member: widget.options.member,
        islevel: widget.options.islevel,
        focusEnabled: true,
        muteOthersMic: _muteOthersMicLocal,
        muteOthersCamera: _muteOthersCameraLocal,
        showAlert: widget.options.showAlert,
      ));
    } else {
      await unfocusPanelists(UnfocusPanelistsOptions(
        socket: widget.options.socket!,
        roomName: widget.options.roomName,
        member: widget.options.member,
        islevel: widget.options.islevel,
        showAlert: widget.options.showAlert,
      ));
    }

    setState(() {
      _focusEnabledLocal = newFocusState;
    });

    widget.options.updatePanelistsFocused?.call(newFocusState);
    widget.options.updateMuteOthersMic
        ?.call(newFocusState ? _muteOthersMicLocal : false);
    widget.options.updateMuteOthersCamera
        ?.call(newFocusState ? _muteOthersCameraLocal : false);
  }

  Future<void> _handleUpdateFocusOptions() async {
    if (widget.options.socket == null || !_focusEnabledLocal) return;

    await focusPanelists(FocusPanelistsOptions(
      socket: widget.options.socket!,
      roomName: widget.options.roomName,
      member: widget.options.member,
      islevel: widget.options.islevel,
      focusEnabled: true,
      muteOthersMic: _muteOthersMicLocal,
      muteOthersCamera: _muteOthersCameraLocal,
      showAlert: widget.options.showAlert,
    ));

    widget.options.updateMuteOthersMic?.call(_muteOthersMicLocal);
    widget.options.updateMuteOthersCamera?.call(_muteOthersCameraLocal);
  }

  Future<void> _handleClearAll() async {
    if (widget.options.socket == null) return;

    if (_focusEnabledLocal) {
      await unfocusPanelists(UnfocusPanelistsOptions(
        socket: widget.options.socket!,
        roomName: widget.options.roomName,
        member: widget.options.member,
        islevel: widget.options.islevel,
        showAlert: widget.options.showAlert,
      ));
      setState(() {
        _focusEnabledLocal = false;
      });
      widget.options.updatePanelistsFocused?.call(false);
    }

    await updatePanelists(UpdatePanelistsOptions(
      socket: widget.options.socket!,
      panelists: [],
      roomName: widget.options.roomName,
      member: widget.options.member,
      islevel: widget.options.islevel,
      showAlert: widget.options.showAlert,
    ));

    widget.options.updatePanelists?.call([]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.options.isPanelistsModalVisible) {
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
                  color: Colors.black.withValues(alpha: 0.4),
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
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(MediasfuSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentPanelistsSection(),
                SizedBox(height: MediasfuSpacing.md),
                if (_isHost) _buildFocusOptionsSection(),
                SizedBox(height: MediasfuSpacing.md),
                if (_isHost) _buildAvailableParticipantsSection(),
              ],
            ),
          ),
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
    final panelists = widget.options.panelists;
    final limit = widget.options.itemPageLimit;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.md,
        vertical: MediasfuSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: MediasfuColors.accentGradient(darkMode: isDarkMode),
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
            Icons.star,
            color: Colors.white,
            size: 22,
          ),
          SizedBox(width: MediasfuSpacing.sm),
          Expanded(
            child: Row(
              children: [
                Text(
                  'Panelists',
                  style: MediasfuTypography.getTitleMedium(true).copyWith(
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: MediasfuSpacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediasfuSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient:
                        MediasfuColors.brandGradient(darkMode: isDarkMode),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '${panelists.length}/$limit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _handleClose,
            child: Container(
              padding: EdgeInsets.all(MediasfuSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(MediasfuSpacing.xs),
              ),
              child: Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPanelistsSection() {
    final panelists = widget.options.panelists;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 18,
                    color: isDarkMode
                        ? MediasfuColors.textSecondaryDark
                        : MediasfuColors.textSecondary,
                  ),
                  SizedBox(width: MediasfuSpacing.sm),
                  Text(
                    'Current Panelists',
                    style:
                        MediasfuTypography.getBodyMedium(isDarkMode).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (_isHost && panelists.isNotEmpty)
                GestureDetector(
                  onTap: _handleClearAll,
                  child: Row(
                    children: [
                      Icon(Icons.clear_all,
                          size: 16, color: MediasfuColors.danger),
                      SizedBox(width: 4),
                      Text(
                        'Clear All',
                        style: TextStyle(
                          color: MediasfuColors.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: MediasfuSpacing.sm),
          if (panelists.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(MediasfuSpacing.md),
                child: Text(
                  'No panelists selected',
                  style: TextStyle(
                    color: isDarkMode
                        ? MediasfuColors.textMutedDark
                        : MediasfuColors.textMuted,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: MediasfuSpacing.sm,
              runSpacing: MediasfuSpacing.sm,
              children: panelists
                  .map((panelist) => _buildPanelistChip(panelist))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPanelistChip(Participant panelist) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.sm,
        vertical: MediasfuSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: MediasfuColors.brandGradient(darkMode: isDarkMode),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            child: Text(
              panelist.name.isNotEmpty ? panelist.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: MediasfuSpacing.xs),
          Text(
            panelist.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_isHost) ...[
            SizedBox(width: MediasfuSpacing.xs),
            GestureDetector(
              onTap: () => _handleRemovePanelist(panelist),
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFocusOptionsSection() {
    return _buildCard(
      borderColor: _focusEnabledLocal
          ? MediasfuColors.success.withValues(alpha: 0.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _focusEnabledLocal ? Icons.visibility : Icons.visibility_off,
                size: 18,
                color: _focusEnabledLocal
                    ? MediasfuColors.success
                    : (isDarkMode
                        ? MediasfuColors.textSecondaryDark
                        : MediasfuColors.textSecondary),
              ),
              SizedBox(width: MediasfuSpacing.sm),
              Text(
                'Focus Mode',
                style: MediasfuTypography.getBodyMedium(isDarkMode).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Switch(
                value: _focusEnabledLocal,
                onChanged: widget.options.panelists.isNotEmpty
                    ? (_) => _handleToggleFocus()
                    : null,
                activeThumbColor: MediasfuColors.success,
              ),
            ],
          ),
          if (widget.options.panelists.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: MediasfuSpacing.xs),
              child: Text(
                'Add panelists to enable focus mode',
                style: TextStyle(
                  color: MediasfuColors.warning,
                  fontSize: 12,
                ),
              ),
            ),
          SizedBox(height: MediasfuSpacing.sm),

          // Mute options
          _buildCheckboxOption(
            'Mute Others\' Mic',
            _muteOthersMicLocal,
            (value) {
              setState(() {
                _muteOthersMicLocal = value ?? false;
              });
              if (_focusEnabledLocal) {
                _handleUpdateFocusOptions();
              }
            },
          ),
          _buildCheckboxOption(
            'Mute Others\' Camera',
            _muteOthersCameraLocal,
            (value) {
              setState(() {
                _muteOthersCameraLocal = value ?? false;
              });
              if (_focusEnabledLocal) {
                _handleUpdateFocusOptions();
              }
            },
          ),

          if (_focusEnabledLocal)
            Container(
              margin: EdgeInsets.only(top: MediasfuSpacing.sm),
              padding: EdgeInsets.all(MediasfuSpacing.sm),
              decoration: BoxDecoration(
                color: MediasfuColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(MediasfuSpacing.xs),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: MediasfuColors.success, size: 16),
                  SizedBox(width: MediasfuSpacing.sm),
                  Expanded(
                    child: Text(
                      'Focus mode active - Only panelists visible',
                      style: TextStyle(
                        color: MediasfuColors.success,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: MediasfuColors.primary,
          side: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.4),
          ),
        ),
        Text(
          label,
          style: MediasfuTypography.getBodySmall(isDarkMode),
        ),
      ],
    );
  }

  Widget _buildAvailableParticipantsSection() {
    final availableParticipants = _availableParticipants;
    final canAddMore =
        widget.options.panelists.length < widget.options.itemPageLimit;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                size: 18,
                color: isDarkMode
                    ? MediasfuColors.textSecondaryDark
                    : MediasfuColors.textSecondary,
              ),
              SizedBox(width: MediasfuSpacing.sm),
              Text(
                'Add Panelists',
                style: MediasfuTypography.getBodyMedium(isDarkMode).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: MediasfuSpacing.sm),

          // Search box
          Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(MediasfuSpacing.sm),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.12),
              ),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
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
          SizedBox(height: MediasfuSpacing.sm),

          if (!canAddMore)
            Container(
              padding: EdgeInsets.all(MediasfuSpacing.sm),
              margin: EdgeInsets.only(bottom: MediasfuSpacing.sm),
              decoration: BoxDecoration(
                color: MediasfuColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(MediasfuSpacing.xs),
                border: Border.all(
                  color: MediasfuColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning,
                      color: MediasfuColors.warningDark, size: 16),
                  SizedBox(width: MediasfuSpacing.sm),
                  Text(
                    'Maximum panelists reached',
                    style: TextStyle(
                      color: MediasfuColors.warningDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Participant list
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 220),
            child: availableParticipants.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(MediasfuSpacing.md),
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'No matching participants'
                            : 'No available participants',
                        style: TextStyle(
                          color: isDarkMode
                              ? MediasfuColors.textMutedDark
                              : MediasfuColors.textMuted,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableParticipants.length,
                    itemBuilder: (context, index) {
                      final participant = availableParticipants[index];
                      return _buildAvailableParticipantItem(
                          participant, canAddMore);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableParticipantItem(
      Participant participant, bool canAddMore) {
    return Container(
      margin: EdgeInsets.only(bottom: MediasfuSpacing.xs),
      padding: EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.sm,
        vertical: MediasfuSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(MediasfuSpacing.xs),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            child: Text(
              participant.name.isNotEmpty
                  ? participant.name[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? MediasfuColors.textPrimaryDark
                    : MediasfuColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: MediasfuSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: MediasfuTypography.getBodyMedium(isDarkMode),
                ),
                Text(
                  _getLevelLabel(participant.islevel ?? "0"),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode
                        ? MediasfuColors.textMutedDark
                        : MediasfuColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          PremiumButton(
            size: PremiumButtonSize.sm,
            variant: PremiumButtonVariant.ghost,
            isDarkMode: isDarkMode,
            onPressed:
                canAddMore ? () => _handleAddPanelist(participant) : null,
            leadingIcon: Icons.add,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, Color? borderColor}) {
    return Container(
      padding: EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(MediasfuSpacing.sm),
        border: Border.all(
          color:
              borderColor ?? MediasfuColors.glassBorder(darkMode: isDarkMode),
        ),
      ),
      child: child,
    );
  }
}
