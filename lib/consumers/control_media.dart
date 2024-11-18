import 'package:socket_io_client/socket_io_client.dart' as io;
import '../types/types.dart' show CoHostResponsibility, Participant, ShowAlert;
import 'package:flutter/foundation.dart';

/// Represents the options for controlling media in a room.
class ControlMediaOptions {
  final String participantId;
  final String participantName;
  final String type; // 'audio' | 'video' | 'screenshare' | 'all'
  final io.Socket? socket;
  final List<CoHostResponsibility> coHostResponsibility;
  final List<Participant> participants;
  final String member;
  final String islevel;
  final ShowAlert? showAlert;
  final String coHost;
  final String roomName;

  ControlMediaOptions({
    required this.participantId,
    required this.participantName,
    required this.type,
    this.socket,
    required this.coHostResponsibility,
    required this.participants,
    required this.member,
    required this.islevel,
    this.showAlert,
    required this.coHost,
    required this.roomName,
  });
}

// Type definition for the controlMedia function
typedef ControlMediaType = Future<void> Function(ControlMediaOptions options);

/// Controls media for a participant in a room by sending a `controlMedia` event to the server.
///
/// This function allows specific users, like admins and authorized co-hosts, to manage the media
/// (audio, video, screenshare, or all) for other participants in a room. The function checks
/// permissions based on participant level, co-host responsibilities, and media type before
/// sending a control request to the server. Unauthorized users receive an alert instead.
///
/// ### Parameters:
/// - `options` (`ControlMediaOptions`): Configuration and details for controlling media, including:
///   - `participantId` (`String`): The unique ID of the participant whose media is being controlled.
///   - `participantName` (`String`): The name of the participant.
///   - `type` (`String`): Type of media to control, one of 'audio', 'video', 'screenshare', or 'all'.
///   - `socket` (`io.Socket`): The socket connection for communication.
///   - `coHostResponsibility` (`List<CoHostResponsibility>`): Responsibilities assigned to the co-host.
///   - `participants` (`List<Participant>`): List of participants in the room.
///   - `member` (`String`): Current user’s ID.
///   - `islevel` (`String`): Level of control for the current user (e.g., admin level).
///   - `showAlert` (`ShowAlert?`): Optional function for showing alerts to the user.
///   - `coHost` (`String`): ID of the co-host.
///   - `roomName` (`String`): Name of the room where the control action is being performed.
///
/// ### Logic Flow:
/// 1. **Permission Check**:
///    - Checks if the current user has permission to control media by verifying admin level or
///      co-host responsibilities.
/// 2. **Participant Lookup**:
///    - Searches for the specified participant in the room. If not found, the function logs an error and exits.
/// 3. **Media Type and Status Check**:
///    - Based on the specified media `type`, checks the current state (e.g., if the participant is muted).
/// 4. **Emit Control Event**:
///    - If the user has permission and conditions are met, emits a `controlMedia` event with media details.
///    - If the user lacks permission, displays an alert.
///
/// ### Throws:
/// - `Exception`: Logs an error if an issue occurs while attempting to control media.
///
/// ### Example:
/// ```dart
/// final options = ControlMediaOptions(
///   participantId: 'participant-123',
///   participantName: 'John Doe',
///   type: 'audio',
///   socket: socket,
///   coHostResponsibility: myCoHostResponsibility,
///   participants: myParticipants,
///   member: 'user-456',
///   islevel: '1',
///   showAlert: (alert) => print(alert['message']),
///   coHost: 'cohost-789',
///   roomName: 'Room 1',
/// );
///
/// controlMedia(options).then(() {
///   print('Media control action executed successfully');
/// }).catchError((error) {
///   print('Error controlling media: $error');
/// });
/// ```
///
/// ### Notes:
/// - Only participants with sufficient permission (admin or authorized co-hosts) can control media.
/// - An alert is displayed for unauthorized attempts.

Future<void> controlMedia(ControlMediaOptions options) async {
  try {
    bool mediaValue = false;

    // Check co-host responsibilities for media control
    try {
      mediaValue = options.coHostResponsibility
          .firstWhere((item) => item.name == 'media')
          .value;
    } catch (error) {
      if (kDebugMode) {
        print('Error retrieving media control value: $error');
      }
    }

    // Find the participant by name
    Participant? participant = options.participants.firstWhere(
        (obj) => obj.name == options.participantName,
        orElse: () => Participant(id: '', name: '', audioID: '', videoID: ''));

    if (participant.name.isEmpty) {
      if (kDebugMode) {
        print('Participant not found');
      }
      return;
    }

    // Check permissions and media type conditions
    if (options.islevel == '2' ||
        (options.coHost == options.member && mediaValue)) {
      if ((!participant.muted! &&
              participant.islevel != '2' &&
              options.type == 'audio') ||
          (participant.islevel != '2' &&
              options.type == 'video' &&
              participant.videoOn!)) {
        // Emit controlMedia event to the server
        options.socket!.emit('controlMedia', {
          'participantId': options.participantId,
          'participantName': options.participantName,
          'type': options.type,
          'roomName': options.roomName,
        });
      }
    } else {
      // Show an alert if the user is not allowed to control media
      options.showAlert?.call(
        message: 'You are not allowed to control media for other participants.',
        type: 'danger',
        duration: 3000,
      );
    }
  } catch (error, stackTrace) {
    if (kDebugMode) {
      print('controlMedia error: $error $stackTrace');
    }
  }
}
