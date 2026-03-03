import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'virtual_background_types.dart';
import 'processed_video_renderer.dart';
import 'virtual_stream_source.dart';
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/types.dart' show ShowAlert;
import '../../types/modal_style_options.dart' show ModalRenderMode;

// Platform check helper that works on all platforms including web
bool _isMobilePlatform() {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows;
}

/// Parameters for the BackgroundModal widget.
abstract class BackgroundModalParameters {
  ShowAlert? get showAlert;
  VirtualBackground? get selectedBackground;
  String get targetResolution; // For selecting appropriate image resolution

  /// The current local video stream from the main app.
  /// This is used for preview instead of creating a new camera stream.
  /// Mirrors React's localStreamVideo parameter.
  MediaStream? get localStreamVideo;

  /// Whether the video is already on (camera already streaming)
  /// When false, the modal will initialize its own camera for preview
  bool get videoAlreadyOn;

  /// Video constraints for camera initialization when videoAlreadyOn is false
  /// Can be VidCons type or Map<String, dynamic>
  dynamic get vidCons;

  /// Target frame rate for camera preview
  int get frameRate;

  /// Whether the app is in dark mode (for theme awareness)
  bool get isDarkModeValue;

  void Function(VirtualBackground?) get updateSelectedBackground;
  void Function(bool) get updateIsBackgroundModalVisible;

  /// Callback when background is applied
  Future<void> Function(VirtualBackground)? get onBackgroundApply;

  /// Callback when background is previewed (before apply)
  Future<void> Function(VirtualBackground)? get onBackgroundPreview;

  /// Callback to update the processed stream for virtual background
  /// This mirrors React's updateProcessedStream
  void Function(MediaStream?)? get updateProcessedStream;

  /// Callback to update keepBackground flag
  /// Set to true when virtual background processing is active
  void Function(bool) get updateKeepBackground;

  /// Callback to mark that background has changed
  void Function(bool) get updateBackgroundHasChanged;

  /// Callback to update appliedBackground flag
  /// Set to true when a background has been successfully applied
  void Function(bool) get updateAppliedBackground;

  BackgroundModalParameters Function() get getUpdatedAllParams;
}

/// Options for the BackgroundModal widget.
class BackgroundModalOptions {
  final bool isVisible;
  final VoidCallback onClose;
  final BackgroundModalParameters parameters;
  final Color backgroundColor;
  final String position;
  final List<VirtualBackground>? customBackgrounds;
  final bool allowCustomUpload;
  final bool showColorPicker;
  final bool showPreview;
  final ModalRenderMode renderMode;
  final bool isDarkMode;

  BackgroundModalOptions({
    required this.isVisible,
    required this.onClose,
    required this.parameters,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.position = 'center',
    this.customBackgrounds,
    this.allowCustomUpload = true,
    this.showColorPicker = true,
    this.showPreview = true,
    this.renderMode = ModalRenderMode.modal,
    this.isDarkMode = false,
  });
}

/// Type definition for BackgroundModal widget builder.
typedef BackgroundModalType = Widget Function(
    {required BackgroundModalOptions options});

/// BackgroundModal - Modal for selecting virtual backgrounds.
///
/// This component provides an interface for selecting and applying virtual
/// backgrounds during video calls, matching the React MediaSFU implementation.
///
/// Features:
/// - Default preset images from MediaSFU (wall, shelf, clock, desert, flower)
/// - Preset blur backgrounds with adjustable intensity
/// - Preset color backgrounds
/// - Custom image upload
/// - Live camera preview with background applied
/// - Platform compatibility checking
///
/// Platform Support:
/// - ✅ Android: Full support via ML Kit Selfie Segmentation
/// - ✅ iOS: Full support via ML Kit Selfie Segmentation
/// - ❌ Web: Not supported (no ML Kit)
/// - ❌ Windows/macOS/Linux: Not supported (no ML Kit)
///
/// Example:
/// ```dart
/// BackgroundModal(
///   options: BackgroundModalOptions(
///     isVisible: true,
///     onClose: () => setState(() => _isVisible = false),
///     parameters: backgroundParams,
///   ),
/// )
/// ```
class BackgroundModal extends StatefulWidget {
  final BackgroundModalOptions options;

