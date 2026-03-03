import 'package:flutter/material.dart';
import '../../types/types.dart'
    show
        ModifyDisplaySettingsOptions,
        TranslationMeta,
        ListenerTranslationPreferences,
        Participant;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../methods/display_settings_methods/modify_display_settings.dart'
    show
        modifyDisplaySettings,
        ModifyDisplaySettingsType,
        ModifyDisplaySettingsParameters;

abstract class DisplaySettingsModalParameters
    implements ModifyDisplaySettingsParameters {
  String get meetingDisplayType;
  bool get autoWave;
  bool get forceFullDisplay;
  bool get meetingVideoOptimized;

  // Translation properties
  ListenerTranslationPreferences? get listenerTranslationPreferences;
  Map<String, String>? get listenerTranslationOverrides;
  Map<String, TranslationMeta>? get translationProducerMap;
  Map<String, dynamic>? get speakerTranslationStates;
  Function(ListenerTranslationPreferences)?
      get updateListenerTranslationPreferences;
  Function(Map<String, String>)? get updateListenerTranslationOverrides;
  Function(Map<String, TranslationMeta>)? get updateTranslationProducerMap;
  Function(Map<String, dynamic>)? get updateSpeakerTranslationStates;
  String get member;
  String get islevel;
  String get roomName;
  List<Participant> get participants;

  // dynamic operator [](String key);
  // void operator []=(String key, dynamic value);
}

/// Configuration for the display-settings modal controlling participant-grid behavior.
///
/// * **onModifySettings** - Override for `modifyDisplaySettings`; receives {settings, parameters}. Applies changes to `meetingDisplayType`, `autoWave`, `forceFullDisplay`, `meetingVideoOptimized`.
/// * **parameters** - Must expose `meetingDisplayType` (current selection: `'video'`, `'media'`, or `'all'`), `autoWave`, `forceFullDisplay`, `meetingVideoOptimized`.
/// * **position** - Modal placement via `getModalPosition` (e.g., 'topRight').
/// * **backgroundColor** - Background color for modal container.
///
/// Compatible with [ModernDisplaySettingsModalOptions] from the modern component.
///
/// ### Usage
/// 1. "Display Option" dropdown: `'video'` = video-only participants, `'media'` = only those with active audio/video, `'all'` = everyone including listeners.
/// 2. "Display Audiographs" switch: enables waveform overlays on audio-only tiles.
/// 3. "Force Full Display" switch: prevents tile collapse for inactive participants.
/// 4. "Force Video Participants" switch: prioritizes video tiles in grid layout.
/// 5. Save button invokes `onModifySettings` with new values, updating `parameters`.
/// 6. Override via `MediasfuUICustomOverrides.displaySettingsModal` to inject analytics tracking, device-specific defaults, or custom display modes.
class DisplaySettingsModalOptions {
  final bool isVisible;
  final VoidCallback onClose;
  final ModifyDisplaySettingsType onModifySettings;
  final DisplaySettingsModalParameters parameters;
  final String position;
  final Color backgroundColor;

  /// Dark mode toggle for modern styling.
  /// Note: Pending modern implementation - placeholder for future glassmorphic UI.
  final bool isDarkMode;

  /// Enable glassmorphism effects for modern styling.
  /// Note: Pending modern implementation - placeholder for future glassmorphic UI.
  final bool enableGlassmorphism;

  /// Render mode for embedding in different contexts.
  /// - `modal`: Full modal with overlay, positioning, visibility wrapper (default)
  /// - `sidebar`: Content only, for embedding in sidebar panel
  /// - `inline`: Content only, no visibility check
  final ModalRenderMode renderMode;

  DisplaySettingsModalOptions({
    required this.isVisible,
    required this.onClose,
    this.onModifySettings = modifyDisplaySettings,
    required this.parameters,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFF83C0E9),
    this.isDarkMode = false,
    this.enableGlassmorphism = false,
    this.renderMode = ModalRenderMode.modal,
  });
}

typedef DisplaySettingsModalType = DisplaySettingsModal Function(
    {required DisplaySettingsModalOptions options});

/// `DisplaySettingsModalOptions` - Configuration options for the `DisplaySettingsModal`.
///
/// ### Properties:
/// - `isVisible`: Boolean to determine the visibility of the modal.
/// - `onClose`: Callback to close the modal.
/// - `onModifySettings`: Callback to apply changes in display settings.
/// - `parameters`: Current display settings as a `DisplaySettingsModalParameters` object.
/// - `position`: Position of the modal on the screen (default is 'topRight').
/// - `backgroundColor`: Background color of the modal (default is `Color(0xFF83C0E9)`).
///
/// ### Example Usage:
/// ```dart
/// DisplaySettingsModal(
///   options: DisplaySettingsModalOptions(
///     isVisible: true,
///     onClose: () => print("Modal closed"),
///     parameters: DisplaySettingsModalParametersImplementation(),
///   ),
/// );
/// ```

