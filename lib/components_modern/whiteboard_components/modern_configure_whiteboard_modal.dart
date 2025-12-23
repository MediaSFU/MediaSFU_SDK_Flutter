import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/types.dart' show Participant, WhiteboardUser;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../../components/whiteboard_components/configure_whiteboard_modal.dart'
    show ConfigureWhiteboardModalOptions, ConfigureWhiteboardModalParameters;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

/// Type definition for ModernConfigureWhiteboardModal widget builder.
typedef ModernConfigureWhiteboardModalType = Widget Function(
    {required ConfigureWhiteboardModalOptions options});

/// ModernConfigureWhiteboardModal - A modern glassmorphic modal for configuring whiteboard sessions.
///
/// Uses the same [ConfigureWhiteboardModalOptions] as the original component.
/// Features a sleek design with glassmorphism effects, smooth animations,
/// and an intuitive dual-list interface for managing participant access.
class ModernConfigureWhiteboardModal extends StatefulWidget {
  final ConfigureWhiteboardModalOptions options;

  const ModernConfigureWhiteboardModal({super.key, required this.options});

  @override
  State<ModernConfigureWhiteboardModal> createState() =>
      _ModernConfigureWhiteboardModalState();
}

class _ModernConfigureWhiteboardModalState
    extends State<ModernConfigureWhiteboardModal>
    with SingleTickerProviderStateMixin {
  List<Participant> _assignedParticipants = [];
  List<Participant> _pendingParticipants = [];
  bool _isEditing = false;
  int _selectedParticipantTab = 0;
  bool _isLoading = false;
  Timer? _loadingTimeoutTimer;
  static const int _emitTimeoutMs = 45000; // 45 seconds timeout

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  ConfigureWhiteboardModalParameters get _params => widget.options.parameters;
  bool get _isDark => widget.options.isDarkMode;
  bool get _useGlass => widget.options.enableGlassmorphism;

  // Theme colors using MediasfuColors for consistency
  Color get _cardBg => _isDark
      ? (_useGlass
          ? MediasfuColors.surfaceDark.withValues(alpha: 0.6)
          : MediasfuColors.surfaceDark)
      : (_useGlass
          ? MediasfuColors.surface.withValues(alpha: 0.85)
          : MediasfuColors.surface);

  Color get _textPrimary =>
      _isDark ? MediasfuColors.textPrimaryDark : MediasfuColors.textPrimary;

  Color get _textSecondary =>
      _isDark ? MediasfuColors.textSecondaryDark : MediasfuColors.textSecondary;

  Color get _borderColor =>
      _isDark ? MediasfuColors.dividerDark : MediasfuColors.divider;

  @override
  void initState() {
    super.initState();
    _initializeParticipants();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _loadingTimeoutTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ModernConfigureWhiteboardModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.isVisible && !oldWidget.options.isVisible) {
      _initializeParticipants();
      _animationController.forward(from: 0);
    }
  }

  void _initializeParticipants() {
    final allParticipants =
        _params.participants.where((p) => p.islevel != '2').toList();
    final assigned = allParticipants.where((p) => p.useBoard == true).toList();
    final pending = allParticipants.where((p) => p.useBoard != true).toList();

    setState(() {
      _assignedParticipants = assigned;
      _pendingParticipants = pending;
    });
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
    if (_assignedParticipants.length > _params.itemPageLimit) {
      _params.showAlert?.call(
        message: 'Participant limit exceeded',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    if (_params.whiteboardStarted && !_params.whiteboardEnded) {
      final whiteboardUsers = _assignedParticipants
          .map((p) => {'name': p.name, 'useBoard': true})
          .toList();

      _params.socket?.emitWithAck(
        'updateWhiteboard',
        {'whiteboardUsers': whiteboardUsers, 'roomName': _params.roomName},
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
          }
        },
      );
    } else {
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
    setState(() => _isEditing = false);
  }

  bool _validateStartWhiteboard() {
    if (_params.shareScreenStarted || _params.shared) {
      _params.showAlert?.call(
        message: 'Cannot start whiteboard while screen sharing is active',
        type: 'danger',
        duration: 3000,
      );
      return false;
    }

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
    if (_isLoading) return;
    if (!_validateStartWhiteboard()) return;

    if (_params.socket == null) {
      _params.showAlert?.call(
        message: 'Socket connection not available',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    setState(() => _isLoading = true);

    // Set timeout to auto-reset loading state after 45s
    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = Timer(Duration(milliseconds: _emitTimeoutMs), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _params.showAlert?.call(
          message: 'Request timed out. Please try again.',
          type: 'danger',
          duration: 3000,
        );
      }
    });

    final whiteboardUsers = _assignedParticipants
        .map((p) => {'name': p.name, 'useBoard': true})
        .toList();

    final emitName = (_params.whiteboardStarted && !_params.whiteboardEnded)
        ? 'updateWhiteboard'
        : 'startWhiteboard';

    _params.socket!.emitWithAck(
      emitName,
      {'whiteboardUsers': whiteboardUsers, 'roomName': _params.roomName},
      ack: (response) {
        // Clear timeout on response
        _loadingTimeoutTimer?.cancel();
        _loadingTimeoutTimer = null;
        if (mounted) setState(() => _isLoading = false);

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
            message: response?['reason'] ?? 'Unable to start whiteboard',
            type: 'danger',
            duration: 3000,
          );
        }
      },
    );
  }

  void _stopWhiteboard() {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    // Set timeout to auto-reset loading state after 45s
    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = Timer(Duration(milliseconds: _emitTimeoutMs), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _params.showAlert?.call(
          message: 'Request timed out. Please try again.',
          type: 'danger',
          duration: 3000,
        );
      }
    });

    _params.socket?.emitWithAck(
      'stopWhiteboard',
      {'roomName': _params.roomName},
      ack: (response) {
        // Clear timeout on response
        _loadingTimeoutTimer?.cancel();
        _loadingTimeoutTimer = null;
        if (mounted) setState(() => _isLoading = false);

        if (response != null && response['success'] == true) {
          _params.updateWhiteboardStarted(false);
          _params.updateWhiteboardEnded(true);
          _params.updateCanStartWhiteboard(true);
          _params.showAlert?.call(
            message: 'Whiteboard stopped',
            type: 'success',
            duration: 3000,
          );
          widget.options.onClose();
        } else {
          _params.showAlert?.call(
            message: response?['reason'] ?? 'Unable to stop whiteboard',
            type: 'danger',
            duration: 3000,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // For sidebar mode, return content directly
    if (widget.options.renderMode == ModalRenderMode.sidebar) {
      return _buildSidebarContent();
    }

    if (widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent();
    }

    if (!widget.options.isVisible) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;
    final modalWidth = screenSize.width > 600 ? 560.0 : screenSize.width * 0.94;
    final modalHeight = screenSize.height * 0.78;

    final screenWidth = screenSize.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = screenWidth >= 1200;
    final shouldUseSidebar = isLandscape && isWide;
    final useHighTransparency = !shouldUseSidebar;

    final positionResult = getModalPosition(GetModalPositionOptions(
      position: widget.options.position,
      modalWidth: modalWidth,
      modalHeight: modalHeight,
      context: context,
    ));

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Backdrop - semi-transparent to see content underneath
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.options.onClose,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: Colors.black
                      .withValues(alpha: 0.1 * _fadeAnimation.value),
                ),
              ),
            ),

            // Modal
            Positioned(
              top: positionResult['top'],
              right: positionResult['right'],
              left: positionResult['left'],
              bottom: positionResult['bottom'],
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildModalContent(
                      modalWidth, modalHeight, useHighTransparency),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidebarContent() {
    return Container(
      color: _isDark
          ? MediasfuColors.backgroundDark
          : MediasfuColors.surfaceElevated,
      child: Column(
        children: [
          _buildHeader(showClose: true),
          if (_params.whiteboardStarted && !_params.whiteboardEnded)
            _buildStatusIndicator(),
          Expanded(child: _buildBody()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildModalContent(
      double width, double height, bool useHighTransparency) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: _useGlass
              ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: useHighTransparency
                  ? (_isDark
                      ? MediasfuColors.backgroundDark.withValues(alpha: 0.05)
                      : MediasfuColors.surface.withValues(alpha: 0.08))
                  : (_isDark
                      ? (_useGlass
                          ? MediasfuColors.backgroundDark
                              .withValues(alpha: 0.85)
                          : MediasfuColors.backgroundDark)
                      : (_useGlass
                          ? MediasfuColors.surface.withValues(alpha: 0.9)
                          : MediasfuColors.surface)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _borderColor),
              boxShadow: useHighTransparency
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      ),
                    ],
            ),
            child: Column(
              children: [
                _buildHeader(showClose: true),
                if (_params.whiteboardStarted && !_params.whiteboardEnded)
                  _buildStatusIndicator(),
                Expanded(child: _buildBody()),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({bool showClose = true}) {
    final isActive = _params.whiteboardStarted && !_params.whiteboardEnded;

    // Dark mode header uses surface color, light mode uses gradient
    final headerDecoration = _isDark
        ? BoxDecoration(
            color: MediasfuColors.surfaceDark,
            borderRadius: widget.options.renderMode == ModalRenderMode.modal
                ? const BorderRadius.vertical(top: Radius.circular(20))
                : null,
            border: Border(
              bottom: BorderSide(
                color: isActive
                    ? MediasfuColors.success.withValues(alpha: 0.3)
                    : MediasfuColors.glassBorder(darkMode: true),
              ),
            ),
          )
        : BoxDecoration(
            gradient: LinearGradient(
              colors: isActive
                  ? [MediasfuColors.success, MediasfuColors.successDark]
                  : [MediasfuColors.primary, MediasfuColors.primaryVariant],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: widget.options.renderMode == ModalRenderMode.modal
                ? const BorderRadius.vertical(top: Radius.circular(20))
                : null,
          );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
      decoration: headerDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isDark
                  ? (isActive
                      ? MediasfuColors.success.withValues(alpha: 0.2)
                      : MediasfuColors.primary.withValues(alpha: 0.2))
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(
              FontAwesomeIcons.chalkboard,
              color: _isDark
                  ? (isActive ? MediasfuColors.success : MediasfuColors.primary)
                  : Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configure Whiteboard',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isActive ? 'Session is live' : 'Manage drawing permissions',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isDark
                        ? Colors.grey[400]
                        : Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (showClose)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.close,
                  color: _isDark ? Colors.grey[300] : Colors.white,
                  size: 18,
                ),
              ),
              onPressed: widget.options.onClose,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: MediasfuColors.success.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: MediasfuColors.success.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: MediasfuColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: MediasfuColors.success.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Whiteboard is active',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _isDark
                  ? MediasfuColors.successLight
                  : MediasfuColors.successDark,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: MediasfuColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_assignedParticipants.length} drawing',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: MediasfuColors.successDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use column layout with tabs for narrow screens (< 450px)
        final isNarrow = constraints.maxWidth < 450;

        return Container(
          padding: EdgeInsets.all(
              isNarrow ? MediasfuSpacing.sm : MediasfuSpacing.md),
          child: Column(
            children: [
              // Info card
              _buildInfoCard(),
              SizedBox(
                  height: isNarrow ? MediasfuSpacing.sm : MediasfuSpacing.md),

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

  Widget _buildWideParticipantLists() {
    return Row(
      children: [
        Expanded(
          child: _buildParticipantCard(
            title: 'Can Draw',
            subtitle: 'Assigned participants',
            icon: FontAwesomeIcons.penNib,
            accentColor: MediasfuColors.success,
            participants: _assignedParticipants,
            onAction: _removeParticipant,
            actionIcon: FontAwesomeIcons.xmark,
            isRemove: true,
            emptyMessage: 'No one assigned yet',
            emptySubtitle: 'Add participants from Available',
          ),
        ),
        const SizedBox(width: MediasfuSpacing.sm),
        Expanded(
          child: _buildParticipantCard(
            title: 'View Only',
            subtitle: 'Available participants',
            icon: FontAwesomeIcons.eye,
            accentColor: MediasfuColors.primary,
            participants: _pendingParticipants,
            onAction: _addParticipant,
            actionIcon: FontAwesomeIcons.plus,
            isRemove: false,
            emptyMessage: 'All assigned',
            emptySubtitle: 'Everyone can draw',
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowParticipantLists() {
    return Column(
      children: [
        // Tab selector
        Container(
          decoration: BoxDecoration(
            color: _isDark
                ? MediasfuColors.surfaceDark.withValues(alpha: 0.5)
                : MediasfuColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedParticipantTab = 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedParticipantTab == 0
                          ? MediasfuColors.success
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.penNib,
                          size: 12,
                          color: _selectedParticipantTab == 0
                              ? Colors.white
                              : _textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Can Draw (${_assignedParticipants.length})',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _selectedParticipantTab == 0
                                ? Colors.white
                                : _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedParticipantTab = 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedParticipantTab == 1
                          ? MediasfuColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.eye,
                          size: 12,
                          color: _selectedParticipantTab == 1
                              ? Colors.white
                              : _textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'View Only (${_pendingParticipants.length})',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _selectedParticipantTab == 1
                                ? Colors.white
                                : _textSecondary,
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
        const SizedBox(height: MediasfuSpacing.sm),

        // Participant card based on selected tab
        Expanded(
          child: _selectedParticipantTab == 0
              ? _buildParticipantCard(
                  title: 'Can Draw',
                  subtitle: 'Assigned participants',
                  icon: FontAwesomeIcons.penNib,
                  accentColor: MediasfuColors.success,
                  participants: _assignedParticipants,
                  onAction: _removeParticipant,
                  actionIcon: FontAwesomeIcons.xmark,
                  isRemove: true,
                  emptyMessage: 'No one assigned yet',
                  emptySubtitle: 'Add participants from Available',
                )
              : _buildParticipantCard(
                  title: 'View Only',
                  subtitle: 'Available participants',
                  icon: FontAwesomeIcons.eye,
                  accentColor: MediasfuColors.primary,
                  participants: _pendingParticipants,
                  onAction: _addParticipant,
                  actionIcon: FontAwesomeIcons.plus,
                  isRemove: false,
                  emptyMessage: 'All assigned',
                  emptySubtitle: 'Everyone can draw',
                ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [
                  MediasfuColors.secondary.withValues(alpha: 0.15),
                  MediasfuColors.primary.withValues(alpha: 0.1),
                ]
              : [MediasfuColors.infoBackground, MediasfuColors.infoBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDark
              ? MediasfuColors.secondary.withValues(alpha: 0.3)
              : MediasfuColors.infoLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(MediasfuSpacing.sm),
            decoration: BoxDecoration(
              color: MediasfuColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              size: 18,
              color: _isDark
                  ? MediasfuColors.secondaryLightDark
                  : MediasfuColors.secondaryDark,
            ),
          ),
          const SizedBox(width: MediasfuSpacing.sm),
          Expanded(
            child: Text(
              'Assign up to ${_params.itemPageLimit} participants to draw on the whiteboard.',
              style: TextStyle(
                fontSize: 13,
                color: _isDark ? _textSecondary : MediasfuColors.infoDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required List<Participant> participants,
    required Function(Participant) onAction,
    required IconData actionIcon,
    required bool isRemove,
    required String emptyMessage,
    required String emptySubtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
        boxShadow: _useGlass
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FaIcon(icon, size: 12, color: accentColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${participants.length}',
                    style: TextStyle(
                      color: accentColor,
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
                ? _buildEmptyState(emptyMessage, emptySubtitle, accentColor)
                : ListView.separated(
                    itemCount: participants.length,
                    padding: const EdgeInsets.all(10),
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      return _buildParticipantTile(
                        participant: participants[index],
                        onAction: onAction,
                        actionIcon: actionIcon,
                        isRemove: isRemove,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, String subtitle, Color color) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.userSlash,
              size: 22,
              color: color.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: _textSecondary.withValues(alpha: 0.7),
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
    required bool isRemove,
  }) {
    final initials = participant.name.isNotEmpty
        ? participant.name.substring(0, 1).toUpperCase()
        : '?';

    final actionColor =
        isRemove ? MediasfuColors.danger : MediasfuColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _isDark
            ? MediasfuColors.surfaceDark.withValues(alpha: 0.5)
            : MediasfuColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MediasfuColors.primary,
                  MediasfuColors.accent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              participant.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => onAction(participant),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: actionColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        color: _isDark
            ? MediasfuColors.backgroundDark.withValues(alpha: 0.8)
            : MediasfuColors.surfaceElevated,
        borderRadius: widget.options.renderMode == ModalRenderMode.modal
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : null,
        border: Border(
          top: BorderSide(color: _borderColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning
          if (limitExceeded)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: MediasfuColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: MediasfuColors.danger.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 18, color: MediasfuColors.danger),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Limit exceeded (max ${_params.itemPageLimit})',
                      style: TextStyle(
                        fontSize: 13,
                        color: MediasfuColors.danger,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              if (_isEditing && !isActive)
                Expanded(
                  child: _buildModernButton(
                    icon: FontAwesomeIcons.floppyDisk,
                    label: 'Save',
                    color: MediasfuColors.secondary,
                    onPressed:
                        (limitExceeded || _isLoading) ? null : _saveAssignments,
                  ),
                ),
              if (_isEditing && !isActive) const SizedBox(width: 10),
              if (canStart)
                Expanded(
                  child: _buildModernButton(
                    icon: FontAwesomeIcons.play,
                    label: _isLoading ? 'Starting...' : 'Start',
                    color: MediasfuColors.success,
                    onPressed:
                        (limitExceeded || _isLoading) ? null : _startWhiteboard,
                    isLoading: _isLoading,
                  ),
                ),
              if (isActive) ...[
                Expanded(
                  child: _buildModernButton(
                    icon: FontAwesomeIcons.arrowsRotate,
                    label: 'Update',
                    color: MediasfuColors.warning,
                    onPressed:
                        (limitExceeded || _isLoading) ? null : _saveAssignments,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildModernButton(
                    icon: FontAwesomeIcons.stop,
                    label: _isLoading ? 'Stopping...' : 'Stop',
                    color: MediasfuColors.danger,
                    onPressed: _isLoading ? null : _stopWhiteboard,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    final isDisabled = onPressed == null || isLoading;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: isDisabled
              ? null
              : LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
          color: isDisabled
              ? (_isDark ? Colors.grey[800] : Colors.grey[300])
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              )
            else
              FaIcon(
                icon,
                size: 14,
                color: isDisabled
                    ? (_isDark ? Colors.grey[600] : Colors.grey[500])
                    : Colors.white,
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDisabled
                    ? (_isDark ? Colors.grey[600] : Colors.grey[500])
                    : Colors.white,
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
