import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import '../../types/types.dart' show MeetingRoomParams, RecordingParams;

/// Validates the provided API key or token.
/// Returns `true` if the API key or token is valid, otherwise throws an exception.
Future<bool> validateApiKeyToken(String value) async {
  // Ensure alphanumeric and exactly 64 characters
  if (!RegExp(r'^[a-zA-Z0-9]{64}$').hasMatch(value)) {
    throw Exception('Invalid API key or token.');
  }
  return true;
}

/// Response for local socket connection.
class ResponseLocalConnection {
  final io.Socket? socket;
  final ResponseLocalConnectionData? data;

  ResponseLocalConnection({this.socket, this.data});
}

/// Data received during local socket connection.
class ResponseLocalConnectionData {
  final String socketId;
  final String mode;
  final String? apiUserName;
  final String? apiKey;
  final bool allowRecord;
  final MeetingRoomParams eventRoomParams;
  final RecordingParams recordingParams;

  ResponseLocalConnectionData({
    required this.socketId,
    required this.mode,
    this.apiUserName,
    this.apiKey,
    required this.allowRecord,
    required this.eventRoomParams,
    required this.recordingParams,
  });

  /// Converts a map into a `ResponseLocalConnectionData` object.
  factory ResponseLocalConnectionData.fromMap(Map<String, dynamic> map) {
    return ResponseLocalConnectionData(
      socketId: map['socketId'],
      mode: map['mode'],
      apiUserName: map['apiUserName'],
      apiKey: map['apiKey'],
      allowRecord: map['allowRecord'],
      eventRoomParams: MeetingRoomParams.fromJson(map['meetingRoomParams_']),
      recordingParams: RecordingParams.fromJson(map['recordingParams_']),
    );
  }
}

/// Options for connecting to a socket.
class ConnectSocketOptions {
  final String apiUserName;
  final String? apiKey;
  final String? apiToken;
  final String link;

  ConnectSocketOptions({
    required this.apiUserName,
    this.apiKey,
    this.apiToken,
    required this.link,
  });
}

/// Options for connecting to a local socket.
class ConnectLocalSocketOptions {
  final String link;

  ConnectLocalSocketOptions({required this.link});
}

class DisconnectSocketOptions {
  final io.Socket? socket;

  DisconnectSocketOptions({this.socket});
}

typedef ConnectSocketType = Future<io.Socket> Function(
    ConnectSocketOptions options);
typedef DisconnectSocketType = Future<bool> Function(
    DisconnectSocketOptions options);
typedef ConnectLocalSocketType = Future<ResponseLocalConnection> Function(
    ConnectLocalSocketOptions options);

/// Connects to a media socket with the specified options.
/// Validates the API key or token and initiates a socket connection.
///
/// Throws an exception if inputs are invalid or if connection fails.
///
/// Example usage:
/// ```dart
/// final options = ConnectSocketOptions(
///   apiUserName: "user123",
///   apiKey: "yourApiKeyHere",
///   link: "https://socketlink.com",
/// );
///
/// try {
///   final socket = await connectSocket(options);
///   print("Connected to socket with ID: ${socket.id}");
/// } catch (error) {
///   print("Failed to connect to socket: $error");
/// }
/// ```
Future<io.Socket> connectSocket(ConnectSocketOptions options) async {
  // Input validation
  if (options.apiUserName.isEmpty) throw Exception('API username required.');
  if ((options.apiKey?.isEmpty ?? true) &&
      (options.apiToken?.isEmpty ?? true)) {
    throw Exception('API key or token required.');
  }
  if (options.link.isEmpty) throw Exception('Socket link required.');

  // Validate API key or token format
  bool useKey = false;
  try {
    if (options.apiKey?.length == 64 &&
        await validateApiKeyToken(options.apiKey!)) {
      useKey = true;
    } else if (options.apiToken?.length == 64 &&
        await validateApiKeyToken(options.apiToken!)) {
      useKey = false;
    } else {
      throw Exception('Invalid API key or token format.');
    }
  } catch (error) {
    throw Exception('Invalid API key or token.');
  }

  // Configure socket options based on whether apiKey or apiToken is used
  final query = useKey
      ? {'apiUserName': options.apiUserName, 'apiKey': options.apiKey}
      : {'apiUserName': options.apiUserName, 'apiToken': options.apiToken};

  final socket = io.io('${options.link}/media', {
    'transports': ['websocket'],
    'query': query,
  });

  // Determine the socket connection path
  String conn = 'media';
  try {
    if (options.link.contains('mediasfu.com') &&
        (RegExp('c').allMatches(options.link).length > 1)) {
      conn = 'consume';
    }
  } catch (e) {
    // Do nothing
  }

  final completer = Completer<io.Socket>();

  // Handle connection success
  socket.onConnect((_) {
    if (kDebugMode) print('Connected to $conn socket with ID: ${socket.id}');
    completer.complete(socket);
  });

  // Handle connection error
  socket.onConnectError((error) {
    completer
        .completeError(Exception('Error connecting to media socket: $error'));
  });

  return completer.future;
}

/// Connects to a media socket with the specified options.
/// Returns a `ResponseLocalConnection` containing the socket and connection data.
/// Throws an exception if inputs are invalid or if connection fails.
/// Example usage:
/// ```dart
/// final options = ConnectLocalSocketOptions(
///  link: "http://localhost:3000",
/// );
/// try {
///  final response = await connectLocalSocket(options);
/// print("Connected to local socket with ID: ${response.data.socketId}");
/// } catch (error) {
/// print("Failed to connect to local socket: $error");
///
/// }
/// ```
///

/// Connects to a local media socket with the specified options.
/// Returns a `ResponseLocalConnection` containing the socket and connection data.
Future<ResponseLocalConnection> connectLocalSocket(
    ConnectLocalSocketOptions options) async {
  if (options.link.isEmpty) throw Exception('Socket link required.');

  final socket = io.io('${options.link}/media', <String, dynamic>{
    'transports': ['websocket'],
  });
  // final socket = io.io('${options.link}/media', {
  //   'transports': ['websocket'],
  //   'query': {},
  // });

  final completer = Completer<ResponseLocalConnection>();

  // Handle connection success
  socket.on('connection-success', (data) {
    final connectionData =
        ResponseLocalConnectionData.fromMap(Map<String, dynamic>.from(data));
    completer.complete(
        ResponseLocalConnection(socket: socket, data: connectionData));
  });

  // Handle connection error
  socket.onConnectError((error) {
    completer.completeError(
        Exception('Error connecting to local media socket: $error'));
  });

  return completer.future;
}

/// Disconnects the given socket instance.
/// Returns `true` upon successful disconnection.
Future<bool> disconnectSocket(DisconnectSocketOptions options) async {
  final socket = options.socket;
  if (socket != null && socket.connected) {
    socket.disconnect();
    return true;
  }
  return false;
}
