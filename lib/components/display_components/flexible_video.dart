import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class FlexibleVideoContainerContext {
  final BuildContext buildContext;
  final FlexibleVideoOptions options;
  final List<Widget> rows;
  final Widget? screenboard;
  final Size cardSize;
  final double cardLeft;
  final double canvasLeft;

  const FlexibleVideoContainerContext({
    required this.buildContext,
    required this.options,
    required this.rows,
    required this.screenboard,
    required this.cardSize,
    required this.cardLeft,
    required this.canvasLeft,
  });
}

class FlexibleVideoGridContext {
  final BuildContext buildContext;
  final FlexibleVideoOptions options;
  final List<Widget> rows;
  final Size cardSize;
  final double cardLeft;
  final double canvasLeft;

  const FlexibleVideoGridContext({
    required this.buildContext,
    required this.options,
    required this.rows,
    required this.cardSize,
    required this.cardLeft,
    required this.canvasLeft,
  });
}

class FlexibleVideoRowContext {
  final BuildContext buildContext;
  final FlexibleVideoOptions options;
  final int rowIndex;
  final List<Widget> cells;
  final Size cardSize;

  const FlexibleVideoRowContext({
    required this.buildContext,
    required this.options,
    required this.rowIndex,
    required this.cells,
    required this.cardSize,
  });
}

class FlexibleVideoCellContext {
  final BuildContext buildContext;
  final FlexibleVideoOptions options;
  final int index;
  final int rowIndex;
  final int columnIndex;
  final Widget? component;
  final bool hasComponent;
  final Size cardSize;

  const FlexibleVideoCellContext({
    required this.buildContext,
    required this.options,
    required this.index,
    required this.rowIndex,
    required this.columnIndex,
    required this.component,
    required this.hasComponent,
    required this.cardSize,
  });
}

class FlexibleVideoScreenboardContext {
  final BuildContext buildContext;
  final FlexibleVideoOptions options;
  final Widget? screenboard;
  final Size cardSize;
  final double cardLeft;
  final double canvasLeft;

  const FlexibleVideoScreenboardContext({
    required this.buildContext,
    required this.options,
    required this.screenboard,
    required this.cardSize,
    required this.cardLeft,
    required this.canvasLeft,
  });
}

typedef FlexibleVideoContainerBuilder = Widget Function(
  FlexibleVideoContainerContext context,
  Widget defaultContainer,
);

typedef FlexibleVideoGridBuilder = Widget Function(
  FlexibleVideoGridContext context,
  Widget defaultGrid,
);

typedef FlexibleVideoRowBuilder = Widget Function(
  FlexibleVideoRowContext context,
  Widget defaultRow,
);

typedef FlexibleVideoCellBuilder = Widget Function(
  FlexibleVideoCellContext context,
  Widget defaultCell,
);

typedef FlexibleVideoScreenboardBuilder = Widget? Function(
  FlexibleVideoScreenboardContext context,
  Widget? defaultScreenboard,
);

/// Configuration payload for [FlexibleVideo].
///
/// Powers the MediaSFU main video grid with responsive card sizing and
/// optional screen-share annotation overlays:
///
/// * `customWidth` / `customHeight` set requested card dimensions. The widget
///   clamps them to available constraints so cards remain visible even when
///   initial values are large or the viewport is narrow.
/// * `annotateScreenStream` + `localStreamScreen` enable overlaying annotation
///   canvases atop screen shares. The card width adjusts to the stream's native
///   resolution when annotations are active.
/// * Rich builder surface (`containerBuilder`, `gridBuilder`, `rowBuilder`,
///   `cellBuilder`, `screenboardBuilder`) lets you inject custom rendering
///   layers while preserving the built-in grid logic.
/// * Computed `cardSize`, `cardLeft`, and `canvasLeft` are passed to each
///   builder context so downstream widgets can align or position elements
///   relative to the final card geometry.
///
/// Override this component via `MediasfuUICustomOverrides.flexibleVideo` when
/// you need branded tiling, watermarks, or alternative card layouts.
class FlexibleVideoOptions {
  final double customWidth;
  final double customHeight;
  final int rows;
  final int columns;
  final List<Widget> componentsToRender;
  final bool showAspect;
  final Color backgroundColor;
  final Widget? screenboard;
  final bool annotateScreenStream;
  final MediaStream? localStreamScreen;

  final EdgeInsetsGeometry? containerPadding;
  final EdgeInsetsGeometry? containerMargin;
  final Decoration? containerDecoration;
  final AlignmentGeometry? containerAlignment;
  final Clip containerClipBehavior;
  final BoxConstraints? containerConstraints;
  final FlexibleVideoContainerBuilder? containerBuilder;

  final FlexibleVideoGridBuilder? gridBuilder;

