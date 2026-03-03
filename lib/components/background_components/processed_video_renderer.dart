import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'frame_processor.dart';
import 'compositor.dart';
import 'virtual_background_types.dart';
import 'virtual_stream_source.dart';

/// Widget that displays live camera preview with virtual background applied.
///
/// This mirrors the React BackgroundModal's preview functionality:
/// ```javascript
/// <video ref={videoPreviewRef} srcObject={processedStream} />
/// ```
///
/// Uses flutter_webrtc's MediaStreamTrack.captureFrame() to capture frames,
/// runs ML Kit segmentation, composites with virtual background,
/// then uses CustomPainter to render the composed frames.
class ProcessedVideoRenderer extends StatefulWidget {
  /// Current virtual background to apply
  final VirtualBackground? background;

  /// Existing camera stream (optional - will create one if not provided)
  final MediaStream? existingStream;

  /// Whether background processing is enabled
  final bool processingEnabled;

  /// Target frames per second
  final int targetFps;

  /// Widget dimensions
  final double? width;
  final double? height;

  /// Callback when preview is ready
  final VoidCallback? onReady;

  /// Callback on error
  final void Function(String error)? onError;

  /// Callback when a frame is processed (for debugging/stats)
  final void Function(Duration processingTime)? onFrameProcessed;

  /// Callback when the virtual stream source is ready
  /// This provides the VirtualStreamSource that can be used to create
  /// a processed MediaStream for transport
  final void Function(VirtualStreamSource source)? onStreamSourceReady;

  const ProcessedVideoRenderer({
    super.key,
    this.background,
    this.existingStream,
    this.processingEnabled = true,
    this.targetFps = 15,
    this.width,
    this.height,
    this.onReady,
    this.onError,
    this.onFrameProcessed,
    this.onStreamSourceReady,
  });

  @override
  State<ProcessedVideoRenderer> createState() => _ProcessedVideoRendererState();
}

class _ProcessedVideoRendererState extends State<ProcessedVideoRenderer> {
  // Core components
  FrameProcessor? _frameProcessor;
  Compositor? _compositor;
  VirtualStreamSource? _streamSource;

  // Camera stream - we only capture frames from it, no RTCVideoRenderer needed
  MediaStream? _cameraStream;
  bool _ownsCameraStream = false;

  // State
  bool _isInitializing = true;
  bool _isProcessing = false;
  String? _error;

  // Current processed frame for display
  ui.Image? _currentFrame;

