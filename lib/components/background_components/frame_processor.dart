import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';
import 'segmenter/segmenter.dart';
import 'virtual_background_types.dart' show SegmentationResult;

/// Represents a processed frame with segmentation data
class ProcessedFrame {
  /// Original camera frame as ui.Image
  final ui.Image? originalImage;

  /// Original frame as raw bytes (RGBA format)
  final Uint8List originalBytes;

  /// Segmentation mask from ML Kit (confidence values 0-255)
  final Uint8List segmentationMask;

  /// Frame width
  final int width;

  /// Frame height
  final int height;

  /// Mask width (may differ from frame width if enableRawSizeMask is false)
  final int maskWidth;

  /// Mask height (may differ from frame height)
  final int maskHeight;

  /// Timestamp when frame was captured
  final DateTime timestamp;

  ProcessedFrame({
    this.originalImage,
    required this.originalBytes,
    required this.segmentationMask,
    required this.width,
    required this.height,
    int? maskWidth,
    int? maskHeight,
    DateTime? timestamp,
  })  : maskWidth = maskWidth ?? width,
        maskHeight = maskHeight ?? height,
        timestamp = timestamp ?? DateTime.now();

  /// Check if this frame has valid data
  bool get isValid =>
      originalBytes.isNotEmpty &&
      segmentationMask.isNotEmpty &&
      width > 0 &&
      height > 0;
}

/// Captures and processes video frames for virtual background
///
/// This class mirrors React's frame processing loop:
/// ```javascript
/// const processFrame = () => {
///   selfieSegmentation.send({ image: videoElement });
///   requestAnimationFrame(processFrame);
/// };
/// ```
///
/// Uses flutter_webrtc's MediaStreamTrack.captureFrame() which returns PNG data,
/// then decodes it to RGBA for segmentation processing.
class FrameProcessor {
  /// Platform-specific segmenter (ML Kit on mobile)
  BackgroundSegmenterBase? _segmenter;

  /// Source camera stream
  MediaStream? _sourceStream;

  /// Whether currently processing frames
  bool _isProcessing = false;

  /// Whether the processor is initialized
  bool _isInitialized = false;

  /// Target frames per second
  int _targetFps = 15;

  /// Last known dimensions
  int _lastWidth = 640;
  int _lastHeight = 480;

  /// Optional target dimensions (vidCons) — if set, frames are decoded
  /// at these dimensions instead of the camera's native resolution.
  int? _targetWidth;
  int? _targetHeight;

  /// Frame processing callback - called for each processed frame
  void Function(ProcessedFrame frame)? onFrameProcessed;

  /// Error callback
  void Function(String error)? onError;

  /// Whether frames are being processed
  bool get isProcessing => _isProcessing;

  /// Whether the processor is ready
  bool get isInitialized => _isInitialized;

  /// Current target FPS
  int get targetFps => _targetFps;

  /// Initialize the frame processor
  ///
  /// This must be called before starting frame processing.
  /// Creates the platform-specific segmenter (ML Kit on mobile).
  Future<void> initialize([SegmenterConfig? config]) async {
    if (_isInitialized) return;

    try {
      // Create platform-specific segmenter
      _segmenter = createSegmenter();
      await _segmenter!.initialize(config ?? const SegmenterConfig());
      _isInitialized = true;
      debugPrint(
          'FrameProcessor: Initialized with ${_segmenter!.platformName}');
    } catch (e) {
      onError?.call('Failed to initialize FrameProcessor: $e');
      rethrow;
    }
  }

