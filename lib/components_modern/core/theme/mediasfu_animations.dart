// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// A comprehensive animation system for the modern MediaSFU UI.
///
/// Provides:
/// - Duration constants for consistent timing
/// - Curve presets for various motion types
/// - Spring physics configurations
/// - Stagger utilities for list animations
/// - Tween helpers for common transitions
class MediasfuAnimations {
  MediasfuAnimations._();

  // ═══════════════════════════════════════════════════════════════════════════
  // DURATION CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Instant - For immediate feedback (hover states)
  static const Duration instant = Duration(milliseconds: 50);

  /// Fast - For micro-interactions (ripples, toggles)
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal - Standard transitions (page changes, modal opens)
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow - For emphasis or complex animations
  static const Duration slow = Duration(milliseconds: 500);

  /// Slower - For dramatic reveals
  static const Duration slower = Duration(milliseconds: 700);

  /// Cinematic - For hero animations and page transitions
  static const Duration cinematic = Duration(milliseconds: 1000);

  // ═══════════════════════════════════════════════════════════════════════════
  // CURVE PRESETS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Smooth ease for general purpose animations
  static const Curve smooth = Curves.easeInOutCubic;

  /// Snappy ease for responsive interactions
  static const Curve snappy = Curves.easeOutCubic;

  /// Bounce effect for playful elements
  static const Curve bounce = Curves.elasticOut;

  /// Overshoot for attention-grabbing animations
  static const Curve overshoot = Curves.easeOutBack;

  /// Decelerate for incoming elements
  static const Curve decelerate = Curves.decelerate;

  /// Accelerate for outgoing elements
  static const Curve accelerate = Curves.easeIn;

  /// Anticipate - slight pullback before forward motion
  static const Curve anticipate = Curves.easeInBack;

  /// Linear for constant-speed animations (loading spinners)
  static const Curve linear = Curves.linear;

  /// Material Design emphasized curve for enter
  static const Curve emphasizedEnter = Curves.easeOutExpo;

  /// Material Design emphasized curve for exit
  static const Curve emphasizedExit = Curves.easeInExpo;

  // ═══════════════════════════════════════════════════════════════════════════
  // SPRING PHYSICS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Default spring - balanced responsiveness
  static SpringDescription get defaultSpring => const SpringDescription(
        mass: 1.0,
        stiffness: 300.0,
        damping: 25.0,
      );

  /// Bouncy spring - for playful, elastic effects
  static SpringDescription get bouncySpring => const SpringDescription(
        mass: 1.0,
        stiffness: 350.0,
        damping: 15.0,
      );

  /// Stiff spring - quick and controlled
  static SpringDescription get stiffSpring => const SpringDescription(
        mass: 1.0,
        stiffness: 500.0,
        damping: 35.0,
      );

  /// Gentle spring - slow and smooth
  static SpringDescription get gentleSpring => const SpringDescription(
        mass: 1.5,
        stiffness: 200.0,
        damping: 25.0,
      );

  /// Snappy spring - fast with slight overshoot
  static SpringDescription get snappySpring => const SpringDescription(
        mass: 0.8,
        stiffness: 400.0,
        damping: 20.0,
      );

