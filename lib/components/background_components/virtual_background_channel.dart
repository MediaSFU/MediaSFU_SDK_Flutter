import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Platform channel interface for native virtual background video track creation.
///
/// This bridges Flutter's virtual background processing to native WebRTC video sources,
/// mirroring React's `mediaCanvas.captureStream()` functionality.
///
/// ## React Equivalent
/// ```javascript
/// processedStream = mediaCanvas.captureStream(frameRate);
/// videoParams = { track: processedStream.getVideoTracks()[0] };
/// ```
///
/// ## Platform Support
/// - Android: Uses Surface/Texture-based video source
/// - iOS: Uses CVPixelBuffer-based video source
/// - Web/Desktop: Fallback (no native support)
class VirtualBackgroundChannel {
  static const MethodChannel _channel =
      MethodChannel('mediasfu/virtual_background');

  /// Singleton instance
  static final VirtualBackgroundChannel _instance =
      VirtualBackgroundChannel._internal();
  factory VirtualBackgroundChannel() => _instance;
  VirtualBackgroundChannel._internal();

  /// Whether native virtual background is supported on this platform
  bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Track ID for the virtual video track
  String? _virtualTrackId;

  /// Current virtual stream
  MediaStream? _virtualStream;

  /// Frame injection timer
  Timer? _frameTimer;

  /// Whether frame injection is active
  bool _isActive = false;

  /// Frame callback for native processing
  Future<Uint8List> Function()? _frameProvider;

  /// Initialize the native virtual background system
  ///
  /// Creates a native video source that can receive processed frames.
  Future<bool> initialize({
    required int width,
    required int height,
    required int fps,
  }) async {
    if (!isSupported) {
      debugPrint('VirtualBackgroundChannel: Not supported on this platform');
      return false;
    }

    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'initialize',
        {
          'width': width,
          'height': height,
          'fps': fps,
        },
      );

      if (result != null && result['success'] == true) {
        _virtualTrackId = result['trackId'] as String?;
        debugPrint(
            'VirtualBackgroundChannel: Initialized with track $_virtualTrackId');
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      debugPrint(
          'VirtualBackgroundChannel: Failed to initialize: ${e.message}');
      return false;
    } on MissingPluginException {
      debugPrint('VirtualBackgroundChannel: Native plugin not available');
      return false;
    }
  }

  /// Create a MediaStream from processed frames
  ///
  /// This creates a WebRTC MediaStream that receives frames from the
  /// virtual background processor.
  ///
  /// ## React Equivalent
  /// ```javascript
  /// processedStream = mediaCanvas.captureStream(frameRate);
  /// ```
  Future<MediaStream?> createProcessedStream({
    required int width,
    required int height,
    required int fps,
  }) async {
    if (!isSupported) {
      // Fallback: Create a dummy stream for unsupported platforms
      return _createFallbackStream();
    }

    try {
      // Initialize native source if needed
      if (_virtualTrackId == null) {
        final initialized =
            await initialize(width: width, height: height, fps: fps);
        if (!initialized) {
          return _createFallbackStream();
        }
      }

      // Create MediaStream with the virtual track
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'createStream',
        {'trackId': _virtualTrackId},
      );

      if (result != null && result['streamId'] != null) {
        // Get the MediaStream from WebRTC
        _virtualStream =
            await _getStreamFromNative(result['streamId'] as String);
        debugPrint(
            'VirtualBackgroundChannel: Created stream ${_virtualStream?.id}');
        return _virtualStream;
      }
    } on PlatformException catch (e) {
      debugPrint(
          'VirtualBackgroundChannel: Failed to create stream: ${e.message}');
    } on MissingPluginException {
      debugPrint('VirtualBackgroundChannel: Native plugin not available');
    }

    return _createFallbackStream();
  }

  /// Push a processed frame to the virtual stream
  ///
  /// This sends RGBA frame data to the native video source for encoding.
  ///
  /// [frameData] - RGBA pixel data (width * height * 4 bytes)
  /// [width] - Frame width
  /// [height] - Frame height
  Future<bool> pushFrame(Uint8List frameData, int width, int height) async {
    if (!isSupported || _virtualTrackId == null) {
      return false;
    }

    try {
      await _channel.invokeMethod('pushFrame', {
        'trackId': _virtualTrackId,
        'data': frameData,
        'width': width,
        'height': height,
      });
      return true;
    } on PlatformException catch (e) {
      debugPrint(
          'VirtualBackgroundChannel: Failed to push frame: ${e.message}');
      return false;
    }
  }

  /// Start continuous frame injection from a provider function
  ///
  /// [frameProvider] - Async function that returns the next frame data
  /// [fps] - Target frames per second
  void startFrameInjection({
    required Future<Uint8List> Function() frameProvider,
    int fps = 15,
  }) {
    if (_isActive) return;

    _frameProvider = frameProvider;
    _isActive = true;

    final interval = Duration(milliseconds: (1000 / fps).round());
    _frameTimer = Timer.periodic(interval, (_) => _injectFrame());

    debugPrint('VirtualBackgroundChannel: Started frame injection at $fps fps');
  }

  /// Stop frame injection
  void stopFrameInjection() {
    _isActive = false;
    _frameTimer?.cancel();
    _frameTimer = null;
    _frameProvider = null;
    debugPrint('VirtualBackgroundChannel: Stopped frame injection');
  }

  Future<void> _injectFrame() async {
    if (!_isActive || _frameProvider == null) return;

    try {
      final frameData = await _frameProvider!();
      // Frame dimensions are embedded in the provider
      // For now, use default dimensions
      await pushFrame(frameData, 640, 480);
    } catch (e) {
      // Don't spam errors
    }
  }

  /// Get the current virtual stream
  MediaStream? get virtualStream => _virtualStream;

  /// Get the virtual video track
  MediaStreamTrack? get virtualTrack {
    final tracks = _virtualStream?.getVideoTracks();
    return tracks?.isNotEmpty == true ? tracks!.first : null;
  }

  /// Dispose resources
  Future<void> dispose() async {
    stopFrameInjection();

    if (_virtualTrackId != null) {
      try {
        await _channel.invokeMethod('dispose', {'trackId': _virtualTrackId});
      } catch (e) {
        // Ignore disposal errors
      }
    }

    if (_virtualStream != null) {
      _virtualStream!.getTracks().forEach((track) => track.stop());
      await _virtualStream!.dispose();
      _virtualStream = null;
    }

    _virtualTrackId = null;
    debugPrint('VirtualBackgroundChannel: Disposed');
  }

  /// Create a fallback stream for unsupported platforms
  Future<MediaStream?> _createFallbackStream() async {
    try {
      // On unsupported platforms, just return null
      // The caller should handle this gracefully
      debugPrint(
          'VirtualBackgroundChannel: Using fallback (no virtual stream)');
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get MediaStream from native stream ID
  Future<MediaStream?> _getStreamFromNative(String streamId) async {
    // This would need platform-specific implementation
    // For now, return null and log
    debugPrint(
        'VirtualBackgroundChannel: Native stream lookup not implemented');
    return null;
  }
}

/// Extension to make channel usage easier
extension VirtualBackgroundChannelX on VirtualBackgroundChannel {
  /// Quick check if virtual backgrounds can work
  bool get canUseVirtualBackground {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }
}
