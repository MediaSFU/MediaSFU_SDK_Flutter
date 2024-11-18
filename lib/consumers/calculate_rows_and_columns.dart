import 'dart:math';

/// Options for calculating the number of rows and columns in a grid layout.
///
/// Contains the number of items to display in the grid.
class CalculateRowsAndColumnsOptions {
  final int n;

  CalculateRowsAndColumnsOptions({
    required this.n,
  });
}

/// Type definition for the `calculateRowsAndColumns` function.
///
/// Represents a function that takes in [CalculateRowsAndColumnsOptions] and returns a `List<int>`.
typedef CalculateRowsAndColumnsType = List<int> Function(
    CalculateRowsAndColumnsOptions options);

/// Calculates the number of rows and columns needed to display a given number of items in a grid.
///
/// ### Parameters:
/// - `options` (CalculateRowsAndColumnsOptions): Options containing the number of items to display.
///
/// ### Returns:
/// - A `List<int>` containing the calculated number of rows and columns.
///
/// ### Example:
/// ```dart
/// final options = CalculateRowsAndColumnsOptions(n: 10);
/// final result = calculateRowsAndColumns(options);
/// print('Rows: ${result[0]}, Columns: ${result[1]}'); // Outputs: Rows: 4, Columns: 3
/// ```
List<int> calculateRowsAndColumns(CalculateRowsAndColumnsOptions options) {
  // Calculate the square root of n
  final double sqrtVal = sqrt(options.n);

  // Initialize columns based on the floor of the square root
  int cols = sqrtVal.floor();

  // Calculate the number of rows needed to display n items
  int rows = (options.n / cols).ceil();

  // Calculate the product of rows and columns
  int prod = rows * cols;

  // Adjust rows and columns until the product is greater than or equal to n
  while (prod < options.n) {
    if (cols < rows) {
      cols++;
    } else {
      rows++;
    }
    prod = rows * cols;
  }

  // Return a list with the calculated number of rows and columns
  return [rows, cols];
}
