import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../types/types.dart'
    show CoHostResponsibility, Message, ShowAlert;
import '../../exit_methods/confirm_exit.dart';
import '../../message_methods/send_message.dart';

class HeadlessActionResult {
  final bool ok;
  final String error;

  const HeadlessActionResult({required this.ok, this.error = ''});
  const HeadlessActionResult.success() : this(ok: true);
  const HeadlessActionResult.failure(String error)
      : this(ok: false, error: error);
}

abstract class RoomActionsParameters {
  String get member;
  String get roomName;
  String get islevel;
  String get coHost;
  String get chatSetting;
  List<CoHostResponsibility> get coHostResponsibility;
  List<Message> get messages;
  io.Socket? get socket;
  io.Socket? get localSocket;
  ShowAlert? get showAlert;
  bool get alertVisible;
  String get alertMessage;
  String get alertType;
}

Future<HeadlessActionResult> leaveRoom(
  RoomActionsParameters parameters, {
  bool ban = false,
  bool endRoomOnHostExit = true,
}) async {
  if (parameters.socket == null) {
    return const HeadlessActionResult.failure(
        'The room connection is unavailable.');
  }
  try {
    await confirmExit(ConfirmExitOptions(
      socket: parameters.socket,
      localSocket: parameters.localSocket,
      member: parameters.member,
      roomName: parameters.roomName,
      ban: ban,
      endRoomOnHostExit: endRoomOnHostExit,
    ));
    return const HeadlessActionResult.success();
  } catch (error) {
    return HeadlessActionResult.failure('Could not leave the room: $error');
  }
}

Future<HeadlessActionResult> sendChatMessage(
  RoomActionsParameters parameters,
  String message, {
  List<String> receivers = const <String>[],
  bool group = true,
}) async {
  final trimmed = message.trim();
  if (trimmed.isEmpty) {
    return const HeadlessActionResult.failure('Enter a message first.');
  }
  if (parameters.socket == null) {
    return const HeadlessActionResult.failure(
        'The room connection is unavailable.');
  }
  try {
    await sendMessage(SendMessageOptions(
      member: parameters.member,
      islevel: parameters.islevel,
      showAlert: parameters.showAlert,
      coHostResponsibility: parameters.coHostResponsibility,
      coHost: parameters.coHost,
      chatSetting: parameters.chatSetting,
      message: trimmed,
      roomName: parameters.roomName,
      messagesLength: parameters.messages.length,
      receivers: receivers,
      group: group,
      sender: parameters.member,
      socket: parameters.socket,
    ));
    return const HeadlessActionResult.success();
  } catch (error) {
    return HeadlessActionResult.failure('Could not send the message: $error');
  }
}

Future<HeadlessActionResult> runMediaControl(
  RoomActionsParameters parameters,
  FutureOr<void> Function() action,
) async {
  final previousAlert = parameters.alertMessage;
  try {
    await action();
    final refused = parameters.alertVisible &&
        parameters.alertMessage != previousAlert &&
        (parameters.alertType == 'danger' || parameters.alertType == 'warning');
    return refused
        ? HeadlessActionResult.failure(parameters.alertMessage)
        : const HeadlessActionResult.success();
  } catch (error) {
    return HeadlessActionResult.failure('$error');
  }
}
