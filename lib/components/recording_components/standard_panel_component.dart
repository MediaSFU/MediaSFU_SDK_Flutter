import 'package:flutter/material.dart';
import '../../types/types.dart' show EventType;

// Define StandardPanelComponentParameters as an abstract class with getters and setters
abstract class StandardPanelComponentParameters {
  String get recordingMediaOptions;
  String get recordingAudioOptions;
  String get recordingVideoOptions;
  bool get recordingAddHLS;
  EventType get eventType;

  void Function(String) get updateRecordingMediaOptions;
  void Function(String) get updateRecordingAudioOptions;
  void Function(String) get updateRecordingVideoOptions;
  void Function(bool) get updateRecordingAddHLS;
}

class StandardPanelComponentOptions {
  final StandardPanelComponentParameters parameters;

  StandardPanelComponentOptions({required this.parameters});
}

typedef StandardPanelType = Widget Function(
    {required StandardPanelComponentOptions options});

/// `StandardPanelComponent` displays a form with recording options, including:
/// - Media Options: Selects the type of recording (audio or video).
/// - Specific Audios and Videos: Configures specific recording preferences for
///   audio and video based on the event type.
/// - Add HLS: Optionally adds HLS (HTTP Live Streaming).
///
/// ### Parameters:
/// - [options] (`StandardPanelComponentOptions`): Options object containing parameters:
///   - `recordingMediaOptions` (String): Selected media recording type.
///   - `recordingAudioOptions` (String): Specific audio configuration.
///   - `recordingVideoOptions` (String): Specific video configuration.
///   - `recordingAddHLS` (bool): Enables or disables HLS streaming.
///   - `eventType` (EventType): Type of the event for filtering options.
///
/// ### Example:
/// ```dart
/// StandardPanelComponent(
///   options: StandardPanelComponentOptions(
///     parameters: MyStandardPanelComponentParameters(
///       recordingMediaOptions: "video",
///       recordingAudioOptions: "all",
///       recordingVideoOptions: "mainScreen",
///       recordingAddHLS: true,
///       eventType: EventType.conference,
///       updateRecordingMediaOptions: (option) => print("Media option updated: $option"),
///       updateRecordingAudioOptions: (option) => print("Audio option updated: $option"),
///       updateRecordingVideoOptions: (option) => print("Video option updated: $option"),
///       updateRecordingAddHLS: (enabled) => print("HLS enabled: $enabled"),
///     ),
///   ),
/// );
/// ```
///
/// This example initializes the component with default settings for a conference event.

class StandardPanelComponent extends StatelessWidget {
  final StandardPanelComponentOptions options;

  const StandardPanelComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    const TextStyle labelStyle = TextStyle(
      color: Colors.black,
      height: 1.5,
      fontWeight: FontWeight.bold,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Media Options
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Media Options:', style: labelStyle),
            _buildPicker(
              value: options.parameters.recordingMediaOptions,
              onValueChanged: (value) =>
                  options.parameters.updateRecordingMediaOptions(value),
              items: [
                {'label': 'Record Video', 'value': 'video'},
                {'label': 'Record Audio Only', 'value': 'audio'},
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),

        // Specific Audios
        if (options.parameters.eventType != EventType.broadcast) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Specific Audios:', style: labelStyle),
              _buildPicker(
                value: options.parameters.recordingAudioOptions,
                onValueChanged: (value) =>
                    options.parameters.updateRecordingAudioOptions(value),
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
                value: options.parameters.recordingVideoOptions,
                onValueChanged: (value) =>
                    options.parameters.updateRecordingVideoOptions(value),
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
              value: options.parameters.recordingAddHLS.toString(),
              onValueChanged: (value) => options.parameters
                  .updateRecordingAddHLS(value == 'true' || value == true),
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
          margin: const EdgeInsets.symmetric(vertical: 5),
        ),
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
