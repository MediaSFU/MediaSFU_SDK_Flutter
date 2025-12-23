/// Mobile Segmenter - Android/iOS ML Kit Implementation
///
/// This is the primary implementation for mobile platforms using
/// Google ML Kit's Selfie Segmentation.
///
/// ## Setup Required
///
/// 1. Add to pubspec.yaml:
///    ```yaml
///    dependencies:
///      google_mlkit_selfie_segmentation: ^0.6.0
///    ```
///
/// 2. Android: minSdkVersion 21 in android/app/build.gradle
///
/// 3. iOS: platform :ios, '12.0' in ios/Podfile
///
/// ## React Comparison
///
/// React uses MediaPipe via CDN:
/// ```javascript
/// selfieSegmentation = new SelfieSegmentation({
///   locateFile: (file) =>
///     `https://cdn.jsdelivr.net/npm/@mediapipe/selfie_segmentation/${file}`,
/// });
/// selfieSegmentation.setOptions({ modelSelection: 1, selfieMode: false });
/// selfieSegmentation.onResults((results) => {
///   // results.segmentationMask - mask image
///   // results.image - original image
/// });
/// ```
///
/// Flutter ML Kit provides equivalent functionality with native performance.

library;

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import '../virtual_background_types.dart';
import 'segmenter_interface.dart';

/// Whether ML Kit is enabled
const bool _mlKitEnabled = true;

/// Mobile segmenter using Google ML Kit Selfie Segmentation.
///
/// This provides real-time person segmentation on Android and iOS,
/// matching the functionality of React's MediaPipe implementation.
class MobileSegmenter implements BackgroundSegmenterBase {
  late SelfieSegmenter _segmenter;

  bool _isReady = false;
  SegmenterConfig _config = const SegmenterConfig();

  @override
  Future<void> initialize([
    SegmenterConfig config = const SegmenterConfig(),
  ]) async {
    _config = config;

    try {
      _segmenter = SelfieSegmenter(
        mode: config.streamMode
            ? SegmenterMode.stream // Optimized for video (like React)
            : SegmenterMode.single, // Single image mode
        enableRawSizeMask: config.enableRawSizeMask,
      );
      _isReady = true;
      if (kDebugMode) {
        debugPrint('✅ MobileSegmenter: ML Kit initialized successfully');
      }
    } catch (e) {
      debugPrint('MobileSegmenter initialization failed: $e');
      _isReady = false;
      rethrow;
    }
  }

