import 'package:flutter/material.dart';

class MiniCardContainerContext {
  final BuildContext buildContext;
  final MiniCardOptions options;
  final bool hasImage;

  const MiniCardContainerContext({
    required this.buildContext,
    required this.options,
    required this.hasImage,
  });
}

class MiniCardImageContext {
  final BuildContext buildContext;
  final MiniCardOptions options;

  const MiniCardImageContext({
    required this.buildContext,
    required this.options,
  });
}

class MiniCardInitialsContext {
  final BuildContext buildContext;
  final MiniCardOptions options;

  const MiniCardInitialsContext({
    required this.buildContext,
    required this.options,
  });
}

typedef MiniCardContainerBuilder = Widget Function(
  MiniCardContainerContext context,
  Widget defaultContainer,
);

typedef MiniCardImageBuilder = Widget Function(
  MiniCardImageContext context,
  Widget defaultImage,
);

typedef MiniCardInitialsBuilder = Widget Function(
  MiniCardInitialsContext context,
  Widget defaultInitials,
);

/// Configuration options for the `MiniCard` widget.
///
/// Provides properties to customize the appearance of a small participant avatar/badge,
/// displaying either an image or text initials with extensive styling options.
///
/// **Core Display Properties:**
/// - `initials`: Text fallback when no image provided (e.g., "JD" for "John Doe")
/// - `fontSize`: Text size for initials (default: 14)
/// - `imageSource`: Optional network image URL; if null/empty, displays initials
/// - `roundedImage`: If true, applies circular clipping (borderRadius=9999); default=true
///
/// **Container Styling:**
/// - `customStyle`: BoxDecoration for outer container (background, border, etc.)
/// - `padding`/`margin`/`alignment`: Positioning and spacing for outer container
///
/// **Initials Styling:**
/// - `initialsDecoration`: BoxDecoration for initials wrapper (background color, etc.)
/// - `initialsPadding`: Padding around initials text
/// - `initialsTextStyle`: TextStyle override (font, color, weight); default=black/600
///
/// **Image Styling:**
/// - `imageStyle`: BoxDecoration for image wrapper (border radius extracted for ClipRRect)
/// - `imageContainerDecoration`: BoxDecoration for image wrapper container
/// - `imageContainerPadding`/`imageContainerMargin`: Spacing for image wrapper
/// - `imageFit`: How image fills bounds (default: BoxFit.cover)
/// - `imageAlignment`: Image alignment within bounds (default: Alignment.center)
///
/// **Builder Hooks (3):**
/// - `customBuilder`: Full widget replacement; receives MiniCardOptions
/// - `containerBuilder`: Override outer Container; receives MiniCardContainerContext + default
/// - `imageBuilder`: Override image display; receives MiniCardImageContext + default
/// - `initialsBuilder`: Override initials display; receives MiniCardInitialsContext + default
///
/// **Usage Patterns:**
/// 1. **Default Initials Display:**
///    ```dart
///    MiniCard(
///      options: MiniCardOptions(
///        initials: 'JD',
///        customStyle: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
///      ),
///    )
///    ```
///
/// 2. **Image Avatar:**
///    ```dart
///    MiniCard(
///      options: MiniCardOptions(
///        initials: 'JD',
///        imageSource: 'https://example.com/avatar.jpg',
///        roundedImage: true,
///      ),
///    )
///    ```
///
/// 3. **Custom Builder Hook:**
///    ```dart
///    MiniCard(
///      options: MiniCardOptions(
///        initials: 'JD',
///        containerBuilder: (context, defaultContainer) {
///          return GestureDetector(
///            onTap: () => print('Avatar tapped'),
///            child: defaultContainer,
///          );
///        },
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Can be overridden via `MediasfuUICustomOverrides` using `ComponentOverride<MiniCardOptions>`:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   miniCardOptions: ComponentOverride<MiniCardOptions>(
///     builder: (existingOptions) => MiniCardOptions(
///       initials: existingOptions.initials,
///       imageSource: existingOptions.imageSource,
///       customStyle: BoxDecoration(border: Border.all(color: Colors.gold, width: 2)),
///     ),
///   ),
/// ),
/// ```
///
/// **Implementation Notes:**
/// - Image loading failures automatically fallback to initials display
/// - Border radius extraction from imageStyle.borderRadius for ClipRRect compatibility
/// - Builder hooks receive both context and default widget for wrapping patterns
class MiniCardOptions {
  final String initials;
  final double fontSize;
  final BoxDecoration customStyle;
  final String? imageSource;
  final bool roundedImage;
  final BoxDecoration? imageStyle;
  final MiniCardType? customBuilder;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignment;
  final BoxDecoration? initialsDecoration;
  final EdgeInsetsGeometry? initialsPadding;
  final TextStyle? initialsTextStyle;
  final BoxDecoration? imageContainerDecoration;
  final EdgeInsetsGeometry? imageContainerPadding;
  final EdgeInsetsGeometry? imageContainerMargin;
  final BoxFit imageFit;
  final AlignmentGeometry imageAlignment;
  final MiniCardContainerBuilder? containerBuilder;
  final MiniCardImageBuilder? imageBuilder;
  final MiniCardInitialsBuilder? initialsBuilder;

  /// Size of the mini card.
  /// Used by modern styling.
  final double size;

  /// Enable glassmorphism effects.
  /// Used by modern styling for blur effects.
  final bool enableGlassmorphism;

  /// Show gradient background.
  /// Used by modern styling.
  final bool showGradientBackground;

  /// Optional gradient.
  /// Used by modern styling.
  final Gradient? gradient;

  /// Dark mode toggle.
  /// Used by modern styling for theme.
  final bool isDarkMode;

  /// Show border.
  /// Used by modern styling.
  final bool showBorder;

  /// Border color.
  /// Used by modern styling.
  final Color? borderColor;

  /// Border width.
  /// Used by modern styling.
  final double borderWidth;

  /// Show shadow.
  /// Used by modern styling.
  final bool showShadow;

  /// Custom shadow.
  /// Used by modern styling.
  final List<BoxShadow>? customShadow;

  /// Initials background color.
  /// Used by modern styling.
  final Color? initialsBackgroundColor;

  /// Enable glow effect.
  /// Used by modern premium styling.
  final bool enableGlow;

  /// Glow color.
  /// Used by modern premium styling.
  final Color? glowColor;

  /// Glow intensity.
  /// Used by modern premium styling.
  final double glowIntensity;

  /// Enable premium border styling.
  /// Used by modern premium styling.
  final bool enablePremiumBorder;

  const MiniCardOptions({
    required this.initials,
    this.fontSize = 14,
    this.customStyle = const BoxDecoration(),
    this.imageSource,
    this.roundedImage = true,
    this.imageStyle,
    this.customBuilder,
    this.padding,
    this.margin,
    this.alignment,
    this.initialsDecoration,
    this.initialsPadding,
    this.initialsTextStyle,
    this.imageContainerDecoration,
    this.imageContainerPadding,
    this.imageContainerMargin,
    this.imageFit = BoxFit.cover,
    this.imageAlignment = Alignment.center,
    this.containerBuilder,
    this.imageBuilder,
    this.initialsBuilder,
    this.size = 40.0,
    this.enableGlassmorphism = false,
    this.showGradientBackground = false,
    this.gradient,
    this.isDarkMode = false,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 1.0,
    this.showShadow = false,
    this.customShadow,
    this.initialsBackgroundColor,
    this.enableGlow = false,
    this.glowColor,
    this.glowIntensity = 0.5,
    this.enablePremiumBorder = false,
  });
}

typedef MiniCardType = Widget Function({required MiniCardOptions options});

/// A compact avatar/badge widget displaying participant image or initials.
///
/// Renders a small circular or rectangular card showing either:
/// - Network image (if `imageSource` provided and loads successfully)
/// - Text initials (if no image or image fails to load)
///
/// **Rendering Logic:**
/// 1. If `customBuilder` provided → delegates full rendering to custom function
/// 2. If `imageSource` non-empty → attempts network image load
/// 3. If image load fails or no source → displays initials text
/// 4. Applies builder hooks at each layer: container, image, initials
///
/// **Layout Structure:**
/// ```
/// Container (containerBuilder)
///   ├─ padding/margin/alignment/decoration
///   └─ IF hasImage:
///      └─ Container (imageBuilder)
///         └─ ClipRRect (borderRadius)
///            └─ Image.network (with errorBuilder → initials)
///      ELSE:
///      └─ Container (initialsBuilder)
///         └─ Text (initials)
/// ```
///
/// **Builder Hook Priorities:**
/// - `customBuilder` → full widget replacement (ignores all other props)
/// - `containerBuilder` → wraps outer container (receives default + context)
/// - `imageBuilder` → wraps image container (receives default + context)
/// - `initialsBuilder` → wraps initials text (receives default + context)
///
/// **Common Use Cases:**
/// 1. **Participant Avatar in Grid:**
///    ```dart
///    MiniCard(
///      options: MiniCardOptions(
///        initials: participant.name.substring(0, 2).toUpperCase(),
///        imageSource: participant.photoURL,
///        customStyle: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
///      ),
///    )
///    ```
///
/// 2. **Fallback Display:**
///    ```dart
///    MiniCard(
///      options: MiniCardOptions(
///        initials: 'NA',
///        fontSize: 12,
///        initialsTextStyle: TextStyle(color: Colors.grey),
///      ),
///    )
///    ```
///
/// 3. **Custom Interactive Badge:**
///    ```dart
///    MiniCard(
///      options: MiniCardOptions(
///        initials: 'Host',
///        containerBuilder: (context, defaultContainer) {
///          return Tooltip(
///            message: 'Meeting Host',
///            child: defaultContainer,
///          );
///        },
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Integrates with `MediasfuUICustomOverrides` for global styling:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   miniCardOptions: ComponentOverride<MiniCardOptions>(
///     builder: (existingOptions) => MiniCardOptions(
///       initials: existingOptions.initials,
///       imageSource: existingOptions.imageSource,
///       roundedImage: true,
///       customStyle: BoxDecoration(
///         gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
///         shape: BoxShape.circle,
///       ),
///     ),
///   ),
/// ),
/// ```
///
/// **Implementation Details:**
/// - Uses ClipRRect for circular/rounded image clipping
/// - Image errorBuilder automatically falls back to initials
/// - Border radius extracted from imageStyle.borderRadius if provided
/// - All builder hooks receive both BuildContext and default widget
/// - Initials centered with default black/600 styling
class MiniCard extends StatelessWidget {
  final MiniCardOptions options;

  const MiniCard({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    if (options.customBuilder != null) {
      return options.customBuilder!(options: options);
    }

    final hasImage =
        options.imageSource != null && options.imageSource!.isNotEmpty;

    final imageWidget = hasImage ? _buildImage(context) : null;
    final initialsWidget = _buildInitials(context);

    final defaultChild = hasImage ? imageWidget! : initialsWidget;

    final container = Container(
      padding: options.padding,
      margin: options.margin,
      alignment: options.alignment,
      decoration: options.customStyle,
      child: defaultChild,
    );

    return options.containerBuilder?.call(
          MiniCardContainerContext(
            buildContext: context,
            options: options,
            hasImage: hasImage,
          ),
          container,
        ) ??
        container;
  }

  Widget _buildImage(BuildContext context) {
    final borderRadius = options.imageStyle?.borderRadius ??
        BorderRadius.circular(options.roundedImage ? 9999 : 0);

    final decoration =
        options.imageContainerDecoration ?? const BoxDecoration();

    final image = ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        options.imageSource!,
        fit: options.imageFit,
        alignment: options.imageAlignment,
        errorBuilder: (_, __, ___) => _buildInitials(context),
      ),
    );

    final imageContainer = Container(
      padding: options.imageContainerPadding,
      margin: options.imageContainerMargin,
      decoration: decoration,
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

  Widget _buildInitials(BuildContext context) {
    final initialsContainer = Container(
      padding: options.initialsPadding,
      alignment: Alignment.center,
      decoration: options.initialsDecoration,
      child: Text(
        options.initials,
        textAlign: TextAlign.center,
        style: options.initialsTextStyle ??
            TextStyle(
              fontSize: options.fontSize,
              color: Colors.black,
              fontWeight: FontWeight.w600,
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
