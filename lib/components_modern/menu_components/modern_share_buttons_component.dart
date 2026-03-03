import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../types/types.dart' show EventType;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

/// Configuration options for a single share button in `ModernShareButtonsComponent`.
///
/// Defines the appearance and action for one social sharing button with
/// modern glassmorphic styling and animated interactions.
class ModernShareButtonOptions {
  final IconData? icon;
  final VoidCallback action;
  final bool show;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  ModernShareButtonOptions({
    required this.action,
    this.icon,
    this.show = true,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
  });
}

/// Configuration options for the `ModernShareButtonsComponent` widget.
///
/// Defines meeting details for generating share URLs and allows custom
/// share button configurations with modern glassmorphic design.
///
/// **Properties:**
/// - `meetingID`: The meeting/event ID to share (required)
/// - `eventType`: Type of event (chat, broadcast, conference, webinar) (required)
/// - `customButtons`: Optional custom share buttons (replaces defaults if provided)
/// - `localLink`: Optional custom domain for share URLs
/// - `showLabels`: Whether to show text labels under icons (default: false)
/// - `useGlassmorphism`: Enable glassmorphic blur effect (default: true)
/// - `compact`: Use compact button sizing (default: false)
class ModernShareButtonsComponentOptions {
  final String meetingID;
  final EventType eventType;
  final List<ModernShareButtonOptions>? customButtons;
  final String? localLink;
  final bool showLabels;
  final bool useGlassmorphism;
  final bool compact;

  ModernShareButtonsComponentOptions({
    required this.meetingID,
    required this.eventType,
    this.customButtons,
    this.localLink,
    this.showLabels = false,
    this.useGlassmorphism = true,
    this.compact = false,
  });
}

typedef ModernShareButtonsComponentType = Widget Function(
    ModernShareButtonsComponentOptions options);

/// A modern glassmorphic widget displaying social share buttons.
///
/// Features:
/// - Glassmorphic design with frosted backgrounds
/// - Smooth hover and press animations
/// - Gradient button backgrounds matching brand colors
/// - Optional text labels
/// - Animated copy confirmation
///
/// **Default Share Buttons:**
/// 1. Copy to clipboard (animated feedback)
/// 2. Email
/// 3. Facebook
/// 4. WhatsApp
/// 5. Telegram
///
/// ### Example Usage:
/// ```dart
/// ModernShareButtonsComponent(
///   options: ModernShareButtonsComponentOptions(
///     meetingID: "ABC-123-XYZ",
///     eventType: EventType.conference,
///     showLabels: true,
///   ),
/// )
/// ```
class ModernShareButtonsComponent extends StatefulWidget {
  final ModernShareButtonsComponentOptions options;

  const ModernShareButtonsComponent({super.key, required this.options});

  @override
  State<ModernShareButtonsComponent> createState() =>
      _ModernShareButtonsComponentState();
}

