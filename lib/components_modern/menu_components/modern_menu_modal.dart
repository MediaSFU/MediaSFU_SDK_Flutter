import 'dart:ui';

import 'package:flutter/material.dart';

import '../../components/menu_components/menu_modal.dart' show MenuModalOptions;
import '../../methods/utils/get_modal_position.dart'
    show GetModalPositionOptions, getModalPosition;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import 'modern_custom_buttons.dart'
    show ModernCustomButtons, ModernCustomButton, ModernCustomButtonsOptions;
import 'modern_meeting_id_component.dart'
    show ModernMeetingIdComponent, ModernMeetingIdComponentOptions;
import 'modern_meeting_passcode_component.dart'
    show ModernMeetingPasscodeComponent, ModernMeetingPasscodeComponentOptions;
import 'modern_share_buttons_component.dart'
    show ModernShareButtonsComponent, ModernShareButtonsComponentOptions;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/theme/mediasfu_typography.dart';
import '../core/theme/mediasfu_animations.dart';
import '../core/widgets/modern_switch.dart';

/// Modern redesigned MenuModal with glassmorphic styling, premium animations,
/// theme selector, and enhanced visual effects.
class ModernMenuModal extends StatefulWidget {
  final MenuModalOptions options;

  const ModernMenuModal({super.key, required this.options});

  @override
  State<ModernMenuModal> createState() => _ModernMenuModalState();
}