  final double? rowSpacing;
  final EdgeInsetsGeometry? rowPadding;
  final EdgeInsetsGeometry? rowMargin;
  final Decoration? rowDecoration;
  final Clip rowClipBehavior;
  final MainAxisAlignment? rowMainAxisAlignment;
  final CrossAxisAlignment? rowCrossAxisAlignment;
  final MainAxisSize rowMainAxisSize;
  final FlexibleVideoRowBuilder? rowBuilder;

  final double? columnSpacing;
  final EdgeInsetsGeometry? cellPadding;
  final EdgeInsetsGeometry? cellMargin;
  final Decoration? cellDecoration;
  final Clip cellClipBehavior;
  final AlignmentGeometry? cellAlignment;
  final FlexibleVideoCellBuilder? cellBuilder;

  final EdgeInsetsGeometry? screenboardPadding;
  final EdgeInsetsGeometry? screenboardMargin;
  final Decoration? screenboardDecoration;
  final Clip screenboardClipBehavior;
  final AlignmentGeometry? screenboardAlignment;
  final FlexibleVideoScreenboardBuilder? screenboardBuilder;

  const FlexibleVideoOptions({
    required this.customWidth,
    required this.customHeight,
    required this.rows,
    required this.columns,
    required this.componentsToRender,
    this.showAspect = true,
    this.backgroundColor = Colors.transparent,
    this.screenboard,
    this.annotateScreenStream = false,
    this.localStreamScreen,
    this.containerPadding,
    this.containerMargin,
    this.containerDecoration,
    this.containerAlignment,
    this.containerClipBehavior = Clip.none,
    this.containerConstraints,
    this.containerBuilder,
    this.gridBuilder,
    this.rowSpacing = 2,
    this.rowPadding,
    this.rowMargin,
    this.rowDecoration,
    this.rowClipBehavior = Clip.none,
    this.rowMainAxisAlignment,
    this.rowCrossAxisAlignment,
    this.rowMainAxisSize = MainAxisSize.min,
    this.rowBuilder,
    this.columnSpacing = 2,
    this.cellPadding,
    this.cellMargin,
    this.cellDecoration,
    this.cellClipBehavior = Clip.none,
    this.cellAlignment,
    this.cellBuilder,
    this.screenboardPadding,
    this.screenboardMargin,
    this.screenboardDecoration,
    this.screenboardClipBehavior = Clip.none,
    this.screenboardAlignment,
    this.screenboardBuilder,
  });
}

typedef FlexibleVideoType = Widget Function({required FlexibleVideoOptions options});

/// Responsive video-grid widget that powers MediaSFU's main participant layout.
///
/// * Computes card size from available layout constraints, accounting for row/
///   column spacing, padding, and margins so cards never overflow or collapse.
/// * Supports screen-share annotation by adjusting card width to match the
///   stream's native resolution when `annotateScreenStream` is enabled.
/// * Exposes computed metrics (`Size cardSize`, offsets) to all builder hooks
///   so custom renderers can align overlays or watermarks consistently.
/// * Hides itself gracefully via [SizedBox.shrink] when `showAspect` is false.
///
/// Use this widget in `MediasfuUICustomOverrides.flexibleVideo` to deliver
/// branded layouts, CRM integrations, or alternative tiling strategies.
class FlexibleVideo extends StatefulWidget {
  final FlexibleVideoOptions options;

  const FlexibleVideo({super.key, required this.options});

  @override
  State<FlexibleVideo> createState() => _FlexibleVideoState();
}

class _FlexibleVideoMetrics {
  final double width;
  final double height;
  final double cardLeft;
  final double canvasLeft;

  const _FlexibleVideoMetrics({
    required this.width,
    required this.height,
    required this.cardLeft,
    required this.canvasLeft,
  });
}

class _FlexibleVideoState extends State<FlexibleVideo> {
  late double _cardWidth;
  late double _cardHeight;
  late double _cardLeft;
  late double _canvasLeft;

  @override
  void initState() {
    super.initState();
    final metrics = _deriveMetrics(widget.options);
    _cardWidth = metrics.width;
    _cardHeight = metrics.height;
    _cardLeft = metrics.cardLeft;
    _canvasLeft = metrics.canvasLeft;
  }

  @override
  void didUpdateWidget(covariant FlexibleVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    final metrics = _deriveMetrics(widget.options);
    if (metrics.width != _cardWidth ||
        metrics.height != _cardHeight ||
        metrics.cardLeft != _cardLeft ||
        metrics.canvasLeft != _canvasLeft) {
      setState(() {
        _cardWidth = metrics.width;
        _cardHeight = metrics.height;
        _cardLeft = metrics.cardLeft;
        _canvasLeft = metrics.canvasLeft;
      });
    }
  }

