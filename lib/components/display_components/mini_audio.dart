import 'package:flutter/foundation.dart';
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

AlignmentGeometry _alignmentFromPosition(String position) {
  switch (position) {
    case 'topLeft':
      return Alignment.topLeft;
    case 'topRight':
      return Alignment.topRight;
    case 'bottomLeft':
      return Alignment.bottomLeft;
    case 'bottomRight':
      return Alignment.bottomRight;
    default:
      return Alignment.topRight;
  }
}

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
    this.imageSource = 'https://mediasfu.com/images/logo192.png',
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
  late OverlayEntry overlayEntry;
  late Offset position;
  late List<int> _waveformDurations;
  late List<AnimationController> _waveformControllers;
  late List<Animation<double>> _waveformAnimations;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    position = widget.options.initialPosition ?? const Offset(50, 50);
    _waveformDurations =
        widget.options.waveformDurations ?? _defaultWaveformDurations;
    _initWaveformAnimations();
    if (widget.options.showWaveform) {
      _startWaveformAnimations();
    }
    overlayEntry = OverlayEntry(builder: (context) => buildMiniAudio(context));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlayState = Overlay.maybeOf(context);
      if (mounted && overlayState != null) {
        overlayState.insert(overlayEntry);
      }
    });
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
    } else if (!widget.options.showWaveform &&
        oldWidget.options.showWaveform) {
      _stopWaveformAnimations();
    }

    if (widget.options.initialPosition != null &&
        widget.options.initialPosition != oldWidget.options.initialPosition) {
      position = widget.options.initialPosition!;
    }

    overlayEntry.markNeedsBuild();
  }

  @override
  void dispose() {
    _stopWaveformAnimations();
    _disposeWaveformAnimations();
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
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
      overlayEntry.markNeedsBuild();
    });
    widget.options.onDragStart?.call();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.options.enableDrag) {
      return;
    }
    setState(() {
      position += details.delta;
      overlayEntry.markNeedsBuild();
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
      overlayEntry.markNeedsBuild();
    });
    widget.options.onDragEnd?.call();
  }

  Widget _buildWaveform(BuildContext context) {
    if (!widget.options.showWaveform) {
      return const SizedBox.shrink();
    }

    final barDecoration = widget.options.barDecoration ??
        BoxDecoration(
          color: widget.options.barColor,
          borderRadius:
              widget.options.barBorderRadius ?? BorderRadius.circular(3),
        );

    final bars = List<Widget>.generate(_waveformAnimations.length, (index) {
      final animation = _waveformAnimations[index];
      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final percent = animation.value.clamp(0.0, 1.0);
          final height = (widget.options.barMaxHeight * percent)
              .clamp(1.0, widget.options.barMaxHeight);
          return Container(
            width: widget.options.barWidth,
            height: height,
            margin: EdgeInsets.symmetric(
              horizontal: widget.options.barSpacing / 2,
            ),
            decoration: barDecoration,
          );
        },
      );
    });

    final defaultWaveform = Container(
      padding: widget.options.waveformPadding,
      decoration: widget.options.waveformDecoration ??
          const BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 0.05),
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: bars,
      ),
    );

    return widget.options.waveformBuilder?.call(
          MiniAudioWaveformContext(
            buildContext: context,
            options: widget.options,
            showWaveform: widget.options.showWaveform,
            animations: _waveformAnimations,
          ),
          defaultWaveform,
        ) ??
        defaultWaveform;
  }

  Widget _buildName(BuildContext context) {
    final defaultName = Container(
      padding: widget.options.nameContainerPadding ??
          const EdgeInsets.symmetric(vertical: 3),
      decoration: widget.options.nameContainerDecoration ??
          const BoxDecoration(
            color: Color(0x80000000),
          ),
      child: Text(
        widget.options.name,
        textAlign: widget.options.nameTextAlign,
        maxLines: widget.options.nameMaxLines ?? 1,
        overflow: TextOverflow.ellipsis,
        style: widget.options.nameTextStyling,
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
            child: Image.network(
              widget.options.imageSource,
              fit: widget.options.imageFit,
              alignment: widget.options.imageAlignment,
              errorBuilder: (_, __, ___) => _buildInitials(),
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
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Center(
        child: Text(
          display,
          style: TextStyle(
            fontSize: 20,
            color: widget.options.textColor,
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

    final alignment =
        widget.options.overlayAlignment ??
            _alignmentFromPosition(widget.options.overlayPosition);

    final waveform = _buildWaveform(overlayContext);
    final overlay = widget.options.overlayBuilder?.call(
          MiniAudioOverlayContext(
            buildContext: overlayContext,
            options: widget.options,
            alignment: alignment,
          ),
          Align(
            alignment: alignment,
            child: Container(
              padding: widget.options.overlayPadding,
              decoration: widget.options.overlayDecoration,
              child: waveform,
            ),
          ),
        ) ??
        Align(
          alignment: alignment,
          child: Container(
            padding: widget.options.overlayPadding,
            decoration: widget.options.overlayDecoration,
            child: waveform,
          ),
        );

    final borderRadius = widget.options.cardBorderRadius ??
        BorderRadius.circular(widget.options.roundedImage ? 20 : 0);

    final defaultCard = Container(
      padding: widget.options.cardPadding,
      margin: widget.options.cardMargin,
      decoration: widget.options.cardDecoration ??
          widget.options.customStyle ??
          BoxDecoration(
            color: const Color(0xFF2C678F),
            borderRadius: borderRadius,
          ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: _buildImage(overlayContext)),
            if (widget.options.showWaveform) overlay,
            Positioned(
              left: 0,
              right: 0,
              top: 0,
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

    final defaultWrapper = Positioned(
      left: position.dx,
      top: position.dy,
      child: widget.options.maintainStateWhenHidden
          ? Visibility(
              visible: widget.options.visible,
              maintainAnimation: true,
              maintainState: true,
              maintainSize: true,
              child: wrapperBody,
            )
          : wrapperBody,
    );

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
    return const SizedBox.shrink();
  }
}
