import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show ShowAlert;

class FocusPanelistsOptions {
  final io.Socket socket;
  final String roomName;
  final String member;
  final String islevel;
  final bool focusEnabled;
  final bool muteOthersMic;
  final bool muteOthersCamera;
  final ShowAlert? showAlert;

  FocusPanelistsOptions({
    required this.socket,
    required this.roomName,
    required this.member,
    required this.islevel,
    required this.focusEnabled,
    this.muteOthersMic = false,
    this.muteOthersCamera = false,
    this.showAlert,
  });
}

class UnfocusPanelistsOptions {
  final io.Socket socket;
  final String roomName;
  final String member;
  final String islevel;
  final ShowAlert? showAlert;

  UnfocusPanelistsOptions({
    required this.socket,
    required this.roomName,
    required this.member,
    required this.islevel,
    this.showAlert,
  });
}

typedef FocusPanelistsType = Future<void> Function(
    FocusPanelistsOptions options);
typedef UnfocusPanelistsType = Future<void> Function(
    UnfocusPanelistsOptions options);

/// Focuses the display on panelists only.
/// When enabled, only panelists appear on the grid.
/// Optionally mutes other participants' mic and/or camera.
///
/// Example:
/// ```dart
/// await focusPanelists(FocusPanelistsOptions(
///   socket: socket,
///   roomName: "room123",
///   member: "currentUser",
///   islevel: "2",
///   focusEnabled: true,
///   muteOthersMic: true,
///   muteOthersCamera: false,
///   showAlert: (alert) => print(alert.message),
/// ));
/// ```
Future<void> focusPanelists(FocusPanelistsOptions options) async {
  // Only hosts can focus panelists
  if (options.islevel != "2") {
    options.showAlert?.call(
      message: "Only the host can focus panelists",
      type: "danger",
      duration: 3000,
    );
    return;
  }

  options.socket.emitWithAck("focusPanelists", {
    'roomName': options.roomName,
    'focusEnabled': options.focusEnabled,
    'muteOthersMic': options.muteOthersMic,
    'muteOthersCamera': options.muteOthersCamera,
  }, ack: (response) {
    if (response == null || response['success'] != true) {
      final reason = response?['reason'] ?? 'Unknown error';
      debugPrint('focusPanelists failed: $reason');
      options.showAlert?.call(
        message: reason,
        type: "danger",
        duration: 3000,
      );
    } else if (options.focusEnabled) {
      String message = "Panelist focus enabled";
      if (options.muteOthersMic && options.muteOthersCamera) {
        message += " (others' mic & camera muted)";
      } else if (options.muteOthersMic) {
        message += " (others' mic muted)";
      } else if (options.muteOthersCamera) {
        message += " (others' camera muted)";
      }
      options.showAlert?.call(
        message: message,
        type: "success",
        duration: 3000,
      );
    }
  });
}

/// Disables panelist focus mode.
/// All participants will be shown on the grid again.
///
/// Example:
/// ```dart
/// await unfocusPanelists(UnfocusPanelistsOptions(
///   socket: socket,
///   roomName: "room123",
///   member: "currentUser",
///   islevel: "2",
///   showAlert: (alert) => print(alert.message),
/// ));
/// ```
Future<void> unfocusPanelists(UnfocusPanelistsOptions options) async {
  // Only hosts can unfocus panelists
  if (options.islevel != "2") {
    options.showAlert?.call(
      message: "Only the host can unfocus panelists",
      type: "danger",
      duration: 3000,
    );
    return;
  }

  options.socket.emitWithAck("focusPanelists", {
    'roomName': options.roomName,
    'focusEnabled': false,
    'muteOthersMic': false,
    'muteOthersCamera': false,
  }, ack: (response) {
    if (response == null || response['success'] != true) {
      final reason = response?['reason'] ?? 'Unknown error';
      debugPrint('unfocusPanelists failed: $reason');
      options.showAlert?.call(
        message: reason,
        type: "danger",
        duration: 3000,
      );
    } else {
      options.showAlert?.call(
        message: "Panelist focus disabled",
        type: "info",
        duration: 3000,
      );
    }
  });
}
