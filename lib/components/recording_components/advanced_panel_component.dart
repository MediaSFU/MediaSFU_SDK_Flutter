import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../types/types.dart' show EventType;

// Abstract class for AdvancedPanel parameters
abstract class AdvancedPanelComponentParameters {
  String get recordingVideoType;
  String get recordingDisplayType;
  String get recordingBackgroundColor;
  String get recordingNameTagsColor;
  String get recordingOrientationVideo;
  bool get recordingNameTags;
  bool get recordingAddText;
  String get recordingCustomText;
  String get recordingCustomTextPosition;
  String get recordingCustomTextColor;
  EventType get eventType;

  void Function(String) get updateRecordingVideoType;
  void Function(String) get updateRecordingDisplayType;
  void Function(String) get updateRecordingBackgroundColor;
  void Function(String) get updateRecordingNameTagsColor;
  void Function(String) get updateRecordingOrientationVideo;
  void Function(bool) get updateRecordingNameTags;
  void Function(bool) get updateRecordingAddText;
  void Function(String) get updateRecordingCustomText;
  void Function(String) get updateRecordingCustomTextPosition;
  void Function(String) get updateRecordingCustomTextColor;
}

/// Configuration options for [AdvancedPanelComponent].
///
/// Encapsulates advanced recording configuration parameters and update callbacks for:
/// - **Video layout:** Full display (no background), full video, or all participants
/// - **Display filtering:** Video only, video (optimized), media, or all participants
/// - **Visual customization:** Background color, name tags color, custom text overlay
/// - **Orientation:** Landscape or portrait video orientation
/// - **Text overlay:** Custom text with position and color configuration
///
/// **Properties:**
/// - `parameters` ([AdvancedPanelComponentParameters]): Advanced recording configuration interface
///
/// **Key Callbacks (via parameters):**
/// - `updateRecordingVideoType(String)`: Updates "fullDisplay", "bestDisplay", or "all"
/// - `updateRecordingDisplayType(String)`: Updates "video", "videoOpt", "media", or "all"
/// - `updateRecordingBackgroundColor(String)`: Updates hex color (e.g., "#000000")
/// - `updateRecordingNameTagsColor(String)`: Updates name tag hex color
/// - `updateRecordingOrientationVideo(String)`: Updates "landscape" or "portrait"
/// - `updateRecordingNameTags(bool)`: Toggles participant name overlays
/// - `updateRecordingAddText(bool)`: Toggles custom text overlay
/// - `updateRecordingCustomText(String)`: Updates custom text (max 40 alphanumeric chars)
/// - `updateRecordingCustomTextPosition(String)`: Updates "top", "middle", or "bottom"
/// - `updateRecordingCustomTextColor(String)`: Updates custom text hex color
///
/// **Example:**
/// ```dart
/// AdvancedPanelComponentOptions(
///   parameters: RecordingParameters(
///     recordingVideoType: "bestDisplay",
///     recordingDisplayType: "videoOpt",
///     recordingBackgroundColor: "#1a1a1a",
///     recordingNameTagsColor: "#ffffff",
///     recordingOrientationVideo: "landscape",
///     recordingNameTags: true,
///     recordingAddText: true,
///     recordingCustomText: "Company Webinar 2024",
///     recordingCustomTextPosition: "bottom",
///     recordingCustomTextColor: "#00ff00",
///     eventType: EventType.webinar,
///     updateRecordingVideoType: (type) => setState(() => _videoType = type),
///     updateRecordingDisplayType: (type) => setState(() => _displayType = type),
///     updateRecordingBackgroundColor: (color) => setState(() => _bgColor = color),
///     updateRecordingNameTagsColor: (color) => setState(() => _nameColor = color),
///     updateRecordingOrientationVideo: (orientation) => setState(() => _orientation = orientation),
///     updateRecordingNameTags: (enable) => setState(() => _showNames = enable),
///     updateRecordingAddText: (enable) => setState(() => _showText = enable),
///     updateRecordingCustomText: (text) => setState(() => _customText = text),
///     updateRecordingCustomTextPosition: (pos) => setState(() => _textPos = pos),
///     updateRecordingCustomTextColor: (color) => setState(() => _textColor = color),
///   ),
/// )
/// ```
class AdvancedPanelComponentOptions {
  final AdvancedPanelComponentParameters parameters;

  AdvancedPanelComponentOptions({required this.parameters});
}

typedef AdvancedPanelType = Widget Function(
    {required AdvancedPanelComponentOptions options});

