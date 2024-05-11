import 'package:flutter/material.dart';

/// MenuItemComponent - A component for displaying a menu item with an icon and name.
///
/// This component displays a menu item with an icon and name. Tapping on the item triggers a callback function.
///
/// The icon to be displayed.
/// final IconData icon;
///
/// The name of the menu item.
/// final String name;
///
/// The callback function to be executed when the menu item is pressed.
/// final VoidCallback onPress;

class MenuItemComponent extends StatelessWidget {
  final IconData icon;
  final String name;
  final VoidCallback onPress;

  const MenuItemComponent({
    super.key,
    required this.icon,
    required this.name,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
