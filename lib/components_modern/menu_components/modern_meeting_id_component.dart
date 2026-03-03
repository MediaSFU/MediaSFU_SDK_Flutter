import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

/// Configuration options for the `ModernMeetingIdComponent` widget.
///
/// Defines the meeting ID value and styling for a modern glassmorphic
/// read-only display field with copy functionality.
///
/// **Properties:**
/// - `meetingID`: The meeting/event ID string to display (required)
/// - `showCopyButton`: Whether to show a copy-to-clipboard button (default: true)
/// - `onCopied`: Optional callback invoked after successful copy
/// - `label`: Custom label text (default: "Event ID")
/// - `useGlassmorphism`: Enable glassmorphic blur effect (default: true)
/// - `isDarkMode`: Whether dark mode is enabled (default: true)
class ModernMeetingIdComponentOptions {
  final String meetingID;
  final bool showCopyButton;
  final VoidCallback? onCopied;
  final String? label;
  final bool useGlassmorphism;
  final bool isDarkMode;

  ModernMeetingIdComponentOptions({
    required this.meetingID,
    this.showCopyButton = true,
    this.onCopied,
    this.label,
    this.useGlassmorphism = true,
    this.isDarkMode = true,
  });
}

typedef ModernMeetingIdComponentType = Widget Function({
  required ModernMeetingIdComponentOptions options,
});

/// A modern glassmorphic widget displaying a read-only meeting/event ID.
///
/// Features:
/// - Frosted glass background with blur effect
/// - One-click copy to clipboard functionality
/// - Animated feedback on copy
/// - Gradient accent on label
/// - Clean, minimal design
///
/// ### Example Usage:
/// ```dart
/// ModernMeetingIdComponent(
///   options: ModernMeetingIdComponentOptions(
///     meetingID: "ABC-123-XYZ",
///     showCopyButton: true,
///     onCopied: () => showToast("Copied!"),
///   ),
/// )
/// ```
class ModernMeetingIdComponent extends StatefulWidget {
  final ModernMeetingIdComponentOptions options;

  const ModernMeetingIdComponent({super.key, required this.options});

  @override
  State<ModernMeetingIdComponent> createState() =>
      _ModernMeetingIdComponentState();
}

class _ModernMeetingIdComponentState extends State<ModernMeetingIdComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.options.meetingID));
    setState(() => _copied = true);
    _controller.forward().then((_) => _controller.reverse());
    widget.options.onCopied?.call();

    // Reset copied state after delay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _copied = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.options.label ?? 'Event ID';
    final isDarkMode = widget.options.isDarkMode;

    // Theme-aware colors
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final surfaceColor =
        isDarkMode ? MediasfuColors.surface : Colors.grey.shade100;
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.1);

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label with gradient
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                MediasfuColors.primary,
                MediasfuColors.secondary,
              ],
            ).createShader(bounds),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
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
                    color: borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: MediasfuColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(MediasfuSpacing.xs),
                      ),
                      child: Icon(
                        Icons.meeting_room_outlined,
                        size: 16,
                        color: MediasfuColors.primary,
                      ),
                    ),
                    const SizedBox(width: MediasfuSpacing.sm),

                    // Meeting ID text
                    Expanded(
                      child: Text(
                        widget.options.meetingID,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Copy button
                    if (widget.options.showCopyButton) ...[
                      const SizedBox(width: MediasfuSpacing.sm),
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
                                        MediasfuColors.primary
                                            .withOpacity(0.3),
                                        MediasfuColors.secondary
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
                                    : MediasfuColors.primary,
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
        ],
      ),
    );
  }
}
