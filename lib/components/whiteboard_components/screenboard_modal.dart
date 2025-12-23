import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show MediaStream, Producer;
import '../../types/types.dart'
    show
        SleepType,
        CreateSendTransportType,
        DisconnectSendTransportScreenType,
        DisconnectSendTransportScreenOptions,
        DisconnectSendTransportScreenParameters,
        ConnectSendTransportScreenType,
        ConnectSendTransportScreenOptions,
        ConnectSendTransportScreenParameters,
        StopShareScreenType,
        PrepopulateUserMediaType,
        PrepopulateUserMediaOptions,
        PrepopulateUserMediaParameters;
import '../../methods/whiteboard_methods/capture_canvas_stream.dart'
    show ScreenAnnotationCapture, isWebCanvasCaptureSupported;
import '../../methods/utils/sleep.dart' show SleepOptions;
import '../../methods/utils/platform_feature_support.dart'
    show PlatformFeatureSupport;

/// Parameters for the ScreenboardModal widget.
///
/// Contains all state and callbacks needed for screen annotation functionality.
/// Matches React's ScreenboardModalParameters interface.
abstract class ScreenboardModalParameters
    implements
        ConnectSendTransportScreenParameters,
        DisconnectSendTransportScreenParameters {
  MediaStream? get localStreamScreen;
  bool get shared;
  String get hostLabel;
  bool get annotateScreenStream;
  MediaStream? get processedScreenStream;
  dynamic get mainScreenCanvas;
  dynamic get canvasScreenboard;
  bool get transportCreated;
  Producer? get screenProducer;

  void Function(MediaStream?) get updateLocalStreamScreen;
  void Function(MediaStream?) get updateProcessedScreenStream;
  void Function(dynamic) get updateMainScreenCanvas;
  void Function(dynamic) get updateCanvasScreenboard;

  // Mediasfu functions
  SleepType get sleep;
  CreateSendTransportType get createSendTransport;
  DisconnectSendTransportScreenType get disconnectSendTransportScreen;
  ConnectSendTransportScreenType get connectSendTransportScreen;
  StopShareScreenType get stopShareScreen;
  PrepopulateUserMediaType get prepopulateUserMedia;

  ScreenboardModalParameters Function() get getUpdatedAllParams;
}

/// Options for configuring the ScreenboardModal.
class ScreenboardModalOptions {
  /// Parameters containing state and callbacks.
  final ScreenboardModalParameters parameters;

  /// Whether the modal is visible.
  final bool isVisible;

  /// Callback when the modal is closed.
  final VoidCallback onClose;

  /// Position of the modal on screen.
  final String position;

  /// Background color of the modal.
  final Color backgroundColor;

  ScreenboardModalOptions({
    required this.parameters,
    required this.isVisible,
    required this.onClose,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFF83C0E9),
  });
}

/// Type definition for ScreenboardModal widget builder.
typedef ScreenboardModalType = Widget Function({
  required ScreenboardModalOptions options,
});

/// ScreenboardModal - A modal component for managing screen annotation overlays.
///
/// This component replicates React's ScreenboardModal approach:
/// - On web: Combines screen video + annotation canvas into a single MediaStream
/// - Uses HTML video/canvas elements for capture (web only)
/// - Sends the combined stream via WebRTC to broadcast annotations
///
/// **Key Features:**
/// - **Annotation Broadcasting (Web)**: Combines screen share with annotations
/// - **Stream Management**: Handles local screen stream and processed stream
/// - **Canvas Integration**: Manages canvas for annotation rendering
/// - **Transport Lifecycle**: Creates, connects, and disconnects WebRTC transport
/// - **Modal Controls**: Close button with automatic cleanup
///
/// Example:
/// ```dart
/// ScreenboardModal(
///   options: ScreenboardModalOptions(
///     parameters: screenboardParameters,
///     isVisible: true,
///     onClose: () => setState(() => isModalVisible = false),
///   ),
/// )
/// ```
class ScreenboardModal extends StatefulWidget {
  final ScreenboardModalOptions options;

  const ScreenboardModal({super.key, required this.options});

  @override
  State<ScreenboardModal> createState() => _ScreenboardModalState();
}

class _ScreenboardModalState extends State<ScreenboardModal> {
  bool _isProcessing = false;

