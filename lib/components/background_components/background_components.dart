/// Background Components
///
/// Provides virtual background functionality for MediaSFU applications.
/// Uses conditional imports to automatically select the right implementation per platform.
library;

///
/// ## Architecture
///
/// ```
/// virtual_background_processor.dart  (Core logic - ALL platforms)
///              ↓
/// segmenter/segmenter.dart          (Conditional export router)
///              ↓
///    ┌─────────┴─────────┐
///    ↓                   ↓
/// segmenter_stub.dart   segmenter_mobile.dart
/// (Web/Desktop)         (Android/iOS - ML Kit)
/// ```
///
/// ## Platform Support
/// - ✅ Android: Full support via ML Kit
/// - ✅ iOS: Full support via ML Kit
/// - ⚠️ Web/Desktop: Graceful fallback (no segmentation)
///
/// ## Components
/// - [BackgroundModal] - UI for selecting virtual backgrounds
/// - [VirtualBackgroundProcessor] - Core processing logic
/// - [VirtualBackground] - Background configuration model
/// - [PresetBackgrounds] - Default preset backgrounds
/// - [BackgroundSegmenterBase] - Interface for platform segmenters

export 'virtual_background_types.dart';
export 'background_modal.dart';
export 'virtual_background_processor.dart';
export 'segmenter/segmenter.dart';

// Real-time processing components (React parity)
export 'frame_processor.dart';
export 'compositor.dart';
export 'virtual_stream_source.dart';
export 'processed_video_renderer.dart';
export 'virtual_background_channel.dart';
export 'background_processor_service.dart';
export 'background_video_display.dart';

// Legacy export for backward compatibility
export 'mlkit_segmenter_stub.dart';
