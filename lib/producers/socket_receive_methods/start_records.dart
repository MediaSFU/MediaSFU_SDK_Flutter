import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Options for starting a recording.
class StartRecordsOptions {
  final String roomName;
  final String member;
  final io.Socket? socket;

  StartRecordsOptions({
    required this.roomName,
    required this.member,
    this.socket,
  });
}

/// Type definition for the start recording function.
typedef StartRecordsType = Future<void> Function(StartRecordsOptions options);

/// Starts recording for a specified room.
///
/// @param [StartRecordsOptions] options - Configuration options to start the recording.
/// - `roomName`: The name of the room to record.
/// - `member`: The name of the member initiating the recording.
/// - `socket`: The socket instance to communicate with the server.
///
/// @returns [Future<void>] A promise that resolves when the attempt to start recording completes.
///
/// Example usage:
/// ```dart
/// final options = StartRecordsOptions(
///   roomName: "RoomA",
///   member: "AdminUser",
///   socket: socketInstance,
/// );
///
/// startRecords(options).then((_) {
///   print("Recording started successfully");
/// }).catchError((error) {
///   print("Failed to start recording: $error");
/// });
/// ```

Future<void> startRecords(StartRecordsOptions options) async {
  try {
    // Emit 'startRecording' event with roomName and member information
    options.socket!.emitWithAck(
      'startRecordIng',
      {
        'roomName': options.roomName,
        'member': options.member,
      },
      ack: (data) {
        if (data is Map && data['success'] == true) {
          if (kDebugMode) {
            print('Recording started successfully');
          }
        } else {
          if (kDebugMode) {
            print('Failed to start recording');
          }
        }
      },
    );
  } catch (error) {
    if (kDebugMode) {
      print("Error in startRecords: $error");
    }
  }
}
