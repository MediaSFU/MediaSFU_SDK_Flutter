import 'package:flutter/material.dart';
import '../../types/types.dart' show ModifyDisplaySettingsOptions;
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

  // dynamic operator [](String key);
  // void operator []=(String key, dynamic value);
}

/// DisplaySettingsModalOptions - Configuration options for the `DisplaySettingsModal`.
class DisplaySettingsModalOptions {
  final bool isVisible;
  final VoidCallback onClose;
  final ModifyDisplaySettingsType onModifySettings;
  final DisplaySettingsModalParameters parameters;
  final String position;
  final Color backgroundColor;

  DisplaySettingsModalOptions({
    required this.isVisible,
    required this.onClose,
    this.onModifySettings = modifyDisplaySettings,
    required this.parameters,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFF83C0E9),
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

/// `DisplaySettingsModal` - A modal widget for adjusting display settings.
///
/// This widget allows users to set display preferences for a meeting or event, including display options,
/// enabling/disabling audiographs, forcing full display, and optimizing video participant visibility.
///
/// ### Parameters:
/// - `options` (`DisplaySettingsModalOptions`): Configuration options for the modal.
///
/// ### Structure:
/// - Modal header with title ("Display Settings") and close button.
/// - Dropdown selector for `Display Option` with values: Video Participants Only, Media Participants Only, and Show All Participants.
/// - Switch toggles for settings:
///     - `Display Audiographs`
///     - `Force Full Display`
///     - `Force Video Participants`
/// - Save button to apply the selected display settings.
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

  @override
  Widget build(BuildContext context) {
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
              child: Container(
                width: modalWidth,
                height: modalHeight,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.options.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      onChanged: (value) =>
                          setState(() => _meetingDisplayType = value),
                    ),
                    _buildSwitchSetting(
                      label: 'Display Audiographs',
                      value: _autoWave,
                      onChanged: (value) => setState(() => _autoWave = value),
                    ),
                    _buildSwitchSetting(
                      label: 'Force Full Display',
                      value: _forceFullDisplay,
                      onChanged: (value) =>
                          setState(() => _forceFullDisplay = value),
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
                        widget.options.parameters.updateMeetingVideoOptimized(
                            _meetingVideoOptimized);
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
