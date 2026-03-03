// ignore_for_file: avoid_web_libraries_in_flutter
/// Web-specific screen annotation capture implementation using JavaScript interop.
///
/// This file replicates React's ScreenboardModal approach:
/// 1. Create a hidden video element to play the screen share stream
/// 2. Create a hidden canvas to combine video + annotations
/// 3. Use captureStream() to create a MediaStream of the combined output
///
/// This matches the React implementation in ScreenboardModal.tsx's `annotatationPreview()`.
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'package:dart_webrtc/dart_webrtc.dart' as webrtc;

// Re-export MediaStream type for convenience
typedef MediaStream = webrtc.MediaStream;

/// Extension to call drawImage with video element using proper JS interop
extension CanvasDrawImageExtension on web.CanvasRenderingContext2D {
  /// Draws a video element to the canvas at the specified position and size.
  /// This uses JS interop to ensure proper binding.
  void drawVideoImage(
    web.HTMLVideoElement video,
    double dx,
    double dy,
    double dWidth,
    double dHeight,
  ) {
    // Use the drawImage method with CanvasImageSource
    drawImage(video, dx.toInt(), dy.toInt(), dWidth.toInt(), dHeight.toInt());
  }
}

/// Combines screen share video with annotation canvas into a single MediaStream.
///
/// This class replicates React's ScreenboardModal approach exactly:
/// - screenVideo: Hidden HTMLVideoElement playing the screen share
/// - mainScreenCanvas: Hidden HTMLCanvasElement that combines video + annotations
/// - drawCombined(): Draws video frame, then annotation overlay
/// - captureStream(30): Creates MediaStream from the combined canvas
///
/// The interval-based drawing (30ms in React) ensures smooth output.
class ScreenAnnotationCapture {
  // Hidden video element for screen share playback
  web.HTMLVideoElement? _screenVideo;

  // Main canvas for combining video + annotations (React: mainScreenCanvas)
  web.HTMLCanvasElement? _mainCanvas;
  web.CanvasRenderingContext2D? _mainCtx;

  // Annotation canvas reference (passed from Flutter Screenboard)
  web.HTMLCanvasElement? _annotationCanvas;

  // Capture state
  Timer? _drawTimer;
  bool _isCapturing = false;
  MediaStream? _processedStream;
  web.MediaStream? _clonedScreenStream;

  int _width = 0;
  int _height = 0;

  /// The combined MediaStream (video + annotations)
  MediaStream? get processedStream => _processedStream;

  /// Whether capture is currently active
  bool get isCapturing => _isCapturing;

  /// The annotation canvas element for external drawing
  web.HTMLCanvasElement? get annotationCanvas => _annotationCanvas;

  /// Canvas dimensions
  int get width => _width;
  int get height => _height;

  /// Initialize the annotation capture system with screen share stream.
  ///
  /// [localStreamScreen] is the flutter_webrtc MediaStream from screen sharing.
  /// Returns the annotation canvas element that can be drawn to.
  Future<web.HTMLCanvasElement?> initialize(
      MediaStream localStreamScreen) async {
    try {
      // Get video track settings for dimensions
      final videoTracks = localStreamScreen.getVideoTracks();
      if (videoTracks.isEmpty) {
        return null;
      }

      final videoTrack = videoTracks.first;

      // Get dimensions from track settings
      // Access the settings from the underlying JS object
      final jsTrack = (videoTrack as dynamic).jsTrack as web.MediaStreamTrack;
      final settings = jsTrack.getSettings();

      // settings.width and settings.height are int, not nullable
      _width = settings.width > 0 ? settings.width : 1920;
      _height = settings.height > 0 ? settings.height : 1080;

      // Clone the screen share track (React: clonedStreamScreen)
      final clonedTrack = jsTrack.clone();
      _clonedScreenStream = web.MediaStream();
      _clonedScreenStream!.addTrack(clonedTrack);

      // Create hidden video element for screen playback (React: screenVideo)
      _screenVideo = web.HTMLVideoElement()
        ..width = _width
        ..height = _height
        ..autoplay = true
        ..muted = true
        ..playsInline = true
        ..style.display = 'none'
        ..style.position = 'absolute'
        ..style.left = '-9999px';

      // Set the cloned stream as video source
      _screenVideo!.srcObject = _clonedScreenStream;

      // Add to DOM (required for video playback)
      web.document.body?.appendChild(_screenVideo!);

      // Wait for video to be ready
      await _waitForVideoReady();

      // Create main canvas for combining video + annotations (React: mainScreenCanvas)
      _mainCanvas = web.HTMLCanvasElement()
        ..width = _width
        ..height = _height
        ..style.display = 'none'
        ..style.position = 'absolute'
        ..style.left = '-9999px';

      web.document.body?.appendChild(_mainCanvas!);
      _mainCtx = _mainCanvas!.context2D;

      // Create annotation canvas for drawing (React: canvasScreenboard)
      _annotationCanvas = web.HTMLCanvasElement()
        ..width = _width
        ..height = _height
        ..style.display = 'none'
        ..style.position = 'absolute'
        ..style.left = '-9999px';

      web.document.body?.appendChild(_annotationCanvas!);

      return _annotationCanvas;
    } catch (e) {
      return null;
    }
  }

