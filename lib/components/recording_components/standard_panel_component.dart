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

/// Configuration options for [StandardPanelComponent].
///
/// Encapsulates recording configuration parameters and update callbacks for:
/// - **Media type selection:** Video or audio-only recording
/// - **Audio source filtering:** All participants, on-screen only, or host only
/// - **Video source filtering:** All videos or main screen (includes screenshare)
/// - **HLS streaming:** Enable/disable HTTP Live Streaming for live playback
///
/// **Properties:**
/// - `parameters` ([StandardPanelComponentParameters]): Recording configuration interface
///
/// **Key Callbacks (via parameters):**
/// - `updateRecordingMediaOptions(String)`: Updates "video" or "audio" selection
/// - `updateRecordingAudioOptions(String)`: Updates "all", "onScreen", or "host"
/// - `updateRecordingVideoOptions(String)`: Updates "all" or "mainScreen"
/// - `updateRecordingAddHLS(bool)`: Toggles HLS streaming
///
/// **Example:**
/// ```dart
/// StandardPanelComponentOptions(
///   parameters: RecordingParameters(
///     recordingMediaOptions: "video",
///     recordingAudioOptions: "all",
///     recordingVideoOptions: "mainScreen",
///     recordingAddHLS: true,
///     eventType: EventType.conference,
///     updateRecordingMediaOptions: (opt) => setState(() => mediaOpt = opt),
///     updateRecordingAudioOptions: (opt) => setState(() => audioOpt = opt),
///     updateRecordingVideoOptions: (opt) => setState(() => videoOpt = opt),
///     updateRecordingAddHLS: (hls) => setState(() => enableHLS = hls),
///   ),
/// )
/// ```
class StandardPanelComponentOptions {
  final StandardPanelComponentParameters parameters;

  StandardPanelComponentOptions({required this.parameters});
}

typedef StandardPanelType = Widget Function(
    {required StandardPanelComponentOptions options});

