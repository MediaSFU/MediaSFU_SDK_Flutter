import 'dart:async';
import 'package:flutter/material.dart';

/// AlertComponentOptions - Configuration options for the `AlertComponent` widget.
///
/// Example:
/// ```dart
/// AlertComponent(
///   options: AlertComponentOptions(
///     visible: true,
///     message: "Operation successful!",
///     type: "success",
///     duration: 3000,
///     onHide: () => print("Alert hidden"),
///     textColor: Colors.white,
///   ),
/// );
/// ```

typedef AlertTapCallback = bool Function();

/// Context provided when customizing the alert message widget.
class AlertMessageContext {
  final AlertComponentOptions options;
  final Widget defaultMessage;

  AlertMessageContext({
    required this.options,
    required this.defaultMessage,
  });
}

/// Context provided when customizing the alert content container.
class AlertContentContext {
  final AlertComponentOptions options;
  final Widget defaultContent;
  final Widget message;

  AlertContentContext({
    required this.options,
    required this.defaultContent,
    required this.message,
  });
}

/// Context provided when customizing the overlay that hosts the alert.
class AlertOverlayContext {
  final AlertComponentOptions options;
  final Widget defaultOverlay;
  final Widget content;

  AlertOverlayContext({
    required this.options,
    required this.defaultOverlay,
    required this.content,
  });
}

typedef AlertMessageBuilder = Widget Function(AlertMessageContext context);
typedef AlertContentBuilder = Widget Function(AlertContentContext context);
typedef AlertOverlayBuilder = Widget Function(AlertOverlayContext context);

class AlertComponentOptions {
  final bool visible;
  final String message;
  final String type;
  final int duration;
  final VoidCallback? onHide;
  final Color textColor;
  final Color? successColor;
  final Color? dangerColor;
  final double overlayOpacity;
  final Color overlayColor;
  final EdgeInsetsGeometry? overlayPadding;
  final AlignmentGeometry overlayAlignment;
  final bool overlayDismissible;
  final AlertTapCallback? onOverlayTap;
  final bool contentDismissible;
  final AlertTapCallback? onContentTap;
  final BoxDecoration? containerDecoration;
  final EdgeInsetsGeometry? containerPadding;
  final EdgeInsetsGeometry? containerMargin;
  final Clip? containerClipBehavior;
  final double? maxWidth;
  final double? minWidth;
  final TextStyle? messageStyle;
  final EdgeInsetsGeometry? messagePadding;
  final TextAlign messageAlignment;
  final int? messageMaxLines;
  final double contentSpacing;
  final CrossAxisAlignment contentAlignment;
  final MainAxisSize contentMainAxisSize;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? trailing;
  final AlertMessageBuilder? messageBuilder;
  final AlertContentBuilder? contentBuilder;
  final AlertOverlayBuilder? overlayBuilder;
  final Duration animationDuration;
  final Curve animationCurve;

  AlertComponentOptions({
    required this.visible,
    required this.message,
    this.type = 'success',
    this.duration = 4000,
    this.onHide,
    this.textColor = Colors.black,
    this.successColor,
    this.dangerColor,
    this.overlayOpacity = 0.5,
    this.overlayColor = Colors.black,
    this.overlayPadding = const EdgeInsets.all(16),
    this.overlayAlignment = Alignment.center,
    this.overlayDismissible = true,
    this.onOverlayTap,
    this.contentDismissible = true,
    this.onContentTap,
    this.containerDecoration,
    this.containerPadding =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    this.containerMargin,
    this.containerClipBehavior,
    this.maxWidth = 420,
    this.minWidth,
    this.messageStyle,
    this.messagePadding,
    this.messageAlignment = TextAlign.center,
    this.messageMaxLines,
    this.contentSpacing = 12,
    this.contentAlignment = CrossAxisAlignment.center,
    this.contentMainAxisSize = MainAxisSize.min,
    this.actions,
    this.leading,
    this.trailing,
    this.messageBuilder,
    this.contentBuilder,
    this.overlayBuilder,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
  })  : assert(duration >= 0, 'duration must be zero or positive'),
        assert(overlayOpacity >= 0 && overlayOpacity <= 1,
            'overlayOpacity must be between 0 and 1'),
        assert(maxWidth == null || maxWidth > 0,
            'maxWidth must be positive when provided'),
        assert(
            minWidth == null || minWidth >= 0, 'minWidth cannot be negative'),
        assert(
          maxWidth == null || minWidth == null || maxWidth >= minWidth,
          'maxWidth must be greater than or equal to minWidth',
        );
}

typedef AlertComponentType = Widget Function(
    {required AlertComponentOptions options});

/// AlertComponent - A widget for displaying alerts with customizable options.
///
/// Example:
/// ```dart
/// AlertComponent(
///   options: AlertComponentOptions(
///     visible: true,
///     message: "An error occurred",
///     type: "error",
///     duration: 3000,
///     onHide: () => print("Alert hidden"),
///     textColor: Colors.white,
///   ),
/// );
/// ```
class AlertComponent extends StatefulWidget {
  final AlertComponentOptions options;

  const AlertComponent({
    super.key,
    required this.options,
  });

  @override
  _AlertComponentState createState() => _AlertComponentState();
}

