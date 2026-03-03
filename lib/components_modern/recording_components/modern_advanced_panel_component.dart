import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../components/recording_components/advanced_panel_component.dart'
    show AdvancedPanelComponentParameters;
import '../../types/types.dart' show EventType;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/widgets/modern_switch.dart';

/// Configuration options for ModernAdvancedPanelComponent.
/// Uses the same [AdvancedPanelComponentParameters] as the original component.
class ModernAdvancedPanelComponentOptions {
  final AdvancedPanelComponentParameters parameters;

  // Modern styling options
  final bool enableGlassmorphism;
  final bool isDarkMode;

  ModernAdvancedPanelComponentOptions({
    required this.parameters,
    this.enableGlassmorphism = true,
    this.isDarkMode = true,
  });
}

typedef ModernAdvancedPanelType = Widget Function({
  required ModernAdvancedPanelComponentOptions options,
});

/// A modern advanced recording configuration panel with glassmorphic styling.
///
/// Features:
/// - Glassmorphic color pickers
/// - Modern toggle switches
/// - Gradient accents
/// - Smooth animations
/// - Dark/light mode support
class ModernAdvancedPanelComponent extends StatefulWidget {
  final ModernAdvancedPanelComponentOptions options;

  const ModernAdvancedPanelComponent({super.key, required this.options});

  @override
  State<ModernAdvancedPanelComponent> createState() =>
      _ModernAdvancedPanelComponentState();
}

