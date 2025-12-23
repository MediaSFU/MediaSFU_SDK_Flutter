/// Options for launching the configure whiteboard modal.
class LaunchConfigureWhiteboardOptions {
  /// Function to update the visibility state of the configure whiteboard modal.
  final void Function(bool) updateIsConfigureWhiteboardModalVisible;

  /// Current visibility state of the configure whiteboard modal.
  final bool isConfigureWhiteboardModalVisible;

  LaunchConfigureWhiteboardOptions({
    required this.updateIsConfigureWhiteboardModalVisible,
    required this.isConfigureWhiteboardModalVisible,
  });
}

/// Type definition for the launchConfigureWhiteboard function.
typedef LaunchConfigureWhiteboardType = void Function(
    LaunchConfigureWhiteboardOptions options);

/// Toggles the visibility of the configure whiteboard modal.
///
/// This function is typically called when the host wants to start, configure,
/// or end a whiteboard session. Only hosts (level 2) can access this functionality.
///
/// Example:
/// ```dart
/// launchConfigureWhiteboard(
///   LaunchConfigureWhiteboardOptions(
///     updateIsConfigureWhiteboardModalVisible: updateIsConfigureWhiteboardModalVisible,
///     isConfigureWhiteboardModalVisible: false,
///   ),
/// );
/// ```
void launchConfigureWhiteboard(LaunchConfigureWhiteboardOptions options) {
  // Toggle the visibility of the configure whiteboard modal
  options.updateIsConfigureWhiteboardModalVisible(
      !options.isConfigureWhiteboardModalVisible);
}
