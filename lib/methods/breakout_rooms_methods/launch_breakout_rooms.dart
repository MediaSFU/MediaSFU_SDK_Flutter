/// Defines options for launching breakout rooms, including the function to
/// update visibility and the current modal visibility state.
class LaunchBreakoutRoomsOptions {
  final void Function(bool isVisible) updateIsBreakoutRoomsModalVisible;
  final bool isBreakoutRoomsModalVisible;

  LaunchBreakoutRoomsOptions({
    required this.updateIsBreakoutRoomsModalVisible,
    required this.isBreakoutRoomsModalVisible,
  });
}

/// Type definition for the function that launches breakout rooms.
typedef LaunchBreakoutRoomsType = void Function(
    LaunchBreakoutRoomsOptions options);

/// Launches the breakout rooms by toggling the visibility of the breakout rooms modal.
///
/// This function calls `updateIsBreakoutRoomsModalVisible` with the negated value of
/// `isBreakoutRoomsModalVisible` to toggle the modal's visibility.
///
/// Example:
/// ```dart
/// final options = LaunchBreakoutRoomsOptions(
///   updateIsBreakoutRoomsModalVisible: (bool isVisible) {
///     // Update visibility here
///   },
///   isBreakoutRoomsModalVisible: false,
/// );
///
/// launchBreakoutRooms(options);
/// // Toggles the breakout rooms modal to visible.
/// ```
void launchBreakoutRooms(LaunchBreakoutRoomsOptions options) {
  options
      .updateIsBreakoutRoomsModalVisible(!options.isBreakoutRoomsModalVisible);
}
