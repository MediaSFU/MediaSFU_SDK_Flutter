import 'package:flutter/material.dart';

/// StandardPanelComponent is a StatelessWidget that represents a standard panel for recording settings.
///
/// `parameters`: Additional parameters for recording settings.

class StandardPanelComponent extends StatelessWidget {
  final Map<String, dynamic> parameters;

  const StandardPanelComponent({super.key, required this.parameters});

  @override
  Widget build(BuildContext context) {
    final String recordingMediaOptions = parameters['recordingMediaOptions'];
    final String recordingAudioOptions = parameters['recordingAudioOptions'];
    final String recordingVideoOptions = parameters['recordingVideoOptions'];
    final bool recordingAddHLS = parameters['recordingAddHLS'];
    final Function updateRecordingMediaOptions =
        parameters['updateRecordingMediaOptions'];
    final Function updateRecordingAudioOptions =
        parameters['updateRecordingAudioOptions'];
    final Function updateRecordingVideoOptions =
        parameters['updateRecordingVideoOptions'];
    final Function updateRecordingAddHLS = parameters['updateRecordingAddHLS'];
    final String eventType = parameters['eventType'];

    const TextStyle labelStyle = TextStyle(
        color: Colors.black, height: 1.5, fontWeight: FontWeight.bold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Media Options
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Media Options:', style: labelStyle),
            _buildPicker(
              value: recordingMediaOptions,
              onValueChanged: (value) => updateRecordingMediaOptions(value),
              items: [
                {'label': 'Record Video', 'value': 'video'},
                {'label': 'Record Audio Only', 'value': 'audio'},
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),

        // Specific Audios
        if (eventType != 'broadcast') ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Specific Audios:', style: labelStyle),
              _buildPicker(
                value: recordingAudioOptions,
                onValueChanged: (value) => updateRecordingAudioOptions(value),
                items: [
                  {'label': 'Add All', 'value': 'all'},
                  {'label': 'Add All On Screen', 'value': 'onScreen'},
                  {'label': 'Add Host Only', 'value': 'host'},
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),

          // Specific Videos
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Specific Videos:', style: labelStyle),
              _buildPicker(
                value: recordingVideoOptions,
                onValueChanged: (value) => updateRecordingVideoOptions(value),
                items: [
                  {'label': 'Add All', 'value': 'all'},
                  {
                    'label': 'Big Screen Only (includes screenshare)',
                    'value': 'mainScreen'
                  },
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],

        // Add HLS
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add HLS:', style: labelStyle),
            _buildPicker(
              value: recordingAddHLS.toString(),
              onValueChanged: (value) =>
                  updateRecordingAddHLS(value == 'true' || value == true),
              items: [
                {'label': 'True', 'value': 'true'},
                {'label': 'False', 'value': 'false'},
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),

        // Separator
        Container(
            height: 1,
            color: Colors.black,
            margin: const EdgeInsets.symmetric(vertical: 5)),
      ],
    );
  }

  Widget _buildPicker({
    required String value,
    required Function(dynamic) onValueChanged,
    required List<Map<String, dynamic>> items,
  }) {
    // Check for duplicate values and count occurrences of current value
    final uniqueItems = items.toSet().toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: DropdownButtonHideUnderline(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: DropdownButton(
                value: value,
                onChanged: onValueChanged,
                items: uniqueItems
                    .map((item) => DropdownMenuItem(
                          value: item['value'],
                          child: Text(item['label']),
                        ))
                    .toList(),
                // Wrap DropdownButton with Expanded to constrain width
                // to prevent horizontal overflow
                isExpanded: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
