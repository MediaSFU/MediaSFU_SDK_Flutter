import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../components/background_components/background_modal.dart'
    show BackgroundModalOptions, BackgroundModalParameters;
import '../../components/background_components/virtual_background_types.dart';
import '../../components/background_components/processed_video_renderer.dart';
import '../../components/background_components/virtual_stream_source.dart';
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

// Platform check helper that works on all platforms including web
bool _isMobilePlatform() {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

typedef ModernBackgroundModalType = Widget Function({
  required BackgroundModalOptions options,
});

/// Modern background modal with glassmorphic design.
/// Uses the same [BackgroundModalOptions] as the original component.
class ModernBackgroundModal extends StatefulWidget {
  final BackgroundModalOptions options;

  const ModernBackgroundModal({super.key, required this.options});

  @override
  State<ModernBackgroundModal> createState() => _ModernBackgroundModalState();
}

class _ModernBackgroundModalState extends State<ModernBackgroundModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

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

  // Virtual stream source for processed frames
  VirtualStreamSource? _streamSource;

  // Tab selection
  int _selectedTabIndex = 0;

  BackgroundModalParameters get _params => widget.options.parameters;

  bool get _isPlatformSupported => _isMobilePlatform();

  /// Get the effective stream to use for preview
  MediaStream? get _effectiveStream {
    if (_params.videoAlreadyOn && _params.localStreamVideo != null) {
      return _params.localStreamVideo;
    }
    return _previewStream;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    _selectedBackground = _params.selectedBackground;

    // Add any custom backgrounds passed in options
    if (widget.options.customBackgrounds != null) {
      _customBackgrounds.addAll(widget.options.customBackgrounds!);
    }
  }

  @override
  void dispose() {
    _cleanupPreviewStream();
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) => widget.options.onClose());
  }

  /// Initialize camera for preview when video is not already on
  Future<void> _initializeCameraIfNeeded() async {
    if (!_params.videoAlreadyOn &&
        _isPlatformSupported &&
        _previewStream == null &&
        !_isInitializingCamera) {
      setState(() {
        _isInitializingCamera = true;
        _cameraInitError = null;
      });

      try {
        final videoConstraints = <String, dynamic>{
          'facingMode': 'user',
          'frameRate': _params.frameRate > 0 ? _params.frameRate : 15,
        };

        final vidCons = _params.vidCons;
        if (vidCons != null) {
          if (vidCons is Map<String, dynamic>) {
            videoConstraints.addAll(vidCons);
          } else {
            try {
              final consMap = (vidCons as dynamic).toMap();
              if (consMap is Map<String, dynamic>) {
                videoConstraints.addAll(consMap);
              }
            } catch (_) {}
          }
        }

        final constraints = <String, dynamic>{
          'audio': false,
          'video': videoConstraints,
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
          print(
              'MediaSFU - ModernBackgroundModal: Camera initialization failed: $e');
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
      _params.updateSelectedBackground(_selectedBackground);
      _params.updateBackgroundHasChanged(true);

      if (_selectedBackground!.type != BackgroundType.none) {
        _params.updateKeepBackground(true);
      } else {
        _params.updateKeepBackground(false);
      }

      if (_params.onBackgroundApply != null) {
        await _params.onBackgroundApply!(_selectedBackground!);
      }

      _params.showAlert?.call(
        message: 'Background applied successfully',
        type: 'success',
        duration: 2000,
      );

      _handleClose();
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

  Future<void> _saveBackgroundForLater() async {
    if (_selectedBackground == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      if (_streamSource != null) {
        try {
          _streamSource!.stopOutput();
        } catch (_) {}
      }

      _params.updateSelectedBackground(_selectedBackground);

      if (_selectedBackground!.type != BackgroundType.none) {
        _params.updateKeepBackground(true);
        // Mark as applied so it auto-applies when camera starts
        _params.updateAppliedBackground(true);
      } else {
        _params.updateKeepBackground(false);
        _params.updateAppliedBackground(false);
      }

      _params.updateBackgroundHasChanged(true);

      _params.showAlert?.call(
        message:
            'Background saved. It will be applied when you turn on your camera.',
        type: 'success',
        duration: 3000,
      );

      _handleClose();
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

    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth * 0.9 > 500 ? 500.0 : screenWidth * 0.9;
    final modalHeight = MediaQuery.of(context).size.height * 0.75;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = screenWidth >= 1200;
    final shouldUseSidebar = isLandscape && isWide;
    final useHighTransparency = !shouldUseSidebar;

    // For sidebar or inline mode, render content directly without modal wrapper
    if (widget.options.renderMode == ModalRenderMode.sidebar ||
        widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent();
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _handleClose,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(color: Colors.black.withValues(alpha: 0.05)),
              ),
            ),
          ),
          Positioned(
            top: getModalPosition(GetModalPositionOptions(
              position: widget.options.position,
              modalWidth: modalWidth,
              modalHeight: modalHeight,
              context: context,
            ))['top'],
            right: getModalPosition(GetModalPositionOptions(
              position: widget.options.position,
              modalWidth: modalWidth,
              modalHeight: modalHeight,
              context: context,
            ))['right'],
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: modalWidth,
                      height: modalHeight,
                      decoration: BoxDecoration(
                        color: useHighTransparency
                            ? (widget.options.isDarkMode
                                ? Colors.black.withValues(alpha: 0.05)
                                : Colors.white.withValues(alpha: 0.08))
                            : (widget.options.isDarkMode
                                ? Colors.black.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.9)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.options.isDarkMode
                              ? Colors.white.withValues(
                                  alpha: useHighTransparency ? 0.08 : 0.15)
                              : Colors.black.withValues(
                                  alpha: useHighTransparency ? 0.05 : 0.1),
                        ),
                        boxShadow: useHighTransparency
                            ? []
                            : [
                                BoxShadow(
                                  color: MediasfuColors.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                ),
                                BoxShadow(
                                  color: MediasfuColors.secondary
                                      .withValues(alpha: 0.15),
                                  blurRadius: 60,
                                  spreadRadius: 10,
                                  offset: const Offset(10, 20),
                                ),
                              ],
                      ),
                      child: Column(
                        children: [
                          _buildHeader(),
                          if (!_isPlatformSupported) _buildPlatformWarning(),
                          Expanded(child: _buildContent()),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds sidebar-optimized content for embedding in sidebar panel.
  Widget _buildSidebarContent() {
    return Container(
      color: widget.options.isDarkMode
          ? Colors.black.withValues(alpha: 0.7)
          : Colors.white.withValues(alpha: 0.9),
      child: Column(
        children: [
          _buildHeader(),
          if (!_isPlatformSupported) _buildPlatformWarning(),
          Expanded(child: _buildContent()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.options.isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(MediasfuSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                MediasfuColors.primary,
                MediasfuColors.primary.withValues(alpha: 0.7),
              ]),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: MediasfuColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.wallpaper_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: MediasfuSpacing.sm),
          Text(
            'Virtual Background',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.options.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _handleClose,
            child: Container(
              padding: const EdgeInsets.all(MediasfuSpacing.sm),
              decoration: BoxDecoration(
                color: widget.options.isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.close_rounded,
                color:
                    widget.options.isDarkMode ? Colors.white70 : Colors.black54,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformWarning() {
    return Container(
      margin: const EdgeInsets.all(MediasfuSpacing.md),
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(MediasfuSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 20),
          ),
          const SizedBox(width: MediasfuSpacing.md),
          Expanded(
            child: Text(
              'Virtual backgrounds are only supported on mobile devices (Android/iOS).',
              style: TextStyle(
                color: widget.options.isDarkMode
                    ? Colors.orange[200]
                    : Colors.orange[800],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Preview area
        if (widget.options.showPreview) _buildPreviewArea(),
        // Tab buttons
        _buildTabButtons(),
        // Tab content
        Expanded(child: _buildTabContent()),
      ],
    );
  }

  Widget _buildPreviewArea() {
    if (_isPlatformSupported) {
      final effectiveStream = _effectiveStream;
      final hasStream = effectiveStream != null &&
          effectiveStream.getVideoTracks().isNotEmpty;
      final isPreviewOnly = !_params.videoAlreadyOn && _previewStream != null;

      // Camera initializing
      if (_isInitializingCamera) {
        return _buildPreviewContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  MediasfuColors.primary,
                ),
              ),
              const SizedBox(height: MediasfuSpacing.md),
              Text(
                'Initializing camera...',
                style: TextStyle(
                  color: widget.options.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }

      // Camera error
      if (_cameraInitError != null && effectiveStream == null) {
        return _buildPreviewContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(MediasfuSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.videocam_off,
                    color: Colors.orange, size: 32),
              ),
              const SizedBox(height: MediasfuSpacing.md),
              Text(
                'Camera not available',
                style: TextStyle(
                  color:
                      widget.options.isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: MediasfuSpacing.xs),
              Text(
                'Select a background to save for later',
                style: TextStyle(
                  color: widget.options.isDarkMode
                      ? Colors.white54
                      : Colors.black45,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: MediasfuSpacing.md),
              _buildGradientButton(
                icon: Icons.refresh,
                label: 'Retry',
                onPressed: () {
                  setState(() {
                    _cameraInitError = null;
                  });
                  _initializeCameraIfNeeded();
                },
                small: true,
              ),
            ],
          ),
        );
      }

      // Preview not started yet - show start button
      if (!_params.videoAlreadyOn &&
          !_previewTriggered &&
          _previewStream == null) {
        return _buildPreviewContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(MediasfuSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    MediasfuColors.primary.withValues(alpha: 0.2),
                    MediasfuColors.secondary.withValues(alpha: 0.2),
                  ]),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.visibility_outlined,
                  size: 36,
                  color: widget.options.isDarkMode
                      ? Colors.white70
                      : MediasfuColors.primary,
                ),
              ),
              const SizedBox(height: MediasfuSpacing.sm),
              Text(
                'Preview Background',
                style: TextStyle(
                  color:
                      widget.options.isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Start camera to preview your selection',
                style: TextStyle(
                  color: widget.options.isDarkMode
                      ? Colors.white54
                      : Colors.black45,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: MediasfuSpacing.sm),
              _buildGradientButton(
                icon: Icons.videocam,
                label: 'Start Preview',
                onPressed: () {
                  setState(() {
                    _previewTriggered = true;
                  });
                  _initializeCameraIfNeeded();
                },
                small: true,
              ),
            ],
          ),
        );
      }

      // Show live preview
      return Container(
        margin: const EdgeInsets.symmetric(
            horizontal: MediasfuSpacing.md, vertical: MediasfuSpacing.sm),
        height: 180,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.grey[900]!.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: ProcessedVideoRenderer(
                  background: _selectedBackground,
                  existingStream: effectiveStream,
                  processingEnabled: hasStream,
                  targetFps: 10,
                  width: double.infinity,
                  height: 160,
                  onReady: () {},
                  onError: (error) {},
                  onStreamSourceReady: (source) {
                    _streamSource = source;
                    if (_selectedBackground != null &&
                        _selectedBackground!.type != BackgroundType.none) {
                      _params.updateKeepBackground(true);
                      _params.updateBackgroundHasChanged(true);
                    }
                  },
                ),
              ),
            ),

            // Preview Only badge
            if (isPreviewOnly)
              Positioned(
                top: MediasfuSpacing.sm,
                right: MediasfuSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MediasfuSpacing.sm,
                    vertical: MediasfuSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Preview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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

    // Unsupported platform - static preview
    return _buildPreviewContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.desktop_access_disabled,
            color: Colors.orange,
            size: 36,
          ),
          const SizedBox(height: MediasfuSpacing.md),
          Text(
            'Live preview not available',
            style: TextStyle(
              color: widget.options.isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: MediasfuSpacing.xs),
          Text(
            'Virtual backgrounds require mobile device',
            style: TextStyle(
              color:
                  widget.options.isDarkMode ? Colors.white54 : Colors.black45,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: MediasfuSpacing.md, vertical: MediasfuSpacing.sm),
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.options.isDarkMode
              ? [Colors.grey[900]!, Colors.grey[850]!]
              : [Colors.grey[200]!, Colors.grey[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.options.isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool small = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? MediasfuSpacing.md : MediasfuSpacing.lg,
          vertical: small ? MediasfuSpacing.sm : MediasfuSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [MediasfuColors.primary, MediasfuColors.secondary],
          ),
          borderRadius: BorderRadius.circular(small ? 8 : 12),
          boxShadow: [
            BoxShadow(
              color: MediasfuColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: small ? 16 : 20),
            SizedBox(width: small ? 6 : 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: small ? 13 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButtons() {
    final tabs = [
      'Presets',
      'Blur',
      if (widget.options.showColorPicker) 'Colors',
      'Custom'
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: MediasfuSpacing.md),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = _selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: MediasfuSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? MediasfuColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? MediasfuColors.primary
                        : (widget.options.isDarkMode
                            ? Colors.white54
                            : Colors.black45),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    final tabIndex = _selectedTabIndex;
    final hasColors = widget.options.showColorPicker;

    if (tabIndex == 0) {
      return _buildPresetsTab();
    } else if (tabIndex == 1) {
      return _buildBlurTab();
    } else if (hasColors && tabIndex == 2) {
      return _buildColorsTab();
    } else {
      return _buildCustomTab();
    }
  }

  Widget _buildPresetsTab() {
    final presetImages = PresetBackgrounds.images;

    return GridView.builder(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: presetImages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          final none = VirtualBackground.none();
          final isSelected =
              _selectedBackground?.id == none.id || _selectedBackground == null;
          return _buildBackgroundCard(
            background: none,
            isSelected: isSelected,
            child: Center(
              child: Text(
                'None',
                style: TextStyle(
                  color: widget.options.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                  fontWeight: FontWeight.w500,
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
          child: CachedNetworkImage(
            imageUrl: bg.thumbnailUrl ?? bg.imageUrl ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(MediasfuColors.primary),
                ),
              ),
            ),
            errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildBlurTab() {
    final blurPresets = [VirtualBackground.none(), ...PresetBackgrounds.blurs];

    return GridView.builder(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
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
              ? Icon(Icons.person,
                  size: 36,
                  color: widget.options.isDarkMode
                      ? Colors.white54
                      : Colors.black45)
              : Icon(
                  Icons.blur_on,
                  size: 36,
                  color: Colors.blue
                      .withValues(alpha: 0.5 + bg.blurIntensity * 0.5),
                ),
        );
      },
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
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
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
          child: Container(color: bg.color),
        );
      },
    );
  }

  Widget _buildCustomTab() {
    return Column(
      children: [
        Expanded(
          child: _customBackgrounds.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(MediasfuSpacing.lg),
                        decoration: BoxDecoration(
                          color: widget.options.isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: widget.options.isDarkMode
                              ? Colors.white38
                              : Colors.black26,
                        ),
                      ),
                      const SizedBox(height: MediasfuSpacing.md),
                      Text(
                        'No custom backgrounds',
                        style: TextStyle(
                          color: widget.options.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: MediasfuSpacing.xs),
                      Text(
                        'Upload your own images',
                        style: TextStyle(
                          color: widget.options.isDarkMode
                              ? Colors.white38
                              : Colors.black38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(MediasfuSpacing.md),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
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
                          ? Image.memory(bg.imageBytes!, fit: BoxFit.cover)
                          : const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
        ),
        if (widget.options.allowCustomUpload)
          Padding(
            padding: const EdgeInsets.all(MediasfuSpacing.md),
            child: GestureDetector(
              onTap: _isPlatformSupported ? _pickImage : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(MediasfuSpacing.md),
                decoration: BoxDecoration(
                  gradient: _isPlatformSupported
                      ? LinearGradient(colors: [
                          MediasfuColors.primary.withValues(alpha: 0.1),
                          MediasfuColors.secondary.withValues(alpha: 0.1),
                        ])
                      : null,
                  color: _isPlatformSupported ? null : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isPlatformSupported
                        ? MediasfuColors.primary.withValues(alpha: 0.3)
                        : Colors.grey,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      color: _isPlatformSupported
                          ? MediasfuColors.primary
                          : Colors.grey,
                    ),
                    const SizedBox(width: MediasfuSpacing.sm),
                    Text(
                      'Add Custom Background',
                      style: TextStyle(
                        color: _isPlatformSupported
                            ? MediasfuColors.primary
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBackgroundCard({
    required VirtualBackground background,
    required bool isSelected,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: () => _selectBackground(background),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? MediasfuColors.primary
                : (widget.options.isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: MediasfuColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: widget.options.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  child: child,
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        MediasfuColors.primary,
                        MediasfuColors.secondary
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: MediasfuColors.primary.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
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
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: widget.options.isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Cancel button
          GestureDetector(
            onTap: _handleClose,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MediasfuSpacing.md,
                vertical: MediasfuSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: widget.options.isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: widget.options.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: MediasfuSpacing.sm),
          // Apply button
          GestureDetector(
            onTap: _isPlatformSupported && !_isProcessing
                ? (videoAlreadyOn ? _applyBackground : _saveBackgroundForLater)
                : null,
            child: Opacity(
              opacity: _isPlatformSupported ? 1.0 : 0.5,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MediasfuSpacing.lg,
                  vertical: MediasfuSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [MediasfuColors.primary, MediasfuColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: MediasfuColors.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        videoAlreadyOn ? 'Apply' : 'Save for Later',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
