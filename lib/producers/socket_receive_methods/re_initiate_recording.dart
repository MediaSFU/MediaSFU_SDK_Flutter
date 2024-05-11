import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Re-initiates recording for a given room and member.
///
/// This function sends a request to the server to start recording for a specific room and member.
/// If the `adminRestrictSetting` parameter is `false`, the request will be sent.
/// If the request is successful, the appropriate success handling logic can be implemented.
/// If the request fails, the appropriate failure handling logic can be implemented.
///
/// Parameters:
/// - `parameters`: A map containing the following required keys:
///   - `roomName`: The name of the room to start recording.
///   - `member`: The member for whom the recording should be started.
///   - `socket`: The socket connection to the server.
///   - `adminRestrictSetting`: (optional) A boolean indicating whether the admin restricts the setting. Defaults to `false`.
///
/// Returns: A `Future` that completes when the request is sent.
Future<void> reInitiateRecording(
    {required Map<String, dynamic> parameters}) async {
  String roomName = parameters['roomName'];
  String member = parameters['member'];
  io.Socket socket = parameters['socket'];
  bool adminRestrictSetting = parameters['adminRestrictSetting'] ?? false;

  // Function to re-initiate recording
  if (!adminRestrictSetting) {
    socket
        .emitWithAck('startRecordIng', {'roomName': roomName, 'member': member},
            ack: (dynamic data) {
      bool success = data['success'] ?? false;
      if (success) {
        // Handle success, if needed
      } else {
        // Handle failure, if needed
      }
    });
  }
}
