import 'package:flutter/material.dart';

/// MenuItemOptions - Defines configuration options for the `MenuItemComponent`.
class MenuItemOptions {
  final IconData? icon;
  final String name;
  final VoidCallback onPress;

  MenuItemOptions({
    required this.name,
    required this.onPress,
    this.icon,
  });
}

/// MenuItemComponent - A component for displaying a customizable menu item with an icon and name.
///
/// This component allows you to specify an icon, a label, and an action for each menu item,
/// making it ideal for constructing flexible and reusable menu lists.
///
/// ### Parameters:
/// - `options`: An instance of `MenuItemOptions`, containing:
///   - `icon` (optional): The icon to be displayed alongside the menu item name.
///   - `name`: The text label for the menu item.
///   - `onPress`: The callback function triggered when the menu item is tapped.
///
/// ### Example Usage:
/// ```dart
/// MenuItemComponent(
///   options: MenuItemOptions(
///     icon: Icons.coffee,
///     name: "Coffee",
///     onPress: () => print("Coffee selected"),
///   ),
/// );
/// ```
class MenuItemComponent extends StatelessWidget {
  final MenuItemOptions options;

  const MenuItemComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: options.onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            if (options.icon != null)
              Icon(options.icon, size: 20, color: Colors.white),
            if (options.icon != null) const SizedBox(width: 10),
            Text(
              options.name,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
