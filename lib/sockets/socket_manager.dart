import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

/// Validates the provided API key or token.
/// Returns `true` if the API key or token is valid, otherwise throws an exception.
Future<bool> validateApiKeyToken(String value) async {
  // Ensure alphanumeric and exactly 64 characters
  if (!RegExp(r'^[a-zA-Z0-9]{64}$').hasMatch(value)) {
    throw Exception('Invalid API key or token.');
  }
  return true;
}

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

typedef ConnectSocketType = Future<io.Socket> Function(
    ConnectSocketOptions options);

class DisconnectSocketOptions {
  final io.Socket? socket;

  DisconnectSocketOptions({this.socket});
}

typedef DisconnectSocketType = Future<bool> Function(
    DisconnectSocketOptions options);

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

  final completer = Completer<io.Socket>();

  // Handle connection success
  socket.onConnect((_) {
    if (kDebugMode) print('Connected to media socket with ID: ${socket.id}');
    completer.complete(socket);
  });

  // Handle connection error
  socket.onConnectError((error) {
    completer
        .completeError(Exception('Error connecting to media socket: $error'));
  });

  return completer.future;
}

/// Disconnects the given socket instance.
/// Returns `true` upon successful disconnection.
Future<bool> disconnectSocket(DisconnectSocketOptions options) async {
  final socket = options.socket;
  if (socket!.connected) {
    socket.disconnect();
    return true;
  }
  return false;
}
