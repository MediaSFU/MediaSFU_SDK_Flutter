typedef UpdateIsPollModalVisible = void Function(bool isVisible);

/// Defines options for toggling the poll modal visibility.
class LaunchPollOptions {
  final UpdateIsPollModalVisible updateIsPollModalVisible;
  final bool isPollModalVisible;

  LaunchPollOptions({
    required this.updateIsPollModalVisible,
    required this.isPollModalVisible,
  });
}

/// Type definition for the function that toggles the poll modal visibility.
typedef LaunchPollType = void Function(LaunchPollOptions options);

/// Toggles the visibility of the poll modal based on the current state.
///
/// This function accepts [LaunchPollOptions] and toggles the visibility state
/// by calling [updateIsPollModalVisible] with the negation of [isPollModalVisible].
///
/// Example:
/// ```dart
/// final options = LaunchPollOptions(
///   updateIsPollModalVisible: (visible) => setPollModalVisible(visible),
///   isPollModalVisible: false,
/// );
///
/// launchPoll(options);
/// ```
void launchPoll(LaunchPollOptions options) {
  // Toggle the visibility state of the poll modal
  options.updateIsPollModalVisible(!options.isPollModalVisible);
}
