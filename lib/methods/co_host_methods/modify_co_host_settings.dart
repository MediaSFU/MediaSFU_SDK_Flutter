import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show ShowAlert, CoHostResponsibility;

/// Defines the options for modifying co-host settings.
class ModifyCoHostSettingsOptions {
  final String roomName;
  final ShowAlert? showAlert;
  final String selectedParticipant;
  final String coHost;
  final List<CoHostResponsibility> coHostResponsibility;
  final void Function(bool) updateIsCoHostModalVisible;
  final void Function(List<CoHostResponsibility>) updateCoHostResponsibility;
  final void Function(String) updateCoHost;
  final io.Socket? socket;

  ModifyCoHostSettingsOptions({
    required this.roomName,
    this.showAlert,
    required this.selectedParticipant,
    required this.coHost,
    required this.coHostResponsibility,
    required this.updateIsCoHostModalVisible,
    required this.updateCoHostResponsibility,
    required this.updateCoHost,
    this.socket,
  });
}

/// Type definition for modifying co-host settings.
typedef ModifyCoHostSettingsType = Future<void> Function(
    ModifyCoHostSettingsOptions options);

/// Modifies the co-host settings for a specified room.
///
/// This function allows updating the co-host settings by selecting a participant,
/// setting co-host responsibilities, and emitting an update event via socket.
///
/// If the room is in demo mode, an alert is shown instead.
///
/// Example:
/// ```dart
/// final options = ModifyCoHostSettingsOptions(
///   roomName: 'mainRoom',
///   showAlert: (alert) => print(alert.message),
///   selectedParticipant: 'User123',
///   coHost: 'No coHost',
///   coHostResponsibility: [CoHostResponsibility(name: 'media', value: true)],
///   updateIsCoHostModalVisible: (isVisible) => print("Modal visibility: $isVisible"),
///   updateCoHostResponsibility: (responsibilities) => print("Updated responsibilities"),
///   updateCoHost: (newCoHost) => print("New co-host: $newCoHost"),
///   socket: socketInstance,
/// );
///
/// await modifyCoHostSettings(options);
/// // Updates co-host settings and emits the event to the server.
/// ```
Future<void> modifyCoHostSettings(ModifyCoHostSettingsOptions options) async {
  // Check if the room is in demo mode
  if (options.roomName.toLowerCase().startsWith('d')) {
    options.showAlert?.call(
      message: 'You cannot add a co-host in demo mode.',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  String newCoHost = options.coHost;

  if (options.coHost != 'No coHost' ||
      (options.selectedParticipant.isNotEmpty &&
          options.selectedParticipant != 'Select a participant')) {
    if (options.selectedParticipant.isNotEmpty &&
        options.selectedParticipant != 'Select a participant') {
      newCoHost = options.selectedParticipant;
      options.updateCoHost(newCoHost);
    }

    options.updateCoHostResponsibility(options.coHostResponsibility);

    List<Map<String, dynamic>> coHostResponsibilityMap = [];

    coHostResponsibilityMap =
        options.coHostResponsibility.map((item) => item.toMap()).toList();

    // Emit socket event to update co-host information
    options.socket!.emit('updateCoHost', {
      'roomName': options.roomName,
      'coHost': newCoHost,
      'coHostResponsibility': coHostResponsibilityMap,
    });
  }

  // Close the co-host modal
  options.updateIsCoHostModalVisible(false);
}
