/// Launches the co-host functionality.
///
/// This function takes a map of parameters, which should include the following:
/// - `updateIsCoHostModalVisible`: A function that updates the visibility state of the co-host modal.
/// - `isCoHostModalVisible`: A boolean indicating the current visibility state of the co-host modal.
///
/// The function opens or closes the co-host modal based on its current visibility state.
void launchCoHost({required Map<String, dynamic> parameters}) {
  final Function updateIsCoHostModalVisible =
      parameters['updateIsCoHostModalVisible'];
  final bool isCoHostModalVisible = parameters['isCoHostModalVisible'];

  // Open or close the co-host modal based on its current visibility state
  updateIsCoHostModalVisible(!isCoHostModalVisible);
}
