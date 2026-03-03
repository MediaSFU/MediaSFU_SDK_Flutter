import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../components/requests_components/requests_modal.dart'
    show RequestsModalOptions;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../../types/types.dart' show Request, RespondToRequestsOptions;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/widgets/modal_header.dart';
import '../core/widgets/section_card.dart';

typedef ModernRequestsModalType = Widget Function(
    {required RequestsModalOptions options});

/// Modern requests modal with glassmorphic design.
/// Uses the same [RequestsModalOptions] as the original component.
class ModernRequestsModal extends StatefulWidget {
  final RequestsModalOptions options;

  const ModernRequestsModal({super.key, required this.options});

  @override
  State<ModernRequestsModal> createState() => _ModernRequestsModalState();
}

class _ModernRequestsModalState extends State<ModernRequestsModal>
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
      widget.options.onRequestClose();
    });
  }

  IconData _getRequestIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'fa-microphone':
        return FontAwesomeIcons.microphone;
      case 'fa-video':
        return FontAwesomeIcons.video;
      case 'fa-desktop':
        return FontAwesomeIcons.desktop;
      default:
        return FontAwesomeIcons.question;
    }
  }

  Color _getRequestColor(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'fa-microphone':
        return MediasfuColors.success;
      case 'fa-video':
        return MediasfuColors.primary;
      case 'fa-desktop':
        return MediasfuColors.secondary;
      default:
        return Colors.grey;
    }
  }

  String _getRequestType(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'fa-microphone':
        return 'Audio';
      case 'fa-video':
        return 'Video';
      case 'fa-desktop':
        return 'Screen Share';
      default:
        return 'Permission';
    }
  }

  @override
  Widget build(BuildContext context) {
    // For sidebar or inline mode, render content directly without modal wrapper
    if (widget.options.renderMode == ModalRenderMode.sidebar ||
        widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = screenWidth >= 1200;
    final shouldUseSidebar = isLandscape && isWide;
    final useHighTransparency = !shouldUseSidebar;

    final modalWidth = screenWidth * 0.85 > 450 ? 450.0 : screenWidth * 0.85;
    final modalHeight = MediaQuery.of(context).size.height * 0.7;

    return Visibility(
      visible: widget.options.isRequestsModalVisible,
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
                                    color:
                                        MediasfuColors.warning.withOpacity(0.2),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                ],
                        ),
                        child: Column(
                          children: [
                            _buildHeader(),
                            _buildSearchBar(),
                            Expanded(child: _buildRequestsList()),
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
  Widget _buildSidebarContent() {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        Expanded(child: _buildRequestsList()),
      ],
    );
  }

  Widget _buildHeader() {
    return ModalHeader(
      icon: Icons.front_hand_rounded,
      title: 'Requests',
      onClose: _handleClose,
      isDarkMode: widget.options.isDarkMode,
      gradientColors: [
        MediasfuColors.warning,
        MediasfuColors.warning.withOpacity(0.7),
      ],
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MediasfuSpacing.sm,
          vertical: MediasfuSpacing.xs,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MediasfuColors.warning.withOpacity(0.2),
              MediasfuColors.warning.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MediasfuColors.warning.withOpacity(0.3),
          ),
        ),
        child: Text(
          widget.options.requestCounter.toString(),
          style: TextStyle(
            color: MediasfuColors.warning,
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
          onChanged: widget.options.onRequestFilterChange,
          cursorColor:
              widget.options.isDarkMode ? Colors.white : Colors.black87,
          style: TextStyle(
            color: widget.options.isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'Search requests...',
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

  Widget _buildRequestsList() {
    if (widget.options.requestList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 48,
              color:
                  widget.options.isDarkMode ? Colors.white30 : Colors.black26,
            ),
            const SizedBox(height: MediasfuSpacing.md),
            Text(
              'No pending requests',
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
      itemCount: widget.options.requestList.length,
      itemBuilder: (context, index) {
        final request = widget.options.requestList[index];
        return _buildRequestItem(request);
      },
    );
  }

  Widget _buildRequestItem(Request request) {
    final icon = _getRequestIcon(request.icon);
    final color = _getRequestColor(request.icon);
    final type = _getRequestType(request.icon);

    return Container(
      margin: const EdgeInsets.only(bottom: MediasfuSpacing.sm),
      child: SectionCard(
        isDarkMode: widget.options.isDarkMode,
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(MediasfuSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FaIcon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: MediasfuSpacing.md),

            // Name and type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.name ?? 'Unknown',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: widget.options.isDarkMode
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Requesting $type',
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
                  color: MediasfuColors.success,
                  onTap: () async {
                    await widget.options.onRequestItemPress(
                      RespondToRequestsOptions(
                        request: request,
                        updateRequestList: widget.options.updateRequestList,
                        requestList: widget.options.requestList,
                        action: 'accepted',
                        roomName: widget.options.roomName,
                        socket: widget.options.socket,
                      ),
                    );
                  },
                ),
                const SizedBox(width: MediasfuSpacing.sm),
                _buildActionButton(
                  icon: Icons.close_rounded,
                  color: MediasfuColors.danger,
                  onTap: () async {
                    await widget.options.onRequestItemPress(
                      RespondToRequestsOptions(
                        request: request,
                        updateRequestList: widget.options.updateRequestList,
                        requestList: widget.options.requestList,
                        action: 'rejected',
                        roomName: widget.options.roomName,
                        socket: widget.options.socket,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(MediasfuSpacing.sm),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.5),
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 18,
        ),
      ),
    );
  }
}
