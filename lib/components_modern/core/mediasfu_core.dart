/// MediaSFU Modern Core
///
/// This library exports the core infrastructure for the modern MediaSFU UI,
/// including the theme system and premium widget primitives.
///
/// ## Quick Start
///
/// Import the core library:
/// ```dart
/// import 'package:mediasfu_sdk/components_modern/core/mediasfu_core.dart';
/// ```
///
/// ## Theme System
///
/// The theme system provides:
/// - [MediasfuColors] - Blue/cyan/teal color palette with glow utilities
/// - [MediasfuTypography] - Inter font family with Material 3 scale
/// - [MediasfuSpacing] - Consistent spacing tokens
/// - [MediasfuAnimations] - Spring physics and timing
/// - [MediasfuBorders] - Border utilities and animated borders
/// - [MediasfuTheme] - Ready-to-use ThemeData
/// - [ModernStyleOptions] - Component style configuration
///
/// ## Premium Widgets
///
/// Reusable widget primitives:
/// - [StyledContainer] - Unified container with glow/neumorphism/glass effects
/// - [PremiumButton] - Buttons with multiple style variants
/// - [GlowContainer] - Container with glowing effects
/// - [NeumorphicContainer] - Soft 3D containers
/// - [AnimatedGradientBackground] - Animated gradient backgrounds
/// - [SkeletonLoader] - Shimmer loading placeholders
/// - Animation utilities: StaggeredAnimationList, AnimatedEntry, etc.
///
/// ## Example
///
/// ```dart
/// import 'package:mediasfu_sdk/components_modern/core/mediasfu_core.dart';
///
/// Widget build(BuildContext context) {
///   return StyledContainer(
///     enableGlow: true,
///     glowColor: MediasfuColors.primary,
///     child: PremiumButton(
///       label: 'Join Meeting',
///       variant: PremiumButtonVariant.gradient,
///       onPressed: () => joinMeeting(),
///     ),
///   );
/// }
/// ```
library;

export 'theme/mediasfu_theme_exports.dart';
export 'widgets/premium_widgets.dart';
