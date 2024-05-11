import 'package:flutter/foundation.dart';

/// Handles the event when a user joins the waiting room.
///
/// The [ShowAlert] typedef represents a function that shows an alert or notification.
/// It takes in a [message] (String), [type] (String), and [duration] (int) as required parameters.
///
/// The [UpdateTotalReqWait] typedef represents a function that updates the total number of requests waiting in the waiting room.
/// It takes in an [int] as a parameter.
///
/// The [userWaiting] function takes in a [name] (String) and [parameters] (Map<String, dynamic>) as required parameters.
/// It is an asynchronous function that handles the event when a user joins the waiting room.
/// It destructures the [parameters] map to get the required values and performs the necessary actions.
/// It displays an alert/notification about the user joining the waiting room using the [showAlert] function.
/// It updates the total number of requests waiting in the waiting room using the [updateTotalReqWait] function.
/// Any errors that occur during the execution of the function are caught and handled accordingly.

/// Handles the event when a user joins the waiting room.
///
typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef UpdateTotalReqWait = void Function(int totalReqWait);

void userWaiting({
  required String name,
  required Map<String, dynamic> parameters,
}) async {
  try {
    // Destructure parameters
    final ShowAlert? showAlert = parameters['showAlert'];
    final List? requestsList = parameters['requestsList'] ?? [];
    final List waitingRoomList = parameters['waitingRoomList'] ?? [];
    int totalReqWait = parameters['totalReqWait'];
    final UpdateTotalReqWait updateTotalReqWait =
        parameters['updateTotalReqWait'];

    // Display an alert/notification about the user joining the waiting room
    if (showAlert != null) {
      showAlert(
        message: '$name has joined the waiting room',
        type: 'info',
        duration: 3000,
      );
    }

    // Update the total number of requests waiting in the waiting room
    totalReqWait = requestsList!.length + waitingRoomList.length;
    updateTotalReqWait(totalReqWait);
  } catch (error) {
    if (kDebugMode) {
      // print("Error in userWaiting: $error");
    }
    // Handle error accordingly
  }
}
