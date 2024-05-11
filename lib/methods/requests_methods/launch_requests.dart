typedef UpdateIsRequestsModalVisible = void Function(bool isVisible);

/// Launches the requests with the given parameters.
///
/// The [parameters] map should contain the following keys:
/// - 'updateIsRequestsModalVisible': A function that updates the visibility state of the requests modal.
/// - 'isRequestsModalVisible': A boolean indicating the current visibility state of the requests modal.
///
/// This function toggles the visibility state of the requests modal by calling the [updateIsRequestsModalVisible]
/// function with the negation of the current visibility state.

void launchRequests({
  required Map<String, dynamic> parameters,
}) {
  final UpdateIsRequestsModalVisible updateIsRequestsModalVisible =
      parameters['updateIsRequestsModalVisible'];
  final bool isRequestsModalVisible = parameters['isRequestsModalVisible'];

  // Toggle the visibility state of the requests modal
  updateIsRequestsModalVisible(!isRequestsModalVisible);
}
