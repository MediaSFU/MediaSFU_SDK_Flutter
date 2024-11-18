/// Options for the formatNumber function.
class FormatNumberOptions {
  final int number;

  FormatNumberOptions({required this.number});
}

/// Type definition for the formatNumber function.
typedef FormatNumberType = Future<String?> Function(
    FormatNumberOptions options);

/// Formats a given number into a human-readable string representation with suffixes (K, M, B).
///
/// The `formatNumber` function takes a `FormatNumberOptions` object with a specified `number`
/// and formats it based on magnitude:
/// - Numbers less than 1,000 are returned as-is.
/// - Numbers between 1,000 and 999,999 are formatted as "X.XK" (e.g., 1,500 becomes "1.5K").
/// - Numbers between 1,000,000 and 999,999,999 are formatted as "X.XM" (e.g., 1,500,000 becomes "1.5M").
/// - Numbers between 1,000,000,000 and 999,999,999,999 are formatted as "X.XB" (e.g., 1,500,000,000 becomes "1.5B").
///
/// Returns `null` if the `number` is non-positive or not specified.
///
/// ## Example Usage:
///
/// ```dart
/// // Define options for different number values
/// FormatNumberOptions options1 = FormatNumberOptions(number: 500);
/// FormatNumberOptions options2 = FormatNumberOptions(number: 1500);
/// FormatNumberOptions options3 = FormatNumberOptions(number: 1500000);
/// FormatNumberOptions options4 = FormatNumberOptions(number: 1500000000);
///
/// // Format the numbers using the formatNumber function
/// print(await formatNumber(options1)); // Output: "500"
/// print(await formatNumber(options2)); // Output: "1.5K"
/// print(await formatNumber(options3)); // Output: "1.5M"
/// print(await formatNumber(options4)); // Output: "1.5B"
/// ```

Future<String?> formatNumber(FormatNumberOptions options) async {
  int number = options.number;
  if (number > 0) {
    if (number < 1e3) {
      return number.toString();
    } else if (number < 1e6) {
      return '${(number / 1e3).toStringAsFixed(1)}K';
    } else if (number < 1e9) {
      return '${(number / 1e6).toStringAsFixed(1)}M';
    } else if (number < 1e12) {
      return '${(number / 1e9).toStringAsFixed(1)}B';
    }
  }
  return null;
}
