import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show ShowAlert;

/// Configuration for what each permission level can do.
/// Each capability can be: "allow" | "approval" | "disallow"

class PermissionCapabilities {
  final String useMic; // "allow" | "approval" | "disallow"
  final String useCamera; // "allow" | "approval" | "disallow"
  final String useScreen; // "allow" | "approval" | "disallow"
  final String useChat; // "allow" | "disallow"

  PermissionCapabilities({
    required this.useMic,
    required this.useCamera,
    required this.useScreen,
    required this.useChat,
  });

  Map<String, dynamic> toJson() => {
        'useMic': useMic,
        'useCamera': useCamera,
        'useScreen': useScreen,
        'useChat': useChat,
      };

  factory PermissionCapabilities.fromJson(Map<String, dynamic> json) {
    return PermissionCapabilities(
      useMic: json['useMic'] ?? 'approval',
      useCamera: json['useCamera'] ?? 'approval',
      useScreen: json['useScreen'] ?? 'disallow',
      useChat: json['useChat'] ?? 'allow',
    );
  }

  PermissionCapabilities copyWith({
    String? useMic,
    String? useCamera,
    String? useScreen,
    String? useChat,
  }) {
    return PermissionCapabilities(
      useMic: useMic ?? this.useMic,
      useCamera: useCamera ?? this.useCamera,
      useScreen: useScreen ?? this.useScreen,
      useChat: useChat ?? this.useChat,
    );
  }
}

/// Permission configuration for all levels.
/// Level "2" (host) always has full permissions - not configurable.

class PermissionConfig {
  final PermissionCapabilities level0; // Basic participants
  final PermissionCapabilities level1; // Elevated participants (co-hosts)

  PermissionConfig({
    required this.level0,
    required this.level1,
  });

  Map<String, dynamic> toJson() => {
        'level0': level0.toJson(),
        'level1': level1.toJson(),
      };

  factory PermissionConfig.fromJson(Map<String, dynamic> json) {
    return PermissionConfig(
      level0: PermissionCapabilities.fromJson(json['level0'] ?? {}),
      level1: PermissionCapabilities.fromJson(json['level1'] ?? {}),
    );
  }

  PermissionConfig copyWith({
    PermissionCapabilities? level0,
    PermissionCapabilities? level1,
  }) {
    return PermissionConfig(
      level0: level0 ?? this.level0,
      level1: level1 ?? this.level1,
    );
  }
}

class UpdatePermissionConfigOptions {
  final io.Socket socket;
  final PermissionConfig config;
  final String member;
  final String islevel;
  final String roomName;
  final ShowAlert? showAlert;

  UpdatePermissionConfigOptions({
    required this.socket,
    required this.config,
    required this.member,
    required this.islevel,
    required this.roomName,
    this.showAlert,
  });
}

typedef UpdatePermissionConfigType = Future<void> Function(
    UpdatePermissionConfigOptions options);

/// Returns the default permission configuration.
PermissionConfig getDefaultPermissionConfig() {
  return PermissionConfig(
    level0: PermissionCapabilities(
      useMic: 'approval',
      useCamera: 'approval',
      useScreen: 'disallow',
      useChat: 'allow',
    ),
    level1: PermissionCapabilities(
      useMic: 'allow',
      useCamera: 'allow',
      useScreen: 'approval',
      useChat: 'allow',
    ),
  );
}

/// Creates a PermissionConfig from event settings.
/// This is useful when permissionConfig is not yet set, extracting initial values
/// from the room's event settings. Both level0 and level1 will have the same initial permissions.
///
/// [audioSetting] - 'allow', 'approval', or 'disallow'
/// [videoSetting] - 'allow', 'approval', or 'disallow'
/// [screenshareSetting] - 'allow', 'approval', or 'disallow'
/// [chatSetting] - 'allow' or 'disallow'
PermissionConfig getPermissionConfigFromEventSettings({
  String audioSetting = 'approval',
  String videoSetting = 'approval',
  String screenshareSetting = 'disallow',
  String chatSetting = 'allow',
}) {
  final capabilities = PermissionCapabilities(
    useMic: audioSetting,
    useCamera: videoSetting,
    useScreen: screenshareSetting,
    useChat: chatSetting == 'allow' ? 'allow' : 'disallow',
  );
  return PermissionConfig(
    level0: PermissionCapabilities(
      useMic: capabilities.useMic,
      useCamera: capabilities.useCamera,
      useScreen: capabilities.useScreen,
      useChat: capabilities.useChat,
    ),
    level1: PermissionCapabilities(
      useMic: capabilities.useMic,
      useCamera: capabilities.useCamera,
      useScreen: capabilities.useScreen,
      useChat: capabilities.useChat,
    ),
  );
}

/// Updates the permission configuration for the room.
/// Only hosts (islevel === "2") can update the configuration.
///
/// Example:
/// ```dart
/// await updatePermissionConfig(UpdatePermissionConfigOptions(
///   socket: socket,
///   config: PermissionConfig(
///     level0: PermissionCapabilities(useMic: "disallow", useCamera: "disallow", useScreen: "disallow", useChat: "allow"),
///     level1: PermissionCapabilities(useMic: "allow", useCamera: "allow", useScreen: "allow", useChat: "allow"),
///   ),
///   member: "currentUser",
///   islevel: "2",
///   roomName: "room123",
///   showAlert: (alert) => print(alert.message),
/// ));
/// ```
Future<void> updatePermissionConfig(
    UpdatePermissionConfigOptions options) async {
  // Only hosts can update permission config
  if (options.islevel != "2") {
    options.showAlert?.call(
      message: "Only the host can update permission configuration",
      type: "danger",
      duration: 3000,
    );
    return;
  }

  final completer = Completer<void>();

  options.socket.emitWithAck("updatePermissionConfig", {
    'config': options.config.toJson(),
    'roomName': options.roomName,
  }, ack: (response) {
    if (response == null || response['success'] != true) {
      final reason = response?['reason'] ?? 'Unknown error';
      debugPrint('updatePermissionConfig failed: $reason');
      options.showAlert?.call(
        message: reason,
        type: "danger",
        duration: 3000,
      );
    } else {
      options.showAlert?.call(
        message: "Permission configuration updated",
        type: "success",
        duration: 3000,
      );
    }
    completer.complete();
  });

  return completer.future;
}