class _ModernAdvancedPanelComponentState
    extends State<ModernAdvancedPanelComponent> {
  late AdvancedPanelComponentParameters parameters;
  late TextEditingController customTextController;
  late Map<String, Color> parsedColors;
  late String recordingText;
  late String selectedOrientationVideo;

  @override
  void initState() {
    super.initState();
    parameters = widget.options.parameters;
    customTextController =
        TextEditingController(text: parameters.recordingCustomText);
    parsedColors = {
      'backgroundColor': _parseColor(parameters.recordingBackgroundColor),
      'customTextColor': _parseColor(parameters.recordingCustomTextColor),
      'nameTagsColor': _parseColor(parameters.recordingNameTagsColor),
    };
    recordingText = parameters.recordingAddText.toString();
    selectedOrientationVideo = parameters.recordingOrientationVideo;
  }

  Color _parseColor(String colorString) {
    return colorString.startsWith('#')
        ? Color(int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000)
        : Colors.transparent;
  }

  @override
  void didUpdateWidget(ModernAdvancedPanelComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (parameters.recordingCustomText != customTextController.text) {
      customTextController.text = parameters.recordingCustomText;
    }
  }

  @override
  void dispose() {
    customTextController.dispose();
    super.dispose();
  }

  void _showColorPickerDialog(String colorType) {
    Color selectedColor = parsedColors[colorType] ?? Colors.white;
    Color tempColor = selectedColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = widget.options.isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Select Color',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                tempColor = color;
              },
              enableAlpha: false,
              // ignore: deprecated_member_use
              showLabel: false,
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black45,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [MediasfuColors.primary, MediasfuColors.secondary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  _onSelectColor(colorType, tempColor);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Apply',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onSelectColor(String colorType, Color color) {
    // ignore: deprecated_member_use
    String colorHex =
        color.value.toRadixString(16).padLeft(8, '0').substring(2);
    String colorString = '#$colorHex';

    if (mounted) {
      setState(() {
        parsedColors[colorType] = color;
      });
    }

    switch (colorType) {
      case 'backgroundColor':
        parameters.updateRecordingBackgroundColor(colorString);
        break;
      case 'customTextColor':
        parameters.updateRecordingCustomTextColor(colorString);
        break;
      case 'nameTagsColor':
        parameters.updateRecordingNameTagsColor(colorString);
        break;
    }
  }

  bool validateTextInput(String input) {
    RegExp regex = RegExp(r'^[a-zA-Z0-9\s]{1,40}$');
    return regex.hasMatch(input);
  }

  void onChangeTextHandler(String text) {
    if (text.isNotEmpty && !validateTextInput(text)) {
      customTextController.text = parameters.recordingCustomText;
      return;
    }
    parameters.updateRecordingCustomText(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.options.isDarkMode;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Type
          _buildSection(
            label: 'Video Layout',
            icon: Icons.view_quilt_rounded,
            isDark: isDark,
            child: _buildModernPicker(
              value: parameters.recordingVideoType,
              onValueChanged: (value) =>
                  parameters.updateRecordingVideoType(value),
              items: [
                {
                  'label': 'Full Display (no background)',
                  'value': 'fullDisplay',
                  'icon': Icons.fullscreen
                },
                {
                  'label': 'Best Display',
                  'value': 'bestDisplay',
                  'icon': Icons.aspect_ratio
                },
                {'label': 'All', 'value': 'all', 'icon': Icons.grid_view},
              ],
              isDark: isDark,
            ),
          ),
          const SizedBox(height: MediasfuSpacing.md),

          // Display Type
          if (parameters.eventType != EventType.broadcast) ...[
            _buildSection(
              label: 'Display Type',
              icon: Icons.display_settings_rounded,
              isDark: isDark,
              child: _buildModernPicker(
                value: parameters.recordingDisplayType,
                onValueChanged: (value) =>
                    parameters.updateRecordingDisplayType(value),
                items: [
                  {
                    'label': 'Video Only',
                    'value': 'video',
                    'icon': Icons.videocam
                  },
                  {
                    'label': 'Video (Optimized)',
                    'value': 'videoOpt',
                    'icon': Icons.auto_fix_high
                  },
                  {
                    'label': 'With Media',
                    'value': 'media',
                    'icon': Icons.perm_media
                  },
                  {
                    'label': 'All Participants',
                    'value': 'all',
                    'icon': Icons.people
                  },
                ],
                isDark: isDark,
              ),
            ),
            const SizedBox(height: MediasfuSpacing.md),
          ],

          // Background Color
          _buildSection(
            label: 'Background Color',
            icon: Icons.palette_rounded,
            isDark: isDark,
            child: _buildColorButton(
              color: parsedColors['backgroundColor'] ?? Colors.black,
              isDark: isDark,
              onTap: () => _showColorPickerDialog('backgroundColor'),
            ),
          ),
          const SizedBox(height: MediasfuSpacing.md),

          // Orientation
          _buildSection(
            label: 'Video Orientation',
            icon: Icons.screen_rotation_rounded,
            isDark: isDark,
            child: _buildSegmentedControl(
              value: selectedOrientationVideo,
              options: ['landscape', 'portrait', 'all'],
              labels: ['Landscape', 'Portrait', 'All'],
              isDark: isDark,
              onChanged: (value) {
                parameters.updateRecordingOrientationVideo(value);
                setState(() {
                  selectedOrientationVideo = value;
                });
              },
            ),
          ),
          const SizedBox(height: MediasfuSpacing.md),

          // Name Tags
          _buildSection(
            label: 'Name Tags',
            icon: Icons.badge_rounded,
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToggleRow(
                  label: 'Show participant names',
                  value: parameters.recordingNameTags,
                  isDark: isDark,
                  onChanged: parameters.updateRecordingNameTags,
                ),
                if (parameters.recordingNameTags) ...[
                  const SizedBox(height: MediasfuSpacing.md),
                  _buildColorButton(
                    color: parsedColors['nameTagsColor'] ?? Colors.white,
                    isDark: isDark,
                    label: 'Tag Color',
                    onTap: () => _showColorPickerDialog('nameTagsColor'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: MediasfuSpacing.md),

          // Custom Text
          _buildSection(
            label: 'Custom Text Overlay',
            icon: Icons.text_fields_rounded,
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToggleRow(
                  label: 'Enable text overlay',
                  value: parameters.recordingAddText,
                  isDark: isDark,
                  onChanged: (value) {
                    parameters.updateRecordingAddText(value);
                    setState(() {
                      recordingText = value.toString();
                    });
                  },
                ),
                if (recordingText == 'true') ...[
                  const SizedBox(height: MediasfuSpacing.md),
                  _buildTextField(isDark),
                  const SizedBox(height: MediasfuSpacing.md),
                  _buildSegmentedControl(
                    value: parameters.recordingCustomTextPosition,
                    options: ['top', 'middle', 'bottom'],
                    labels: ['Top', 'Middle', 'Bottom'],
                    isDark: isDark,
                    onChanged: parameters.updateRecordingCustomTextPosition,
                  ),
                  const SizedBox(height: MediasfuSpacing.md),
                  _buildColorButton(
                    color: parsedColors['customTextColor'] ?? Colors.white,
                    isDark: isDark,
                    label: 'Text Color',
                    onTap: () => _showColorPickerDialog('customTextColor'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
      child: widget.options.enableGlassmorphism
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
                  Flexible(
                    child: Text(
                      item['label'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? MediasfuColors.primary
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildColorButton({
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    String? label,
  }) {
    // ignore: deprecated_member_use
    String colorHex =
        color.value.toRadixString(16).padLeft(8, '0').substring(2);
    String colorString = '#$colorHex';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MediasfuSpacing.md,
          vertical: MediasfuSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: MediasfuSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: (isDark ? Colors.white : Colors.black)
                            .withOpacity(0.6),
                      ),
                    ),
                  Text(
                    colorString.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.colorize_rounded,
              size: 20,
              color: MediasfuColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl({
    required String value,
    required List<String> options,
    required List<String> labels,
    required bool isDark,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = options[index] == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(options[index]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(vertical: MediasfuSpacing.sm),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            MediasfuColors.primary,
                            MediasfuColors.secondary
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black45),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required bool isDark,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.7),
            ),
          ),
        ),
        ModernSwitch(
          value: value,
          onChanged: (v) => onChanged(v),
          isDarkMode: isDark,
          semanticLabel: '$label toggle',
        ),
      ],
    );
  }

  Widget _buildTextField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: customTextController,
        onChanged: onChangeTextHandler,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
        maxLength: 40,
        decoration: InputDecoration(
          hintText: 'Enter custom text (max 40 chars)',
          hintStyle: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(MediasfuSpacing.md),
          counterText: '',
        ),
      ),
    );
  }
}
