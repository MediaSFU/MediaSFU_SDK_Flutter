import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show Participant, ShowAlert;

/// Permission level values:
/// - "2": Host (full permissions, cannot be changed)
/// - "1": Co-host/Elevated (extended permissions)
/// - "0": Participant (basic permissions)

class UpdateParticipantPermissionOptions {
  final io.Socket socket;
  final Participant participant;
  final String newLevel;
  final String member;
  final String islevel;
  final String roomName;
  final ShowAlert? showAlert;

  UpdateParticipantPermissionOptions({
    required this.socket,
    required this.participant,
    required this.newLevel,
    required this.member,
    required this.islevel,
    required this.roomName,
    this.showAlert,
  });
}

class BulkUpdateParticipantPermissionsOptions {
  final io.Socket socket;
  final List<Participant> participants;
  final String newLevel;
  final String member;
  final String islevel;
  final String roomName;
  final ShowAlert? showAlert;
  final int maxBatchSize;

  BulkUpdateParticipantPermissionsOptions({
    required this.socket,
    required this.participants,
    required this.newLevel,
    required this.member,
    required this.islevel,
    required this.roomName,
    this.showAlert,
    this.maxBatchSize = 50,
  });
}

typedef UpdateParticipantPermissionType = Future<void> Function(
    UpdateParticipantPermissionOptions options);

typedef BulkUpdateParticipantPermissionsType = Future<void> Function(
    BulkUpdateParticipantPermissionsOptions options);

/// Updates a single participant's permission level.
/// Only hosts (islevel === "2") can update permissions.
/// Cannot change a host's permission level.
///
/// Example:
/// ```dart
/// await updateParticipantPermission(UpdateParticipantPermissionOptions(
///   socket: socket,
///   participant: Participant(id: "123", name: "John", islevel: "0"),
///   newLevel: "1",
///   member: "currentUser",
///   islevel: "2",
///   roomName: "room123",
///   showAlert: (alert) => print(alert.message),
/// ));
/// ```
Future<void> updateParticipantPermission(
    UpdateParticipantPermissionOptions options) async {
  // Only hosts can update permissions
  if (options.islevel != "2") {
    options.showAlert?.call(
      message: "Only the host can update participant permissions",
      type: "danger",
      duration: 3000,
    );
    return;
  }

  // Cannot change host's permission
  if (options.participant.islevel == "2") {
    options.showAlert?.call(
      message: "Cannot change the host's permission level",
      type: "danger",
      duration: 3000,
    );
    return;
  }

  // Don't emit if level is the same
  if (options.participant.islevel == options.newLevel) {
    return;
  }

  final completer = Completer<void>();

  options.socket.emitWithAck("updateParticipantPermission", {
    'participantId': options.participant.id,
    'participantName': options.participant.name,
    'newLevel': options.newLevel,
    'roomName': options.roomName,
  }, ack: (response) {
    if (response == null || response['success'] != true) {
      final reason = response?['reason'] ?? 'Unknown error';
      debugPrint('updateParticipantPermission failed: $reason');
      options.showAlert?.call(
        message: reason,
        type: "danger",
        duration: 3000,
      );
    }
    completer.complete();
  });

  return completer.future;
}

/// Updates multiple participants' permission levels in bulk.
/// Only hosts (islevel === "2") can update permissions.
/// Processes in batches (default max 50 at a time).
///
/// Example:
/// ```dart
/// await bulkUpdateParticipantPermissions(BulkUpdateParticipantPermissionsOptions(
///   socket: socket,
///   participants: [participant1, participant2],
///   newLevel: "0",
///   member: "currentUser",
///   islevel: "2",
///   roomName: "room123",
///   showAlert: (alert) => print(alert.message),
///   maxBatchSize: 50,
/// ));
/// ```
Future<void> bulkUpdateParticipantPermissions(
    BulkUpdateParticipantPermissionsOptions options) async {
  // Only hosts can update permissions
  if (options.islevel != "2") {
    options.showAlert?.call(
      message: "Only the host can update participant permissions",
      type: "danger",
      duration: 3000,
    );
    return;
  }

  // Filter out hosts and participants already at the target level
  final eligibleParticipants = options.participants
      .where((p) => p.islevel != "2" && p.islevel != options.newLevel)
      .toList();

  if (eligibleParticipants.isEmpty) {
    options.showAlert?.call(
      message: "No participants to update",
      type: "info",
      duration: 3000,
    );
    return;
  }

  // Limit to maxBatchSize
  final batch = eligibleParticipants.take(options.maxBatchSize).toList();

  final completer = Completer<void>();

  options.socket.emitWithAck("bulkUpdateParticipantPermissions", {
    'updates': batch
        .map((p) => {
              'participantId': p.id,
              'participantName': p.name,
              'newLevel': options.newLevel,
            })
        .toList(),
    'roomName': options.roomName,
  }, ack: (response) {
    if (response == null || response['success'] != true) {
      final reason = response?['reason'] ?? 'Unknown error';
      debugPrint('bulkUpdateParticipantPermissions failed: $reason');
      options.showAlert?.call(
        message: reason,
        type: "danger",
        duration: 3000,
      );
    } else if (eligibleParticipants.length > options.maxBatchSize) {
      options.showAlert?.call(
        message:
            "Updated ${batch.length} participants. ${eligibleParticipants.length - options.maxBatchSize} remaining.",
        type: "info",
        duration: 3000,
      );
    }
    completer.complete();
  });

  return completer.future;
}
