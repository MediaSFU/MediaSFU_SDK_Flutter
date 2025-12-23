/// launchPanelists - Toggles the visibility of the panelists modal.
///
/// Example:
/// ```dart
/// launchPanelists(LaunchPanelistsOptions(
///   updateIsPanelistsModalVisible: (visible) => setState(() => isPanelistsModalVisible = visible),
///   isPanelistsModalVisible: false,
/// ));
/// ```
library;

class LaunchPanelistsOptions {
  final void Function(bool) updateIsPanelistsModalVisible;
  final bool isPanelistsModalVisible;

  LaunchPanelistsOptions({
    required this.updateIsPanelistsModalVisible,
    required this.isPanelistsModalVisible,
  });
}

typedef LaunchPanelistsType = void Function(LaunchPanelistsOptions options);

void launchPanelists(LaunchPanelistsOptions options) {
  options.updateIsPanelistsModalVisible(!options.isPanelistsModalVisible);
}
