import 'dart:async';

import 'package:flutter/material.dart';

import '../../components/display_components/alert_component.dart'
    show
        AlertComponentOptions,
        AlertContentContext,
        AlertMessageContext,
        AlertOverlayContext,
        AlertTapCallback;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/theme/mediasfu_typography.dart';
import '../core/widgets/glassmorphic_container.dart';

/// Modern redesigned AlertComponent with glassmorphic styling, premium animations,
/// and glow effects for success/error states.
class ModernAlertComponent extends StatefulWidget {
  final AlertComponentOptions options;

  const ModernAlertComponent({super.key, required this.options});

  @override
  State<ModernAlertComponent> createState() => _ModernAlertComponentState();
}

class _ModernAlertComponentState extends State<ModernAlertComponent>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────────────────────────────────
  String _alertType = 'success';
  Timer? _dismissTimer;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _alertType = widget.options.type;
    _maybeScheduleDismiss();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250), // Faster for toast
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Slide from top-right for toast effect (horizontal offset for non-intrusive positioning)
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.5, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _glowAnim = Tween<double>(begin: 0.2, end: 0.4).animate(
      // Subtler glow
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.options.visible) {
      _slideController.forward();
      _fadeController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ModernAlertComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.type != oldWidget.options.type) {
      _updateAlertType();
    }
    if (widget.options.visible != oldWidget.options.visible ||
        widget.options.duration != oldWidget.options.duration) {
      _maybeScheduleDismiss();
    }
    if (widget.options.visible && !oldWidget.options.visible) {
      _slideController.forward(from: 0);
      _fadeController.forward(from: 0);
    } else if (!widget.options.visible && oldWidget.options.visible) {
      _slideController.reverse();
      _fadeController.reverse();
    }
  }

  void _updateAlertType() {
    final String nextType = widget.options.type;
    if (_alertType != nextType) {
      setState(() {
        _alertType = nextType;
      });
    }
  }

  void _maybeScheduleDismiss() {
    _dismissTimer?.cancel();
    if (widget.options.visible && widget.options.duration > 0) {
      _dismissTimer = Timer(
        Duration(milliseconds: widget.options.duration),
        _dismiss,
      );
    }
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    widget.options.onHide?.call();
  }

  bool _invokeTap(AlertTapCallback? callback) {
    if (callback == null) return true;
    try {
      return callback();
    } catch (_) {
      return true;
    }
  }

  void _handleContentTap() {
    final bool shouldDismiss = _invokeTap(widget.options.onContentTap);
    if (shouldDismiss && widget.options.contentDismissible) {
      _dismiss();
    }
  }

  void _handleOverlayTap() {
    final bool shouldDismiss = _invokeTap(widget.options.onOverlayTap);
    if (shouldDismiss && widget.options.overlayDismissible) {
      _dismiss();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _slideController.dispose();
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MODERN UI BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = MediasfuTypography.textTheme(darkMode: isDark);

    final String normalizedType = _alertType.toLowerCase();
    final bool isDanger =
        normalizedType == 'danger' || normalizedType == 'error';

    final Color tintColor =
        isDanger ? MediasfuColors.danger : MediasfuColors.success;
    final Color glowColor = tintColor;

    final IconData icon =
        isDanger ? Icons.error_outline : Icons.check_circle_outline;

    // Animated icon with glow
    final Widget iconWidget = AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tintColor.withValues(alpha: 0.15),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: _glowAnim.value * 0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: tintColor, size: 24),
        );
      },
    );

    // Message widget with gradient text for success
    final Widget baseMessage = isDanger
        ? Text(
            options.message,
            style: textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: options.messageAlignment,
            maxLines: options.messageMaxLines,
            overflow:
                options.messageMaxLines != null ? TextOverflow.ellipsis : null,
          )
        : Text(
            options.message,
            style: textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: options.messageAlignment,
            maxLines: options.messageMaxLines,
            overflow:
                options.messageMaxLines != null ? TextOverflow.ellipsis : null,
          );

    final Widget messageWidget = options.messageBuilder?.call(
          AlertMessageContext(options: options, defaultMessage: baseMessage),
        ) ??
        baseMessage;

    // Content segments
    final List<Widget> segments = <Widget>[
      iconWidget,
      const SizedBox(width: MediasfuSpacing.md),
      Expanded(child: messageWidget),
    ];

    if (options.trailing != null) {
      segments.add(const SizedBox(width: MediasfuSpacing.sm));
      segments.add(options.trailing!);
    }

    // Content row
    Widget contentRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: segments,
    );

    if (options.actions != null && options.actions!.isNotEmpty) {
      contentRow = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          contentRow,
          const SizedBox(height: MediasfuSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: options.actions!,
          ),
        ],
      );
    }

    // Premium glass container with colored border accent - toast style
    Widget contentNode = AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: _glowAnim.value * 0.25),
                blurRadius: 16,
                spreadRadius: 0,
              ),
              // Subtle drop shadow for depth
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Stack(
        children: [
          GlassmorphicContainer(
            padding: MediasfuSpacing.insetSymmetric(
              horizontal: MediasfuSpacing.md,
              vertical: MediasfuSpacing.sm,
            ),
            borderRadius: 14,
            blur: 12,
            child: contentRow,
          ),
          // Colored accent line at left (toast style)
          Positioned(
            top: 8,
            bottom: 8,
            left: 0,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: tintColor,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Apply custom content builder if provided
    if (options.contentBuilder != null) {
      contentNode = options.contentBuilder!(
        AlertContentContext(
          options: options,
          defaultContent: contentNode,
          message: messageWidget,
        ),
      );
    }

    // Tap handler
    final bool enableContentTap =
        options.contentDismissible || options.onContentTap != null;
    if (enableContentTap) {
      contentNode = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleContentTap,
        child: contentNode,
      );
    }

    // Position and constraints
    final double maxWidth = options.maxWidth ?? 420;
    final double minWidth = options.minWidth ?? 0;

    final Widget overlayContent = SafeArea(
      child: Align(
        alignment: options.overlayAlignment,
        child: Padding(
          padding: options.overlayPadding ??
              MediasfuSpacing.insetAll(MediasfuSpacing.lg),
          child: AnimatedBuilder(
            animation: Listenable.merge([_slideAnim, _scaleAnim]),
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnim,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: child,
                ),
              );
            },
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
              child: contentNode,
            ),
          ),
        ),
      ),
    );

    // Very light/transparent backdrop - allows seeing content underneath
    // For toast-like alerts, we use minimal backdrop or none
    Widget overlay = Stack(
      clipBehavior: Clip.none,
      children: [
        // Very subtle/transparent backdrop - almost invisible
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _handleOverlayTap,
            child: AnimatedBuilder(
              animation: _fadeAnim,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnim.value * 0.3, // Even more transparent
                  child: child,
                );
              },
              // No blur, just very light tint for toast effect
              child: Container(
                color: Colors.transparent, // Fully transparent backdrop
              ),
            ),
          ),
        ),
        overlayContent,
      ],
    );

    Widget defaultOverlay = SizedBox.expand(child: overlay);

    if (options.overlayBuilder != null) {
      defaultOverlay = options.overlayBuilder!(
        AlertOverlayContext(
          options: options,
          defaultOverlay: defaultOverlay,
          content: contentNode,
        ),
      );
    }

    return IgnorePointer(
      ignoring: !options.visible,
      child: defaultOverlay,
    );
  }
}

/// Convenience builder conforming to AlertComponentType signature.
Widget modernAlertComponentBuilder({required AlertComponentOptions options}) {
  return ModernAlertComponent(options: options);
}
