import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../components/display_components/flexible_video.dart'
    show
        FlexibleVideoOptions,
        FlexibleVideoContainerContext,
        FlexibleVideoGridContext,
        FlexibleVideoRowContext,
        FlexibleVideoCellContext,
        FlexibleVideoScreenboardContext;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

typedef ModernFlexibleVideoType = Widget Function(
    {required FlexibleVideoOptions options});

/// Modern styled flexible video grid that accepts [FlexibleVideoOptions].
/// Provides glassmorphic styling and modern visual treatment while
/// maintaining API compatibility with the original FlexibleVideo.
class ModernFlexibleVideo extends StatefulWidget {
  final FlexibleVideoOptions options;
  final bool isDarkMode;
  final bool enableGlassmorphism;
  final BorderRadius? cellBorderRadius;

  const ModernFlexibleVideo({
    super.key,
    required this.options,
    this.isDarkMode = true,
    this.enableGlassmorphism = true,
    this.cellBorderRadius,
  });

  @override
  State<ModernFlexibleVideo> createState() => _ModernFlexibleVideoState();
}

class _ModernFlexibleVideoMetrics {
  final double width;
  final double height;
  final double cardLeft;
  final double canvasLeft;

  const _ModernFlexibleVideoMetrics({
    required this.width,
    required this.height,
    required this.cardLeft,
    required this.canvasLeft,
  });
}

class _ModernFlexibleVideoState extends State<ModernFlexibleVideo> {
  late double _cardWidth;
  late double _cardHeight;
  late double _cardLeft;
  late double _canvasLeft;

