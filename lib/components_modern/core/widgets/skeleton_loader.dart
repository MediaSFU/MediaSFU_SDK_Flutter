import 'package:flutter/material.dart';
import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_animations.dart';

/// A skeleton loading placeholder with shimmer animation.
///
/// Supports:
/// - Various shapes (rectangle, circle, text lines)
/// - Customizable shimmer direction and speed
/// - Multiple skeleton presets for common UI elements
class SkeletonLoader extends StatefulWidget {
  /// Width of the skeleton. Required for non-circle shapes.
  final double? width;

  /// Height of the skeleton.
  final double height;

  /// Border radius for rounded corners.
  final double borderRadius;

  /// Whether the skeleton is a circle.
  final bool isCircle;

  /// Duration of one shimmer cycle.
  final Duration shimmerDuration;

  /// Base color of the skeleton.
  final Color? baseColor;

  /// Highlight color of the shimmer.
  final Color? highlightColor;

  /// Whether the shimmer animation is running.
  final bool isLoading;

  /// Margin around the skeleton.
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    this.isCircle = false,
    this.shimmerDuration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
    this.isLoading = true,
    this.margin,
  });

  /// Creates a circular skeleton (avatar placeholder).
  factory SkeletonLoader.circle({
    Key? key,
    required double size,
    Duration shimmerDuration = const Duration(milliseconds: 1500),
    Color? baseColor,
    Color? highlightColor,
    bool isLoading = true,
    EdgeInsetsGeometry? margin,
  }) {
    return SkeletonLoader(
      key: key,
      width: size,
      height: size,
      isCircle: true,
      shimmerDuration: shimmerDuration,
      baseColor: baseColor,
      highlightColor: highlightColor,
      isLoading: isLoading,
      margin: margin,
    );
  }

  /// Creates a text line skeleton.
  factory SkeletonLoader.text({
    Key? key,
    double? width,
    double height = 14,
    Duration shimmerDuration = const Duration(milliseconds: 1500),
    Color? baseColor,
    Color? highlightColor,
    bool isLoading = true,
    EdgeInsetsGeometry? margin,
  }) {
    return SkeletonLoader(
      key: key,
      width: width,
      height: height,
      borderRadius: 4,
      shimmerDuration: shimmerDuration,
      baseColor: baseColor,
      highlightColor: highlightColor,
      isLoading: isLoading,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
    );
  }

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.shimmerDuration,
    );

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SkeletonLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base =
        widget.baseColor ?? MediasfuColors.shimmerBase(darkMode: isDark);
    final highlight = widget.highlightColor ??
        MediasfuColors.shimmerHighlight(darkMode: isDark);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: widget.isCircle
                ? null
                : BorderRadius.circular(widget.borderRadius),
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            gradient: LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
            ),
          ),
        );
      },
    );
  }
}

/// A skeleton paragraph with multiple text lines.
class SkeletonParagraph extends StatelessWidget {
  /// Number of lines to display.
  final int lines;

  /// Height of each line.
  final double lineHeight;

  /// Spacing between lines.
  final double lineSpacing;

  /// Width of the last line (as a fraction 0.0-1.0).
  final double lastLineWidth;

  /// Base color.
  final Color? baseColor;

  /// Highlight color.
  final Color? highlightColor;

  /// Whether loading.
  final bool isLoading;

  const SkeletonParagraph({
    super.key,
    this.lines = 3,
    this.lineHeight = 14,
    this.lineSpacing = 8,
    this.lastLineWidth = 0.6,
    this.baseColor,
    this.highlightColor,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lines, (index) {
        final isLast = index == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? lineSpacing : 0),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: isLast ? lastLineWidth : 1.0,
            child: SkeletonLoader.text(
              height: lineHeight,
              baseColor: baseColor,
              highlightColor: highlightColor,
              isLoading: isLoading,
              margin: EdgeInsets.zero,
            ),
          ),
        );
      }),
    );
  }
}

/// A skeleton card layout preset.
class SkeletonCard extends StatelessWidget {
  /// Whether to show an avatar.
  final bool showAvatar;

  /// Avatar size.
  final double avatarSize;

  /// Number of text lines.
  final int textLines;

  /// Whether to show an image area.
  final bool showImage;

  /// Height of the image area.
  final double imageHeight;

  /// Border radius.
  final double borderRadius;

  /// Padding inside the card.
  final EdgeInsetsGeometry? padding;

  /// Whether loading.
  final bool isLoading;

  const SkeletonCard({
    super.key,
    this.showAvatar = true,
    this.avatarSize = 40,
    this.textLines = 2,
    this.showImage = false,
    this.imageHeight = 120,
    this.borderRadius = 16,
    this.padding,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? MediasfuColors.cardDark : MediasfuColors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: MediasfuColors.elevation(level: 1, darkMode: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showImage) ...[
            SkeletonLoader(
              width: double.infinity,
              height: imageHeight,
              borderRadius: borderRadius - 4,
              isLoading: isLoading,
            ),
            const SizedBox(height: 16),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showAvatar) ...[
                SkeletonLoader.circle(
                  size: avatarSize,
                  isLoading: isLoading,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: 120,
                      height: 16,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 8),
                    SkeletonParagraph(
                      lines: textLines,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A skeleton list item preset.
class SkeletonListItem extends StatelessWidget {
  /// Whether to show a leading element.
  final bool showLeading;

  /// Size of the leading element.
  final double leadingSize;

  /// Whether the leading element is a circle.
  final bool leadingIsCircle;

  /// Whether to show a trailing element.
  final bool showTrailing;

  /// Number of text lines.
  final int textLines;

  /// Padding.
  final EdgeInsetsGeometry? padding;

  /// Whether loading.
  final bool isLoading;

  const SkeletonListItem({
    super.key,
    this.showLeading = true,
    this.leadingSize = 48,
    this.leadingIsCircle = true,
    this.showTrailing = false,
    this.textLines = 2,
    this.padding,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          if (showLeading) ...[
            leadingIsCircle
                ? SkeletonLoader.circle(
                    size: leadingSize,
                    isLoading: isLoading,
                  )
                : SkeletonLoader(
                    width: leadingSize,
                    height: leadingSize,
                    borderRadius: 8,
                    isLoading: isLoading,
                  ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonLoader(
                  width: 140,
                  height: 14,
                  isLoading: isLoading,
                ),
                if (textLines > 1) ...[
                  const SizedBox(height: 8),
                  SkeletonLoader(
                    height: 12,
                    isLoading: isLoading,
                  ),
                ],
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: 12),
            SkeletonLoader(
              width: 24,
              height: 24,
              borderRadius: 4,
              isLoading: isLoading,
            ),
          ],
        ],
      ),
    );
  }
}

/// A wrapper that shows skeleton or content based on loading state.
class SkeletonWrapper extends StatelessWidget {
  /// The actual content to show when loaded.
  final Widget child;

  /// The skeleton to show when loading.
  final Widget skeleton;

  /// Whether currently loading.
  final bool isLoading;

  /// Duration of the fade transition.
  final Duration fadeDuration;

  const SkeletonWrapper({
    super.key,
    required this.child,
    required this.skeleton,
    required this.isLoading,
    this.fadeDuration = MediasfuAnimations.normal,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: fadeDuration,
      child: isLoading ? skeleton : child,
    );
  }
}