  /// Start processing frames from the given media stream
  ///
  /// This mirrors React's approach:
  /// 1. Get camera stream
  /// 2. Start frame capture loop
  /// 3. Run segmentation on each frame
  /// 4. Call onFrameProcessed with results
  ///
  /// [stream] - MediaStream from camera
  /// [fps] - Target frames per second (default: 15, max: 10 for stability)
  /// [targetWidth] - Target width to downscale frames to (vidCons)
  /// [targetHeight] - Target height to downscale frames to (vidCons)
  Future<void> startProcessing(MediaStream stream,
      {int fps = 15, int? targetWidth, int? targetHeight}) async {
    if (!_isInitialized) {
      throw StateError(
          'FrameProcessor not initialized. Call initialize() first.');
    }

    if (_isProcessing) {
      debugPrint('FrameProcessor: Already processing, stopping first');
      await stopProcessing();
    }

    _sourceStream = stream;
    // Limit FPS to avoid overwhelming ImageReader buffer
    _targetFps = fps.clamp(1, 10);
    _targetWidth = targetWidth;
    _targetHeight = targetHeight;
    _isProcessing = true;
    _frameCounter = 0;
    _consecutiveFailures = 0;

    // Get initial dimensions from track settings
    final videoTracks = stream.getVideoTracks();
    if (videoTracks.isNotEmpty) {
      final settings = videoTracks.first.getSettings();
      _lastWidth = settings['width'] as int? ?? 640;
      _lastHeight = settings['height'] as int? ?? 480;
    }

    debugPrint(
        'FrameProcessor: Starting processing at $_targetFps FPS (${_lastWidth}x$_lastHeight)');

    // Start the frame processing loop using sequential async calls
    // This ensures we wait for each capture to complete before starting the next
    _runFrameLoop();
  }