  bool get _isDark => widget.isDarkMode;
  BorderRadius get _borderRadius =>
      widget.cellBorderRadius ?? BorderRadius.circular(12);

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
  void didUpdateWidget(covariant ModernFlexibleVideo oldWidget) {
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

  _ModernFlexibleVideoMetrics _deriveMetrics(FlexibleVideoOptions options) {
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

    return _ModernFlexibleVideoMetrics(
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
        final double columnSpacing = options.columnSpacing ?? 4;
        final double totalColumnSpacing =
            columnSpacing * math.max(0, options.columns - 1);
        final double cellMarginHorizontal = options.cellMargin?.horizontal ?? 0;
        final double cellPaddingHorizontal =
            options.cellPadding?.horizontal ?? 0;
        final double totalCellMarginWidth =
            cellMarginHorizontal * math.max(0, options.columns);
        final double totalCellPaddingWidth =
            cellPaddingHorizontal * math.max(0, options.columns);
        final double availableForCards = (maxWidth -
                totalColumnSpacing -
                totalCellMarginWidth -
                totalCellPaddingWidth)
            .clamp(0.0, double.infinity);

        double cardWidth = _cardWidth;
        if (options.columns > 0 &&
            availableForCards.isFinite &&
            availableForCards > 0) {
          final double perColumnWidth = availableForCards / options.columns;
          cardWidth = math.min(_cardWidth, perColumnWidth).floorToDouble();
        }

        double cardHeight = _cardHeight;
        double aspectRatio = 0;
        if (_cardWidth > 0 && _cardHeight > 0) {
          aspectRatio = _cardHeight / _cardWidth;
        }
        if (cardWidth > 0 && aspectRatio > 0) {
          cardHeight = (cardWidth * aspectRatio).floorToDouble();
        }

        final double rowSpacing = options.rowSpacing ?? 4;
        final double totalRowSpacing =
            rowSpacing * math.max(0, options.rows - 1);
        final double cellMarginVertical = options.cellMargin?.vertical ?? 0;
        final double cellPaddingVertical = options.cellPadding?.vertical ?? 0;
        final double totalCellMarginHeight =
            cellMarginVertical * math.max(0, options.rows);
        final double totalCellPaddingHeight =
            cellPaddingVertical * math.max(0, options.rows);
        final double rowPaddingVertical = options.rowPadding?.vertical ?? 0;
        final double rowMarginVertical = options.rowMargin?.vertical ?? 0;

        double availableForRows = (maxHeight -
                totalRowSpacing -
                totalCellMarginHeight -
                totalCellPaddingHeight)
            .clamp(0.0, double.infinity);

        if (rowPaddingVertical > 0) {
          availableForRows =
              (availableForRows - rowPaddingVertical * options.rows)
                  .clamp(0.0, double.infinity);
        }
        if (rowMarginVertical > 0) {
          availableForRows =
              (availableForRows - rowMarginVertical * options.rows)
                  .clamp(0.0, double.infinity);
        }

        if (options.rows > 0 && availableForRows > 0) {
          final double perRowHeight = availableForRows / options.rows;
          if (cardHeight > perRowHeight && perRowHeight > 0) {
            cardHeight = perRowHeight.floorToDouble();
            if (aspectRatio > 0) {
              cardWidth = (cardHeight / aspectRatio).floorToDouble();
              cardWidth = cardWidth.clamp(0.0, _cardWidth);
            }
          }
        }

        final Size cardSize = Size(cardWidth, cardHeight);

        for (var rowIndex = 0; rowIndex < options.rows; rowIndex++) {
          final List<Widget> rowCells = [];
          final List<Widget> rawCells = [];

          for (var columnIndex = 0;
              columnIndex < options.columns;
              columnIndex++) {
            final cellIndex = rowIndex * options.columns + columnIndex;
            final component =
                cellIndex < components.length ? components[cellIndex] : null;
            final hasComponent = component != null;

            Widget cellChild = SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: component ?? _buildEmptyCell(cardSize),
            );

            // Modern styled cell with rounded corners and theming
            Widget defaultCell = Container(
              margin: options.cellMargin,
              padding: options.cellPadding,
              alignment: options.cellAlignment ?? Alignment.center,
              decoration: options.cellDecoration ??
                  (hasComponent
                      ? BoxDecoration(
                          borderRadius: _borderRadius,
                          color: Colors.transparent,
                        )
                      : BoxDecoration(
                          borderRadius: _borderRadius,
                          // Use themed surface colors for empty cells
                          color: _isDark
                              ? MediasfuColors.surfaceDark.withOpacity(0.5)
                              : MediasfuColors.surfaceElevated.withOpacity(0.5),
                          border: Border.all(
                            color: _isDark
                                ? MediasfuColors.primaryDark.withOpacity(0.1)
                                : MediasfuColors.primary.withOpacity(0.05),
                          ),
                        )),
              clipBehavior: Clip.antiAlias,
              child: ClipRRect(
                borderRadius: _borderRadius,
                child: cellChild,
              ),
            );

            if (options.cellBuilder != null) {
              final cellContext = _ModernFlexibleVideoCellContext(
                buildContext: context,
                options: options,
                index: cellIndex,
                rowIndex: rowIndex,
                columnIndex: columnIndex,
                component: component,
                hasComponent: hasComponent,
                cardSize: cardSize,
              );
              defaultCell = options.cellBuilder!(
                _convertToOriginalCellContext(cellContext),
                defaultCell,
              );
            }

            rawCells.add(defaultCell);
            rowCells.add(defaultCell);

            if (columnIndex < options.columns - 1 && columnSpacing > 0) {
              rowCells.add(SizedBox(width: columnSpacing));
            }
          }

          Widget row = ClipRect(
            child: Row(
              mainAxisSize: options.rowMainAxisSize,
              mainAxisAlignment:
                  options.rowMainAxisAlignment ?? MainAxisAlignment.start,
              crossAxisAlignment:
                  options.rowCrossAxisAlignment ?? CrossAxisAlignment.center,
              children: rowCells,
            ),
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

          if (options.rowBuilder != null) {
            final rowContext = _ModernFlexibleVideoRowContext(
              buildContext: context,
              options: options,
              rowIndex: rowIndex,
              cells: List.unmodifiable(rawCells),
              cardSize: cardSize,
            );
            row = options.rowBuilder!(
              _convertToOriginalRowContext(rowContext),
              row,
            );
          }

          builtRows.add(row);
          columnChildren.add(row);

          if (rowIndex < options.rows - 1 && rowSpacing > 0) {
            columnChildren.add(SizedBox(height: rowSpacing));
          }
        }

        Widget grid = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              options.rowCrossAxisAlignment ?? CrossAxisAlignment.center,
          children: columnChildren,
        );

        if (options.gridBuilder != null) {
          final gridContext = _ModernFlexibleVideoGridContext(
            buildContext: context,
            options: options,
            rows: List.unmodifiable(builtRows),
            cardSize: cardSize,
            cardLeft: _cardLeft,
            canvasLeft: _canvasLeft,
          );
          grid = options.gridBuilder!(
            _convertToOriginalGridContext(gridContext),
            grid,
          );
        }

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
            child: Container(
              padding: options.screenboardPadding,
              margin: options.screenboardMargin,
              decoration: options.screenboardDecoration,
              clipBehavior: options.screenboardClipBehavior,
              alignment: options.screenboardAlignment,
              child: ClipRRect(
                borderRadius: _borderRadius,
                child: SizedBox(
                  width: cardSize.width,
                  height: cardSize.height,
                  child: options.screenboard,
                ),
              ),
            ),
          );

          if (options.screenboardBuilder != null) {
            final screenboardContext = _ModernFlexibleVideoScreenboardContext(
              buildContext: context,
              options: options,
              screenboard: options.screenboard,
              cardSize: cardSize,
              cardLeft: _cardLeft,
              canvasLeft: _canvasLeft,
            );
            screenboardNode = options.screenboardBuilder!(
              _convertToOriginalScreenboardContext(screenboardContext),
              defaultScreenboard,
            );
          } else {
            screenboardNode = defaultScreenboard;
          }
        }

