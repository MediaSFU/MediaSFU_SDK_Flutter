/// MediaSFU Modern Theme System
///
/// This library exports the complete theming infrastructure for the
/// modern MediaSFU UI, including colors, typography, spacing, animations,
/// borders, and style options.
///
/// ## Quick Start
///
/// Import the theme system:
/// ```dart
/// import 'package:mediasfu_sdk/components_modern/core/theme/mediasfu_theme_exports.dart';
/// ```
///
/// Use the theme in your app:
/// ```dart
/// MaterialApp(
///   theme: MediasfuTheme.light(),
///   darkTheme: MediasfuTheme.dark(),
/// )
/// ```
///
/// ## Available Exports
///
/// - [MediasfuColors] - Color tokens and utility methods
/// - [MediasfuTypography] - Text styles and font configuration
/// - [MediasfuSpacing] - Spacing constants and inset helpers
/// - [MediasfuAnimations] - Animation durations, curves, and springs
/// - [MediasfuBorders] - Border widths, radii, and gradient borders
/// - [MediasfuTheme] - ThemeData factory for light/dark modes
/// - [ModernStyleOptions] - Style configuration for components
library;

export 'mediasfu_animations.dart';
export 'mediasfu_borders.dart';
export 'mediasfu_colors.dart';
export 'mediasfu_spacing.dart';
export 'mediasfu_theme.dart';
export 'mediasfu_typography.dart';
export 'modern_style_options.dart';
