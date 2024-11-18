import 'package:flutter/foundation.dart';
import '../../types/types.dart' show ShowAlert;

/// Represents the options for the user waiting event, including user details and alert/updating functions.
class UserWaitingOptions {
  final String name;
  final ShowAlert? showAlert;
  final int totalReqWait;
  final void Function(int) updateTotalReqWait;

  UserWaitingOptions({
    required this.name,
    this.showAlert,
    required this.totalReqWait,
    required this.updateTotalReqWait,
  });
}

typedef UserWaitingType = void Function(UserWaitingOptions options);

/// Handles the event when a user joins the waiting room.
///
/// This function displays a notification if `showAlert` is provided and increments
/// the waiting room request count by calling `updateTotalReqWait`.
///
/// Example usage:
/// ```dart
/// userWaiting(UserWaitingOptions(
///   name: "John Doe",
///   showAlert: (message, type, duration) => print("Alert: $message"),
///   totalReqWait: 3,
///   updateTotalReqWait: (total) => print("Updated total: $total"),
/// ));
/// ```

void userWaiting(UserWaitingOptions options) {
  try {
    // Display alert if provided
    options.showAlert?.call(
      message: '${options.name} joined the waiting room.',
      type: 'success',
      duration: 3000,
    );

    // Increment the total waiting requests and update
    final updatedTotalReqWait = options.totalReqWait + 1;
    options.updateTotalReqWait(updatedTotalReqWait);
  } catch (error) {
    if (kDebugMode) {
      print("Error in userWaiting: $error");
    }
  }
}
