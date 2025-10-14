import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../types/types.dart' show EventType;

/// Configuration options for the `CardVideoDisplay` widget.
///
/// Defines video stream rendering behavior, styling, and builder hooks for a WebRTC video player.
/// This component handles RTCVideoRenderer lifecycle, stream attachment, video track polling,
/// and layered content (placeholder, video, overlay).
///
/// **Properties:**
/// - `remoteProducerId`: Unique identifier for the remote producer (used for tracking/logging)
/// - `eventType`: Type of video event (e.g., EventType.conference, EventType.webinar) for context-specific behavior
/// - `forceFullDisplay`: Video scaling mode (true = cover/crop to fill; false = contain/letterbox)
/// - `videoStream`: MediaStream containing video tracks to render (null = no video)
/// - `backgroundColor`: Background color visible when no video or during loading (defaults to Colors.transparent)
/// - `doMirror`: Horizontal flip for local camera preview (true = mirror effect; false = normal)
/// - `padding`: Inner padding around video content
/// - `margin`: Outer margin around container
/// - `decoration`: BoxDecoration for borders, gradients, shadows (merged with backgroundColor)
/// - `clipBehavior`: Clipping strategy (auto-detected from decoration if null: antiAlias for rounded corners, none otherwise)
/// - `alignment`: Content alignment within container (defaults to Alignment.center)
/// - `constraints`: Size constraints for container (e.g., BoxConstraints.expand(), BoxConstraints.tightFor(width: 320))
/// - `placeholder`: Widget shown when streamReady=false (e.g., loading spinner, avatar, "Video Off" text)
/// - `overlay`: Widget always layered on top of video (e.g., name badge, audio indicator, controls)
/// - `containerBuilder`: Hook to wrap Container with dimensions/styling (receives child content, streamReady state)
/// - `videoBuilder`: Hook to customize RTCVideoView rendering (receives renderer, streamReady state)
/// - `maintainRendererOnNullStream`: Keep last frame when stream becomes null (true = retain; false = clear srcObject)
/// - `streamPollInterval`: Polling interval for checking video track availability when stream has no tracks (defaults to 120ms)
///
/// **Stream Attachment Logic:**
/// ```
/// if (videoStream == null) {
///   if (!maintainRendererOnNullStream) {
///     renderer.srcObject = null; // clear video
///   }
///   streamReady = false;
/// } else if (videoStream.getVideoTracks().isNotEmpty) {
///   renderer.srcObject = videoStream; // attach stream
///   streamReady = true;
/// } else {
///   streamReady = false;
///   startPolling(); // wait for tracks to become available
/// }
/// ```
///
/// **Video Scaling Modes:**
/// - `forceFullDisplay = true`: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover (crop to fill, no letterbox)
/// - `forceFullDisplay = false`: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain (scale to fit, may letterbox)
///
/// **Layered Content Structure:**
/// ```
/// Stack
///   ├─ Positioned.fill → RTCVideoView (always present)
///   ├─ Positioned.fill → placeholder (if streamReady=false and placeholder!=null)
///   └─ Positioned.fill → overlay (if overlay!=null, always visible)
/// ```
///
/// **Builder Hook Flow:**
/// ```
/// 1. Build RTCVideoView with mirror/objectFit
/// 2. videoBuilder?(renderer, streamReady) → videoSurface
/// 3. Create Stack with videoSurface + placeholder + overlay
/// 4. Wrap in Container with decoration/padding/alignment
/// 5. containerBuilder?(content, streamReady) → final widget
/// ```
///
/// **Common Configurations:**
/// ```dart
/// // 1. Basic remote participant video (contain mode)
/// CardVideoDisplayOptions(
///   remoteProducerId: participant.videoId,
///   eventType: EventType.conference,
///   forceFullDisplay: false, // contain with letterbox
///   videoStream: participant.stream,
///   backgroundColor: Colors.black,
///   placeholder: Center(
///     child: CircularProgressIndicator(),
///   ),
/// )
///
/// // 2. Local camera preview (mirrored, cover mode)
/// CardVideoDisplayOptions(
///   remoteProducerId: 'local_camera',
///   eventType: EventType.conference,
///   forceFullDisplay: true, // cover/crop
///   videoStream: localStream,
///   backgroundColor: Colors.grey[900]!,
///   doMirror: true, // horizontal flip
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(12),
///     border: Border.all(color: Colors.blue, width: 2),
///   ),
///   overlay: Positioned(
///     top: 8,
///     right: 8,
///     child: Icon(Icons.videocam, color: Colors.white),
///   ),
/// )
///
/// // 3. Screenshare display with custom placeholder
/// CardVideoDisplayOptions(
///   remoteProducerId: presenter.screenId,
///   eventType: EventType.conference,
///   forceFullDisplay: false, // contain for aspect ratio preservation
///   videoStream: screenshareStream,
///   backgroundColor: Colors.black,
///   placeholder: Center(
///     child: Column(
///       mainAxisSize: MainAxisSize.min,
///       children: [
///         Icon(Icons.screen_share, size: 64, color: Colors.white54),
///         SizedBox(height: 16),
///         Text('Waiting for screenshare...', style: TextStyle(color: Colors.white54)),
///       ],
///     ),
///   ),
///   maintainRendererOnNullStream: true, // keep last frame
/// )
///
/// // 4. Picture-in-picture mini player
/// CardVideoDisplayOptions(
///   remoteProducerId: participant.videoId,
///   eventType: EventType.conference,
///   forceFullDisplay: true,
///   videoStream: participant.stream,
///   backgroundColor: Colors.black,
///   doMirror: false,
///   constraints: BoxConstraints.tightFor(width: 160, height: 120),
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(8),
///     boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)],
///   ),
///   overlay: Positioned(
///     bottom: 4,
///     left: 4,
///     child: Container(
///       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
///       decoration: BoxDecoration(
///         color: Colors.black54,
///         borderRadius: BorderRadius.circular(4),
///       ),
///       child: Text(
///         participant.name,
///         style: TextStyle(color: Colors.white, fontSize: 10),
///       ),
///     ),
///   ),
/// )
/// ```
///
/// **Typical Use Cases:**
/// - Remote participant video rendering
/// - Local camera preview with mirror effect
/// - Screenshare display
/// - Picture-in-picture mini player
/// - Video tiles in gallery grid

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

