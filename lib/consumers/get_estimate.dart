import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show EventType, CalculateRowsAndColumnsType, CalculateRowsAndColumnsOptions;

/// Parameters for estimating rows and columns based on given configurations.
abstract class GetEstimateParameters {
  // Properties as abstract getters
  int get fixedPageLimit;
  int get screenPageLimit;
  bool get shareScreenStarted;
  bool get shared;
  EventType get eventType;
  bool get removeAltGrid;
  bool get isWideScreen;
  bool get isMediumScreen;

  // Update function as an abstract getter
  void Function(bool) get updateRemoveAltGrid;

  // Mediasfu function as an abstract getter
  CalculateRowsAndColumnsType get calculateRowsAndColumns;
}

class GetEstimateOptions {
  int n;
  GetEstimateParameters parameters;

  GetEstimateOptions({
    required this.n,
    required this.parameters,
  });
}

typedef GetEstimateType = List<int> Function(GetEstimateOptions options);

/// Estimates the number of rows and columns based on the provided options.
///
/// - [options] The options containing the number of items and parameters to use in the estimation.
/// - Returns a list `[totalItems, rows, columns]` representing the calculated number of items, rows, and columns.
///
/// Example usage:
/// ```dart
/// final parameters = GetEstimateParameters(
///   fixedPageLimit: 5,
///   screenPageLimit: 8,
///   shareScreenStarted: false,
///   shared: false,
///   eventType: EventType.conference,
///   removeAltGrid: false,
///   isWideScreen: true,
///   isMediumScreen: false,
///   updateRemoveAltGrid: (value) => print('Remove Alt Grid: $value'),
///   calculateRowsAndColumns: (n) => [3, 4],
/// );
///
/// final options = GetEstimateOptions(n: 10, parameters: parameters);
/// final estimate = getEstimate(options);
/// print('Estimated: $estimate'); // Output: Estimated: [10, 3, 4]
/// ```
///
List<int> getEstimate(GetEstimateOptions options) {
  try {
    // Destructure parameters
    var params = options.parameters;
    int fixedPageLimit = params.fixedPageLimit;
    int screenPageLimit = params.screenPageLimit;
    bool shareScreenStarted = params.shareScreenStarted;
    bool shared = params.shared;
    EventType eventType = params.eventType;
    bool removeAltGrid = params.removeAltGrid;
    bool isWideScreen = params.isWideScreen;
    bool isMediumScreen = params.isMediumScreen;
    var updateRemoveAltGrid = params.updateRemoveAltGrid;
    CalculateRowsAndColumnsType calculateRowsAndColumns =
        params.calculateRowsAndColumns;

    // Calculate rows and columns
    final optionCal = CalculateRowsAndColumnsOptions(n: options.n);
    List<int> rowsAndCols = calculateRowsAndColumns(optionCal);
    int rows = rowsAndCols[0];
    int cols = rowsAndCols[1];

    // Check conditions for removing alt grid
    if (options.n < fixedPageLimit ||
        ((shareScreenStarted || shared) && options.n < screenPageLimit + 1)) {
      removeAltGrid = true;
      updateRemoveAltGrid(removeAltGrid);

      // Return estimated values based on screen width and event type
      if (!(isMediumScreen || isWideScreen)) {
        return eventType == EventType.chat ||
                (eventType == EventType.conference &&
                    !(shareScreenStarted || shared))
            ? [options.n, options.n, 1]
            : [options.n, 1, options.n];
      } else {
        return eventType == EventType.chat ||
                (eventType == EventType.conference &&
                    !(shareScreenStarted || shared))
            ? [options.n, 1, options.n]
            : [options.n, options.n, 1];
      }
    }

    return [rows * cols, rows, cols];
  } catch (error) {
    if (kDebugMode) {
      // print("Error estimating rows and columns: ${error.toString()}");
    }
    return [options.n, 1, options.n];
  }
}