/// Display-settings modal controlling participant-grid composition and audiograph visibility.
///
/// * Dropdown: "Video Participants Only" (`meetingDisplayType = 'video'`), "Media
///   Participants Only" (`'media'`), "Show All Participants" (`'all'`).
/// * Three Switch toggles:
///   - **Display Audiographs** (`autoWave`): overlays waveform on audio-only tiles.
///   - **Force Full Display** (`forceFullDisplay`): prevents tile collapse for inactive participants.
///   - **Force Video Participants** (`meetingVideoOptimized`): prioritizes video tiles in grid.
/// * Save button constructs `ModifyDisplaySettingsOptions` and invokes `onModifySettings`,
///   which updates `parameters` and triggers re-layout of participant grids.
/// * Positions via `getModalPosition` using `options.position`.
///
/// Override via `MediasfuUICustomOverrides.displaySettingsModal` to inject analytics
/// tracking, device-specific defaults, or custom display modes (e.g., speaker-focused,
/// gallery-only, or accessibility-driven layouts).
class DisplaySettingsModal extends StatefulWidget {
  final DisplaySettingsModalOptions options;

  const DisplaySettingsModal({super.key, required this.options});

  @override
  _DisplaySettingsModalState createState() => _DisplaySettingsModalState();
}

class _DisplaySettingsModalState extends State<DisplaySettingsModal> {
  late String _meetingDisplayType;
  late bool _autoWave;
  late bool _forceFullDisplay;
  late bool _meetingVideoOptimized;

  @override
  void initState() {
    super.initState();
    _meetingDisplayType = widget.options.parameters.meetingDisplayType;
    _autoWave = widget.options.parameters.autoWave;
    _forceFullDisplay = widget.options.parameters.forceFullDisplay;
    _meetingVideoOptimized = widget.options.parameters.meetingVideoOptimized;
  }

  /// Builds the core content of the modal without visibility/positioning wrapper.
  Widget _buildContent(BuildContext context, {bool showCloseButton = true}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.options.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Display Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (showCloseButton)
                IconButton(
                  onPressed: widget.options.onClose,
                  icon: const Icon(Icons.close),
                  color: Colors.black,
                ),
            ],
          ),
          const Divider(color: Colors.black),
          _buildDropdownSetting(
            label: 'Display Option:',
            value: _meetingDisplayType,
            options: const ['video', 'media', 'all'],
            onChanged: (value) => setState(() => _meetingDisplayType = value),
          ),
          _buildSwitchSetting(
            label: 'Display Audiographs',
            value: _autoWave,
            onChanged: (value) => setState(() => _autoWave = value),
          ),
          _buildSwitchSetting(
            label: 'Force Full Display',
            value: _forceFullDisplay,
            onChanged: (value) => setState(() => _forceFullDisplay = value),
          ),
          _buildSwitchSetting(
            label: 'Force Video Participants',
            value: _meetingVideoOptimized,
            onChanged: (value) =>
                setState(() => _meetingVideoOptimized = value),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.options.parameters
                  .updateMeetingDisplayType(_meetingDisplayType);
              widget.options.parameters.updateAutoWave(_autoWave);
              widget.options.parameters
                  .updateForceFullDisplay(_forceFullDisplay);
              _forceFullDisplay;
              widget.options.parameters
                  .updateMeetingVideoOptimized(_meetingVideoOptimized);
              _meetingVideoOptimized;
              final optionsModify = ModifyDisplaySettingsOptions(
                  parameters: widget.options.parameters);
              widget.options.onModifySettings(
                optionsModify,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Full modal mode with visibility, positioning, and overlay
    final double screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = 0.8 * screenWidth;
    if (modalWidth > 400) {
      modalWidth = 400;
    }

    final modalHeight = MediaQuery.of(context).size.height * 0.65;

    return Visibility(
      visible: widget.options.isVisible,
      child: Stack(
        children: [
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
                context: context))['right'],
            child: Center(
              child: SizedBox(
                width: modalWidth,
                height: modalHeight,
                child: _buildContent(context, showCloseButton: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        DropdownButton<String>(
          value: value,
          onChanged: (newValue) => onChanged(newValue!),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option == 'video'
                  ? 'Video Participants Only'
                  : option == 'media'
                      ? 'Media Participants Only'
                      : 'Show All Participants'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