  // Performance tracking
  int _frameCount = 0;
  DateTime? _lastFpsUpdate;
  double _currentFps = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(ProcessedVideoRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle background change
    if (oldWidget.background != widget.background) {
      _compositor?.clearCache();
    }

    // Handle processing toggle
    if (oldWidget.processingEnabled != widget.processingEnabled) {
      if (widget.processingEnabled) {
        _startProcessing();
      } else {
        _stopProcessing();
      }
    }
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      // Initialize frame processor (no RTCVideoRenderer needed - we only capture frames)
      _frameProcessor = FrameProcessor();
      await _frameProcessor!.initialize();

      // Initialize compositor
      _compositor = Compositor();

      // Initialize stream source
      _streamSource = VirtualStreamSource();
      await _streamSource!.initialize(
        width: 640,
        height: 480,
        fps: widget.targetFps,
      );

      // Set up frame processing callback
      _frameProcessor!.onFrameProcessed = _onFrameProcessed;
      _frameProcessor!.onError = (error) {
        widget.onError?.call(error);
      };

      // Set up stream source callback
      _streamSource!.onFrameAvailable = (frame) {
        if (mounted) {
          setState(() {
            _currentFrame = frame;
          });
        }
      };

      // Get or create camera stream
      if (widget.existingStream != null) {
        _cameraStream = widget.existingStream;
        _ownsCameraStream = false;
      } else {
        await _createCameraStream();
        _ownsCameraStream = true;
      }

      setState(() {
        _isInitializing = false;
      });

      // Notify that stream source is ready
      if (_streamSource != null) {
        widget.onStreamSourceReady?.call(_streamSource!);
      }

      widget.onReady?.call();

      // Start processing if enabled
      if (widget.processingEnabled) {
        // Delay start slightly to ensure camera is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startProcessing();
        });
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _error = 'Failed to initialize: $e';
      });
      widget.onError?.call(_error!);
    }
  }

  Future<void> _createCameraStream() async {
    final constraints = <String, dynamic>{
      'audio': false,
      'video': {
        'facingMode': 'user',
        'width': {'ideal': 640},
        'height': {'ideal': 480},
        'frameRate': {'ideal': widget.targetFps},
      },
    };

    _cameraStream = await navigator.mediaDevices.getUserMedia(constraints);
  }

  void _startProcessing() async {
    if (_isProcessing || _cameraStream == null || _frameProcessor == null) {
      return;
    }

    _isProcessing = true;
    _lastFpsUpdate = DateTime.now();
    _frameCount = 0;

    await _frameProcessor!.startProcessing(
      _cameraStream!,
      fps: widget.targetFps,
    );

    debugPrint('ProcessedVideoRenderer: Started processing');
  }

  void _stopProcessing() async {
    if (!_isProcessing) return;

    _isProcessing = false;
    await _frameProcessor?.stopProcessing();

    debugPrint('ProcessedVideoRenderer: Stopped processing');
  }

  /// Called when a frame has been segmented
  void _onFrameProcessed(ProcessedFrame frame) async {
    // Early exit if not mounted or not processing (race condition guard)
    if (!mounted || !_isProcessing) return;

    // Capture references to prevent null during async operations
    final compositor = _compositor;
    final streamSource = _streamSource;

    if (compositor == null || streamSource == null) {
      return;
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Compose the frame with virtual background
      final background = widget.background ?? VirtualBackground.none();
      final composedFrame = await compositor.compose(
        frame: frame,
        background: background,
      );

      // Check if still processing after async operation
      if (!mounted || !_isProcessing) {
        debugPrint(
            'ProcessedVideoRenderer: Stopped during compositing, discarding frame');
        return;
      }

      // Push to stream source for display (with try-catch for state errors)
      try {
        await streamSource.pushFrame(composedFrame);
      } catch (e) {
        // Stream source may be disposed during shutdown
        if (_isProcessing) {
          debugPrint('ProcessedVideoRenderer: pushFrame error: $e');
        }
        return;
      }

      // Update FPS counter
      _frameCount++;
      final now = DateTime.now();
      if (_lastFpsUpdate != null) {
        final elapsed = now.difference(_lastFpsUpdate!);
        if (elapsed.inMilliseconds >= 1000) {
          _currentFps = _frameCount / (elapsed.inMilliseconds / 1000);
          _frameCount = 0;
          _lastFpsUpdate = now;
        }
      }

      stopwatch.stop();
      widget.onFrameProcessed?.call(stopwatch.elapsed);
    } catch (e) {
      // Only log if still processing (otherwise expected during shutdown)
      if (_isProcessing) {
        debugPrint('ProcessedVideoRenderer: Compositing error: $e');
      }
    }
  }

  Future<void> _cleanup() async {
    _stopProcessing();

    await _frameProcessor?.dispose();
    _compositor?.dispose();
    await _streamSource?.dispose();

    // Only dispose streams we own - don't touch external streams!
    if (_ownsCameraStream && _cameraStream != null) {
      _cameraStream!.getTracks().forEach((track) => track.stop());
      await _cameraStream!.dispose();
    }
    _cameraStream = null;
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? 320;
    final height = widget.height ?? 240;

    if (_error != null) {
      return _buildErrorState(width, height);
    }

    if (_isInitializing) {
      return _buildLoadingState(width, height);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        height: height,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Show processed frame when available
            // No RTCVideoView needed - we only show processed frames via CustomPaint
            if (_currentFrame != null)
              CustomPaint(
                painter: _FramePainter(image: _currentFrame!),
                size: Size(width, height),
              ),

            // Show loading indicator when processing but no frames yet
            if (_isProcessing && _currentFrame == null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Processing...',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Show waiting message only if not processing yet
            if (!_isProcessing && _currentFrame == null)
              const Center(
                child: Text(
                  'Waiting for camera...',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),

            // FPS indicator (debug)
            if (_isProcessing)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${_currentFps.toStringAsFixed(1)} fps',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),

            // Processing indicator
            if (_isProcessing)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),

            // Background type indicator
            if (widget.background != null &&
                widget.background!.type != BackgroundType.none)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getBackgroundIcon(widget.background!.type),
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.background!.name,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error ?? 'Unknown error',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isInitializing = true;
                });
                _initialize();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBackgroundIcon(BackgroundType type) {
    switch (type) {
      case BackgroundType.blur:
        return Icons.blur_on;
      case BackgroundType.image:
        return Icons.image;
      case BackgroundType.color:
        return Icons.palette;
      case BackgroundType.video:
        return Icons.videocam;
      case BackgroundType.none:
        return Icons.person;
    }
  }
}

/// CustomPainter that renders a ui.Image
class _FramePainter extends CustomPainter {
  final ui.Image image;

  _FramePainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scaling to fit the canvas while maintaining aspect ratio
    final imageAspect = image.width / image.height;
    final canvasAspect = size.width / size.height;

    double drawWidth, drawHeight, offsetX, offsetY;

    if (imageAspect > canvasAspect) {
      // Image is wider - fit to width
      drawWidth = size.width;
      drawHeight = size.width / imageAspect;
      offsetX = 0;
      offsetY = (size.height - drawHeight) / 2;
    } else {
      // Image is taller - fit to height
      drawHeight = size.height;
      drawWidth = size.height * imageAspect;
      offsetX = (size.width - drawWidth) / 2;
      offsetY = 0;
    }

    final srcRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    // Mirror horizontally for selfie view
    canvas.save();
    canvas.translate(size.width, 0);
    canvas.scale(-1, 1);

    final mirroredDstRect = Rect.fromLTWH(
      size.width - offsetX - drawWidth,
      offsetY,
      drawWidth,
      drawHeight,
    );

    canvas.drawImageRect(image, srcRect, mirroredDstRect, Paint());
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FramePainter oldDelegate) {
    return oldDelegate.image != image;
  }
}
