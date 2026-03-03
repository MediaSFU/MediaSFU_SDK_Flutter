import 'package:flutter/foundation.dart';

import '../../utils/image_utils.dart';
import 'package:flutter/material.dart';

const List<int> _defaultWaveformDurations = [
  474,
  433,
  407,
  458,
  400,
  427,
  441,
  419,
  487,
];

class MiniAudioWrapperContext {
  final BuildContext buildContext;
  final MiniAudioOptions options;
  final Offset position;
  final bool isDragging;

  const MiniAudioWrapperContext({
    required this.buildContext,
    required this.options,
    required this.position,
    required this.isDragging,
  });
}

class MiniAudioContainerContext {
  final BuildContext buildContext;
  final MiniAudioOptions options;
  final Offset position;
  final bool isDragging;

  const MiniAudioContainerContext({
    required this.buildContext,
    required this.options,
    required this.position,
    required this.isDragging,
  });
}

class MiniAudioCardContext {
  final BuildContext buildContext;
  final MiniAudioOptions options;
  final bool hasImage;

  const MiniAudioCardContext({
    required this.buildContext,
    required this.options,
    required this.hasImage,
  });
}

class MiniAudioOverlayContext {
  final BuildContext buildContext;
  final MiniAudioOptions options;
  final AlignmentGeometry alignment;

  const MiniAudioOverlayContext({
    required this.buildContext,
    required this.options,
    required this.alignment,
  });
}

class MiniAudioWaveformContext {
  final BuildContext buildContext;
  final MiniAudioOptions options;
  final bool showWaveform;
  final List<Animation<double>> animations;

  const MiniAudioWaveformContext({
    required this.buildContext,
    required this.options,
    required this.showWaveform,
    required this.animations,
  });
}

class MiniAudioNameContext {
  final BuildContext buildContext;
  final MiniAudioOptions options;

  const MiniAudioNameContext({
    required this.buildContext,
    required this.options,
  });
}

class MiniAudioImageContext {
  final BuildContext buildContext;
  final MiniAudioOptions options;
  final bool hasImage;

  const MiniAudioImageContext({
    required this.buildContext,
    required this.options,
    required this.hasImage,
  });
}

typedef MiniAudioWrapperBuilder = Widget Function(
  MiniAudioWrapperContext context,
  Widget defaultWrapper,
);

typedef MiniAudioContainerBuilder = Widget Function(
  MiniAudioContainerContext context,
  Widget defaultContainer,
);

typedef MiniAudioCardBuilder = Widget Function(
  MiniAudioCardContext context,
  Widget defaultCard,
);

typedef MiniAudioOverlayBuilder = Widget Function(
  MiniAudioOverlayContext context,
  Widget defaultOverlay,
);

typedef MiniAudioWaveformBuilder = Widget Function(
  MiniAudioWaveformContext context,
  Widget defaultWaveform,
);

typedef MiniAudioNameBuilder = Widget Function(
  MiniAudioNameContext context,
  Widget defaultName,
);

typedef MiniAudioImageBuilder = Widget Function(
  MiniAudioImageContext context,
  Widget defaultImage,
);

