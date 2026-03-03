import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'virtual_background_types.dart';
import 'segmenter/segmenter.dart';

// Platform check helper that works on all platforms including web
bool _isSupportedPlatform() {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows;
}

/// Legacy abstract interface for backward compatibility.
///
/// @deprecated Use [BackgroundSegmenterBase] from segmenter/segmenter.dart instead.
/// This interface is kept for backward compatibility with existing code.
abstract class BackgroundSegmenter {
  /// Initialize the segmenter
  Future<void> initialize();

  /// Process a frame and return the segmented result
  Future<SegmentationResult> processFrame(
    Uint8List frameData, {
    required int width,
    required int height,
  });

  /// Dispose of resources
  Future<void> dispose();

  /// Check if the segmenter is ready
  bool get isReady;

  /// Check if this platform is supported
  /// Supported platforms:
  /// - iOS: MediaPipe TFLite
  /// - Android: Google MediaPipe
  /// - macOS: Apple Vision
  /// - Windows: ONNX Runtime + DirectML
  static bool get isPlatformSupported {
    return _isSupportedPlatform();
  }
}

/// Platform-aware virtual background processor.
///
/// This class provides a unified interface for virtual background processing.
/// It automatically selects the appropriate platform-specific segmenter.
///
/// ## Architecture
///
/// Uses conditional imports to select the right implementation:
/// - **Android/iOS**: ML Kit Selfie Segmentation
/// - **Web/Desktop**: Stub (graceful fallback)
///
/// ## Integration with React MediaSFU
///
/// This implementation mirrors the React version which uses:
/// - `@mediapipe/selfie_segmentation` for web
/// - Canvas-based compositing for background replacement
///
/// ## Usage
/// ```dart
/// final processor = VirtualBackgroundProcessor();
/// await processor.initialize();
///
/// // Set background
/// await processor.setBackground(VirtualBackground.blur(intensity: 0.8));
///
/// // Process frames from camera
/// final result = await processor.processFrame(cameraFrame, width: 640, height: 480);
///
/// // When done
/// await processor.dispose();
/// ```
///
/// ## Custom Segmenter
///
/// You can provide a custom segmenter by setting [legacySegmenter]:
/// ```dart
/// processor.legacySegmenter = MyCustomSegmenter();
/// ```
///
/// Or use the built-in platform segmenter which is auto-created.
class VirtualBackgroundProcessor {
  VirtualBackground? _currentBackground;
  bool _isInitialized = false;
  bool _isProcessing = false;

  /// Platform-specific segmenter (auto-created via conditional imports).
  late BackgroundSegmenterBase _platformSegmenter;

  /// Optional legacy segmenter for backward compatibility.
  /// @deprecated Use the built-in platform segmenter instead.
  BackgroundSegmenter? legacySegmenter;

  /// Alias for [legacySegmenter] for backward compatibility.
  @Deprecated('Use legacySegmenter or rely on built-in platform segmenter')
  BackgroundSegmenter? get segmenter => legacySegmenter;
  @Deprecated('Use legacySegmenter or rely on built-in platform segmenter')
  set segmenter(BackgroundSegmenter? value) => legacySegmenter = value;

  // Cached background image for performance
  ui.Image? _cachedBackgroundImage;
  String? _cachedBackgroundId;

  /// Frame processing callback for real-time processing.
  /// This is called for each processed frame.
  void Function(SegmentationResult)? onFrameProcessed;

  /// Current virtual background configuration
  VirtualBackground? get currentBackground => _currentBackground;

  /// Whether the processor is initialized and ready
  bool get isReady => _isInitialized;

  /// Whether the processor is currently processing a frame
  bool get isProcessing => _isProcessing;

  /// Whether virtual backgrounds are supported on this platform
  static bool get isSupported => BackgroundSegmenter.isPlatformSupported;

  /// The platform-specific segmenter info
  String get segmenterInfo => _isInitialized
      ? '${_platformSegmenter.platformName} (supported: ${_platformSegmenter.isSupported})'
      : 'not initialized';