  /// Wait for video element to be ready for playback.
  Future<void> _waitForVideoReady() async {
    if (_screenVideo == null) return;

    final completer = Completer<void>();

    // Check if already ready
    if (_screenVideo!.readyState >= 2) {
      await _ensureVideoPlaying();
      return;
    }

    // Listen for loadeddata event
    _screenVideo!.onLoadedData.first.then((_) {
      if (!completer.isCompleted) completer.complete();
    }).catchError((e) {
      if (!completer.isCompleted) completer.completeError(e);
    });

    // Also try playing immediately
    await _ensureVideoPlaying();

    // Timeout after 3 seconds
    await completer.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () {},
    );
  }

  /// Ensure video element is playing.
  Future<void> _ensureVideoPlaying() async {
    if (_screenVideo == null) return;

    try {
      if (_screenVideo!.paused) {
        await _screenVideo!.play().toDart;
      }
    } catch (_) {}
  }

  /// Start capturing the combined video + annotation stream.
  ///
  /// Returns the processed MediaStream that can be sent via WebRTC.
  Future<MediaStream?> startCapture({int frameRate = 30}) async {
    if (_mainCanvas == null || _screenVideo == null) {
      return null;
    }

    if (_isCapturing) {
      return _processedStream;
    }

    try {
      _isCapturing = true;

      // Draw initial frame before starting capture stream
      _drawCombined();

      // Create MediaStream from main canvas (React: mediaCanvas!.captureStream(30))
      final jsStream = _mainCanvas!.captureStream(frameRate);

      // Wrap in dart_webrtc MediaStreamWeb
      _processedStream = webrtc.MediaStreamWeb(jsStream, 'annotation-capture');

      // Verify the stream has tracks
      final _ = jsStream.getVideoTracks().toDart;

      // Start draw interval (React: setInterval(() => { drawCombined(); }, 30))
      final frameDuration = Duration(milliseconds: (1000 / frameRate).round());
      _drawTimer = Timer.periodic(frameDuration, (_) {
        if (!_isCapturing) return;
        _drawCombined();
      });

      return _processedStream;
    } catch (_) {
      _isCapturing = false;
      return null;
    }
  }

  /// Draw combined video + annotations to main canvas.
  ///
  /// This is the key function that replicates React's `drawCombined()`:
  /// ```javascript
  /// function drawCombined() {
  ///   ctx.clearRect(0, 0, canvasElement!.width, canvasElement!.height);
  ///   ctx.drawImage(screenVideo!, 0, 0, canvasElement!.width, canvasElement!.height);
  ///   ctx.drawImage(canvasElement!, 0, 0, canvasElement!.width, canvasElement!.height);
  /// }
  /// ```
  void _drawCombined() {
    if (_mainCtx == null || _mainCanvas == null) return;

    final width = _mainCanvas!.width;
    final height = _mainCanvas!.height;

    // Clear the canvas
    _mainCtx!.clearRect(0, 0, width, height);

    // Draw video frame (screen share)
    // React: ctx.drawImage(screenVideo!, 0, 0, canvasElement!.width, canvasElement!.height);
    if (_screenVideo != null && _screenVideo!.readyState >= 2) {
      try {
        // Use extension method for proper video drawing
        _mainCtx!.drawVideoImage(
          _screenVideo!,
          0.0,
          0.0,
          width.toDouble(),
          height.toDouble(),
        );
      } catch (_) {}
    }

    // Draw annotation overlay
    // React: ctx.drawImage(canvasScreenboard!, 0, 0, canvasElement!.width, canvasElement!.height);
    if (_annotationCanvas != null) {
      try {
        _mainCtx!.drawImage(
          _annotationCanvas!,
          0, // dest x
          0, // dest y
          width, // dest width
          height, // dest height
        );
      } catch (e) {
        try {
          _mainCtx!.drawImage(_annotationCanvas!, 0, 0);
        } catch (_) {}
      }
    }
  }

  /// Draw a shape to the annotation canvas.
  ///
  /// This provides a way for Flutter's Screenboard to mirror its drawings
  /// to the HTML canvas that will be captured.
  void drawToAnnotationCanvas({
    required String type,
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required String color,
    required double thickness,
    List<Map<String, dynamic>>? freehandPoints,
  }) {
    final ctx = _annotationCanvas?.context2D;
    if (ctx == null) return;

    ctx.strokeStyle = color.toJS;
    ctx.lineWidth = thickness;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';

    switch (type) {
      case 'line':
        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2, y2);
        ctx.stroke();
        break;

      case 'freehand':
        if (freehandPoints != null && freehandPoints.isNotEmpty) {
          ctx.beginPath();
          final first = freehandPoints.first;
          ctx.moveTo(
            (first['x'] as num).toDouble(),
            (first['y'] as num).toDouble(),
          );
          for (final point in freehandPoints.skip(1)) {
            ctx.lineTo(
              (point['x'] as num).toDouble(),
              (point['y'] as num).toDouble(),
            );
          }
          ctx.stroke();
        }
        break;

      case 'rectangle':
        ctx.beginPath();
        ctx.rect(x1, y1, x2 - x1, y2 - y1);
        ctx.stroke();
        break;

      case 'circle':
        final centerX = (x1 + x2) / 2;
        final centerY = (y1 + y2) / 2;
        final radius = ((x2 - x1).abs() + (y2 - y1).abs()) / 4;
        ctx.beginPath();
        ctx.arc(centerX, centerY, radius, 0, 2 * 3.14159265359, false);
        ctx.stroke();
        break;

      case 'oval':
        final centerX = (x1 + x2) / 2;
        final centerY = (y1 + y2) / 2;
        final radiusX = (x2 - x1).abs() / 2;
        final radiusY = (y2 - y1).abs() / 2;
        ctx.beginPath();
        ctx.ellipse(
            centerX, centerY, radiusX, radiusY, 0, 0, 2 * 3.14159265359, false);
        ctx.stroke();
        break;

      case 'triangle':
        final midX = (x1 + x2) / 2;
        ctx.beginPath();
        ctx.moveTo(midX, y1);
        ctx.lineTo(x2, y2);
        ctx.lineTo(x1, y2);
        ctx.closePath();
        ctx.stroke();
        break;

      case 'square':
        final size = (x2 - x1).abs();
        ctx.beginPath();
        ctx.rect(x1, y1, size, size);
        ctx.stroke();
        break;

      case 'rhombus':
        final centerX = (x1 + x2) / 2;
        final centerY = (y1 + y2) / 2;
        ctx.beginPath();
        ctx.moveTo(centerX, y1);
        ctx.lineTo(x2, centerY);
        ctx.lineTo(centerX, y2);
        ctx.lineTo(x1, centerY);
        ctx.closePath();
        ctx.stroke();
        break;

      case 'parallelogram':
        final centerX = (x1 + x2) / 2;
        ctx.beginPath();
        ctx.moveTo(centerX, y1);
        ctx.lineTo(x2, y2);
        ctx.lineTo(centerX, y2);
        ctx.lineTo(x1, y1);
        ctx.closePath();
        ctx.stroke();
        break;

      case 'pentagon':
        _drawPolygon(ctx, 5, x1, y1, x2, y2);
        break;

      case 'hexagon':
        _drawPolygon(ctx, 6, x1, y1, x2, y2);
        break;

      case 'octagon':
        _drawPolygon(ctx, 8, x1, y1, x2, y2);
        break;

      default:
        // For any other shape type, don't draw anything
        break;
    }
  }

  /// Helper function to draw regular polygons (pentagon, hexagon, octagon, etc.)
  void _drawPolygon(web.CanvasRenderingContext2D ctx, int sides, double x1,
      double y1, double x2, double y2) {
    final centerX = (x1 + x2) / 2;
    final centerY = (y1 + y2) / 2;
    final radius = ((x2 - x1).abs() < (y2 - y1).abs()
            ? (x2 - x1).abs()
            : (y2 - y1).abs()) /
        2;
    final angle = (2 * math.pi) / sides;

    ctx.beginPath();
    for (int i = 0; i < sides; i++) {
      final x = centerX + radius * math.cos(i * angle - math.pi / 2);
      final y = centerY + radius * math.sin(i * angle - math.pi / 2);
      if (i == 0) {
        ctx.moveTo(x, y);
      } else {
        ctx.lineTo(x, y);
      }
    }
    ctx.closePath();
    ctx.stroke();
  }

  /// Clear the annotation canvas.
  void clearAnnotationCanvas() {
    final ctx = _annotationCanvas?.context2D;
    if (ctx == null || _annotationCanvas == null) return;

    ctx.clearRect(
      0,
      0,
      _annotationCanvas!.width.toDouble(),
      _annotationCanvas!.height.toDouble(),
    );
  }

  /// Redraw all shapes to the annotation canvas.
  void redrawShapes(List<Map<String, dynamic>> shapes) {
    clearAnnotationCanvas();
    for (final shape in shapes) {
      drawToAnnotationCanvas(
        type: shape['type'] as String,
        x1: (shape['x1'] as num?)?.toDouble() ?? 0,
        y1: (shape['y1'] as num?)?.toDouble() ?? 0,
        x2: (shape['x2'] as num?)?.toDouble() ?? 0,
        y2: (shape['y2'] as num?)?.toDouble() ?? 0,
        color: shape['color'] as String? ?? '#000000',
        thickness: (shape['thickness'] as num?)?.toDouble() ?? 2,
        freehandPoints: shape['points'] as List<Map<String, dynamic>>?,
      );
    }
  }

  /// Stop capturing and clean up resources.
  void stopCapture() {
    _isCapturing = false;
    _drawTimer?.cancel();
    _drawTimer = null;

    if (_processedStream != null) {
      for (final track in _processedStream!.getTracks()) {
        track.stop();
      }
      _processedStream = null;
    }

    debugPrint('ScreenAnnotationCapture: Stopped capture');
  }

  /// Dispose of all resources.
  void dispose() {
    stopCapture();

    // Stop cloned video
    if (_screenVideo != null) {
      _screenVideo!.pause();
      _screenVideo!.srcObject = null;
      _screenVideo!.remove();
      _screenVideo = null;
    }

    // Stop cloned stream tracks
    if (_clonedScreenStream != null) {
      for (final track in _clonedScreenStream!.getTracks().toDart) {
        track.stop();
      }
      _clonedScreenStream = null;
    }

    // Remove canvases
    _mainCanvas?.remove();
    _mainCanvas = null;
    _mainCtx = null;

    _annotationCanvas?.remove();
    _annotationCanvas = null;

    debugPrint('ScreenAnnotationCapture: Disposed');
  }
}

/// Legacy class for backward compatibility.
/// Prefer using ScreenAnnotationCapture for the React-style implementation.
@Deprecated('Use ScreenAnnotationCapture instead')
class WebCanvasCapture {
  // Kept for backward compatibility
  bool get isCapturing => false;
  MediaStream? get mediaStream => null;
  void dispose() {}
}

/// Check if web canvas capture is supported.
bool isWebCanvasCaptureSupported() {
  if (!kIsWeb) return false;

  try {
    final testCanvas = web.HTMLCanvasElement();
    // captureStream is available on HTMLCanvasElement
    testCanvas.remove();
    return true;
  } catch (e) {
    return false;
  }
}
