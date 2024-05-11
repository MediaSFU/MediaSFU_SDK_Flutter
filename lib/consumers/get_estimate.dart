typedef CalculateRowsAndColumns = List<int> Function(int n);
typedef UpdateFunction<T> = void Function(T value);

/// Calculates the estimate for the number of rows and columns based on the given parameters.
///
/// The [n] parameter represents the total number of items.
/// The [parameters] parameter is a map that contains the following keys:
///   - 'fixedPageLimit': The maximum number of items per page.
///   - 'screenPageLimit': The maximum number of items per page when sharing the screen.
///   - 'shareScreenStarted': A boolean indicating whether the screen sharing has started.
///   - 'shared': A boolean indicating whether the screen is being shared.
///   - 'eventType': The type of event ('chat' or 'conference').
///   - 'isWideScreen': A boolean indicating whether the screen is wide.
///   - 'isMediumScreen': A boolean indicating whether the screen is medium-sized.
///   - 'updateRemoveAltGrid': A function to update the value of 'removeAltGrid'.
///
/// The function returns a list containing the estimated number of items, rows, and columns.
/// If an error occurs during estimation, it returns a list with the original number of items and 1 row and column.

List<dynamic> getEstimate(
    {required int n, required Map<String, dynamic> parameters}) {
  try {
    // Destructure parameters
    int fixedPageLimit = parameters['fixedPageLimit'];
    int screenPageLimit = parameters['screenPageLimit'];
    bool shareScreenStarted = parameters['shareScreenStarted'];
    bool shared = parameters['shared'];
    String eventType = parameters['eventType'];
    bool isWideScreen = parameters['isWideScreen'];
    bool isMediumScreen = parameters['isMediumScreen'];
    UpdateFunction<bool> updateRemoveAltGrid =
        parameters['updateRemoveAltGrid'];

    // mediasfu functions
    CalculateRowsAndColumns calculateRowsAndColumns =
        parameters['calculateRowsAndColumns'];

    // Calculate rows and columns
    var rowsAndColumns = calculateRowsAndColumns(n);
    var rows = rowsAndColumns[0];
    var cols = rowsAndColumns[1];

    // Check conditions for removing alt grid
    if (n < fixedPageLimit ||
        ((shareScreenStarted || shared) && n < screenPageLimit + 1)) {
      var removeAltGrid = true;
      updateRemoveAltGrid(removeAltGrid);

      // Return estimated values based on screen width
      if (!(isMediumScreen || isWideScreen)) {
        return eventType == 'chat' ||
                (eventType == 'conference' && !(shareScreenStarted || shared))
            ? [n, n, 1]
            : [n, 1, n];
      } else {
        return eventType == 'chat' ||
                (eventType == 'conference' && !(shareScreenStarted || shared))
            ? [n, 1, n]
            : [n, n, 1];
      }
    }

    return [rows * cols, rows, cols];
  } catch (error) {
    // Handle errors during estimation
    return [n, 1, n];
    // rethrow;
  }
}
