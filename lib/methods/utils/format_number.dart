/// Formats a given [number] into a human-readable string representation.
///
/// If the [number] is not null and greater than 0, it will be formatted
/// based on its magnitude. Numbers less than 1,000 will be returned as is.
/// Numbers between 1,000 and 999,999 will be formatted as "X.XK", where X is
/// the number divided by 1,000 and rounded to 1 decimal place. Numbers between
/// 1,000,000 and 999,999,999 will be formatted as "X.XM", where X is the number
/// divided by 1,000,000 and rounded to 1 decimal place. Numbers between
/// 1,000,000,000 and 999,999,999,999 will be formatted as "X.XB", where X is
/// the number divided by 1,000,000,000 and rounded to 1 decimal place.
///
/// Returns null for falsy or non-positive input values.
String? formatNumber(int? number) {
  if (number != null && number > 0) {
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
  // Return null for falsy or non-positive input values
  return null;
}
