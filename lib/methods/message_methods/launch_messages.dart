/// Defines options for toggling the visibility of the messages modal.
class LaunchMessagesOptions {
  final void Function(bool visible) updateIsMessagesModalVisible;
  final bool isMessagesModalVisible;

  LaunchMessagesOptions({
    required this.updateIsMessagesModalVisible,
    required this.isMessagesModalVisible,
  });
}

/// Type definition for the function that toggles the messages modal.
typedef LaunchMessagesType = void Function(LaunchMessagesOptions options);

/// Toggles the visibility state of the messages modal.
///
/// This function calls `updateIsMessagesModalVisible` with the negated value of
/// `isMessagesModalVisible` to toggle the modal's visibility.
///
/// Example:
/// ```dart
/// final options = LaunchMessagesOptions(
///   updateIsMessagesModalVisible: (visible) => print("Messages modal visibility: $visible"),
///   isMessagesModalVisible: false,
/// );
///
/// launchMessages(options);
/// // This will open the messages modal if it's currently closed, or close it if it's open.
/// ```
void launchMessages(LaunchMessagesOptions options) {
  options.updateIsMessagesModalVisible(!options.isMessagesModalVisible);
}
