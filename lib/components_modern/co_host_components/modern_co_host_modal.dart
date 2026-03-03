import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/co_host_components/co_host_modal.dart'
    show CoHostModalOptions;
import '../../methods/co_host_methods/modify_co_host_settings.dart'
    show ModifyCoHostSettingsOptions;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../../types/types.dart' show CoHostResponsibility;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/widgets/modern_switch.dart';

/// Modern glassmorphic co-host management modal.
///
/// Features:
/// - Glassmorphic frosted container with backdrop blur
/// - Animated participant selection dropdown
/// - Modern toggle switches for responsibilities
/// - Visual hierarchy for dedicated vs standard permissions
/// - Smooth animations and micro-interactions
///
/// Uses [CoHostModalOptions] for configuration and delegates
/// all business logic to the original co-host methods.
class ModernCoHostModal extends StatefulWidget {
  final CoHostModalOptions options;

  const ModernCoHostModal({super.key, required this.options});

  @override
  State<ModernCoHostModal> createState() => _ModernCoHostModalState();
}

class _ModernCoHostModalState extends State<ModernCoHostModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late String _selectedCohost;
  late List<CoHostResponsibility> _coHostResponsibilityCopy;
  late Map<String, bool> _responsibilities;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _selectedCohost = widget.options.currentCohost;
    _coHostResponsibilityCopy = List.from(widget.options.coHostResponsibility);
    _responsibilities = _initializeResponsibilities(_coHostResponsibilityCopy);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Map<String, bool> _initializeResponsibilities(
      List<CoHostResponsibility> responsibilitiesList) {
    final map = <String, bool>{};
    for (var resp in responsibilitiesList) {
      final capitalizedName = _capitalize(resp.name);
      map['manage$capitalizedName'] = resp.value;
      map['dedicateToManage$capitalizedName'] = resp.dedicated;
    }
    return map;
  }

  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  void _handleToggleSwitch(String key) {
    if (!mounted) return;
    setState(() {
      _responsibilities[key] = !_responsibilities[key]!;
      _updateResponsibilityList(key);
    });
  }

  void _updateResponsibilityList(String key) {
    String responsibilityName = '';
    bool? newValue;

    if (key.startsWith('dedicateToManage')) {
      responsibilityName = key.replaceAll('dedicateToManage', '').toLowerCase();
      newValue = _responsibilities[key];
      _setCoHostResponsibilityValue(responsibilityName,
          dedicated: newValue ?? false);
    } else if (key.startsWith('manage')) {
      responsibilityName = key.replaceAll('manage', '').toLowerCase();
      newValue = _responsibilities[key];
      _setCoHostResponsibilityValue(responsibilityName,
          value: newValue ?? false);
      if (!newValue!) {
        String dedicatedKey =
            'dedicateToManage${_capitalize(responsibilityName)}';
        _responsibilities[dedicatedKey] = false;
        _setCoHostResponsibilityValue(responsibilityName, dedicated: false);
      }
    }
  }

  void _setCoHostResponsibilityValue(String name,
      {bool? value, bool? dedicated}) {
    int index =
        _coHostResponsibilityCopy.indexWhere((item) => item.name == name);
    if (index != -1) {
      if (value != null) _coHostResponsibilityCopy[index].value = value;
      if (dedicated != null) {
        _coHostResponsibilityCopy[index].dedicated = dedicated;
      }
    }
  }

  Future<void> _saveCoHostSettings() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      await widget.options.onModifyCoHostSettings(
        ModifyCoHostSettingsOptions(
          roomName: widget.options.roomName,
          showAlert: widget.options.showAlert,
          selectedParticipant: _selectedCohost,
          coHost: widget.options.currentCohost,
          coHostResponsibility: _coHostResponsibilityCopy,
          updateCoHostResponsibility: widget.options.updateCoHostResponsibility,
          updateCoHost: widget.options.updateCoHost,
          updateIsCoHostModalVisible: widget.options.updateIsCoHostModalVisible,
          socket: widget.options.socket,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      widget.options.onCoHostClose();
    });
  }

  String _formatResponsibilityLabel(String name) {
    final regex = RegExp(r'(?=[A-Z])');
    final splitName = name.split(regex).join(' ');
    return splitName[0].toUpperCase() + splitName.substring(1);
  }

  IconData _getResponsibilityIcon(String name) {
    switch (name.toLowerCase()) {
      case 'participants':
        return Icons.people_outline;
      case 'media':
        return Icons.videocam_outlined;
      case 'waiting':
        return Icons.hourglass_empty;
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'polls':
        return Icons.poll_outlined;
      case 'breakout':
        return Icons.workspaces_outline;
      case 'recording':
        return Icons.fiber_manual_record_outlined;
      default:
        return Icons.settings_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    // For sidebar or inline mode, render content directly without modal wrapper
    if (widget.options.renderMode == ModalRenderMode.sidebar ||
        widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent(context);
    }

    if (!widget.options.isCoHostModalVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth > 480 ? 460.0 : screenWidth * 0.92;

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
            ? MediasfuColors.surfaceDark.withOpacity(0.92)
            : MediasfuColors.surface.withOpacity(0.95));
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor =
        isDark ? Colors.white70 : Colors.black87.withOpacity(0.6);
    final primaryColor = MediasfuColors.primary;
    final dividerColor =
        (isDark ? Colors.white : Colors.black).withOpacity(0.1);

    final filteredParticipants =
        widget.options.participants.where((p) => p.islevel != '2').toList();

    if (!filteredParticipants.any((p) => p.name == _selectedCohost) &&
        _selectedCohost != 'No coHost') {
      _selectedCohost = 'No coHost';
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _handleClose,
        child: Container(
          color: Colors.black.withOpacity(0.1),
          child: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: child,
              );
            },
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: modalWidth,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  margin: const EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: dividerColor,
                            width: 1,
                          ),
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
                            _buildHeader(textColor, dividerColor),
                            _buildCoHostSelector(
                              textColor,
                              subtitleColor,
                              primaryColor,
                              dividerColor,
                              filteredParticipants,
                            ),
                            Flexible(
                              child: _buildResponsibilitiesList(
                                textColor,
                                subtitleColor,
                                primaryColor,
                                dividerColor,
                              ),
                            ),
                            _buildFooter(primaryColor),
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

    final surfaceColor = isDark
        ? MediasfuColors.surfaceDark.withOpacity(0.92)
        : MediasfuColors.surface.withOpacity(0.95);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor =
        isDark ? Colors.white70 : Colors.black87.withOpacity(0.6);
    final primaryColor = MediasfuColors.primary;
    final dividerColor =
        (isDark ? Colors.white : Colors.black).withOpacity(0.1);

    final filteredParticipants =
        widget.options.participants.where((p) => p.islevel != '2').toList();

    if (!filteredParticipants.any((p) => p.name == _selectedCohost) &&
        _selectedCohost != 'No coHost') {
      _selectedCohost = 'No coHost';
    }

    return Container(
      color: surfaceColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildHeader(textColor, dividerColor),
          _buildCoHostSelector(
            textColor,
            subtitleColor,
            primaryColor,
            dividerColor,
            filteredParticipants,
          ),
          Expanded(
            child: _buildResponsibilitiesList(
              textColor,
              subtitleColor,
              primaryColor,
              dividerColor,
            ),
          ),
          _buildFooter(primaryColor),
        ],
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color dividerColor) {
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
                  MediasfuColors.primary,
                  MediasfuColors.primary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: MediasfuColors.primary.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: MediasfuSpacing.sm),
          Expanded(
            child: Text(
              'Manage Co-Host',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
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

  Widget _buildCoHostSelector(
    Color textColor,
    Color subtitleColor,
    Color primaryColor,
    Color dividerColor,
    List filteredParticipants,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Co-Host',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: MediasfuSpacing.sm),
          Tooltip(
            message: 'Choose a participant to assign as co-host',
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
                  value: _selectedCohost,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark
                        ? MediasfuColors.primaryDark
                        : MediasfuColors.primary,
                  ),
                  style: MediasfuColors.dropdownTextStyle(darkMode: isDark),
                  dropdownColor:
                      MediasfuColors.dropdownBackground(darkMode: isDark),
                  onChanged: (String? newValue) {
                    if (newValue != null && mounted) {
                      setState(() => _selectedCohost = newValue);
                    }
                  },
                  items: [
                    DropdownMenuItem<String>(
                      value: 'No coHost',
                      child: Row(
                        children: [
                          Icon(Icons.person_off_outlined,
                              size: 18, color: subtitleColor),
                          const SizedBox(width: MediasfuSpacing.sm),
                          Text('No Co-Host',
                              style: TextStyle(color: subtitleColor)),
                        ],
                      ),
                    ),
                    ...filteredParticipants.map<DropdownMenuItem<String>>((p) {
                      return DropdownMenuItem<String>(
                        value: p.name,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: primaryColor.withOpacity(0.2),
                              child: Text(
                                p.name.isNotEmpty
                                    ? p.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: MediasfuSpacing.sm),
                            Text(p.name),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsibilitiesList(
    Color textColor,
    Color subtitleColor,
    Color primaryColor,
    Color dividerColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: MediasfuSpacing.md),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  'Responsibility',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    'Allow',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: subtitleColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    'Dedicated',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: subtitleColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: MediasfuSpacing.xs),
        Divider(color: dividerColor, height: 1),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: MediasfuSpacing.xs),
            itemCount: _coHostResponsibilityCopy.length,
            itemBuilder: (context, index) {
              final responsibility = _coHostResponsibilityCopy[index];
              return _buildResponsibilityRow(
                responsibility,
                textColor,
                subtitleColor,
                primaryColor,
                dividerColor,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResponsibilityRow(
    CoHostResponsibility responsibility,
    Color textColor,
    Color subtitleColor,
    Color primaryColor,
    Color dividerColor,
  ) {
    final capitalizedName = _capitalize(responsibility.name);
    final manageKey = 'manage$capitalizedName';
    final dedicateKey = 'dedicateToManage$capitalizedName';
    final isManageEnabled = _responsibilities[manageKey] ?? false;
    final isDedicateEnabled = _responsibilities[dedicateKey] ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.md,
        vertical: MediasfuSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (isManageEnabled ? primaryColor : subtitleColor)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getResponsibilityIcon(responsibility.name),
                    size: 16,
                    color: isManageEnabled ? primaryColor : subtitleColor,
                  ),
                ),
                const SizedBox(width: MediasfuSpacing.sm),
                Expanded(
                  child: Text(
                    _formatResponsibilityLabel(responsibility.name),
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      fontWeight:
                          isManageEnabled ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: ModernSwitch(
                value: isManageEnabled,
                onChanged: (_) => _handleToggleSwitch(manageKey),
                isDarkMode: Theme.of(context).brightness == Brightness.dark,
                semanticLabel:
                    '${_formatResponsibilityLabel(responsibility.name)} manage toggle',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isManageEnabled ? 1.0 : 0.3,
                child: ModernSwitch(
                  value: isDedicateEnabled,
                  onChanged: isManageEnabled
                      ? (_) => _handleToggleSwitch(dedicateKey)
                      : (_) {},
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  semanticLabel:
                      '${_formatResponsibilityLabel(responsibility.name)} dedicate toggle',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _handleClose,
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: MediasfuSpacing.md),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveCoHostSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: MediasfuSpacing.sm + 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
