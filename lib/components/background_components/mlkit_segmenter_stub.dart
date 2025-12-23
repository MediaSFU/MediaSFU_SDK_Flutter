/// ML Kit Selfie Segmentation Integration
///
/// This file provides a reference implementation for integrating
/// Google ML Kit Selfie Segmentation with the VirtualBackgroundProcessor.
///
/// ## Setup
///
/// 1. Add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   google_mlkit_selfie_segmentation: ^0.6.0
/// ```
///
/// 2. For Android, add to android/app/build.gradle:
/// ```gradle
/// android {
///   defaultConfig {
///     minSdkVersion 21
///   }
/// }
/// ```
///
/// 3. For iOS, add to ios/Podfile:
/// ```ruby
/// platform :ios, '12.0'
/// ```
///
/// ## React Comparison
///
/// React uses `@mediapipe/selfie_segmentation`:
/// ```typescript
/// selfieSegmentation = new SelfieSegmentation({
///   locateFile: (file) =>
///     `https://cdn.jsdelivr.net/npm/@mediapipe/selfie_segmentation/${file}`,
/// });
///
/// selfieSegmentation.setOptions({
///   modelSelection: 1,  // 0 = general, 1 = landscape (faster)
///   selfieMode: false,
/// });
///
/// selfieSegmentation.onResults((results) => {
///   // results.segmentationMask - the mask image
///   // results.image - the original image
/// });
/// ```
///
/// Flutter ML Kit equivalent:
/// ```dart
/// final segmenter = SelfieSegmenter(mode: SegmenterMode.stream);
/// final mask = await segmenter.processImage(inputImage);
/// // mask.confidences[i] - confidence value per pixel
/// ```

library;

import 'package:flutter/foundation.dart';
import 'virtual_background_processor.dart';
import 'virtual_background_types.dart';

/// Stub implementation of BackgroundSegmenter for platforms without ML Kit.
///
/// This class serves as a reference implementation. To enable real
/// segmentation on mobile:
///
/// 1. Add `google_mlkit_selfie_segmentation: ^0.6.0` to pubspec.yaml
/// 2. Create a class extending [BackgroundSegmenter] that uses ML Kit
/// 3. Set it on [VirtualBackgroundProcessor.segmenter]
///
/// Example implementation with ML Kit:
/// ```dart
/// import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
///
/// class MLKitSegmenter implements BackgroundSegmenter {
///   late SelfieSegmenter _segmenter;
///   bool _isReady = false;
///
///   @override
///   Future<void> initialize() async {
///     _segmenter = SelfieSegmenter(
///       mode: SegmenterMode.stream, // Use stream mode for video
///       enableRawSizeMask: true,
///     );
///     _isReady = true;
///   }
///
///   @override
///   Future<SegmentationResult> processFrame(
///     Uint8List frameData, {
///     required int width,
///     required int height,
///   }) async {
///     // Convert frame to InputImage
///     final inputImage = InputImage.fromBytes(
///       bytes: frameData,
///       metadata: InputImageMetadata(
///         size: Size(width.toDouble(), height.toDouble()),
///         rotation: InputImageRotation.rotation0deg,
///         format: InputImageFormat.nv21, // or bgra8888 on iOS
///         bytesPerRow: width,
///       ),
///     );
///
///     // Process with ML Kit
///     final mask = await _segmenter.processImage(inputImage);
///     if (mask == null) {
///       return SegmentationResult.error('Segmentation failed');
///     }
///
///     // Convert mask to Uint8List
///     final maskBytes = _convertMaskToBytes(mask, width, height);
///
///     return SegmentationResult(
///       processedFrame: frameData,
///       mask: maskBytes,
///       processingTimeMs: 0,
///     );
///   }
///
///   Uint8List _convertMaskToBytes(SegmentationMask mask, int width, int height) {
///     final bytes = Uint8List(width * height);
///     for (int i = 0; i < mask.confidences.length; i++) {
///       // Convert confidence (0.0-1.0) to grayscale (0-255)
///       bytes[i] = (mask.confidences[i] * 255).round().clamp(0, 255);
///     }
///     return bytes;
///   }
///
///   @override
///   Future<void> dispose() async {
///     await _segmenter.close();
///     _isReady = false;
///   }
///
///   @override
///   bool get isReady => _isReady;
/// }
/// ```
class StubBackgroundSegmenter implements BackgroundSegmenter {
  bool _isReady = false;

  @override
  Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint(
        'StubBackgroundSegmenter: This is a stub implementation. '
        'Add google_mlkit_selfie_segmentation to enable real segmentation.',
      );
    }
    _isReady = true;
  }

  @override
  Future<SegmentationResult> processFrame(
    Uint8List frameData, {
    required int width,
    required int height,
  }) async {
    // Stub: return original frame without processing
    return SegmentationResult(
      processedFrame: frameData,
      processingTimeMs: 0,
    );
  }

  @override
  Future<void> dispose() async {
    _isReady = false;
  }

  @override
  bool get isReady => _isReady;
}

/// Extension to help with frame conversion for ML Kit.
///
/// ML Kit expects specific image formats:
/// - Android: NV21 or YV12
/// - iOS: BGRA8888
extension FrameConversion on Uint8List {
  /// Convert RGBA to NV21 format for Android ML Kit.
  ///
  /// NV21 format: Y plane followed by interleaved VU plane
  Uint8List toNV21(int width, int height) {
    final ySize = width * height;
    final uvSize = ySize ~/ 2;
    final nv21 = Uint8List(ySize + uvSize);

    for (int i = 0; i < ySize; i++) {
      final r = this[i * 4];
      final g = this[i * 4 + 1];
      final b = this[i * 4 + 2];

      // Convert RGB to Y
      nv21[i] = ((66 * r + 129 * g + 25 * b + 128) >> 8) + 16;
    }

    // Convert to UV (simplified - every 2x2 block)
    for (int j = 0; j < height ~/ 2; j++) {
      for (int i = 0; i < width ~/ 2; i++) {
        final index = j * 2 * width + i * 2;
        final r = this[index * 4];
        final g = this[index * 4 + 1];
        final b = this[index * 4 + 2];

        final uvIndex = ySize + j * width + i * 2;
        // V
        nv21[uvIndex] = ((112 * r - 94 * g - 18 * b + 128) >> 8) + 128;
        // U
        nv21[uvIndex + 1] = ((-38 * r - 74 * g + 112 * b + 128) >> 8) + 128;
      }
    }

    return nv21;
  }

  /// Create a simple binary mask from confidence values.
  ///
  /// Threshold: pixels with confidence > threshold become 255 (person)
  Uint8List toBinaryMask({double threshold = 0.5}) {
    final mask = Uint8List(length);
    final thresholdByte = (threshold * 255).round();

    for (int i = 0; i < length; i++) {
      mask[i] = this[i] > thresholdByte ? 255 : 0;
    }

    return mask;
  }
}
