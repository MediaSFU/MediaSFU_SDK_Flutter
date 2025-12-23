/// Segmenter - Conditional Export Router
///
/// This file uses Dart's conditional imports to automatically select
/// the correct platform-specific implementation at compile time.
///
/// ## How It Works
///
/// ```dart
/// export 'segmenter_stub.dart'          // Default (fallback)
///     if (dart.library.io) 'segmenter_mobile.dart';  // Android/iOS
/// ```
///
/// The compiler picks the RIGHT implementation based on the target platform.
/// No runtime checks needed - it's resolved at build time.
///
/// ## Adding Web Support (Future)
///
/// When TensorFlow.js support is added:
/// ```dart
/// export 'segmenter_stub.dart'
///     if (dart.library.html) 'segmenter_web.dart'    // Web
///     if (dart.library.io) 'segmenter_mobile.dart';  // Mobile
/// ```
///
/// ## Usage
///
/// ```dart
/// import 'package:mediasfu_sdk/components/background_components/segmenter/segmenter.dart';
///
/// final segmenter = createSegmenter();
/// await segmenter.initialize();
/// ```

library;

// Re-export interface for type definitions
export 'segmenter_interface.dart';

// Conditional export: Use MobileSegmenter on Android/iOS, StubSegmenter otherwise
export 'segmenter_stub.dart' if (dart.library.io) 'segmenter_mobile.dart';
