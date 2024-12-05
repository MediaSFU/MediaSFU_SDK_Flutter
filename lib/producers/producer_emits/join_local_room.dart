import 'package:flutter/foundation.dart';
import '../../../types/types.dart'
    show PreJoinPageParameters, ResponseJoinLocalRoom;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import '../../methods/utils/check_limits_and_make_request.dart';
import '../../methods/utils/join_room_on_media_sfu.dart';

/// Validates if a string is alphanumeric.
bool _validateAlphanumeric(String value) {
  final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
  return alphanumericRegex.hasMatch(value);
}

/// Options for joining a local room.
class JoinLocalRoomOptions {
  final io.Socket? socket;
  final String roomName;
  final String islevel;
  final String member;
  final String sec;
  final String apiUserName;
  final PreJoinPageParameters parameters;
  final bool checkConnect;

  JoinLocalRoomOptions({
    this.socket,
    required this.roomName,
    required this.islevel,
    required this.member,
    required this.sec,
    required this.apiUserName,
    required this.parameters,
    this.checkConnect = false,
  });
}

typedef JoinLocalRoomType = Future<ResponseJoinLocalRoom> Function(
    JoinLocalRoomOptions options);

/// Options for checking MediaSFU URL.
class CheckMediasfuURLOptions {
  final ResponseJoinLocalRoom data;
  final String member;
  final String roomName;
  final String islevel;
  final io.Socket? socket;
  final PreJoinPageParameters parameters;

  CheckMediasfuURLOptions({
    required this.data,
    required this.member,
    required this.roomName,
    required this.islevel,
    this.socket,
    required this.parameters,
  });
}

typedef CheckMediasfuURLType = Future<void> Function(
    CheckMediasfuURLOptions options);

/// Joins a local room on the socket server with specified options.
///
/// This function validates the input parameters, then emits a `joinRoom` event to the server.
/// It returns a `Future` that completes with the server’s response data or an error if validation fails
/// or if the server returns a specific status.
///
/// - Throws: `Exception` if input validation fails or if the user is banned, suspended, or if
///           the host has not joined the room yet.
///
/// - Returns: A `Future<Map<String, dynamic>>` containing the server's response data on success.
///
/// Example usage:
/// ```dart
/// final socket = io.io('https://your-socket-server.com', <String, dynamic>{
///   'transports': ['websocket'],
///   'autoConnect': false,
/// });
/// socket.connect();
///
/// final options = JoinLocalRoomOptions(
///   socket: socket,
///   roomName: 'm12345678',
///   islevel: '1',
///   member: 'User123',
///   sec: 'your-secure-key-here-32-characters-long',
///   apiUserName: 'apiUser',
/// );
///
/// try {
///   final response = await joinRoom(options);
///   print('Successfully joined room: $response');
/// } catch (e) {
///   print('Error joining room: $e');
/// }
/// ```
///
/// Parameters:
/// - [options] (`JoinRoomOptions`): The options for joining the room, including socket and user details.

Future<ResponseJoinLocalRoom> joinLocalRoom(
    JoinLocalRoomOptions options) async {
  // Validate inputs
  if (!_validateInputs(options)) {
    throw Exception('Validation failed for input parameters.');
  }

  // Emit the 'joinRoom' event and handle the response
  return await _emitJoinLocalRoom(
    options.socket,
    options.roomName,
    options.islevel,
    options.member,
    options.sec,
    options.apiUserName,
    options.parameters,
    options.checkConnect,
  );
}

/// Validates inputs for joining a local room.
bool _validateInputs(JoinLocalRoomOptions options) {
  if (options.sec.isEmpty ||
      options.roomName.isEmpty ||
      options.islevel.isEmpty ||
      options.apiUserName.isEmpty ||
      options.member.isEmpty) {
    if (kDebugMode) {
      print('Missing required parameters');
    }
    return false;
  }

  // Validate alphanumeric fields
  if (!_validateAlphanumeric(options.roomName) ||
      !_validateAlphanumeric(options.apiUserName) ||
      !_validateAlphanumeric(options.member)) {
    if (kDebugMode) {
      print('Invalid roomName, apiUserName, or member');
    }
    return false;
  }

  // Validate specific conditions for the inputs
  if (!(options.roomName.startsWith('s') ||
      options.roomName.startsWith('p') ||
      options.roomName.startsWith('m'))) {
    if (kDebugMode) {
      print('Invalid roomName, must start with "s" or "p" or "m"');
    }
    return false;
  }

  if (!(options.sec.length == 32 &&
      options.roomName.length >= 8 &&
      options.islevel.length == 1 &&
      options.apiUserName.length >= 6 &&
      ['0', '1', '2'].contains(options.islevel))) {
    if (kDebugMode) {
      print('Invalid roomName, islevel, apiUserName, or secret');
    }
    return false;
  }

  return true;
}

