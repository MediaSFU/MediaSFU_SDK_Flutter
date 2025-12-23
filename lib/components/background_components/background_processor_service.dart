import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'frame_processor.dart';
import 'compositor.dart';
import 'virtual_background_types.dart';

/// Singleton service that manages persistent background processing.
///
/// This service lives in the main app state and continues processing
/// frames even after the BackgroundModal is closed.
///
/// Usage:
/// 1. Call `start()` when video is enabled
/// 2. Set `background` to apply a virtual background
/// 3. Listen to `onFrameReady` to get processed frames
/// 4. Call `stop()` when video is disabled
class BackgroundProcessorService {
  static final BackgroundProcessorService _instance =
      BackgroundProcessorService._internal();
  factory BackgroundProcessorService() => _instance;
  BackgroundProcessorService._internal();

  // Components
  FrameProcessor? _frameProcessor;
  Compositor? _compositor;

  // State
  bool _isInitialized = false;
  bool _isProcessing = false;
  MediaStream? _sourceStream;
  VirtualBackground? _currentBackground;

  // Current processed frame
  ui.Image? _currentFrame;

  // Callbacks
  void Function(ui.Image frame)? onFrameReady;
  void Function(String error)? onError;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  bool get hasBackground =>
      _currentBackground != null &&
      _currentBackground!.type != BackgroundType.none;
  ui.Image? get currentFrame => _currentFrame;
  VirtualBackground? get currentBackground => _currentBackground;

  /// Initialize the background processor service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _frameProcessor = FrameProcessor();
      await _frameProcessor!.initialize();

      _compositor = Compositor();

      _frameProcessor!.onFrameProcessed = _onFrameProcessed;
      _frameProcessor!.onError = (error) {
        onError?.call(error);
      };

      _isInitialized = true;
      debugPrint('BackgroundProcessorService: Initialized');
    } catch (e) {
      debugPrint('BackgroundProcessorService: Failed to initialize: $e');
      onError?.call('Failed to initialize: $e');
      rethrow;
    }
  }

  /// Set the virtual background to apply
  void setBackground(VirtualBackground? background) {
    _currentBackground = background;
    _compositor?.clearCache();

    debugPrint(
        'BackgroundProcessorService: Background set to ${background?.name ?? 'none'}');

    // If no background, stop processing
    if (background == null || background.type == BackgroundType.none) {
      if (_isProcessing) {
        _stopProcessingInternal();
      }
      _currentFrame = null;
    } else if (_sourceStream != null && !_isProcessing) {
      // Start processing if we have a stream and a background
      _startProcessingInternal();
    }
  }

  /// Start processing frames from the given stream
  Future<void> start(MediaStream stream) async {
    if (!_isInitialized) {
      await initialize();
    }

    _sourceStream = stream;

    // Only start processing if we have a background set
    if (hasBackground) {
      await _startProcessingInternal();
    }

    debugPrint('BackgroundProcessorService: Started with stream');
  }

  /// Stop all processing
  Future<void> stop() async {
    await _stopProcessingInternal();
    _sourceStream = null;
    _currentFrame = null;
    debugPrint('BackgroundProcessorService: Stopped');
  }

  /// Internal start processing
  Future<void> _startProcessingInternal() async {
    if (_isProcessing || _sourceStream == null || _frameProcessor == null) {
      return;
    }

    _isProcessing = true;
    await _frameProcessor!.startProcessing(_sourceStream!, fps: 10);
    debugPrint('BackgroundProcessorService: Processing started');
  }

  /// Internal stop processing
  Future<void> _stopProcessingInternal() async {
    if (!_isProcessing) return;

    _isProcessing = false;
    await _frameProcessor?.stopProcessing();
    debugPrint('BackgroundProcessorService: Processing stopped');
  }

  /// Called when a frame is processed by the FrameProcessor
  void _onFrameProcessed(ProcessedFrame frame) async {
    if (!_isProcessing || _currentBackground == null) return;

    try {
      // Composite the frame with the background
      final composited = await _compositor?.compose(
        frame: frame,
        background: _currentBackground!,
      );

      if (composited != null) {
        _currentFrame = composited;
        onFrameReady?.call(composited);
      }
    } catch (e) {
      debugPrint('BackgroundProcessorService: Compositing error: $e');
    }
  }

  /// Dispose all resources
  Future<void> dispose() async {
    await stop();
    await _frameProcessor?.dispose();
    _compositor?.dispose();
    _isInitialized = false;
    debugPrint('BackgroundProcessorService: Disposed');
  }
}
