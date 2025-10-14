import 'package:flutter/material.dart';

class LoadingModalContainerContext {
  final BuildContext buildContext;
  final LoadingModalOptions options;
  final Widget content;

  const LoadingModalContainerContext({
    required this.buildContext,
    required this.options,
    required this.content,
  });
}

class LoadingModalContentContext {
  final BuildContext buildContext;
  final LoadingModalOptions options;
  final Widget spinner;
  final Widget text;

  const LoadingModalContentContext({
    required this.buildContext,
    required this.options,
    required this.spinner,
    required this.text,
  });
}

class LoadingModalSpinnerContext {
  final BuildContext buildContext;
  final LoadingModalOptions options;

  const LoadingModalSpinnerContext({
    required this.buildContext,
    required this.options,
  });
}

class LoadingModalTextContext {
  final BuildContext buildContext;
  final LoadingModalOptions options;

  const LoadingModalTextContext({
    required this.buildContext,
    required this.options,
  });
}

typedef LoadingModalContainerBuilder = Widget Function(
  LoadingModalContainerContext context,
  Widget defaultContainer,
);

typedef LoadingModalContentBuilder = Widget Function(
  LoadingModalContentContext context,
  Widget defaultContent,
);

typedef LoadingModalSpinnerBuilder = Widget Function(
  LoadingModalSpinnerContext context,
  Widget defaultSpinner,
);

typedef LoadingModalTextBuilder = Widget Function(
  LoadingModalTextContext context,
  Widget defaultText,
);

/// `LoadingModalOptions` - Configuration options for the `LoadingModal` widget.
///
/// ### Properties:
/// - `isVisible` (`bool`): Determines if the loading modal is visible.
/// - `backgroundColor` (`Color`): Background color of the modal overlay, defaulting to a semi-transparent black.
/// - `displayColor` (`Color`): Color for the loading indicator and loading text.
///
/// ### Example Usage:
/// ```dart
/// LoadingModalOptions(
///   isVisible: true,
///   backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
///   displayColor: Colors.white,
/// );
/// ```

class LoadingModalOptions {
  /// A boolean indicating whether the loading modal is visible.
  final bool isVisible;

  /// The background color of the loading modal overlay.
  final Color backgroundColor;

  /// The color of the loading indicator and loading text.
  final Color displayColor;

  /// The color of the modal overlay, defaults to semi-transparent black.
  final Color? overlayColor;

  /// Custom widget for loading text. If provided, [textBuilder] will be ignored.
  final Widget? loadingText;

  /// Whether to show the spinner/loading indicator.
  final bool showSpinner;

  /// Custom spinner widget. If provided, defaults to [CircularProgressIndicator].
  final Widget? spinner;

  /// Space between the spinner and the text, in logical pixels.
  final double spinnerTextSpacing;

  /// Fixed width for the content area. If not provided, defaults to 60% of screen width.
  final double? contentWidth;

  /// Padding for the content area.
  final EdgeInsetsGeometry? contentPadding;

  /// Decoration for the content container, including color, border, and shape.
  final Decoration? contentDecoration;

  /// Alignment for the content within the modal.
  final AlignmentGeometry contentAlignment;

  /// Custom builder for the entire modal container.
  final LoadingModalContainerBuilder? containerBuilder;

  /// Custom builder for the content area of the modal.
  final LoadingModalContentBuilder? contentBuilder;

  /// Custom builder for the spinner/loading indicator.
  final LoadingModalSpinnerBuilder? spinnerBuilder;

  /// Custom builder for the loading text.
  final LoadingModalTextBuilder? textBuilder;

  /// Constructs a `LoadingModalOptions` object with the given configuration.
  const LoadingModalOptions({
    required this.isVisible,
    this.backgroundColor = const Color.fromRGBO(0, 0, 0, 0.5),
    this.displayColor = Colors.black,
    this.overlayColor,
    this.loadingText,
    this.showSpinner = true,
    this.spinner,
    this.spinnerTextSpacing = 10,
    this.contentWidth,
    this.contentPadding,
    this.contentDecoration,
    this.contentAlignment = Alignment.center,
    this.containerBuilder,
    this.contentBuilder,
    this.spinnerBuilder,
    this.textBuilder,
  });
}

typedef LoadingModalType = Widget Function(
    {required LoadingModalOptions options});

/// `LoadingModal` - A loading modal overlay widget.
///
/// This modal displays a centered loading indicator with customizable background and indicator colors.
/// It blocks interactions outside the modal when visible.
///
/// ### Features:
/// - Fully covers the screen to create a loading overlay.
/// - Customizable background and indicator color.
/// - Prevents interaction outside the modal when visible.
///
/// ### Example Usage:
/// ```dart
/// LoadingModal(
///   options: LoadingModalOptions(
///     isVisible: true,
///     backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
///     displayColor: Colors.white,
///   ),
/// );
/// ```
class LoadingModal extends StatelessWidget {
  final LoadingModalOptions options;

  const LoadingModal({
    super.key,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    if (!options.isVisible) {
      return const SizedBox.shrink();
    }

    Widget spinner = options.showSpinner
        ? (options.spinner ??
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(options.displayColor),
                strokeWidth: 3,
              ),
            ))
        : const SizedBox.shrink();

    if (options.spinnerBuilder != null) {
      spinner = options.spinnerBuilder!(
        LoadingModalSpinnerContext(buildContext: context, options: options),
        spinner,
      );
    }

    Widget text = options.loadingText ??
        Text(
          'Loading...',
          style: TextStyle(color: options.displayColor),
        );

    if (options.textBuilder != null) {
      text = options.textBuilder!(
        LoadingModalTextContext(buildContext: context, options: options),
        text,
      );
    }

    final List<Widget> contentChildren = [];
    if (options.showSpinner) {
      contentChildren.add(spinner);
      if (options.spinnerTextSpacing > 0) {
        contentChildren.add(SizedBox(height: options.spinnerTextSpacing));
      }
    }

    contentChildren.add(text);

    Widget content = Container(
      width: options.contentWidth ?? MediaQuery.of(context).size.width * 0.6,
      padding: options.contentPadding ?? const EdgeInsets.all(20),
      decoration: options.contentDecoration ??
          BoxDecoration(
            color: options.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: contentChildren,
      ),
    );

    if (options.contentBuilder != null) {
      content = options.contentBuilder!(
        LoadingModalContentContext(
          buildContext: context,
          options: options,
          spinner: spinner,
          text: text,
        ),
        content,
      );
    }

    final Color overlayColor = options.overlayColor ??
        options.backgroundColor.withValues(
          alpha: (0.5 * options.backgroundColor.a).clamp(0.0, 1.0),
        );

    Widget modal = Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              color: overlayColor,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: options.contentAlignment,
            child: content,
          ),
        ),
      ],
    );

    if (options.containerBuilder != null) {
      modal = options.containerBuilder!(
        LoadingModalContainerContext(
          buildContext: context,
          options: options,
          content: content,
        ),
        modal,
      );
    }

    return modal;
  }
}
