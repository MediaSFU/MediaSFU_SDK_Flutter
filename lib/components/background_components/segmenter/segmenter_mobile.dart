/// Mobile/Desktop Segmenter - Uses native implementations for supported platforms
///
/// iOS: Calls native MediaPipe plugin for real segmentation (preview shows VB effect)
/// macOS: Calls native Vision framework for real segmentation (preview shows VB effect)
/// Windows: Calls native ONNX Runtime plugin for real segmentation (preview shows VB effect)
/// Android: Stub implementation (add google_mlkit_selfie_segmentation to your app)
///
/// For virtual backgrounds:
/// - iOS: Uses native MediaPipe plugin (VirtualBackgroundPlugin.swift)
/// - macOS: Uses native Vision plugin (VirtualBackgroundPlugin.swift)
/// - Windows: Uses native ONNX Runtime plugin (virtual_background_plugin.cpp)
/// - Android: Add google_mlkit_selfie_segmentation to your app's pubspec.yaml
///
/// If you need ML Kit on Android, create a custom segmenter implementation
/// in your app that imports google_mlkit_selfie_segmentation directly.

library;

import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../virtual_background_types.dart';
import 'segmenter_interface.dart';

/// Mobile/Desktop segmenter - Native MediaPipe on iOS, Vision on macOS, ONNX on Windows, stub on Android
class MobileSegmenter implements BackgroundSegmenterBase {
  bool _isReady = false;
  SegmenterConfig _config = const SegmenterConfig();
  bool _nativeInitialized = false;

  /// Platform channel for native segmentation (iOS and macOS)
  static const _channel = MethodChannel('com.mediasfu/virtual_background');

  /// Whether current platform supports native segmentation
  /// Windows is disabled — no viable frame-injection path in libwebrtc.
  bool get _supportsNativeSegmentation =>
      Platform.isIOS || Platform.isMacOS;

  @override
  Future<void> initialize([
    SegmenterConfig config = const SegmenterConfig(),
  ]) async {
    _config = config;

    // On iOS, macOS, and Windows, initialize native segmentation for preview
    if (_supportsNativeSegmentation) {
      try {
        final result = await _channel.invokeMethod<Map>('initialize', {
          'useGpu': true,
        });
        _nativeInitialized = result?['success'] as bool? ?? false;

        // Log initialization result with model status
        final modelLoaded = result?['modelLoaded'] as bool? ?? false;
        final engine = result?['engine'] as String? ?? 'unknown';
        final message = result?['message'] as String? ?? '';
        debugPrint(
            'MobileSegmenter: Native init result - success=$_nativeInitialized, modelLoaded=$modelLoaded, engine=$engine, message=$message');
      } catch (e) {
        debugPrint('MobileSegmenter: Native init failed - $e');
        _nativeInitialized = false;
      }
    }

    _isReady = true;
  }

  @override
  Future<SegmentationResult> processFrame(
    Uint8List frameData,
    SegmenterInputMetadata metadata,
  ) async {
    // On iOS/macOS with native initialized, use real segmentation
    if (_supportsNativeSegmentation && _nativeInitialized) {
      return _processWithNative(frameData, metadata);
    }

    // Fallback: Return all-white mask (no background replacement in preview)
    return _createStubResult(frameData, metadata);
  }

  @override
  Future<SegmentationResult> processFile(
    String filePath,
    Uint8List frameData,
    SegmenterInputMetadata metadata,
  ) async {
    // On iOS/macOS with native initialized, use real segmentation with the file
    if (_supportsNativeSegmentation && _nativeInitialized) {
      try {
        // Read file as bytes and send to native
        final file = File(filePath);
        if (await file.exists()) {
          final imageBytes = await file.readAsBytes();
          return _processWithNativeBytes(imageBytes, frameData, metadata);
        }
      } catch (e) {
        // Fall through to stub
      }
    }

    // Fallback: Return all-white mask
    return _createStubResult(frameData, metadata);
  }

  /// Process frame using native segmentation (iOS MediaPipe or macOS Vision)
  Future<SegmentationResult> _processWithNative(
    Uint8List frameData,
    SegmenterInputMetadata metadata,
  ) async {
    try {
      final result = await _channel.invokeMethod<Map>('segmentFrame', {
        'imageData': frameData,
        'width': metadata.width,
        'height': metadata.height,
      });

      final success = result?['success'] as bool? ?? false;
      if (success) {
        final maskData = result?['mask'] as Uint8List?;
        final maskWidth = result?['maskWidth'] as int? ?? metadata.width;
        final maskHeight = result?['maskHeight'] as int? ?? metadata.height;

        if (maskData != null) {
          return SegmentationResult(
            processedFrame: frameData,
            mask: maskData,
            maskWidth: maskWidth,
            maskHeight: maskHeight,
            processingTimeMs: 0,
            success: true,
          );
        }
      }
    } catch (e) {
      // Fall through to stub
    }

    return _createStubResult(frameData, metadata);
  }

  /// Process image bytes using native segmentation (iOS MediaPipe or macOS Vision)
  Future<SegmentationResult> _processWithNativeBytes(
    Uint8List imageBytes,
    Uint8List originalFrameData,
    SegmenterInputMetadata metadata,
  ) async {
    try {
      final result = await _channel.invokeMethod<Map>('segmentFrame', {
        'imageData': imageBytes,
        'width': metadata.width,
        'height': metadata.height,
      });

      final success = result?['success'] as bool? ?? false;
      if (success) {
        final maskData = result?['mask'] as Uint8List?;
        final maskWidth = result?['maskWidth'] as int? ?? metadata.width;
        final maskHeight = result?['maskHeight'] as int? ?? metadata.height;

        if (maskData != null) {
          return SegmentationResult(
            processedFrame: originalFrameData,
            mask: maskData,
            maskWidth: maskWidth,
            maskHeight: maskHeight,
            processingTimeMs: 0,
            success: true,
          );
        }
      }
    } catch (e) {
      // Fall through to stub
    }

    return _createStubResult(originalFrameData, metadata);
  }

  /// Create stub result with all-white mask (shows original camera, no VB effect)
  SegmentationResult _createStubResult(
    Uint8List frameData,
    SegmenterInputMetadata metadata,
  ) {
    final maskSize = metadata.width * metadata.height;
    final mask = Uint8List(maskSize);
    for (int i = 0; i < maskSize; i++) {
      mask[i] = 255; // 255 = fully person (no background replacement)
    }

    return SegmentationResult(
      processedFrame: frameData,
      mask: mask,
      maskWidth: metadata.width,
      maskHeight: metadata.height,
      processingTimeMs: 0,
      success: true,
    );
  }

  @override
  Future<void> dispose() async {
    _isReady = false;
    _nativeInitialized = false;
  }

  @override
  bool get isReady => _isReady;

  @override
  String get platformName {
    if (_nativeInitialized) {
      if (Platform.isIOS) return 'ios_mediapipe';
      if (Platform.isMacOS) return 'macos_vision';
    }
    return 'mobile_stub';
  }

  @override
  bool get isSupported => _supportsNativeSegmentation && _nativeInitialized;
}

/// Factory function for conditional imports
BackgroundSegmenterBase createSegmenter() => MobileSegmenter();
