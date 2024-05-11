import 'dart:async';

import 'package:flutter/foundation.dart';

/// A function type that represents a function that checks the grid.
///
/// The function takes in the number of rows, number of columns, and number of active cells,
/// and returns a [Future] that resolves to a list of dynamic values.
/// Checks the grid based on the given number of rows, number of columns, and number of active cells.
///
/// The function calculates various properties of the grid, such as the number of rows and columns,
/// the last row and its number of columns, the remaining videos, the number of cells to add,
/// the actual number of rows, and whether to remove the alternate grid.
///
/// If the product of the number of rows and number of columns is not equal to the number of active cells,
/// the function adjusts the grid to accommodate the active cells.
///
/// Returns a list containing the following values in the specified order:
/// - [removeAltGrid]: A boolean indicating whether to remove the alternate grid.
/// - [numtoadd]: The number of cells to add.
/// - [numRows]: The number of rows in the grid.
/// - [numCols]: The number of columns in the grid.
/// - [remainingVideos]: The number of remaining videos.
/// - [actualRows]: The actual number of rows in the grid.
/// - [lastrowcols]: The number of columns in the last row of the grid.
///
/// If an error occurs during the execution of the function, an empty list is returned.

typedef CheckGridFunction = Future<List<dynamic>> Function(
    int rows, int cols, int actives);

Future<List<dynamic>> checkGrid(int rows, int cols, int actives) async {
  try {
    int numRows = 0;
    int numCols = 0;
    int lastrow = 0;
    int lastrowcols = 0;
    int remainingVideos = 0;
    int numtoadd = 0;
    int actualRows = 0;
    bool removeAltGrid = false;

    if (rows * cols != actives) {
      if (rows * cols > actives) {
        final res = actives - (rows - 1) * cols;
        if (cols * 0.5 < res) {
          lastrow = rows;
          lastrowcols = res;
          remainingVideos = lastrowcols;
        } else {
          lastrowcols = res + cols;
          lastrow = rows - 1;
          remainingVideos = lastrowcols;
        }

        numRows = lastrow - 1;
        numCols = cols;
        numtoadd = (lastrow - 1) * numCols;
        actualRows = lastrow;

        removeAltGrid = false;
      }
    } else {
      // Perfect fit
      numCols = cols;
      numRows = rows;
      lastrow = rows;
      lastrowcols = cols;
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
      lastrowcols
    ];
  } catch (error) {
    if (kDebugMode) {
      // print('checkGrid error $error');
    }
    // throw error;
    return [];
  }
}
