import 'package:flutter/material.dart';

/// ControlButtonsComponent is a widget used to display a set of control buttons.
///
/// It takes in a list of [buttons] to be displayed, where each button is represented by a map containing
/// properties such as icon, name, onPressed callback, etc. The [buttonColor] parameter allows customization
/// of the button color. The [buttonBackgroundColor] parameter allows customization of the button background color.
/// The [alignment] parameter determines the horizontal alignment of the buttons.
/// The [vertical] parameter specifies whether the buttons are arranged vertically or horizontally.
/// The [buttonsContainerConstraints] parameter allows customization of the constraints applied to the container holding the buttons.
///

class ControlButtonsComponent extends StatelessWidget {
  final List<Map<String, dynamic>> buttons;
  final Color? buttonColor;
  final Map<String, Color>? buttonBackgroundColor;
  final MainAxisAlignment alignment;
  final bool vertical;
  final BoxConstraints? buttonsContainerConstraints;

  const ControlButtonsComponent({
    super.key,
    required this.buttons,
    this.buttonColor,
    this.buttonBackgroundColor,
    this.alignment = MainAxisAlignment.start,
    this.vertical = false,
    this.buttonsContainerConstraints,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: buttons.map((buttonData) {
        return GestureDetector(
          onTap: buttonData['onPress'],
          child: Container(
            constraints: buttonsContainerConstraints,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: buttonData['active'] != null && buttonData['active']
                  ? buttonBackgroundColor != null
                      ? buttonBackgroundColor!['pressed'] ??
                          const Color(0xFF444444)
                      : Colors.transparent
                  : buttonBackgroundColor != null
                      ? buttonBackgroundColor!['default'] ?? Colors.transparent
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: buttonData['customComponent'] ??
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (buttonData['icon'] != null)
                      Icon(
                        buttonData['active']
                            ? buttonData['alternateIcon'] ?? buttonData['icon']
                            : buttonData['icon'],
                        size: 18,
                        color: buttonData['active']
                            ? buttonData['activeColor'] ?? Colors.white
                            : buttonData['inActiveColor'] ?? Colors.white,
                      ),
                    if (buttonData['name'] != null)
                      Text(
                        buttonData['name'],
                        style: TextStyle(
                          color: buttonData['color'] ?? Colors.white,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
          ),
        );
      }).toList(),
    );
  }
}