class _ModernShareButtonsComponentState
    extends State<ModernShareButtonsComponent> {
  bool _copiedToClipboard = false;

  String getShareUrl() {
    if (widget.options.localLink != null &&
        widget.options.localLink!.isNotEmpty &&
        !widget.options.localLink!.contains('mediasfu.com')) {
      return '${widget.options.localLink}/meeting/${widget.options.meetingID}';
    }
    final shareName = widget.options.eventType == EventType.chat
        ? 'chat'
        : widget.options.eventType == EventType.broadcast
            ? 'broadcast'
            : 'meeting';
    return 'https://$shareName.mediasfu.com/$shareName/${widget.options.meetingID}';
  }

  Future<void> _copyToClipboard() async {
    await FlutterClipboard.copy(getShareUrl());
    setState(() => _copiedToClipboard = true);

    // Reset after delay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _copiedToClipboard = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define default buttons with their brand colors
    final defaultButtons = [
      _ShareButtonData(
        icon: _copiedToClipboard ? Icons.check : Icons.copy_rounded,
        action: _copyToClipboard,
        backgroundColor: _copiedToClipboard
            ? MediasfuColors.success
            : MediasfuColors.primary,
        label: _copiedToClipboard ? 'Copied!' : 'Copy',
        tooltip: 'Copy link',
      ),
      _ShareButtonData(
        icon: Icons.email_outlined,
        action: () {
          final emailUrl =
              'mailto:?subject=Join my meeting&body=Here\'s the link: ${getShareUrl()}';
          launchUrl(Uri.parse(emailUrl));
        },
        backgroundColor: const Color(0xFFEA4335), // Gmail red
        label: 'Email',
        tooltip: 'Share via email',
      ),
      _ShareButtonData(
        icon: Icons.facebook,
        action: () {
          final facebookUrl =
              'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(getShareUrl())}';
          launchUrl(Uri.parse(facebookUrl));
        },
        backgroundColor: const Color(0xFF1877F2), // Facebook blue
        label: 'Facebook',
        tooltip: 'Share on Facebook',
      ),
      _ShareButtonData(
        icon: FontAwesomeIcons.whatsapp,
        action: () {
          final whatsappUrl =
              'https://wa.me/?text=${Uri.encodeComponent(getShareUrl())}';
          launchUrl(Uri.parse(whatsappUrl));
        },
        backgroundColor: const Color(0xFF25D366), // WhatsApp green
        label: 'WhatsApp',
        tooltip: 'Share via WhatsApp',
      ),
      _ShareButtonData(
        icon: FontAwesomeIcons.telegram,
        action: () {
          final telegramUrl =
              'https://t.me/share/url?url=${Uri.encodeComponent(getShareUrl())}';
          launchUrl(Uri.parse(telegramUrl));
        },
        backgroundColor: const Color(0xFF0088CC), // Telegram blue
        label: 'Telegram',
        tooltip: 'Share via Telegram',
      ),
    ];

    // Convert custom buttons to _ShareButtonData if provided
    List<_ShareButtonData> buttonsToShow;
    if (widget.options.customButtons != null) {
      buttonsToShow = widget.options.customButtons!
          .where((b) => b.show)
          .map((b) => _ShareButtonData(
                icon: b.icon ?? Icons.share,
                action: b.action,
                backgroundColor: b.backgroundColor ?? MediasfuColors.primary,
                iconColor: b.iconColor,
                label: b.tooltip ?? '',
                tooltip: b.tooltip,
              ))
          .toList();
    } else {
      buttonsToShow = defaultButtons;
    }

    final buttonSize = widget.options.compact ? 44.0 : 52.0;
    final iconSize = widget.options.compact ? 20.0 : 24.0;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: MediasfuSpacing.sm,
      runSpacing: MediasfuSpacing.sm,
      children: buttonsToShow.map((buttonData) {
        return _ModernShareButton(
          buttonData: buttonData,
          buttonSize: buttonSize,
          iconSize: iconSize,
          showLabel: widget.options.showLabels,
          useGlassmorphism: widget.options.useGlassmorphism,
        );
      }).toList(),
    );
  }
}

class _ShareButtonData {
  final IconData icon;
  final VoidCallback action;
  final Color backgroundColor;
  final Color? iconColor;
  final String label;
  final String? tooltip;

  _ShareButtonData({
    required this.icon,
    required this.action,
    required this.backgroundColor,
    this.iconColor,
    this.label = '',
    this.tooltip,
  });
}

class _ModernShareButton extends StatefulWidget {
  final _ShareButtonData buttonData;
  final double buttonSize;
  final double iconSize;
  final bool showLabel;
  final bool useGlassmorphism;

  const _ModernShareButton({
    required this.buttonData,
    required this.buttonSize,
    required this.iconSize,
    required this.showLabel,
    required this.useGlassmorphism,
  });

  @override
  State<_ModernShareButton> createState() => _ModernShareButtonState();
}

class _ModernShareButtonState extends State<_ModernShareButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.buttonData;

    Widget button = ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: data.action,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(widget.buttonSize / 4),
              child: BackdropFilter(
                filter: widget.useGlassmorphism
                    ? ImageFilter.blur(sigmaX: 8, sigmaY: 8)
                    : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: widget.buttonSize,
                  height: widget.buttonSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _isPressed
                            ? data.backgroundColor
                            : data.backgroundColor.withOpacity(0.9),
                        _isPressed
                            ? data.backgroundColor.withOpacity(0.9)
                            : data.backgroundColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(widget.buttonSize / 4),
                    border: Border.all(
                      color: _isPressed
                          ? Colors.white.withOpacity(0.4)
                          : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: data.backgroundColor
                            .withOpacity(_isPressed ? 0.6 : 0.3),
                        blurRadius: _isPressed ? 16 : 8,
                        spreadRadius: _isPressed ? 2 : 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      data.icon,
                      size: widget.iconSize,
                      color: data.iconColor ?? Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.showLabel && data.label.isNotEmpty) ...[
              const SizedBox(height: MediasfuSpacing.xs),
              Text(
                data.label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // Wrap with tooltip if provided
    if (data.tooltip != null && data.tooltip!.isNotEmpty) {
      button = Tooltip(
        message: data.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
