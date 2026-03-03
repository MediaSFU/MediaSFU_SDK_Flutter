import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Native virtual background helper for Android, iOS, and macOS.
///
/// This class communicates with platform-specific native code that:
/// 1. Intercepts video frames from the camera track
/// 2. Runs segmentation to create a person mask
/// 3. Composites the person over the background image
/// 4. Sends processed frames through WebRTC to remote participants
///
/// **Platform Support:**
/// - Android: ✅ Supported via LocalVideoTrack.ExternalVideoFrameProcessing + MediaPipe
/// - iOS: ✅ Supported via VideoProcessingAdapter + Vision framework
/// - macOS: ✅ Supported via VideoProcessingAdapter + Vision framework (requires macOS 12.0+)
/// - Windows/Linux: ❌ Not supported - flutter_webrtc C++ layer lacks video processing hooks
/// - Web: ❌ Not supported - would need different approach (canvas-based)
///
/// For unsupported platforms, the fallback is local-only background replacement
/// which only affects the local preview but not what remote participants see.
///
/// Usage:
/// ```dart
/// final helper = NativeVirtualBackground();
///
/// // Initialize the native segmentation engine
/// await helper.initialize();
///
/// // Enable with a video track and background image
/// await helper.enable(
///   trackId: localVideoTrack.id!,
///   backgroundImage: imageBytes,
/// );
///
/// // Update background
/// await helper.updateBackground(newImageBytes);
///
/// // Disable
/// await helper.disable();
///
/// // Cleanup
/// await helper.dispose();
/// ```
class NativeVirtualBackground {
  static const _channel = MethodChannel('com.mediasfu/virtual_background');

  bool _isInitialized = false;
  bool _isEnabled = false;

  /// Whether the native virtual background is initialized.
  bool get isInitialized => _isInitialized;

  /// Whether virtual background is currently enabled.
  bool get isEnabled => _isEnabled;

  /// Check if native virtual background is supported on this platform.
  ///
  /// Supported platforms:
  /// - Android: Has LocalVideoTrack.ExternalVideoFrameProcessing interface + MediaPipe
  /// - iOS: Has VideoProcessingAdapter + Vision framework for segmentation
  /// - macOS: Has VideoProcessingAdapter + Vision framework (requires macOS 12.0+)
  /// - Windows: Disabled — libwebrtc RTCVideoSource has no PushFrame API
  ///   and WGC refuses to capture programmatic popup windows.
  /// - Linux: flutter_webrtc C++ layer lacks video processing hooks
  /// - Web: Would need different approach (not native)
  static bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS;
  }

  /// Initialize the native virtual background engine.
  ///
  /// This loads the segmentation model and prepares the processing pipeline.
  ///
  /// [useGpu] - Whether to use GPU acceleration (recommended on supported devices)
  ///
  /// Returns true if initialization was successful.
  Future<bool> initialize({bool useGpu = true}) async {
    if (!isSupported) {
      return false;
    }

    if (_isInitialized) {
      return true;
    }

    try {
      final result = await _channel.invokeMethod<Map>('initialize', {
        'useGpu': useGpu,
      });

      final success = result?['success'] as bool? ?? false;
      if (success) {
        _isInitialized = true;
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Enable virtual background for a video track.
  ///
  /// [trackId] - The ID of the local video track to process
  /// [backgroundImage] - The background image as PNG/JPEG bytes
  /// [confidence] - Segmentation confidence threshold (0.0-1.0, default 0.7)
  ///
  /// Returns true if virtual background was enabled successfully.
  Future<bool> enable({
    required String trackId,
    required Uint8List backgroundImage,
    double confidence = 0.7,
  }) async {
    if (!isSupported) {
      return false;
    }

    if (!_isInitialized) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod<Map>('enable', {
        'trackId': trackId,
        'imageBytes': backgroundImage,
        'confidence': confidence,
      });

      final success = result?['success'] as bool? ?? false;
      if (success) {
        _isEnabled = true;
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Update the background image.
  ///
  /// [backgroundImage] - The new background image as PNG/JPEG bytes
  ///
  /// Returns true if the background was updated successfully.
  Future<bool> updateBackground(Uint8List backgroundImage) async {
    if (!isSupported || !_isEnabled) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod<Map>('updateBackground', {
        'imageBytes': backgroundImage,
      });

      final success = result?['success'] as bool? ?? false;
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Disable virtual background processing.
  ///
  /// The video track will return to showing the original camera feed.
  Future<bool> disable() async {
    if (!isSupported) {
      return true;
    }

    if (!_isEnabled) {
      return true;
    }

    try {
      final result = await _channel.invokeMethod<Map>('disable');

      final success = result?['success'] as bool? ?? false;
      if (success) {
        _isEnabled = false;
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Check if virtual background is currently enabled (from native side).
  Future<bool> checkEnabled() async {
    if (!isSupported) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod<Map>('isEnabled');
      return result?['enabled'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Process a single frame with virtual background applied.
  ///
  /// This method takes raw BGRA frame data and returns the processed frame
  /// with the virtual background composited in.
  ///
  /// Use this for:
  /// - Dart-level frame processing when native WebRTC integration isn't available
  /// - Preview rendering with virtual background applied
  /// - Feeding processed frames to a canvas-based video source
  ///
  /// [imageData] - Raw BGRA pixel data (4 bytes per pixel)
  /// [width] - Frame width in pixels
  /// [height] - Frame height in pixels
  ///
  /// Returns a map with:
  /// - 'success': bool
  /// - 'processedData': Uint8List (BGRA) if successful
  /// - 'width': int
  /// - 'height': int
  /// - 'error': String if failed
  Future<Map<String, dynamic>> processFrame({
    required Uint8List imageData,
    required int width,
    required int height,
  }) async {
    if (!isSupported) {
      return {'success': false, 'error': 'Platform not supported'};
    }

    if (!_isInitialized) {
      return {'success': false, 'error': 'Not initialized'};
    }

    if (!_isEnabled) {
      return {'success': false, 'error': 'Not enabled'};
    }

    try {
      final result = await _channel.invokeMethod<Map>('processFrame', {
        'imageData': imageData,
        'width': width,
        'height': height,
      });

      if (result == null) {
        return {'success': false, 'error': 'No response from native'};
      }

      return Map<String, dynamic>.from(result);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get the platform's virtual background capabilities.
  ///
  /// Returns information about what features are supported on this platform:
  /// - 'nativeWebRTCIntegration': Whether processed frames are sent via WebRTC pipeline
  /// - 'frameByFrameProcessing': Whether processFrame method is available
  /// - 'onnxSegmentation': Whether ONNX model is loaded for segmentation
  /// - 'gpuAcceleration': Whether GPU processing is available
  ///
  /// This helps the app decide whether to use native processing or fall back
  /// to Dart-level processing with replaceTrack().
  Future<Map<String, dynamic>> getCapabilities() async {
    if (!isSupported) {
      return {
        'success': false,
        'platform': 'unsupported',
        'capabilities': <String, dynamic>{},
      };
    }

    try {
      final result = await _channel.invokeMethod<Map>('getCapabilities');
      if (result == null) {
        return {
          'success': false,
          'error': 'No response from native',
        };
      }
      return Map<String, dynamic>.from(result);
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Release all resources.
  ///
  /// Call this when the virtual background feature is no longer needed.
  Future<void> dispose() async {
    if (!isSupported) {
      return;
    }

    try {
      await _channel.invokeMethod('dispose');
      _isEnabled = false;
      _isInitialized = false;
    } catch (e) {
      // Ignore dispose errors
    }
  }
}
