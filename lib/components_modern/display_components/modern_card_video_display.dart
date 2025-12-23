import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../types/types.dart' show EventType;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

/// Provides context data when building a custom container for [ModernCardVideoDisplay].
class ModernCardVideoDisplayContainerContext {
  final ModernCardVideoDisplayOptions options;
  final bool streamReady;
  final Widget child;
  final Widget defaultContainer;

  ModernCardVideoDisplayContainerContext({
    required this.options,
    required this.streamReady,
    required this.child,
    required this.defaultContainer,
  });
}

/// Provides context data when building a custom video surface for [ModernCardVideoDisplay].
class ModernCardVideoDisplayVideoContext {
  final ModernCardVideoDisplayOptions options;
  final RTCVideoRenderer renderer;
  final bool streamReady;
  final Widget defaultVideo;

  ModernCardVideoDisplayVideoContext({
    required this.options,
    required this.renderer,
    required this.streamReady,
    required this.defaultVideo,
  });
}

typedef ModernCardVideoDisplayContainerBuilder = Widget Function(
  ModernCardVideoDisplayContainerContext context,
);

typedef ModernCardVideoDisplayVideoBuilder = Widget Function(
  ModernCardVideoDisplayVideoContext context,
);

/// Configuration options for the modern `CardVideoDisplay` widget.
///
/// Features modern glassmorphic styling with animated transitions,
/// gradient overlays, and refined visual feedback.
class ModernCardVideoDisplayOptions {
  final String remoteProducerId;
  final EventType eventType;
  final bool forceFullDisplay;
  final MediaStream? videoStream;
  final Color backgroundColor;
  final bool doMirror;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final Clip? clipBehavior;
  final AlignmentGeometry alignment;
  final BoxConstraints? constraints;
  final Widget? placeholder;
  final Widget? overlay;
  final ModernCardVideoDisplayContainerBuilder? containerBuilder;
  final ModernCardVideoDisplayVideoBuilder? videoBuilder;
  final bool maintainRendererOnNullStream;
  final Duration streamPollInterval;

  // Modern styling options
  final double borderRadius;
  final bool enableGlassmorphism;
  final bool showLoadingIndicator;
  final bool showGradientOverlay;
  final Gradient? gradientOverlay;
  final bool isDarkMode;
  final bool animateTransitions;
  final Duration transitionDuration;

  ModernCardVideoDisplayOptions({
    required this.remoteProducerId,
    required this.eventType,
    required this.forceFullDisplay,
    required this.videoStream,
    this.backgroundColor = const Color(0xFF1A1A2E),
    this.doMirror = false,
    this.padding,
    this.margin,
    this.decoration,
    this.clipBehavior,
    this.alignment = Alignment.center,
    this.constraints,
    this.placeholder,
    this.overlay,
    this.containerBuilder,
    this.videoBuilder,
    this.maintainRendererOnNullStream = false,
    this.streamPollInterval = const Duration(milliseconds: 120),
    // Modern defaults
    this.borderRadius = 16.0,
    this.enableGlassmorphism = true,
    this.showLoadingIndicator = true,
    this.showGradientOverlay = false,
    this.gradientOverlay,
    this.isDarkMode = true,
    this.animateTransitions = true,
    this.transitionDuration = const Duration(milliseconds: 300),
  });
}

typedef ModernCardVideoDisplayType = Widget Function({
  required ModernCardVideoDisplayOptions options,
});

/// A modern video display widget with glassmorphic styling and smooth animations.
///
/// Features:
/// - Glassmorphic placeholder with blur effects
/// - Smooth fade transitions when video becomes ready
/// - Animated loading indicator
/// - Gradient overlay support
/// - Dark/light mode theming
/// - WebRTC video stream rendering
class ModernCardVideoDisplay extends StatefulWidget {
  final ModernCardVideoDisplayOptions options;

  const ModernCardVideoDisplay({super.key, required this.options});

  @override
  State<ModernCardVideoDisplay> createState() => _ModernCardVideoDisplayState();
}

