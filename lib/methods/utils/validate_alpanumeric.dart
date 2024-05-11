/// Validates if a given string is alphanumeric.
///
/// Returns `true` if the string is alphanumeric, otherwise `false`.
Future<bool> validateAlphanumeric(String str) async {
  RegExp alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
  return alphanumericRegex.hasMatch(str);
}
