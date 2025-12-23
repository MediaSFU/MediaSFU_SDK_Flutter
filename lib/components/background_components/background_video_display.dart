import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'background_processor_service.dart';

/// A widget that displays either processed (background-replaced) video frames
/// or falls back to standard RTCVideoView when no background is active.
///
/// This widget is designed to be used as a videoBuilder in CardVideoDisplay
/// or as a replacement for the video surface in VideoCard when the local
/// participant has a virtual background enabled.
///
/// **Usage:**
/// ```dart
/// // In a VideoCard or CardVideoDisplay, use this as a video overlay
/// BackgroundVideoDisplay(
///   videoStream: localStreamVideo,
///   doMirror: true,
///   objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
/// )
/// ```
///
/// **How it works:**
/// 1. Checks BackgroundProcessorService.hasBackground to see if processing is active
/// 2. If processing active: Shows CustomPaint with processed frames
/// 3. If not processing: Shows standard RTCVideoView with raw camera
/// 4. Automatically updates when frames are ready via callback
class BackgroundVideoDisplay extends StatefulWidget {
  /// The source stream to display (used when no background is active)
  final MediaStream? videoStream;

  /// Whether to mirror the video (for local camera preview)
  final bool doMirror;

  /// Object fit mode
  final RTCVideoViewObjectFit objectFit;

  /// The processor service (uses singleton if not provided)
  final BackgroundProcessorService? processorService;

  const BackgroundVideoDisplay({
    super.key,
    required this.videoStream,
    this.doMirror = true,
    this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    this.processorService,
  });

  @override
  State<BackgroundVideoDisplay> createState() => _BackgroundVideoDisplayState();
}

class _BackgroundVideoDisplayState extends State<BackgroundVideoDisplay> {
  late final BackgroundProcessorService _service;
  ui.Image? _currentFrame;
  RTCVideoRenderer? _renderer;
  bool _rendererInitialized = false;

  // Store the previous callback to restore it on dispose
  void Function(ui.Image)? _previousCallback;

  @override
  void initState() {
    super.initState();
    _service = widget.processorService ?? BackgroundProcessorService();
    _setupListeners();
    _initRenderer();

    // Get the current frame if available
    _currentFrame = _service.currentFrame;
  }

  void _setupListeners() {
    // Store the previous callback
    _previousCallback = _service.onFrameReady;

    // Set our callback
    _service.onFrameReady = _onFrameReady;
  }

  void _onFrameReady(ui.Image frame) {
    if (!mounted) return;
    setState(() {
      _currentFrame = frame;
    });
  }

  Future<void> _initRenderer() async {
    _renderer = RTCVideoRenderer();
    await _renderer!.initialize();
    if (mounted) {
      _attachStream();
      setState(() {
        _rendererInitialized = true;
      });
    }
  }

  void _attachStream() {
    if (_renderer != null && widget.videoStream != null) {
      _renderer!.srcObject = widget.videoStream;
    }
  }

  @override
  void didUpdateWidget(covariant BackgroundVideoDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.videoStream != oldWidget.videoStream) {
      _attachStream();
    }
  }

  @override
  void dispose() {
    // Restore the previous callback
    if (_service.onFrameReady == _onFrameReady) {
      _service.onFrameReady = _previousCallback;
    }
    _renderer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we should show processed video
    final showProcessed = _service.hasBackground &&
        _service.isProcessing &&
        _currentFrame != null;

    if (showProcessed) {
      // Show processed video with virtual background
      return CustomPaint(
        painter: _ProcessedVideoPainter(
          image: _currentFrame!,
          mirror: widget.doMirror,
          objectFit: widget.objectFit,
        ),
        size: Size.infinite,
      );
    }

    // Fall back to standard RTCVideoView
    if (!_rendererInitialized || _renderer == null) {
      return const SizedBox.shrink();
    }

    return RTCVideoView(
      _renderer!,
      mirror: widget.doMirror,
      objectFit: widget.objectFit,
    );
  }
}

/// Custom painter for displaying processed video frames
class _ProcessedVideoPainter extends CustomPainter {
  final ui.Image image;
  final bool mirror;
  final RTCVideoViewObjectFit objectFit;

  _ProcessedVideoPainter({
    required this.image,
    required this.mirror,
    required this.objectFit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();

    // Calculate the destination rect based on object fit
    final Rect destRect;
    if (objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitCover) {
      destRect = _calculateCoverRect(size, imageWidth, imageHeight);
    } else {
      destRect = _calculateContainRect(size, imageWidth, imageHeight);
    }

    canvas.save();

    // Apply mirror transformation if needed
    if (mirror) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    // Draw the image
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, imageWidth, imageHeight),
      destRect,
      Paint()..filterQuality = FilterQuality.medium,
    );

    canvas.restore();
  }

  Rect _calculateCoverRect(Size size, double imageWidth, double imageHeight) {
    final imageAspect = imageWidth / imageHeight;
    final canvasAspect = size.width / size.height;

    double destWidth, destHeight;
    if (imageAspect > canvasAspect) {
      // Image is wider - fit by height
      destHeight = size.height;
      destWidth = destHeight * imageAspect;
    } else {
      // Image is taller - fit by width
      destWidth = size.width;
      destHeight = destWidth / imageAspect;
    }

    // Center the image
    final left = (size.width - destWidth) / 2;
    final top = (size.height - destHeight) / 2;

    return Rect.fromLTWH(left, top, destWidth, destHeight);
  }

  Rect _calculateContainRect(Size size, double imageWidth, double imageHeight) {
    final imageAspect = imageWidth / imageHeight;
    final canvasAspect = size.width / size.height;

    double destWidth, destHeight;
    if (imageAspect > canvasAspect) {
      // Image is wider - fit by width
      destWidth = size.width;
      destHeight = destWidth / imageAspect;
    } else {
      // Image is taller - fit by height
      destHeight = size.height;
      destWidth = destHeight * imageAspect;
    }

    // Center the image
    final left = (size.width - destWidth) / 2;
    final top = (size.height - destHeight) / 2;

    return Rect.fromLTWH(left, top, destWidth, destHeight);
  }

  @override
  bool shouldRepaint(covariant _ProcessedVideoPainter oldDelegate) {
    return image != oldDelegate.image ||
        mirror != oldDelegate.mirror ||
        objectFit != oldDelegate.objectFit;
  }
}
