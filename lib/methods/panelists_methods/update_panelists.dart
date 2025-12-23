import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show Participant, ShowAlert;

class UpdatePanelistsOptions {
  final io.Socket socket;
  final List<Participant> panelists;
  final String roomName;
  final String member;
  final String islevel;
  final ShowAlert? showAlert;

  UpdatePanelistsOptions({
    required this.socket,
    required this.panelists,
    required this.roomName,
    required this.member,
    required this.islevel,
    this.showAlert,
  });
}

class AddPanelistOptions {
  final io.Socket socket;
  final Participant participant;
  final List<Participant> currentPanelists;
  final int maxPanelists;
  final String roomName;
  final String member;
  final String islevel;
  final ShowAlert? showAlert;

  AddPanelistOptions({
    required this.socket,
    required this.participant,
    required this.currentPanelists,
    required this.maxPanelists,
    required this.roomName,
    required this.member,
    required this.islevel,
    this.showAlert,
  });
}

class RemovePanelistOptions {
  final io.Socket socket;
  final Participant participant;
  final String roomName;
  final String member;
  final String islevel;
  final ShowAlert? showAlert;

  RemovePanelistOptions({
    required this.socket,
    required this.participant,
    required this.roomName,
    required this.member,
    required this.islevel,
    this.showAlert,
  });
}

typedef UpdatePanelistsType = Future<void> Function(
    UpdatePanelistsOptions options);
typedef AddPanelistType = Future<bool> Function(AddPanelistOptions options);
typedef RemovePanelistType = Future<void> Function(
    RemovePanelistOptions options);

/// Updates the entire panelist list.
/// Only hosts (islevel === "2") can update panelists.
///
/// Example:
/// ```dart
/// await updatePanelists(UpdatePanelistsOptions(
///   socket: socket,
///   panelists: [participant1, participant2],
///   roomName: "room123",
///   member: "currentUser",
///   islevel: "2",
///   showAlert: (alert) => print(alert.message),
/// ));
/// ```
Future<void> updatePanelists(UpdatePanelistsOptions options) async {
  // Only hosts can update panelists
  if (options.islevel != "2") {
    options.showAlert?.call(
      message: "Only the host can update panelists",
      type: "danger",
      duration: 3000,
    );
    return;
  }

  options.socket.emitWithAck("updatePanelists", {
    'panelists': options.panelists
        .map((p) => {
              'id': p.id,
              'name': p.name,
            })
        .toList(),
    'roomName': options.roomName,
  }, ack: (response) {
    if (response == null || response['success'] != true) {
      final reason = response?['reason'] ?? 'Unknown error';
      debugPrint('updatePanelists failed: $reason');
      options.showAlert?.call(
        message: reason,
        type: "danger",
        duration: 3000,
      );
    }
  });
}

/// Adds a participant to the panelist list.
/// Respects the maximum panelist limit.
///
/// Returns true if added successfully, false otherwise.
///
/// Example:
/// ```dart
/// final success = await addPanelist(AddPanelistOptions(
///   socket: socket,
///   participant: Participant(id: "123", name: "John"),
///   currentPanelists: [],
///   maxPanelists: 10,
///   roomName: "room123",
///   member: "currentUser",
///   islevel: "2",
///   showAlert: (alert) => print(alert.message),
/// ));
/// ```
Future<bool> addPanelist(AddPanelistOptions options) async {
  // Only hosts can add panelists
  if (options.islevel != "2") {
    options.showAlert?.call(
      message: "Only the host can add panelists",
      type: "danger",
      duration: 3000,
    );
    return false;
  }

  // Check if already a panelist
  if (options.currentPanelists.any((p) => p.id == options.participant.id)) {
    options.showAlert?.call(
      message: "${options.participant.name} is already a panelist",
      type: "info",
      duration: 3000,
    );
    return false;
  }

  // Check max limit
  if (options.currentPanelists.length >= options.maxPanelists) {
    options.showAlert?.call(
      message: "Maximum panelist limit (${options.maxPanelists}) reached",
      type: "danger",
      duration: 3000,
    );
    return false;
  }

  final completer = Completer<bool>();

  options.socket.emitWithAck("addPanelist", {
    'participantId': options.participant.id,
    'participantName': options.participant.name,
    'roomName': options.roomName,
  }, ack: (response) {
    if (response == null || response['success'] != true) {
      final reason = response?['reason'] ?? 'Unknown error';
      debugPrint('addPanelist failed: $reason');
      options.showAlert?.call(
        message: reason,
        type: "danger",
        duration: 3000,
      );
      completer.complete(false);
    } else {
      completer.complete(true);
    }
  });

  return completer.future;
}

/// Removes a participant from the panelist list.
///
/// Example:
/// ```dart
/// await removePanelist(RemovePanelistOptions(
///   socket: socket,
///   participant: Participant(id: "123", name: "John"),
///   roomName: "room123",
///   member: "currentUser",
///   islevel: "2",
///   showAlert: (alert) => print(alert.message),
/// ));
/// ```
Future<void> removePanelist(RemovePanelistOptions options) async {
  // Only hosts can remove panelists
  if (options.islevel != "2") {
    options.showAlert?.call(
      message: "Only the host can remove panelists",
      type: "danger",
      duration: 3000,
    );
    return;
  }

  options.socket.emitWithAck("removePanelist", {
    'participantId': options.participant.id,
    'participantName': options.participant.name,
    'roomName': options.roomName,
  }, ack: (response) {
    if (response == null || response['success'] != true) {
      final reason = response?['reason'] ?? 'Unknown error';
      debugPrint('removePanelist failed: $reason');
      options.showAlert?.call(
        message: reason,
        type: "danger",
        duration: 3000,
      );
    }
  });
}
