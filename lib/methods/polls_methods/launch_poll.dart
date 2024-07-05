typedef UpdateIsPollModalVisible = void Function(bool isVisible);

/// Launches the polls with the given parameters.
///
/// The [parameters] map should contain the following keys:
/// - 'updateIsPollModalVisible': A function that updates the visibility state of the polls modal.
/// - 'isPollModalVisible': A boolean indicating the current visibility state of the polls modal.
///
/// This function toggles the visibility state of the polls modal by calling the [updateIsPollModalVisible]
/// function with the negation of the current visibility state.

void launchPoll({
  required Map<String, dynamic> parameters,
}) {
  final UpdateIsPollModalVisible updateIsPollModalVisible =
      parameters['updateIsPollModalVisible'];
  final bool isPollModalVisible = parameters['isPollModalVisible'];

  // Toggle the visibility state of the polls modal
  updateIsPollModalVisible(!isPollModalVisible);
}