  const BackgroundModal({super.key, required this.options});

  @override
  State<BackgroundModal> createState() => _BackgroundModalState();
}

class _BackgroundModalState extends State<BackgroundModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();

  VirtualBackground? _selectedBackground;
  final List<VirtualBackground> _customBackgrounds = [];
  bool _isProcessing = false;

  // Preview stream for when camera is not already on
  MediaStream? _previewStream;
  bool _isInitializingCamera = false;
  String? _cameraInitError;

  // Whether preview has been triggered (like React's applyBackground button)
  bool _previewTriggered = false;

  // Virtual stream source for processed frames (React parity)
  VirtualStreamSource? _streamSource;

  BackgroundModalParameters get _params => widget.options.parameters;

  bool get _isPlatformSupported {
    // Virtual backgrounds only work on mobile (iOS/Android) with ML Kit
    return _isMobilePlatform();
  }

  /// Get the effective stream to use for preview
  MediaStream? get _effectiveStream {
    if (_params.videoAlreadyOn && _params.localStreamVideo != null) {
      return _params.localStreamVideo;
    }
    return _previewStream;
  }

  /// Dark mode theme helpers
  /// Uses explicit isDarkMode from options if provided, otherwise uses isDarkModeValue from parameters
  bool get _isDarkMode => widget.options.isDarkMode || _params.isDarkModeValue;

  Color get _textColor => _isDarkMode ? Colors.white : Colors.black87;

  Color get _secondaryTextColor =>
      _isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

  Color get _dividerColor =>
      _isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

  Color get _tabLabelColor => _isDarkMode ? Colors.blue[300]! : Colors.blue;

  Color get _unselectedTabColor =>
      _isDarkMode ? Colors.grey[500]! : Colors.grey;

  @override
  void initState() {
    super.initState();
    // 4 tabs: Images, Blur, Colors, Custom
    _tabController = TabController(
      length: widget.options.showColorPicker ? 4 : 3,
      vsync: this,
    );
    _selectedBackground = _params.selectedBackground;

    // Add any custom backgrounds passed in options
    if (widget.options.customBackgrounds != null) {
      _customBackgrounds.addAll(widget.options.customBackgrounds!);
    }

    // Don't auto-initialize camera - let user trigger it via preview if needed
    // This prevents the "stuck waiting for camera" issue
  }

  /// Initialize camera for preview when video is not already on
  Future<void> _initializeCameraIfNeeded() async {
    // Only initialize if camera is not already on and platform supports it
    if (!_params.videoAlreadyOn &&
        _isPlatformSupported &&
        _previewStream == null &&
        !_isInitializingCamera) {
      setState(() {
        _isInitializingCamera = true;
        _cameraInitError = null;
      });

      try {
        // Build mandatory constraints for cross-platform compatibility (iOS needs 'mandatory')
        final mandatoryConstraints = <String, dynamic>{
          'facingMode': 'user',
          'frameRate': {
            'ideal': _params.frameRate > 0 ? _params.frameRate : 15
          },
        };

        // Merge with custom constraints if provided
        // Handle both VidCons type and Map<String, dynamic> type
        final vidCons = _params.vidCons;
        if (vidCons != null) {
          if (vidCons is Map<String, dynamic>) {
            if (vidCons['width'] != null)
              mandatoryConstraints['width'] = vidCons['width'];
            if (vidCons['height'] != null)
              mandatoryConstraints['height'] = vidCons['height'];
          } else {
            // VidCons type - call toMap() method if available
            try {
              final consMap = (vidCons as dynamic).toMap();
              if (consMap is Map<String, dynamic>) {
                if (consMap['width'] != null)
                  mandatoryConstraints['width'] = consMap['width'];
                if (consMap['height'] != null)
                  mandatoryConstraints['height'] = consMap['height'];
              }
            } catch (_) {}
          }
        }

        final constraints = <String, dynamic>{
          'audio': false,
          'video': {
            'mandatory': mandatoryConstraints,
          },
        };

        final stream = await navigator.mediaDevices.getUserMedia(constraints);

        if (mounted) {
          setState(() {
            _previewStream = stream;
            _isInitializingCamera = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _cameraInitError = e.toString();
            _isInitializingCamera = false;
          });
        }
        if (kDebugMode) {
          print('MediaSFU - BackgroundModal: Camera initialization failed: $e');
        }
      }
    }
  }

  /// Clean up preview stream when modal closes
  Future<void> _cleanupPreviewStream() async {
    if (_previewStream != null) {
      try {
        final tracks = _previewStream!.getVideoTracks();
        for (final track in tracks) {
          track.stop();
        }
        await _previewStream!.dispose();
      } catch (_) {}
      _previewStream = null;
    }
  }

  @override
  void dispose() {
    // Clean up preview stream if we created one
    _cleanupPreviewStream();
    _tabController.dispose();
    super.dispose();
  }

  // Note: No camera preview initialization needed!
  // ProcessedVideoRenderer handles everything using localStreamVideo directly.
  // This design prevents freezing issues that occur when creating multiple streams.

  Future<void> _pickImage() async {
    if (!widget.options.allowCustomUpload) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final customBg = VirtualBackground.image(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          name: image.name,
          imageBytes: bytes,
        );

        setState(() {
          _customBackgrounds.add(customBg);
          _selectedBackground = customBg;
        });
      }
    } catch (e) {
      _params.showAlert?.call(
        message: 'Failed to load image: $e',
        type: 'danger',
        duration: 3000,
      );
    }
  }

  void _selectBackground(VirtualBackground background) {
    setState(() {
      _selectedBackground = background;
    });
  }

  Future<void> _applyBackground() async {
    if (_selectedBackground == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Update the selected background in parameters
      _params.updateSelectedBackground(_selectedBackground);

      // IMPORTANT: Set backgroundHasChanged to true so handleBackgroundApply processes it
      _params.updateBackgroundHasChanged(true);

      // IMPORTANT: Set keepBackground to true for non-none backgrounds
      // This is required by _applyNativeVirtualBackground which checks keepBackground.value == true
      if (_selectedBackground!.type != BackgroundType.none) {
        _params.updateKeepBackground(true);
      } else {
        _params.updateKeepBackground(false);
      }

      // Call the apply callback if provided
      if (_params.onBackgroundApply != null) {
        await _params.onBackgroundApply!(_selectedBackground!);
      }

      _params.showAlert?.call(
        message: 'Background applied successfully',
        type: 'success',
        duration: 2000,
      );

      widget.options.onClose();
    } catch (e) {
      _params.showAlert?.call(
        message: 'Failed to apply background: $e',
        type: 'danger',
        duration: 3000,
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// Save background for later application when user turns on their camera
  /// This is used when videoAlreadyOn is false - the background will be applied
  /// automatically when the user starts their camera
  Future<void> _saveBackgroundForLater() async {
    if (_selectedBackground == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Stop the preview processor if running since we're just saving the selection
      if (_streamSource != null) {
        try {
          _streamSource!.stopOutput();
        } catch (_) {}
      }

      // Update the selected background in parameters so it's saved
      _params.updateSelectedBackground(_selectedBackground);

      // Set keepBackground to true for non-none backgrounds
      // When camera turns on, stream_success_video will auto-apply this
      if (_selectedBackground!.type != BackgroundType.none) {
        _params.updateKeepBackground(true);
        // Mark as applied so it auto-applies when camera starts
        _params.updateAppliedBackground(true);
      } else {
        _params.updateKeepBackground(false);
        _params.updateAppliedBackground(false);
      }

      // Set backgroundHasChanged so stream_success_video knows to apply it
      _params.updateBackgroundHasChanged(true);

      _params.showAlert?.call(
        message:
            'Background saved. It will be applied when you turn on your camera.',
        type: 'success',
        duration: 3000,
      );

      widget.options.onClose();
    } catch (e) {
      _params.showAlert?.call(
        message: 'Failed to save background: $e',
        type: 'danger',
        duration: 3000,
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.options.isVisible) return const SizedBox.shrink();

    // For sidebar or inline mode, render content directly without modal wrapper
    if (widget.options.renderMode == ModalRenderMode.sidebar ||
        widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent();
    }

    final screenSize = MediaQuery.of(context).size;
    final modalWidth = screenSize.width > 600 ? 500.0 : screenSize.width * 0.9;
    final modalHeight = screenSize.height * 0.75;

    final positionResult = getModalPosition(GetModalPositionOptions(
      position: widget.options.position,
      modalWidth: modalWidth,
      modalHeight: modalHeight,
      context: context,
    ));

    return Stack(
      children: [
        // Overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.options.onClose,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),

        // Modal
        Positioned(
          top: positionResult['top'],
          right: positionResult['right'],
          left: positionResult['left'],
          bottom: positionResult['bottom'],
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: modalWidth,
              height: modalHeight,
              decoration: BoxDecoration(
                color: widget.options.backgroundColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _buildContent(context, showCloseButton: true),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the content for sidebar/inline rendering.
  Widget _buildSidebarContent() {
    return Container(
      color: widget.options.backgroundColor,
      child: Column(
        children: [
          _buildHeader(showCloseButton: true),
          if (!_isPlatformSupported) _buildPlatformWarning(),
          Divider(height: 1, color: _dividerColor),
          _buildTabs(),
          Expanded(child: _buildTabContent()),
          Divider(height: 1, color: _dividerColor),
          _buildFooter(),
        ],
      ),
    );
  }

  /// Builds the content for modal rendering.
  Widget _buildContent(BuildContext context, {bool showCloseButton = true}) {
    return Column(
      children: [
        _buildHeader(showCloseButton: showCloseButton),
        if (!_isPlatformSupported) _buildPlatformWarning(),
        Divider(height: 1, color: _dividerColor),
        _buildTabs(),
        Expanded(child: _buildTabContent()),
        Divider(height: 1, color: _dividerColor),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader({bool showCloseButton = true}) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Virtual Background',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          if (showCloseButton)
            IconButton(
              icon: Icon(Icons.close, color: _textColor),
              onPressed: widget.options.onClose,
            ),
        ],
      ),
    );
  }

  Widget _buildPlatformWarning() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Virtual backgrounds are supported on Android, iOS, macOS, and Windows. '
              'This feature is not available on ${kIsWeb ? 'web' : defaultTargetPlatform.name}.',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: _tabLabelColor,
      unselectedLabelColor: _unselectedTabColor,
      indicatorColor: _tabLabelColor,
      dividerColor: _dividerColor,
      isScrollable: true,
      tabs: [
        const Tab(
          icon: Icon(Icons.image),
          text: 'Presets',
        ),
        const Tab(
          icon: Icon(Icons.blur_on),
          text: 'Blur',
        ),
        if (widget.options.showColorPicker)
          const Tab(
            icon: Icon(Icons.color_lens),
            text: 'Colors',
          ),
        const Tab(
          icon: Icon(Icons.add_photo_alternate),
          text: 'Custom',
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPresetImagesTab(),
        _buildBlurTab(),
        if (widget.options.showColorPicker) _buildColorsTab(),
        _buildCustomImagesTab(),
      ],
    );
  }

  /// Build the preset images tab with default MediaSFU backgrounds
  Widget _buildPresetImagesTab() {
    final presetImages = PresetBackgrounds.images;

    return Column(
      children: [
        // Preview area (if enabled)
        if (widget.options.showPreview) _buildPreviewArea(),

        // Image grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: presetImages.length + 1, // +1 for "None" option
            itemBuilder: (context, index) {
              if (index == 0) {
                // "None" option
                final none = VirtualBackground.none();
                final isSelected = _selectedBackground?.id == none.id ||
                    _selectedBackground == null;
                return _buildBackgroundCard(
                  background: none,
                  isSelected: isSelected,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'None',
                        style: TextStyle(
                          color: _secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final bg = presetImages[index - 1];
              final isSelected = _selectedBackground?.id == bg.id;

              return _buildBackgroundCard(
                background: bg,
                isSelected: isSelected,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: bg.thumbnailUrl ?? bg.imageUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build the preview area showing camera with background applied in real-time.
  ///
  /// This matches React's BackgroundModal behavior:
  /// - Shows live camera feed with virtual background applied
  /// - Uses ProcessedVideoRenderer for real-time segmentation
  /// - Falls back to static preview on unsupported platforms
  /// - Handles camera initialization when video is not yet started
  /// - Camera is initialized LAZILY when user clicks "Preview Background" (like React)
  Widget _buildPreviewArea() {
    // Use ProcessedVideoRenderer for live preview with actual background
    if (_isPlatformSupported) {
      // Use effectiveStream - either localStreamVideo (if video on) or _previewStream (if video off)
      final effectiveStream = _effectiveStream;
      final hasStream = effectiveStream != null &&
          effectiveStream.getVideoTracks().isNotEmpty;

      // Check if we're using preview stream (camera not officially "on")
      final isPreviewOnly = !_params.videoAlreadyOn && _previewStream != null;

      // Show camera initialization loading state
      if (_isInitializingCamera) {
        return Container(
          margin: const EdgeInsets.all(16),
          height: 180,
          decoration: BoxDecoration(
            color: _isDarkMode ? Colors.grey[900] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isDarkMode ? Colors.white : Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Initializing camera for preview...',
                  style: TextStyle(color: _secondaryTextColor, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      }

      // Show camera initialization error state
      if (_cameraInitError != null && effectiveStream == null) {
        return Container(
          margin: const EdgeInsets.all(16),
          height: 180,
          decoration: BoxDecoration(
            color: _isDarkMode ? Colors.grey[900] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam_off, color: Colors.orange, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Camera not available',
                  style:
                      TextStyle(color: _textColor, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'You can still select a background.\nIt will be applied when you turn on your camera.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _secondaryTextColor, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                  onPressed: () {
                    setState(() {
                      _cameraInitError = null;
                    });
                    _initializeCameraIfNeeded();
                  },
                ),
              ],
            ),
          ),
        );
      }

      // When video is NOT already on and preview hasn't been triggered yet
      // Show a "Start Preview" button (like React's "Preview Background" button)
      if (!_params.videoAlreadyOn &&
          !_previewTriggered &&
          _previewStream == null) {
        return Container(
          margin: const EdgeInsets.all(12),
          height: 200,
          decoration: BoxDecoration(
            color: _isDarkMode ? Colors.grey[900] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 48,
                  color: _secondaryTextColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'Preview Background',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Click below to start camera preview',
                  style: TextStyle(
                    color: _secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.videocam, size: 16),
                  label: const Text('Start Preview',
                      style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _previewTriggered = true;
                    });
                    _initializeCameraIfNeeded();
                  },
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.all(16),
        height: 180,
        child: Stack(
          children: [
            // Live processed video preview
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ProcessedVideoRenderer(
                background: _selectedBackground,
                existingStream: effectiveStream,
                processingEnabled: hasStream,
                targetFps: 10, // Lower FPS for preview to reduce load
                width: double.infinity,
                height: 180,
                onReady: () {},
                onError: (error) {},
                onStreamSourceReady: (source) {
                  // Store the stream source for later use
                  _streamSource = source;

                  // Set keepBackground = true (like React does)
                  // This is important for handleBackgroundApply to know a background is active
                  if (_selectedBackground != null &&
                      _selectedBackground!.type != BackgroundType.none) {
                    _params.updateKeepBackground(true);
                    _params.updateBackgroundHasChanged(true);
                  }
                },
              ),
            ),

            // Preview Only indicator when camera not officially on
            if (isPreviewOnly)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Preview Only',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Processing indicator
            if (_isProcessing)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Applying background...',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Fallback for unsupported platforms - static preview
    return Container(
      margin: const EdgeInsets.all(16),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildStaticBackgroundPreview(),

            // Platform warning overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.desktop_access_disabled,
                        color: Colors.orange,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Live preview not available',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Virtual backgrounds require a supported platform',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build static background preview when camera is not available
  Widget _buildStaticBackgroundPreview() {
    if (_selectedBackground != null &&
        _selectedBackground!.type == BackgroundType.image &&
        _selectedBackground!.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: _selectedBackground!.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[800],
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white, size: 48),
        ),
      );
    } else if (_selectedBackground != null &&
        _selectedBackground!.type == BackgroundType.color &&
        _selectedBackground!.color != null) {
      return Container(color: _selectedBackground!.color);
    } else if (_selectedBackground != null &&
        _selectedBackground!.type == BackgroundType.blur) {
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Icon(
            Icons.blur_on,
            size: 64,
            color: Colors.blue.withOpacity(0.5 + _selectedBackground!.blurIntensity * 0.5),
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Text(
            'Select a background',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
  }

  Widget _buildBlurTab() {
    final blurPresets = [
      VirtualBackground.none(),
      ...PresetBackgrounds.blurs,
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: blurPresets.length,
      itemBuilder: (context, index) {
        final bg = blurPresets[index];
        final isSelected = _selectedBackground?.id == bg.id;

        return _buildBackgroundCard(
          background: bg,
          isSelected: isSelected,
          child: bg.type == BackgroundType.none
              ? Icon(Icons.person, size: 40, color: _secondaryTextColor)
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color:
                            _isDarkMode ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Icon(
                      Icons.blur_on,
                      size: 40,
                      color: Colors.blue
                          .withOpacity(0.5 + bg.blurIntensity * 0.5),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCustomImagesTab() {
    return Column(
      children: [
        // Custom backgrounds list
        Expanded(
          child: _customBackgrounds.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 64, color: _secondaryTextColor),
                      const SizedBox(height: 16),
                      Text(
                        'No custom backgrounds',
                        style: TextStyle(color: _secondaryTextColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add images',
                        style: TextStyle(
                            color: _secondaryTextColor.withOpacity(0.7),
                            fontSize: 13),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _customBackgrounds.length,
                  itemBuilder: (context, index) {
                    final bg = _customBackgrounds[index];
                    final isSelected = _selectedBackground?.id == bg.id;

                    return _buildBackgroundCard(
                      background: bg,
                      isSelected: isSelected,
                      child: bg.imageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                bg.imageBytes!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
        ),

        // Upload button
        if (widget.options.allowCustomUpload)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Custom Background'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: _isPlatformSupported ? _pickImage : null,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildColorsTab() {
    final colorPresets = PresetBackgrounds.colors;
    final extraColors = [
      Colors.red.shade700,
      Colors.pink.shade700,
      Colors.orange.shade700,
      Colors.amber.shade700,
      Colors.teal.shade700,
      Colors.cyan.shade700,
      Colors.indigo.shade700,
      Colors.brown.shade700,
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: colorPresets.length + extraColors.length,
      itemBuilder: (context, index) {
        final VirtualBackground bg;
        if (index < colorPresets.length) {
          bg = colorPresets[index];
        } else {
          final color = extraColors[index - colorPresets.length];
          bg = VirtualBackground.color(color);
        }

        final isSelected = _selectedBackground?.id == bg.id;

        return _buildBackgroundCard(
          background: bg,
          isSelected: isSelected,
          child: Container(
            decoration: BoxDecoration(
              color: bg.color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundCard({
    required VirtualBackground background,
    required bool isSelected,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: () => _selectBackground(background),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : _dividerColor,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: child,
              ),
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(10),
                  ),
                ),
                child: Text(
                  background.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final videoAlreadyOn = _params.videoAlreadyOn;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          TextButton(
            onPressed: widget.options.onClose,
            child: Text('Cancel', style: TextStyle(color: _secondaryTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            // Apply button enabled when platform supported and not processing
            onPressed: _isPlatformSupported && !_isProcessing
                ? (videoAlreadyOn ? _applyBackground : _saveBackgroundForLater)
                : null,
            child: _isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(videoAlreadyOn ? 'Apply' : 'Save for Later',
                    style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
