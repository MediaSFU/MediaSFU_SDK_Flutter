import 'dart:math' as math;

import 'package:flutter/material.dart';

/// `FlexibleGridOptions` - Configuration options for the `FlexibleGrid` widget.
///
/// ### Properties:
/// - `customWidth` (`double?`): Optional width of each grid item. If `null`, a default aspect ratio of 1.0 is used.
/// - `customHeight` (`double?`): Optional height of each grid item. If `null`, a default aspect ratio of 1.0 is used.
/// - `rows` (`int`): The number of rows in the grid layout. Must be greater than 0.
/// - `columns` (`int`): The number of columns in the grid layout. Must be greater than 0.
/// - `componentsToRender` (`List<Widget>`): A list of widgets (e.g., video streams or images) to render in the grid cells. If fewer components are provided than cells in the grid, the components are repeated.
/// - `backgroundColor` (`Color`): The background color of each grid cell. Defaults to `Colors.transparent`.
/// - `showAspect` (`bool`): Controls the visibility of the entire grid. If `false`, the grid is hidden. Defaults to `true`.
///
/// ### Example Usage:
/// ```dart
/// FlexibleGridOptions(
///   customWidth: 100.0,
///   customHeight: 100.0,
///   rows: 3,
///   columns: 3,
///   componentsToRender: [
///     Text("Item 1"),
///     Text("Item 2"),
///     Icon(Icons.star),
///   ],
///   backgroundColor: Colors.blueAccent,
///   showAspect: true,
/// );
/// ```
class FlexibleGridOptions {
  final double? customWidth;
  final double? customHeight;
  final int rows;
  final int columns;
  final List<Widget> componentsToRender;
  final Color backgroundColor;
  final bool showAspect;
  final EdgeInsetsGeometry? containerPadding;
  final EdgeInsetsGeometry? containerMargin;
  final Decoration? containerDecoration;
  final AlignmentGeometry? containerAlignment;
  final Clip containerClipBehavior;
  final BoxConstraints? containerConstraints;
  final MainAxisAlignment? gridMainAxisAlignment;
  final CrossAxisAlignment? gridCrossAxisAlignment;
  final MainAxisSize gridMainAxisSize;
  final double? rowSpacing;
  final double? columnSpacing;
  final EdgeInsetsGeometry? rowPadding;
  final EdgeInsetsGeometry? rowMargin;
  final Decoration? rowDecoration;
  final Clip rowClipBehavior;
  final MainAxisAlignment? rowMainAxisAlignment;
  final CrossAxisAlignment? rowCrossAxisAlignment;
  final MainAxisSize rowMainAxisSize;
  final EdgeInsetsGeometry? cellPadding;
  final EdgeInsetsGeometry? cellMargin;
  final Decoration? cellDecoration;
  final Decoration? emptyCellDecoration;
  final Clip cellClipBehavior;
  final AlignmentGeometry? cellAlignment;
  final Widget? emptyCell;
  final FlexibleGridEmptyCellBuilder? emptyCellBuilder;
  final FlexibleGridCellBuilder? cellBuilder;
  final FlexibleGridRowBuilder? rowBuilder;
  final FlexibleGridGridBuilder? gridBuilder;
  final FlexibleGridContainerBuilder? containerBuilder;

  const FlexibleGridOptions({
    required this.customWidth,
    required this.customHeight,
    required this.rows,
    required this.columns,
    required this.componentsToRender,
    this.backgroundColor = Colors.transparent,
    this.showAspect = true,
    this.containerPadding,
    this.containerMargin,
    this.containerDecoration,
    this.containerAlignment,
    this.containerClipBehavior = Clip.none,
    this.containerConstraints,
    this.gridMainAxisAlignment,
    this.gridCrossAxisAlignment,
    this.gridMainAxisSize = MainAxisSize.min,
    this.rowSpacing = 2,
    this.columnSpacing = 2,
    this.rowPadding,
    this.rowMargin,
    this.rowDecoration,
    this.rowClipBehavior = Clip.none,
    this.rowMainAxisAlignment,
    this.rowCrossAxisAlignment,
    this.rowMainAxisSize = MainAxisSize.min,
    this.cellPadding,
    this.cellMargin,
    this.cellDecoration,
    this.emptyCellDecoration,
    this.cellClipBehavior = Clip.none,
    this.cellAlignment,
    this.emptyCell,
    this.emptyCellBuilder,
    this.cellBuilder,
    this.rowBuilder,
    this.gridBuilder,
    this.containerBuilder,
  });
}

class FlexibleGridContainerContext {
  final BuildContext buildContext;
  final FlexibleGridOptions options;
  final List<Widget> rows;

  const FlexibleGridContainerContext({
    required this.buildContext,
    required this.options,
    required this.rows,
  });
}

