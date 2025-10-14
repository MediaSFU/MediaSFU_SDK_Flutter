import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../types/types.dart' show EventType;

/// CardVideoDisplayOptions - Configuration options for the `CardVideoDisplay` widget.
///
/// Example:
/// ```dart
/// CardVideoDisplayOptions(
///   remoteProducerId: 'remote_producer_123',
///   eventType: 'video_event',
///   forceFullDisplay: true,
///   videoStream: myVideoStream,
///   backgroundColor: Colors.black,
///   doMirror: true,
/// )
/// ```

/// Provides context data when building a custom container for [CardVideoDisplay].
class CardVideoDisplayContainerContext {
  final CardVideoDisplayOptions options;
  final bool streamReady;
  final Widget child;
  final Widget defaultContainer;

  CardVideoDisplayContainerContext({
    required this.options,
    required this.streamReady,
    required this.child,
    required this.defaultContainer,
  });
}

/// Provides context data when building a custom video surface for [CardVideoDisplay].
class CardVideoDisplayVideoContext {
  final CardVideoDisplayOptions options;
  final RTCVideoRenderer renderer;
  final bool streamReady;
  final Widget defaultVideo;

  CardVideoDisplayVideoContext({
    required this.options,
    required this.renderer,
    required this.streamReady,
    required this.defaultVideo,
  });
}

typedef CardVideoDisplayContainerBuilder = Widget Function(
  CardVideoDisplayContainerContext context,
);

typedef CardVideoDisplayVideoBuilder = Widget Function(
  CardVideoDisplayVideoContext context,
);

class CardVideoDisplayOptions {
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
  final CardVideoDisplayContainerBuilder? containerBuilder;
  final CardVideoDisplayVideoBuilder? videoBuilder;
  final bool maintainRendererOnNullStream;
  final Duration streamPollInterval;

  CardVideoDisplayOptions({
    required this.remoteProducerId,
    required this.eventType,
    required this.forceFullDisplay,
    required this.videoStream,
    this.backgroundColor = Colors.transparent,
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
  });
}

typedef CardVideoDisplayType = Widget Function({
  required CardVideoDisplayOptions options,
});

/// CardVideoDisplay - A widget to display video streams in a card format based on [CardVideoDisplayOptions].
///
/// Example:
/// ```dart
/// CardVideoDisplay(
///   options: CardVideoDisplayOptions(
///     remoteProducerId: 'remote_producer_123',
///     eventType: 'video_event',
///     forceFullDisplay: true,
///     videoStream: myVideoStream,
///     backgroundColor: Colors.black,
///     doMirror: true,
///   ),
/// )
/// ```
///
class CardVideoDisplay extends StatefulWidget {
  final CardVideoDisplayOptions options;

  const CardVideoDisplay({super.key, required this.options});

  @override
  _CardVideoDisplayState createState() => _CardVideoDisplayState();
}

class _CardVideoDisplayState extends State<CardVideoDisplay> {
  late RTCVideoRenderer _renderer;
  Timer? _pollTimer;
  bool _streamReady = false;

  @override
  void initState() {
    super.initState();
    _renderer = RTCVideoRenderer();
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    await _renderer.initialize();
    if (!mounted) {
      return;
    }
    _attachStream(widget.options.videoStream);
  }

  @override
  void didUpdateWidget(covariant CardVideoDisplay oldWidget) {
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
      }
    } else {
      if (_streamReady) {
        setState(() {
          _streamReady = false;
        });
      }
      _schedulePolling();
    }
  }

  void _schedulePolling() {
    final Duration interval = widget.options.streamPollInterval;
    final Duration effectiveInterval =
        interval <= Duration.zero ? const Duration(milliseconds: 60) : interval;

    _pollTimer = Timer(effectiveInterval, () {
      if (!mounted) {
        return;
      }
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
        CardVideoDisplayVideoContext(
          options: options,
          renderer: _renderer,
          streamReady: _streamReady,
          defaultVideo: defaultVideo,
        ),
      );
    }

    return defaultVideo;
  }

  Widget _buildLayeredContent(Widget videoSurface) {
    final options = widget.options;
    final bool showPlaceholder = options.placeholder != null && !_streamReady;
    final bool hasOverlay = options.overlay != null;

    if (!showPlaceholder && !hasOverlay) {
      return videoSurface;
    }

    final List<Widget> children = <Widget>[
      Positioned.fill(child: videoSurface),
    ];

    if (showPlaceholder) {
      children.add(
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: options.placeholder!,
          ),
        ),
      );
    }

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

    final BoxDecoration decoration =
        (options.decoration ?? const BoxDecoration()).copyWith(
      color: options.decoration?.color ?? options.backgroundColor,
    );

    final Clip effectiveClip = options.clipBehavior ??
        ((decoration.borderRadius != null ||
                decoration.shape != BoxShape.rectangle)
            ? Clip.antiAlias
            : Clip.none);

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
        CardVideoDisplayContainerContext(
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
    final Widget videoSurface = _buildVideoSurface();
    final Widget layeredContent = _buildLayeredContent(videoSurface);
    return _buildContainer(layeredContent);
  }
}