/// A stateful widget rendering an advanced recording configuration panel.
///
/// Displays 6-10 configuration fields for fine-tuning recording visual appearance,
/// layout composition, and text overlays. Provides color pickers, text input validation,
/// and conditional field visibility based on user selections.
///
/// **Form Fields:**
/// 1. **Video Type (always visible):**
///    - "Full Display (no background)" (value: "fullDisplay") - Tight crop with no empty space
///    - "Full Video" (value: "bestDisplay") - Optimized full-frame video
///    - "All" (value: "all") - All participants in grid
///
/// 2. **Display Type (hidden for EventType.broadcast):**
///    - "Only Video Participants" (value: "video") - Participants with video enabled
///    - "Only Video Participants (optimized)" (value: "videoOpt") - Optimized video-only layout
///    - "Participants with media" (value: "media") - Participants with video or screenshare
///    - "All Participants" (value: "all") - Everyone including audio-only
///
/// 3. **Background Color (always visible):**
///    - Color picker button showing current hex color
///    - Opens ColorPicker dialog from flutter_colorpicker package
///
/// 4. **Add Text (always visible):**
///    - "True" (value: "true") - Enable custom text overlay
///    - "False" (value: "false") - Disable text overlay
///
/// 5. **Custom Text (visible if recordingAddText == true):**
///    - TextFormField with alphanumeric validation (max 40 chars)
///    - RegExp: `^[a-zA-Z0-9\s]{1,40}$`
///    - Invalid input reverts to previous value
///
/// 6. **Custom Text Position (visible if recordingAddText == true):**
///    - "Top" (value: "top") - Text at top of frame
///    - "Middle" (value: "middle") - Centered text
///    - "Bottom" (value: "bottom") - Text at bottom
///
/// 7. **Custom Text Color (visible if recordingAddText == true):**
///    - Color picker for text overlay color
///
/// 8. **Add Name Tags (always visible):**
///    - "True" (value: "true") - Show participant names on videos
///    - "False" (value: "false") - Hide name overlays
///
/// 9. **Name Tags Color (visible if recordingNameTags == true):**
///    - Color picker for name tag background/text color
///
/// 10. **Orientation Video (always visible):**
///     - "Landscape" (value: "landscape") - 16:9 widescreen
///     - "Portrait" (value: "portrait") - 9:16 vertical
///
/// **Rendering Structure:**
/// ```
/// Column (crossAxisAlignment: start)
///   ├─ buildPicker (Video Type)
///   ├─ SizedBox (15px)
///   ├─ [if eventType != broadcast] buildPicker (Display Type)
///   ├─ SizedBox (15px)
///   ├─ buildColorPicker (Background Color)
///   ├─ SizedBox (15px)
///   ├─ buildPicker (Add Text: true/false)
///   ├─ SizedBox (15px)
///   ├─ [if recordingAddText]
///   │  ├─ buildCustomText() (TextFormField)
///   │  ├─ buildPicker (Custom Text Position)
///   │  ├─ buildColorPicker (Custom Text Color)
///   │  └─ SizedBox (15px)
///   ├─ buildPicker (Add Name Tags: true/false)
///   ├─ [if recordingNameTags]
///   │  ├─ buildColorPicker (Name Tags Color)
///   │  └─ SizedBox (15px)
///   └─ buildPicker (Orientation Video)
/// ```
///
/// **State Management:**
/// - `parsedColors`: `Map<String, Color>` storing parsed hex colors for pickers
/// - `customTextController`: TextEditingController for custom text input
/// - `showBackgroundColorModal`: bool for background color picker visibility
/// - `showCustomTextColorModal`: bool for text color picker visibility
/// - `showNameTagsColorModal`: bool for name tags color picker visibility
/// - `selectedColorType`: String tracking which color picker is active
/// - `recordingText`: String mirroring `recordingAddText` for conditional rendering
///
/// **Common Use Cases:**
/// 1. **Professional Webinar Recording:**
///    ```dart
///    AdvancedPanelComponent(
///      options: AdvancedPanelComponentOptions(
///        parameters: RecordingParams(
///          recordingVideoType: "bestDisplay",
///          recordingDisplayType: "video",
///          recordingBackgroundColor: "#1a1a1a",
///          recordingNameTagsColor: "#ffffff",
///          recordingOrientationVideo: "landscape",
///          recordingNameTags: true,
///          recordingAddText: true,
///          recordingCustomText: "Q4 Sales Review",
///          recordingCustomTextPosition: "bottom",
///          recordingCustomTextColor: "#00bfff",
///          eventType: EventType.webinar,
///          updateRecordingVideoType: (type) => _updateState(type),
///          updateRecordingDisplayType: (type) => _updateState(type),
///          updateRecordingBackgroundColor: (color) => _updateState(color),
///          updateRecordingNameTagsColor: (color) => _updateState(color),
///          updateRecordingOrientationVideo: (orientation) => _updateState(orientation),
///          updateRecordingNameTags: (enable) => _updateState(enable),
///          updateRecordingAddText: (enable) => _updateState(enable),
///          updateRecordingCustomText: (text) => _updateState(text),
///          updateRecordingCustomTextPosition: (pos) => _updateState(pos),
///          updateRecordingCustomTextColor: (color) => _updateState(color),
///        ),
///      ),
///    )
///    // Result: Landscape recording with blue "Q4 Sales Review" at bottom, white name tags
///    ```
///
/// 2. **Portrait Social Media Recording:**
///    ```dart
///    AdvancedPanelComponent(
///      options: AdvancedPanelComponentOptions(
///        parameters: RecordingParams(
///          recordingVideoType: "fullDisplay",
///          recordingDisplayType: "videoOpt",
///          recordingBackgroundColor: "#000000",
///          recordingNameTagsColor: "#ff6b6b",
///          recordingOrientationVideo: "portrait",
///          recordingNameTags: true,
///          recordingAddText: true,
///          recordingCustomText: "@YourBrand",
///          recordingCustomTextPosition: "top",
///          recordingCustomTextColor: "#ffffff",
///          eventType: EventType.conference,
///          updateRecordingVideoType: updateVidType,
///          updateRecordingDisplayType: updateDispType,
///          updateRecordingBackgroundColor: updateBgColor,
///          updateRecordingNameTagsColor: updateNameColor,
///          updateRecordingOrientationVideo: updateOrientation,
///          updateRecordingNameTags: updateNameTags,
///          updateRecordingAddText: updateAddText,
///          updateRecordingCustomText: updateCustomText,
///          updateRecordingCustomTextPosition: updateTextPos,
///          updateRecordingCustomTextColor: updateTextColor,
///        ),
///      ),
///    )
///    // Result: 9:16 portrait with "@YourBrand" at top, coral name tags, black background
///    ```
///
/// 3. **Minimal Recording (No Overlays):**
///    ```dart
///    AdvancedPanelComponent(
///      options: AdvancedPanelComponentOptions(
///        parameters: RecordingParams(
///          recordingVideoType: "bestDisplay",
///          recordingDisplayType: "video",
///          recordingBackgroundColor: "#ffffff",
///          recordingNameTagsColor: "#000000",
///          recordingOrientationVideo: "landscape",
///          recordingNameTags: false, // no names
///          recordingAddText: false, // no text
///          recordingCustomText: "",
///          recordingCustomTextPosition: "bottom",
///          recordingCustomTextColor: "#000000",
///          eventType: EventType.conference,
///          updateRecordingVideoType: (type) => updateSettings(type),
///          updateRecordingDisplayType: (type) => updateSettings(type),
///          updateRecordingBackgroundColor: (color) => updateSettings(color),
///          updateRecordingNameTagsColor: (color) => updateSettings(color),
///          updateRecordingOrientationVideo: (orientation) => updateSettings(orientation),
///          updateRecordingNameTags: (enable) => updateSettings(enable),
///          updateRecordingAddText: (enable) => updateSettings(enable),
///          updateRecordingCustomText: (text) => updateSettings(text),
///          updateRecordingCustomTextPosition: (pos) => updateSettings(pos),
///          updateRecordingCustomTextColor: (color) => updateSettings(color),
///        ),
///      ),
///    )
///    // Result: Clean landscape recording with white background, no overlays
///    ```
///
/// **Color Picker Implementation:**
/// - Uses flutter_colorpicker package (ColorPicker widget)
/// - Opens AlertDialog with color picker on button tap
/// - Persists color selection via update callback
/// - Parses hex strings to Color objects using `_parseColor()`
/// - Updates `parsedColors` map for reactive UI
///
/// **Text Input Validation:**
/// - `validateTextInput()`: RegExp `^[a-zA-Z0-9\s]{1,40}$`
/// - Allows: letters, numbers, spaces
/// - Max length: 40 characters
/// - Invalid input: reverts to previous value (no update)
/// - Prevents special characters, emojis, or overflow
///
/// **EventType Filtering:**
/// - `EventType.broadcast`: Hides "Display Type" (broadcaster controls all sources)
/// - `EventType.conference/webinar/chat`: Shows all fields
///
/// **Update Callbacks:**
/// - Invoked immediately when user changes dropdown/color/text
/// - Should update parent state (typically MediasfuParameters)
/// - Changes not persisted until "Confirm" button clicked in RecordingModal
/// - Color callbacks receive hex strings (e.g., "#1a2b3c")
///
/// **Typical Usage Context:**
/// - RecordingModal "Advanced" tab
/// - Power user recording customization
/// - Brand-consistent recording styling
/// - Custom overlay text for branding/disclaimers
class AdvancedPanelComponent extends StatefulWidget {
  final AdvancedPanelComponentOptions options;