class FlexibleGridGridContext {
  final BuildContext buildContext;
  final FlexibleGridOptions options;
  final List<Widget> rows;

  const FlexibleGridGridContext({
    required this.buildContext,
    required this.options,
    required this.rows,
  });
}

class FlexibleGridRowContext {
  final BuildContext buildContext;
  final FlexibleGridOptions options;
  final int rowIndex;
  final List<Widget> cells;

  const FlexibleGridRowContext({
    required this.buildContext,
    required this.options,
    required this.rowIndex,
    required this.cells,
  });
}

class FlexibleGridCellContext {
  final BuildContext buildContext;
  final FlexibleGridOptions options;
  final int index;
  final int rowIndex;
  final int columnIndex;
  final Widget? component;
  final bool hasComponent;

  const FlexibleGridCellContext({
    required this.buildContext,
    required this.options,
    required this.index,
    required this.rowIndex,
    required this.columnIndex,
    required this.component,
    required this.hasComponent,
  });
}

typedef FlexibleGridContainerBuilder = Widget Function(
  FlexibleGridContainerContext context,
  Widget defaultContainer,
);

typedef FlexibleGridGridBuilder = Widget Function(
  FlexibleGridGridContext context,
  Widget defaultGrid,
);

typedef FlexibleGridRowBuilder = Widget Function(
  FlexibleGridRowContext context,
  Widget defaultRow,
);

typedef FlexibleGridCellBuilder = Widget Function(
  FlexibleGridCellContext context,
  Widget defaultCell,
);

typedef FlexibleGridEmptyCellBuilder = Widget? Function(
  FlexibleGridCellContext context,
  Widget? suggested,
);

typedef FlexibleGridType = Widget Function(
    {required FlexibleGridOptions options});

/// `FlexibleGrid` - A widget that displays a flexible grid layout based on specified rows and columns.
///
/// The `FlexibleGrid` widget uses the options provided in `FlexibleGridOptions` to construct a grid layout.
/// The grid cells can display a repeated pattern of components when there are fewer components than slots in the grid.
///
/// ### Example Usage:
/// ```dart
/// FlexibleGrid(
///   options: FlexibleGridOptions(
///     customWidth: 100.0,
///     customHeight: 100.0,
///     rows: 2,
///     columns: 2,
///     componentsToRender: [
///       Text("Component 1"),
///       Icon(Icons.star),
///       Icon(Icons.circle),
///     ],
///     backgroundColor: Colors.grey,
///   ),
/// );
/// ```
///
/// ### Notes:
/// - If there are fewer components than grid slots, the provided components are repeated across the grid.
/// - `customWidth` and `customHeight` determine the cell dimensions; otherwise, the cells use a default 1:1 aspect ratio.
class FlexibleGrid extends StatelessWidget {
  final FlexibleGridOptions options;

  const FlexibleGrid({super.key, required this.options});

