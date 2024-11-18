import 'package:flutter/material.dart';

/// ButtonTouch - Represents a control button with customizable style and behavior.
///
/// ### Example Usage:
/// ```dart
/// ButtonTouch(
///   name: 'Play',
///   icon: Icons.play_arrow,
///   alternateIcon: Icons.pause,
///   onPress: () => print('Button pressed'),
///   active: true,
///   show: true,
///   backgroundColor: {
///     'default': Colors.blue,
///     'pressed': Colors.green,
///   },
/// );
/// ```
class ButtonTouch {
  final String? name;
  final IconData? icon;
  final IconData? alternateIcon;
  final VoidCallback? onPress;
  final Color? color;
  final Color? activeColor;
  final Color? inActiveColor;
  final bool active;
  final bool show;
  final Widget? customComponent;
  final bool disabled;
  final int? size;
  final Map<String, Color>? backgroundColor;

  ButtonTouch({
    this.name,
    this.icon,
    this.alternateIcon,
    this.onPress,
    this.color = Colors.white,
    this.activeColor,
    this.inActiveColor,
    this.active = false,
    this.show = true,
    this.customComponent,
    this.disabled = false,
    this.backgroundColor,
    this.size = 16,
  });
}

/// ControlButtonsComponentTouchOptions - Configuration options for `ControlButtonsComponentTouch`.
///
/// ### Example Usage:
/// ```dart
/// ControlButtonsComponentTouchOptions(
///   buttons: [
///     ButtonTouch(name: 'Play', icon: Icons.play_arrow, onPress: () {} ),
///     ButtonTouch(name: 'Stop', icon: Icons.stop, onPress: () {}, disabled: true ),
///   ],
///   position: 'right',
///   location: 'bottom',
///   direction: 'horizontal',
///   containerDecoration: BoxDecoration(
///     color: Colors.grey,
///     borderRadius: BorderRadius.circular(8),
///   ),
/// );
/// ```
class ControlButtonsComponentTouchOptions {
  final List<ButtonTouch> buttons;
  final String position;
  final String location;
  final String direction;
  final BoxDecoration? containerDecoration;
  final bool showAspect;

  ControlButtonsComponentTouchOptions({
    required this.buttons,
    this.position = 'left',
    this.location = 'top',
    this.direction = 'horizontal',
    this.containerDecoration,
    this.showAspect = true,
  });
}

typedef ControlButtonsComponentTouchType = Widget Function(
    ControlButtonsComponentTouchOptions options);

/// ControlButtonsComponentTouch - Renders a customizable set of control buttons.
///
/// ### Example Usage:
/// ```dart
/// ControlButtonsComponentTouch(
///   options: ControlButtonsComponentTouchOptions(
///     buttons: [
///       ButtonTouch(name: 'Play', icon: Icons.play_arrow, onPress: () {} ),
///       ButtonTouch(name: 'Pause', icon: Icons.pause, onPress: () {} ),
///     ],
///   ),
/// );
/// ```
class ControlButtonsComponentTouch extends StatelessWidget {
  final ControlButtonsComponentTouchOptions options;

  const ControlButtonsComponentTouch({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: options.showAspect,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: options.direction ==
                'horizontal' // Check direction to decide layout
            ? Column(
                // horizontal layout
                mainAxisAlignment: options.location == 'top'
                    ? MainAxisAlignment.start
                    : options.location == 'bottom'
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.center,
                children: [
                    Row(
                      mainAxisAlignment: options.position == 'left'
                          ? MainAxisAlignment.start
                          : options.position == 'right'
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.center,
                      children: _buildButtons(),
                    ),
                  ])
            : Row(
                //Vertical layout
                mainAxisAlignment: options.position == 'left'
                    ? MainAxisAlignment.start
                    : options.position == 'right'
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: options.location == 'top'
                        ? MainAxisAlignment.start
                        : options.location == 'bottom'
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.center,
                    children: _buildButtons(),
                  ),
                ],
              ),
      ),
    );
  }

  /// Builds the button widgets based on configuration.
  List<Widget> _buildButtons() {
    return options.buttons.where((button) => button.show).map((button) {
      return Visibility(
          visible: button.show,
          child: GestureDetector(
            onTap: button.disabled ? null : button.onPress,
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: button.active
                    ? (button.backgroundColor?['pressed'] != null
                        ? button.backgroundColor!['pressed']!
                        : const Color(0xFF444444))
                    : button.backgroundColor?['default'] ?? Colors.transparent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  if (button.customComponent != null) button.customComponent!,
                  if (button.icon != null)
                    Icon(
                      button.active
                          ? button.alternateIcon ?? button.icon
                          : button.icon,
                      color: button.active
                          ? button.activeColor
                          : button.inActiveColor,
                      size: button.size!.toDouble(),
                    ),
                  if (button.name != null)
                    Text(
                      button.name!,
                      style: TextStyle(color: button.color, fontSize: 12),
                    ),
                ],
              ),
            ),
          ));
    }).toList();
  }
}
