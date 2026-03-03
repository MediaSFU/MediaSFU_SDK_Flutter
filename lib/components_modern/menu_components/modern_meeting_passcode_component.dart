import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

/// Configuration options for the `ModernMeetingPasscodeComponent` widget.
///
/// Defines the meeting passcode value and styling for a modern glassmorphic
/// read-only display field with copy functionality and optional visibility toggle.
///
/// **Properties:**
/// - `meetingPasscode`: The passcode string to display (required)
/// - `showCopyButton`: Whether to show a copy-to-clipboard button (default: true)
/// - `showVisibilityToggle`: Whether to allow showing/hiding passcode (default: true)
/// - `initiallyVisible`: Initial visibility state of passcode (default: false - masked)
/// - `onCopied`: Optional callback invoked after successful copy
/// - `label`: Custom label text (default: "Event Passcode (Host)")
/// - `useGlassmorphism`: Enable glassmorphic blur effect (default: true)
/// - `isDarkMode`: Whether dark mode is enabled (default: true)
class ModernMeetingPasscodeComponentOptions {
  final String meetingPasscode;
  final bool showCopyButton;
  final bool showVisibilityToggle;
  final bool initiallyVisible;
  final VoidCallback? onCopied;
  final String? label;
  final bool useGlassmorphism;
  final bool isDarkMode;

  ModernMeetingPasscodeComponentOptions({
    required this.meetingPasscode,
    this.showCopyButton = true,
    this.showVisibilityToggle = true,
    this.initiallyVisible = false,
    this.onCopied,
    this.label,
    this.useGlassmorphism = true,
    this.isDarkMode = true,
  });
}

typedef ModernMeetingPasscodeComponentType = Widget Function(
    ModernMeetingPasscodeComponentOptions options);

/// A modern glassmorphic widget displaying a read-only meeting passcode.
///
/// Features:
/// - Frosted glass background with blur effect
/// - Visibility toggle to show/hide passcode
/// - One-click copy to clipboard functionality
/// - Animated feedback on copy
/// - Security-focused design with masked text
/// - Host-only indicator styling
///
/// ### Example Usage:
/// ```dart
/// ModernMeetingPasscodeComponent(
///   options: ModernMeetingPasscodeComponentOptions(
///     meetingPasscode: "1234",
///     showVisibilityToggle: true,
///     onCopied: () => showToast("Passcode copied!"),
///   ),
/// )
/// ```
class ModernMeetingPasscodeComponent extends StatefulWidget {
  final ModernMeetingPasscodeComponentOptions options;

  const ModernMeetingPasscodeComponent({super.key, required this.options});

  @override
  State<ModernMeetingPasscodeComponent> createState() =>
      _ModernMeetingPasscodeComponentState();
}

class _ModernMeetingPasscodeComponentState
    extends State<ModernMeetingPasscodeComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _copied = false;
  late bool _isVisible;

  @override
  void initState() {
    super.initState();
    _isVisible = widget.options.initiallyVisible;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _displayText {
    if (_isVisible) {
      return widget.options.meetingPasscode;
    }
    return '•' * widget.options.meetingPasscode.length;
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(
        ClipboardData(text: widget.options.meetingPasscode));
    setState(() => _copied = true);
    _controller.forward().then((_) => _controller.reverse());
    widget.options.onCopied?.call();

    // Reset copied state after delay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _copied = false);
    }
  }

  void _toggleVisibility() {
    setState(() => _isVisible = !_isVisible);
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.options.label ?? 'Admin Passcode';
    final isDarkMode = widget.options.isDarkMode;

    // Theme-aware colors
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtleTextColor = isDarkMode ? Colors.white54 : Colors.black54;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final surfaceColor =
        isDarkMode ? MediasfuColors.surface : Colors.grey.shade100;
    final toggleBgColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.06);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.1);

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label with warning gradient (host-only indicator)
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: MediasfuSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: MediasfuColors.danger.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 10,
                      color: MediasfuColors.danger,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Private',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: MediasfuColors.danger,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: MediasfuSpacing.sm),

          // Glassmorphic input field
          ClipRRect(
            borderRadius: BorderRadius.circular(MediasfuSpacing.md),
            child: BackdropFilter(
              filter: widget.options.useGlassmorphism
                  ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                  : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediasfuSpacing.md,
                  vertical: MediasfuSpacing.sm + 2,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      surfaceColor.withOpacity(isDarkMode ? 0.7 : 0.95),
                      surfaceColor.withOpacity(isDarkMode ? 0.5 : 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(MediasfuSpacing.md),
                  border: Border.all(
                    color: MediasfuColors.danger.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Lock icon
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: MediasfuColors.danger.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(MediasfuSpacing.xs),
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: MediasfuColors.danger,
                      ),
                    ),
                    const SizedBox(width: MediasfuSpacing.sm),

                    // Passcode text (masked or visible)
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _displayText,
                          key: ValueKey(_isVisible),
                          style: TextStyle(
                            color: textColor,
                            fontSize: _isVisible ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: _isVisible ? 2.0 : 4.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Visibility toggle
                    if (widget.options.showVisibilityToggle) ...[
                      GestureDetector(
                        onTap: _toggleVisibility,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: toggleBgColor,
                            borderRadius:
                                BorderRadius.circular(MediasfuSpacing.sm),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _isVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              key: ValueKey(_isVisible),
                              size: 16,
                              color: iconColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: MediasfuSpacing.xs),
                    ],

                    // Copy button
                    if (widget.options.showCopyButton) ...[
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: GestureDetector(
                          onTap: _copyToClipboard,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _copied
                                    ? [
                                        MediasfuColors.success,
                                        MediasfuColors.success
                                            .withOpacity(0.8),
                                      ]
                                    : [
                                        MediasfuColors.warning
                                            .withOpacity(0.3),
                                        MediasfuColors.warning
                                            .withOpacity(0.2),
                                      ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(MediasfuSpacing.sm),
                              border: Border.all(
                                color: _copied
                                    ? MediasfuColors.success
                                        .withOpacity(0.5)
                                    : borderColor,
                              ),
                              boxShadow: _copied
                                  ? [
                                      BoxShadow(
                                        color: MediasfuColors.success
                                            .withOpacity(0.5),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                _copied ? Icons.check : Icons.copy_rounded,
                                key: ValueKey(_copied),
                                size: 16,
                                color: _copied
                                    ? Colors.white
                                    : MediasfuColors.warning,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Security hint
          Padding(
            padding: EdgeInsets.only(top: MediasfuSpacing.xs),
            child: Text(
              'Others with this passcode can join as host with full privileges.',
              style: TextStyle(
                fontSize: 11,
                color: subtleTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
