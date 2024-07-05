import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

typedef ShowAlert = void Function(
    {required String message, required String type, required int duration});
typedef UpdateIsPollModalVisible = void Function(bool visible);

Future<void> handleVotePoll({
  required String pollId,
  required int optionIndex,
  required Map<String, dynamic> parameters,
}) async {
  final io.Socket socket = parameters['socket'];
  final String roomName = parameters['roomName'];
  final String member = parameters['member'];
  final ShowAlert? showAlert = parameters['showAlert'];
  final UpdateIsPollModalVisible updateIsPollModalVisible =
      parameters['updateIsPollModalVisible'];

  try {
    socket.emitWithAck(
      'votePoll',
      {
        'roomName': roomName,
        'poll_id': pollId,
        'member': member,
        'choice': optionIndex
      },
      ack: (response) {
        if (response['success']) {
          if (showAlert != null) {
            showAlert(
              message: 'Vote submitted successfully',
              type: 'success',
              duration: 3000,
            );
            updateIsPollModalVisible(false);
          }
        } else {
          if (showAlert != null) {
            showAlert(
              message: response['reason'],
              type: 'danger',
              duration: 3000,
            );
          }
        }
      },
    );
  } catch (error) {
    if (kDebugMode) {
      print('Error submitting vote: $error');
    }
  }
}