/// A stateful widget rendering WebRTC video streams with advanced lifecycle management.
///
/// Handles RTCVideoRenderer initialization, MediaStream attachment, video track polling,
/// and layered content rendering (placeholder, video, overlay). Automatically detects
/// video track availability and polls for tracks when stream exists but has no tracks.
///
/// **Lifecycle & State Management:**
/// - Creates RTCVideoRenderer in `initState()` and initializes asynchronously
/// - Attaches stream in `_attachStream()` after renderer initialization
/// - Monitors stream changes in `didUpdateWidget()` (detects stream replacement or track availability changes)
/// - Polls for video tracks when stream exists but getVideoTracks() is empty
/// - Disposes renderer and cancels polling timer in `dispose()`
/// - Tracks `_streamReady` boolean (true when stream has video tracks and is attached)
///
/// **Stream Attachment Flow:**
/// ```
/// 1. _attachStream(stream) called
/// 2. Cancel any active polling timer
/// 3. Check stream status:
///    - If stream == null:
///      - If !maintainRendererOnNullStream: renderer.srcObject = null
///      - Set streamReady = false
///    - If stream has video tracks:
///      - renderer.srcObject = stream
///      - Set streamReady = true
///    - If stream has no video tracks:
///      - Set streamReady = false
///      - Start polling timer to check again later
/// 4. setState() if streamReady changed
/// ```
///
/// **Video Track Polling:**
/// - Triggered when stream exists but getVideoTracks().isEmpty
/// - Polls at `streamPollInterval` (default 120ms, min 60ms)
/// - Continues until tracks detected or stream changes
/// - Useful for streams where tracks are added asynchronously
/// - Automatically cancelled when stream changes or widget disposes
///
/// **Widget Update Detection:**
/// ```dart
/// // Stream replacement:
/// if (newStream != oldStream) { _attachStream(newStream); }
///
/// // Track availability change (e.g., track added/removed):
/// if (oldStream.hasVideoTracks != newStream.hasVideoTracks) {
///   _attachStream(newStream);
/// }
/// ```
///
/// **Rendering Pipeline:**
/// ```
/// 1. _buildVideoSurface():
///    - Create RTCVideoView with mirror/objectFit settings
///    - Call videoBuilder hook (if provided)
///
/// 2. _buildLayeredContent():
///    - Positioned.fill → videoSurface (always present)
///    - Positioned.fill → placeholder (if !streamReady and placeholder!=null)
///    - Positioned.fill → overlay (if overlay!=null)
///    - Wrap in Stack(fit: StackFit.expand)
///
/// 3. _buildContainer():
///    - Wrap layeredContent in Container with:
///      - margin, padding, alignment, constraints
///      - decoration (merged with backgroundColor)
///      - clipBehavior (auto-detected from decoration)
///    - Call containerBuilder hook (if provided)
/// ```
///
/// **Clip Behavior Auto-Detection:**
/// ```dart
/// if (clipBehavior provided) {
///   use clipBehavior;
/// } else if (decoration has borderRadius or non-rectangle shape) {
///   use Clip.antiAlias; // smooth rounded corners
/// } else {
///   use Clip.none; // no clipping overhead
/// }
/// ```
///
/// **Common Use Cases:**
/// 1. **Remote Participant Video:**
///    ```dart
///    CardVideoDisplay(
///      options: CardVideoDisplayOptions(
///        remoteProducerId: participant.videoId,
///        eventType: EventType.conference,
///        forceFullDisplay: false, // contain mode
///        videoStream: participant.stream,
///        backgroundColor: Colors.black,
///        placeholder: Center(
///          child: Column(
///            mainAxisSize: MainAxisSize.min,
///            children: [
///              MiniCard(options: MiniCardOptions(
///                initials: participant.name[0],
///                fontSize: 32,
///              )),
///              SizedBox(height: 8),
///              Text(
///                participant.name,
///                style: TextStyle(color: Colors.white),
///              ),
///            ],
///          ),
///        ),
///        overlay: Positioned(
///          bottom: 8,
///          left: 8,
///          child: participant.muted
///              ? Icon(Icons.mic_off, color: Colors.red, size: 20)
///              : SizedBox.shrink(),
///        ),
///      ),
///    )
///    ```
///
/// 2. **Local Camera Preview (Mirrored):**
///    ```dart
///    CardVideoDisplay(
///      options: CardVideoDisplayOptions(
///        remoteProducerId: 'local_camera',
///        eventType: EventType.conference,
///        forceFullDisplay: true, // cover mode
///        videoStream: localStream,
///        backgroundColor: Colors.grey[900]!,
///        doMirror: true, // horizontal flip for natural preview
///        decoration: BoxDecoration(
///          borderRadius: BorderRadius.circular(12),
///          border: Border.all(color: Colors.blue, width: 2),
///        ),
///        constraints: BoxConstraints.tightFor(width: 200, height: 150),
///        overlay: Positioned(
///          top: 8,
///          right: 8,
///          child: Container(
///            padding: EdgeInsets.all(4),
///            decoration: BoxDecoration(
///              color: Colors.black54,
///              borderRadius: BorderRadius.circular(4),
///            ),
///            child: Text(
///              'You',
///              style: TextStyle(color: Colors.white, fontSize: 12),
///            ),
///          ),
///        ),
///      ),
///    )
///    ```
///
/// 3. **Screenshare Display:**
///    ```dart
///    CardVideoDisplay(
///      options: CardVideoDisplayOptions(
///        remoteProducerId: presenter.screenId,
///        eventType: EventType.conference,
///        forceFullDisplay: false, // contain to preserve aspect ratio
///        videoStream: screenshareStream,
///        backgroundColor: Colors.black,
///        placeholder: Center(
///          child: Column(
///            mainAxisSize: MainAxisSize.min,
///            children: [
///              Icon(Icons.screen_share, size: 80, color: Colors.white38),
///              SizedBox(height: 16),
///              Text(
///                'Waiting for screenshare...',
///                style: TextStyle(color: Colors.white54, fontSize: 16),
///              ),
///            ],
///          ),
///        ),
///        maintainRendererOnNullStream: true, // keep last frame on disconnect
///        streamPollInterval: Duration(milliseconds: 100), // check frequently
///      ),
///    )
///    ```
///
/// 4. **Gallery Grid Tile:**
///    ```dart
///    CardVideoDisplay(
///      options: CardVideoDisplayOptions(
///        remoteProducerId: participant.videoId,
///        eventType: EventType.conference,
///        forceFullDisplay: true, // cover for uniform grid
///        videoStream: participant.stream,
///        backgroundColor: Colors.grey[850]!,
///        decoration: BoxDecoration(
///          border: participant.isSpeaking
///              ? Border.all(color: Colors.green, width: 3)
///              : null,
///        ),
///        placeholder: Center(
///          child: MiniCard(
///            options: MiniCardOptions(
///              initials: participant.name.substring(0, 2).toUpperCase(),
///              fontSize: 24,
///              customStyle: BoxDecoration(
///                color: Colors.blueGrey,
///                shape: BoxShape.circle,
///              ),
///            ),
///          ),
///        ),
///        overlay: Stack(
///          children: [
///            // Name badge at bottom
///            Positioned(
///              bottom: 8,
///              left: 8,
///              right: 8,
///              child: Container(
///                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
///                decoration: BoxDecoration(
///                  color: Colors.black54,
///                  borderRadius: BorderRadius.circular(4),
///                ),
///                child: Text(
///                  participant.name,
///                  style: TextStyle(color: Colors.white, fontSize: 12),
///                  overflow: TextOverflow.ellipsis,
///                ),
///              ),
///            ),
///            // Mute indicator at top-right
///            if (participant.muted)
///              Positioned(
///                top: 8,
///                right: 8,
///                child: Container(
///                  padding: EdgeInsets.all(4),
///                  decoration: BoxDecoration(
///                    color: Colors.red,
///                    shape: BoxShape.circle,
///                  ),
///                  child: Icon(Icons.mic_off, color: Colors.white, size: 16),
///                ),
///              ),
///          ],
///        ),
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Integrates with `MediasfuUICustomOverrides` for global styling:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   cardVideoDisplayOptions: ComponentOverride<CardVideoDisplayOptions>(
///     builder: (existingOptions) => CardVideoDisplayOptions(
///       remoteProducerId: existingOptions.remoteProducerId,
///       eventType: existingOptions.eventType,
///       forceFullDisplay: existingOptions.forceFullDisplay,
///       videoStream: existingOptions.videoStream,
///       backgroundColor: Colors.grey[900]!,
///       decoration: BoxDecoration(
///         borderRadius: BorderRadius.circular(8),
///         border: Border.all(color: Colors.white24),
///       ),
///       placeholder: Center(
///         child: CircularProgressIndicator(color: Colors.blue),
///       ),
///     ),
///   ),
/// ),
/// ```
///
/// **Performance Notes:**
/// - Stateful widget (maintains _renderer, _pollTimer, _streamReady)
/// - RTCVideoRenderer initialized once per lifecycle
/// - Stream attachment only when stream/tracks change (not every frame)
/// - Polling timer cancelled immediately on stream change (no redundant timers)
/// - setState() called only when _streamReady changes (efficient rebuilds)
/// - Builder hooks called during every build (not cached)
///
/// **Implementation Details:**
/// - Uses flutter_webrtc RTCVideoRenderer for native video rendering
/// - Checks mounted before setState() to prevent errors after dispose
/// - Stream polling uses single-shot Timer (not periodic) to avoid overlap
/// - Track availability checked via getVideoTracks().isNotEmpty
/// - Decoration merges with backgroundColor (decoration.color takes precedence)
/// - Placeholder uses IgnorePointer to pass touches through to video
/// - Overlay receives all pointer events (not IgnorePointer)
///
/// **Typical Usage Context:**
/// - Video conferencing participant tiles
/// - Local camera preview
/// - Screenshare display
/// - Picture-in-picture mini player
/// - Gallery grid video cells
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
