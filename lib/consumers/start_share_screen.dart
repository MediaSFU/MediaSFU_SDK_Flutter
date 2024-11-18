import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../types/types.dart'
    show
        ShowAlert,
        StreamSuccessScreenType,
        StreamSuccessScreenParameters,
        StreamSuccessScreenOptions;

/// Parameters for starting screen sharing.
abstract class StartShareScreenParameters
    implements StreamSuccessScreenParameters {
  // Properties as abstract getters
  bool get shared;
  ShowAlert? get showAlert;
  bool get onWeb;

  // Update function as an abstract getter
  Function(bool) get updateShared;

  // Mediasfu function as an abstract getter
  StreamSuccessScreenType get streamSuccessScreen;

  // Dynamic access operator for additional properties
  // dynamic operator [](String key);
}

/// Options for starting screen sharing.
class StartShareScreenOptions {
  StartShareScreenParameters parameters;
  int? targetWidth;
  int? targetHeight;

  StartShareScreenOptions(
      {required this.parameters, this.targetWidth, this.targetHeight});
}

/// Function type for starting screen sharing.
typedef StartShareScreenType = Future<void> Function(
    StartShareScreenOptions options);

/// Starts the screen sharing process.
///
/// @param [StartShareScreenOptions] options - The options for starting screen sharing.
/// @param [StartShareScreenParameters] options.parameters - The parameters for screen sharing.
///
/// This function displays an alert if screen sharing fails or if an attempt is made to share screen on mobile.
/// It also calls the `streamSuccessScreen` function when sharing is successful.
///
/// Example:
/// ```dart
/// final options = StartShareScreenOptions(
///   parameters: StartShareScreenParameters(
///     shared: false,
///     showAlert: (msg, type, duration) => print(msg),
///     updateShared: (isShared) => print("Shared: $isShared"),
///     onWeb: true,
///     streamSuccessScreen: (stream, parameters) async => print("Success"),
///   ),
///  targetWidth: 1920,
///  targetHeight: 1080,
/// );
/// await startShareScreen(options);
/// ```

Future<void> startShareScreen(StartShareScreenOptions options) async {
  final targetWidth = options.targetWidth ?? 1280;
  final targetHeight = options.targetHeight ?? 720;
  final parameters = options.parameters;
  bool shared = parameters.shared;
  final showAlert = parameters.showAlert;
  final updateShared = parameters.updateShared;
  final onWeb = parameters.onWeb;
  final streamSuccessScreen = parameters.streamSuccessScreen;

  try {
    if (!onWeb) {
      if (showAlert != null) {
        showAlert(
          message: 'You cannot share screen while on mobile',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    // Check if navigator.mediaDevices.getDisplayMedia is supported; defer for later for flutter
    try {
      MediaStream stream = await navigator.mediaDevices.getDisplayMedia({
        'video': {
          'cursor': 'always',
          'width': targetWidth,
          'height': targetHeight,
          'frameRate': 30
        },
        'audio': false
      });

      try {
        final optionsStream = StreamSuccessScreenOptions(
          stream: stream,
          parameters: parameters,
        );
        await streamSuccessScreen(optionsStream);
      } catch (_) {}
      shared = true;
    } catch (error) {
      shared = false;

      showAlert?.call(
        message: 'Could not share screen, check and retry',
        type: 'danger',
        duration: 3000,
      );
    }

    // Update the shared variable
    updateShared(shared);
  } catch (error) {
    if (kDebugMode) {
      print('Error starting screen share: $error');
    }
    rethrow;
  }
}
