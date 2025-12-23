import 'dart:ui';
import 'package:flutter/material.dart';

import '../../components/display_components/pagination.dart'
    show PaginationOptions, PaginationParameters;
import '../../consumers/generate_page_content.dart'
    show GeneratePageContentOptions;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/theme/mediasfu_animations.dart';

typedef ModernPaginationType = Widget Function(
    {required PaginationOptions options});

/// Modern styled pagination that accepts [PaginationOptions].
/// Provides glassmorphic styling and modern visual treatment while
/// maintaining API compatibility with the original Pagination.
///
/// Features:
/// - Smart pagination with prev/next arrows when > 6 pages
/// - Breakout room icons and styling
/// - Tooltips for all buttons
/// - Home button always visible
/// - For breakout rooms, centers on user's assigned room
///
/// Note: isDarkMode is read from options.isDarkMode for reactivity
class ModernPagination extends StatefulWidget {
  final PaginationOptions options;
  final bool enableGlassmorphism;
  final bool enableGlow;
  final double glowIntensity;

  const ModernPagination({
    super.key,
    required this.options,
    @Deprecated('Use options.isDarkMode instead for reactive updates')
    bool isDarkMode = true,
    this.enableGlassmorphism = true,
    this.enableGlow = true,
    this.glowIntensity = 0.4,
  });

  /// Get isDarkMode from options for reactivity
  bool get isDarkMode => options.isDarkMode;

  @override
  State<ModernPagination> createState() => _ModernPaginationState();
}

