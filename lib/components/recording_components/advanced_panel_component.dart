import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// AdvancedPanelComponent is a StatefulWidget that represents an advanced panel component.
///
/// `parameters`: A map containing parameters for the advanced panel.
///
/// State:
///   `_AdvancedPanelComponentState`: The state class for AdvancedPanelComponent.
///
/// Internal State Variables:
///   - `updateRecordingVideoType`: Function to update the recording video type.
///   - `updateRecordingDisplayType`: Function to update the recording display type.
///   - `updateRecordingBackgroundColor`: Function to update the recording background color.
///   - `updateRecordingNameTagsColor`: Function to update the recording name tags color.
///   - `updateRecordingOrientationVideo`: Function to update the recording orientation video.
///   - `updateRecordingNameTags`: Function to update whether to display name tags.
///   - `updateRecordingAddText`: Function to update whether to add text.
///   - `updateRecordingCustomText`: Function to update the custom text.
///   - `updateRecordingCustomTextPosition`: Function to update the custom text position.
///   - `updateRecordingCustomTextColor`: Function to update the custom text color.
///   - `recordingVideoType`: The current recording video type.
///   - `recordingDisplayType`: The current recording display type.
///   - `recordingBackgroundColor`: The current recording background color.
///   - `recordingNameTagsColor`: The current recording name tags color.
///   - `recordingOrientationVideo`: The current recording orientation video.
///   - `recordingNameTags`: Indicates whether name tags are enabled.
///   - `recordingAddText`: Indicates whether additional text is added.
///   - `recordingCustomText`: The current custom text.
///   - `recordingCustomTextPosition`: The current position of the custom text.
///   - `recordingCustomTextColor`: The current color of the custom text.
///   - `eventType`: The type of event.
///   - `showBackgroundColorModal`: Indicates whether the background color modal is visible.
///   - `showNameTagsColorModal`: Indicates whether the name tags color modal is visible.
///   - `showCustomTextColorModal`: Indicates whether the custom text color modal is visible.
///   - `selectedColorType`: The currently selected color type.
///   - `recordingText`: Indicates whether text is being recorded.
///   - `customText`: The current custom text value.
///   - `selectedOrientationVideo`: The currently selected orientation video.
///   - `customTextController`: Controller for the custom text field.
///   - `parsedColors`: Map to store parsed colors.
///
/// Methods:
///   - `initState`: Initializes the state of the widget.
///   - `_parseColor`: Parses color from a string.
///   - `didUpdateWidget`: Handles updates to the widget.
///   - `dispose`: Disposes of resources when the widget is removed.
///   - `_showColorPickerDialog`: Shows the color picker dialog.
///   - `_updateParameters`: Updates parameters based on input.
///   - `toggleColorPicker`: Toggles the color picker based on color type.
///   - `onSelectColor`: Handles color selection from the color picker.
///   - `validateTextInput`: Validates text input.
///   - `onChangeTextHandler`: Handles changes to the custom text.
///   - `build`: Builds the widget.
///   - `buildPicker`: Builds a dropdown picker.
///   - `buildColorPicker`: Builds a color picker.
///   - `buildCustomText`: Builds the custom text field.

class AdvancedPanelComponent extends StatefulWidget {
  final Map<String, dynamic> parameters;

  const AdvancedPanelComponent({super.key, required this.parameters});

  @override
  // ignore: library_private_types_in_public_api
  _AdvancedPanelComponentState createState() => _AdvancedPanelComponentState();
}

class _AdvancedPanelComponentState extends State<AdvancedPanelComponent> {
  late Function updateRecordingVideoType;
  late Function updateRecordingDisplayType;
  late Function updateRecordingBackgroundColor;
  late Function updateRecordingNameTagsColor;
  late Function updateRecordingOrientationVideo;
  late Function updateRecordingNameTags;
  late Function updateRecordingAddText;
  late Function updateRecordingCustomText;
  late Function updateRecordingCustomTextPosition;
  late Function updateRecordingCustomTextColor;

  late String recordingVideoType;
  late String recordingDisplayType;
  late String recordingBackgroundColor;
  late String recordingNameTagsColor;
  late String recordingOrientationVideo;
  late bool recordingNameTags;
  late bool recordingAddText;
  late String recordingCustomText;
  late String recordingCustomTextPosition;
  late String recordingCustomTextColor;