  _FlexibleVideoMetrics _deriveMetrics(FlexibleVideoOptions options) {
    double width = options.customWidth;
    double height = options.customHeight;
    double cardLeft = 0;
    double canvasLeft = 0;

    if (options.annotateScreenStream && options.localStreamScreen != null) {
      final tracks = options.localStreamScreen!.getVideoTracks();
      if (tracks.isNotEmpty) {
        final settings = tracks.first.getSettings();
        final trackWidth = (settings['width'] as num?)?.toDouble();
        final trackHeight = (settings['height'] as num?)?.toDouble();
        if (trackWidth != null && trackWidth > 0) {
          width = trackWidth;
        }
        if (trackHeight != null && trackHeight > 0) {
          height = trackHeight;
        }
      }
      cardLeft = (options.customWidth - width) / 2;
      canvasLeft = cardLeft < 0 ? cardLeft : 0;
    }

    return _FlexibleVideoMetrics(
      width: width,
      height: height,
      cardLeft: cardLeft,
      canvasLeft: canvasLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;

    if (!options.showAspect) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final components = options.componentsToRender;
        final List<Widget> builtRows = [];
        final List<Widget> columnChildren = [];

    final mediaSize = MediaQuery.of(context).size;
    final double maxWidth = constraints.maxWidth.isFinite
      ? constraints.maxWidth
      : mediaSize.width;
    final double maxHeight = constraints.maxHeight.isFinite
      ? constraints.maxHeight
      : (widget.options.customHeight.isFinite
        ? widget.options.customHeight
        : mediaSize.height);
        final double columnSpacing = options.columnSpacing ?? 0;
        final double totalColumnSpacing =
            columnSpacing * math.max(0, options.columns - 1);
        final double cellMarginHorizontal =
            options.cellMargin?.horizontal ?? 0;
        final double totalCellMarginWidth =
            cellMarginHorizontal * math.max(0, options.columns);
        final double availableForCards = (maxWidth - totalColumnSpacing -
                totalCellMarginWidth)
            .clamp(0.0, double.infinity);

        double cardWidth = _cardWidth;
        if (options.columns > 0 && availableForCards.isFinite &&
            availableForCards > 0) {
          final double perColumnWidth = availableForCards / options.columns;
          cardWidth = math.min(_cardWidth, perColumnWidth);
        }

        double cardHeight = _cardHeight;
        double aspectRatio = 0;
        if (_cardWidth > 0 && _cardHeight > 0) {
          aspectRatio = _cardHeight / _cardWidth;
        }
        if (cardWidth > 0 && aspectRatio > 0) {
          cardHeight = cardWidth * aspectRatio;
        }

        final double rowSpacing = options.rowSpacing ?? 0;
    final double totalRowSpacing = rowSpacing * math.max(0, options.rows - 1);
    final double cellMarginVertical = options.cellMargin?.vertical ?? 0;
    final double totalCellMarginHeight =
      cellMarginVertical * math.max(0, options.rows);
    final double rowPaddingVertical =
      options.rowPadding?.vertical ?? 0;
    final double rowMarginVertical = options.rowMargin?.vertical ?? 0;

    double availableForRows = (maxHeight - totalRowSpacing - totalCellMarginHeight)
            .clamp(0.0, double.infinity);

    if (rowPaddingVertical > 0) {
      availableForRows = (availableForRows - rowPaddingVertical * options.rows)
        .clamp(0.0, double.infinity);
    }
    if (rowMarginVertical > 0) {
      availableForRows = (availableForRows - rowMarginVertical * options.rows)
        .clamp(0.0, double.infinity);
    }

        if (options.rows > 0 && availableForRows > 0) {
          final double perRowHeight = availableForRows / options.rows;
          if (cardHeight > perRowHeight && perRowHeight > 0) {
            cardHeight = perRowHeight;
            if (aspectRatio > 0) {
              cardWidth = cardHeight / aspectRatio;
              cardWidth = cardWidth.clamp(0.0, _cardWidth);
            }
          }
        }

        final Size cardSize = Size(cardWidth, cardHeight);

        for (var rowIndex = 0; rowIndex < options.rows; rowIndex++) {
          final List<Widget> rowCells = [];
          final List<Widget> rawCells = [];

          for (var columnIndex = 0; columnIndex < options.columns; columnIndex++) {
            final cellIndex = rowIndex * options.columns + columnIndex;
            final component = cellIndex < components.length
                ? components[cellIndex]
                : null;
            final hasComponent = component != null;

            final cellContext = FlexibleVideoCellContext(
              buildContext: context,
              options: options,
              index: cellIndex,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
              component: component,
              hasComponent: hasComponent,
              cardSize: cardSize,
            );

            Widget cellChild = SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: component ?? const SizedBox.shrink(),
            );

            Widget defaultCell = Container(
              margin: options.cellMargin,
              padding: options.cellPadding,
              alignment: options.cellAlignment ?? Alignment.center,
              decoration: options.cellDecoration ??
                  BoxDecoration(color: options.backgroundColor),
              clipBehavior: options.cellClipBehavior,
              child: cellChild,
            );

            if (options.cellBuilder != null) {
              defaultCell = options.cellBuilder!(cellContext, defaultCell);
            }

            rawCells.add(defaultCell);
            rowCells.add(defaultCell);

            if (columnIndex < options.columns - 1 &&
                (options.columnSpacing ?? 0) > 0) {
              rowCells.add(SizedBox(width: options.columnSpacing));
            }
          }

          Widget row = Row(
            mainAxisSize: options.rowMainAxisSize,
            mainAxisAlignment:
                options.rowMainAxisAlignment ?? MainAxisAlignment.start,
            crossAxisAlignment:
                options.rowCrossAxisAlignment ?? CrossAxisAlignment.center,
            children: rowCells,
          );

          if (options.rowDecoration != null ||
              options.rowPadding != null ||
              options.rowMargin != null ||
              options.rowClipBehavior != Clip.none) {
            row = Container(
              padding: options.rowPadding,
              margin: options.rowMargin,
              decoration: options.rowDecoration,
              clipBehavior: options.rowClipBehavior,
              child: row,
            );
          }

          final rowContext = FlexibleVideoRowContext(
            buildContext: context,
            options: options,
            rowIndex: rowIndex,
            cells: List.unmodifiable(rawCells),
            cardSize: cardSize,
          );

          if (options.rowBuilder != null) {
            row = options.rowBuilder!(rowContext, row);
          }

          builtRows.add(row);
          columnChildren.add(row);

          if (rowIndex < options.rows - 1 && (options.rowSpacing ?? 0) > 0) {
            columnChildren.add(SizedBox(height: options.rowSpacing));
          }
        }

        Widget grid = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              options.rowCrossAxisAlignment ?? CrossAxisAlignment.center,
          children: columnChildren,
        );

