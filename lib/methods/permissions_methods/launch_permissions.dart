/// launchPermissions - Toggles the visibility of the permissions modal.
///
/// Example:
/// ```dart
/// launchPermissions(LaunchPermissionsOptions(
///   updateIsPermissionsModalVisible: (visible) => setState(() => isPermissionsModalVisible = visible),
///   isPermissionsModalVisible: false,
/// ));
/// ```
library;

class LaunchPermissionsOptions {
  final void Function(bool) updateIsPermissionsModalVisible;
  final bool isPermissionsModalVisible;

  LaunchPermissionsOptions({
    required this.updateIsPermissionsModalVisible,
    required this.isPermissionsModalVisible,
  });
}

typedef LaunchPermissionsType = void Function(LaunchPermissionsOptions options);

void launchPermissions(LaunchPermissionsOptions options) {
  options.updateIsPermissionsModalVisible(!options.isPermissionsModalVisible);
}
