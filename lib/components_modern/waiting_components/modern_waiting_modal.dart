import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/waiting_components/waiting_modal.dart'
    show WaitingRoomModalOptions;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../methods/waiting_methods/respond_to_waiting.dart'
    show RespondToWaitingOptions;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../../types/types.dart' show WaitingRoomParticipant;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/widgets/modal_header.dart';

typedef ModernWaitingRoomModalType = Widget Function(
    {required WaitingRoomModalOptions options});

/// Modern waiting room modal with glassmorphic design.
/// Uses the same [WaitingRoomModalOptions] as the original component.
class ModernWaitingRoomModal extends StatefulWidget {
  final WaitingRoomModalOptions options;

  const ModernWaitingRoomModal({super.key, required this.options});

  @override
  State<ModernWaitingRoomModal> createState() => _ModernWaitingRoomModalState();
}

class _ModernWaitingRoomModalState extends State<ModernWaitingRoomModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      widget.options.onWaitingRoomClose();
    });
  }

  Future<void> _handleResponse(
      WaitingRoomParticipant participant, bool accepted) async {
    final params = widget.options.parameters.getUpdatedAllParams();
    await widget.options.onWaitingRoomItemPress(
      options: RespondToWaitingOptions(
        participantId: participant.id,
        participantName: participant.name,
        updateWaitingList: params.updateWaitingRoomList,
        waitingList: params.waitingRoomList,
        roomName: params.roomName,
        socket: params.socket,
        type: accepted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    final defaultWidth = math.min(mediaSize.width * 0.85, 450.0);
    final modalWidth = defaultWidth;
    final modalHeight = mediaSize.height * 0.7;

    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = screenWidth >= 1200;
    final shouldUseSidebar = isLandscape && isWide;
    final useHighTransparency = !shouldUseSidebar;

    final positionData = getModalPosition(
      GetModalPositionOptions(
        position: widget.options.position,
        modalWidth: modalWidth,
        modalHeight: modalHeight,
        context: context,
      ),
    );

    final params = widget.options.parameters.getUpdatedAllParams();
    final baseList = params.filteredWaitingRoomList.isNotEmpty
        ? params.filteredWaitingRoomList
        : (params.waitingRoomList.isNotEmpty
            ? params.waitingRoomList
            : widget.options.waitingRoomList);
    final waitingList = List<WaitingRoomParticipant>.from(baseList);
    final fallbackCounter =
        params.waitingRoomCounter > widget.options.waitingRoomCounter
            ? params.waitingRoomCounter
            : widget.options.waitingRoomCounter;
    final waitingCounter =
        waitingList.isNotEmpty ? waitingList.length : fallbackCounter;

    // For sidebar or inline mode, render content directly without modal wrapper
    if (widget.options.renderMode == ModalRenderMode.sidebar ||
        widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent(waitingCounter, waitingList);
    }

    return Visibility(
      visible: widget.options.isWaitingModalVisible,
      child: Material(
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
                    color: Colors.black.withOpacity(0.05),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: widget.options.enableGlassmorphism
                          ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                          : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: Container(
                        width: modalWidth,
                        height: modalHeight,
                        decoration: BoxDecoration(
                          color: useHighTransparency
                              ? (widget.options.isDarkMode
                                  ? Colors.black.withOpacity(0.05)
                                  : Colors.white.withOpacity(0.08))
                              : (widget.options.isDarkMode
                                  ? Colors.black.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.9)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.options.isDarkMode
                                ? Colors.white.withOpacity(
                                    useHighTransparency ? 0.08 : 0.1)
                                : Colors.black.withOpacity(
                                    useHighTransparency ? 0.05 : 0.1),
                          ),
                          boxShadow: useHighTransparency
                              ? []
                              : [
                                  BoxShadow(
                                    color: MediasfuColors.info.withOpacity(0.2),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                ],
                        ),
                        child: Column(
                          children: [
                            _buildHeader(waitingCounter),
                            _buildSearchBar(),
                            Expanded(child: _buildWaitingList(waitingList)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds sidebar-optimized content for embedding in sidebar panel.
  Widget _buildSidebarContent(
      int waitingCounter, List<WaitingRoomParticipant> waitingList) {
    return Column(
      children: [
        _buildHeader(waitingCounter),
        _buildSearchBar(),
        Expanded(child: _buildWaitingList(waitingList)),
      ],
    );
  }

  Widget _buildHeader(int count) {
    return ModalHeader(
      icon: Icons.hourglass_empty_rounded,
      title: 'Waiting Room',
      onClose: _handleClose,
      isDarkMode: widget.options.isDarkMode,
      gradientColors: [
        MediasfuColors.info,
        MediasfuColors.info.withOpacity(0.7),
      ],
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MediasfuSpacing.sm,
          vertical: MediasfuSpacing.xs,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MediasfuColors.info.withOpacity(0.2),
              MediasfuColors.info.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MediasfuColors.info.withOpacity(0.3),
          ),
        ),
        child: Text(
          count.toString(),
          style: TextStyle(
            color: MediasfuColors.info,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: widget.options.isDarkMode
              ? Colors.white.withOpacity(0.12)
              : const Color(0xFFEEF2F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.options.isDarkMode
                ? Colors.white.withOpacity(0.18)
                : Colors.black.withOpacity(0.12),
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: widget.options.onWaitingRoomFilterChange,
          cursorColor:
              widget.options.isDarkMode ? Colors.white : Colors.black87,
          style: TextStyle(
            color: widget.options.isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'Search participants...',
            hintStyle: TextStyle(
              color:
                  widget.options.isDarkMode ? Colors.white70 : Colors.black45,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color:
                  widget.options.isDarkMode ? Colors.white70 : Colors.black45,
            ),
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: MediasfuSpacing.md,
              vertical: MediasfuSpacing.sm,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingList(List<WaitingRoomParticipant> waitingList) {
    if (waitingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color:
                  widget.options.isDarkMode ? Colors.white30 : Colors.black26,
            ),
            const SizedBox(height: MediasfuSpacing.md),
            Text(
              'No one in waiting room',
              style: TextStyle(
                fontSize: 16,
                color:
                    widget.options.isDarkMode ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: MediasfuSpacing.md),
      itemCount: waitingList.length,
      itemBuilder: (context, index) {
        final participant = waitingList[index];
        return _buildParticipantItem(participant);
      },
    );
  }

  Widget _buildParticipantItem(WaitingRoomParticipant participant) {
    return Container(
      margin: const EdgeInsets.only(bottom: MediasfuSpacing.sm),
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        color: widget.options.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.options.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MediasfuColors.primary,
                  MediasfuColors.secondary,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                participant.name.isNotEmpty
                    ? participant.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: MediasfuSpacing.md),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: widget.options.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Waiting to join',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.options.isDarkMode
                        ? Colors.white54
                        : Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: Icons.check_rounded,
                label: 'Admit',
                color: MediasfuColors.success,
                onTap: () => _handleResponse(participant, true),
              ),
              const SizedBox(width: MediasfuSpacing.sm),
              _buildActionButton(
                icon: Icons.close_rounded,
                label: 'Deny',
                color: MediasfuColors.danger,
                onTap: () => _handleResponse(participant, false),
              ),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MediasfuSpacing.sm,
          vertical: MediasfuSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
