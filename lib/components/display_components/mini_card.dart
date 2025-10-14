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
  });
}

typedef MiniCardType = Widget Function({required MiniCardOptions options});

class MiniCard extends StatelessWidget {
  final MiniCardOptions options;

  const MiniCard({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    if (options.customBuilder != null) {
      return options.customBuilder!(options: options);
    }

    final hasImage = options.imageSource != null && options.imageSource!.isNotEmpty;

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

    final decoration = options.imageContainerDecoration ?? const BoxDecoration();

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