class _AlertComponentState extends State<AlertComponent> {
  String _alertType = 'success';
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _alertType = widget.options.type;
    _maybeScheduleDismiss();
  }

  @override
  void didUpdateWidget(covariant AlertComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.options.type != oldWidget.options.type) {
      _updateAlertType();
    }

    if (widget.options.visible != oldWidget.options.visible ||
        widget.options.duration != oldWidget.options.duration) {
      _maybeScheduleDismiss();
    }
  }

  void _updateAlertType() {
    final String nextType = widget.options.type;
    if (_alertType != nextType) {
      setState(() {
        _alertType = nextType;
      });
    }
  }

  void _maybeScheduleDismiss() {
    _dismissTimer?.cancel();

    if (widget.options.visible && widget.options.duration > 0) {
      _dismissTimer = Timer(
        Duration(milliseconds: widget.options.duration),
        _dismiss,
      );
    }
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    widget.options.onHide?.call();
  }

  bool _invokeTap(AlertTapCallback? callback) {
    if (callback == null) {
      return true;
    }
    try {
      return callback();
    } catch (_) {
      return true;
    }
  }

  void _handleContentTap() {
    final bool shouldDismiss = _invokeTap(widget.options.onContentTap);
    if (shouldDismiss && widget.options.contentDismissible) {
      _dismiss();
    }
  }

  void _handleOverlayTap() {
    final bool shouldDismiss = _invokeTap(widget.options.onOverlayTap);
    if (shouldDismiss && widget.options.overlayDismissible) {
      _dismiss();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final String normalizedType = _alertType.toLowerCase();
    final bool isDanger =
        normalizedType == 'danger' || normalizedType == 'error';

    final Color backgroundColor = isDanger
        ? (options.dangerColor ?? const Color(0xFFDC2626))
        : (options.successColor ?? const Color(0xFF16A34A));

    final TextStyle effectiveMessageStyle = (options.messageStyle ??
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
        .copyWith(color: options.messageStyle?.color ?? options.textColor);

    final Widget baseMessage = Padding(
      padding: options.messagePadding ?? EdgeInsets.zero,
      child: Text(
        options.message,
        style: effectiveMessageStyle,
        textAlign: options.messageAlignment,
        maxLines: options.messageMaxLines,
        overflow:
            options.messageMaxLines != null ? TextOverflow.ellipsis : null,
      ),
    );

    final Widget messageWidget = options.messageBuilder?.call(
          AlertMessageContext(
            options: options,
            defaultMessage: baseMessage,
          ),
        ) ??
        baseMessage;

    final List<Widget> segments = <Widget>[messageWidget];
    if (options.leading != null) {
      segments.insert(0, options.leading!);
    }
    if (options.trailing != null) {
      segments.add(options.trailing!);
    }
    if (options.actions != null && options.actions!.isNotEmpty) {
      segments.add(
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: options.actions!,
        ),
      );
    }

    final double spacing = options.contentSpacing;
    final List<Widget> contentChildren = <Widget>[];
    for (int i = 0; i < segments.length; i++) {
      contentChildren.add(segments[i]);
      if (i != segments.length - 1) {
        contentChildren.add(SizedBox(height: spacing));
      }
    }

    Widget contentColumn = Column(
      mainAxisSize: options.contentMainAxisSize,
      crossAxisAlignment: options.contentAlignment,
      mainAxisAlignment: MainAxisAlignment.center,
      children: contentChildren,
    );

    contentColumn = Semantics(
      liveRegion: true,
      container: true,
      label: options.message,
      child: contentColumn,
    );

    final BoxDecoration decoration = options.containerDecoration?.copyWith(
          color: options.containerDecoration?.color ?? backgroundColor,
        ) ??
        BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 18),
              blurRadius: 45,
            ),
          ],
        );

    final Clip effectiveClip = options.containerClipBehavior ??
        (decoration.borderRadius != null ||
                decoration.shape != BoxShape.rectangle
            ? Clip.antiAlias
            : Clip.none);

    Widget defaultContent = Container(
      padding: options.containerPadding ??
          const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      margin: options.containerMargin,
      decoration: decoration,
      clipBehavior: effectiveClip,
      child: contentColumn,
    );

    Widget contentNode = options.contentBuilder?.call(
          AlertContentContext(
            options: options,
            defaultContent: defaultContent,
            message: messageWidget,
          ),
        ) ??
        defaultContent;

    final bool enableContentTap =
        options.contentDismissible || options.onContentTap != null;
    if (enableContentTap) {
      contentNode = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleContentTap,
        child: contentNode,
      );
    }

    final double maxWidth = options.maxWidth ?? double.infinity;
    final double minWidth = options.minWidth ?? 0;

    final double overlayOpacity =
        (options.overlayOpacity.isNaN ? 0.5 : options.overlayOpacity)
            .clamp(0.0, 1.0);
    final double baseOverlayOpacity = options.overlayColor.a;
    final double effectiveOverlayOpacity =
        (overlayOpacity * baseOverlayOpacity).clamp(0.0, 1.0);
    final Color overlayBackgroundColor = options.overlayColor.withValues(
      alpha: effectiveOverlayOpacity,
    );

    final Widget overlayContent = Align(
      alignment: options.overlayAlignment,
      child: Padding(
        padding: options.overlayPadding ?? const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minWidth,
            maxWidth: maxWidth,
          ),
          child: contentNode,
        ),
      ),
    );

    Widget overlay = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _handleOverlayTap,
            child: ColoredBox(color: overlayBackgroundColor),
          ),
        ),
        overlayContent,
      ],
    );

    Widget defaultOverlay = SizedBox.expand(child: overlay);

    defaultOverlay = options.overlayBuilder?.call(
          AlertOverlayContext(
            options: options,
            defaultOverlay: defaultOverlay,
            content: contentNode,
          ),
        ) ??
        defaultOverlay;

    return IgnorePointer(
      ignoring: !options.visible,
      child: AnimatedOpacity(
        opacity: options.visible ? 1 : 0,
        duration: options.animationDuration,
        curve: options.animationCurve,
        child: defaultOverlay,
      ),
    );
  }
}
