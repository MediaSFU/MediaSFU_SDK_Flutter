typedef UpdateIsBreakoutRoomsModalVisible = void Function(bool isVisible);

/// Launches the breakoutrooms with the given parameters.
///
/// The [parameters] map should contain the following keys:
/// - 'updateIsBreakoutRoomsModalVisible': A function that updates the visibility state of the breakoutrooms modal.
/// - 'isBreakoutRoomsModalVisible': A boolean indicating the current visibility state of the breakoutrooms modal.
///
/// This function toggles the visibility state of the breakoutrooms modal by calling the [updateIsBreakoutRoomsModalVisible]
/// function with the negation of the current visibility state.

void launchBreakoutRooms({
  required Map<String, dynamic> parameters,
}) {
  final UpdateIsBreakoutRoomsModalVisible updateIsBreakoutRoomsModalVisible =
      parameters['updateIsBreakoutRoomsModalVisible'];
  final bool isBreakoutRoomsModalVisible =
      parameters['isBreakoutRoomsModalVisible'];

  // Toggle the visibility state of the breakoutrooms modal
  updateIsBreakoutRoomsModalVisible(!isBreakoutRoomsModalVisible);
}
