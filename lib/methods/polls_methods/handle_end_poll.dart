import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show ShowAlert;

/// Defines options for handling the end of a poll.
class HandleEndPollOptions {
  final String pollId;
  final io.Socket? socket;
  final ShowAlert? showAlert;
  final String roomName;
  final void Function(bool) updateIsPollModalVisible;

  HandleEndPollOptions({
    required this.pollId,
    this.socket,
    this.showAlert,
    required this.roomName,
    required this.updateIsPollModalVisible,
  });
}

typedef HandleEndPollType = Future<void> Function(HandleEndPollOptions options);

/// Handles ending a poll by emitting an "endPoll" event through the provided socket.
/// Displays an alert based on the success or failure of the operation.
///
/// Example:
/// ```dart
/// final options = HandleEndPollOptions(
///   pollId: 'poll123',
///   socket: socketInstance,
///   showAlert: (message) => print(message),
///   roomName: 'roomA',
///   updateIsPollModalVisible: (isVisible) => setIsPollModalVisible(isVisible),
/// );
/// await handleEndPoll(options);
/// ```
Future<void> handleEndPoll(HandleEndPollOptions options) async {
  try {
    options.socket!.emitWithAck(
      'endPoll',
      {'roomName': options.roomName, 'poll_id': options.pollId},
      ack: (response) {
        if (response['success']) {
          options.showAlert?.call(
            message: 'Poll ended successfully',
            type: 'success',
            duration: 3000,
          );
          options.updateIsPollModalVisible(false);
        } else {
          options.showAlert?.call(
            message: response['reason'] ?? 'Failed to end poll',
            type: 'danger',
            duration: 3000,
          );
        }
      },
    );
  } catch (error) {
    if (kDebugMode) {
      print('Error ending poll: $error');
    }
  }
}