        final stackChildren = <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: gridWithOffset,
          ),
          if (screenboardNode != null) screenboardNode,
        ];

        // Modern styled container
        Widget container = Container(
          width: options.customWidth,
          height: options.customHeight,
          padding: options.containerPadding,
          margin: options.containerMargin,
          decoration: options.containerDecoration ??
              BoxDecoration(
                color: options.backgroundColor,
                borderRadius: _borderRadius,
              ),
          alignment: options.containerAlignment,
          clipBehavior: options.containerClipBehavior,
          constraints: options.containerConstraints,
          child: Stack(children: stackChildren),
        );

        if (options.containerBuilder != null) {
          final containerContext = _ModernFlexibleVideoContainerContext(
            buildContext: context,
            options: options,
            rows: List.unmodifiable(builtRows),
            screenboard: screenboardNode,
            cardSize: cardSize,
            cardLeft: _cardLeft,
            canvasLeft: _canvasLeft,
          );
          container = options.containerBuilder!(
            _convertToOriginalContainerContext(containerContext),
            container,
          );
        }

        return container;
      },
    );
  }

  /// Modern styled empty cell with subtle icon
  Widget _buildEmptyCell(Size cardSize) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(MediasfuSpacing.md),
        decoration: BoxDecoration(
          color: _isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.03),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.videocam_off_rounded,
          size: math.min(cardSize.width, cardSize.height) * 0.15,
          color: _isDark
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.15),
        ),
      ),
    );
  }
}

// Internal context classes for modern version
class _ModernFlexibleVideoContainerContext {
  final BuildContext buildContext;
  final FlexibleVideoOptions options;
  final List<Widget> rows;
  final Widget? screenboard;
  final Size cardSize;
  final double cardLeft;
  final double canvasLeft;

