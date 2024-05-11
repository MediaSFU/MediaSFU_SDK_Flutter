/// Launches the menu modal and updates its visibility state.
///
/// This function takes two parameters:
/// - `updateIsMenuModalVisible`: A required function that takes a boolean parameter and updates the visibility state of the menu modal.
/// - `isMenuModalVisible`: A required boolean parameter that represents the current visibility state of the menu modal.
///
/// When called, this function will open or close the menu modal based on the current visibility state.
library;

void launchMenuModal(
    {required Function(bool) updateIsMenuModalVisible,
    required bool isMenuModalVisible}) {
  // Open or close the menu modal based on the current visibility state
  updateIsMenuModalVisible(!isMenuModalVisible);
}
