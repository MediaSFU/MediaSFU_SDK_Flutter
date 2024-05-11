// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Controls media for a participant in a room.
///
/// This function sends a controlMedia event to the server to control the media
/// (audio or video) for a participant in a room. It checks if the participant
/// is allowed to control media based on their role and the room settings.
///
/// Parameters:
/// - [participantId]: The ID of the participant.
/// - [participantName]: The name of the participant.
/// - [type]: The type of media to control (audio or video).
/// - [parameters]: Additional parameters for controlling media.
///
/// Throws:
/// - [Exception]: If an error occurs while controlling media.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

Future<void> controlMedia({
  required String participantId,
  required String participantName,
  required String type,
  required Map<String, dynamic> parameters,
}) async {
  try {
    // Destructure parameters
    io.Socket socket = parameters['socket'];
    final coHostResponsibility = parameters['coHostResponsibility'];
    final List<dynamic> participants = parameters['participants'];
    final String member = parameters['member'];
    final String islevel = parameters['islevel'] ?? '1';
    ShowAlert? showAlert = parameters['showAlert'];
    final String coHost = parameters['coHost'] ?? '';
    final String roomName = parameters['roomName'];

    bool mediaValue = false;

    try {
      mediaValue = coHostResponsibility
          .firstWhere((item) => item['name'] == 'media')['value'];
    } catch (error) {}

    final participant =
        participants.firstWhere((obj) => obj['name'] == participantName);

    if (islevel == '2' || (coHost == member && mediaValue == true)) {
      // Check if the participant is not muted and is not a host
      if ((!participant['muted'] &&
              participant['islevel'] != '2' &&
              type == 'audio') ||
          (participant['islevel'] != '2' &&
              type == 'video' &&
              participant['videoOn'])) {
        // Emit controlMedia event to the server
        socket.emit('controlMedia', {
          'participantId': participantId,
          'participantName': participantName,
          'type': type,
          'roomName': roomName
        });
      }
    } else {
      // Display an alert if the participant is not allowed to mute other participants
      if (showAlert != null) {
        showAlert(
          message:
              'You are not allowed to control media for other participants.',
          type: 'danger',
          duration: 3000,
        );
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - controlMedia error $error');
    }
    // throw error;
  }
}