  const AdvancedPanelComponent({super.key, required this.options});

  @override
  _AdvancedPanelComponentState createState() => _AdvancedPanelComponentState();
}

class _AdvancedPanelComponentState extends State<AdvancedPanelComponent> {
  late AdvancedPanelComponentParameters parameters;
  late bool showBackgroundColorModal;
  late bool showNameTagsColorModal;
  late bool showCustomTextColorModal;

  late String selectedColorType;
  late String recordingText;
  late String customText;
  late String selectedOrientationVideo;

  late TextEditingController customTextController;
  late Map<String, Color> parsedColors; // Declare parsedColors map

  @override
  void initState() {
    super.initState();
    parameters = widget.options.parameters;
    customTextController =
        TextEditingController(text: parameters.recordingCustomText);
    // Initialize parsedColors with the initial colors
    parsedColors = {
      'backgroundColor': _parseColor(parameters.recordingBackgroundColor),
      'customTextColor': _parseColor(parameters.recordingCustomTextColor),
      'nameTagsColor': _parseColor(parameters.recordingNameTagsColor),
    };
    showBackgroundColorModal = false;
    showNameTagsColorModal = false;
    showCustomTextColorModal = false;
    selectedColorType = '';
    recordingText = parameters.recordingAddText.toString();
    customText = parameters.recordingCustomText;
    selectedOrientationVideo = parameters.recordingOrientationVideo;
  }

