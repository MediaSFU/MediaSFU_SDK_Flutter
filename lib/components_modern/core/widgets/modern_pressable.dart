import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/mediasfu_animations.dart';

/// Whether this platform has a pointer that can hover.
///
/// Resolved once at startup so the hover plumbing costs nothing on phones,
/// where it can never fire.
final bool kHasHover = kIsWeb ||
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.linux;

/// The interaction primitive for the modern components.
///
/// Most interactive surfaces in this tree are a bare [GestureDetector] with no
/// visual response at all — the difference between an interface that feels
/// responsive and one that feels inert. This adds press-scale, hover-lift and
/// haptics to any child.
///
/// [child] is handed to the implicit animation widgets by reference, so the
/// subtree short-circuits on every state change and only this widget's own
/// (tiny) build runs. Callers that need to restyle their own decoration on
/// interaction pass [onStateChanged] and keep the expensive part of their tree
/// in a `child` of their own, rather than rebuilding it here.
///
/// ```dart
/// ModernPressable(
///   onTap: _send,
///   child: Container(...),
/// )
/// ```
class ModernPressable extends StatefulWidget {
  const ModernPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.hoverLift = 2.0,
    this.haptic = true,
    this.enabled = true,
    this.cursor = SystemMouseCursors.click,
    this.onStateChanged,
    this.behavior = HitTestBehavior.opaque,
    this.semanticLabel,
    this.isButton = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Scale applied while the pointer is down. 1.0 disables the effect.
  final double pressedScale;

  /// Pixels the surface rises on hover. 0 disables the effect.
  final double hoverLift;

  final bool haptic;
  final bool enabled;
  final MouseCursor cursor;
  final HitTestBehavior behavior;

  /// Called whenever hover or press state changes, so a parent can animate its
  /// own decoration without owning the gesture plumbing.
  final void Function(bool hovered, bool pressed)? onStateChanged;

  final String? semanticLabel;
  final bool isButton;

  @override
  State<ModernPressable> createState() => _ModernPressableState();
}

class _ModernPressableState extends State<ModernPressable> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _update({bool? hovered, bool? pressed}) {
    final bool nextHovered = hovered ?? _hovered;
    final bool nextPressed = pressed ?? _pressed;
    if (nextHovered == _hovered && nextPressed == _pressed) return;
    setState(() {
      _hovered = nextHovered;
      _pressed = nextPressed;
    });
    widget.onStateChanged?.call(_hovered, _pressed);
  }

  void _handleTap() {
    if (!_interactive) return;
    if (widget.haptic) HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final double scale =
        (!_interactive || reduced) ? 1.0 : (_pressed ? widget.pressedScale : 1.0);
    final double lift = (!_interactive || reduced || !kHasHover)
        ? 0.0
        : (_hovered && !_pressed ? -widget.hoverLift : 0.0);

    // The child is passed through both animated widgets rather than rebuilt.
    Widget result = AnimatedScale(
      scale: scale,
      duration: MediasfuAnimations.instant,
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: Offset(0, lift / 100),
        duration: MediasfuAnimations.fast,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );

    result = GestureDetector(
      behavior: widget.behavior,
      onTap: _interactive ? _handleTap : null,
      onLongPress: _interactive ? widget.onLongPress : null,
      onTapDown: _interactive ? (_) => _update(pressed: true) : null,
      onTapUp: _interactive ? (_) => _update(pressed: false) : null,
      onTapCancel: _interactive ? () => _update(pressed: false) : null,
      child: result,
    );

    if (kHasHover && _interactive) {
      result = MouseRegion(
        cursor: widget.cursor,
        onEnter: (_) => _update(hovered: true),
        onExit: (_) => _update(hovered: false, pressed: false),
        child: result,
      );
    }

    if (widget.semanticLabel != null || widget.isButton) {
      result = Semantics(
        label: widget.semanticLabel,
        button: widget.isButton,
        enabled: _interactive,
        child: result,
      );
    }

    return result;
  }
}
