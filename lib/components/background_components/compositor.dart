import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'virtual_background_types.dart';
import 'frame_processor.dart';

/// Composites a person with a virtual background using a segmentation mask.
///
/// This mirrors the React canvas compositing logic:
/// ```javascript
/// ctx.drawImage(results.segmentationMask, ...);
/// ctx.globalCompositeOperation = "source-out";
/// ctx.fillStyle = ctx.createPattern(virtualImage, ...);
/// ctx.fillRect(...);
/// ctx.globalCompositeOperation = "destination-atop";
/// ctx.drawImage(results.image, ...);
/// ```
class Compositor {
  /// Cached background image for performance
  ui.Image? _cachedBackgroundImage;
  String? _cachedBackgroundId;

  /// Compose a processed frame with a virtual background
  ///
  /// This is the main compositing function that blends:
  /// 1. The person (from original frame, masked by segmentation)
  /// 2. The background (image, color, or blurred version of original)
  ///
  /// Returns a new ui.Image with the composed result
  Future<ui.Image> compose({
    required ProcessedFrame frame,
    required VirtualBackground background,
  }) async {
    switch (background.type) {
      case BackgroundType.image:
        return _composeWithImage(frame, background);
      case BackgroundType.blur:
        return _composeWithBlur(frame, background.blurIntensity);
      case BackgroundType.color:
        return _composeWithColor(frame, background.color ?? Colors.green);
      case BackgroundType.video:
        // Video backgrounds would need frame-by-frame video processing
        // For now, treat as no background
        return _createImageFromBytes(
            frame.originalBytes, frame.width, frame.height);
      case BackgroundType.none:
        // No processing needed - return original frame
        return _createImageFromBytes(
            frame.originalBytes, frame.width, frame.height);
    }
  }

  /// Compose with an image background
  ///
  /// Mirrors React's approach:
  /// 1. Draw segmentation mask
  /// 2. Use source-out to draw background where person is NOT
  /// 3. Use destination-atop to draw person on top
  Future<ui.Image> _composeWithImage(
    ProcessedFrame frame,
    VirtualBackground background,
  ) async {
    // Load background image if needed
    final bgImage = await _getBackgroundImage(background);
    if (bgImage == null) {
      // Fallback to original if background can't be loaded
      return _createImageFromBytes(
          frame.originalBytes, frame.width, frame.height);
    }

    // Create the composed image using canvas operations
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(frame.width.toDouble(), frame.height.toDouble());

    // Step 1: Draw the background image (scaled to fit)
    final bgPaint = Paint();
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Scale background to cover the frame
    final bgSrcRect = _calculateCoverRect(
      Size(bgImage.width.toDouble(), bgImage.height.toDouble()),
      size,
    );
    canvas.drawImageRect(bgImage, bgSrcRect, bgRect, bgPaint);

    // Step 2: Create person mask from segmentation
    final personImage = await _createImageFromBytes(
      frame.originalBytes,
      frame.width,
      frame.height,
    );

    // Step 3: Apply mask and composite person over background
    await _compositePersonOverBackground(
      canvas,
      personImage,
      frame.segmentationMask,
      frame.width,
      frame.height,
      maskWidth: frame.maskWidth,
      maskHeight: frame.maskHeight,
    );

    // Create final image
    final picture = recorder.endRecording();
    return picture.toImage(frame.width, frame.height);
  }

  /// Compose with a blurred background
  ///
  /// The background is a blurred version of the original frame,
  /// with the person composited on top.
  Future<ui.Image> _composeWithBlur(
      ProcessedFrame frame, double intensity) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    // ignore: unused_local_variable
    final size = Size(frame.width.toDouble(), frame.height.toDouble());

    // Step 1: Draw blurred background
    final originalImage = await _createImageFromBytes(
      frame.originalBytes,
      frame.width,
      frame.height,
    );

