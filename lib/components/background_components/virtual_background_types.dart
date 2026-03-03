import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Enum representing the type of virtual background.
enum BackgroundType {
  /// No virtual background (camera only)
  none,

  /// Blurred background
  blur,

  /// Custom image background
  image,

  /// Solid color background
  color,

  /// Video background (animated)
  video,
}

/// Virtual background configuration.
class VirtualBackground {
  /// Unique identifier for the background
  final String id;

  /// Type of background
  final BackgroundType type;

  /// Display name
  final String name;

  /// Thumbnail for UI display
  final String? thumbnailUrl;

  /// Full image URL (for image type)
  final String? imageUrl;

  /// Image bytes (for local images)
  final Uint8List? imageBytes;

  /// Color value (for color type)
  final Color? color;

  /// Blur intensity (for blur type, 0.0 to 1.0)
  final double blurIntensity;

  /// Video URL (for video type)
  final String? videoUrl;

  /// Whether this is a default/preset background
  final bool isPreset;

  /// Whether this background is currently selected
  final bool isSelected;

  const VirtualBackground({
    required this.id,
    required this.type,
    required this.name,
    this.thumbnailUrl,
    this.imageUrl,
    this.imageBytes,
    this.color,
    this.blurIntensity = 0.5,
    this.videoUrl,
    this.isPreset = false,
    this.isSelected = false,
  });

  VirtualBackground copyWith({
    String? id,
    BackgroundType? type,
    String? name,
    String? thumbnailUrl,
    String? imageUrl,
    Uint8List? imageBytes,
    Color? color,
    double? blurIntensity,
    String? videoUrl,
    bool? isPreset,
    bool? isSelected,
  }) {
    return VirtualBackground(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
      color: color ?? this.color,
      blurIntensity: blurIntensity ?? this.blurIntensity,
      videoUrl: videoUrl ?? this.videoUrl,
      isPreset: isPreset ?? this.isPreset,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'thumbnailUrl': thumbnailUrl,
      'imageUrl': imageUrl,
      'color': color?.value,
      'blurIntensity': blurIntensity,
      'videoUrl': videoUrl,
      'isPreset': isPreset,
    };
  }

  factory VirtualBackground.fromMap(Map<String, dynamic> map) {
    return VirtualBackground(
      id: map['id'] ?? '',
      type: BackgroundType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => BackgroundType.none,
      ),
      name: map['name'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      imageUrl: map['imageUrl'],
      color: map['color'] != null ? Color(map['color']) : null,
      blurIntensity: (map['blurIntensity'] ?? 0.5).toDouble(),
      videoUrl: map['videoUrl'],
      isPreset: map['isPreset'] ?? false,
    );
  }

  /// Factory for creating a "None" (disabled) background
  factory VirtualBackground.none() {
    return const VirtualBackground(
      id: 'none',
      type: BackgroundType.none,
      name: 'None',
      isPreset: true,
    );
  }

  /// Factory for creating a blur background
  factory VirtualBackground.blur({
    double intensity = 0.5,
    String name = 'Blur',
  }) {
    return VirtualBackground(
      id: 'blur_${(intensity * 100).toInt()}',
      type: BackgroundType.blur,
      name: name,
      blurIntensity: intensity,
      isPreset: true,
    );
  }

  /// Factory for creating a color background
  factory VirtualBackground.color(Color color, {String? name}) {
    return VirtualBackground(
      id: 'color_${color.value}',
      type: BackgroundType.color,
      name: name ?? 'Color',
      color: color,
      isPreset: false,
    );
  }

  /// Factory for creating an image background
  factory VirtualBackground.image({
    required String id,
    required String name,
    String? imageUrl,
    Uint8List? imageBytes,
    String? thumbnailUrl,
    bool isPreset = false,
  }) {
    return VirtualBackground(
      id: id,
      type: BackgroundType.image,
      name: name,
      imageUrl: imageUrl,
      imageBytes: imageBytes,
      thumbnailUrl: thumbnailUrl ?? imageUrl,
      isPreset: isPreset,
    );
  }

  /// Get image bytes for this background.
  ///
  /// For image type: returns imageBytes if available, otherwise downloads from imageUrl.
  /// For color type: creates a solid color image.
  /// For blur type: returns null (blur is applied as an effect, not a replacement image).
  /// For none type: returns null.
  Future<Uint8List?> getImageBytes() async {
    switch (type) {
      case BackgroundType.image:
        // Return existing bytes if available
        if (imageBytes != null) {
          return imageBytes;
        }
        // Download from URL if available
        if (imageUrl != null) {
          try {
            final response = await http.get(Uri.parse(imageUrl!));
            if (response.statusCode == 200) {
              return response.bodyBytes;
            }
          } catch (e) {
            debugPrint('Failed to download background image: $e');
          }
        }
        return null;

      case BackgroundType.color:
        // Create a solid color image (256x256 is sufficient, will be scaled)
        if (color != null) {
          return _createSolidColorImage(color!, 256, 256);
        }
        return null;

      case BackgroundType.blur:
      case BackgroundType.none:
      case BackgroundType.video:
        // These don't need image bytes
        return null;
    }
  }