  double? _positiveDimension(double? value) {
    if (value == null || value.isNaN || value.isInfinite || value <= 0) {
      return null;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    if (options.rows <= 0 || options.columns <= 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final textDirection = Directionality.of(context);
        final EdgeInsets resolvedContainerPadding =
            options.containerPadding?.resolve(textDirection) ?? EdgeInsets.zero;
        final EdgeInsets resolvedRowPadding =
            options.rowPadding?.resolve(textDirection) ?? EdgeInsets.zero;
        final EdgeInsets resolvedRowMargin =
            options.rowMargin?.resolve(textDirection) ?? EdgeInsets.zero;
        final EdgeInsets resolvedCellMargin =
            options.cellMargin?.resolve(textDirection) ?? EdgeInsets.zero;

        final BoxConstraints enforcedConstraints =
            options.containerConstraints == null
                ? constraints
                : constraints.enforce(options.containerConstraints!);

        final double columnSpacing = options.columnSpacing ?? 0;
        final double totalColumnSpacing =
            columnSpacing * math.max(0, options.columns - 1);
        final double totalCellMarginWidth =
            resolvedCellMargin.horizontal * math.max(0, options.columns);

        double? computedWidth;
        if (enforcedConstraints.maxWidth.isFinite) {
          final double usableWidth = (enforcedConstraints.maxWidth -
                  resolvedContainerPadding.horizontal -
                  totalColumnSpacing -
                  totalCellMarginWidth)
              .clamp(0.0, double.infinity);
          if (options.columns > 0 && usableWidth > 0) {
            computedWidth = usableWidth / options.columns;
          }
        }

        final double rowSpacing = options.rowSpacing ?? 0;
        final double totalRowSpacing =
            rowSpacing * math.max(0, options.rows - 1);
        final double totalCellMarginHeight =
            resolvedCellMargin.vertical * math.max(0, options.rows);
        final double totalRowPaddingHeight =
            resolvedRowPadding.vertical * math.max(0, options.rows);
        final double totalRowMarginHeight =
            resolvedRowMargin.vertical * math.max(0, options.rows);

        double? computedHeight;
        if (enforcedConstraints.maxHeight.isFinite) {
          final double usableHeight = (enforcedConstraints.maxHeight -
                  resolvedContainerPadding.vertical -
                  totalRowSpacing -
                  totalCellMarginHeight -
                  totalRowPaddingHeight -
                  totalRowMarginHeight)
              .clamp(0.0, double.infinity);
          if (options.rows > 0 && usableHeight > 0) {
            computedHeight = usableHeight / options.rows;
          }
        }

        final double cellWidth = _positiveDimension(options.customWidth) ??
            _positiveDimension(computedWidth) ??
            120.0;
        final double cellHeight = _positiveDimension(options.customHeight) ??
            _positiveDimension(computedHeight) ??
            cellWidth;

        final components = options.componentsToRender;
        final List<Widget> rowWidgets = [];

        for (var rowIndex = 0; rowIndex < options.rows; rowIndex++) {
          final List<Widget> cellWidgets = [];

          for (var columnIndex = 0;
              columnIndex < options.columns;
              columnIndex++) {
            final cellIndex = rowIndex * options.columns + columnIndex;
            final component =
                cellIndex < components.length ? components[cellIndex] : null;
            final hasComponent = component != null;

            final cellContext = FlexibleGridCellContext(
              buildContext: context,
              options: options,
              index: cellIndex,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
              component: component,
              hasComponent: hasComponent,
            );

            Widget content = component ??
                options.emptyCellBuilder
                    ?.call(cellContext, options.emptyCell) ??
                options.emptyCell ??
                const SizedBox.shrink();

            final Decoration? decoration = hasComponent
                ? options.cellDecoration
                : options.emptyCellDecoration ?? options.cellDecoration;

            Widget defaultCell = Container(
              margin: options.cellMargin,
              padding: options.cellPadding,
              alignment: options.cellAlignment ?? Alignment.center,
              decoration:
                  decoration ?? BoxDecoration(color: options.backgroundColor),
              clipBehavior: options.cellClipBehavior,
              child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                  width: cellWidth,
                  height: cellHeight,
                ),
                child: content,
              ),
            );

            if (options.cellBuilder != null) {
              defaultCell = options.cellBuilder!(cellContext, defaultCell);
            }

            if (cellWidgets.isNotEmpty && columnSpacing > 0) {
              cellWidgets.add(SizedBox(width: columnSpacing));
            }

            cellWidgets.add(defaultCell);
          }

          Widget row = Row(
            mainAxisSize: options.rowMainAxisSize,
            mainAxisAlignment:
                options.rowMainAxisAlignment ?? MainAxisAlignment.start,
            crossAxisAlignment:
                options.rowCrossAxisAlignment ?? CrossAxisAlignment.center,
            children: cellWidgets,
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

          final rowContext = FlexibleGridRowContext(
            buildContext: context,
            options: options,
            rowIndex: rowIndex,
            cells: List.unmodifiable(cellWidgets),
          );

          if (options.rowBuilder != null) {
            row = options.rowBuilder!(rowContext, row);
          }

          if (rowWidgets.isNotEmpty && rowSpacing > 0) {
            rowWidgets.add(SizedBox(height: rowSpacing));
          }

          rowWidgets.add(row);
        }

        Widget gridColumn = Column(
          mainAxisSize: options.gridMainAxisSize,
          mainAxisAlignment:
              options.gridMainAxisAlignment ?? MainAxisAlignment.start,
          crossAxisAlignment:
              options.gridCrossAxisAlignment ?? CrossAxisAlignment.stretch,
          children: rowWidgets,
        );

        final gridContext = FlexibleGridGridContext(
          buildContext: context,
          options: options,
          rows: List.unmodifiable(rowWidgets),
        );

        if (options.gridBuilder != null) {
          gridColumn = options.gridBuilder!(gridContext, gridColumn);
        }

        Widget container = Container(
          padding: options.containerPadding,
          margin: options.containerMargin,
          decoration: options.containerDecoration ??
              BoxDecoration(color: options.backgroundColor),
          alignment: options.containerAlignment,
          clipBehavior: options.containerClipBehavior,
          constraints: options.containerConstraints,
          child: gridColumn,
        );

        final containerContext = FlexibleGridContainerContext(
          buildContext: context,
          options: options,
          rows: List.unmodifiable(rowWidgets),
        );

        if (options.containerBuilder != null) {
          container = options.containerBuilder!(containerContext, container);
        }

        return container;
      },
    );
  }
}
