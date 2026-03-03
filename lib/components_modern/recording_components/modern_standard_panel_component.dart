import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/recording_components/standard_panel_component.dart'
    show StandardPanelComponentParameters;
import '../../types/types.dart' show EventType;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/widgets/modern_switch.dart';

/// Configuration options for ModernStandardPanelComponent.
/// Uses the same [StandardPanelComponentParameters] as the original component.
class ModernStandardPanelComponentOptions {
  final StandardPanelComponentParameters parameters;

  // Modern styling options
  final bool enableGlassmorphism;
  final bool isDarkMode;

  ModernStandardPanelComponentOptions({
    required this.parameters,
    this.enableGlassmorphism = true,
    this.isDarkMode = true,
  });
}

typedef ModernStandardPanelType = Widget Function({
  required ModernStandardPanelComponentOptions options,
});

/// A modern standard recording configuration panel with glassmorphic styling.
///
/// Features:
/// - Glassmorphic dropdown selectors
/// - Gradient accents
/// - Smooth animations
/// - Dark/light mode support
class ModernStandardPanelComponent extends StatelessWidget {
  final ModernStandardPanelComponentOptions options;

  const ModernStandardPanelComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final isDark = options.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Media Options
        _buildSection(
          label: 'Media Options',
          icon: Icons.videocam_rounded,
          isDark: isDark,
          child: _buildModernPicker(
            value: options.parameters.recordingMediaOptions,
            onValueChanged: (value) =>
                options.parameters.updateRecordingMediaOptions(value),
            items: [
              {
                'label': 'Record Video',
                'value': 'video',
                'icon': Icons.videocam
              },
              {
                'label': 'Record Audio Only',
                'value': 'audio',
                'icon': Icons.audiotrack
              },
            ],
            isDark: isDark,
          ),
        ),
        const SizedBox(height: MediasfuSpacing.md),

        // Specific Audios
        if (options.parameters.eventType != EventType.broadcast) ...[
          _buildSection(
            label: 'Audio Sources',
            icon: Icons.mic_rounded,
            isDark: isDark,
            child: _buildModernPicker(
              value: options.parameters.recordingAudioOptions,
              onValueChanged: (value) =>
                  options.parameters.updateRecordingAudioOptions(value),
              items: [
                {
                  'label': 'All Participants',
                  'value': 'all',
                  'icon': Icons.people
                },
                {
                  'label': 'On-Screen Only',
                  'value': 'onScreen',
                  'icon': Icons.tv
                },
                {'label': 'Host Only', 'value': 'host', 'icon': Icons.person},
              ],
              isDark: isDark,
            ),
          ),
          const SizedBox(height: MediasfuSpacing.md),

          // Specific Videos
          _buildSection(
            label: 'Video Sources',
            icon: Icons.video_library_rounded,
            isDark: isDark,
            child: _buildModernPicker(
              value: options.parameters.recordingVideoOptions,
              onValueChanged: (value) =>
                  options.parameters.updateRecordingVideoOptions(value),
              items: [
                {
                  'label': 'All Videos',
                  'value': 'all',
                  'icon': Icons.grid_view
                },
                {
                  'label': 'Main Screen + Screenshare',
                  'value': 'mainScreen',
                  'icon': Icons.present_to_all
                },
              ],
              isDark: isDark,
            ),
          ),
          const SizedBox(height: MediasfuSpacing.md),
        ],

        // Add HLS
        _buildSection(
          label: 'Live Streaming (HLS)',
          icon: Icons.live_tv_rounded,
          isDark: isDark,
          child: _buildToggleSwitch(
            value: options.parameters.recordingAddHLS,
            onChanged: options.parameters.updateRecordingAddHLS,
            isDark: isDark,
            enableLabel: 'Enable live playback during recording',
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String label,
    required IconData icon,
    required bool isDark,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: options.enableGlassmorphism
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: _buildSectionContent(label, icon, isDark, child),
            )
          : _buildSectionContent(label, icon, isDark, child),
    );
  }

  Widget _buildSectionContent(
    String label,
    IconData icon,
    bool isDark,
    Widget child,
  ) {
    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MediasfuColors.primary.withOpacity(0.2),
                      MediasfuColors.secondary.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: MediasfuColors.primary,
                ),
              ),
              const SizedBox(width: MediasfuSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: MediasfuSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buildModernPicker({
    required String value,
    required Function(String) onValueChanged,
    required List<Map<String, dynamic>> items,
    required bool isDark,
  }) {
    return Container(
      decoration: MediasfuColors.dropdownDecoration(darkMode: isDark),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? MediasfuColors.primaryDark : MediasfuColors.primary,
          ),
          dropdownColor: MediasfuColors.dropdownBackground(darkMode: isDark),
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(
            horizontal: MediasfuSpacing.md,
            vertical: MediasfuSpacing.xs,
          ),
          onChanged: (newValue) {
            if (newValue != null) {
              onValueChanged(newValue);
            }
          },
          items: items.map((item) {
            final isSelected = item['value'] == value;
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Row(
                children: [
                  if (item['icon'] != null) ...[
                    Icon(
                      item['icon'],
                      size: 18,
                      color: isSelected
                          ? MediasfuColors.primary
                          : (isDark ? Colors.white60 : Colors.black45),
                    ),
                    const SizedBox(width: MediasfuSpacing.sm),
                  ],
                  Text(
                    item['label'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? MediasfuColors.primary
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch({
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
    required String enableLabel,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            enableLabel,
            style: TextStyle(
              fontSize: 13,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(width: MediasfuSpacing.md),
        ModernSwitch(
          value: value,
          onChanged: (v) => onChanged(v),
          isDarkMode: isDark,
          semanticLabel: '$enableLabel toggle',
        ),
      ],
    );
  }
}
