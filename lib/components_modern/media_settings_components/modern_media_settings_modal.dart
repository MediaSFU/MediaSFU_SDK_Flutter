import 'dart:ui';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../components/media_settings_components/media_settings_modal.dart'
    show MediaSettingsModalOptions;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../methods/stream_methods/switch_video.dart' show SwitchVideoOptions;
import '../../methods/stream_methods/switch_audio.dart' show SwitchAudioOptions;
import '../../methods/stream_methods/switch_video_alt.dart'
    show SwitchVideoAltOptions;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

typedef ModernMediaSettingsModalType = Widget Function({
  required MediaSettingsModalOptions options,
});

/// Modern media settings modal with glassmorphic design.
/// Uses the same [MediaSettingsModalOptions] as the original component.
class ModernMediaSettingsModal extends StatefulWidget {
  final MediaSettingsModalOptions options;

  const ModernMediaSettingsModal({super.key, required this.options});

  @override
  State<ModernMediaSettingsModal> createState() =>
      _ModernMediaSettingsModalState();
}

class _ModernMediaSettingsModalState extends State<ModernMediaSettingsModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) => widget.options.onClose());
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.options.isVisible) return const SizedBox.shrink();

    final parameters = widget.options.parameters.getUpdatedAllParams();
    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth * 0.85 > 420 ? 420.0 : screenWidth * 0.85;
    final modalHeight = MediaQuery.of(context).size.height * 0.6;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = screenWidth >= 1200;
    final shouldUseSidebar = isLandscape && isWide;
    final useHighTransparency = !shouldUseSidebar;

    final videoInputs = parameters.videoInputs;
    final audioInputs = parameters.audioInputs;

    String selectedVideo = parameters.userDefaultVideoInputDevice;
    if (videoInputs.isEmpty) {
      selectedVideo = '';
    } else if (selectedVideo.isEmpty ||
        !videoInputs.any((i) => i.deviceId == selectedVideo)) {
      selectedVideo = videoInputs[0].deviceId;
    }

    String selectedAudio = parameters.userDefaultAudioInputDevice;
    if (audioInputs.isEmpty) {
      selectedAudio = '';
    } else if (selectedAudio.isEmpty ||
        !audioInputs.any((i) => i.deviceId == selectedAudio)) {
      selectedAudio = audioInputs[0].deviceId;
    }

    // For sidebar or inline mode, render content directly without modal wrapper
    if (widget.options.renderMode == ModalRenderMode.sidebar ||
        widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent(
          parameters, videoInputs, audioInputs, selectedVideo, selectedAudio);
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
                    filter: widget.options.enableGlassmorphism
                        ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                        : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
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
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(MediasfuSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDeviceSection(
                                    icon: Icons.videocam_rounded,
                                    label: 'Camera',
                                    devices: videoInputs,
                                    selectedDevice: selectedVideo,
                                    onChanged: (deviceId) async {
                                      final params = widget.options.parameters
                                          .getUpdatedAllParams();
                                      await widget.options.switchVideoOnPress(
                                          SwitchVideoOptions(
                                        videoPreference: deviceId,
                                        parameters: params,
                                      ));
                                    },
                                  ),
                                  const SizedBox(height: MediasfuSpacing.md),
                                  _buildDeviceSection(
                                    icon: Icons.mic_rounded,
                                    label: 'Microphone',
                                    devices: audioInputs,
                                    selectedDevice: selectedAudio,
                                    onChanged: (deviceId) async {
                                      final params = widget.options.parameters
                                          .getUpdatedAllParams();
                                      await widget.options.switchAudioOnPress(
                                          SwitchAudioOptions(
                                        audioPreference: deviceId,
                                        parameters: params,
                                      ));
                                    },
                                  ),
                                  if (!kIsWeb) ...[
                                    const SizedBox(height: MediasfuSpacing.lg),
                                    _buildSwitchCameraButton(parameters),
                                  ],
                                  const SizedBox(height: MediasfuSpacing.lg),
                                  _buildVirtualBackgroundButton(parameters),
                                ],
                              ),
                            ),
                          ),
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
  Widget _buildSidebarContent(
    dynamic parameters,
    List<MediaDeviceInfo> videoInputs,
    List<MediaDeviceInfo> audioInputs,
    String selectedVideo,
    String selectedAudio,
  ) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MediasfuSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDeviceSection(
                  icon: Icons.videocam_rounded,
                  label: 'Camera',
                  devices: videoInputs,
                  selectedDevice: selectedVideo,
                  onChanged: (deviceId) async {
                    final params =
                        widget.options.parameters.getUpdatedAllParams();
                    await widget.options.switchVideoOnPress(SwitchVideoOptions(
                      videoPreference: deviceId,
                      parameters: params,
                    ));
                  },
                ),
                const SizedBox(height: MediasfuSpacing.md),
                _buildDeviceSection(
                  icon: Icons.mic_rounded,
                  label: 'Microphone',
                  devices: audioInputs,
                  selectedDevice: selectedAudio,
                  onChanged: (deviceId) async {
                    final params =
                        widget.options.parameters.getUpdatedAllParams();
                    await widget.options.switchAudioOnPress(SwitchAudioOptions(
                      audioPreference: deviceId,
                      parameters: params,
                    ));
                  },
                ),
                if (!kIsWeb) ...[
                  const SizedBox(height: MediasfuSpacing.lg),
                  _buildSwitchCameraButton(parameters),
                ],
                const SizedBox(height: MediasfuSpacing.lg),
                _buildVirtualBackgroundButton(parameters),
              ],
            ),
          ),
        ),
      ],
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
          // Settings icon with glow
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
            child: const Icon(Icons.settings_input_component_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: MediasfuSpacing.sm),
          Text(
            'Media Settings',
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

  Widget _buildDeviceSection({
    required IconData icon,
    required String label,
    required List<MediaDeviceInfo> devices,
    required String selectedDevice,
    required Future<void> Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        color: widget.options.isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.options.isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: MediasfuColors.primary, size: 20),
              const SizedBox(width: MediasfuSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      widget.options.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              if (devices.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: MediasfuSpacing.sm,
                      vertical: MediasfuSpacing.xs),
                  decoration: BoxDecoration(
                    color: MediasfuColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${devices.length} devices',
                    style: TextStyle(
                        fontSize: 11,
                        color: MediasfuColors.success,
                        fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
          const SizedBox(height: MediasfuSpacing.sm),
          if (devices.isEmpty)
            Text(
              'No devices found',
              style: TextStyle(
                  color: widget.options.isDarkMode
                      ? Colors.white54
                      : Colors.black45),
            )
          else
            Tooltip(
              message: 'Select $label device',
              decoration: MediasfuColors.tooltipDecoration(
                  darkMode: widget.options.isDarkMode),
              textStyle: TextStyle(
                color: MediasfuColors.tooltipText(
                    darkMode: widget.options.isDarkMode),
                fontSize: 12,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: MediasfuSpacing.md),
                decoration: MediasfuColors.dropdownDecoration(
                    darkMode: widget.options.isDarkMode),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedDevice.isNotEmpty ? selectedDevice : null,
                    isExpanded: true,
                    dropdownColor: MediasfuColors.dropdownBackground(
                        darkMode: widget.options.isDarkMode),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.options.isDarkMode
                          ? MediasfuColors.primaryDark
                          : MediasfuColors.primary,
                    ),
                    items: devices.map((device) {
                      return DropdownMenuItem(
                        value: device.deviceId,
                        child: Text(
                          device.label.isNotEmpty
                              ? device.label
                              : 'Device ${device.deviceId.substring(0, 8)}',
                          style: TextStyle(
                            color: widget.options.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) onChanged(value);
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSwitchCameraButton(dynamic params) {
    return Tooltip(
      message: 'Switch between front and back camera',
      decoration:
          MediasfuColors.tooltipDecoration(darkMode: widget.options.isDarkMode),
      textStyle: TextStyle(
        color: MediasfuColors.tooltipText(darkMode: widget.options.isDarkMode),
        fontSize: 12,
      ),
      child: GestureDetector(
        onTap: () async {
          final updatedParams = params.getUpdatedAllParams();
          await widget.options.switchCameraOnPress(
              SwitchVideoAltOptions(parameters: updatedParams));
        },
        child: Container(
          padding: const EdgeInsets.all(MediasfuSpacing.md),
          decoration: BoxDecoration(
            color: widget.options.isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.options.isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(MediasfuSpacing.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    MediasfuColors.secondary,
                    MediasfuColors.secondary.withValues(alpha: 0.7),
                  ]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cameraswitch_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: MediasfuSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Switch Camera',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: widget.options.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    Text(
                      'Toggle front/back camera',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.options.isDarkMode
                            ? Colors.white54
                            : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color:
                    widget.options.isDarkMode ? Colors.white38 : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Check if virtual background is supported on current platform
  bool get _isVirtualBackgroundSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Widget _buildVirtualBackgroundButton(dynamic params) {
    final isSupported = _isVirtualBackgroundSupported;

    return GestureDetector(
      onTap: () {
        if (isSupported) {
          widget.options.onClose();
          params.updateIsBackgroundModalVisible(true);
        } else {
          // Show alert for unsupported platforms
          params.showAlert?.call(
            message:
                'Virtual backgrounds are only supported on mobile devices (Android/iOS). '
                'This feature is not available on ${kIsWeb ? 'web' : defaultTargetPlatform.name}.',
            type: 'warning',
            duration: 4000,
          );
        }
      },
      child: Opacity(
        opacity: isSupported ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(MediasfuSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              MediasfuColors.primary
                  .withValues(alpha: isSupported ? 0.1 : 0.05),
              MediasfuColors.secondary
                  .withValues(alpha: isSupported ? 0.1 : 0.05),
            ]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: MediasfuColors.primary
                    .withValues(alpha: isSupported ? 0.3 : 0.15)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(MediasfuSpacing.sm),
                decoration: BoxDecoration(
                  gradient: isSupported
                      ? LinearGradient(colors: [
                          MediasfuColors.primary,
                          MediasfuColors.secondary
                        ])
                      : LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade500]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wallpaper_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: MediasfuSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Virtual Background',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: widget.options.isDarkMode
                            ? (isSupported ? Colors.white : Colors.white60)
                            : (isSupported ? Colors.black87 : Colors.black45),
                      ),
                    ),
                    Text(
                      isSupported
                          ? 'Change or blur your background'
                          : 'Mobile only (Android/iOS)',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.options.isDarkMode
                            ? Colors.white54
                            : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: MediasfuSpacing.sm,
                    vertical: MediasfuSpacing.xs),
                decoration: BoxDecoration(
                  gradient: isSupported
                      ? LinearGradient(colors: [
                          MediasfuColors.primary,
                          MediasfuColors.secondary
                        ])
                      : LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade500]),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isSupported ? 'NEW' : 'N/A',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
