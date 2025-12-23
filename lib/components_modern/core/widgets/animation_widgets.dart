// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import '../theme/mediasfu_animations.dart';

/// A widget that animates its children with staggered delays.
///
/// Each child fades in and slides up in sequence, creating an elegant
/// cascading effect. Commonly used for lists, menus, and modal content.
///
/// Example usage:
/// ```dart
/// StaggeredAnimationList(
///   children: [
///     Text('First item'),
///     Text('Second item'),
///     Text('Third item'),
///   ],
/// )
/// ```
class StaggeredAnimationList extends StatefulWidget {
  /// The list of widgets to animate.
  final List<Widget> children;

  /// Delay between each child animation.
  final Duration staggerDelay;

  /// Duration of each child's animation.
  final Duration itemDuration;

  /// Animation curve.
  final Curve curve;

  /// Vertical offset for slide animation.
  final double slideOffset;

  /// Whether to animate on first build.
  final bool animateOnInit;

  /// Whether to play animations.
  final bool enabled;

  /// Main axis alignment for the column.
  final MainAxisAlignment mainAxisAlignment;

  /// Cross axis alignment for the column.
  final CrossAxisAlignment crossAxisAlignment;

  /// Main axis size for the column.
  final MainAxisSize mainAxisSize;

  /// Spacing between children.
  final double spacing;

  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.itemDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
    this.slideOffset = 20.0,
    this.animateOnInit = true,
    this.enabled = true,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.spacing = 0,
  });

  @override
  State<StaggeredAnimationList> createState() => _StaggeredAnimationListState();
}

class _StaggeredAnimationListState extends State<StaggeredAnimationList>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    if (widget.animateOnInit && widget.enabled) {
      _playAnimations();
    }
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        vsync: this,
        duration: widget.itemDuration,
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: widget.curve),
      );
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: Offset(0, widget.slideOffset),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: widget.curve),
      );
    }).toList();
  }

  Future<void> _playAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(widget.staggerDelay);
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  /// Trigger animations programmatically.
  void animate() => _playAnimations();

  /// Reset all animations.
  void reset() {
    for (var controller in _controllers) {
      controller.reset();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return Column(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        mainAxisSize: widget.mainAxisSize,
        children: _buildChildrenWithSpacing(widget.children),
      );
    }

    return Column(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisSize: widget.mainAxisSize,
      children: _buildAnimatedChildren(),
    );
  }

  List<Widget> _buildAnimatedChildren() {
    final List<Widget> items = [];
    for (int i = 0; i < widget.children.length; i++) {
      items.add(
        AnimatedBuilder(
          animation: _controllers[i],
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimations[i].value,
              child: Transform.translate(
                offset: _slideAnimations[i].value,
                child: widget.children[i],
              ),
            );
          },
        ),
      );
      if (widget.spacing > 0 && i < widget.children.length - 1) {
        items.add(SizedBox(height: widget.spacing));
      }
    }
    return items;
  }

  List<Widget> _buildChildrenWithSpacing(List<Widget> children) {
    if (widget.spacing <= 0) return children;
    final List<Widget> items = [];
    for (int i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(SizedBox(height: widget.spacing));
      }
    }
    return items;
  }
}

/// A widget that animates a single child with slide and fade animation.
class AnimatedEntry extends StatefulWidget {
  /// The child widget.
  final Widget child;

  /// Delay before animation starts.
  final Duration delay;

  /// Animation duration.
  final Duration duration;

  /// Animation curve.
  final Curve curve;

  /// Slide direction and distance.
  final Offset slideOffset;

  /// Whether to animate on first build.
  final bool animateOnInit;

  /// Whether animations are enabled.
  final bool enabled;

  const AnimatedEntry({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
    this.slideOffset = const Offset(0, 20),
    this.animateOnInit = true,
    this.enabled = true,
  });

  @override
  State<AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<AnimatedEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.animateOnInit && widget.enabled) {
      _playAnimation();
    } else if (!widget.enabled) {
      _controller.value = 1.0;
    }
  }

  Future<void> _playAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) {
      _controller.forward();
    }
  }

  /// Trigger animation programmatically.
  void animate() => _playAnimation();

  /// Reset animation.
  void reset() => _controller.reset();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// A widget that provides a scale + fade animation for modals.
class AnimatedModal extends StatefulWidget {
  /// The modal content.
  final Widget child;

  /// Whether the modal is visible.
  final bool isVisible;

  /// Animation duration.
  final Duration duration;

  /// Animation curve.
  final Curve curve;

  /// Starting scale value.
  final double startScale;

  /// Alignment for scale transform.
  final Alignment scaleAlignment;

  /// Callback when close animation completes.
  final VoidCallback? onDismissed;

  const AnimatedModal({
    super.key,
    required this.child,
    required this.isVisible,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOutCubic,
    this.startScale = 0.92,
    this.scaleAlignment = Alignment.center,
    this.onDismissed,
  });

  @override
  State<AnimatedModal> createState() => _AnimatedModalState();
}

class _AnimatedModalState extends State<AnimatedModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(begin: widget.startScale, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && widget.onDismissed != null) {
        widget.onDismissed!();
      }
    });

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            alignment: widget.scaleAlignment,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// A shimmer animation effect for loading states.
class ShimmerEffect extends StatefulWidget {
  /// The child widget to apply shimmer to.
  final Widget child;

  /// Duration of one shimmer cycle.
  final Duration duration;

  /// Base color for shimmer.
  final Color baseColor;

  /// Highlight color for shimmer.
  final Color highlightColor;

  /// Whether shimmer is active.
  final bool isActive;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0x1AFFFFFF),
    this.highlightColor = const Color(0x40FFFFFF),
    this.isActive = true,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ShimmerEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// A widget that animates between two children with a crossfade effect.
class AnimatedCrossfade extends StatelessWidget {
  /// First child.
  final Widget firstChild;

  /// Second child.
  final Widget secondChild;

  /// Whether to show the second child.
  final bool showSecond;

  /// Animation duration.
  final Duration duration;

  /// Animation curve.
  final Curve curve;

  const AnimatedCrossfade({
    super.key,
    required this.firstChild,
    required this.secondChild,
    required this.showSecond,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      child: showSecond
          ? KeyedSubtree(key: const ValueKey('second'), child: secondChild)
          : KeyedSubtree(key: const ValueKey('first'), child: firstChild),
    );
  }
}

/// A widget that bounces in when first displayed.
class BounceIn extends StatefulWidget {
  /// The child widget.
  final Widget child;

  /// Animation delay.
  final Duration delay;

  /// Animation duration.
  final Duration duration;

  /// Whether to animate on init.
  final bool animateOnInit;

  const BounceIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.animateOnInit = true,
  });

  @override
  State<BounceIn> createState() => _BounceInState();
}

class _BounceInState extends State<BounceIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.animateOnInit) {
      _playAnimation();
    }
  }

  Future<void> _playAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Opacity(
            opacity: _animation.value.clamp(0.0, 1.0),
            child: widget.child,
          ),
        );
      },
    );
  }
}