class _ModernPaginationState extends State<ModernPagination>
    with SingleTickerProviderStateMixin {
  int _hoverIndex = -1;
  int _windowStart =
      1; // Start of visible page window (excludes home which is always shown)
  bool _hasInitializedWindow =
      false; // Track if we've done initial centering for breakout
  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  static const int _maxVisiblePages =
      5; // Max pages to show (excluding home and arrows)

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: MediasfuAnimations.normal,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ModernPagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only auto-adjust when breakout state changes (starts/ends)
    final oldParams = oldWidget.options.parameters.getUpdatedAllParams();
    final newParams = widget.options.parameters.getUpdatedAllParams();

    final wasBreakout =
        oldParams.breakOutRoomStarted && !oldParams.breakOutRoomEnded;
    final isBreakout =
        newParams.breakOutRoomStarted && !newParams.breakOutRoomEnded;

    // Re-center window when breakout rooms start
    if (!wasBreakout && isBreakout) {
      _hasInitializedWindow = false;
    }
  }

  void _adjustWindowForCurrentPage() {
    final totalPages = widget.options.totalPages;
    final params = widget.options.parameters.getUpdatedAllParams();

    if (totalPages <= _maxVisiblePages) {
      _windowStart = 1;
      return;
    }

    // For breakout rooms, center on user's assigned room ONCE when they start
    final isBreakout = params.breakOutRoomStarted && !params.breakOutRoomEnded;
    if (isBreakout && !_hasInitializedWindow) {
      final userRoom = params.memberRoom + params.mainRoomsLength;
      final halfWindow = _maxVisiblePages ~/ 2;
      _windowStart =
          (userRoom - halfWindow).clamp(1, totalPages - _maxVisiblePages + 1);
      _hasInitializedWindow = true;
    }

    // Clamp window to valid bounds
    _windowStart = _windowStart.clamp(
        1, (totalPages - _maxVisiblePages + 1).clamp(1, totalPages));
  }

  Future<void> _handlePageChange(int page) async {
    final params = widget.options.parameters.getUpdatedAllParams();
    await widget.options.handlePageChange(GeneratePageContentOptions(
      page: page,
      parameters: params,
      breakRoom:
          page >= params.mainRoomsLength ? page - params.mainRoomsLength : -1,
      inBreakRoom: page >= params.mainRoomsLength,
    ));
  }

  void _shiftWindowBack() {
    setState(() {
      // Shift by 3 pages for smoother navigation
      _windowStart = (_windowStart - 3).clamp(1, widget.options.totalPages);
    });
  }

  void _shiftWindowForward() {
    final maxStart = (widget.options.totalPages - _maxVisiblePages + 1)
        .clamp(1, widget.options.totalPages);
    setState(() {
      // Shift by 3 pages for smoother navigation
      _windowStart = (_windowStart + 3).clamp(1, maxStart);
    });
  }

  List<int> _getVisiblePages() {
    final totalPages = widget.options.totalPages;
    final allPages = List.generate(totalPages + 1, (i) => i); // 0 to totalPages

    if (totalPages <= _maxVisiblePages + 1) {
      // Show all pages if not many
      return allPages;
    }

    // Always include home (0), then window of pages
    final visiblePages = <int>[0];
    final windowEnd =
        (_windowStart + _maxVisiblePages - 1).clamp(1, totalPages);

    for (int i = _windowStart; i <= windowEnd; i++) {
      visiblePages.add(i);
    }

    return visiblePages;
  }

  bool get _canGoBack => _windowStart > 1;
  bool get _canGoForward =>
      _windowStart + _maxVisiblePages <= widget.options.totalPages;
  bool get _needsArrows => widget.options.totalPages > _maxVisiblePages + 1;

  @override
  Widget build(BuildContext context) {
    if (!widget.options.showAspect || widget.options.totalPages < 1) {
      return const SizedBox.shrink();
    }

    _adjustWindowForCurrentPage();

    final params = widget.options.parameters.getUpdatedAllParams();
    final visiblePages = _getVisiblePages();
    final isVertical = widget.options.direction == 'vertical';

    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnim, _scaleAnim]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
        );
      },
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: widget.enableGlow
                ? [
                    BoxShadow(
                      color: MediasfuColors.primary
                          .withValues(alpha: widget.glowIntensity * 0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: widget.enableGlassmorphism
                  ? ImageFilter.blur(sigmaX: 15, sigmaY: 15)
                  : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: MediasfuSpacing.sm,
                    vertical: MediasfuSpacing.xs),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isDarkMode
                        ? [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.04),
                          ]
                        : [
                            Colors.grey.shade200.withValues(alpha: 0.95),
                            Colors.grey.shade100.withValues(alpha: 0.90),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: widget.isDarkMode
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
                child: isVertical
                    ? IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _buildPaginationItems(
                              params, visiblePages, isVertical),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildPaginationItems(
                            params, visiblePages, isVertical),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPaginationItems(
      PaginationParameters params, List<int> visiblePages, bool isVertical) {
    final items = <Widget>[];

    // Home button (always first)
    items.add(_buildBtn(0, params));

    // Back arrow if needed
    if (_needsArrows && _canGoBack) {
      items.add(_buildArrowBtn(isBack: true, isVertical: isVertical));
    }

    // Visible page buttons (skip home since we already added it)
    for (final page in visiblePages) {
      if (page != 0) {
        items.add(_buildBtn(page, params));
      }
    }

    // Forward arrow if needed
    if (_needsArrows && _canGoForward) {
      items.add(_buildArrowBtn(isBack: false, isVertical: isVertical));
    }

    return items;
  }

  Widget _buildArrowBtn({required bool isBack, required bool isVertical}) {
    final isHovered = _hoverIndex == (isBack ? -2 : -3);
    final icon = isVertical
        ? (isBack
            ? Icons.keyboard_arrow_up_rounded
            : Icons.keyboard_arrow_down_rounded)
        : (isBack ? Icons.chevron_left_rounded : Icons.chevron_right_rounded);
    final tooltip = isBack ? 'Previous pages' : 'More pages';

    return Tooltip(
      message: tooltip,
      preferBelow: !isVertical,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoverIndex = isBack ? -2 : -3),
        onExit: (_) => setState(() => _hoverIndex = -1),
        child: GestureDetector(
          onTap: isBack ? _shiftWindowBack : _shiftWindowForward,
          child: AnimatedContainer(
            duration: MediasfuAnimations.fast,
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isHovered
                  ? MediasfuColors.primary.withValues(alpha: 0.2)
                  : (widget.isDarkMode
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHovered
                    ? MediasfuColors.primary.withValues(alpha: 0.4)
                    : (widget.isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08)),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isHovered
                  ? MediasfuColors.primary
                  : (widget.isDarkMode ? Colors.white60 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBtn(int page, PaginationParameters params) {
    final isActive = page == widget.options.currentUserPage;
    final isHome = page == 0;
    final mainRoomsLength = params.mainRoomsLength;
    final isBR = page >= mainRoomsLength;
    final isBreakoutActive =
        params.breakOutRoomStarted && !params.breakOutRoomEnded;
    bool isLocked = false;
    String label;
    String tooltip;
    IconData? icon;

    if (isHome) {
      label = '';
      tooltip = 'Home (Main Room)';
      icon = Icons.home_rounded;
    } else if (isBR && isBreakoutActive) {
      final roomNumber = page - (mainRoomsLength - 1);
      final userRoomNumber = params.memberRoom + 1;
      final isUserRoom = userRoomNumber == roomNumber;
      final isHost = params.islevel == '2';

      isLocked = !isUserRoom && !isHost;
      label = '$roomNumber';
      tooltip = isUserRoom
          ? 'Your Breakout Room ($roomNumber)'
          : (isLocked
              ? 'Room $roomNumber (Locked)'
              : 'Breakout Room $roomNumber');
      icon = isUserRoom
          ? Icons.meeting_room_rounded
          : (isLocked ? Icons.lock_rounded : Icons.groups_rounded);
    } else {
      label = '$page';
      tooltip = 'Page $page';
      icon = null;
    }

    final isHovered = _hoverIndex == page;

    return Tooltip(
      message: tooltip,
      preferBelow: widget.options.direction != 'vertical',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoverIndex = page),
        onExit: (_) => setState(() => _hoverIndex = -1),
        child: GestureDetector(
          onTap: isLocked ? null : () => _handlePageChange(page),
          child: AnimatedContainer(
            duration: MediasfuAnimations.fast,
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            width: isHome ? 40 : (isBR && isBreakoutActive ? 48 : 36),
            height: 36,
            decoration: BoxDecoration(
              gradient: isActive
                  ? MediasfuColors.brandGradient(darkMode: widget.isDarkMode)
                  : (isHovered && !isLocked
                      ? LinearGradient(colors: [
                          MediasfuColors.primary.withValues(alpha: 0.25),
                          MediasfuColors.secondary.withValues(alpha: 0.25)
                        ])
                      : null),
              color: isActive || isHovered
                  ? null
                  : (isLocked
                      ? Colors.grey.withValues(alpha: 0.15)
                      : (widget.isDarkMode
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.08))),
              borderRadius: BorderRadius.circular(18),
              border: isActive
                  ? null
                  : Border.all(
                      color: isHovered
                          ? MediasfuColors.primary.withValues(alpha: 0.4)
                          : (widget.isDarkMode
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.08)),
                      width: 1,
                    ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: MediasfuColors.primary
                            .withValues(alpha: widget.glowIntensity),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: _buildBtnContent(
                isHome: isHome,
                isBR: isBR && isBreakoutActive,
                isActive: isActive,
                isLocked: isLocked,
                label: label,
                icon: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBtnContent({
    required bool isHome,
    required bool isBR,
    required bool isActive,
    required bool isLocked,
    required String label,
    IconData? icon,
  }) {
    final activeColor = Colors.white;
    final inactiveColor = widget.isDarkMode ? Colors.white70 : Colors.black87;
    final lockedColor = Colors.grey;

    if (isHome) {
      return AnimatedContainer(
        duration: MediasfuAnimations.fast,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
        ),
        child: Icon(
          Icons.home_rounded,
          size: 18,
          color: isActive ? activeColor : inactiveColor,
        ),
      );
    }

    if (isBR) {
      // Breakout room button with icon
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.groups_rounded,
            size: 14,
            color: isLocked
                ? lockedColor
                : (isActive ? activeColor : inactiveColor),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              letterSpacing: 0.2,
              color: isLocked
                  ? lockedColor
                  : (isActive ? activeColor : inactiveColor),
            ),
          ),
        ],
      );
    }

    // Regular page number
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
        letterSpacing: 0.3,
        color: isActive ? activeColor : inactiveColor,
      ),
    );
  }
}
