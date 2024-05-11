import 'dart:async';

/// Updates the mini cards grid based on the provided parameters.
///
/// The [rows] parameter specifies the number of rows in the grid.
/// The [cols] parameter specifies the number of columns in the grid.
/// The [defal] parameter specifies whether to update the default grid or an alternative grid.
/// The [actualRows] parameter specifies the actual number of rows in the grid.
/// The [ind] parameter specifies the index of the grid.
/// The [parameters] parameter is a map that contains various update functions and grid sizes.
///
/// The [parameters] map should contain the following keys:
/// - 'getUpdatedAllParams': A function that returns a map of updated parameters.
/// - 'updateGridRows': A function that updates the number of rows in the grid.
/// - 'updateGridCols': A function that updates the number of columns in the grid.
/// - 'updateAltGridRows': A function that updates the number of rows in the alternative grid.
/// - 'updateAltGridCols': A function that updates the number of columns in the alternative grid.
/// - 'updateGridSizes': A function that updates the grid sizes.
/// - 'gridSizes': A map that contains the current grid sizes.
/// - 'paginationDirection': A string that specifies the pagination direction.
/// - 'paginationHeightWidth': An integer that specifies the pagination height or width.
/// - 'doPaginate': A boolean that indicates whether pagination is enabled.
/// - 'componentSizes': A map that contains the sizes of various components.
/// - 'eventType': A string that specifies the type of event.
///
/// The function calculates the card width and height based on the container size, number of rows, and number of columns.
/// It then updates the grid sizes and calls the appropriate update functions based on the [defal] parameter.
///
/// Throws an error if any of the required parameters are missing.

typedef UpdateGridRows = void Function(int rows);
typedef UpdateGridCols = void Function(int cols);
typedef UpdateAltGridRows = void Function(int rows);
typedef UpdateAltGridCols = void Function(int cols);
typedef UpdateGridSizes = void Function(Map<String, int> gridSizes);
typedef GetUpdatedAllParams = Map<String, dynamic> Function();

Future<void> updateMiniCardsGrid({
  required int rows,
  required int cols,
  bool defal = true,
  int actualRows = 2,
  int ind = 0,
  required Map<String, dynamic> parameters,
}) async {
  GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];

  parameters = getUpdatedAllParams();

  UpdateGridRows updateGridRows = parameters['updateGridRows'];
  UpdateGridCols updateGridCols = parameters['updateGridCols'];
  UpdateAltGridRows updateAltGridRows = parameters['updateAltGridRows'];
  UpdateAltGridCols updateAltGridCols = parameters['updateAltGridCols'];
  UpdateGridSizes updateGridSizes = parameters['updateGridSizes'];

  Map<String, int> gridSizes = parameters['gridSizes'];
  String paginationDirection = parameters['paginationDirection'];
  int paginationHeightWidth = parameters['paginationHeightWidth'];
  bool doPaginate = parameters['doPaginate'];
  Map<String, double> componentSizes = parameters['componentSizes'];
  String eventType = parameters['eventType'];

  double? containerWidth = componentSizes['otherWidth'];
  double? containerHeight = componentSizes['otherHeight'];

  if (doPaginate) {
    if (paginationDirection == 'horizontal') {
      if (containerHeight != null) {
        containerHeight -= paginationHeightWidth;
      }
    } else {
      if (containerWidth != null) {
        containerWidth -= paginationHeightWidth;
      }
    }
  }

  int cardSpacing = 1; // 3px margin between cards
  if (eventType == 'chat') {
    cardSpacing = 0;
  }
  int totalSpacingHorizontal = (cols - 1) * cardSpacing;
  int totalSpacingVertical = (actualRows - 1) * cardSpacing;
  int cardWidth = cols == 0 || actualRows == 0
      ? 0
      : ((containerWidth! - totalSpacingHorizontal) / cols).floor();
  int cardHeight = cols == 0 || actualRows == 0
      ? 0
      : ((containerHeight! - totalSpacingVertical) / actualRows).floor();

  if (defal) {
    updateGridRows(rows);
    updateGridCols(cols);

    gridSizes = {
      ...gridSizes,
      'gridWidth': cardWidth,
      'gridHeight': cardHeight,
    };
    updateGridSizes(gridSizes);
  } else {
    updateAltGridRows(rows);
    updateAltGridCols(cols);

    gridSizes = {
      ...gridSizes,
      'altGridWidth': cardWidth,
      'altGridHeight': cardHeight,
    };
    updateGridSizes(gridSizes);
  }
}
