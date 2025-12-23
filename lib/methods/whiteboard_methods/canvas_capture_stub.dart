/// Stub implementation for non-web platforms.
///
/// This file provides placeholder classes for platforms that don't support
/// HTML Canvas captureStream() API. The actual functionality is only
/// available on web platforms.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show MediaStream;

// Re-export for API compatibility
export 'package:flutter_webrtc/flutter_webrtc.dart' show MediaStream;

/// Stub implementation for non-web platforms.
///
/// On non-web platforms, direct canvas-to-MediaStream capture is not available.
/// The annotation broadcasting feature is only supported on web.
class ScreenAnnotationCapture {
  final int _width = 0;
  final int _height = 0;

  /// The combined MediaStream (always null on non-web)
  MediaStream? get processedStream => null;

  /// Whether capture is active (always false on non-web)
  bool get isCapturing => false;

  /// The annotation canvas (null on non-web)
  dynamic get annotationCanvas => null;

  /// Canvas dimensions
  int get width => _width;
  int get height => _height;

  /// Initialize (returns null on non-web as annotation broadcasting is not supported)
  Future<dynamic> initialize(MediaStream localStreamScreen) async {
    debugPrint(
        'ScreenAnnotationCapture: Annotation broadcasting not supported on this platform');
    debugPrint(
        'ScreenAnnotationCapture: Annotations will only be visible locally');
    return null;
  }

  /// Start capture (returns null on non-web)
  Future<MediaStream?> startCapture({int frameRate = 30}) async {
    debugPrint('ScreenAnnotationCapture: Not supported on this platform');
    return null;
  }

  /// Draw to annotation canvas (no-op on non-web)
  void drawToAnnotationCanvas({
    required String type,
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required String color,
    required double thickness,
    String lineType = 'solid',
    List<Map<String, dynamic>>? freehandPoints,
  }) {
    // No-op: annotations only work locally on non-web platforms
  }

  /// Clear annotation canvas (no-op on non-web)
  void clearAnnotationCanvas() {
    // No-op
  }

  /// Redraw shapes (no-op on non-web)
  void redrawShapes(List<Map<String, dynamic>> shapes) {
    // No-op
  }

  /// Stop capture (no-op on non-web)
  void stopCapture() {
    debugPrint('ScreenAnnotationCapture: stopCapture (no-op on this platform)');
  }

  /// Dispose (no-op on non-web)
  void dispose() {
    // No-op
  }
}

/// Legacy class for backward compatibility.
@Deprecated('Use ScreenAnnotationCapture instead')
class WebCanvasCapture {
  bool get isCapturing => false;
  MediaStream? get mediaStream => null;
  void dispose() {}
}

/// Check if web canvas capture is supported (always false on non-web).
bool isWebCanvasCaptureSupported() {
  return false;
}