/// A stateless widget rendering a standard recording configuration panel.
///
/// Displays 3-4 dropdown pickers for configuring basic recording settings. Provides
/// simplified recording options suitable for most event types, hiding advanced controls
/// like layout/orientation/naming that power users need.
///
/// **Form Fields:**
/// 1. **Media Options (always visible):**
///    - "Record Video" (value: "video")
///    - "Record Audio Only" (value: "audio")
///
/// 2. **Specific Audios (hidden for EventType.broadcast):**
///    - "Add All" (value: "all") - Records all participant audio
///    - "Add All On Screen" (value: "onScreen") - Records only visible participants
///    - "Add Host Only" (value: "host") - Records only host audio
///
/// 3. **Specific Videos (hidden for EventType.broadcast):**
///    - "Add All" (value: "all") - Records all video streams
///    - "Big Screen Only (includes screenshare)" (value: "mainScreen") - Records main view + screenshare
///
/// 4. **Add HLS (always visible):**
///    - "True" (value: "true") - Enables HTTP Live Streaming for live playback
///    - "False" (value: "false") - Disables HLS (recording only)
///
/// **Rendering Structure:**
/// ```
/// Column (crossAxisAlignment: start)
///   ├─ Column (Media Options)
///   │  ├─ Text ("Media Options:", bold)
///   │  ├─ _buildPicker (video/audio)
///   │  └─ SizedBox (10px height)
///   ├─ [if eventType != broadcast]
///   │  ├─ Column (Specific Audios)
///   │  │  ├─ Text ("Specific Audios:", bold)
///   │  │  ├─ _buildPicker (all/onScreen/host)
///   │  │  └─ SizedBox (10px height)
///   │  └─ Column (Specific Videos)
///   │     ├─ Text ("Specific Videos:", bold)
///   │     ├─ _buildPicker (all/mainScreen)
///   │     └─ SizedBox (10px height)
///   └─ Column (Add HLS)
///      ├─ Text ("Add HLS:", bold)
///      └─ _buildPicker (true/false)
/// ```
///
/// **EventType Filtering:**
/// - `EventType.broadcast`: Hides "Specific Audios" and "Specific Videos"
///   (broadcaster controls all sources, no participant filtering needed)
/// - `EventType.conference/webinar/chat`: Shows all 4 fields
///
/// **Common Use Cases:**
/// 1. **Basic Video Recording (Conference):**
///    ```dart
///    StandardPanelComponent(
///      options: StandardPanelComponentOptions(
///        parameters: RecordingParams(
///          recordingMediaOptions: "video",
///          recordingAudioOptions: "all",
///          recordingVideoOptions: "all",
///          recordingAddHLS: false,
///          eventType: EventType.conference,
///          updateRecordingMediaOptions: (opt) => setState(() => _mediaOpt = opt),
///          updateRecordingAudioOptions: (opt) => setState(() => _audioOpt = opt),
///          updateRecordingVideoOptions: (opt) => setState(() => _videoOpt = opt),
///          updateRecordingAddHLS: (hls) => setState(() => _enableHLS = hls),
///        ),
///      ),
///    )
///    ```
///
/// 2. **Audio-Only Recording (Podcast Mode):**
///    ```dart
///    StandardPanelComponent(
///      options: StandardPanelComponentOptions(
///        parameters: RecordingParams(
///          recordingMediaOptions: "audio",
///          recordingAudioOptions: "all",
///          recordingVideoOptions: "mainScreen", // ignored for audio-only
///          recordingAddHLS: false,
///          eventType: EventType.conference,
///          updateRecordingMediaOptions: (opt) => updateState(opt),
///          updateRecordingAudioOptions: (opt) => updateState(opt),
///          updateRecordingVideoOptions: (opt) => updateState(opt),
///          updateRecordingAddHLS: (hls) => updateState(hls),
///        ),
///      ),
///    )
///    // Result: Audio-only MP3/M4A with all participant audio mixed
///    ```
///
/// 3. **Webinar Recording with HLS:**
///    ```dart
///    StandardPanelComponent(
///      options: StandardPanelComponentOptions(
///        parameters: RecordingParams(
///          recordingMediaOptions: "video",
///          recordingAudioOptions: "host", // only host audio
///          recordingVideoOptions: "mainScreen", // main view + slides
///          recordingAddHLS: true, // enable live streaming
///          eventType: EventType.webinar,
///          updateRecordingMediaOptions: updateMedia,
///          updateRecordingAudioOptions: updateAudio,
///          updateRecordingVideoOptions: updateVideo,
///          updateRecordingAddHLS: updateHLS,
///        ),
///      ),
///    )
///    // Result: Video recording with host audio, main screen, and HLS stream
///    ```
///
/// 4. **Broadcast Recording (Simplified):**
///    ```dart
///    StandardPanelComponent(
///      options: StandardPanelComponentOptions(
///        parameters: RecordingParams(
///          recordingMediaOptions: "video",
///          recordingAudioOptions: "all", // not shown in UI
///          recordingVideoOptions: "all", // not shown in UI
///          recordingAddHLS: true,
///          eventType: EventType.broadcast,
///          updateRecordingMediaOptions: (opt) => _updateSettings(opt),
///          updateRecordingAudioOptions: (_) {}, // no-op
///          updateRecordingVideoOptions: (_) {}, // no-op
///          updateRecordingAddHLS: (hls) => _updateSettings(hls),
///        ),
///      ),
///    )
///    // Only shows "Media Options" and "Add HLS" (no participant filtering)
///    ```
///
/// **Update Callbacks:**
/// - Invoked immediately when user changes dropdown selection
/// - Should update parent state to reflect new recording configuration
/// - Parent component typically stores these in MediasfuParameters for later use
/// - Changes not persisted until "Confirm" button clicked in RecordingModal
///
/// **HLS Streaming:**
/// - When `recordingAddHLS: true`, server generates .m3u8 playlist
/// - Allows live playback while recording is in progress
/// - Increases server load and storage costs
/// - Typically used for webinars, broadcasts, or large events
///
/// **Picker Implementation:**
/// - Uses custom `_buildPicker()` helper with `DropdownButton`
/// - Border radius: 10px
/// - Padding: 8px vertical, 12px horizontal
/// - Light gray background (0xFFE0E0E0)
/// - Full-width dropdown
///
/// **Styling:**
/// - Label font: Bold, black, 1.5 line height
/// - Field spacing: 10px between sections
/// - Cross-axis alignment: Start (left-aligned)
///
/// **Typical Usage Context:**
/// - RecordingModal "Standard" tab
/// - Quick recording setup for non-technical hosts
/// - Default recording configuration before switching to advanced panel
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