class _ModernMenuModalState extends State<ModernMenuModal>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _backdropController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _backdropAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: MediasfuAnimations.normal,
    );
    _backdropController = AnimationController(
      vsync: this,
      duration: MediasfuAnimations.fast,
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _backdropAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backdropController, curve: Curves.easeOut),
    );
    if (widget.options.isVisible) {
      _backdropController.forward();
      _animController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ModernMenuModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.isVisible != oldWidget.options.isVisible) {
      if (widget.options.isVisible) {
        _backdropController.forward();
        _animController.forward();
      } else {
        _animController.reverse();
        _backdropController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _backdropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the passed isDarkMode value from options for consistent theming
    final bool isDark = widget.options.isDarkMode;
    final textTheme = MediasfuTypography.textTheme(darkMode: isDark);

    // For sidebar or inline mode, render content directly without modal wrapper
    if (widget.options.renderMode == ModalRenderMode.sidebar ||
        widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent(context, isDark, textTheme);
    }

    final double modalWidth = MediaQuery.of(context).size.width * 0.85 > 480
        ? 480
        : MediaQuery.of(context).size.width * 0.85;
    final double modalHeight = MediaQuery.of(context).size.height * 0.75;

    final position = getModalPosition(GetModalPositionOptions(
      position: widget.options.position,
      modalWidth: modalWidth,
      modalHeight: modalHeight,
      context: context,
    ));

    return Visibility(
      visible: widget.options.isVisible,
      child: Stack(
        children: [
          // Semi-transparent backdrop - minimal to see content underneath
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.options.onClose,
              child: AnimatedBuilder(
                animation: _backdropAnim,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color:
                          Colors.black.withOpacity(0.05 * _backdropAnim.value),
                    ),
                  );
                },
              ),
            ),
          ),
          // Modal with premium styling
          Positioned(
            top: position['top'],
            right: position['right'],
            child: AnimatedBuilder(
              animation: Listenable.merge([_fadeAnim, _scaleAnim, _slideAnim]),
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.translate(
                    offset: Offset(_slideAnim.value, 0),
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      alignment: Alignment.topRight,
                      child: child,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      width: modalWidth,
                      height: modalHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  MediasfuColors.surfaceElevatedDark
                                      .withOpacity(0.05),
                                  MediasfuColors.surfaceDark.withOpacity(0.1),
                                ]
                              : [
                                  Colors.white.withOpacity(0.05),
                                  MediasfuColors.surface.withOpacity(0.1),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? MediasfuColors.primaryDark.withOpacity(0.2)
                              : MediasfuColors.primary.withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Premium header
                          _buildHeader(isDark, textTheme),
                          // Premium divider
                          _buildDivider(isDark),
                          // Body
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(MediasfuSpacing.lg),
                              physics: const BouncingScrollPhysics(),
                              children: [
                                // Theme selector
                                _buildThemeSelector(isDark, textTheme),
                                const SizedBox(height: MediasfuSpacing.lg),

                                // Custom buttons section
                                if (widget
                                    .options.customButtons.isNotEmpty) ...[
                                  _buildSectionTitle(
                                      'Quick Actions', textTheme, isDark),
                                  const SizedBox(height: MediasfuSpacing.sm),
                                  ModernCustomButtons(
                                    options: ModernCustomButtonsOptions(
                                      buttons: widget.options.customButtons
                                          .map(
                                            (btn) => ModernCustomButton(
                                              action: btn.action,
                                              show: btn.show,
                                              backgroundColor:
                                                  btn.backgroundColor,
                                              disabled: btn.disabled,
                                              icon: btn.icon,
                                              text: btn.text,
                                              textStyle: btn.textStyle,
                                              customComponent:
                                                  btn.customComponent,
                                              iconColor: btn.iconStyle?.color,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                  const SizedBox(height: MediasfuSpacing.lg),
                                ],

                                // Meeting info section
                                _buildSectionTitle(
                                    'Meeting Info', textTheme, isDark),
                                const SizedBox(height: MediasfuSpacing.sm),

                                // Admin passcode
                                if (widget.options.islevel == '2') ...[
                                  ModernMeetingPasscodeComponent(
                                    options:
                                        ModernMeetingPasscodeComponentOptions(
                                      meetingPasscode:
                                          widget.options.adminPasscode,
                                      isDarkMode: isDark,
                                    ),
                                  ),
                                  const SizedBox(height: MediasfuSpacing.md),
                                ],

                                // Meeting ID
                                ModernMeetingIdComponent(
                                  options: ModernMeetingIdComponentOptions(
                                    meetingID: widget.options.roomName,
                                    isDarkMode: isDark,
                                  ),
                                ),

                                // Share buttons
                                if (widget.options.shareButtons) ...[
                                  const SizedBox(height: MediasfuSpacing.lg),
                                  _buildSectionTitle(
                                      'Share Meeting', textTheme, isDark),
                                  const SizedBox(height: MediasfuSpacing.sm),
                                  ModernShareButtonsComponent(
                                    options: ModernShareButtonsComponentOptions(
                                      meetingID: widget.options.roomName,
                                      eventType: widget.options.eventType,
                                      localLink: widget.options.localLink,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: MediasfuSpacing.xl),
                              ],
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
    );
  }

  /// Builds sidebar-optimized content for embedding in sidebar panel.
  Widget _buildSidebarContent(
      BuildContext context, bool isDark, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Premium header with close button
        _buildHeader(isDark, textTheme),
        // Premium divider
        _buildDivider(isDark),
        // Body
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(MediasfuSpacing.lg),
            physics: const BouncingScrollPhysics(),
            children: [
              // Theme selector
              _buildThemeSelector(isDark, textTheme),
              const SizedBox(height: MediasfuSpacing.lg),

              // Custom buttons section
              if (widget.options.customButtons.isNotEmpty) ...[
                _buildSectionTitle('Quick Actions', textTheme, isDark),
                const SizedBox(height: MediasfuSpacing.sm),
                ModernCustomButtons(
                  options: ModernCustomButtonsOptions(
                    buttons: widget.options.customButtons
                        .map(
                          (btn) => ModernCustomButton(
                            action: btn.action,
                            show: btn.show,
                            backgroundColor: btn.backgroundColor,
                            disabled: btn.disabled,
                            icon: btn.icon,
                            text: btn.text,
                            textStyle: btn.textStyle,
                            customComponent: btn.customComponent,
                            iconColor: btn.iconStyle?.color,
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: MediasfuSpacing.lg),
              ],

              // Meeting info section
              _buildSectionTitle('Meeting Info', textTheme, isDark),
              const SizedBox(height: MediasfuSpacing.sm),

              // Admin passcode
              if (widget.options.islevel == '2') ...[
                ModernMeetingPasscodeComponent(
                  options: ModernMeetingPasscodeComponentOptions(
                    meetingPasscode: widget.options.adminPasscode,
                    isDarkMode: isDark,
                  ),
                ),
                const SizedBox(height: MediasfuSpacing.md),
              ],

              // Meeting ID
              ModernMeetingIdComponent(
                options: ModernMeetingIdComponentOptions(
                  meetingID: widget.options.roomName,
                  isDarkMode: isDark,
                ),
              ),

              // Share buttons
              if (widget.options.shareButtons) ...[
                const SizedBox(height: MediasfuSpacing.lg),
                _buildSectionTitle('Share Meeting', textTheme, isDark),
                const SizedBox(height: MediasfuSpacing.sm),
                ModernShareButtonsComponent(
                  options: ModernShareButtonsComponentOptions(
                    meetingID: widget.options.roomName,
                    eventType: widget.options.eventType,
                    localLink: widget.options.localLink,
                  ),
                ),
              ],
              const SizedBox(height: MediasfuSpacing.xl),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Animated menu icon with gradient
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: MediasfuColors.brandGradient(darkMode: isDark),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: MediasfuSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Control Center',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Manage your meeting',
                    style: textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? Colors.white.withOpacity(0.6)
                          : Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildCloseButton(isDark),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: MediasfuSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            (isDark ? MediasfuColors.primaryDark : MediasfuColors.primary)
                .withOpacity(0.4),
            (isDark ? MediasfuColors.secondary : MediasfuColors.accent)
                .withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(bool isDark, TextTheme textTheme) {
    final hasToggleCallback = widget.options.onToggleTheme != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: hasToggleCallback
            ? () => widget.options.onToggleTheme!(!isDark)
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MediasfuSpacing.md,
            vertical: MediasfuSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.02),
                    ]
                  : [
                      MediasfuColors.primary.withOpacity(0.05),
                      MediasfuColors.secondary.withOpacity(0.03),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : MediasfuColors.primary.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              // Theme icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? MediasfuColors.primaryDark.withOpacity(0.2)
                      : MediasfuColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: isDark
                      ? MediasfuColors.primaryDark
                      : MediasfuColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: MediasfuSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDark ? 'Dark mode' : 'Light mode',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (hasToggleCallback) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Tap to switch theme',
                        style: textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white.withOpacity(0.5)
                              : Colors.black.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Toggle switch
              ModernSwitch(
                value: isDark,
                onChanged: hasToggleCallback
                    ? (value) => widget.options.onToggleTheme!(value)
                    : (_) {},
                isDarkMode: isDark,
                semanticLabel: 'Dark mode toggle',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton(bool isDark) {
    return Tooltip(
      message: 'Close menu and return to meeting',
      decoration: MediasfuColors.tooltipDecoration(darkMode: isDark),
      textStyle: TextStyle(
        color: MediasfuColors.tooltipText(darkMode: isDark),
        fontSize: 12,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.options.onClose,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: MediasfuColors.brandGradient(darkMode: isDark),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: MediasfuSpacing.sm),
        Text(
          title,
          style: textTheme.labelLarge?.copyWith(
            color: isDark ? MediasfuColors.primaryDark : MediasfuColors.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Convenience builder conforming to MenuModalType signature.
Widget modernMenuModalBuilder(MenuModalOptions options) {
  return ModernMenuModal(options: options);
}
