import 'package:socket_io_client/socket_io_client.dart' as io;

/// Modifies the co-host settings for a chat room.
///
/// This function takes a map of parameters including the room name, co-host information,
/// and various callback functions. It performs the following steps:
///
/// 1. Checks if the chat room is in demo mode. If so, it displays an alert message and returns.
/// 2. Updates the co-host information based on the selected participant or the provided co-host value.
/// 3. Updates the co-host responsibilities.
/// 4. Emits a socket event to update the co-host information on the server.
/// 5. Closes the co-host modal.
///
/// The function requires the following parameters:
/// - `parameters`: A map containing the following keys:
///   - `roomName`: The name of the chat room.
///   - `showAlert`: A function to display an alert message.
///   - `selectedParticipant`: The selected participant for the co-host role.
///   - `coHost`: The current co-host value.
///   - `coHostResponsibility`: A list of co-host responsibilities.
///   - `updateIsCoHostModalVisible`: A function to update the visibility of the co-host modal.
///   - `updateCoHostResponsibility`: A function to update the co-host responsibilities.
///   - `updateCoHost`: A function to update the co-host value.
///   - `socket`: The socket object for communication with the server.
///
/// Example usage:
/// ```dart
/// modifyCoHostSettings(parameters: {
///   'roomName': 'exampleRoom',
///   'showAlert': showAlertFunction,
///   'selectedParticipant': 'John Doe',
///   'coHost': 'No coHost',
///   'coHostResponsibility': ['Manage participants', 'Moderate chat'],
///   'updateIsCoHostModalVisible': updateModalVisibilityFunction,
///   'updateCoHostResponsibility': updateResponsibilityFunction,
///   'updateCoHost': updateCoHostFunction,
///   'socket': socketObject,
/// });
///

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

void modifyCoHostSettings({required Map<String, dynamic> parameters}) async {
  final String roomName = parameters['roomName'];
  final ShowAlert? showAlert = parameters['showAlert'];
  final String selectedParticipant = parameters['selectedParticipant'] ?? '';
  final String coHost = parameters['coHost'];
  final List<dynamic> coHostResponsibility = parameters['coHostResponsibility'];
  final void Function(bool) updateIsCoHostModalVisible =
      parameters['updateIsCoHostModalVisible'];
  final void Function(List<dynamic>) updateCoHostResponsibility =
      parameters['updateCoHostResponsibility'];
  final void Function(String) updateCoHost = parameters['updateCoHost'];
  final io.Socket socket = parameters['socket'];

  // Check if the chat room is in demo mode
  if (roomName.toLowerCase().startsWith('d')) {
    if (showAlert != null) {
      showAlert(
        message: 'You cannot add co-host in demo mode.',
        type: 'danger',
        duration: 3000,
      );
    }
    return;
  }

  String newCoHost = coHost;

  if (coHost != 'No coHost' ||
      (selectedParticipant.isNotEmpty &&
          selectedParticipant != 'Select a participant')) {
    if (selectedParticipant.isNotEmpty &&
        selectedParticipant != 'Select a participant') {
      newCoHost = selectedParticipant;
      updateCoHost(newCoHost);
    }

    updateCoHostResponsibility(coHostResponsibility);

    // Emit a socket event to update co-host information
    socket.emit('updateCoHost', {
      'roomName': roomName,
      'coHost': newCoHost,
      'coHostResponsibility': coHostResponsibility
    });
  }

  // Close the co-host modal
  updateIsCoHostModalVisible(false);
}
