import 'package:flutter/material.dart';

/// `CustomButton` - Defines options for each button within the `CustomButtons` widget.
class CustomButton {
  final VoidCallback action;
  final bool show;
  final Color? backgroundColor;
  final bool disabled;
  final IconData? icon;
  final TextStyle? textStyle;
  final String? text;
  final Widget? customComponent;
  final TextStyle? iconStyle;

  CustomButton({
    required this.action,
    this.show = true,
    this.backgroundColor,
    this.disabled = false,
    this.icon,
    this.text,
    this.textStyle,
    this.customComponent,
    this.iconStyle,
  });
}

/// `CustomButtonsOptions` - Defines configuration options for multiple buttons in `CustomButtons`.
class CustomButtonsOptions {
  List<CustomButton> buttons;

  CustomButtonsOptions({required this.buttons});
}

typedef CustomButtonsType = Widget Function(CustomButtonsOptions options);

/// `CustomButtons` - A widget to display a list of customizable buttons.
///
/// This widget allows you to create multiple buttons with individual styles, actions, and layouts.
/// Each button is defined using the `CustomButton` class within `CustomButtonsOptions`.
///
/// ### Parameters:
/// - `options` (`CustomButtonsOptions`): Configuration options containing a list of `CustomButton` items.
///
/// ### Example Usage:
/// ```dart
/// CustomButtons(
///   options: CustomButtonsOptions(
///     buttons: [
///       CustomButton(
///         action: () => print("Action 1"),
///         text: "First Button",
///         backgroundColor: Colors.blue,
///         icon: Icons.add,
///         textStyle: TextStyle(color: Colors.white),
///       ),
///       CustomButton(
///         action: () => print("Action 2"),
///         text: "Second Button",
///         backgroundColor: Colors.red,
///         icon: Icons.remove,
///         disabled: true,
///         textStyle: TextStyle(color: Colors.white),
///       ),
///     ],
///   ),
/// );
/// ```
///
/// ### Customization Options:
/// - **Visibility**: Control each button's visibility with `show`.
/// - **Disabling**: Set `disabled` to `true` to disable a button.
/// - **Custom Content**: Use `customComponent` to replace standard text and icon with custom content.
///
/// ### Layout:
/// Each button is wrapped in a `Container` with padding, displayed vertically in a column.

class CustomButtons extends StatelessWidget {
  final CustomButtonsOptions options;

  const CustomButtons({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.buttons.map<Widget>((button) {
        return Visibility(
          visible: button.show,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: button.disabled ? null : button.action,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color?>(
                  button.show
                      ? button.backgroundColor ?? Colors.grey[50]
                      : null,
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.all(10),
                ),
              ),
              child: Row(
                children: [
                  if (button.customComponent != null) button.customComponent!,
                  if (button.icon != null)
                    Icon(
                      button.icon,
                      size: 20,
                      color: button.iconStyle?.color ?? Colors.black,
                    ),
                  if (button.text != null) const SizedBox(width: 4),
                  Text(
                    button.text ?? '',
                    style: button.textStyle ??
                        const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
