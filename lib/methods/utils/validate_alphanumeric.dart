/// Options for the alphanumeric validation, containing the string to validate.
class ValidateAlphanumericOptions {
  final String str;

  ValidateAlphanumericOptions({required this.str});
}

typedef ValidateAlphanumericType = Future<bool> Function(
    ValidateAlphanumericOptions options);

/// Validates if the provided string in [options] contains only alphanumeric characters.
///
/// Returns `true` if the string is alphanumeric, otherwise `false`.
///
/// Example usage:
/// ```dart
/// final isValid = await validateAlphanumeric(ValidateAlphanumericOptions(str: "abc123"));
/// print(isValid); // Output: true
/// ```
Future<bool> validateAlphanumeric(ValidateAlphanumericOptions options) async {
  RegExp alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
  return alphanumericRegex.hasMatch(options.str);
}
