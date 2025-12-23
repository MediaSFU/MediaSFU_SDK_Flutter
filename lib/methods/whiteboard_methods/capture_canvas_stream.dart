import 'package:flutter/foundation.dart';
import '../../types/types.dart'
    show
        CaptureCanvasStreamOptions,
        CaptureCanvasStreamParameters,
        CaptureCanvasStreamType,
        DisconnectSendTransportScreenOptions,
        DisconnectSendTransportScreenParameters,
        MediaStream;

// Conditional import for web canvas capture
import 'canvas_capture_stub.dart'
    if (dart.library.js_interop) 'canvas_capture_web.dart'
    show ScreenAnnotationCapture, isWebCanvasCaptureSupported;

// Re-export for external access
export 'canvas_capture_stub.dart'
    if (dart.library.js_interop) 'canvas_capture_web.dart'
    show ScreenAnnotationCapture, isWebCanvasCaptureSupported;

/// Global instance of ScreenAnnotationCapture for managing annotation capture.
/// This is used to maintain state across start/stop calls.
ScreenAnnotationCapture? _annotationCapture;

/// Captures the canvas stream and handles the transport connection for whiteboard streaming.
///
/// This function manages the lifecycle of canvas stream capture for whiteboard recording:
/// - When [start] is `true`: Attempts to capture the canvas stream and connect the transport
/// - When [start] is `false`: Stops the canvas stream tracks and disconnects the transport
///
/// **Platform Support:**
/// - **Web**: Uses HTML Canvas's `captureStream()` API via JavaScript interop
/// - **Mobile/Desktop**: Not natively supported; uses server-side recording
///
/// For web platforms, this function can capture the screenboard/whiteboard annotations
/// and stream them via WebRTC to other participants.
///
/// @param [CaptureCanvasStreamOptions] options - The options for capturing the canvas stream.
/// @param [CaptureCanvasStreamParameters] options.parameters - The parameters required for capturing and managing the canvas stream.
/// @param [bool] options.start - Flag indicating whether to start (true) or stop (false) the canvas stream. Defaults to true.
///
/// @returns [Future<void>] A promise that resolves when the operation is complete.
///
/// Example:
/// ```dart
/// final options = CaptureCanvasStreamOptions(
///   parameters: myParameters,
///   start: true,
/// );
/// await captureCanvasStream(options);
/// ```
///
/// To stop the canvas stream:
/// ```dart
/// final options = CaptureCanvasStreamOptions(
///   parameters: myParameters,
///   start: false,
/// );
/// await captureCanvasStream(options);
/// ```
Future<void> captureCanvasStream(CaptureCanvasStreamOptions options) async {
  try {
    final CaptureCanvasStreamParameters parameters = options.parameters;
    final bool start = options.start;

    // Get the latest parameters
    CaptureCanvasStreamParameters params = parameters.getUpdatedAllParams();

    MediaStream? canvasStream = params.canvasStream;
    final updateCanvasStream = params.updateCanvasStream;
    final disconnectSendTransportScreen = params.disconnectSendTransportScreen;

    if (start && canvasStream == null) {
      // Check if we're on web and canvas capture is supported
      if (kIsWeb && isWebCanvasCaptureSupported()) {
        if (kDebugMode) {
          print(
              'captureCanvasStream: Web platform detected, canvas capture is available');
          print(
              'captureCanvasStream: To capture screenboard annotations, use startScreenboardCapture()');
        }
        // Note: Actual capture is initiated from the screenboard component
        // which has access to the RepaintBoundary key for canvas rendering.
        // This function prepares the infrastructure; the screenboard will
        // call startScreenboardCapture() when annotation mode is enabled.
      } else {
        // Non-web platforms or unsupported browsers
        if (kDebugMode) {
          print(
              'captureCanvasStream: Canvas stream capture is not natively supported on this platform. '
              'Whiteboard data is synced to server for recording.');
        }
      }
    } else if (!start && canvasStream != null) {
      // Stop the canvas stream
      try {
        // Stop all tracks in the canvas stream
        for (final track in canvasStream.getTracks()) {
          await track.stop();
        }
      } catch (e) {
        if (kDebugMode) {
          print('captureCanvasStream: Error stopping canvas stream tracks: $e');
        }
      }

      // Clean up annotation capture if active
      if (_annotationCapture != null) {
        _annotationCapture!.dispose();
        _annotationCapture = null;
      }

      // Clear the canvas stream reference
      canvasStream = null;
      updateCanvasStream(null);

      // Disconnect the send transport for screen
      try {
        await Function.apply(disconnectSendTransportScreen, [
          DisconnectSendTransportScreenOptions(
            parameters: params as DisconnectSendTransportScreenParameters,
          )
        ]);
      } catch (e) {
        if (kDebugMode) {
          print('captureCanvasStream: Error disconnecting transport: $e');
        }
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('captureCanvasStream: Error - $error');
    }
  }
}

/// Type definition for the captureCanvasStream function.
/// This is exported for type safety when passing the function as a parameter.
const CaptureCanvasStreamType captureCanvasStreamFunction = captureCanvasStream;