/// Checks the MediaSFU URL and processes necessary actions based on its validity.
Future<void> checkMediasfuURL(CheckMediasfuURLOptions options) async {
  final data = options.data;

  if (data.mediasfuURL != null &&
      data.mediasfuURL!.isNotEmpty &&
      data.mediasfuURL!.length > 10) {
    try {
      final splitTexts = ["/meet/", "/chat/", "/broadcast/"];
      final splitText = splitTexts.firstWhere(
        (text) => data.mediasfuURL!.contains(text),
        orElse: () => "/meet/",
      );

      final urlParts = data.mediasfuURL!.split(splitText);
      final link = urlParts[0];
      final secretCode = urlParts[1].split("/")[1];

      await checkLimitsAndMakeRequest(
        apiUserName: options.roomName,
        apiToken: secretCode,
        link: link,
        userName: options.member,
        parameters: options.parameters,
        validate: false,
      );

      return;
    } catch (_) {
      return;
    }
  }

  if (data.mediasfuURL == null &&
      options.islevel != '2' &&
      data.allowRecord == true &&
      data.apiKey != null &&
      data.apiKey!.length == 64 &&
      data.apiUserName != null &&
      data.apiUserName!.length > 5 &&
      (options.roomName.startsWith('s') || options.roomName.startsWith('p'))) {
    final response = await joinRoomOnMediaSFU(
      payload: {
        'action': 'join',
        'meetingID': options.roomName,
        'userName': options.member,
      },
      apiKey: data.apiKey!,
      apiUserName: data.apiUserName!,
    );

    if (response.success &&
        response.data != null &&
        response.data!.roomName != null) {
      options.socket!.emitWithAck('updateMediasfuURL', {
        'eventID': options.roomName,
        'mediasfuURL': response.data!.publicURL,
      }, ack: (_) {
        // Do nothing
      });

      await checkLimitsAndMakeRequest(
        apiUserName: response.data!.roomName!,
        apiToken: response.data!.secret,
        link: response.data!.link,
        userName: options.member,
        parameters: options.parameters,
        validate: false,
      );

      options.parameters.updateApiToken(response.data!.secret);
    }
  }
}

/// Extracts the secret code from the MediaSFU URL.
String? _extractSecretCode(String? mediasfuURL) {
  try {
    final splitTexts = ["/meet/", "/chat/", "/broadcast/"];
    final splitText = splitTexts.firstWhere(
      (text) => mediasfuURL!.contains(text),
      orElse: () => "/meet/",
    );
    final urlParts = mediasfuURL!.split(splitText);
    return urlParts[1].split("/")[1];
  } catch (_) {
    return null;
  }
}

/// Emits the 'joinRoom' event to the socket server for joining a local room.
///
/// Returns the response from the server.
Future<ResponseJoinLocalRoom> _emitJoinLocalRoom(
  io.Socket? socket,
  String roomName,
  String islevel,
  String member,
  String sec,
  String apiUserName,
  PreJoinPageParameters parameters,
  bool checkConnect,
) async {
  final completer = Completer<ResponseJoinLocalRoom>();

  socket!.emitWithAck('joinRoom', [
    {
      'roomName': roomName,
      'islevel': islevel,
      'member': member,
      'sec': sec,
      'apiUserName': apiUserName,
    }
  ], ack: (data) async {
    try {
      final response = ResponseJoinLocalRoom.fromJson(data);

      if (response.rtpCapabilities == null) {
        if (response.isBanned!) throw Exception('User is banned.');
        if (response.hostNotJoined!) {
          throw Exception('Host has not joined the room yet.');
        }
      }

      if (checkConnect) {
        await checkMediasfuURL(
          CheckMediasfuURLOptions(
            data: response,
            member: member,
            roomName: roomName,
            islevel: islevel,
            socket: socket,
            parameters: parameters,
          ),
        );
      } else {
        if (response.mediasfuURL != null && response.mediasfuURL!.isNotEmpty) {
          final secretCode = _extractSecretCode(response.mediasfuURL);
          if (secretCode != null) parameters.updateApiToken(secretCode);
        }
      }

      completer.complete(response);
    } catch (error) {
      completer.completeError(error);
    }
  });

  return completer.future;
}