  /// Initialize the processor.
  ///
  /// This must be called before processing frames.
  /// Automatically creates the appropriate platform-specific segmenter.
  ///
  /// If you have a custom [legacySegmenter], set it before calling initialize.
  ///
  /// Returns true if initialization was successful, false if it failed.
  /// Failures are handled gracefully - virtual backgrounds will be disabled.
  Future<bool> initialize([SegmenterConfig? config]) async {
    try {
      // Create platform-specific segmenter via conditional import factory
      _platformSegmenter = createSegmenter();

      // Initialize the platform segmenter
      await _platformSegmenter.initialize(config ?? const SegmenterConfig());

      // Also initialize legacy segmenter if provided
      if (legacySegmenter != null) {
        try {
          await legacySegmenter!.initialize();
        } catch (e) {
          debugPrint(
              'VirtualBackgroundProcessor: Legacy segmenter init failed: $e');
        }
      }

      _isInitialized = _platformSegmenter.isReady;
      debugPrint(
          'VirtualBackgroundProcessor: Initialized with ${_platformSegmenter.platformName} (ready=$_isInitialized)');
      return _isInitialized;
    } catch (e, stack) {
      debugPrint('⚠️ VirtualBackgroundProcessor: Initialization failed: $e');
      debugPrint('Stack: $stack');
      _isInitialized = false;
      return false;
    }
  }

  /// Set the current virtual background.
  ///
  /// This preloads any necessary resources for the background.
  Future<void> setBackground(VirtualBackground background) async {
    _currentBackground = background;

    // Preload image if needed
    if (background.type == BackgroundType.image) {
      await _preloadBackgroundImage(background);
    }
  }

  /// Preload and cache the background image
  Future<void> _preloadBackgroundImage(VirtualBackground background) async {
    if (_cachedBackgroundId == background.id &&
        _cachedBackgroundImage != null) {
      return; // Already cached
    }

    if (background.imageBytes != null) {
      final codec = await ui.instantiateImageCodec(background.imageBytes!);
      final frame = await codec.getNextFrame();
      _cachedBackgroundImage = frame.image;
      _cachedBackgroundId = background.id;
    }
  }

