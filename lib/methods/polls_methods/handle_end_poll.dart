import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

typedef ShowAlert = void Function(
    {required String message, required String type, required int duration});

Future<void> handleEndPoll({
  required String pollId,
  required Map<String, dynamic> parameters,
}) async {
  final io.Socket socket = parameters['socket'];
  final String roomName = parameters['roomName'];
  final ShowAlert? showAlert = parameters['showAlert'];

  try {
    socket.emitWithAck(
      'endPoll',
      {'roomName': roomName, 'poll_id': pollId},
      ack: (response) {
        if (response['success']) {
          if (showAlert != null) {
            showAlert(
              message: 'Poll ended successfully',
              type: 'success',
              duration: 3000,
            );
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
      print('Error ending poll: $error');
    }
  }
}