class _ModernCardVideoDisplayState extends State<ModernCardVideoDisplay>
    with SingleTickerProviderStateMixin {
  late RTCVideoRenderer _renderer;
  Timer? _pollTimer;
  bool _streamReady = false;
  bool _isInitialized = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _renderer = RTCVideoRenderer();

    _fadeController = AnimationController(
      duration: widget.options.transitionDuration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _initRenderer();
  }

  Future<void> _initRenderer() async {
    await _renderer.initialize();
    if (!mounted) return;

    setState(() {
      _isInitialized = true;
    });

    _attachStream(widget.options.videoStream);
  }

  @override
  void didUpdateWidget(covariant ModernCardVideoDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final MediaStream? newStream = widget.options.videoStream;
    final MediaStream? oldStream = oldWidget.options.videoStream;

    if (newStream != oldStream) {
      _attachStream(newStream);
    } else if (_trackAvailabilityChanged(oldStream, newStream)) {
      _attachStream(newStream);
    }
  }

  bool _trackAvailabilityChanged(MediaStream? previous, MediaStream? current) {
    final bool prevHasTracks = previous?.getVideoTracks().isNotEmpty ?? false;
    final bool currHasTracks = current?.getVideoTracks().isNotEmpty ?? false;
    return prevHasTracks != currHasTracks;
  }

  void _attachStream(MediaStream? stream) {
    _cancelPolling();

    if (stream == null) {
      if (!widget.options.maintainRendererOnNullStream) {
        _renderer.srcObject = null;
      }
      if (_streamReady) {
        setState(() {
          _streamReady = false;
        });
        if (widget.options.animateTransitions) {
          _fadeController.reverse();
        }
      }
      return;
    }

    final bool hasTracks = stream.getVideoTracks().isNotEmpty;

    if (hasTracks) {
      if (_renderer.srcObject != stream) {
        _renderer.srcObject = stream;
      }
      if (!_streamReady) {
        setState(() {
          _streamReady = true;
        });
        if (widget.options.animateTransitions) {
          _fadeController.forward();
        }
      }
    } else {
      if (_streamReady) {
        setState(() {
          _streamReady = false;
        });
        if (widget.options.animateTransitions) {
          _fadeController.reverse();
        }
      }
      _schedulePolling();
    }
  }

  void _schedulePolling() {
    final Duration interval = widget.options.streamPollInterval;
    final Duration effectiveInterval =
        interval <= Duration.zero ? const Duration(milliseconds: 60) : interval;

    _pollTimer = Timer(effectiveInterval, () {
      if (!mounted) return;
      final MediaStream? stream = widget.options.videoStream;
      if (stream != null && stream.getVideoTracks().isNotEmpty) {
        _attachStream(stream);
      } else {
        _schedulePolling();
      }
    });
  }

  void _cancelPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _cancelPolling();
    _fadeController.dispose();
    _renderer.dispose();
    super.dispose();
  }

  Widget _buildVideoSurface() {
    final options = widget.options;

    final Widget defaultVideo = RTCVideoView(
      _renderer,
      mirror: options.doMirror,
      objectFit: options.forceFullDisplay
          ? RTCVideoViewObjectFit.RTCVideoViewObjectFitCover
          : RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    );

    if (options.videoBuilder != null) {
      return options.videoBuilder!(
        ModernCardVideoDisplayVideoContext(
          options: options,
          renderer: _renderer,
          streamReady: _streamReady,
          defaultVideo: defaultVideo,
        ),
      );
    }

    return defaultVideo;
  }

  Widget _buildModernPlaceholder() {
    final options = widget.options;

    return ClipRRect(
      borderRadius: BorderRadius.circular(options.borderRadius),
      child: BackdropFilter(
        filter: options.enableGlassmorphism
            ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: options.isDarkMode
                  ? [
                      const Color(0xFF2D2D44),
                      const Color(0xFF1A1A2E),
                    ]
                  : [
                      const Color(0xFFF5F5F5),
                      const Color(0xFFE0E0E0),
                    ],
            ),
            border: Border.all(
              color: (options.isDarkMode ? Colors.white : Colors.black)
                  .withValues(alpha: 0.1),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (options.showLoadingIndicator && !_streamReady) ...[
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        MediasfuColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: MediasfuSpacing.md),
                  Text(
                    'Connecting...',
                    style: TextStyle(
                      color: (options.isDarkMode ? Colors.white : Colors.black)
                          .withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayeredContent(Widget videoSurface) {
    final options = widget.options;
    final bool showPlaceholder = !_streamReady;
    final bool hasOverlay = options.overlay != null;
    final bool hasGradientOverlay = options.showGradientOverlay;

    final List<Widget> children = <Widget>[
      // Video surface
      Positioned.fill(child: videoSurface),
    ];

    // Placeholder with fade animation
    if (options.animateTransitions) {
      children.add(
        Positioned.fill(
          child: FadeTransition(
            opacity:
                Tween<double>(begin: 1.0, end: 0.0).animate(_fadeAnimation),
            child: IgnorePointer(
              ignoring: _streamReady,
              child: options.placeholder ?? _buildModernPlaceholder(),
            ),
          ),
        ),
      );
    } else if (showPlaceholder) {
      children.add(
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: options.placeholder ?? _buildModernPlaceholder(),
          ),
        ),
      );
    }

    // Gradient overlay
    if (hasGradientOverlay && _streamReady) {
      children.add(
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Container(
              decoration: BoxDecoration(
                gradient: options.gradientOverlay ??
                    LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                      stops: const [0.6, 1.0],
                    ),
              ),
            ),
          ),
        ),
      );
    }

    // Custom overlay
    if (hasOverlay) {
      children.add(
        Positioned.fill(child: options.overlay!),
      );
    }

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: children,
    );
  }

  Widget _buildContainer(Widget content) {
    final options = widget.options;

    BoxDecoration decoration = options.decoration ??
        BoxDecoration(
          color: options.backgroundColor,
          borderRadius: BorderRadius.circular(options.borderRadius),
          border: Border.all(
            color: (options.isDarkMode ? Colors.white : Colors.black)
                .withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );

    final Clip effectiveClip = options.clipBehavior ?? Clip.antiAlias;

    Widget container = Container(
      margin: options.margin,
      padding: options.padding,
      alignment: options.alignment,
      constraints: options.constraints,
      decoration: decoration,
      clipBehavior: effectiveClip,
      child: content,
    );

    if (options.containerBuilder != null) {
      container = options.containerBuilder!(
        ModernCardVideoDisplayContainerContext(
          options: options,
          streamReady: _streamReady,
          child: content,
          defaultContainer: container,
        ),
      );
    }

    return container;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildContainer(_buildModernPlaceholder());
    }

    final Widget videoSurface = _buildVideoSurface();
    final Widget layeredContent = _buildLayeredContent(videoSurface);
    return _buildContainer(layeredContent);
  }
}