  Color _parseColor(String colorString) {
    return colorString.startsWith('#')
        ? Color(int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000)
        : Colors.transparent;
  }

  @override
  void didUpdateWidget(AdvancedPanelComponent oldWidget) {
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

  void _showColorPickerDialog() {
    // Get the selected color based on the selectedColorType
    Color selectedColor = parsedColors[selectedColorType] ?? Colors.white;
    Color tempColor = selectedColor;

    // Show the color picker dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                // Update the selected color in parsedColors
                tempColor = color;
              },
              // ignore: deprecated_member_use
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                onSelectColor(tempColor);
                if (mounted) {
                  setState(() {
                    parsedColors[selectedColorType] = tempColor;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void toggleColorPicker(String colorType) {
    if (mounted) {
      setState(() {
        selectedColorType = colorType;
        showBackgroundColorModal = colorType == 'backgroundColor';
        showCustomTextColorModal = colorType == 'customTextColor';
        showNameTagsColorModal = colorType == 'nameTagsColor';
      });
    }
  }

  void onSelectColor(Color color) {
    String colorHex =
        // ignore: deprecated_member_use
        color.value.toRadixString(16).padLeft(8, '0').substring(2);
    String colorString = '#$colorHex';

    if (showBackgroundColorModal) {
      parameters.updateRecordingBackgroundColor(colorString);
    } else if (showCustomTextColorModal) {
      parameters.updateRecordingCustomTextColor(colorString);
    } else if (showNameTagsColorModal) {
      parameters.updateRecordingNameTagsColor(colorString);
    }
  }

  bool validateTextInput(String input) {
    // Regular expression to match alphanumeric characters and spaces, with a maximum length of 40 characters
    RegExp regex = RegExp(r'^[a-zA-Z0-9\s]{1,40}$');

    // Test the input against the regular expression
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video Type
        buildPicker(
          label: 'Video Type:',
          value: parameters.recordingVideoType,
          onValueChanged: (value) => parameters.updateRecordingVideoType(value),
          items: [
            {'label': 'Full Display (no background)', 'value': 'fullDisplay'},
            {'label': 'Full Video', 'value': 'bestDisplay'},
            {'label': 'All', 'value': 'all'},
          ],
        ),
        const SizedBox(height: 15),
        // Display Type
        if (parameters.eventType != EventType.broadcast)
          buildPicker(
            label: 'Display Type:',
            value: parameters.recordingDisplayType,
            onValueChanged: (value) =>
                parameters.updateRecordingDisplayType(value),
            items: [
              {'label': 'Only Video Participants', 'value': 'video'},
              {
                'label': 'Only Video Participants (optimized)',
                'value': 'videoOpt'
              },
              {'label': 'Participants with media', 'value': 'media'},
              {'label': 'All Participants', 'value': 'all'},
            ],
          ),
        const SizedBox(height: 15),
        // Background Color
        buildColorPicker(
          label: 'Background Color:',
          color: parsedColors['backgroundColor'] ?? Colors.transparent,
          onColorSelected: () => toggleColorPicker('backgroundColor'),
        ),
        const SizedBox(height: 15),
        // Add Text or not
        buildPicker(
          label: 'Add Text:',
          value: parameters.recordingAddText.toString(),
          onValueChanged: (value) {
            final isTrue = value == 'true' || value == true;
            parameters.updateRecordingAddText(isTrue);
            recordingText = isTrue.toString();
          },
          items: [
            {'label': 'True', 'value': 'true'},
            {'label': 'False', 'value': 'false'},
          ],
        ),
        const SizedBox(height: 15),
        // Custom Text
        if (recordingText == 'true') buildCustomText(),
        // Custom Text Position
        if (recordingText == 'true')
          buildPicker(
            label: 'Custom Text Position:',
            value: parameters.recordingCustomTextPosition,
            onValueChanged: (value) =>
                parameters.updateRecordingCustomTextPosition(value),
            items: [
              {'label': 'Top', 'value': 'top'},
              {'label': 'Middle', 'value': 'middle'},
              {'label': 'Bottom', 'value': 'bottom'},
            ],
          ),
        // Custom Text Color
        if (recordingText == 'true')
          buildColorPicker(
            label: 'Custom Text Color:',
            color: parsedColors['customTextColor'] ?? Colors.transparent,
            onColorSelected: () => toggleColorPicker('customTextColor'),
          ),
        const SizedBox(height: 15),
        // Add name tags or not
        buildPicker(
          label: 'Add Name Tags:',
          value: parameters.recordingNameTags.toString(),
          onValueChanged: (value) => parameters
              .updateRecordingNameTags(value == 'true' || value == true),
          items: [
            {'label': 'True', 'value': 'true'},
            {'label': 'False', 'value': 'false'},
          ],
        ),
        const SizedBox(height: 15),
        // Name Tags Color
        buildColorPicker(
          label: 'Name Tags Color:',
          color: parsedColors['nameTagsColor'] ?? Colors.transparent,
          onColorSelected: () => toggleColorPicker('nameTagsColor'),
        ),
        const SizedBox(height: 15),
        // Orientation (Video)
        buildPicker(
          label: 'Orientation (Video):',
          value: selectedOrientationVideo,
          onValueChanged: (value) {
            parameters.updateRecordingOrientationVideo(value);
            if (mounted) {
              setState(() {
                selectedOrientationVideo = value;
              });
            }
          },
          items: [
            {'label': 'Landscape', 'value': 'landscape'},
            {'label': 'Portrait', 'value': 'portrait'},
            {'label': 'All', 'value': 'all'},
          ],
        ),
      ],
    );
  }

  Widget buildPicker(
      {required String label,
      required String value,
      required Function onValueChanged,
      required List<Map<String, String>> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DropdownButton<String>(
            value: value,
            onChanged: (newValue) {
              onValueChanged(newValue);
            },
            items: items.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(
                  item['label']!,
                  // style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildColorPicker({
    required String label,
    required Color color,
    required VoidCallback onColorSelected,
  }) {
    String colorHex =
        // ignore: deprecated_member_use
        color.value.toRadixString(16).padLeft(8, '0').substring(2);
    String colorString = '#$colorHex';

    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ElevatedButton(
          onPressed: () {
            onColorSelected(); // Call the callback to show the color picker dialog
            _showColorPickerDialog(); // Show the color picker dialog
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(color),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.all(16.0), // Adjust the padding as needed
            ),
          ),
          child: Text(
            colorString,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildCustomText() {
    return Column(
      children: [
        const Text('Custom Text:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: customTextController,
          onChanged: (text) {
            onChangeTextHandler(text);
          },
          decoration: const InputDecoration(
            hintText: 'Enter custom text',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 5)
      ],
    );
  }
}
