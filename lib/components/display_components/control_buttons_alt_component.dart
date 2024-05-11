import 'package:flutter/material.dart';

/// ControlButtonsAltComponent is a widget used to display a set of control buttons in an alternative layout.
///
/// It takes in a list of [buttons] to be displayed, where each button is represented by a map containing
/// properties such as icon, name, onPressed callback, etc. The [position] parameter determines the alignment
/// of the buttons (left, right, or center). The [location] parameter specifies whether the buttons are placed
/// at the top or bottom. The [direction] parameter defines the layout direction of the buttons (horizontal or vertical).
/// The [buttonsContainerStyle] allows customization of the container holding the buttons. The [alternateIconComponent]
/// and [iconComponent] parameters allow customization of the icon displayed for each button. The [showAspect] parameter
/// controls the visibility of the widget.
///
/// Example:
/// ```dart
/// ControlButtonsAltComponent(
///   buttons: [
///     {
///       'icon': Icons.play_arrow,
///       'name': 'Play',
///       'onPress': () => _play(),
///       'backgroundColor': {
///         'default': Colors.blue,
///         'pressed': Colors.blue[800],
///       },
///       'active': true,
///       'activeColor': Colors.green,
///       'inActiveColor': Colors.red,
///     },
///     {
///       'icon': Icons.stop,
///       'name': 'Stop',
///       'onPress': () => _stop(),
///       'backgroundColor': {
///         'default': Colors.red,
///         'pressed': Colors.red[800],
///       },
///       'active': false,
///       'activeColor': Colors.green,
///       'inActiveColor': Colors.red,
///     },
///   ],
///   position: 'left',
///   location: 'top',
///   direction: 'horizontal',
///   buttonsContainerStyle: BoxDecoration(
///     color: Colors.black,
///     borderRadius: BorderRadius.circular(10),
///   ),
///   alternateIconComponent: Icon(Icons.check),
///   iconComponent: Icon(Icons.close),
///   showAspect: true,
/// )
/// ```

class ControlButtonsAltComponent extends StatelessWidget {
  final List<Map<String, dynamic>> buttons;
  final String position;
  final String location;
  final String direction;
  final BoxDecoration? buttonsContainerStyle;
  final Widget? alternateIconComponent;
  final Widget? iconComponent;
  final bool showAspect;

  const ControlButtonsAltComponent({
    super.key,
    required this.buttons,
    this.position = 'left',
    this.location = 'top',
    this.direction = 'horizontal',
    this.buttonsContainerStyle,
    this.alternateIconComponent,
    this.iconComponent,
    this.showAspect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: showAspect,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
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
      return GestureDetector(
        onTap: button['onPress'],
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: button['pressed'] != null && button['pressed']
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
              if (button['customComponent'] != null) button['customComponent']!,
              if (button['icon'] != null)
                button['active']
                    ? button['alternateIconComponent'] ??
                        alternateIconComponent ??
                        Icon(
                          button['alternateIcon'],
                          size: 14,
                          color: button['activeColor'] ?? Colors.white,
                        )
                    : button['iconComponent'] ??
                        iconComponent ??
                        Icon(
                          button['icon'],
                          size: 14,
                          color: button['inActiveColor'] ?? Colors.white,
                        ),
              if (button['name'] != null)
                Text(
                  button['name'],
                  style: TextStyle(
                    color: button['color'] ?? Colors.white,
                    fontSize: 12,
                    height: 1.5, // Adjust line height here
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
