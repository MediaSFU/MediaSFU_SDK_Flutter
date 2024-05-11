import 'package:flutter/material.dart';
import '../../methods/utils/get_modal_position.dart' show getModalPosition;
import '../../methods/display_settings_methods/modify_display_settings.dart'
    show modifyDisplaySettings;

/// DisplaySettingsModal - A modal widget for configuring display settings.
///
/// This widget allows users to modify various display settings such as display options,
/// audiograph visibility, and force full display settings.
///
/// Whether the display settings modal is visible.
///final bool isDisplaySettingsModalVisible;
///
/// A function called when the display settings modal is closed.
///final Function() onDisplaySettingsClose;
///
/// A function for modifying display settings.
///final Future<void> Function({required Map<String, dynamic> parameters}) onModifyDisplaySettings;
///
/// The parameters associated with the display settings.
///final Map<String, dynamic> parameters;
///
/// The position of the modal.
///final String position;
///
/// The background color of the modal.
///final Color backgroundColor;

class DisplaySettingsModal extends StatefulWidget {
  final bool isDisplaySettingsModalVisible;
  final Function() onDisplaySettingsClose;
  final Future<void> Function({required Map<String, dynamic> parameters})
      onModifyDisplaySettings;
  final Map<String, dynamic> parameters;
  final String position;
  final Color backgroundColor;

  const DisplaySettingsModal({
    super.key,
    required this.isDisplaySettingsModalVisible,
    required this.onDisplaySettingsClose,
    this.onModifyDisplaySettings = modifyDisplaySettings,
    required this.parameters,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFF83C0E9),
  });

  @override
  // ignore: library_private_types_in_public_api
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
    // Initialize local state variables with current parameter values
    _meetingDisplayType = widget.parameters['meetingDisplayType'];
    _autoWave = widget.parameters['autoWave'];
    _forceFullDisplay = widget.parameters['forceFullDisplay'];
    _meetingVideoOptimized = widget.parameters['meetingVideoOptimized'];
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
      visible: widget.isDisplaySettingsModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(
                widget.position, context, modalWidth, modalHeight)['top'],
            right: getModalPosition(
                widget.position, context, modalWidth, modalHeight)['right'],
            child: Center(
              child: Container(
                width: modalWidth,
                height: modalHeight,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
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
                        IconButton(
                          onPressed: widget.onDisplaySettingsClose,
                          icon: const Icon(Icons.close),
                          color: Colors.black,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Display Option Picker
                    const Text(
                      'Display Option:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    DropdownButton<String>(
                      value: _meetingDisplayType,
                      onChanged: (value) {
                        setState(() {
                          _meetingDisplayType = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'video',
                          child: Text('Video Participants Only'),
                        ),
                        DropdownMenuItem(
                          value: 'media',
                          child: Text('Media Participants Only'),
                        ),
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('Show All Participants'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Display Audiographs Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Display Audiographs',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Switch(
                          value: _autoWave,
                          onChanged: (value) {
                            setState(() {
                              _autoWave = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Force Full Display Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Force Full Display',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Switch(
                          value: _forceFullDisplay,
                          onChanged: (value) {
                            setState(() {
                              _forceFullDisplay = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Force Video Participants Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Force Video Participants',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Switch(
                          value: _meetingVideoOptimized,
                          onChanged: (value) {
                            setState(() {
                              _meetingVideoOptimized = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Save Button
                    ElevatedButton(
                      onPressed: () {
                        // On save, apply temporary changes to parameters and trigger the modification function
                        widget.onModifyDisplaySettings(
                          parameters: {
                            ...widget.parameters,
                            'meetingDisplayType': _meetingDisplayType,
                            'autoWave': _autoWave,
                            'forceFullDisplay': _forceFullDisplay,
                            'meetingVideoOptimized': _meetingVideoOptimized,
                          },
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
}
