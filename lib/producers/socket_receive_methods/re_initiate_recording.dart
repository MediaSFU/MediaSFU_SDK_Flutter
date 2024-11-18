import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Options for re-initiating recording, including room details, the member initiating the recording,
/// the socket connection to the server, and an optional admin restriction setting.
class ReInitiateRecordingOptions {
  final String roomName; // The name of the room to start recording
  final String member; // The member who is initiating the recording
  final io.Socket? socket; // The socket instance for server communication
  final bool
      adminRestrictSetting; // Determines if admin restrictions prevent re-initiation

  ReInitiateRecordingOptions({
    required this.roomName,
    required this.member,
    this.socket,
    this.adminRestrictSetting = false,
  });
}

typedef ReInitiateRecordingType = Future<void> Function(
    ReInitiateRecordingOptions options);

/// Re-initiates the recording for a specified room and member.
///
/// This function sends a request to the server to start recording for a specific room and member. If the
/// `adminRestrictSetting` option is set to `false`, the recording re-initiation request will be sent
/// through the socket connection. Upon completion, the server responds with success or failure, which can be
/// handled within the function or in the calling context.
///
/// Parameters:
/// - [options] - An instance of [ReInitiateRecordingOptions], containing:
///   - `roomName`: Name of the room to start recording.
///   - `member`: Name of the member initiating the recording.
///   - `socket`: The socket instance for server communication.
///   - `adminRestrictSetting`: Boolean flag that, when true, prevents the recording from being re-initiated.
///
/// Example usage:
/// ```dart
/// final options = ReInitiateRecordingOptions(
///   roomName: 'meetingRoom123',
///   member: 'adminUser',
///   socket: socketInstance,
///   adminRestrictSetting: false,
/// );
///
/// reInitiateRecording(options).then((_) {
///   print("Re-initiate recording attempt completed.");
/// }).catchError((error) {
///   print("Failed to re-initiate recording: $error");
/// });
/// ```
///
/// If the re-initiation attempt is successful, further success handling logic can be implemented as needed.
/// If the attempt fails, handle the failure within the function or in the calling context.
///
/// Returns:
/// - A [Future<void>] that completes when the request to re-initiate recording is sent.
Future<void> reInitiateRecording(ReInitiateRecordingOptions options) async {
  // Check if admin restrictions allow recording re-initiation
  if (!options.adminRestrictSetting) {
    options.socket!.emitWithAck(
      'startRecordIng',
      {'roomName': options.roomName, 'member': options.member},
      ack: (dynamic data) {
        bool success = data['success'] ?? false;
        if (success) {
          // Handle successful re-initiation, if needed
        } else {
          // Handle failed re-initiation, if needed
        }
      },
    );
  }
}