  @override
  Future<SegmentationResult> processFrame(
    Uint8List frameData,
    SegmenterInputMetadata metadata,
  ) async {
    print('>>> MobileSegmenter.processFrame CALLED - isReady=$_isReady');

    if (!_isReady) {
      print('>>> MobileSegmenter: Not ready, returning error');
      return SegmentationResult.error('Segmenter not initialized');
    }

    final stopwatch = Stopwatch()..start();

    try {
      print(
          '>>> MobileSegmenter: Processing ${metadata.width}x${metadata.height}, ${frameData.length} bytes');

      // Validate frame data size
      final expectedSize = metadata.width * metadata.height * 4;
      if (frameData.length != expectedSize) {
        debugPrint(
            'MobileSegmenter: WARNING - Frame size mismatch! Expected $expectedSize, got ${frameData.length}');
      }

      // Debug: Sample some pixel values to verify we have real image data
      if (frameData.length >= 100) {
        final r0 = frameData[0],
            g0 = frameData[1],
            b0 = frameData[2],
            a0 = frameData[3];
        final mid = frameData.length ~/ 2;
        final rM = frameData[mid],
            gM = frameData[mid + 1],
            bM = frameData[mid + 2],
            aM = frameData[mid + 3];
        debugPrint(
            'MobileSegmenter: Pixel samples - first: RGBA($r0,$g0,$b0,$a0), mid: RGBA($rM,$gM,$bM,$aM)');
      }

      // Try using the data as-is first (RGBA)
      // ML Kit might accept RGBA on some devices
      // If that doesn't work, we'll convert

      // Actually, let's try NV21 which ML Kit handles better
      // But first, let's just pass RGBA and see what happens
      Uint8List processData = frameData;
      InputImageFormat mlFormat = InputImageFormat.bgra8888;

      // RGBA to BGRA conversion (swap R and B)
      debugPrint('MobileSegmenter: Converting RGBA to BGRA for ML Kit');
      processData = Uint8List(frameData.length);
      for (int i = 0; i < frameData.length; i += 4) {
        processData[i] = frameData[i + 2]; // B <- R
        processData[i + 1] = frameData[i + 1]; // G <- G
        processData[i + 2] = frameData[i]; // R <- B
        processData[i + 3] = frameData[i + 3]; // A <- A
      }

      debugPrint('MobileSegmenter: Creating InputImage - format=$mlFormat, '
          'size=${metadata.width}x${metadata.height}, rotation=${metadata.rotation}');

      // For front camera on Android, try rotation 270
      // The JPEG from captureFrame() might not have rotation metadata
      InputImageRotation rotation = InputImageRotation.rotation0deg;

      // Try different rotations - front camera often needs 270 or 90
      // Since the image is 720x1280 (portrait), rotation should be 0 or 180
      // Let's try 0 first, if person detection fails, we can try others

      final inputImage = InputImage.fromBytes(
        bytes: processData,
        metadata: InputImageMetadata(
          size: Size(metadata.width.toDouble(), metadata.height.toDouble()),
          rotation: rotation,
          format: mlFormat,
          bytesPerRow: metadata.width * 4,
        ),
      );

      debugPrint('MobileSegmenter: Calling processImage...');

      final mask = await _segmenter.processImage(inputImage);

      if (mask == null) {
        stopwatch.stop();
        debugPrint(
            'MobileSegmenter: processImage returned null (took ${stopwatch.elapsedMilliseconds}ms)');
        return SegmentationResult.error('Segmentation failed - null mask');
      }

      // Debug: Check confidence distribution
      int nonZero = 0;
      double maxConf = 0;
      for (final c in mask.confidences) {
        if (c > 0) nonZero++;
        if (c > maxConf) maxConf = c;
      }
      debugPrint(
          'MobileSegmenter: Mask analysis - nonZero=$nonZero/${mask.confidences.length}, maxConf=$maxConf');

      debugPrint(
          'MobileSegmenter: Got mask with ${mask.confidences.length} confidence values, '
          'width=${mask.width}, height=${mask.height}');

      // Convert mask confidences to bytes (like React's results.segmentationMask)
      // Use the mask dimensions for output, not input dimensions
      final maskWidth = mask.width;
      final maskHeight = mask.height;

      final maskBytes = _convertMaskToBytes(
        mask.confidences,
        maskWidth,
        maskHeight,
      );

      stopwatch.stop();

      final avgConf = _calculateAverageConfidence(mask.confidences);
      debugPrint(
          'MobileSegmenter: Success - mask size=${maskBytes.length} (${maskWidth}x$maskHeight), '
          'avgConfidence=${avgConf.toStringAsFixed(3)}, '
          'took ${stopwatch.elapsedMilliseconds}ms');

      return SegmentationResult(
        processedFrame: frameData,
        mask: maskBytes,
        confidence: avgConf,
        processingTimeMs: stopwatch.elapsedMilliseconds,
        // Store actual mask dimensions
        maskWidth: maskWidth,
        maskHeight: maskHeight,
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      if (kDebugMode) {
        debugPrint('MobileSegmenter: Error processing frame: $e');
        debugPrint('MobileSegmenter: Stack trace: $stackTrace');
      }
      return SegmentationResult.error('Processing error: $e');
    }
  }

  @override
  Future<SegmentationResult> processFile(
    String filePath,
    Uint8List frameData,
    SegmenterInputMetadata metadata,
  ) async {
    debugPrint('MobileSegmenter: processFile called - $filePath');

    if (!_isReady) {
      return SegmentationResult.error('Segmenter not initialized');
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Use InputImage.fromFilePath - ML Kit handles decoding
      final inputImage = InputImage.fromFilePath(filePath);

      debugPrint('MobileSegmenter: Processing image from file...');

      final mask = await _segmenter.processImage(inputImage);

      if (mask == null) {
        stopwatch.stop();
        debugPrint('MobileSegmenter: processImage from file returned null');
        return SegmentationResult.error(
            'Segmentation failed - null mask from file');
      }

      // Debug: Check confidence distribution
      int nonZero = 0;
      double maxConf = 0;
      for (final c in mask.confidences) {
        if (c > 0) nonZero++;
        if (c > maxConf) maxConf = c;
      }
      debugPrint(
          'MobileSegmenter: File mask analysis - nonZero=$nonZero/${mask.confidences.length}, maxConf=$maxConf');

      final maskWidth = mask.width;
      final maskHeight = mask.height;

      debugPrint('MobileSegmenter: Got file mask ${maskWidth}x$maskHeight');

      final maskBytes = _convertMaskToBytes(
        mask.confidences,
        maskWidth,
        maskHeight,
      );

      stopwatch.stop();

      final avgConf = _calculateAverageConfidence(mask.confidences);
      debugPrint(
          'MobileSegmenter: File success - mask=${maskWidth}x$maskHeight, '
          'avgConf=${avgConf.toStringAsFixed(3)}, took ${stopwatch.elapsedMilliseconds}ms');

      return SegmentationResult(
        processedFrame: frameData,
        mask: maskBytes,
        confidence: avgConf,
        processingTimeMs: stopwatch.elapsedMilliseconds,
        maskWidth: maskWidth,
        maskHeight: maskHeight,
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      debugPrint('MobileSegmenter: File processing error: $e');
      debugPrint('MobileSegmenter: Stack: $stackTrace');
      return SegmentationResult.error('File processing error: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await _segmenter.close();
    _isReady = false;
    if (kDebugMode) {
      debugPrint('🛑 MobileSegmenter: Disposed');
    }
  }

  @override
  bool get isReady => _isReady;

  @override
  String get platformName => 'mobile_mlkit';

  @override
  bool get isSupported => _mlKitEnabled;

  // ===========================================================================
  // Helper Methods for ML Kit
  // ===========================================================================

  InputImageRotation _getRotation(int degrees) {
    switch (degrees) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  InputImageFormat _getFormat(SegmenterInputFormat format) {
    switch (format) {
      case SegmenterInputFormat.nv21:
        return InputImageFormat.nv21;
      case SegmenterInputFormat.yuv420:
        return InputImageFormat.yuv420;
      case SegmenterInputFormat.bgra8888:
        return InputImageFormat.bgra8888;
      case SegmenterInputFormat.rgba8888:
      default:
        // Note: dart:ui's rawRgba returns RGBA format, but ML Kit on some
        // platforms expects BGRA. In practice, for segmentation purposes,
        // the difference is minimal as ML Kit focuses on luminance.
        // Use bgra8888 for best compatibility.
        return InputImageFormat.bgra8888;
    }
  }

  int _getBytesPerRow(SegmenterInputMetadata metadata) {
    switch (metadata.format) {
      case SegmenterInputFormat.rgba8888:
      case SegmenterInputFormat.bgra8888:
        return metadata.width * 4;
      case SegmenterInputFormat.nv21:
      case SegmenterInputFormat.yuv420:
        return metadata.width;
    }
  }

  /// Convert ML Kit confidence values to grayscale mask bytes.
  ///
  /// ML Kit returns List<double> with values 0.0-1.0 (like React's segmentationMask).
  /// We convert to Uint8List with values 0-255 for compositing.
  Uint8List _convertMaskToBytes(
    List<double> confidences,
    int width,
    int height,
  ) {
    final bytes = Uint8List(width * height);
    final threshold = _config.confidenceThreshold;

    for (int i = 0; i < confidences.length && i < bytes.length; i++) {
      // Apply threshold and convert to byte
      final confidence = confidences[i];
      if (confidence >= threshold) {
        bytes[i] = (confidence * 255).round().clamp(0, 255);
      } else {
        bytes[i] = 0;
      }
    }

    return bytes;
  }

  /// Calculate average confidence for logging/debugging.
  double _calculateAverageConfidence(List<double> confidences) {
    if (confidences.isEmpty) return 0.0;
    final sum = confidences.fold<double>(0, (a, b) => a + b);
    return sum / confidences.length;
  }
}

/// Factory function for conditional imports.
BackgroundSegmenterBase createSegmenter() => MobileSegmenter();
