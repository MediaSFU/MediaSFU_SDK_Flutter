/// Segmenter Interface - Shared Base for All Platforms
///
/// This file defines the abstract interface that ALL platform-specific
/// implementations must conform to. Changes here automatically propagate
/// to all platforms.
///
/// ## Architecture Pattern
///
/// ```
/// segmenter_interface.dart  <-- You are here (SHARED CONTRACT)
///        ↓
///   ┌────┴────┐
///   ↓         ↓
/// segmenter_stub.dart    segmenter_mobile.dart    (segmenter_web.dart)
/// (fallback/desktop)     (Android/iOS ML Kit)     (future TensorFlow.js)
/// ```
///
/// ## Adding a New Platform
///
/// 1. Create `segmenter_<platform>.dart`
/// 2. Implement [BackgroundSegmenterBase]
/// 3. Add conditional import to `segmenter.dart`

library;

import 'dart:typed_data';
import '../virtual_background_types.dart';

/// Configuration options for the segmenter.
class SegmenterConfig {
  /// Whether to use stream mode (optimized for video) vs single image mode.
  final bool streamMode;

  /// Whether to enable raw size mask (matching input dimensions).
  final bool enableRawSizeMask;

  /// Model selection: 0 = general, 1 = landscape (faster, like React's modelSelection).
  final int modelSelection;

  /// Confidence threshold for person detection (0.0 - 1.0).
  final double confidenceThreshold;

  const SegmenterConfig({
    this.streamMode = true,
    this.enableRawSizeMask = true,
    this.modelSelection = 1,
    this.confidenceThreshold = 0.5,
  });

  /// React-equivalent default settings.
  ///
  /// Mirrors:
  /// ```javascript
  /// selfieSegmentation.setOptions({
  ///   modelSelection: 1,
  ///   selfieMode: false,
  /// });
  /// ```
  static const SegmenterConfig reactDefault = SegmenterConfig(
    streamMode: true,
    modelSelection: 1,
    confidenceThreshold: 0.5,
  );
}

/// Input image format for the segmenter.
enum SegmenterInputFormat {
  /// RGBA format (4 bytes per pixel) - common for Flutter textures
  rgba8888,

  /// BGRA format (4 bytes per pixel) - iOS camera default
  bgra8888,

  /// NV21 format (YUV) - Android camera default
  nv21,

  /// YUV420 format - common video format
  yuv420,
}

/// Metadata for input images.
class SegmenterInputMetadata {
  final int width;
  final int height;
  final SegmenterInputFormat format;
  final int rotation; // 0, 90, 180, 270

  const SegmenterInputMetadata({
    required this.width,
    required this.height,
    this.format = SegmenterInputFormat.rgba8888,
    this.rotation = 0,
  });
}

/// Abstract base class for background segmenters.
///
/// All platform-specific implementations MUST extend this class.
/// This ensures API consistency across platforms and allows the core
/// [VirtualBackgroundProcessor] to work with any implementation.
///
/// ## Contract
///
/// 1. [initialize] MUST be called before [processFrame]
/// 2. [dispose] MUST be called when done to free resources
/// 3. [processFrame] MUST handle null/empty input gracefully
/// 4. Implementations SHOULD be thread-safe for use with Isolates
abstract class BackgroundSegmenterBase {
  /// Initialize the segmenter with optional configuration.
  ///
  /// This may download models, allocate GPU resources, etc.
  /// Returns a [Future] that completes when ready.
  Future<void> initialize([SegmenterConfig config = const SegmenterConfig()]);

  /// Process a single frame and return segmentation result.
  ///
  /// Parameters:
  /// - [frameData]: Raw pixel data (format specified in metadata)
  /// - [metadata]: Image dimensions, format, and rotation
  ///
  /// Returns [SegmentationResult] with mask and processed frame.
  Future<SegmentationResult> processFrame(
    Uint8List frameData,
    SegmenterInputMetadata metadata,
  );

  /// Process an image file and return segmentation result.
  ///
  /// This is more reliable than [processFrame] as ML Kit can decode
  /// the image directly from the file path.
  ///
  /// Parameters:
  /// - [filePath]: Path to image file (JPEG, PNG, etc.)
  /// - [frameData]: Original RGBA frame data for compositing
  /// - [metadata]: Image dimensions for mask scaling
  Future<SegmentationResult> processFile(
    String filePath,
    Uint8List frameData,
    SegmenterInputMetadata metadata,
  );

  /// Release all resources.
  ///
  /// After calling dispose, [initialize] must be called again before use.
  Future<void> dispose();

  /// Whether the segmenter is initialized and ready.
  bool get isReady;

  /// Platform-specific identifier (for debugging/logging).
  String get platformName;

  /// Whether this platform actually supports segmentation.
  ///
  /// Stub implementations return false.
  bool get isSupported;
}

/// Factory function type for creating segmenters.
///
/// Used by conditional imports to provide platform-specific instances.
typedef SegmenterFactory = BackgroundSegmenterBase Function();
