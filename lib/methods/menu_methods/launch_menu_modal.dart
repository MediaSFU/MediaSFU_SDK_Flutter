/// Defines options for toggling the visibility of the menu modal.
class LaunchMenuModalOptions {
  final void Function(bool isVisible) updateIsMenuModalVisible;
  final bool isMenuModalVisible;

  LaunchMenuModalOptions({
    required this.updateIsMenuModalVisible,
    required this.isMenuModalVisible,
  });
}

/// Type definition for the function that toggles the menu modal.
typedef LaunchMenuModalType = void Function(LaunchMenuModalOptions options);

/// Toggles the visibility of the menu modal.
///
/// This function calls `updateIsMenuModalVisible` with the negated value of
/// `isMenuModalVisible` to toggle the modal's visibility.
///
/// Example:
/// ```dart
/// final options = LaunchMenuModalOptions(
///   updateIsMenuModalVisible: (isVisible) => print("Menu modal visibility: $isVisible"),
///   isMenuModalVisible: false,
/// );
///
/// launchMenuModal(options);
/// // This will open the modal if it's currently closed, or close it if it's open.
/// ```
void launchMenuModal(LaunchMenuModalOptions options) {
  options.updateIsMenuModalVisible(!options.isMenuModalVisible);
}
