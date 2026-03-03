import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../components/display_components/flexible_grid.dart'
    show
        FlexibleGridOptions,
        FlexibleGridCellContext,
        FlexibleGridRowContext,
        FlexibleGridGridContext,
        FlexibleGridContainerContext;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

typedef ModernFlexibleGridType = Widget Function(
    {required FlexibleGridOptions options});

/// Modern styled flexible grid that accepts [FlexibleGridOptions].
/// Provides modern visual treatment while maintaining API compatibility
/// with the original FlexibleGrid.
class ModernFlexibleGrid extends StatelessWidget {
  final FlexibleGridOptions options;
  final bool isDarkMode;
  final bool enableGlassmorphism;
  final BorderRadius? cellBorderRadius;

  const ModernFlexibleGrid({
    super.key,
    required this.options,
    this.isDarkMode = true,
    this.enableGlassmorphism = true,
    this.cellBorderRadius,
  });

  double? _positiveDimension(double? value) {
    if (value == null || value.isNaN || value.isInfinite || value <= 0) {
      return null;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    // Early return if no rows/columns (matching original FlexibleGrid)
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
            computedWidth = (usableWidth / options.columns).floorToDouble();
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
            computedHeight = (usableHeight / options.rows).floorToDouble();
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
                _buildEmpty(context);

            final Decoration? decoration = hasComponent
                ? options.cellDecoration
                : options.emptyCellDecoration ?? options.cellDecoration;

            // Use modern styling if no custom decoration provided
            final BoxDecoration modernDecoration = BoxDecoration(
              borderRadius: cellBorderRadius ?? BorderRadius.circular(8),
              color: hasComponent
                  ? Colors.transparent
                  : (isDarkMode
                      ? Colors.white.withOpacity(0.03)
                      : Colors.black.withOpacity(0.02)),
            );

            Widget defaultCell = Container(
              margin: options.cellMargin,
              padding: options.cellPadding,
              alignment: options.cellAlignment ?? Alignment.center,
              decoration: decoration ??
                  (hasComponent
                      ? BoxDecoration(color: options.backgroundColor)
                      : modernDecoration),
              clipBehavior: options.cellClipBehavior,
              child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                  width: cellWidth,
                  height: cellHeight,
                ),
                child: hasComponent
                    ? ClipRRect(
                        borderRadius:
                            cellBorderRadius ?? BorderRadius.circular(8),
                        child: content,
                      )
                    : content,
              ),
            );

            if (options.cellBuilder != null) {
              defaultCell = options.cellBuilder!(cellContext, defaultCell);
            }

            if (cellWidgets.isNotEmpty && columnSpacing > 0) {
              cellWidgets.add(SizedBox(width: columnSpacing));
            }

            // Use Flexible to allow cells to share space evenly and prevent overflow
            cellWidgets.add(Flexible(
              flex: 1,
              child: defaultCell,
            ));
          }

          // Wrap row in ClipRect to prevent overflow rendering errors
          Widget row = ClipRect(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment:
                  options.rowMainAxisAlignment ?? MainAxisAlignment.start,
              crossAxisAlignment:
                  options.rowCrossAxisAlignment ?? CrossAxisAlignment.center,
              children: cellWidgets,
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

          // Use Flexible to allow rows to share vertical space evenly and prevent overflow
          rowWidgets.add(Flexible(
            flex: 1,
            child: row,
          ));
        }

        Widget gridColumn = Column(
          mainAxisSize: MainAxisSize.max,
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

  Widget _buildEmpty(BuildContext context) {
    final isDark = isDarkMode;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(MediasfuSpacing.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            MediasfuColors.primary.withOpacity(0.08),
            MediasfuColors.secondary.withOpacity(0.08)
          ]),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_outline_rounded,
          size: 20,
          color: isDark
              ? Colors.white.withOpacity(0.25)
              : Colors.black.withOpacity(0.15),
        ),
      ),
    );
  }
}
