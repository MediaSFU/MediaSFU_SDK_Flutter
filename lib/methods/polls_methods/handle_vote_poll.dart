import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show ShowAlert;
import 'package:flutter/foundation.dart';

/// Defines options for handling a poll vote.
class HandleVotePollOptions {
  final String pollId;
  final int optionIndex;
  final io.Socket? socket;
  final ShowAlert? showAlert;
  final String member;
  final String roomName;
  final void Function(bool) updateIsPollModalVisible;

  HandleVotePollOptions({
    required this.pollId,
    required this.optionIndex,
    this.socket,
    this.showAlert,
    required this.member,
    required this.roomName,
    required this.updateIsPollModalVisible,
  });
}

typedef HandleVotePollType = Future<void> Function(
    HandleVotePollOptions options);

/// Handles the voting process for a poll.
///
/// The function submits a vote to the server using the specified [HandleVotePollOptions].
///
/// Example:
/// ```dart
/// final options = HandleVotePollOptions(
///   pollId: 'poll123',
///   optionIndex: 1,
///   socket: socketInstance,
///   showAlert: (message) => print(message),
///   member: 'user1',
///   roomName: 'roomA',
///   updateIsPollModalVisible: (isVisible) => setPollModalVisible(isVisible),
/// );
/// await handleVotePoll(options);
/// ```
Future<void> handleVotePoll(HandleVotePollOptions options) async {
  try {
    options.socket!.emitWithAck(
      'votePoll',
      {
        'roomName': options.roomName,
        'poll_id': options.pollId,
        'member': options.member,
        'choice': options.optionIndex
      },
      ack: (response) {
        if (response['success']) {
          options.showAlert?.call(
            message: 'Vote submitted successfully',
            type: 'success',
            duration: 3000,
          );
          options.updateIsPollModalVisible(false);
        } else {
          options.showAlert?.call(
            message: response['reason'] ?? 'Failed to submit vote',
            type: 'danger',
            duration: 3000,
          );
        }
      },
    );
  } catch (error) {
    if (kDebugMode) {
      print('Error submitting vote: $error');
    }
  }
}