  /// Create a solid color PNG image.
  static Uint8List? _createSolidColorImage(Color color, int width, int height) {
    try {
      // Create a simple uncompressed BMP image (easier than PNG)
      // BMP format:
      // - 14 byte header
      // - 40 byte DIB header
      // - pixel data (BGRA, bottom-up)

      final int rowSize = (width * 4 + 3) & ~3; // BGRA, padded to 4 bytes
      final int pixelDataSize = rowSize * height;
      final int fileSize = 54 + pixelDataSize;

      final bytes = Uint8List(fileSize);
      final data = ByteData.view(bytes.buffer);

      // BMP Header
      bytes[0] = 0x42; // 'B'
      bytes[1] = 0x4D; // 'M'
      data.setUint32(2, fileSize, Endian.little);
      data.setUint32(10, 54, Endian.little); // Pixel data offset

      // DIB Header (BITMAPINFOHEADER)
      data.setUint32(14, 40, Endian.little); // Header size
      data.setInt32(18, width, Endian.little);
      data.setInt32(22, -height, Endian.little); // Negative = top-down
      data.setUint16(26, 1, Endian.little); // Color planes
      data.setUint16(28, 32, Endian.little); // Bits per pixel
      data.setUint32(30, 0, Endian.little); // No compression
      data.setUint32(34, pixelDataSize, Endian.little);

      // Fill with color (BGRA format)
      final b = color.blue;
      final g = color.green;
      final r = color.red;
      final a = color.alpha;

      int offset = 54;
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          bytes[offset++] = b;
          bytes[offset++] = g;
          bytes[offset++] = r;
          bytes[offset++] = a;
        }
        // Skip padding bytes (if any)
        while (offset % 4 != 54 % 4) {
          offset++;
        }
      }

      return bytes;
    } catch (e) {
      debugPrint('Failed to create solid color image: $e');
      return null;
    }
  }
}

/// Default preset backgrounds available in the SDK.
class PresetBackgrounds {
  PresetBackgrounds._();

  /// Base URL for MediaSFU background images
  static const String _baseUrl = 'https://mediasfu.com/images/backgrounds';

  /// Default image names available from MediaSFU
  static const List<String> _defaultImageNames = [
    'wall',
    'wall2',
    'shelf',
    'clock',
    'desert',
    'flower',
  ];

  /// Get thumbnail URL for an image
  static String getThumbnailUrl(String imageName) =>
      '$_baseUrl/${imageName}_thumbnail.jpg';

  /// Get small resolution URL for an image
  static String getSmallUrl(String imageName) =>
      '$_baseUrl/${imageName}_small.jpg';

  /// Get large resolution URL for an image
  static String getLargeUrl(String imageName) =>
      '$_baseUrl/${imageName}_large.jpg';

  /// Get full resolution URL for an image
  static String getFullUrl(String imageName) => '$_baseUrl/$imageName.jpg';

  /// Get all default preset backgrounds
  static List<VirtualBackground> get all => [
        VirtualBackground.none(),
        ...blurs,
        ...colors,
        ...images,
      ];

  /// Get blur presets only
  static List<VirtualBackground> get blurs => [
        VirtualBackground.blur(intensity: 0.3, name: 'Light Blur'),
        VirtualBackground.blur(intensity: 0.6, name: 'Medium Blur'),
        VirtualBackground.blur(intensity: 0.9, name: 'Strong Blur'),
      ];

  /// Get color presets only
  static List<VirtualBackground> get colors => [
        VirtualBackground.color(Colors.blue.shade700, name: 'Blue'),
        VirtualBackground.color(Colors.green.shade700, name: 'Green'),
        VirtualBackground.color(Colors.purple.shade700, name: 'Purple'),
        VirtualBackground.color(Colors.grey.shade800, name: 'Dark Gray'),
        VirtualBackground.color(Colors.white, name: 'White'),
      ];

  /// Get default image presets from MediaSFU
  static List<VirtualBackground> get images => _defaultImageNames
      .map((name) => VirtualBackground.image(
            id: 'preset_$name',
            name: _formatName(name),
            thumbnailUrl: getThumbnailUrl(name),
            imageUrl: getFullUrl(name),
            isPreset: true,
          ))
      .toList();

  /// Get an image preset with appropriate resolution based on target
  static VirtualBackground getImageForResolution(
    String imageName,
    String targetResolution,
  ) {
    final String imageUrl;
    if (targetResolution == 'fhd' || targetResolution == 'qhd') {
      imageUrl = getLargeUrl(imageName);
    } else {
      imageUrl = getFullUrl(imageName);
    }

    return VirtualBackground.image(
      id: 'preset_$imageName',
      name: _formatName(imageName),
      thumbnailUrl: getThumbnailUrl(imageName),
      imageUrl: imageUrl,
      isPreset: true,
    );
  }

  /// Format image name for display
  static String _formatName(String name) {
    // Capitalize first letter and handle special cases
    if (name == 'wall2') return 'Wall 2';
    return name[0].toUpperCase() + name.substring(1);
  }
}

/// Result of background segmentation processing.
///
/// This mirrors the React implementation where `selfieSegmentation.onResults`
/// receives the segmentation mask and confidence data.
class SegmentationResult {
  /// The processed frame with background replaced
  final Uint8List? processedFrame;

  /// The segmentation mask (grayscale: 0=background, 255=person)
  final Uint8List? mask;

  /// Mask width (may differ from input if enableRawSizeMask is false)
  final int? maskWidth;

  /// Mask height (may differ from input if enableRawSizeMask is false)
  final int? maskHeight;

  /// Per-pixel confidence (0.0-1.0) from ML Kit, if available
  final double? confidence;

  /// Processing time in milliseconds
  final int processingTimeMs;

  /// Whether processing was successful
  final bool success;

  /// Error message if processing failed
  final String? error;

  const SegmentationResult({
    this.processedFrame,
    this.mask,
    this.maskWidth,
    this.maskHeight,
    this.confidence,
    this.processingTimeMs = 0,
    this.success = true,
    this.error,
  });

  factory SegmentationResult.error(String message) {
    return SegmentationResult(
      success: false,
      error: message,
    );
  }
}
