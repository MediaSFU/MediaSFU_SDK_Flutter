import 'dart:async';

import '../methods/permissions_methods/update_permission_config.dart';

/// Options for checking permission based on specific settings.
///
/// Contains settings for audio, video, screenshare, and chat, as well as the type of permission to check.
/// Optionally supports per-level permission configuration via [permissionConfig] and [participantLevel].
class CheckPermissionOptions {
  final String audioSetting;
  final String videoSetting;
  final String screenshareSetting;
  final String chatSetting;
  final String permissionType;
  // Optional: per-level permission configuration
  final PermissionConfig? permissionConfig;
  final String? participantLevel; // "0", "1", or "2"

  CheckPermissionOptions({
    required this.audioSetting,
    required this.videoSetting,
    required this.screenshareSetting,
    required this.chatSetting,
    required this.permissionType,
    this.permissionConfig,
    this.participantLevel,
  });
}

/// Type definition for the `checkPermission` function.
///
/// Represents a function that takes in [CheckPermissionOptions] and returns a `Future<int>`.
typedef CheckPermissionType = Future<int> Function(
    CheckPermissionOptions options);

/// Checks the permission based on the provided settings.
///
/// If [permissionConfig] and [participantLevel] are provided, uses the per-level
/// configuration to determine permissions. Otherwise falls back to room-wide
/// eventSettings (audioSetting, videoSetting, etc.).
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
///   // Optional: per-level config override
///   permissionConfig: PermissionConfig(...),
///   participantLevel: "0",
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
    // Map permission types to permissionConfig capability names
    const permissionTypeToCapability = {
      'audioSetting': 'useMic',
      'videoSetting': 'useCamera',
      'screenshareSetting': 'useScreen',
      'chatSetting': 'useChat',
    };

    // If permissionConfig is provided and participant has a valid level (not host)
    if (options.permissionConfig != null &&
        options.participantLevel != null &&
        options.participantLevel != '2') {
      final levelConfig = options.participantLevel == '0'
          ? options.permissionConfig!.level0
          : options.permissionConfig!.level1;

      final capability = permissionTypeToCapability[options.permissionType];
      if (capability != null) {
        String? configValue;
        switch (capability) {
          case 'useMic':
            configValue = levelConfig.useMic;
            break;
          case 'useCamera':
            configValue = levelConfig.useCamera;
            break;
          case 'useScreen':
            configValue = levelConfig.useScreen;
            break;
          case 'useChat':
            configValue = levelConfig.useChat;
            break;
        }

        if (configValue != null) {
          return configValue == 'allow'
              ? 0
              : (configValue == 'approval' ? 1 : 2);
        }
      }
    }

    // Fallback to room-wide eventSettings
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
  } catch (_) {
    return 2;
  }
}
