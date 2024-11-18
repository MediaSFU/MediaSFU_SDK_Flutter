import 'package:flutter/material.dart';

/// `ControlButton` - A model class to define properties of individual control buttons.
///
/// This model allows customization of button icons, colors, text, states, and actions,
/// enabling the creation of flexible and interactive control buttons.
///
/// ### Properties:
/// - `name` (`String?`): Optional text to display below the button's icon.
/// - `icon` (`IconData?`): Icon to display on the button when inactive.
/// - `alternateIcon` (`IconData?`): Alternate icon to display when the button is active.
/// - `onPress` (`VoidCallback?`): Function callback triggered on button press.
/// - `color` (`Color?`): Color of the button text. Defaults to `Colors.white`.
/// - `activeColor` (`Color?`): Color of the icon when the button is active. Defaults to `Colors.blue`.
/// - `inActiveColor` (`Color?`): Color of the icon when the button is inactive. Defaults to `Colors.grey`.
/// - `active` (`bool`): Indicates whether the button is active. Defaults to `false`.
/// - `show` (`bool`): Indicates whether the button is visible. Defaults to `true`.
/// - `customComponent` (`Widget?`): Custom widget to display instead of the default icon and text.
/// - `disabled` (`bool`): Indicates whether the button is disabled (non-clickable). Defaults to `false`.
///
/// ### Example Usage:
/// ```dart
/// ControlButton(
///   name: "Mute",
///   icon: Icons.mic,
///   alternateIcon: Icons.mic_off,
///   onPress: () => print("Mute button pressed"),
///   active: false,
///   color: Colors.black,
/// );
/// ```
///
class ControlButton {
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

  ControlButton({
    this.name,
    this.icon,
    this.alternateIcon,
    this.onPress,
    this.color = Colors.white,
    this.activeColor = Colors.blue,
    this.inActiveColor = Colors.grey,
    this.active = false,
    this.show = true,
    this.customComponent,
    this.disabled = false,
  });
}

/// `ControlButtonsComponentOptions` - Configuration options for the `ControlButtonsComponent`.
///
/// This class defines the layout, alignment, and appearance of a collection of `ControlButton` widgets,
/// allowing flexible and customizable control button arrangements.
///
/// ### Properties:
/// - `buttons` (`List<ControlButton>`): List of `ControlButton` instances to display in the component.
/// - `alignment` (`MainAxisAlignment`): Alignment of buttons within the component. Defaults to `MainAxisAlignment.start`.
/// - `vertical` (`bool`): If `true`, arranges buttons vertically; otherwise, horizontally. Defaults to `false`.
/// - `buttonBackgroundColor` (`Color?`): Background color for active buttons.
/// - `buttonsContainerConstraints` (`BoxConstraints?`): Constraints on the container holding the buttons.
///
/// ### Example Usage:
/// ```dart
/// ControlButtonsComponentOptions(
///   buttons: [
///     ControlButton(
///       name: "Play",
///       icon: Icons.play_arrow,
///       onPress: () => print("Play button pressed"),
///     ),
///     ControlButton(
///       name: "Pause",
///       icon: Icons.pause,
///       onPress: () => print("Pause button pressed"),
///       active: true,
///     ),
///   ],
///   alignment: MainAxisAlignment.center,
///   vertical: false,
///   buttonBackgroundColor: Colors.blue,
/// );
/// ```
class ControlButtonsComponentOptions {
  final List<ControlButton> buttons;
  final MainAxisAlignment alignment;
  final bool vertical;
  final Color? buttonBackgroundColor;
  final BoxConstraints? buttonsContainerConstraints;

  ControlButtonsComponentOptions({
    required this.buttons,
    this.alignment = MainAxisAlignment.start,
    this.vertical = false,
    this.buttonBackgroundColor,
    this.buttonsContainerConstraints,
  });
}

typedef ControlButtonsComponentType = Widget Function(
    ControlButtonsComponentOptions options);

/// `ControlButtonsComponent` - A widget that displays a set of control buttons based on specified options.
///
/// This widget arranges a collection of `ControlButton` instances either horizontally or vertically,
/// providing an interactive and visually flexible control panel.
///
/// ### Example Usage:
/// ```dart
/// ControlButtonsComponent(
///   options: ControlButtonsComponentOptions(
///     buttons: [
///       ControlButton(
///         name: "Play",
///         icon: Icons.play_arrow,
///         onPress: () => print("Play button pressed"),
///       ),
///       ControlButton(
///         name: "Stop",
///         icon: Icons.stop,
///         onPress: () => print("Stop button pressed"),
///         active: true,
///       ),
///     ],
///     alignment: MainAxisAlignment.center,
///     vertical: false,
///     buttonBackgroundColor: Colors.blue,
///   ),
/// );
/// ```
///
/// ### Notes:
/// - Each button can have an `active` state, displaying an `alternateIcon` and `activeColor` when active.
/// - The component can be laid out horizontally or vertically based on the `vertical` property.
class ControlButtonsComponent extends StatelessWidget {
  final ControlButtonsComponentOptions options;

  const ControlButtonsComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: options.buttonsContainerConstraints,
      child: Flex(
        direction: options.vertical ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: options.alignment,
        children: options.buttons.where((button) => button.show).map((button) {
          return GestureDetector(
            onTap: button.disabled ? null : button.onPress,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: button.active
                    ? options.buttonBackgroundColor ?? Colors.transparent
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: button.customComponent ??
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (button.icon != null)
                        Icon(
                          button.active
                              ? button.alternateIcon ?? button.icon
                              : button.icon,
                          color: button.active
                              ? button.activeColor
                              : button.inActiveColor,
                          size: 20,
                        ),
                      if (button.name != null)
                        Text(
                          button.name!,
                          style: TextStyle(color: button.color, fontSize: 12),
                        ),
                    ],
                  ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
