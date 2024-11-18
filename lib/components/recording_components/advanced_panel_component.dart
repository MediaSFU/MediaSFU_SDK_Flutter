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

// Options class to contain AdvancedPanelComponentParameters
class AdvancedPanelComponentOptions {
  final AdvancedPanelComponentParameters parameters;

  AdvancedPanelComponentOptions({required this.parameters});
}

typedef AdvancedPanelType = Widget Function(
    {required AdvancedPanelComponentOptions options});

/// `AdvancedPanelComponent` displays an advanced configuration panel for recording options.
///
/// ### Parameters:
/// - [options] (`AdvancedPanelComponentOptions`): Contains configuration parameters:
///   - `recordingVideoType` (String): Type of video recording (e.g., "fullDisplay").
///   - `recordingDisplayType` (String): Display type for recording.
///   - `recordingBackgroundColor` (String): Background color for the recording.
///   - `recordingNameTagsColor` (String): Color for name tags.
///   - `recordingOrientationVideo` (String): Video orientation.
///   - `recordingNameTags` (bool): Enable name tags.
///   - `recordingAddText` (bool): Add custom text.
///   - `recordingCustomText` (String): Custom text for recording.
///   - `recordingCustomTextPosition` (String): Position of custom text.
///   - `recordingCustomTextColor` (String): Custom text color.
///
/// ### Example:
/// ```dart
/// AdvancedPanelComponent(
///   options: AdvancedPanelComponentOptions(
///     parameters: MyAdvancedPanelComponentParameters(
///       recordingVideoType: "fullDisplay",
///       recordingDisplayType: "video",
///       recordingBackgroundColor: "#000000",
///       // other parameters...
///     ),
///   ),
/// );
/// ```
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
                setState(() {
                  parsedColors[selectedColorType] = tempColor;
                });
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
    setState(() {
      selectedColorType = colorType;
      showBackgroundColorModal = colorType == 'backgroundColor';
      showCustomTextColorModal = colorType == 'customTextColor';
      showNameTagsColorModal = colorType == 'nameTagsColor';
    });
  }

  void onSelectColor(Color color) {
    String colorHex =
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
            setState(() {
              selectedOrientationVideo = value;
            });
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
