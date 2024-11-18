import 'dart:async';
import 'package:flutter/foundation.dart';

/// Options for checking the grid configuration.
///
/// Contains properties such as the number of rows, columns, and active elements.
class CheckGridOptions {
  final int rows;
  final int cols;
  final int actives;

  CheckGridOptions({
    required this.rows,
    required this.cols,
    required this.actives,
  });
}

/// Type definition for the `checkGrid` function.
///
/// Represents a function that takes in [CheckGridOptions] and returns a `Future<List<dynamic>>`.
typedef CheckGridType = Future<List<dynamic>> Function(
    CheckGridOptions options);

/// Checks the grid configuration and calculates various parameters based on the number of rows, columns, and active elements.
///
/// ### Parameters:
/// - `options` (CheckGridOptions): The options containing grid details.
///
/// ### Returns:
/// - A `Future<List<dynamic>>` containing:
///   - `removeAltGrid` (bool): Whether to remove the alternate grid.
///   - `numtoadd` (int): The number of elements to add.
///   - `numRows` (int): The number of rows.
///   - `numCols` (int): The number of columns.
///   - `remainingVideos` (int): The remaining videos count.
///   - `actualRows` (int): The actual number of rows.
///   - `lastrowcols` (int): The number of columns in the last row.
///
/// ### Example:
/// ```dart
/// final options = CheckGridOptions(rows: 3, cols: 4, actives: 10);
///
/// checkGrid(options).then((result) {
///   print('Grid check result: $result');
/// }).catchError((error) {
///   print('Error checking grid: $error');
/// });
/// ```
Future<List<dynamic>> checkGrid(CheckGridOptions options) async {
  try {
    int numRows = 0;
    int numCols = 0;
    int lastrow = 0;
    int lastrowcols = 0;
    int remainingVideos = 0;
    int numtoadd = 0;
    int actualRows = 0;
    bool removeAltGrid = false;

    if (options.rows * options.cols != options.actives) {
      if (options.rows * options.cols > options.actives) {
        final res = options.actives - (options.rows - 1) * options.cols;
        if (options.cols * 0.5 < res) {
          lastrow = options.rows;
          lastrowcols = res;
          remainingVideos = lastrowcols;
        } else {
          lastrowcols = res + options.cols;
          lastrow = options.rows - 1;
          remainingVideos = lastrowcols;
        }

        numRows = lastrow - 1;
        numCols = options.cols;
        numtoadd = (lastrow - 1) * numCols;
        actualRows = lastrow;

        removeAltGrid = false;
      }
    } else {
      // Perfect fit
      numCols = options.cols;
      numRows = options.rows;
      lastrow = options.rows;
      lastrowcols = options.cols;
      remainingVideos = 0;
      numtoadd = lastrow * numCols;
      actualRows = lastrow;
      removeAltGrid = true;
    }

    return [
      removeAltGrid,
      numtoadd,
      numRows,
      numCols,
      remainingVideos,
      actualRows,
      lastrowcols,
    ];
  } catch (error) {
    if (kDebugMode) {
      print('checkGrid error: $error');
    }
    return [];
  }
}
