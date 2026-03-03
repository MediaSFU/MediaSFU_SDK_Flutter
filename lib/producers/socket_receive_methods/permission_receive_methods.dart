/// Handler for permission-related socket events.
///
/// Listens for:
/// - permissionUpdated: When a user's permission level changes
/// - permissionConfigUpdated: When the room's permission configuration changes
library;

import '../../types/types.dart' show ShowAlert;
import '../../methods/permissions_methods/update_permission_config.dart';

/// Data received when permission is updated.
class PermissionUpdatedData {
  final String newLevel;
  final String? message;

  PermissionUpdatedData({
    required this.newLevel,
    this.message,
  });

  factory PermissionUpdatedData.fromMap(Map<String, dynamic> map) {
    return PermissionUpdatedData(
      newLevel: map['newLevel']?.toString() ?? "0",
      message: map['message']?.toString(),
    );
  }
}

/// Data received when permission config is updated.
class PermissionConfigUpdatedData {
  final PermissionConfig config;

  PermissionConfigUpdatedData({
    required this.config,
  });

  factory PermissionConfigUpdatedData.fromMap(Map<String, dynamic> map) {
    return PermissionConfigUpdatedData(
      config: PermissionConfig.fromJson(map['config'] ?? {}),
    );
  }
}

/// Options for handling permissionUpdated event.
class PermissionUpdatedOptions {
  final PermissionUpdatedData data;
  final ShowAlert? showAlert;
  final void Function(String)? updateIslevel;

  PermissionUpdatedOptions({
    required this.data,
    this.showAlert,
    this.updateIslevel,
  });
}

/// Options for handling permissionConfigUpdated event.
class PermissionConfigUpdatedOptions {
  final PermissionConfigUpdatedData data;
  final void Function(PermissionConfig)? updatePermissionConfig;

  PermissionConfigUpdatedOptions({
    required this.data,
    this.updatePermissionConfig,
  });
}

typedef PermissionUpdatedType = Future<void> Function(
    PermissionUpdatedOptions options);
typedef PermissionConfigUpdatedType = Future<void> Function(
    PermissionConfigUpdatedOptions options);

/// Handles the permissionUpdated socket event.
/// Called when the host changes a participant's permission level.
///
/// Example:
/// ```dart
/// socket.on("permissionUpdated", (data) async {
///   await permissionUpdated(PermissionUpdatedOptions(
///     data: PermissionUpdatedData.fromMap(data),
///     showAlert: showAlert,
///     updateIslevel: (level) => setState(() => islevel = level),
///   ));
/// });
/// ```
Future<void> permissionUpdated(PermissionUpdatedOptions options) async {
  try {
    final data = options.data;

    // Update local permission level
    options.updateIslevel?.call(data.newLevel);

    // Show notification
    if (options.showAlert != null && data.message != null) {
      options.showAlert!(
        message: data.message!,
        type: data.newLevel == "1" ? "success" : "info",
        duration: 3000,
      );
    }
  } catch (e) {
    print('Error handling permissionUpdated: $e');
  }
}

/// Handles the permissionConfigUpdated socket event.
/// Called when the host changes the room's permission configuration.
///
/// Example:
/// ```dart
/// socket.on("permissionConfigUpdated", (data) async {
///   await permissionConfigUpdated(PermissionConfigUpdatedOptions(
///     data: PermissionConfigUpdatedData.fromMap(data),
///     updatePermissionConfig: (config) => setState(() => permissionConfig = config),
///   ));
/// });
/// ```
Future<void> permissionConfigUpdated(
    PermissionConfigUpdatedOptions options) async {
  try {
    final data = options.data;

    // Update local permission config
    options.updatePermissionConfig?.call(data.config);
  } catch (e) {
    print('Error handling permissionConfigUpdated: $e');
  }
}
