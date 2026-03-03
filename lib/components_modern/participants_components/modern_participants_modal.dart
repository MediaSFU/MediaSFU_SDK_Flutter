import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/participants_components/participants_modal.dart'
    show ParticipantsModalOptions;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../../components/participants_components/participant_list.dart'
    show ParticipantListOptions;
import '../../components/participants_components/participant_list_others.dart'
    show ParticipantListOthersOptions;
import 'modern_participant_list.dart'
    show ModernParticipantList, ModernParticipantListOptions;
import '../../types/types.dart' show Participant, EventType;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

typedef ModernParticipantsModalType = Widget Function(
    {required ParticipantsModalOptions options});

/// Modern participants modal with glassmorphic design.
/// Uses the same [ParticipantsModalOptions] as the original component.
class ModernParticipantsModal extends StatefulWidget {
  final ParticipantsModalOptions options;

  const ModernParticipantsModal({super.key, required this.options});

  @override
  State<ModernParticipantsModal> createState() =>
      _ModernParticipantsModalState();
}

class _ModernParticipantsModalState extends State<ModernParticipantsModal>
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
      widget.options.onParticipantsClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = mediaSize.width >= 1200;
    final shouldUseSidebar = isLandscape && isWide;

    final defaultModalWidth = math.min(mediaSize.width * 0.85, 450.0);
    final modalWidth = defaultModalWidth;
    final modalHeight = mediaSize.height * 0.75;

    final positionData = getModalPosition(
      GetModalPositionOptions(
        position: widget.options.position,
        modalWidth: modalWidth,
        modalHeight: modalHeight,
        context: context,
      ),
    );

    final params = widget.options.parameters.getUpdatedAllParams();

    // Check if this is a webinar or chat event - these benefit from high transparency
    // so users can still see the video feed behind the modal
    final isLiveEvent = params.eventType == EventType.webinar ||
        params.eventType == EventType.chat;

    // For live events on smaller screens (not shouldUseSidebar), use very high transparency
    final useHighTransparency = !shouldUseSidebar;

    // Use filtered list if it has items, otherwise show all participants
    final participantsList = params.filteredParticipants.isNotEmpty
        ? params.filteredParticipants
        : params.participants;
    final participantsCounter = participantsList.length;
    final islevel = params.islevel;
    final coHost = params.coHost;
    final member = params.member;
    final participantsValue = params.coHostResponsibility
        .any((item) => item.name == 'participants' && item.value);
    final canModerate = participantsList.isNotEmpty &&
        (islevel == '2' || (coHost == member && participantsValue));

    // For sidebar or inline mode, render content directly without modal wrapper
    if (widget.options.renderMode == ModalRenderMode.sidebar ||
        widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent(participantsCounter, participantsList,
          canModerate, params, coHost, member);
    }

    return Visibility(
      visible: widget.options.isParticipantsModalVisible,
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
                          // For live events (webinar/chat) on smaller screens, use ~95% transparency
                          // so users can still see the video feed behind the modal
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
                                    useHighTransparency ? 0.08 : 0.15)
                                : Colors.black.withOpacity(
                                    useHighTransparency ? 0.05 : 0.1),
                          ),
                          boxShadow: useHighTransparency
                              ? [] // No shadow for high transparency mode
                              : [
                                  BoxShadow(
                                    color:
                                        MediasfuColors.primary.withOpacity(0.3),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                  BoxShadow(
                                    color: MediasfuColors.secondary
                                        .withOpacity(0.15),
                                    blurRadius: 60,
                                    spreadRadius: 10,
                                    offset: const Offset(10, 20),
                                  ),
                                ],
                        ),
                        child: Column(
                          children: [
                            _buildHeader(participantsCounter),
                            _buildSearchBar(),
                            Expanded(
                              child: _buildParticipantsList(
                                participantsList,
                                canModerate,
                                params,
                                coHost,
                                member,
                              ),
                            ),
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
      int participantsCounter,
      List<Participant> participantsList,
      bool canModerate,
      dynamic params,
      String coHost,
      String member) {
    return Column(
      children: [
        _buildHeader(participantsCounter),
        _buildSearchBar(),
        Expanded(
          child: _buildParticipantsList(
            participantsList,
            canModerate,
            params,
            coHost,
            member,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.options.isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon with glow
          Container(
            padding: const EdgeInsets.all(MediasfuSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MediasfuColors.primary,
                  MediasfuColors.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: MediasfuColors.primary.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.people_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: MediasfuSpacing.sm),

          // Title
          Text(
            'Participants',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.options.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),

          const Spacer(),

          // Counter badge - subtle, positioned to the right
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: widget.options.isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: widget.options.isDarkMode
                      ? Colors.white60
                      : Colors.black54,
                ),
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: TextStyle(
                    color: widget.options.isDarkMode
                        ? Colors.white70
                        : Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: MediasfuSpacing.sm),

          // Close button
          Tooltip(
            message: 'Close participants panel',
            decoration: MediasfuColors.tooltipDecoration(
                darkMode: widget.options.isDarkMode),
            textStyle: TextStyle(
              color: MediasfuColors.tooltipText(
                  darkMode: widget.options.isDarkMode),
              fontSize: 12,
            ),
            child: GestureDetector(
              onTap: _handleClose,
              child: Container(
                padding: const EdgeInsets.all(MediasfuSpacing.sm),
                decoration: BoxDecoration(
                  color: widget.options.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: widget.options.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
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
          onChanged: widget.options.onParticipantsFilterChange,
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

  Widget _buildParticipantsList(
    List<Participant> participantsList,
    bool canModerate,
    dynamic params,
    String coHost,
    String member,
  ) {
    if (participantsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 48,
              color:
                  widget.options.isDarkMode ? Colors.white30 : Colors.black26,
            ),
            const SizedBox(height: MediasfuSpacing.md),
            Text(
              'No participants',
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

    // Use modern participant list by default
    Widget participantListWidget;
    if (canModerate) {
      // Check for custom renderer using the RenderParticipantList property
      final renderList = widget.options.RenderParticipantList;
      if (renderList != ParticipantsModalOptions.defaultParticipantList) {
        participantListWidget = renderList(
          options: ParticipantListOptions(
            participants: participantsList,
            isBroadcast: params.eventType == EventType.broadcast,
            onMuteParticipants: widget.options.onMuteParticipants,
            onMessageParticipants: widget.options.onMessageParticipants,
            onRemoveParticipants: widget.options.onRemoveParticipants,
            socket: params.socket,
            coHostResponsibility: params.coHostResponsibility,
            member: params.member,
            islevel: params.islevel,
            showAlert: params.showAlert,
            coHost: params.coHost,
            roomName: params.roomName,
            updateIsMessagesModalVisible: params.updateIsMessagesModalVisible,
            updateDirectMessageDetails: params.updateDirectMessageDetails,
            updateStartDirectMessage: params.updateStartDirectMessage,
            updateParticipants: params.updateParticipants,
          ),
        );
      } else {
        // Use modern participant list
        participantListWidget = ModernParticipantList(
          options: ModernParticipantListOptions(
            participants: participantsList,
            isBroadcast: params.eventType == EventType.broadcast,
            onMuteParticipants: widget.options.onMuteParticipants,
            onMessageParticipants: widget.options.onMessageParticipants,
            onRemoveParticipants: widget.options.onRemoveParticipants,
            socket: params.socket,
            coHostResponsibility: params.coHostResponsibility,
            member: params.member,
            islevel: params.islevel,
            showAlert: params.showAlert,
            coHost: params.coHost,
            roomName: params.roomName,
            updateIsMessagesModalVisible: params.updateIsMessagesModalVisible,
            updateDirectMessageDetails: params.updateDirectMessageDetails,
            updateStartDirectMessage: params.updateStartDirectMessage,
            updateParticipants: params.updateParticipants,
            enableGlassmorphism: widget.options.enableGlassmorphism,
            isDarkMode: widget.options.isDarkMode,
          ),
        );
      }
    } else {
      // Check for custom renderer using the RenderParticipantListOthers property
      final renderListOthers = widget.options.RenderParticipantListOthers;
      if (renderListOthers !=
          ParticipantsModalOptions.defaultParticipantListOthers) {
        participantListWidget = renderListOthers(
          options: ParticipantListOthersOptions(
            participants: participantsList,
            coHost: coHost,
            member: member,
          ),
        );
      } else {
        // Use modern participant list for non-moderators
        participantListWidget = ModernParticipantList(
          options: ModernParticipantListOptions(
            participants: participantsList,
            isBroadcast: params.eventType == EventType.broadcast,
            onMuteParticipants: widget.options.onMuteParticipants,
            onMessageParticipants: widget.options.onMessageParticipants,
            onRemoveParticipants: widget.options.onRemoveParticipants,
            socket: params.socket,
            coHostResponsibility: params.coHostResponsibility,
            member: params.member,
            islevel: params.islevel,
            showAlert: params.showAlert,
            coHost: params.coHost,
            roomName: params.roomName,
            updateIsMessagesModalVisible: params.updateIsMessagesModalVisible,
            updateDirectMessageDetails: params.updateDirectMessageDetails,
            updateStartDirectMessage: params.updateStartDirectMessage,
            updateParticipants: params.updateParticipants,
            enableGlassmorphism: widget.options.enableGlassmorphism,
            isDarkMode: widget.options.isDarkMode,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MediasfuSpacing.md),
      child: participantListWidget,
    );
  }
}
