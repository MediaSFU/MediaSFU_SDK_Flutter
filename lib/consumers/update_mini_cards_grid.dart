import '../types/types.dart' show GridSizes, ComponentSizes, EventType;

/// Parameters required for updating the mini cards grid layout.
///
/// This class holds the properties and functions needed to update
/// the grid layout dynamically based on configuration changes.
abstract class UpdateMiniCardsGridParameters {
  // Update functions as abstract getters returning function types
  void Function(int) get updateGridRows;
  void Function(int) get updateGridCols;
  void Function(int) get updateAltGridRows;
  void Function(int) get updateAltGridCols;
  void Function(GridSizes) get updateGridSizes;

  // Properties as abstract getters
  GridSizes get gridSizes;
  String get paginationDirection;
  double get paginationHeightWidth;
  bool get doPaginate;
  ComponentSizes get componentSizes;
  EventType get eventType;

  // Method to retrieve updated parameters as a getter
  UpdateMiniCardsGridParameters Function() get getUpdatedAllParams;

  // Dynamic access operator for additional properties
  // dynamic operator [](String key);
}

/// Options for configuring the mini cards grid update.
class UpdateMiniCardsGridOptions {
  final int rows;
  final int cols;
  final bool defal;
  final int actualRows;
  final UpdateMiniCardsGridParameters parameters;

  /// Constructor for [UpdateMiniCardsGridOptions].
  ///
  /// [rows] and [cols] specify the number of rows and columns in the grid.
  /// [defal] determines if the main grid should be updated (`true`) or the alternate grid (`false`).
  /// [actualRows] is the number of rows used in the grid layout calculation.
  /// [parameters] holds the necessary functions and configurations for the grid update.
  UpdateMiniCardsGridOptions({
    required this.rows,
    required this.cols,
    this.defal = true,
    this.actualRows = 2,
    required this.parameters,
  });
}

typedef UpdateMiniCardsGridType = Future<void> Function(
    UpdateMiniCardsGridOptions options);

/// Updates the mini cards grid layout based on the specified configuration.
///
/// This function calculates the dimensions of each grid cell and updates either
/// the main grid or an alternative grid based on [defal]. The layout calculation
/// considers pagination adjustments, event-specific spacing, and component dimensions.
///
/// * [rows] - The number of rows in the grid.
/// * [cols] - The number of columns in the grid.
/// * [defal] - If `true`, updates the main grid; if `false`, updates an alternative grid.
/// * [actualRows] - The effective row count used for layout calculations.
///
/// Example usage:
/// ```dart
/// final params = UpdateMiniCardsGridParameters(
///   updateGridRows: (rows) => print('Updated grid rows: $rows'),
///   updateGridCols: (cols) => print('Updated grid cols: $cols'),
///   updateAltGridRows: (rows) => print('Updated alt grid rows: $rows'),
///   updateAltGridCols: (cols) => print('Updated alt grid cols: $cols'),
///   updateGridSizes: (gridSizes) => print('Updated grid sizes: $gridSizes'),
///   gridSizes: GridSizes(gridWidth: 100, gridHeight: 100, altGridWidth: 80, altGridHeight: 80),
///   paginationDirection: 'horizontal',
///   paginationHeightWidth: 30.0,
///   doPaginate: true,
///   componentSizes: ComponentSizes(otherWidth: 500, otherHeight: 300),
///   eventType: EventType.chat,
///   getUpdatedAllParams: () => params,
/// );
///
/// final options = UpdateMiniCardsGridOptions(
///   rows: 3,
///   cols: 4,
///   defal: true,
///   actualRows: 3,
///   parameters: params,
/// );
///
/// await updateMiniCardsGrid(options);
/// ```
Future<void> updateMiniCardsGrid(UpdateMiniCardsGridOptions options) async {
  // Retrieve updated parameters
  var parameters = options.parameters.getUpdatedAllParams();

  // Destructure parameters
  final updateGridRows = parameters.updateGridRows;
  final updateGridCols = parameters.updateGridCols;
  final updateAltGridRows = parameters.updateAltGridRows;
  final updateAltGridCols = parameters.updateAltGridCols;
  final updateGridSizes = parameters.updateGridSizes;

  // Grid configuration
  var gridSizes = parameters.gridSizes;
  final paginationDirection = parameters.paginationDirection;
  final paginationHeightWidth = parameters.paginationHeightWidth;
  final doPaginate = parameters.doPaginate;
  final componentSizes = parameters.componentSizes;
  final eventType = parameters.eventType;

  double containerWidth = componentSizes.otherWidth;
  double containerHeight = componentSizes.otherHeight;

  // Adjust container size for pagination if enabled
  if (doPaginate) {
    if (paginationDirection == 'horizontal') {
      containerHeight -= paginationHeightWidth;
    } else {
      containerWidth -= paginationHeightWidth;
    }
  }

  int cardSpacing = eventType == EventType.chat ? 0 : 3;
  final totalSpacingHorizontal = (options.cols - 1) * cardSpacing;
  final totalSpacingVertical = (options.actualRows - 1) * cardSpacing;

  // Calculate individual card dimensions
  final cardWidth = options.cols == 0 || options.actualRows == 0
      ? 0
      : ((containerWidth - totalSpacingHorizontal) / options.cols).floor();
  final cardHeight = options.cols == 0 || options.actualRows == 0
      ? 0
      : ((containerHeight - totalSpacingVertical) / options.actualRows).floor();

  // Update grid or alternative grid based on `defal` flag
  if (options.defal) {
    updateGridRows(options.rows);
    updateGridCols(options.cols);
    gridSizes = GridSizes(
      gridWidth: cardWidth,
      gridHeight: cardHeight,
      altGridWidth: gridSizes.altGridWidth,
      altGridHeight: gridSizes.altGridHeight,
    );
    updateGridSizes(gridSizes);
  } else {
    updateAltGridRows(options.rows);
    updateAltGridCols(options.cols);
    gridSizes = GridSizes(
      gridWidth: gridSizes.gridWidth,
      gridHeight: gridSizes.gridHeight,
      altGridWidth: cardWidth,
      altGridHeight: cardHeight,
    );
    updateGridSizes(gridSizes);
  }
}