  /// Process a camera frame with the current virtual background.
  ///
  /// This method mirrors the React `selfieSegmentationPreview` function.
  /// It uses a segmentation mask to separate person from background.
  ///
  /// Parameters:
  /// - [frameData]: Raw frame data from the camera (RGBA or YUV)
  /// - [width]: Frame width in pixels
  /// - [height]: Frame height in pixels
  /// - [rotationDegrees]: Camera rotation (0, 90, 180, 270)
  /// - [format]: Input image format (defaults to RGBA)
  ///
  /// Returns a [SegmentationResult] containing the processed frame.
  Future<SegmentationResult> processFrame(
    Uint8List frameData, {
    required int width,
    required int height,
    int rotationDegrees = 0,
    SegmenterInputFormat format = SegmenterInputFormat.rgba8888,
  }) async {
    if (!_isInitialized || _currentBackground == null) {
      return SegmentationResult.error('Processor not initialized');
    }

    if (_currentBackground!.type == BackgroundType.none) {
      // No processing needed - return original frame
      return SegmentationResult(
        processedFrame: frameData,
        processingTimeMs: 0,
      );
    }

    if (_isProcessing) {
      // Skip if already processing (frame drop)
      return SegmentationResult.error('Already processing');
    }

    _isProcessing = true;
    final stopwatch = Stopwatch()..start();

    try {
      // Create metadata for the input frame
      final metadata = SegmenterInputMetadata(
        width: width,
        height: height,
        format: format,
        rotation: rotationDegrees,
      );

      // Use platform segmenter (preferred) or legacy segmenter
      SegmentationResult result;

      if (_platformSegmenter.isSupported && _platformSegmenter.isReady) {
        // Use the new platform-specific segmenter
        result = await _platformSegmenter.processFrame(frameData, metadata);
      } else if (legacySegmenter != null && legacySegmenter!.isReady) {
        // Fall back to legacy segmenter for backward compatibility
        result = await legacySegmenter!.processFrame(
          frameData,
          width: width,
          height: height,
        );
      } else {
        // No segmenter available - return original
        stopwatch.stop();
        return SegmentationResult(
          processedFrame: frameData,
          processingTimeMs: stopwatch.elapsedMilliseconds,
        );
      }

      // Apply background compositing based on type
      final processedFrame = await _applyBackgroundToFrame(
        result.processedFrame ?? frameData,
        result.mask,
        width: width,
        height: height,
      );

      stopwatch.stop();

      final finalResult = SegmentationResult(
        processedFrame: processedFrame,
        mask: result.mask,
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );

      onFrameProcessed?.call(finalResult);
      return finalResult;
    } catch (e) {
      return SegmentationResult.error('Processing error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Apply background effect based on current background type.
  Future<Uint8List> _applyBackgroundToFrame(
    Uint8List frame,
    Uint8List? mask, {
    required int width,
    required int height,
  }) async {
    if (mask == null || _currentBackground == null) {
      return frame;
    }

    switch (_currentBackground!.type) {
      case BackgroundType.blur:
        return await applyBlur(
              frame,
              intensity: _currentBackground!.blurIntensity,
              width: width,
              height: height,
              mask: mask,
            ) ??
            frame;

      case BackgroundType.color:
        if (_currentBackground!.color != null) {
          return await applyColorBackground(
                frame,
                color: _currentBackground!.color!,
                width: width,
                height: height,
                mask: mask,
              ) ??
              frame;
        }
        return frame;

      case BackgroundType.image:
        if (_cachedBackgroundImage != null) {
          return await applyImageBackground(
                frame,
                backgroundImage: _cachedBackgroundImage!,
                width: width,
                height: height,
                mask: mask,
              ) ??
              frame;
        }
        return frame;

      case BackgroundType.none:
      case BackgroundType.video:
        return frame;
    }
  }

  /// Apply blur effect to the background (person stays sharp).
  ///
  /// Mirrors React's blur background effect.
  /// Uses the segmentation mask to selectively blur only the background.
  Future<Uint8List?> applyBlur(
    Uint8List frameData, {
    required double intensity,
    required int width,
    required int height,
    Uint8List? mask,
  }) async {
    if (mask == null) return frameData;

    try {
      // Decode the frame to an image
      final codec = await ui.instantiateImageCodec(
        frameData,
        targetWidth: width,
        targetHeight: height,
      );
      final frameImage = (await codec.getNextFrame()).image;

      // Create a picture recorder for compositing
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(width.toDouble(), height.toDouble());

      // Calculate blur sigma from intensity (0.0-1.0 → 0-30 sigma)
      final sigma = intensity * 30.0;

      // Step 1: Draw blurred background
      final blurPaint = Paint()
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: sigma,
          sigmaY: sigma,
          tileMode: TileMode.clamp,
        );
      canvas.drawImage(frameImage, Offset.zero, blurPaint);

      // Step 2: Draw sharp foreground (person) using mask
      // Create mask image from bytes
      final maskImage =
          await _bytesToImage(mask, width, height, isGrayscale: true);
      if (maskImage != null) {
        // Use mask as alpha channel to composite original over blur
        final maskPaint = Paint()..blendMode = BlendMode.dstIn;

        // Draw original frame
        canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
        canvas.drawImage(frameImage, Offset.zero, Paint());

        // Apply mask
        canvas.drawImage(maskImage, Offset.zero, maskPaint);
        canvas.restore();

        maskImage.dispose();
      }

      // Finalize
      final picture = recorder.endRecording();
      final resultImage = await picture.toImage(width, height);
      final byteData =
          await resultImage.toByteData(format: ui.ImageByteFormat.rawRgba);

      frameImage.dispose();
      resultImage.dispose();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('applyBlur error: $e');
      return frameData;
    }
  }

  /// Apply solid color background replacement.
  ///
  /// Mirrors React's color background:
  /// ```javascript
  /// ctx.globalCompositeOperation = "source-out";
  /// ctx.fillStyle = color;
  /// ctx.fillRect(0, 0, width, height);
  /// ctx.globalCompositeOperation = "destination-atop";
  /// ctx.drawImage(results.image, 0, 0, width, height);
  /// ```
  Future<Uint8List?> applyColorBackground(
    Uint8List frameData, {
    required Color color,
    required int width,
    required int height,
    required Uint8List mask,
  }) async {
    try {
      // Decode the frame
      final codec = await ui.instantiateImageCodec(
        frameData,
        targetWidth: width,
        targetHeight: height,
      );
      final frameImage = (await codec.getNextFrame()).image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(width.toDouble(), height.toDouble());

      // Create mask image
      final maskImage =
          await _bytesToImage(mask, width, height, isGrayscale: true);
      if (maskImage == null) {
        frameImage.dispose();
        return frameData;
      }

      // Step 1: Draw solid color background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = color,
      );

      // Step 2: Draw person using mask (destination-atop equivalent)
      canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
      canvas.drawImage(frameImage, Offset.zero, Paint());
      canvas.drawImage(
          maskImage, Offset.zero, Paint()..blendMode = BlendMode.dstIn);
      canvas.restore();

      // Finalize
      final picture = recorder.endRecording();
      final resultImage = await picture.toImage(width, height);
      final byteData =
          await resultImage.toByteData(format: ui.ImageByteFormat.rawRgba);

      frameImage.dispose();
      maskImage.dispose();
      resultImage.dispose();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('applyColorBackground error: $e');
      return frameData;
    }
  }

  /// Apply image background replacement.
  ///
  /// Mirrors React's image compositing:
  /// ```javascript
  /// ctx.drawImage(results.segmentationMask, 0, 0, width, height);
  /// ctx.globalCompositeOperation = "source-out";
  /// ctx.fillStyle = ctx.createPattern(virtualImage, 'no-repeat');
  /// ctx.fillRect(0, 0, width, height);
  /// ctx.globalCompositeOperation = "destination-atop";
  /// ctx.drawImage(results.image, 0, 0, width, height);
  /// ```
  Future<Uint8List?> applyImageBackground(
    Uint8List frameData, {
    required ui.Image backgroundImage,
    required int width,
    required int height,
    required Uint8List mask,
  }) async {
    try {
      // Decode the frame
      final codec = await ui.instantiateImageCodec(
        frameData,
        targetWidth: width,
        targetHeight: height,
      );
      final frameImage = (await codec.getNextFrame()).image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(width.toDouble(), height.toDouble());

      // Create mask image
      final maskImage =
          await _bytesToImage(mask, width, height, isGrayscale: true);
      if (maskImage == null) {
        frameImage.dispose();
        return frameData;
      }

      // Step 1: Draw background image (scaled to fill)
      final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
      final srcRect = Rect.fromLTWH(
        0,
        0,
        backgroundImage.width.toDouble(),
        backgroundImage.height.toDouble(),
      );
      canvas.drawImageRect(backgroundImage, srcRect, bgRect, Paint());

      // Step 2: Draw person over background using mask
      canvas.saveLayer(bgRect, Paint());
      canvas.drawImage(frameImage, Offset.zero, Paint());
      canvas.drawImage(
          maskImage, Offset.zero, Paint()..blendMode = BlendMode.dstIn);
      canvas.restore();

      // Finalize
      final picture = recorder.endRecording();
      final resultImage = await picture.toImage(width, height);
      final byteData =
          await resultImage.toByteData(format: ui.ImageByteFormat.rawRgba);

      frameImage.dispose();
      maskImage.dispose();
      resultImage.dispose();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('applyImageBackground error: $e');
      return frameData;
    }
  }

  /// Helper: Convert grayscale mask bytes to ui.Image.
  Future<ui.Image?> _bytesToImage(
    Uint8List bytes,
    int width,
    int height, {
    bool isGrayscale = false,
  }) async {
    try {
      Uint8List rgbaBytes;

      if (isGrayscale) {
        // Convert grayscale mask to RGBA (use as alpha channel)
        rgbaBytes = Uint8List(width * height * 4);
        for (int i = 0; i < bytes.length && i < width * height; i++) {
          final alpha = bytes[i];
          rgbaBytes[i * 4] = 255; // R
          rgbaBytes[i * 4 + 1] = 255; // G
          rgbaBytes[i * 4 + 2] = 255; // B
          rgbaBytes[i * 4 + 3] = alpha; // A (from mask)
        }
      } else {
        rgbaBytes = bytes;
      }

      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        rgbaBytes,
        width,
        height,
        ui.PixelFormat.rgba8888,
        completer.complete,
      );

      return await completer.future;
    } catch (e) {
      debugPrint('_bytesToImage error: $e');
      return null;
    }
  }

  /// Dispose of all resources.
  ///
  /// Call this when the processor is no longer needed.
  Future<void> dispose() async {
    // Dispose platform segmenter
    if (_isInitialized) {
      await _platformSegmenter.dispose();
    }

    // Dispose legacy segmenter if present
    await legacySegmenter?.dispose();

    _isInitialized = false;
    _currentBackground = null;
    _cachedBackgroundImage?.dispose();
    _cachedBackgroundImage = null;
    _cachedBackgroundId = null;
    debugPrint('VirtualBackgroundProcessor: Disposed');
  }
}

/// Extension to integrate with MediaSFU video pipeline.
///
/// This extension provides methods to hook into the video pipeline
/// for real-time background replacement.
extension VirtualBackgroundVideoIntegration on VirtualBackgroundProcessor {
  /// Create a video frame transformer for the WebRTC pipeline.
  ///
  /// This can be used with flutter_webrtc to process video frames
  /// before they are encoded and sent.
  ///
  /// Note: This requires additional setup in the WebRTC configuration.
  Map<String, dynamic> createVideoTransformerConfig() {
    return {
      'type': 'virtualBackground',
      'enabled': isReady && currentBackground?.type != BackgroundType.none,
      'background': currentBackground?.toMap(),
    };
  }
}