  /// Sequential frame processing loop that waits for each capture to complete
  Future<void> _runFrameLoop() async {
    // Use a much slower rate to avoid ImageReader buffer exhaustion
    // captureFrame() uses ImageReader with limited buffer
    const minFrameTime = Duration(milliseconds: 200); // 5 FPS max

    while (_isProcessing) {
      final frameStart = DateTime.now();

      // Process one frame and wait for it to complete
      await _captureAndProcessFrame();

      // Always wait at least minFrameTime between frames
      final elapsed = DateTime.now().difference(frameStart);
      final waitTime = minFrameTime - elapsed;

      if (waitTime.inMilliseconds > 0) {
        await Future.delayed(waitTime);
      } else {
        // If processing took longer than frame interval, yield briefly
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
  }

  /// Stop frame processing
  Future<void> stopProcessing() async {
    _isProcessing = false;
    debugPrint('FrameProcessor: Stopped processing');
  }

  // Frame counter for debug logging
  int _frameCounter = 0;
  int _consecutiveFailures = 0;

  /// Capture a single frame and run segmentation
  Future<void> _captureAndProcessFrame() async {
    if (!_isProcessing || _sourceStream == null) return;

    _frameCounter++;

    // Log first 5 frames, then every 30 frames (roughly every 3 seconds at 10fps)
    final shouldLog = _frameCounter % 30 == 1 || _frameCounter <= 5;

    try {
      final videoTracks = _sourceStream!.getVideoTracks();
      if (videoTracks.isEmpty) {
        if (shouldLog) debugPrint('FrameProcessor: No video tracks available');
        _consecutiveFailures++;
        return;
      }

      final videoTrack = videoTracks.first;
      if (!videoTrack.enabled) {
        if (shouldLog) debugPrint('FrameProcessor: Video track is disabled');
        _consecutiveFailures++;
        return;
      }

      if (shouldLog) {
        debugPrint(
            'FrameProcessor: Capturing frame #$_frameCounter, track=${videoTrack.id}, kind=${videoTrack.kind}');
      }

      // Capture frame using flutter_webrtc's captureFrame()
      // This returns image data (JPEG) as ByteBuffer
      ByteBuffer imageBuffer;
      try {
        imageBuffer = await videoTrack.captureFrame();
      } catch (captureError) {
        if (shouldLog || _consecutiveFailures < 3) {
          debugPrint('FrameProcessor: captureFrame() failed: $captureError');
        }
        _consecutiveFailures++;
        return;
      }

      final Uint8List imageBytes = imageBuffer.asUint8List();

      if (imageBytes.isEmpty) {
        if (shouldLog) debugPrint('FrameProcessor: Empty frame captured');
        _consecutiveFailures++;
        return;
      }

      // Reset failure counter on successful capture
      _consecutiveFailures = 0;

      if (shouldLog) debugPrint('FrameProcessor: Captured ${imageBytes.length} bytes (JPEG)');

      // Save JPEG to temp file for ML Kit to process directly
      // This avoids the RGBA/BGRA conversion issues
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/ml_frame.jpg');
      await tempFile.writeAsBytes(imageBytes);

      if (shouldLog) debugPrint('FrameProcessor: Saved JPEG to ${tempFile.path}');

      // Also decode to get dimensions and RGBA for compositing
      // Decode JPEG — if vidCons target dimensions are set, decode directly
      // at that resolution (more efficient than full-res decode + resize)
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: _targetWidth,
        targetHeight: _targetHeight,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      _lastWidth = image.width;
      _lastHeight = image.height;

      if (shouldLog) debugPrint('FrameProcessor: Decoded image ${_lastWidth}x$_lastHeight');

      // Get raw RGBA bytes from the image for compositing later
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      codec.dispose();

      if (byteData == null) {
        debugPrint('FrameProcessor: Failed to get byte data from image');
        return;
      }

      final Uint8List frameData = byteData.buffer.asUint8List();

      // Check if still processing before running segmentation
      if (!_isProcessing || _segmenter == null) {
        debugPrint('FrameProcessor: Stopped before segmentation');
        return;
      }

      if (shouldLog) debugPrint('FrameProcessor: Running segmentation via file path');

      // Run segmentation using file path (more reliable than fromBytes)
      final metadata = SegmenterInputMetadata(
        width: _lastWidth,
        height: _lastHeight,
        format: SegmenterInputFormat.rgba8888,
      );

      SegmentationResult result;
      try {
        // Use processFile instead of processFrame for better ML Kit compatibility
        final segmenter = _segmenter;
        if (segmenter == null) {
          debugPrint('FrameProcessor: Segmenter disposed during processing');
          return;
        }
        result =
            await segmenter.processFile(tempFile.path, frameData, metadata);
      } catch (segError, segStack) {
        debugPrint('FrameProcessor: Segmenter threw exception: $segError');
        debugPrint('FrameProcessor: Segmenter stack: $segStack');
        return;
      }

      if (result.success && result.mask != null) {
        // Check if still processing after segmentation completed
        if (!_isProcessing) {
          debugPrint(
              'FrameProcessor: Stopped after segmentation, discarding frame');
          return;
        }

        // Get mask dimensions - may differ from frame dimensions
        final maskWidth = result.maskWidth ?? _lastWidth;
        final maskHeight = result.maskHeight ?? _lastHeight;

        if (shouldLog) debugPrint('FrameProcessor: Segmentation successful - '
            'frame=${_lastWidth}x$_lastHeight, mask=${maskWidth}x$maskHeight, '
            'maskBytes=${result.mask!.length}');

        final processedFrame = ProcessedFrame(
          originalBytes: frameData,
          segmentationMask: result.mask!,
          width: _lastWidth,
          height: _lastHeight,
          maskWidth: maskWidth,
          maskHeight: maskHeight,
        );

        // Final check before callback
        if (_isProcessing) {
          onFrameProcessed?.call(processedFrame);
        }
      } else {
        // Log the actual error from segmenter
        debugPrint(
            'FrameProcessor: Segmentation failed - success=${result.success}, '
            'hasMask=${result.mask != null}, error=${result.error}');
      }
    } catch (e, stackTrace) {
      // Log error with stack trace on first occurrence
      if (_frameCounter == 1) {
        debugPrint('FrameProcessor: Frame processing error: $e');
        debugPrint('FrameProcessor: Stack trace: $stackTrace');
      } else if (shouldLog) {
        debugPrint('FrameProcessor: Frame processing error: $e');
      }
    }
  }

  /// Process a single frame manually (for testing or one-off processing)
  ///
  /// [frameData] - Raw frame data in RGBA format
  /// [width] - Frame width
  /// [height] - Frame height
  Future<ProcessedFrame?> processFrame(
    Uint8List frameData, {
    required int width,
    required int height,
  }) async {
    if (!_isInitialized || _segmenter == null) {
      throw StateError('FrameProcessor not initialized');
    }

    final metadata = SegmenterInputMetadata(
      width: width,
      height: height,
      format: SegmenterInputFormat.rgba8888,
    );
    final result = await _segmenter!.processFrame(frameData, metadata);

    if (result.success && result.mask != null) {
      return ProcessedFrame(
        originalBytes: frameData,
        segmentationMask: result.mask!,
        width: width,
        height: height,
      );
    }

    return null;
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await stopProcessing();
    await _segmenter?.dispose();
    _segmenter = null;
    _sourceStream = null;
    _isInitialized = false;
    debugPrint('FrameProcessor: Disposed');
  }
}
