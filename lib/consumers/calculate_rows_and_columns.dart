import 'dart:math';

/// Calculates the number of rows and columns needed to display `n` videos in a grid layout.
///
/// The function takes an integer `n` as input and returns a list with the calculated number of rows and columns.
/// The number of columns is calculated based on the floor of the square root of `n`.
/// The number of rows is calculated by dividing `n` by the number of columns and rounding up to the nearest integer.
/// The function then adjusts the number of rows and columns until the product is greater than or equal to `n`.
///
/// Example usage:
///
/// ```dart
/// List<int> result = calculateRowsAndColumns(12);
/// print(result); // Output: [4, 3]
/// ```

List<int> calculateRowsAndColumns(int n) {
  // Calculate the square root of n
  final double sqrtVal = sqrt(n);

  // Initialize columns based on the floor of the square root
  int cols = sqrtVal.floor();

  // Calculate the number of rows needed to display n videos
  int rows = (n / cols).ceil();

  // Calculate the product of rows and columns
  int prod = rows * cols;

  // Adjust rows and columns until the product is greater than or equal to n
  while (prod < n) {
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