class MiniAudioOptions {
  final bool visible;
  final String name;
  final bool showWaveform;
  final String overlayPosition;
  final Color barColor;
  final Color textColor;
  final TextStyle nameTextStyling;
  final TextAlign nameTextAlign;
  final int? nameMaxLines;
  final BoxDecoration? nameContainerDecoration;
  final EdgeInsetsGeometry? nameContainerPadding;
  final String imageSource;
  final bool roundedImage;
  final BoxFit imageFit;
  final AlignmentGeometry imageAlignment;
  final double width;
  final double height;
  final bool enableDrag;
  final Offset? initialPosition;
  final Duration fadeDuration;
  final bool maintainStateWhenHidden;
  final BoxDecoration? wrapperDecoration;
  final EdgeInsetsGeometry? wrapperPadding;
  final EdgeInsetsGeometry? wrapperMargin;
  final BoxDecoration? containerDecoration;
  final EdgeInsetsGeometry? containerPadding;
  final EdgeInsetsGeometry? containerMargin;
  final BoxDecoration? cardDecoration;
  final EdgeInsetsGeometry? cardPadding;
  final EdgeInsetsGeometry? cardMargin;
  final BorderRadiusGeometry? cardBorderRadius;
  final BoxDecoration? overlayDecoration;
  final EdgeInsetsGeometry? overlayPadding;
  final AlignmentGeometry? overlayAlignment;
  final BoxDecoration? waveformDecoration;
  final EdgeInsetsGeometry? waveformPadding;
  final BoxDecoration? barDecoration;
  final BorderRadiusGeometry? barBorderRadius;
  final double barWidth;
  final double barSpacing;
  final double barMaxHeight;
  final List<int>? waveformDurations;
  final BoxDecoration? customStyle;
  final MiniAudioWrapperBuilder? wrapperBuilder;
  final MiniAudioContainerBuilder? containerBuilder;
  final MiniAudioCardBuilder? cardBuilder;
  final MiniAudioOverlayBuilder? overlayBuilder;
  final MiniAudioWaveformBuilder? waveformBuilder;
  final MiniAudioNameBuilder? nameBuilder;
  final MiniAudioImageBuilder? imageBuilder;
  final ValueChanged<Offset>? onPositionChanged;
  final VoidCallback? onDragStart;
  final ValueChanged<Offset>? onDragUpdate;
  final VoidCallback? onDragEnd;

  const MiniAudioOptions({
    this.visible = true,
    required this.name,
    this.showWaveform = false,
    this.overlayPosition = 'topRight',
    this.barColor = const Color.fromARGB(255, 245, 28, 28),
    this.textColor = const Color.fromARGB(255, 24, 24, 24),
    this.nameTextStyling =
        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    this.nameTextAlign = TextAlign.center,
    this.nameMaxLines,
    this.nameContainerDecoration,
    this.nameContainerPadding,
    this.imageSource = kDefaultMediaSFULogo,
    this.roundedImage = false,
    this.imageFit = BoxFit.cover,
    this.imageAlignment = Alignment.center,
    this.width = 100,
    this.height = 100,
    this.enableDrag = true,
    this.initialPosition,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.maintainStateWhenHidden = false,
    this.wrapperDecoration,
    this.wrapperPadding,
    this.wrapperMargin,
    this.containerDecoration,
    this.containerPadding,
    this.containerMargin,
    this.cardDecoration,
    this.cardPadding,
    this.cardMargin,
    this.cardBorderRadius,
    this.overlayDecoration,
    this.overlayPadding,
    this.overlayAlignment,
    this.waveformDecoration,
    this.waveformPadding,
    this.barDecoration,
    this.barBorderRadius,
    this.barWidth = 8,
    this.barSpacing = 2,
    this.barMaxHeight = 30,
    this.waveformDurations,
    this.customStyle,
    this.wrapperBuilder,
    this.containerBuilder,
    this.cardBuilder,
    this.overlayBuilder,
    this.waveformBuilder,
    this.nameBuilder,
    this.imageBuilder,
    this.onPositionChanged,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });
}

typedef MiniAudioType = Widget Function({required MiniAudioOptions options});

class MiniAudio extends StatefulWidget {
  final MiniAudioOptions options;

  const MiniAudio({super.key, required this.options});

  @override
  State<MiniAudio> createState() => _MiniAudioState();
}

