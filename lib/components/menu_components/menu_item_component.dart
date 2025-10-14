import 'package:flutter/material.dart';

/// Configuration options for the `MenuItemComponent` widget.
///
/// Defines the appearance and behavior of a single menu item in a list,
/// typically used within MenuModal or custom menu implementations.
///
/// **Properties:**
/// - `icon`: Optional IconData for leading icon (null = no icon displayed)
/// - `name`: Text label for the menu item (displayed after icon)
/// - `onPress`: Callback invoked when the menu item is tapped
///
/// **Common Configurations:**
/// ```dart
/// // 1. Menu item with icon
/// MenuItemOptions(
///   icon: Icons.settings,
///   name: "Settings",
///   onPress: () => openSettings(),
/// )
///
/// // 2. Menu item without icon
/// MenuItemOptions(
///   name: "Help & Support",
///   onPress: () => showHelp(),
/// )
/// ```
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

/// A stateless widget rendering a single menu item with optional icon and text label.
///
/// Displays a tappable menu row with an optional leading icon and text label.
/// Used as a building block for menu lists in MenuModal and custom menu implementations.
///
/// **Rendering Structure:**
/// ```
/// InkWell (onTap: onPress)
///   └─ Container (padding: 10px vertical)
///      └─ Row
///         ├─ Icon (if icon != null, 20px, white)
///         ├─ SizedBox(width: 10) (if icon != null)
///         └─ Text (name, 16px, white)
/// ```
///
/// **Common Use Cases:**
/// 1. **Menu with Icon:**
///    ```dart
///    MenuItemComponent(
///      options: MenuItemOptions(
///        icon: Icons.settings,
///        name: "Settings",
///        onPress: () {
///          Navigator.push(context, MaterialPageRoute(
///            builder: (_) => SettingsScreen(),
///          ));
///        },
///      ),
///    )
///    ```
///
/// 2. **Menu without Icon:**
///    ```dart
///    MenuItemComponent(
///      options: MenuItemOptions(
///        name: "About",
///        onPress: () => showAboutDialog(context),
///      ),
///    )
///    ```
///
/// 3. **Menu List:**
///    ```dart
///    Column(
///      children: [
///        MenuItemComponent(
///          options: MenuItemOptions(
///            icon: Icons.videocam,
///            name: "Video Settings",
///            onPress: () => openVideoSettings(),
///          ),
///        ),
///        MenuItemComponent(
///          options: MenuItemOptions(
///            icon: Icons.mic,
///            name: "Audio Settings",
///            onPress: () => openAudioSettings(),
///          ),
///        ),
///        MenuItemComponent(
///          options: MenuItemOptions(
///            icon: Icons.share,
///            name: "Share Event",
///            onPress: () => shareEvent(),
///          ),
///        ),
///      ],
///    )
///    ```
///
/// **Styling:**
/// - Icon: 20px, white color
/// - Text: 16px, white color, regular weight
/// - Padding: 10px vertical (symmetric)
/// - Icon-to-text spacing: 10px (if icon present)
///
/// **Interaction:**
/// - Uses InkWell for material ripple effect on tap
/// - onPress callback invoked immediately on tap
/// - No built-in loading state or disabled state
///
/// **Typical Usage Context:**
/// - Menu items in MenuModal
/// - Custom dropdown menus
/// - Settings lists
/// - Action sheets
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
