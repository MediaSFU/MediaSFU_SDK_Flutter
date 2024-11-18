import 'package:flutter/material.dart';

/// AltButton - Represents a configurable button within the control button component.
///
/// ### Example Usage:
/// ```dart
/// ControlButton(
///   name: 'Mute',
///   icon: Icons.mic_off,
///   alternateIcon: Icons.mic,
///   onPress: () => print('Muted'),
///   defaultBackgroundColor: Colors.grey,
///   pressedBackgroundColor: Colors.blue,
///   active: true,
///   activeColor: Colors.green,
///   inActiveColor: Colors.red,
///   show: true,
///   disabled: false,
/// );
/// ```

class AltButton {
  /// The display name of the button.
  final String? name;

  /// The primary icon of the button.
  final IconData? icon;

  /// The alternate icon displayed when the button is active.
  final IconData? alternateIcon;

  /// The callback function triggered when the button is pressed.
  final VoidCallback? onPress;

  /// The default background color of the button.
  final Color? defaultBackgroundColor;

  /// The background color of the button when pressed or active.
  final Color? pressedBackgroundColor;

  /// Indicates whether the button is in an active state.
  final bool active;

  /// The color of the icon when the button is active.
  final Color? activeColor;

  /// The color of the icon when the button is inactive.
  final Color? inActiveColor;

  /// The color of the text label.
  final Color? textColor;

  /// Indicates whether the button should be displayed.
  final bool show;

  /// If true, the button is disabled and non-interactive.
  final bool disabled;

  /// A custom widget to replace the default icon and text layout.
  final Widget? customComponent;

  AltButton({
    this.name,
    this.icon,
    this.alternateIcon,
    this.onPress,
    this.defaultBackgroundColor,
    this.pressedBackgroundColor,
    this.active = false,
    this.activeColor,
    this.inActiveColor,
    this.textColor,
    this.show = true,
    this.disabled = false,
    this.customComponent,
  });
}

typedef ControlButtonsAltComponentType = Widget Function(
    {required ControlButtonsAltComponentOptions options});

/// ControlButtonsAltComponentOptions - Configures settings for the `ControlButtonsAltComponent`.
///
/// ### Example Usage:
/// ```dart
/// ControlButtonsAltComponentOptions(
///   buttons: [
///     ControlButton(
///       name: 'Start',
///       icon: Icons.play_arrow,
///       onPress: () => print('Play button pressed'),
///       defaultBackgroundColor: Colors.black,
///       pressedBackgroundColor: Colors.green,
///     ),
///     ControlButton(
///       name: 'Stop',
///       icon: Icons.stop,
///       onPress: () => print('Stop button pressed'),
///       defaultBackgroundColor: Colors.black,
///       pressedBackgroundColor: Colors.red,
///     ),
///   ],
///   position: 'center',
///   location: 'bottom',
///   direction: 'horizontal',
///   buttonsContainerStyle: BoxDecoration(
///     color: Colors.white,
///     borderRadius: BorderRadius.circular(8),
///   ),
///   showAspect: true,
/// );
/// ```
class ControlButtonsAltComponentOptions {
  /// An array of button configurations to render within the component.
  final List<AltButton> buttons;

  /// Specifies the horizontal alignment of the buttons within the container.
  /// Options: 'left', 'right', 'center'.
  final String position;

  /// Specifies the vertical alignment of the buttons within the container.
  /// Options: 'top', 'bottom', 'center'.
  final String location;

  /// Determines the layout direction of the buttons.
  /// Options: 'horizontal', 'vertical'.
  final String direction;

  /// Additional styling for the container holding the buttons.
  final BoxDecoration? buttonsContainerStyle;

  /// A custom widget to display in place of the default icon component when the button is active.
  final Widget? alternateIconComponent;

  /// A custom widget to display in place of the default icon component when the button is inactive.
  final Widget? iconComponent;

  /// Controls the visibility of the widget.
  final bool showAspect;

  ControlButtonsAltComponentOptions({
    required this.buttons,
    this.position = 'left',
    this.location = 'top',
    this.direction = 'horizontal',
    this.buttonsContainerStyle,
    this.alternateIconComponent,
    this.iconComponent,
    this.showAspect = true,
  });
}

/// ControlButtonsAltComponent - A widget that displays a configurable set of control buttons with flexible styling and alignment options.
///
/// ### Example Usage:
/// ```dart
/// ControlButtonsAltComponent(
///   options: ControlButtonsAltComponentOptions(
///     buttons: [
///       AltButton(
///         name: 'Mute',
///         icon: Icons.mic_off,
///         onPress: () => print('Mic off'),
///         defaultBackgroundColor: Colors.grey,
///         pressedBackgroundColor: Colors.blue,
///         active: true,
///       ),
///       AltButton(
///         name: 'Camera',
///         icon: Icons.videocam,
///         onPress: () => print('Camera on'),
///       ),
///     ],
///     position: 'right',
///     location: 'center',
///     direction: 'horizontal',
///   ),
/// );
/// ```
///
class ControlButtonsAltComponent extends StatelessWidget {
  final ControlButtonsAltComponentOptions options;

  const ControlButtonsAltComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: options.showAspect,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: options.buttonsContainerStyle,
        padding: const EdgeInsets.all(5),
        child: _buildLayout(),
      ),
    );
  }

  /// Builds the button layout based on the [direction] property.
  Widget _buildLayout() {
    if (options.direction == 'horizontal') {
      return Column(
        mainAxisAlignment: _getVerticalMainAxisAlignment(),
        children: [
          Row(
            mainAxisAlignment: _getHorizontalMainAxisAlignment(),
            children: _buildButtons(),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: _getHorizontalMainAxisAlignment(),
        children: [
          Column(
            mainAxisAlignment: _getVerticalMainAxisAlignment(),
            children: _buildButtons(),
          ),
        ],
      );
    }
  }

  /// Determines the horizontal alignment based on [position].
  MainAxisAlignment _getHorizontalMainAxisAlignment() {
    switch (options.position) {
      case 'right':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'left':
      default:
        return MainAxisAlignment.start;
    }
  }

  /// Determines the vertical alignment based on [location].
  MainAxisAlignment _getVerticalMainAxisAlignment() {
    switch (options.location) {
      case 'bottom':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'top':
      default:
        return MainAxisAlignment.start;
    }
  }

  /// Builds the list of button widgets based on the [buttons] configuration.
  List<Widget> _buildButtons() {
    return options.buttons.map((button) {
      if (!button.show) return const SizedBox.shrink();

      return GestureDetector(
        onTap: button.disabled ? null : button.onPress,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          decoration: BoxDecoration(
            color: button.active
                ? (button.pressedBackgroundColor ?? Colors.grey)
                : (button.defaultBackgroundColor ?? Colors.transparent),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display custom component if provided
              if (button.customComponent != null)
                button.customComponent!
              else ...[
                // Display icon
                if (button.icon != null)
                  Icon(
                    button.active
                        ? (button.alternateIcon ?? button.icon)
                        : button.icon,
                    size: 16,
                    color: button.active
                        ? (button.activeColor ?? Colors.white)
                        : (button.inActiveColor ?? Colors.white),
                  ),
                // Display name
                if (button.name != null)
                  Text(
                    button.name!,
                    style: TextStyle(
                      color: button.textColor ?? Colors.white,
                      fontSize: 12,
                    ),
                  ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }
}
