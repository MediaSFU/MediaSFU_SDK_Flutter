import 'dart:async';

import 'package:flutter/foundation.dart';

/// Options for checking permission based on specific settings.
///
/// Contains settings for audio, video, screenshare, and chat, as well as the type of permission to check.
class CheckPermissionOptions {
  final String audioSetting;
  final String videoSetting;
  final String screenshareSetting;
  final String chatSetting;
  final String permissionType;

  CheckPermissionOptions({
    required this.audioSetting,
    required this.videoSetting,
    required this.screenshareSetting,
    required this.chatSetting,
    required this.permissionType,
  });
}

/// Type definition for the `checkPermission` function.
///
/// Represents a function that takes in [CheckPermissionOptions] and returns a `Future<int>`.
typedef CheckPermissionType = Future<int> Function(
    CheckPermissionOptions options);

/// Checks the permission based on the provided settings.
///
/// ### Parameters:
/// - `options` (CheckPermissionOptions): The options containing permission settings.
///
/// ### Returns:
/// - A `Future<int>` representing the permission status:
///   - `0`: Permission is allowed.
///   - `1`: Permission requires approval.
///   - `2`: Permission is disallowed or the `permissionType` is invalid.
///
/// ### Example:
/// ```dart
/// final options = CheckPermissionOptions(
///   permissionType: 'audioSetting',
///   audioSetting: 'allow',
///   videoSetting: 'approval',
///   screenshareSetting: 'approval',
///   chatSetting: 'allow',
/// );
///
/// checkPermission(options).then((result) {
///   print('Permission result: $result');
/// }).catchError((error) {
///   print('Error checking permission: $error');
/// });
/// ```
Future<int> checkPermission(CheckPermissionOptions options) async {
  try {
    // Determine the permission type and corresponding setting
    switch (options.permissionType) {
      case 'audioSetting':
        if (options.audioSetting == 'allow') return 0;
        if (options.audioSetting == 'approval') return 1;
        return 2;

      case 'videoSetting':
        if (options.videoSetting == 'allow') return 0;
        if (options.videoSetting == 'approval') return 1;
        return 2;

      case 'screenshareSetting':
        if (options.screenshareSetting == 'allow') return 0;
        if (options.screenshareSetting == 'approval') return 1;
        return 2;

      case 'chatSetting':
        if (options.chatSetting == 'allow') return 0;
        if (options.chatSetting == 'approval') return 1;
        return 2;

      default:
        // Return 2 for invalid permission type
        return 2;
    }
  } catch (error) {
    if (kDebugMode) {
      print('checkPermission error: $error');
    }
    return 2;
  }
}
