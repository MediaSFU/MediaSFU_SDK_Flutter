import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show ShowAlert, Poll;

/// Defines options for creating a poll in a room.
class HandleCreatePollOptions {
  final Poll poll;
  final io.Socket? socket;
  final String roomName;
  final ShowAlert? showAlert;
  final void Function(bool) updateIsPollModalVisible;

  HandleCreatePollOptions({
    required this.poll,
    this.socket,
    required this.roomName,
    this.showAlert,
    required this.updateIsPollModalVisible,
  });
}

typedef HandleCreatePollType = Future<void> Function(
    HandleCreatePollOptions options);

/// Handles the creation of a poll by emitting a "createPoll" event with the provided details.
/// Shows an alert based on the success or failure of the operation.
///
/// Example:
/// ```dart
/// final options = HandleCreatePollOptions(
///   poll: {'question': 'Favorite color?', 'type': 'singleChoice', 'options': ['Red', 'Blue', 'Green']},
///   socket: socketInstance,
///   roomName: 'roomA',
///   showAlert: (message) => print(message),
///   updateIsPollModalVisible: (isVisible) => setIsPollModalVisible(isVisible),
/// );
/// await handleCreatePoll(options);
/// ```
Future<void> handleCreatePoll(HandleCreatePollOptions options) async {
  try {
    var pollMap = options.poll.toMap();
    // keep only the question, type, and options
    pollMap.removeWhere(
        (key, value) => key != 'question' && key != 'type' && key != 'options');

    options.socket!.emitWithAck(
      'createPoll',
      {'roomName': options.roomName, 'poll': pollMap},
      ack: (response) {
        if (response['success']) {
          options.showAlert?.call(
            message: 'Poll created successfully',
            type: 'success',
            duration: 3000,
          );
          options.updateIsPollModalVisible(false);
        } else {
          options.showAlert?.call(
            message: response['reason'] ?? 'Failed to create poll',
            type: 'danger',
            duration: 3000,
          );
        }
      },
    );
  } catch (error) {
    if (kDebugMode) {
      print('Error creating poll: $error');
    }
  }
}
