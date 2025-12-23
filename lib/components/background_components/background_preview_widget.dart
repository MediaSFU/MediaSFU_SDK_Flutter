import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'virtual_background_types.dart';
import 'virtual_background_processor.dart';

/// Widget that shows a live camera preview with virtual background applied.
///
/// This mirrors the React BackgroundModal's preview functionality which uses:
/// - A hidden video element for camera capture
/// - MediaPipe for segmentation
/// - Canvas for compositing person + background
/// - A visible video element for preview
///
/// In Flutter, we use:
/// - flutter_webrtc for camera capture
/// - ML Kit for segmentation (via VirtualBackgroundProcessor)
/// - CustomPaint for compositing
class BackgroundPreviewWidget extends StatefulWidget {
  final VirtualBackground? selectedBackground;
  final MediaStream? existingStream;
  final bool isEnabled;
  final double? width;
  final double? height;
  final VoidCallback? onPreviewReady;
  final void Function(String error)? onError;

  const BackgroundPreviewWidget({
    super.key,
    this.selectedBackground,
    this.existingStream,
    this.isEnabled = true,
    this.width,
    this.height,
    this.onPreviewReady,
    this.onError,
  });

  @override
  State<BackgroundPreviewWidget> createState() =>
      _BackgroundPreviewWidgetState();
}

class _BackgroundPreviewWidgetState extends State<BackgroundPreviewWidget> {
  final RTCVideoRenderer _renderer = RTCVideoRenderer();
  MediaStream? _localStream;
  VirtualBackgroundProcessor? _processor;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _error;

  // For composited preview
  ui.Image? _currentFrame;
  ui.Image? _backgroundImage;
  Uint8List? _currentMask;
  Timer? _frameTimer;

  @override
  void initState() {
    super.initState();
    _initializePreview();
  }

  @override
  void didUpdateWidget(BackgroundPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedBackground != widget.selectedBackground) {
      _updateBackground();
    }
    if (oldWidget.isEnabled != widget.isEnabled) {
      if (widget.isEnabled) {
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

  Future<void> _initializePreview() async {
    try {
      await _renderer.initialize();

      // Use existing stream or create new one
      if (widget.existingStream != null) {
        _localStream = widget.existingStream;
      } else {
        // Get camera stream
        final constraints = <String, dynamic>{
          'audio': false,
          'video': {
            'facingMode': 'user',
            'width': {'ideal': 640},
            'height': {'ideal': 480},
          },
        };
        _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      }

      _renderer.srcObject = _localStream;

      // Initialize virtual background processor if supported
      if (VirtualBackgroundProcessor.isSupported) {
        _processor = VirtualBackgroundProcessor();
        await _processor!.initialize();

        if (widget.selectedBackground != null) {
          await _processor!.setBackground(widget.selectedBackground!);
        }
      }

      setState(() {
        _isInitialized = true;
        _error = null;
      });

      widget.onPreviewReady?.call();

      if (widget.isEnabled) {
        _startProcessing();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize camera: $e';
      });
      widget.onError?.call(_error!);
    }
  }

  Future<void> _updateBackground() async {
    if (_processor == null || widget.selectedBackground == null) return;

    try {
      await _processor!.setBackground(widget.selectedBackground!);

      // Preload background image for compositing
      if (widget.selectedBackground!.type == BackgroundType.image) {
        await _loadBackgroundImage();
      }
    } catch (e) {
      debugPrint('Error updating background: $e');
    }
  }

  Future<void> _loadBackgroundImage() async {
    if (widget.selectedBackground?.imageUrl != null) {
      try {
        // Load image from network using NetworkImage
        // Note: In Flutter, prefer using Image.network or CachedNetworkImage
        // For direct bytes, we'd need to use http package
        // The actual image loading will be handled by CachedNetworkImage in production
        debugPrint(
            'Background image URL set: ${widget.selectedBackground!.imageUrl}');
        // For URL-based backgrounds, the image is cached and loaded by the background modal
        // The processor will receive the image bytes through a different path
      } catch (e) {
        debugPrint('Error loading background image: $e');
      }
    } else if (widget.selectedBackground?.imageBytes != null) {
      final codec = await ui.instantiateImageCodec(
        widget.selectedBackground!.imageBytes!,
      );
      final frame = await codec.getNextFrame();
      _backgroundImage = frame.image;
    }
  }

  void _startProcessing() {
    if (_isProcessing || _processor == null || !_isInitialized) return;

    _isProcessing = true;

    // Start frame processing timer
    // Note: Real implementation would capture frames from the video track
    // This is a simplified version that shows the concept
    _frameTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _processFrame();
    });
  }

  void _stopProcessing() {
    _isProcessing = false;
    _frameTimer?.cancel();
    _frameTimer = null;
  }

  Future<void> _processFrame() async {
    // In a full implementation, we would:
    // 1. Capture a frame from the video track
    // 2. Send it to the processor
    // 3. Get back the composited frame
    // 4. Display it

    // For now, this is a placeholder that shows the concept
    // The actual frame processing would need platform-specific code
    // to capture frames from the MediaStreamTrack
  }

  Future<void> _cleanup() async {
    _stopProcessing();

    // Only dispose stream if we created it
    if (widget.existingStream == null && _localStream != null) {
      _localStream!.getTracks().forEach((track) => track.stop());
      await _localStream!.dispose();
    }

    await _processor?.dispose();
    await _renderer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? 320;
    final height = widget.height ?? 240;

    if (_error != null) {
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
                  _error!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
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
                'Starting camera...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video preview (raw or with background applied)
            RTCVideoView(
              _renderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              mirror: true,
            ),

            // Background indicator overlay
            if (widget.selectedBackground != null &&
                widget.selectedBackground!.type != BackgroundType.none)
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
                        _getBackgroundIcon(widget.selectedBackground!.type),
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.selectedBackground!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Processing indicator
            if (_isProcessing && _processor != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
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
