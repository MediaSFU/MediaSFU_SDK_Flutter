import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import '../../types/types.dart' show MeetingRoomParams, RecordingParams;
import 'media_socket_errors.dart';

export 'media_socket_errors.dart';

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
/// Supports optional authentication parameters for backend handshake.
class ConnectLocalSocketOptions {
  final String link;

  /// Optional app key for Flutter app authentication (X-App-Key)
  final String? appKey;

  /// Optional API username for backend authentication
  final String? apiUserName;

  /// Optional API key for backend authentication
  final String? apiKey;

  ConnectLocalSocketOptions({
    required this.link,
    this.appKey,
    this.apiUserName,
    this.apiKey,
  });
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
/// Throws an exception if inputs are invalid. A failed connection throws a [MediaSocketConnectException]: its `phase`
/// says where it stopped (before the transport opened, after, rejected by the server, timeout), `reason`/`stage`
/// carry the server's `connection-rejected` verdict, `elapsedMs`/`online` help tell a network problem from a
/// refusal, `retryable` is false when the same credentials cannot succeed, and `userMessage` is ready for an alert.
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
    'autoConnect': false,
  });

  final completer = Completer<io.Socket>();
  Timer? admissionTimer;
  var settled = false;
  final startedAt = DateTime.now();
  var transportOpened = false;
  String? rejectionReason;
  String? rejectionStage;

  late void Function(dynamic) handleConnectionSuccess;
  late void Function(dynamic) handleConnectError;
  late void Function(dynamic) handleSocketError;
  late void Function(dynamic) handleDisconnectBeforeReady;
  late void Function(dynamic) handleTransportOpen;
  late void Function(dynamic) handleConnectionRejected;

  void cleanupAdmissionListeners() {
    admissionTimer?.cancel();
    socket.off('connection-success', handleConnectionSuccess);
    socket.off('connect_error', handleConnectError);
    socket.off('error', handleSocketError);
    socket.off('disconnect', handleDisconnectBeforeReady);
    socket.off('connect', handleTransportOpen);
    socket.off('connection-rejected', handleConnectionRejected);
  }

  String? describeTransportError(dynamic error) {
    if (error == null) return null;
    final text = error is Map ? (error['message'] ?? error).toString() : error.toString();
    return text.length > 200 ? text.substring(0, 200) : text;
  }

  void finishWithError(MediaSocketConnectPhase phase, [dynamic error]) {
    if (settled) return;
    settled = true;
    cleanupAdmissionListeners();
    socket.disconnect();
    completer.completeError(MediaSocketConnectException(
      phase: rejectionReason != null ? MediaSocketConnectPhase.rejected : phase,
      reason: rejectionReason,
      stage: rejectionStage,
      elapsedMs: DateTime.now().difference(startedAt).inMilliseconds,
      online: currentOnlineState(),
      transportError: describeTransportError(error),
      link: options.link,
    ));
  }

  // A raw Socket.IO connection is only transport establishment. The media
  // server emits connection-success after its credential admission finishes;
  // do not expose the socket to callers before that application-level proof.
  handleConnectionSuccess = (_) {
    if (settled) return;
    settled = true;
    cleanupAdmissionListeners();
    completer.complete(socket);
  };

  // Handle connection error
  handleConnectError = (error) => finishWithError(
      transportOpened
          ? MediaSocketConnectPhase.afterOpen
          : MediaSocketConnectPhase.beforeOpen,
      error);
  handleSocketError = (error) => finishWithError(
      transportOpened
          ? MediaSocketConnectPhase.afterOpen
          : MediaSocketConnectPhase.beforeOpen,
      error);
  handleDisconnectBeforeReady =
      (reason) => finishWithError(MediaSocketConnectPhase.afterOpen, reason);
  handleTransportOpen = (_) => transportOpened = true;
  // Media admission v2: the node says why before it closes the handshake. A refusal is final for these credentials,
  // so it is reported as such and never retried as a network error.
  handleConnectionRejected = (payload) {
    final data = payload is Map ? payload : const {};
    rejectionReason = normalizeRejectionReason(data['reason']);
    rejectionStage = data['stage'] is String ? data['stage'] as String : null;
    finishWithError(MediaSocketConnectPhase.rejected);
  };

  socket.on('connection-success', handleConnectionSuccess);
  socket.on('connect_error', handleConnectError);
  socket.on('error', handleSocketError);
  socket.on('disconnect', handleDisconnectBeforeReady);
  socket.on('connect', handleTransportOpen);
  socket.on('connection-rejected', handleConnectionRejected);

  admissionTimer = Timer(
    const Duration(seconds: 12),
    () => finishWithError(MediaSocketConnectPhase.timeout),
  );
  socket.connect();

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
/// Supports optional authentication parameters for backend handshake.
Future<ResponseLocalConnection> connectLocalSocket(
    ConnectLocalSocketOptions options) async {
  if (options.link.isEmpty) throw Exception('Socket link required.');

  // Build query parameters for handshake authentication
  final Map<String, dynamic> query = {};
  if (options.appKey != null && options.appKey!.isNotEmpty) {
    query['appKey'] = options.appKey;
  }
  if (options.apiUserName != null && options.apiUserName!.isNotEmpty) {
    query['apiUserName'] = options.apiUserName;
  }
  if (options.apiKey != null && options.apiKey!.isNotEmpty) {
    query['apiKey'] = options.apiKey;
  }

  final socket = io.io('${options.link}/media', <String, dynamic>{
    'transports': ['websocket'],
    if (query.isNotEmpty) 'query': query,
  });
  // final socket = io.io('${options.link}/media', {
  //   'transports': ['websocket'],
  //   'query': {},
  // });

  final completer = Completer<ResponseLocalConnection>();
  final startedAt = DateTime.now();
  var transportOpened = false;
  socket.onConnect((_) => transportOpened = true);

  // Handle connection success
  socket.on('connection-success', (data) {
    if (!completer.isCompleted) {
      final connectionData =
          ResponseLocalConnectionData.fromMap(Map<String, dynamic>.from(data));
      completer.complete(
          ResponseLocalConnection(socket: socket, data: connectionData));
    }
  });

  // Handle connection error
  socket.onConnectError((error) {
    if (!completer.isCompleted) {
      completer.completeError(MediaSocketConnectException(
        phase: transportOpened
            ? MediaSocketConnectPhase.afterOpen
            : MediaSocketConnectPhase.beforeOpen,
        elapsedMs: DateTime.now().difference(startedAt).inMilliseconds,
        online: currentOnlineState(),
        transportError: error?.toString(),
        link: options.link,
      ));
    }
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