  late String eventType;

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
    _updateParameters(widget.parameters);
    customTextController =
        TextEditingController(text: widget.parameters['recordingCustomText']);
    // Initialize parsedColors with the initial colors
    parsedColors = {
      'backgroundColor':
          _parseColor(widget.parameters['recordingBackgroundColor']),
      'customTextColor':
          _parseColor(widget.parameters['recordingCustomTextColor']),
      'nameTagsColor': _parseColor(widget.parameters['recordingNameTagsColor']),
    };
  }

  Color _parseColor(String colorString) {
    return colorString.startsWith('#')
        ? Color(int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000)
        : Colors.transparent;
  }

  @override
  void didUpdateWidget(AdvancedPanelComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.parameters != oldWidget.parameters) {
      _updateParameters(widget.parameters);
    }
    if (widget.parameters['recordingCustomText'] != customTextController.text) {
      customTextController.text = widget.parameters['recordingCustomText'];
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

  void _updateParameters(Map<String, dynamic> parameters) {
    setState(() {
      recordingVideoType = parameters['recordingVideoType'];
      recordingDisplayType = parameters['recordingDisplayType'];
      recordingBackgroundColor = parameters['recordingBackgroundColor'];
      recordingNameTagsColor = parameters['recordingNameTagsColor'];
      recordingOrientationVideo = parameters['recordingOrientationVideo'];
      recordingNameTags = parameters['recordingNameTags'];
      recordingAddText = parameters['recordingAddText'];
      recordingCustomText = parameters['recordingCustomText'];
      recordingCustomTextPosition = parameters['recordingCustomTextPosition'];
      recordingCustomTextColor = parameters['recordingCustomTextColor'];

      updateRecordingVideoType = parameters['updateRecordingVideoType'];
      updateRecordingDisplayType = parameters['updateRecordingDisplayType'];
      updateRecordingBackgroundColor =
          parameters['updateRecordingBackgroundColor'];
      updateRecordingNameTagsColor = parameters['updateRecordingNameTagsColor'];
      updateRecordingOrientationVideo =
          parameters['updateRecordingOrientationVideo'];
      updateRecordingNameTags = parameters['updateRecordingNameTags'];
      updateRecordingAddText = parameters['updateRecordingAddText'];
      updateRecordingCustomText = parameters['updateRecordingCustomText'];
      updateRecordingCustomTextPosition =
          parameters['updateRecordingCustomTextPosition'];
      updateRecordingCustomTextColor =
          parameters['updateRecordingCustomTextColor'];

      eventType = parameters['eventType'];

      showBackgroundColorModal = false;
      showNameTagsColorModal = false;
      showCustomTextColorModal = false;

      selectedColorType = '';
      recordingText = recordingAddText.toString();
      customText = recordingCustomText;
      selectedOrientationVideo = recordingOrientationVideo;
    });
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
      updateRecordingBackgroundColor(colorString);
    } else if (showCustomTextColorModal) {
      updateRecordingCustomTextColor(colorString);
    } else if (showNameTagsColorModal) {
      updateRecordingNameTagsColor(colorString);
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
      customTextController.text = recordingCustomText;
      return;
    }
    updateRecordingCustomText(text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video Type
        buildPicker(
          label: 'Video Type:',
          value: recordingVideoType,
          onValueChanged: (value) => updateRecordingVideoType(value),
          items: [
            {'label': 'Full Display (no background)', 'value': 'fullDisplay'},
            {'label': 'Full Video', 'value': 'bestDisplay'},
            {'label': 'All', 'value': 'all'},
          ],
        ),
        const SizedBox(height: 15),
        // Display Type
        if (eventType != 'broadcast')
          buildPicker(
            label: 'Display Type:',
            value: recordingDisplayType,
            onValueChanged: (value) => updateRecordingDisplayType(value),
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
          value: recordingAddText.toString(),
          onValueChanged: (value) =>
              updateRecordingAddText(value == 'true' || value == true),
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
            value: recordingCustomTextPosition,
            onValueChanged: (value) => updateRecordingCustomTextPosition(value),
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
          value: recordingNameTags.toString(),
          onValueChanged: (value) =>
              updateRecordingNameTags(value == 'true' || value == true),
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
            updateRecordingOrientationVideo(value);
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
