/// Stub Segmenter - Fallback for Unsupported Platforms
///
/// This implementation is used on platforms where ML-based segmentation
/// is not available (Web, Windows, macOS, Linux).
///
/// It returns the original frame without processing, allowing the app
/// to run without crashes while gracefully degrading functionality.
///
/// Note: On Android/iOS, use `segmenter_mobile.dart` directly with
/// conditional imports in your app's build configuration.

library;

import 'package:flutter/foundation.dart';
import '../virtual_background_types.dart';
import 'segmenter_interface.dart';

/// Stub implementation that returns frames unprocessed.
///
/// Used as fallback when:
/// - Platform doesn't support ML Kit (desktop, web)
/// - ML Kit package not installed
/// - Segmentation explicitly disabled
class StubSegmenter implements BackgroundSegmenterBase {
  bool _isReady = false;
  bool _warningShown = false;

  @override
  Future<void> initialize([
    SegmenterConfig config = const SegmenterConfig(),
  ]) async {
    if (!_warningShown && kDebugMode) {
      debugPrint(
        '⚠️ StubSegmenter: Virtual backgrounds not supported on this platform.\n'
        '   Supported platforms: Android, iOS (with google_mlkit_selfie_segmentation)',
      );
      _warningShown = true;
    }
    _isReady = true;
  }

  @override
  Future<SegmentationResult> processFrame(
    Uint8List frameData,
    SegmenterInputMetadata metadata,
  ) async {
    // Return original frame without processing
    return SegmentationResult(
      processedFrame: frameData,
      mask: null,
      processingTimeMs: 0,
      success: true,
    );
  }

  @override
  Future<SegmentationResult> processFile(
    String filePath,
    Uint8List frameData,
    SegmenterInputMetadata metadata,
  ) async {
    // Stub: just return the frame without processing
    return SegmentationResult(
      processedFrame: frameData,
      mask: null,
      processingTimeMs: 0,
      success: true,
    );
  }

  @override
  Future<void> dispose() async {
    _isReady = false;
  }

  @override
  bool get isReady => _isReady;

  @override
  String get platformName => 'stub';

  @override
  bool get isSupported => false;
}

/// Factory function - returns StubSegmenter.
///
/// For mobile platforms (Android/iOS), apps should use conditional imports
/// to load `segmenter_mobile.dart` instead of this stub.
///
/// Example in your app's code:
/// ```dart
/// import 'package:mediasfu_sdk/.../segmenter_stub.dart'
///     if (dart.library.io) 'package:mediasfu_sdk/.../segmenter_mobile.dart';
/// ```
BackgroundSegmenterBase createSegmenter() => StubSegmenter();
