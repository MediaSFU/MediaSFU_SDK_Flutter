typedef UpdateIsRequestsModalVisible = void Function(bool isVisible);

/// Parameters for launching requests in the app.
class LaunchRequestsOptions {
  final UpdateIsRequestsModalVisible updateIsRequestsModalVisible;
  final bool isRequestsModalVisible;

  LaunchRequestsOptions({
    required this.updateIsRequestsModalVisible,
    required this.isRequestsModalVisible,
  });
}

typedef LaunchRequestsType = void Function(LaunchRequestsOptions options);

/// Toggles the visibility state of the requests modal.
///
/// The [options] parameter should include:
/// - `updateIsRequestsModalVisible`: A function to update the visibility state of the requests modal.
/// - `isRequestsModalVisible`: A boolean indicating the current visibility state of the requests modal.
///
/// This function inverts the visibility state by passing the negated value of `isRequestsModalVisible`
/// to `updateIsRequestsModalVisible`.
///
/// Example:
/// ```dart
/// launchRequests(
///   LaunchRequestsOptions(
///     updateIsRequestsModalVisible: (isVisible) => print('Modal visible: $isVisible'),
///     isRequestsModalVisible: true,
///   ),
/// );
/// ```

void launchRequests(LaunchRequestsOptions options) {
  options.updateIsRequestsModalVisible(!options.isRequestsModalVisible);
}
