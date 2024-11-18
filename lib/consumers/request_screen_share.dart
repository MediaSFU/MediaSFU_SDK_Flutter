import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../types/types.dart'
    show
        ShowAlert,
        StartShareScreenType,
        StartShareScreenParameters,
        StartShareScreenOptions;

// Define RequestScreenShareParameters class
abstract class RequestScreenShareParameters
    implements StartShareScreenParameters {
  // Properties as abstract getters
  io.Socket? get socket;
  ShowAlert? get showAlert;
  bool get localUIMode;
  String get targetResolution;
  String get targetResolutionHost;
  StartShareScreenType get startShareScreen;

  // Method to retrieve updated parameters
  RequestScreenShareParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

// Define RequestScreenShareOptions class
class RequestScreenShareOptions {
  final RequestScreenShareParameters parameters;

  RequestScreenShareOptions({
    required this.parameters,
  });
}

typedef RequestScreenShareType = Future<void> Function(
    RequestScreenShareOptions options);

/// Requests permission to start screen sharing or initiates screen sharing if in local UI mode.
///
/// This function configures screen resolution settings, checks if screen sharing is allowed
/// via a socket event, and initiates screen sharing based on the response.
///
/// Parameters:
/// - [options] (`RequestScreenShareOptions`): Contains parameters for requesting and starting screen sharing,
///   including the socket connection, alert function, and resolution settings.
///
/// The function supports two modes:
/// 1. **Local UI Mode**: Directly starts screen sharing without permission checks.
/// 2. **Network Mode**: Emits a socket event to check if screen sharing is allowed before starting.
///
/// Example:
/// ```dart
/// final options = RequestScreenShareOptions(
///   parameters: RequestScreenShareParameters(
///     socket: socketInstance,
///     showAlert: (String message, String type, int duration) => print(message),
///     localUIMode: false,
///     targetResolution: 'fhd',
///     startShareScreen: startShareScreenFunction,
///     getUpdatedAllParams: () => this, // Replace with actual updated params implementation
///   ),
/// );
///
/// await requestScreenShare(options);
/// ```

Future<void> requestScreenShare(
  RequestScreenShareOptions options,
) async {
  // Retrieve and update parameters
  var parameters = options.parameters.getUpdatedAllParams();

  final socket = parameters.socket;
  final ShowAlert? showAlert = parameters.showAlert;
  final bool localUIMode = parameters.localUIMode;
  final StartShareScreenType startShareScreen = parameters.startShareScreen;

  // Default to 'hd' resolution
  var targetWidth = 1280;
  var targetHeight = 720;
  final targetResolution = parameters.targetResolution;
  final targetResolutionHost = parameters.targetResolutionHost;

  // Set resolution based on target
  if (targetResolution == 'qhd' || targetResolutionHost == 'qhd') {
    targetWidth = 2560;
    targetHeight = 1440;
  } else if (targetResolution == 'fhd' || targetResolutionHost == 'fhd') {
    targetWidth = 1920;
    targetHeight = 1080;
  }

  try {
    // Directly start screen sharing if in local UI mode
    if (localUIMode == true) {
      final optionsStartShareScreen = StartShareScreenOptions(
        parameters: parameters,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
      await startShareScreen(optionsStartShareScreen);
      return;
    }

    // Otherwise, emit a socket event to request screen sharing permission
    socket!.emitWithAck('requestScreenShare', [], ack: (responseData) async {
      final bool allowScreenShare = responseData['allowScreenShare'] ?? false;

      if (!allowScreenShare) {
        // Show alert if sharing is not allowed
        showAlert?.call(
          message: 'You are not allowed to share screen',
          type: 'danger',
          duration: 3000,
        );
      } else {
        // Start sharing if allowed
        var updatedParams = parameters;
        final optionsStartShareScreen = StartShareScreenOptions(
          parameters: updatedParams,
          targetWidth: targetWidth,
          targetHeight: targetHeight,
        );
        await startShareScreen(optionsStartShareScreen);
      }
    });
  } catch (error) {
    // Log any errors encountered
    if (kDebugMode) {
      print("Error during requesting screen share: $error");
    }
  }
}
