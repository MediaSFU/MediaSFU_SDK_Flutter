import 'package:flutter/material.dart';

/// ControlButtonsComponentTouch is a widget used to display a set of touch-sensitive control buttons.
///
/// It takes in a list of [buttons] to be displayed, where each button is represented by a map containing
/// properties such as icon, name, onPressed callback, etc. The [position] parameter determines the alignment
/// of the buttons (left, right, or center). The [location] parameter specifies whether the buttons are placed
/// at the top or bottom. The [direction] parameter defines the layout direction of the buttons (horizontal or vertical).
/// The [alternateIconComponent] and [iconComponent] parameters allow customization of the icons displayed for each button.
/// The [showAspect] parameter controls the visibility of the widget.

class ControlButtonsComponentTouch extends StatelessWidget {
  final List<Map<String, dynamic>> buttons;
  final String position;
  final String location;
  final String direction;
  final Widget? alternateIconComponent;
  final Widget? iconComponent;
  final bool showAspect;

  const ControlButtonsComponentTouch({
    super.key,
    required this.buttons,
    this.position = 'left',
    this.location = 'top',
    this.direction = 'horizontal',
    this.alternateIconComponent,
    this.iconComponent,
    this.showAspect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: showAspect,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: direction == 'horizontal' // Check direction to decide layout
            ? Column(
                // horizontal layout
                mainAxisAlignment: location == 'top'
                    ? MainAxisAlignment.start
                    : location == 'bottom'
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.center,
                children: [
                    Row(
                      mainAxisAlignment: position == 'left'
                          ? MainAxisAlignment.start
                          : position == 'right'
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.center,
                      children: _buildButtons(),
                    ),
                  ])
            : Row(
                //Vertical layout
                mainAxisAlignment: position == 'left'
                    ? MainAxisAlignment.start
                    : position == 'right'
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: location == 'top'
                        ? MainAxisAlignment.start
                        : location == 'bottom'
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.center,
                    children: _buildButtons(),
                  ),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildButtons() {
    return buttons.map((button) {
      return Visibility(
          visible: button['show'] ?? false,
          child: GestureDetector(
            onTap: button['onPress'] as void Function()?,
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: button['active'] != null && button['active']
                    ? button['backgroundColor'] != null
                        ? button['backgroundColor']!['pressed'] ??
                            const Color(0xFF444444)
                        : const Color.fromRGBO(255, 255, 255, 0.25)
                    : button['backgroundColor'] != null
                        ? button['backgroundColor']!['default'] ??
                            const Color.fromRGBO(255, 255, 255, 0.25)
                        : const Color.fromRGBO(255, 255, 255, 0.25),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  if (button['customComponent'] != null)
                    button['customComponent']!,
                  if (button['icon'] != null)
                    Icon(
                      button['active']
                          ? button['alternateIcon']
                          : button['icon'],
                      size: 16,
                      color: button['active']
                          ? button['activeColor'] ?? Colors.transparent
                          : button['inActiveColor'] ?? Colors.transparent,
                    ),
                  if (button['name'] != null)
                    Text(
                      button['name'],
                      style: TextStyle(
                        color: button['color'] ?? Colors.transparent,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ));
    }).toList();
  }
}