class _MiniAudioState extends State<MiniAudio> with TickerProviderStateMixin {
  late Offset position;
  late List<int> _waveformDurations;
  late List<AnimationController> _waveformControllers;
  late List<Animation<double>> _waveformAnimations;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    position = widget.options.initialPosition ?? const Offset(0, 0);
    _waveformDurations =
        widget.options.waveformDurations ?? _defaultWaveformDurations;
    _initWaveformAnimations();
    if (widget.options.showWaveform) {
      _startWaveformAnimations();
    }
  }

  @override
  void didUpdateWidget(covariant MiniAudio oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newDurations =
        widget.options.waveformDurations ?? _defaultWaveformDurations;
    if (!listEquals(newDurations, _waveformDurations)) {
      _waveformDurations = newDurations;
      _disposeWaveformAnimations();
      _initWaveformAnimations();
    }

    if (widget.options.showWaveform && !oldWidget.options.showWaveform) {
      _startWaveformAnimations();
    } else if (!widget.options.showWaveform && oldWidget.options.showWaveform) {
      _stopWaveformAnimations();
    }

    if (widget.options.initialPosition != null &&
        widget.options.initialPosition != oldWidget.options.initialPosition) {
      position = widget.options.initialPosition!;
    }
  }

  @override
  void dispose() {
    _stopWaveformAnimations();
    _disposeWaveformAnimations();
    super.dispose();
  }

  void _initWaveformAnimations() {
    _waveformControllers = <AnimationController>[];
    _waveformAnimations = <Animation<double>>[];
    for (var i = 0; i < _waveformDurations.length; i++) {
      final durationMs = _waveformDurations[i];
      final safeDuration = durationMs <= 0 ? 400 : durationMs;
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: safeDuration),
      );
      final animation = CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      );
      _waveformControllers.add(controller);
      _waveformAnimations.add(animation);
    }
  }

  void _disposeWaveformAnimations() {
    for (final controller in _waveformControllers) {
      controller.dispose();
    }
    _waveformControllers = <AnimationController>[];
    _waveformAnimations = <Animation<double>>[];
  }

  void _startWaveformAnimations() {
    for (var i = 0; i < _waveformControllers.length; i++) {
      final controller = _waveformControllers[i];
      if (!controller.isAnimating) {
        final phase = i / (_waveformControllers.length + 1);
        controller.value = phase;
        controller.repeat(reverse: true);
      }
    }
  }

  void _stopWaveformAnimations() {
    for (final controller in _waveformControllers) {
      controller.stop();
    }
  }

  void _handlePanStart(DragStartDetails details) {
    if (!widget.options.enableDrag) {
      return;
    }
    setState(() {
      isDragging = true;
    });
    widget.options.onDragStart?.call();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.options.enableDrag) {
      return;
    }
    setState(() {
      position += details.delta;
    });
    widget.options.onPositionChanged?.call(position);
    widget.options.onDragUpdate?.call(position);
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!widget.options.enableDrag) {
      return;
    }
    setState(() {
      isDragging = false;
    });
    widget.options.onDragEnd?.call();
  }

  Widget _buildWaveform(BuildContext context) {
    if (!widget.options.showWaveform) {
      return const SizedBox.shrink();
    }

    // Modern pulsing ring animation around avatar using existing animation controllers
    final List<Widget> rings = [];

    // Use first 3 animation controllers for pulsing rings
    for (int i = 0; i < 3 && i < _waveformAnimations.length; i++) {
      final animation = _waveformAnimations[i];
      rings.add(
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final scale = 1.0 + (animation.value * 0.3 * (i + 1) / 3);
            final opacity = (0.6 - animation.value * 0.5).clamp(0.0, 1.0);
            return Container(
              width: 60 * scale,
              height: 60 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.options.barColor.withOpacity(opacity),
                  width: 2,
                ),
              ),
            );
          },
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: rings,
    );
  }

  Widget _buildName(BuildContext context) {
    final defaultName = Container(
      padding: widget.options.nameContainerPadding ??
          const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      decoration: widget.options.nameContainerDecoration ??
          const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color.fromRGBO(0, 0, 0, 0.8),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
      child: Text(
        widget.options.name,
        textAlign: widget.options.nameTextAlign,
        maxLines: widget.options.nameMaxLines ?? 1,
        overflow: TextOverflow.ellipsis,
        style: widget.options.nameTextStyling.copyWith(
          fontSize: widget.options.nameTextStyling.fontSize ?? 11,
        ),
      ),
    );

    return widget.options.nameBuilder?.call(
          MiniAudioNameContext(
            buildContext: context,
            options: widget.options,
          ),
          defaultName,
        ) ??
        defaultName;
  }

  Widget _buildImage(BuildContext context) {
    final hasImage = widget.options.imageSource.isNotEmpty;
    final borderRadius = widget.options.cardBorderRadius ??
        BorderRadius.circular(widget.options.roundedImage ? 20 : 0);

    final defaultImage = hasImage
        ? ClipRRect(
            borderRadius: borderRadius,
            child: buildMediasfuImage(
              widget.options.imageSource,
              fit: widget.options.imageFit,
            ),
          )
        : _buildInitials();

    return widget.options.imageBuilder?.call(
          MiniAudioImageContext(
            buildContext: context,
            options: widget.options,
            hasImage: hasImage,
          ),
          defaultImage,
        ) ??
        defaultImage;
  }

  Widget _buildInitials() {
    final display = widget.options.name.isNotEmpty
        ? widget.options.name.substring(0, 2).toUpperCase()
        : '';
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
      ),
      child: Center(
        child: Text(
          display,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildMiniAudio(BuildContext overlayContext) {
    if (!widget.options.visible && !widget.options.maintainStateWhenHidden) {
      return const SizedBox.shrink();
    }

    final waveform = _buildWaveform(overlayContext);

    final borderRadius =
        widget.options.cardBorderRadius ?? BorderRadius.circular(12);

    // Modern glassmorphic card styling
    final defaultCard = Container(
      padding: widget.options.cardPadding,
      margin: widget.options.cardMargin,
      decoration: widget.options.cardDecoration ??
          widget.options.customStyle ??
          BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a1a2e),
                Color(0xFF16213e),
              ],
            ),
            borderRadius: borderRadius,
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 0.1),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Centered avatar with pulsing ring animation
            Center(
              child: SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulsing ring animation (shows when waveform is active)
                    if (widget.options.showWaveform) waveform,
                    // Avatar image
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromRGBO(255, 255, 255, 0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _buildImage(overlayContext),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Name at bottom with gradient overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildName(overlayContext),
            ),
          ],
        ),
      ),
    );

    final card = widget.options.cardBuilder?.call(
          MiniAudioCardContext(
            buildContext: overlayContext,
            options: widget.options,
            hasImage: widget.options.imageSource.isNotEmpty,
          ),
          defaultCard,
        ) ??
        defaultCard;

    final animatedContent = AnimatedOpacity(
      opacity: widget.options.visible ? 1.0 : 0.0,
      duration: widget.options.fadeDuration,
      child: SizedBox(
        width: widget.options.width,
        height: widget.options.height,
        child: card,
      ),
    );

    final containerBody = Container(
      padding: widget.options.containerPadding,
      margin: widget.options.containerMargin,
      decoration: widget.options.containerDecoration,
      child: animatedContent,
    );

    final draggable = GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: containerBody,
    );

    final container = widget.options.containerBuilder?.call(
          MiniAudioContainerContext(
            buildContext: overlayContext,
            options: widget.options,
            position: position,
            isDragging: isDragging,
          ),
          draggable,
        ) ??
        draggable;

    final wrapperBody = Container(
      padding: widget.options.wrapperPadding,
      margin: widget.options.wrapperMargin,
      decoration: widget.options.wrapperDecoration,
      child: container,
    );

    final defaultWrapper = widget.options.maintainStateWhenHidden
        ? Visibility(
            visible: widget.options.visible,
            maintainAnimation: true,
            maintainState: true,
            maintainSize: true,
            child: wrapperBody,
          )
        : wrapperBody;

    return widget.options.wrapperBuilder?.call(
          MiniAudioWrapperContext(
            buildContext: overlayContext,
            options: widget.options,
            position: position,
            isDragging: isDragging,
          ),
          defaultWrapper,
        ) ??
        defaultWrapper;
  }

  @override
  Widget build(BuildContext context) {
    return buildMiniAudio(context);
  }
}