        final gridContext = FlexibleVideoGridContext(
          buildContext: context,
          options: options,
          rows: List.unmodifiable(builtRows),
          cardSize: cardSize,
          cardLeft: _cardLeft,
          canvasLeft: _canvasLeft,
        );

        grid = options.gridBuilder?.call(gridContext, grid) ?? grid;

        final double positiveOffset = _cardLeft > 0 ? _cardLeft : 0;
        final double negativeOffset = _cardLeft < 0 ? _cardLeft : 0;

        Widget gridWithOffset = Padding(
          padding: EdgeInsets.only(left: positiveOffset),
          child: Transform.translate(
            offset: Offset(negativeOffset, 0),
            child: grid,
          ),
        );

        Widget? screenboardNode;
        if (options.screenboard != null) {
          Widget? defaultScreenboard = Positioned(
            top: 0,
            left: _canvasLeft + positiveOffset,
            child: IgnorePointer(
              ignoring: !options.annotateScreenStream,
              child: Container(
                padding: options.screenboardPadding,
                margin: options.screenboardMargin,
                decoration: options.screenboardDecoration,
                clipBehavior: options.screenboardClipBehavior,
                alignment: options.screenboardAlignment,
                child: SizedBox(
                  width: cardSize.width,
                  height: cardSize.height,
                  child: options.screenboard,
                ),
              ),
            ),
          );

          final screenboardContext = FlexibleVideoScreenboardContext(
            buildContext: context,
            options: options,
            screenboard: options.screenboard,
            cardSize: cardSize,
            cardLeft: _cardLeft,
            canvasLeft: _canvasLeft,
          );

          screenboardNode = options.screenboardBuilder
                  ?.call(screenboardContext, defaultScreenboard) ??
              defaultScreenboard;
        }

        final stackChildren = <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: gridWithOffset,
          ),
          if (screenboardNode != null) screenboardNode,
        ];

        Widget container = Container(
          width: options.customWidth,
          height: options.customHeight,
          padding: options.containerPadding,
          margin: options.containerMargin,
          decoration: options.containerDecoration ??
              BoxDecoration(color: options.backgroundColor),
          alignment: options.containerAlignment,
          clipBehavior: options.containerClipBehavior,
          constraints: options.containerConstraints,
          child: Stack(children: stackChildren),
        );

        final containerContext = FlexibleVideoContainerContext(
          buildContext: context,
          options: options,
          rows: List.unmodifiable(builtRows),
          screenboard: screenboardNode,
          cardSize: cardSize,
          cardLeft: _cardLeft,
          canvasLeft: _canvasLeft,
        );

        container = options.containerBuilder?.call(containerContext, container) ?? container;

        return container;
      },
    );
  }
}