  /// Web-only: Screen annotation capture instance
  /// Replicates React's mainScreenCanvas + screenVideo + drawCombined() approach
  ScreenAnnotationCapture? _annotationCapture;

  /// Whether annotation capture is active
  bool _isAnnotationActive = false;

  /// Original screen stream saved before annotation (for restoration)
  /// Replicates React's clonedStreamScreen.current
  MediaStream? _originalStreamScreen;

  ScreenboardModalParameters get _params => widget.options.parameters;

  @override
  void initState() {
    super.initState();
    if (widget.options.isVisible) {
      _showModal();
    }
  }

  @override
  void didUpdateWidget(ScreenboardModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.isVisible != oldWidget.options.isVisible) {
      if (widget.options.isVisible) {
        _showModal();
      } else {
        _hideModal();
      }
    }
  }

  /// Shows the modal and starts annotation capture (web only).
  ///
  /// Replicates React's `showModal()` and `annotatationPreview()` functions:
  /// 1. Clone the screen share track
  /// 2. Create video + canvas elements for combining
  /// 3. Start capture with 30fps interval for drawCombined()
  /// 4. Send combined stream via WebRTC
  Future<void> _showModal() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final params = _params.getUpdatedAllParams();
      final annotate = params.annotateScreenStream;
      final shared = params.shared;
      final localStreamScreen = params.localStreamScreen;

      if (annotate && shared && localStreamScreen != null) {
        // Check if web annotation capture is supported
        if (kIsWeb && isWebCanvasCaptureSupported()) {
          await _startAnnotationCapture(params, localStreamScreen);
        } else {
          // Non-web: annotations are local-only
          if (kDebugMode) {
            print(
                'ScreenboardModal: Annotation broadcasting not supported on this platform');
            print('ScreenboardModal: Annotations will only be visible locally');
          }
        }

        await params.prepopulateUserMedia(PrepopulateUserMediaOptions(
          name: params.hostLabel,
          parameters: params as PrepopulateUserMediaParameters,
        ));
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('ScreenboardModal: Error showing modal: $e');
        print(stack);
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// Start annotation capture and switch to combined stream.
  ///
  /// Replicates React's `annotatationPreview()` function exactly:
  /// ```javascript
  /// clonedStreamScreen.current = new MediaStream([originalTrack.clone()]);
  /// screenVideo!.srcObject = annotateVideo;
  /// processedScreenStream = await captureStream();
  /// await connectSendTransportScreen({ stream: processedScreenStream!, parameters });
  /// ```
  Future<void> _startAnnotationCapture(
    ScreenboardModalParameters params,
    MediaStream localStreamScreen,
  ) async {
    try {
      if (kDebugMode) {
        print('ScreenboardModal: Starting annotation capture (React-style)');
      }

      // Clone the original stream for later restoration (React: clonedStreamScreen)
      // This ensures we have a backup of the original stream that won't be affected
      // when we replace localStreamScreen with processedStream
      _originalStreamScreen = await localStreamScreen.clone();
      if (kDebugMode) {
        print('ScreenboardModal: Cloned original stream for restoration');
        print(
            'ScreenboardModal: Original stream has ${_originalStreamScreen?.getVideoTracks().length} video tracks');
      }

      // Create the annotation capture instance
      _annotationCapture = ScreenAnnotationCapture();

      // Initialize with the screen stream (creates video + canvas elements)
      final annotationCanvas =
          await _annotationCapture!.initialize(localStreamScreen);

      if (annotationCanvas == null) {
        if (kDebugMode) {
          print('ScreenboardModal: Failed to initialize annotation capture');
        }
        return;
      }

      // Store the ScreenAnnotationCapture instance for Screenboard to use.
      // Screenboard will call redrawShapes() on this to update the HTML canvas.
      params.updateCanvasScreenboard(_annotationCapture);

      // Start capturing the combined stream
      final processedStream =
          await _annotationCapture!.startCapture(frameRate: 30);

      if (processedStream == null) {
        if (kDebugMode) {
          print('ScreenboardModal: Failed to start capture');
        }
        return;
      }

      _isAnnotationActive = true;

      // Update the processed stream state
      params.updateProcessedScreenStream(processedStream);

      // IMPORTANT: Update localStreamScreen to use the processedStream
      // This ensures FlexibleVideo displays the combined video+annotations locally
      // React does this by updating localStreamScreen with cloned tracks
      params.updateLocalStreamScreen(processedStream);

      if (kDebugMode) {
        print('ScreenboardModal: Annotation capture started');
        print(
            'ScreenboardModal: processedStream has ${processedStream.getVideoTracks().length} video tracks');
        print(
            'ScreenboardModal: Updated localStreamScreen to show combined stream locally');
      }

      // Disconnect the current screen transport and reconnect with the combined stream
      // This matches React's flow:
      // await disconnectSendTransportScreen({ parameters });
      // await connectSendTransportScreen({ stream: processedScreenStream!, parameters });

      try {
        // Disconnect existing screen transport
        await params.disconnectSendTransportScreen(
          DisconnectSendTransportScreenOptions(
            parameters: params as DisconnectSendTransportScreenParameters,
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          print('ScreenboardModal: Error disconnecting screen transport: $e');
        }
      }

      // Small delay before reconnecting (matches React's sleep)
      await params.sleep(SleepOptions(ms: 500));

      try {
        // Connect with the new combined stream
        await params.connectSendTransportScreen(
          ConnectSendTransportScreenOptions(
            stream: processedStream,
            parameters: params as ConnectSendTransportScreenParameters,
          ),
        );

        if (kDebugMode) {
          print(
              'ScreenboardModal: Reconnected with combined annotation stream');
        }
      } catch (e) {
        if (kDebugMode) {
          print('ScreenboardModal: Error connecting screen transport: $e');
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('ScreenboardModal: Error starting annotation capture: $e');
        print(stack);
      }
    }
  }

  /// Hides the modal and stops annotation capture.
  ///
  /// Replicates React's `hideModal()` and `stopAnnotation()` functions.
  /// IMPORTANT: Only stops annotation if annotateScreenStream is false!
  /// The modal can close (visibility=false) while capture continues.
  Future<void> _hideModal() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final params = _params.getUpdatedAllParams();
      final annotate = params.annotateScreenStream;
      final shared = params.shared;

      if (kDebugMode) {
        print(
            'ScreenboardModal: _hideModal called, annotate=$annotate, shared=$shared');
      }

      // React: if (!annotate) { ... } - only stop if annotation is disabled
      if (!annotate) {
        if (kDebugMode) {
          print(
              'ScreenboardModal: annotate=false, stopping annotation capture');
        }
        // Stop annotation capture
        await _stopAnnotation(params);

        if (shared) {
          // Reconnect with original screen stream
          await _reconnectOriginalStream(params);
        } else {
          await _stopAllTracks(params);
        }
      } else {
        if (kDebugMode) {
          print(
              'ScreenboardModal: annotate=true, keeping capture running (modal just hiding)');
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('ScreenboardModal: Error hiding modal: $e');
        print(stack);
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// Stop annotation capture and clean up resources.
  Future<void> _stopAnnotation(ScreenboardModalParameters params) async {
    if (_annotationCapture != null) {
      _annotationCapture!.stopCapture();
      _annotationCapture!.dispose();
      _annotationCapture = null;
    }

    _isAnnotationActive = false;

    // Clear processed stream
    if (params.processedScreenStream != null) {
      params.updateProcessedScreenStream(null);
    }

    // Clear canvas references
    params.updateCanvasScreenboard(null);

    if (kDebugMode) {
      print('ScreenboardModal: Annotation capture stopped');
    }
  }

  /// Reconnect with the original screen stream (without annotations).
  Future<void> _reconnectOriginalStream(
      ScreenboardModalParameters params) async {
    // Use the saved original stream, not the current localStreamScreen
    // (which was replaced with processedStream)
    final originalStream = _originalStreamScreen;

    if (originalStream == null) {
      if (kDebugMode) {
        print(
            'ScreenboardModal: No original screen stream saved for restoration');
      }
      return;
    }

    final videoTracks = originalStream.getVideoTracks();
    if (kDebugMode) {
      print('ScreenboardModal: Restoring original screen stream');
      print(
          'ScreenboardModal: Original stream has ${videoTracks.length} video tracks');
      if (videoTracks.isNotEmpty) {
        final track = videoTracks.first;
        print(
            'ScreenboardModal: Track enabled: ${track.enabled}, readyState: ${track.kind}');
      }
    }

    // First, restore localStreamScreen to the original
    params.updateLocalStreamScreen(originalStream);

    try {
      // Disconnect the combined stream transport
      await params.disconnectSendTransportScreen(
        DisconnectSendTransportScreenOptions(
          parameters: params as DisconnectSendTransportScreenParameters,
        ),
      );
      if (kDebugMode) {
        print('ScreenboardModal: Disconnected transport successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ScreenboardModal: Error disconnecting transport: $e');
      }
    }

    await params.sleep(SleepOptions(ms: 500));

    try {
      // Reconnect with original stream
      await params.connectSendTransportScreen(
        ConnectSendTransportScreenOptions(
          stream: originalStream,
          parameters: params as ConnectSendTransportScreenParameters,
        ),
      );

      if (kDebugMode) {
        print('ScreenboardModal: Reconnected with original screen stream');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ScreenboardModal: Error reconnecting transport: $e');
      }
    }

    // Clear the saved original stream reference
    _originalStreamScreen = null;

    await params.prepopulateUserMedia(PrepopulateUserMediaOptions(
      name: params.hostLabel,
      parameters: params as PrepopulateUserMediaParameters,
    ));
  }

  Future<void> _stopAllTracks(ScreenboardModalParameters params) async {
    if (params.localStreamScreen != null) {
      for (final track in params.localStreamScreen!.getTracks()) {
        await track.stop();
      }
      params.updateLocalStreamScreen(null);
    }

    if (params.processedScreenStream != null) {
      for (final track in params.processedScreenStream!.getTracks()) {
        await track.stop();
      }
      params.updateProcessedScreenStream(null);
    }
  }

  Alignment _getModalAlignment() {
    final position = widget.options.position;
    if (position.contains('top') && position.contains('Right')) {
      return Alignment.topRight;
    } else if (position.contains('top') && position.contains('Left')) {
      return Alignment.topLeft;
    } else if (position.contains('bottom') && position.contains('Right')) {
      return Alignment.bottomRight;
    } else if (position.contains('bottom') && position.contains('Left')) {
      return Alignment.bottomLeft;
    }
    return Alignment.topRight;
  }

  @override
  Widget build(BuildContext context) {
    // Screenboard is only supported on web platform
    if (!PlatformFeatureSupport.isScreenboardSupported) {
      return const SizedBox.shrink();
    }

    if (!widget.options.isVisible) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = (screenWidth * 0.8).clamp(0.0, 500.0);

    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          // Tap to close background
          GestureDetector(
            onTap: widget.options.onClose,
            child: Container(color: Colors.transparent),
          ),

          // Modal content
          Align(
            alignment: _getModalAlignment(),
            child: Container(
              margin: const EdgeInsets.all(10),
              width: modalWidth,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: widget.options.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Screen Annotation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: widget.options.onClose,
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  const Divider(
                    height: 1,
                    color: Colors.black,
                  ),

                  // Content area
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status indicator
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isAnnotationActive
                                        ? Icons.videocam
                                        : Icons.draw,
                                    size: 48,
                                    color: _isAnnotationActive
                                        ? Colors.green
                                        : Colors.white54,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isAnnotationActive
                                        ? 'Broadcasting Annotations'
                                        : 'Screen Annotation Preview',
                                    style: TextStyle(
                                      color: _isAnnotationActive
                                          ? Colors.green
                                          : Colors.white70,
                                      fontSize: 14,
                                      fontWeight: _isAnnotationActive
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  if (_isAnnotationActive) ...[
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Annotations visible to all participants',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                  if (!kIsWeb ||
                                      !isWebCanvasCaptureSupported()) ...[
                                    const SizedBox(height: 4),
                                    const Text(
                                      '(Local-only on this platform)',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Info text
                          Text(
                            'Host: ${_params.hostLabel}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _params.annotateScreenStream
                                ? 'Annotation: Enabled'
                                : 'Annotation: Disabled',
                            style: TextStyle(
                              color: _params.annotateScreenStream
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up annotation capture
    _annotationCapture?.stopCapture();
    _annotationCapture?.dispose();
    super.dispose();
  }
}
