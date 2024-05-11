import 'dart:async';
import 'package:flutter/foundation.dart';

/// Checks the screen sharing status and performs the necessary actions based on the status.
///
/// The [parameters] parameter is a map that contains the following keys:
/// - 'shared': A boolean value indicating whether the screen is currently being shared.
/// - 'stopShareScreen': A function that stops the screen sharing.
/// - 'requestScreenShare': A function that requests to start screen sharing.
///
/// If the screen is already being shared (shared = true), the [stopShareScreen] function is called with the [parameters].
/// Otherwise, the [requestScreenShare] function is called with the [parameters].
///
/// Throws an error if any error occurs during the process.

typedef StopShareScreenFunction = Future<void> Function(
    {required Map<String, dynamic> parameters});
typedef RequestScreenShareFunction = Future<void> Function(
    {required Map<String, dynamic> parameters});

typedef CheckScreenShareFunction = Future<void> Function(
    {Map<String, dynamic> parameters});

Future<void> checkScreenShare(
    {required Map<String, dynamic> parameters}) async {
  try {
    final bool shared = parameters['shared'];
    final StopShareScreenFunction stopShareScreen =
        parameters['stopShareScreen'];
    final RequestScreenShareFunction requestScreenShare =
        parameters['requestScreenShare'];

    // Stop screen share if already shared or request screen share if not shared
    if (shared) {
      await stopShareScreen(parameters: parameters);
    } else {
      await requestScreenShare(parameters: parameters);
    }
  } catch (error) {
    if (kDebugMode) {
      print('checkScreenShare error $error');
    }
    // throw error;
  }
}