  /// Creates a spring simulation for physics-based animations.
  static SpringSimulation createSpringSimulation({
    SpringDescription? spring,
    double start = 0.0,
    double end = 1.0,
    double velocity = 0.0,
  }) {
    return SpringSimulation(
      spring ?? defaultSpring,
      start,
      end,
      velocity,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STAGGER UTILITIES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculates stagger delay for list item animations.
  ///
  /// [index] - The item's position in the list
  /// [baseDelay] - The delay between each item (default 50ms)
  /// [maxDelay] - Maximum total delay cap (default 500ms)
  static Duration staggerDelay(
    int index, {
    Duration baseDelay = const Duration(milliseconds: 50),
    Duration maxDelay = const Duration(milliseconds: 500),
  }) {
    final calculated = baseDelay * index;
    return calculated > maxDelay ? maxDelay : calculated;
  }

  /// Calculates stagger interval for use with AnimationController.
  ///
  /// [index] - The item's position
  /// [totalItems] - Total number of items
  /// [overlapRatio] - How much animations overlap (0.0-1.0)
  static Interval staggerInterval(
    int index,
    int totalItems, {
    double overlapRatio = 0.5,
  }) {
    if (totalItems <= 1) return const Interval(0.0, 1.0);

    final segmentLength = 1.0 / totalItems;
    final overlap = segmentLength * overlapRatio;

    final start = (index * segmentLength * (1 - overlapRatio)).clamp(0.0, 1.0);
    final end = (start + segmentLength + overlap).clamp(0.0, 1.0);

    return Interval(start, end, curve: smooth);
  }

  /// Creates a cascading stagger effect configuration.
  static List<Interval> cascadeIntervals(
    int itemCount, {
    double staggerAmount = 0.1,
    Curve curve = Curves.easeOutCubic,
  }) {
    return List.generate(itemCount, (index) {
      final start = (index * staggerAmount).clamp(0.0, 0.9);
      final end = (start + (1.0 - start)).clamp(start, 1.0);
      return Interval(start, end, curve: curve);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fade in animation
  static Animation<double> fadeIn(AnimationController controller) {
    return CurvedAnimation(
      parent: controller,
      curve: smooth,
    );
  }

  /// Fade out animation
  static Animation<double> fadeOut(AnimationController controller) {
    return CurvedAnimation(
      parent: controller,
      curve: accelerate,
    );
  }

  /// Scale up animation (0.0 to 1.0)
  static Animation<double> scaleUp(
    AnimationController controller, {
    double from = 0.8,
    double to = 1.0,
  }) {
    return Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: controller, curve: overshoot),
    );
  }

  /// Scale down animation
  static Animation<double> scaleDown(
    AnimationController controller, {
    double from = 1.0,
    double to = 0.95,
  }) {
    return Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: controller, curve: snappy),
    );
  }

  /// Slide from bottom animation
  static Animation<Offset> slideFromBottom(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: smooth));
  }

  /// Slide from top animation
  static Animation<Offset> slideFromTop(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: smooth));
  }

  /// Slide from left animation
  static Animation<Offset> slideFromLeft(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: smooth));
  }

  /// Slide from right animation
  static Animation<Offset> slideFromRight(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: smooth));
  }

  /// Rotation animation
  static Animation<double> rotate(
    AnimationController controller, {
    double turns = 1.0,
  }) {
    return Tween<double>(begin: 0, end: turns).animate(
      CurvedAnimation(parent: controller, curve: smooth),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TRANSITION PRESETS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Modal enter transition configuration
  static AnimationConfig get modalEnter => const AnimationConfig(
        duration: normal,
        curve: Curves.easeOutCubic,
        fadeFrom: 0.0,
        fadeTo: 1.0,
        scaleFrom: 0.95,
        scaleTo: 1.0,
        slideFrom: Offset(0, 0.05),
        slideTo: Offset.zero,
      );

  /// Modal exit transition configuration
  static AnimationConfig get modalExit => const AnimationConfig(
        duration: fast,
        curve: Curves.easeInCubic,
        fadeFrom: 1.0,
        fadeTo: 0.0,
        scaleFrom: 1.0,
        scaleTo: 0.95,
        slideFrom: Offset.zero,
        slideTo: Offset(0, 0.05),
      );

  /// Page enter transition configuration
  static AnimationConfig get pageEnter => const AnimationConfig(
        duration: normal,
        curve: Curves.easeOutCubic,
        fadeFrom: 0.0,
        fadeTo: 1.0,
        scaleFrom: 1.0,
        scaleTo: 1.0,
        slideFrom: Offset(0.1, 0),
        slideTo: Offset.zero,
      );

  /// Toast notification enter configuration
  static AnimationConfig get toastEnter => const AnimationConfig(
        duration: fast,
        curve: Curves.easeOutBack,
        fadeFrom: 0.0,
        fadeTo: 1.0,
        scaleFrom: 0.8,
        scaleTo: 1.0,
        slideFrom: Offset(0, -0.2),
        slideTo: Offset.zero,
      );

  /// Button press feedback configuration
  static AnimationConfig get buttonPress => const AnimationConfig(
        duration: instant,
        curve: Curves.easeOut,
        fadeFrom: 1.0,
        fadeTo: 1.0,
        scaleFrom: 1.0,
        scaleTo: 0.95,
        slideFrom: Offset.zero,
        slideTo: Offset.zero,
      );

  /// Hover scale configuration
  static AnimationConfig get hoverScale => const AnimationConfig(
        duration: fast,
        curve: Curves.easeOut,
        fadeFrom: 1.0,
        fadeTo: 1.0,
        scaleFrom: 1.0,
        scaleTo: 1.02,
        slideFrom: Offset.zero,
        slideTo: Offset.zero,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // PULSE & HEARTBEAT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a pulsing animation for attention-grabbing effects.
  static Animation<double> pulse(
    AnimationController controller, {
    double minScale = 1.0,
    double maxScale = 1.05,
  }) {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: minScale, end: maxScale)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: maxScale, end: minScale)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(controller);
  }

  /// Creates a heartbeat animation (two quick pulses).
  static Animation<double> heartbeat(AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween:
            Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 40,
      ),
    ]).animate(controller);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHIMMER UTILITIES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a shimmer gradient animation alignment.
  static Animation<Alignment> shimmerAlignment(
    AnimationController controller,
  ) {
    return TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(-1.5, -0.3),
          end: const Alignment(1.5, 0.3),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(controller);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ANIMATION CONFIG CLASS
// ═════════════════════════════════════════════════════════════════════════════

/// Configuration class for complex multi-property animations.
class AnimationConfig {
  final Duration duration;
  final Curve curve;
  final double fadeFrom;
  final double fadeTo;
  final double scaleFrom;
  final double scaleTo;
  final Offset slideFrom;
  final Offset slideTo;

  const AnimationConfig({
    required this.duration,
    required this.curve,
    this.fadeFrom = 0.0,
    this.fadeTo = 1.0,
    this.scaleFrom = 1.0,
    this.scaleTo = 1.0,
    this.slideFrom = Offset.zero,
    this.slideTo = Offset.zero,
  });

  /// Creates animations from this config using the given controller.
  AnimatedValues animate(AnimationController controller) {
    final curvedAnimation = CurvedAnimation(parent: controller, curve: curve);

    return AnimatedValues(
      fade:
          Tween<double>(begin: fadeFrom, end: fadeTo).animate(curvedAnimation),
      scale: Tween<double>(begin: scaleFrom, end: scaleTo)
          .animate(curvedAnimation),
      slide: Tween<Offset>(begin: slideFrom, end: slideTo)
          .animate(curvedAnimation),
    );
  }
}

/// Container for multiple animation values.
class AnimatedValues {
  final Animation<double> fade;
  final Animation<double> scale;
  final Animation<Offset> slide;

  const AnimatedValues({
    required this.fade,
    required this.scale,
    required this.slide,
  });
}

// ═════════════════════════════════════════════════════════════════════════════
// ANIMATION MIXIN FOR STATEFUL WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

/// Mixin that provides common animation controller setup.
mixin AnimationControllerMixin<T extends StatefulWidget> on State<T>
    implements TickerProvider {
  late AnimationController _animationController;

  AnimationController get animationController => _animationController;

  @protected
  void initAnimationController({
    Duration duration = MediasfuAnimations.normal,
    double? lowerBound,
    double? upperBound,
  }) {
    _animationController = AnimationController(
      vsync: this,
      duration: duration,
      lowerBound: lowerBound ?? 0.0,
      upperBound: upperBound ?? 1.0,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ANIMATED VALUE WRAPPER
// ═════════════════════════════════════════════════════════════════════════════

/// A simple value notifier with smooth animation transitions.
class AnimatedValue<T> extends ChangeNotifier {
  T _value;
  T? _targetValue;
  final Duration duration;
  final Curve curve;

  AnimatedValue(
    this._value, {
    this.duration = MediasfuAnimations.normal,
    this.curve = MediasfuAnimations.smooth,
  });

  T get value => _value;
  T? get targetValue => _targetValue;

  set value(T newValue) {
    if (_value != newValue) {
      _targetValue = newValue;
      _value = newValue;
      notifyListeners();
    }
  }

  void animateTo(T newValue) {
    _targetValue = newValue;
    notifyListeners();
  }
}
