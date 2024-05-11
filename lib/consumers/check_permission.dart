import 'dart:async';

/// A function that checks the permission for a given permission type and parameters.
///
/// The [CheckPermission] typedef represents a function that returns a [Future] of an [int].
/// It takes in a [permissionType] of type [String] and [parameters] of type [Map<String, dynamic>].
///
/// The [checkPermission] function is an implementation of the [CheckPermission] typedef.
/// It performs a switch case to check for the [permissionType] and returns the corresponding response.
/// The [parameters] map is used to retrieve the settings for audio, video, screenshare, and chat.
/// If the settings are not provided, the default value is 'disallow'.
///
/// The function returns a [Future] of an [int] representing the permission status:
/// - 0: Permission is allowed.
/// - 1: Permission requires approval.
/// - 2: Permission is disallowed or invalid permissionType.
///
/// If an error occurs during the permission check, the function returns 2.

typedef CheckPermission = Future<int> Function(
    {String permissionType, Map<String, dynamic> parameters});

Future<int> checkPermission(
    {required String permissionType,
    required Map<String, dynamic> parameters}) async {
  try {
    String audioSetting = parameters['audioSetting'] ?? 'disallow';
    String videoSetting = parameters['videoSetting'] ?? 'disallow';
    String screenshareSetting = parameters['screenshareSetting'] ?? 'disallow';
    String chatSetting = parameters['chatSetting'] ?? 'disallow';

    // Perform a switch case to check for the permissionType and return the response
    switch (permissionType) {
      case 'audioSetting':
        if (audioSetting == 'allow') {
          return 0;
        } else if (audioSetting == 'approval') {
          return 1;
        } else {
          return 2;
        }
      case 'videoSetting':
        if (videoSetting == 'allow') {
          return 0;
        } else if (videoSetting == 'approval') {
          return 1;
        } else {
          return 2;
        }
      case 'screenshareSetting':
        if (screenshareSetting == 'allow') {
          return 0;
        } else if (screenshareSetting == 'approval') {
          return 1;
        } else {
          return 2;
        }
      case 'chatSetting':
        if (chatSetting == 'allow') {
          return 0;
        } else if (chatSetting == 'approval') {
          return 1;
        } else {
          return 2;
        }
      default:
        // throw Exception('Invalid permissionType: $permissionType');
        return 2;
    }
  } catch (error) {
    return 2;
  }
}
