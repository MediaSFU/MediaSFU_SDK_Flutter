import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/display_components/mini_card.dart'
    show
        MiniCardOptions,
        MiniCardContainerContext,
        MiniCardImageContext,
        MiniCardInitialsContext;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_animations.dart';

// Re-export the original context classes for compatibility
// (No need to define duplicates - we use the originals directly)

typedef ModernMiniCardType = Widget Function(
    {required MiniCardOptions options});

/// A modern compact avatar/badge widget with glassmorphic styling.
///
/// Features:
/// - Premium gradient backgrounds with glow effects
/// - Glassmorphic blur effects with frosted glass appearance
/// - Smooth loading transitions for network images
/// - Automatic fallback to styled initials
/// - Dark/light mode support
/// - Customizable size and styling
/// - Animated entry effects
/// Uses the same [MiniCardOptions] as the original component.
class ModernMiniCard extends StatefulWidget {
  final MiniCardOptions options;

  const ModernMiniCard({super.key, required this.options});

  @override
  State<ModernMiniCard> createState() => _ModernMiniCardState();
}

class _ModernMiniCardState extends State<ModernMiniCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: MediasfuAnimations.normal,
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;

    if (options.customBuilder != null) {
      return options.customBuilder!(options: options);
    }

    final hasImage =
        options.imageSource != null && options.imageSource!.isNotEmpty;

    final imageWidget = hasImage ? _buildImage(context) : null;
    final initialsWidget = _buildInitials(context);

    final defaultChild = hasImage ? imageWidget! : initialsWidget;

    final container = _buildContainer(context, defaultChild, hasImage);

    final wrappedContainer = AnimatedBuilder(
      animation: Listenable.merge([_scaleAnim, _opacityAnim]),
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
        );
      },
      child: container,
    );

    return options.containerBuilder?.call(
          MiniCardContainerContext(
            buildContext: context,
            options: options,
            hasImage: hasImage,
          ),
          wrappedContainer,
        ) ??
        wrappedContainer;
  }

  Widget _buildContainer(BuildContext context, Widget child, bool hasImage) {
    final options = widget.options;

    // Premium gradient with brand colors — theme-aware
    final defaultGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: options.isDarkMode
          ? [
              MediasfuColors.primary,
              MediasfuColors.secondary,
              MediasfuColors.accent,
            ]
          : [
              MediasfuColors.primaryLight,
              MediasfuColors.secondaryLight,
              MediasfuColors.accentLight,
            ],
      stops: const [0.0, 0.5, 1.0],
    );

    // Compute glow color
    final glowColor = options.glowColor ?? MediasfuColors.primary;

    BoxDecoration decoration;

    // Check if user provided a custom style (not the default empty BoxDecoration)
    final hasCustomStyle = options.customStyle != const BoxDecoration();
    if (hasCustomStyle) {
      decoration = options.customStyle;
    } else {
      // Use MediaSFU brand colors for better visual consistency
      // Dark mode: Use brand primary color for visibility
      // Light mode: Use a light surface color
      final backgroundColor = options.initialsBackgroundColor ??
          (options.isDarkMode
              ? MediasfuColors.primaryDark
                  .withOpacity(0.3) // Brand primary with transparency
              : MediasfuColors.surfaceElevated);

      decoration = BoxDecoration(
        shape: options.roundedImage ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: options.roundedImage ? null : BorderRadius.circular(12),
        gradient: options.showGradientBackground && !hasImage
            ? (options.gradient ?? defaultGradient)
            : null,
        color: !options.showGradientBackground && !hasImage
            ? backgroundColor
            : null,
        border: options.showBorder
            ? (options.enablePremiumBorder
                ? Border.all(
                    color: options.borderColor ??
                        MediasfuColors.primary.withOpacity(0.4),
                    width: options.borderWidth,
                  )
                : Border.all(
                    color: options.borderColor ??
                        (options.isDarkMode
                            ? Colors.white.withOpacity(
                                0.2) // More visible border in dark mode
                            : Colors.black.withOpacity(0.15)),
                    width: options.borderWidth,
                  ))
            : (options.isDarkMode && !hasImage
                // Add subtle border in dark mode even without showBorder for visual separation
                ? Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  )
                : null),
        boxShadow: options.showShadow
            ? (options.customShadow ??
                (options.enableGlow
                    ? [
                        BoxShadow(
                          color: glowColor.withOpacity(options.isDarkMode
                              ? options.glowIntensity
                              : options.glowIntensity * 0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(options.isDarkMode ? 0.3 : 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(options.isDarkMode ? 0.2 : 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]))
            : null,
      );
    }

    return Container(
      width: options.size,
      height: options.size,
      padding: options.padding,
      margin: options.margin,
      alignment: options.alignment ?? Alignment.center,
      decoration: decoration,
      child: child,
    );
  }

  Widget _buildImage(BuildContext context) {
    final options = widget.options;
    final borderRadius = options.imageStyle?.borderRadius ??
        BorderRadius.circular(options.roundedImage ? 9999 : 12);

    final image = ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        options.imageSource!,
        fit: options.imageFit,
        alignment: options.imageAlignment,
        width: options.size,
        height: options.size,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder(context);
        },
        errorBuilder: (_, __, ___) => _buildInitials(context),
      ),
    );

    final imageContainer = Container(
      padding: options.imageContainerPadding,
      margin: options.imageContainerMargin,
      decoration: options.imageContainerDecoration,
      child: image,
    );

    return options.imageBuilder?.call(
          MiniCardImageContext(
            buildContext: context,
            options: options,
          ),
          imageContainer,
        ) ??
        imageContainer;
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    final options = widget.options;

    return ClipRRect(
      borderRadius: BorderRadius.circular(options.roundedImage ? 9999 : 12),
      child: options.enableGlassmorphism
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: options.size,
                height: options.size,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MediasfuColors.primary.withOpacity(0.2),
                      MediasfuColors.secondary.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: options.size * 0.35,
                    height: options.size * 0.35,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        MediasfuColors.primary,
                      ),
                      backgroundColor: MediasfuColors.primary.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            )
          : Container(
              width: options.size,
              height: options.size,
              color: (options.isDarkMode ? Colors.white : Colors.black)
                  .withOpacity(0.1),
              child: Center(
                child: SizedBox(
                  width: options.size * 0.35,
                  height: options.size * 0.35,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      MediasfuColors.primary,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInitials(BuildContext context) {
    final options = widget.options;

    // Get the full name or truncate to 10 characters max
    String displayInitials = options.initials.trim();
    if (displayInitials.length > 10) {
      displayInitials = displayInitials.substring(0, 10);
    }

    final initialsContainer = Container(
      padding: options.initialsPadding,
      alignment: Alignment.center,
      decoration: options.initialsDecoration,
      child: Text(
        displayInitials,
        textAlign: TextAlign.center,
        style: options.initialsTextStyle ??
            TextStyle(
              fontSize: options.fontSize,
              color:
                  options.isDarkMode ? Colors.white : const Color(0xFF1F2937),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              shadows: options.isDarkMode
                  ? [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
      ),
    );

    return options.initialsBuilder?.call(
          MiniCardInitialsContext(
            buildContext: context,
            options: options,
          ),
          initialsContainer,
        ) ??
        initialsContainer;
  }
}
