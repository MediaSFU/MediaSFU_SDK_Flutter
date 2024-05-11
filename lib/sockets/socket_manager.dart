import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

io.Socket? socket; // Initialize socket as nullable

/// Validates the API key or token.
/// Returns `true` if the value is a valid API key or token, otherwise throws an exception.
Future<bool> validateApiKeyToken(String value) async {
  // Validate inputs
  // API key or token must be alphanumeric and length 64
  if (!RegExp(r'^[a-zA-Z0-9]{64}$').hasMatch(value)) {
    throw Exception('Invalid API key or token.');
  }

  return true;
}

/// Connects to the socket using the provided API credentials and link.
/// Returns a future that completes with the connected socket.
/// Throws an exception if any of the required inputs are empty or if the API key or token is invalid.
Future<io.Socket> connectSocket(
    String apiUserName, String apiKey, String apiToken, String link) async {
  // Validate inputs
  if (apiUserName.isEmpty) {
    throw Exception('API username required.');
  }
  if (apiKey.isEmpty && apiToken.isEmpty) {
    throw Exception('API key or token required.');
  }
  if (link.isEmpty) {
    throw Exception('Socket link required.');
  }

  // Validate the API key or token
  bool useKey = false;
  try {
    if (apiKey.isNotEmpty && apiKey.length == 64) {
      await validateApiKeyToken(apiKey);
      useKey = true;
    } else {
      await validateApiKeyToken(apiToken);
      useKey = false;
    }
  } catch (error) {
    throw Exception('Invalid API key or token.');
  }

  socket = io.io('$link/media', <String, dynamic>{
    'transports': ['websocket'],
    'query': useKey
        ? {'apiUserName': apiUserName, 'apiKey': apiKey}
        : {'apiUserName': apiUserName, 'apiToken': apiToken},
  });

  // Create a completer to await the connection
  Completer<io.Socket> completer = Completer<io.Socket>();

  // Handle socket connection events
  socket!.onConnect((_) {
    if (kDebugMode) {
      print('Connected to media socket with ID: ${socket!.id}');
    }
    completer.complete(socket); // Complete the future when connected
  });

  socket!.onError((error) {
    throw Exception('Error connecting to media socket.');
  });

  // Return the future from the completer
  return completer.future;
}

/// Disconnects the socket if it is not null.
/// Returns `true` if the socket was disconnected successfully, otherwise returns `false`.
Future<bool> disconnectSocket(io.Socket? socket) async {
  if (socket != null) {
    socket.disconnect();
  }

  return true;
}