    // Apply blur filter to background
    // Intensity 0-1 maps to sigma 0-30
    final sigma = intensity * 30.0;
    final blurPaint = Paint()
      ..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);

    canvas.drawImage(originalImage, Offset.zero, blurPaint);

    // Step 2: Composite person over blurred background
    await _compositePersonOverBackground(
      canvas,
      originalImage,
      frame.segmentationMask,
      frame.width,
      frame.height,
      maskWidth: frame.maskWidth,
      maskHeight: frame.maskHeight,
    );

    final picture = recorder.endRecording();
    return picture.toImage(frame.width, frame.height);
  }

  /// Compose with a solid color background
  Future<ui.Image> _composeWithColor(ProcessedFrame frame, Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(frame.width.toDouble(), frame.height.toDouble());

    // Step 1: Fill with solid color
    final colorPaint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), colorPaint);

    // Step 2: Composite person over colored background
    final personImage = await _createImageFromBytes(
      frame.originalBytes,
      frame.width,
      frame.height,
    );

    await _compositePersonOverBackground(
      canvas,
      personImage,
      frame.segmentationMask,
      frame.width,
      frame.height,
      maskWidth: frame.maskWidth,
      maskHeight: frame.maskHeight,
    );

    final picture = recorder.endRecording();
    return picture.toImage(frame.width, frame.height);
  }

  /// Composite the person (using mask) over the current canvas content
  ///
  /// This is the key operation that:
  /// 1. Creates a mask from segmentation data
  /// 2. Uses the mask to extract just the person
  /// 3. Draws the person over the background
  ///
  /// The approach mirrors React's canvas operations:
  /// - Draw mask, use source-out for background, destination-atop for person
  Future<void> _compositePersonOverBackground(
    Canvas canvas,
    ui.Image personImage,
    Uint8List mask,
    int width,
    int height, {
    int? maskWidth,
    int? maskHeight,
  }) async {
    // Use mask dimensions if provided, otherwise assume same as frame
    final mWidth = maskWidth ?? width;
    final mHeight = maskHeight ?? height;

    // Reduce per-frame logging noise (logged in FrameProcessor);

    // Create a masked version of the person image
    // This creates an image where only the person (high mask values) is visible
    final maskedPerson = await _createMaskedPersonImage(
      personImage,
      mask,
      width,
      height,
      mWidth,
      mHeight,
    );

    // Draw the masked person on top of the background
    canvas.drawImage(maskedPerson, Offset.zero, Paint());
  }

  /// Create an image with only the person visible (background transparent)
  Future<ui.Image> _createMaskedPersonImage(
    ui.Image personImage,
    Uint8List mask,
    int frameWidth,
    int frameHeight,
    int maskWidth,
    int maskHeight,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // First, draw the person image
    canvas.drawImage(personImage, Offset.zero, Paint());

    // Now apply the mask using DstIn blend mode
    // DstIn: keeps destination (person) only where source (mask) is opaque
    final maskImage = await _createMaskImage(mask, maskWidth, maskHeight);

    final maskPaint = Paint()..blendMode = BlendMode.dstIn;

    if (maskWidth != frameWidth || maskHeight != frameHeight) {
      // Scale mask to frame size
      final srcRect =
          Rect.fromLTWH(0, 0, maskWidth.toDouble(), maskHeight.toDouble());
      final dstRect =
          Rect.fromLTWH(0, 0, frameWidth.toDouble(), frameHeight.toDouble());
      canvas.drawImageRect(maskImage, srcRect, dstRect, maskPaint);
    } else {
      canvas.drawImage(maskImage, Offset.zero, maskPaint);
    }

    final picture = recorder.endRecording();
    return picture.toImage(frameWidth, frameHeight);
  }

  /// Create a mask image from segmentation data
  ///
  /// ML Kit returns confidence values (0-255) for each pixel.
  /// We convert this to an RGBA image where alpha represents person confidence.
  /// - High confidence (person) = fully opaque (alpha = 255)
  /// - Low confidence (background) = transparent (alpha = 0)
  Future<ui.Image> _createMaskImage(
    Uint8List maskData,
    int width,
    int height,
  ) async {
    // Convert grayscale mask to RGBA with alpha channel
    final rgbaData = Uint8List(width * height * 4);

    // Debug: check mask statistics
    // ignore: unused_local_variable
    int personPixels = 0;
    // ignore: unused_local_variable
    int bgPixels = 0;

    for (int i = 0; i < maskData.length && i < width * height; i++) {
      final confidence = maskData[i];
      final rgbaIndex = i * 4;

      // Use confidence directly as alpha
      // ML Kit: higher values = more likely to be person
      // Threshold at ~50% confidence (128) for cleaner edges
      final alpha = confidence > 100 ? confidence : 0;

      if (alpha > 128) {
        personPixels++;
      } else {
        bgPixels++;
      }

      // White pixel with alpha based on confidence
      // The color doesn't matter much, alpha is what masks
      rgbaData[rgbaIndex] = 255; // R
      rgbaData[rgbaIndex + 1] = 255; // G
      rgbaData[rgbaIndex + 2] = 255; // B
      rgbaData[rgbaIndex + 3] = alpha; // A - this is the mask!
    }

    // Mask stats logging removed to reduce noise

    return _createImageFromBytes(rgbaData, width, height);
  }

  /// Load and cache background image
  Future<ui.Image?> _getBackgroundImage(VirtualBackground background) async {
    // Check cache first
    if (_cachedBackgroundId == background.id &&
        _cachedBackgroundImage != null) {
      return _cachedBackgroundImage;
    }

    ui.Image? image;

    if (background.imageBytes != null) {
      // Load from bytes
      final codec = await ui.instantiateImageCodec(background.imageBytes!);
      final frame = await codec.getNextFrame();
      image = frame.image;
    } else if (background.imageUrl != null) {
      // Load from URL
      image = await _loadImageFromUrl(background.imageUrl!);
    }

    if (image != null) {
      _cachedBackgroundImage = image;
      _cachedBackgroundId = background.id;
    }

    return image;
  }

  /// Load image from URL
  Future<ui.Image?> _loadImageFromUrl(String url) async {
    try {
      // Use NetworkImage to load and decode
      final completer = Completer<ui.Image>();

      final imageProvider = NetworkImage(url);
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);

      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          completer.complete(info.image);
          imageStream.removeListener(listener);
        },
        onError: (error, stackTrace) {
          completer.completeError(error);
          imageStream.removeListener(listener);
        },
      );

      imageStream.addListener(listener);

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Image load timeout'),
      );
    } catch (e) {
      debugPrint('Compositor: Failed to load image from URL: $e');
      return null;
    }
  }

  /// Create ui.Image from raw RGBA bytes
  Future<ui.Image> _createImageFromBytes(
    Uint8List bytes,
    int width,
    int height,
  ) async {
    final completer = Completer<ui.Image>();

    ui.decodeImageFromPixels(
      bytes,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (image) => completer.complete(image),
    );

    return completer.future;
  }

  /// Calculate source rect for "cover" scaling (like CSS background-size: cover)
  Rect _calculateCoverRect(Size source, Size target) {
    final sourceAspect = source.width / source.height;
    final targetAspect = target.width / target.height;

    double srcWidth, srcHeight, srcX, srcY;

    if (sourceAspect > targetAspect) {
      // Source is wider - crop sides
      srcHeight = source.height;
      srcWidth = source.height * targetAspect;
      srcX = (source.width - srcWidth) / 2;
      srcY = 0;
    } else {
      // Source is taller - crop top/bottom
      srcWidth = source.width;
      srcHeight = source.width / targetAspect;
      srcX = 0;
      srcY = (source.height - srcHeight) / 2;
    }

    return Rect.fromLTWH(srcX, srcY, srcWidth, srcHeight);
  }

  /// Clear cached images
  void clearCache() {
    _cachedBackgroundImage = null;
    _cachedBackgroundId = null;
  }

  /// Dispose resources
  void dispose() {
    clearCache();
  }
}