  const _ModernFlexibleVideoContainerContext({
    required this.buildContext,
    required this.options,
    required this.rows,
    required this.screenboard,
    required this.cardSize,
    required this.cardLeft,
    required this.canvasLeft,
  });
}

class _ModernFlexibleVideoGridContext {
  final BuildContext buildContext;
  final FlexibleVideoOptions options;
  final List<Widget> rows;
  final Size cardSize;
  final double cardLeft;
  final double canvasLeft;

  const _ModernFlexibleVideoGridContext({
    required this.buildContext,
    required this.options,
    required this.rows,
    required this.cardSize,
    required this.cardLeft,
    required this.canvasLeft,
  });
}

class _ModernFlexibleVideoRowContext {
  final BuildContext buildContext;
  final FlexibleVideoOptions options;
  final int rowIndex;
  final List<Widget> cells;
  final Size cardSize;

  const _ModernFlexibleVideoRowContext({
    required this.buildContext,
    required this.options,
    required this.rowIndex,
    required this.cells,
    required this.cardSize,
  });
}

class _ModernFlexibleVideoCellContext {
  final BuildContext buildContext;
  final FlexibleVideoOptions options;
  final int index;
  final int rowIndex;
  final int columnIndex;
  final Widget? component;
  final bool hasComponent;
  final Size cardSize;

  const _ModernFlexibleVideoCellContext({
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

class _ModernFlexibleVideoScreenboardContext {
  final BuildContext buildContext;
  final FlexibleVideoOptions options;
  final Widget? screenboard;
  final Size cardSize;
  final double cardLeft;
  final double canvasLeft;

  const _ModernFlexibleVideoScreenboardContext({
    required this.buildContext,
    required this.options,
    required this.screenboard,
    required this.cardSize,
    required this.cardLeft,
    required this.canvasLeft,
  });
}

// Conversion functions for builder compatibility
FlexibleVideoContainerContext _convertToOriginalContainerContext(
    _ModernFlexibleVideoContainerContext ctx) {
  return FlexibleVideoContainerContext(
    buildContext: ctx.buildContext,
    options: ctx.options,
    rows: ctx.rows,
    screenboard: ctx.screenboard,
    cardSize: ctx.cardSize,
    cardLeft: ctx.cardLeft,
    canvasLeft: ctx.canvasLeft,
  );
}

FlexibleVideoGridContext _convertToOriginalGridContext(
    _ModernFlexibleVideoGridContext ctx) {
  return FlexibleVideoGridContext(
    buildContext: ctx.buildContext,
    options: ctx.options,
    rows: ctx.rows,
    cardSize: ctx.cardSize,
    cardLeft: ctx.cardLeft,
    canvasLeft: ctx.canvasLeft,
  );
}

FlexibleVideoRowContext _convertToOriginalRowContext(
    _ModernFlexibleVideoRowContext ctx) {
  return FlexibleVideoRowContext(
    buildContext: ctx.buildContext,
    options: ctx.options,
    rowIndex: ctx.rowIndex,
    cells: ctx.cells,
    cardSize: ctx.cardSize,
  );
}

FlexibleVideoCellContext _convertToOriginalCellContext(
    _ModernFlexibleVideoCellContext ctx) {
  return FlexibleVideoCellContext(
    buildContext: ctx.buildContext,
    options: ctx.options,
    index: ctx.index,
    rowIndex: ctx.rowIndex,
    columnIndex: ctx.columnIndex,
    component: ctx.component,
    hasComponent: ctx.hasComponent,
    cardSize: ctx.cardSize,
  );
}

FlexibleVideoScreenboardContext _convertToOriginalScreenboardContext(
    _ModernFlexibleVideoScreenboardContext ctx) {
  return FlexibleVideoScreenboardContext(
    buildContext: ctx.buildContext,
    options: ctx.options,
    screenboard: ctx.screenboard,
    cardSize: ctx.cardSize,
    cardLeft: ctx.cardLeft,
    canvasLeft: ctx.canvasLeft,
  );
}
