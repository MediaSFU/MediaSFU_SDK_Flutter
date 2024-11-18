import 'dart:async';
import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show
        ShowAlert,
        StopShareScreenType,
        RequestScreenShareType,
        StopShareScreenOptions,
        StopShareScreenParameters,
        RequestScreenShareOptions,
        RequestScreenShareParameters;

/// Parameters for checking screen sharing status and managing screen share actions.
///
/// Contains properties to track the screen share state, alert functions, whiteboard and breakout room status,
/// and functions to start or stop screen sharing.
abstract class CheckScreenShareParameters
    implements StopShareScreenParameters, RequestScreenShareParameters {
  bool get shared;
  bool get whiteboardStarted;
  bool get whiteboardEnded;
  bool get breakOutRoomStarted;
  bool get breakOutRoomEnded;
  ShowAlert? get showAlert;

  // Mediasfu functions as getters
  StopShareScreenType get stopShareScreen;
  RequestScreenShareType get requestScreenShare;
}

/// Options for the [checkScreenShare] function.
///
/// Holds the parameters needed for checking and managing screen sharing.
class CheckScreenShareOptions {
  final CheckScreenShareParameters parameters;

  CheckScreenShareOptions({required this.parameters});
}

/// Type definition for the `checkScreenShare` function.
///
/// Represents a function that takes in [CheckScreenShareOptions] and returns a `Future<void>`.
typedef CheckScreenShareType = Future<void> Function(
    CheckScreenShareOptions options);

/// Checks and manages screen sharing status, initiating or stopping screen share actions based on conditions.
///
/// This function verifies whether screen sharing is currently active. If sharing is active, it attempts to stop
/// the screen share unless the whiteboard is active, in which case an alert is shown. If not sharing, it initiates
/// screen share unless a breakout room or whiteboard is active, with alerts as needed.
///
/// Parameters:
/// - [options] (`CheckScreenShareOptions`): Holds the parameters needed to manage screen sharing actions:
///   - [parameters] (`CheckScreenShareParameters`): Defines properties to check screen sharing state and
///     methods for starting/stopping screen share.
///
/// Example:
/// ```dart
/// final parameters = CheckScreenShareParameters(
///   shared: true,
///   whiteboardStarted: false,
///   whiteboardEnded: true,
///   breakOutRoomStarted: false,
///   breakOutRoomEnded: true,
///   showAlert: (alert) => print('Alert: ${alert.message}'),
///   stopShareScreen: (StopShareScreenOptions options) async {
///     print('Stopping screen share...');
///   },
///   requestScreenShare: (RequestScreenShareOptions options) async {
///     print('Requesting screen share...');
///   },
/// );
///
/// final options = CheckScreenShareOptions(parameters: parameters);
///
/// await checkScreenShare(options);
/// ```

Future<void> checkScreenShare(CheckScreenShareOptions options) async {
  final parameters = options.parameters;
  try {
    final shared = parameters.shared;
    final whiteboardStarted = parameters.whiteboardStarted;
    final whiteboardEnded = parameters.whiteboardEnded;
    final breakOutRoomStarted = parameters.breakOutRoomStarted;
    final breakOutRoomEnded = parameters.breakOutRoomEnded;
    final showAlert = parameters.showAlert;
    final stopShareScreen = parameters.stopShareScreen;
    final requestScreenShare = parameters.requestScreenShare;

    // Stop screen share if already shared or request screen share if not shared
    if (shared) {
      if (whiteboardStarted && !whiteboardEnded) {
        showAlert?.call(
          message: 'Screen share is not allowed when whiteboard is active',
          type: 'danger',
          duration: 3000,
        );
        return;
      }
      final optionsStop = StopShareScreenOptions(parameters: parameters);
      await stopShareScreen(optionsStop);
    } else {
      // Can't share if breakout room is active
      if (breakOutRoomStarted && !breakOutRoomEnded) {
        showAlert?.call(
          message: 'Screen share is not allowed when breakout room is active',
          type: 'danger',
          duration: 3000,
        );
        return;
      }

      if (whiteboardStarted && !whiteboardEnded) {
        showAlert?.call(
          message: 'Screen share is not allowed when whiteboard is active',
          type: 'danger',
          duration: 3000,
        );
        return;
      }
      final optionsRequest = RequestScreenShareOptions(parameters: parameters);
      await requestScreenShare(optionsRequest);
    }
  } catch (error) {
    if (kDebugMode) {
      print('checkScreenShare error: $error');
    }
  }
}
