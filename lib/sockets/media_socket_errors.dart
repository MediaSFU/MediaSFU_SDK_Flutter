import 'media_socket_platform_stub.dart'
    if (dart.library.js_interop) 'media_socket_platform_web.dart';

/// Reasons a media node sends with `connection-rejected { reason, stage }` (media admission v2) just before it closes
/// a refused handshake.
const List<String> mediaConnectionRejectionReasons = [
  'invalid-credentials',
  'meeting-minutes-unavailable',
  'api-check-failed',
  'invalid-request',
  'rejected-before-connection-success',
];

const Set<String> _permanentRejections = {
  'invalid-credentials',
  'meeting-minutes-unavailable',
  'invalid-request',
};

/// Where a media socket connection attempt stopped.
enum MediaSocketConnectPhase {
  /// The transport never opened (offline, DNS, TLS, firewall, server down).
  beforeOpen,

  /// The transport opened but closed or errored before `connection-success`.
  afterOpen,

  /// The server refused the handshake and said why ([MediaSocketConnectException.reason]).
  rejected,

  /// Nothing settled in time.
  timeout,
}

String _phaseName(MediaSocketConnectPhase phase) => const {
      MediaSocketConnectPhase.beforeOpen: 'before-open',
      MediaSocketConnectPhase.afterOpen: 'after-open',
      MediaSocketConnectPhase.rejected: 'rejected',
      MediaSocketConnectPhase.timeout: 'timeout',
    }[phase]!;

/// Maps any reason from the server onto a known one (unknown values become `rejected-before-connection-success`).
String normalizeRejectionReason(Object? reason) =>
    mediaConnectionRejectionReasons.contains(reason?.toString())
        ? reason.toString()
        : 'rejected-before-connection-success';

/// `navigator.onLine` on web; null elsewhere (unknown).
bool? currentOnlineState() {
  try {
    return platformOnlineState();
  } catch (_) {
    return null;
  }
}

/// Thrown by `connectSocket` when the media socket cannot be used.
///
/// [phase] says where the attempt stopped, [reason]/[stage] carry the server's `connection-rejected` verdict,
/// [elapsedMs] and [online] help tell a device/network problem from a refusal, and [retryable] is false for
/// rejections that cannot succeed with the same credentials. [userMessage] is a sentence for an end user.
class MediaSocketConnectException implements Exception {
  final MediaSocketConnectPhase phase;
  final String? reason;
  final String? stage;
  final int elapsedMs;
  final bool? online;
  final String? transportError;
  final String? link;

  MediaSocketConnectException({
    required this.phase,
    this.reason,
    this.stage,
    required this.elapsedMs,
    this.online,
    this.transportError,
    this.link,
  });

  bool get retryable =>
      !(phase == MediaSocketConnectPhase.rejected &&
          reason != null &&
          _permanentRejections.contains(reason));

  /// Technical one-liner for logs.
  String get message {
    final facts = <String>[
      'phase: ${_phaseName(phase)}',
      'after ${elapsedMs < 0 ? 0 : elapsedMs} ms',
      if (online != null) 'online: $online',
      if (stage != null && stage!.isNotEmpty) 'stage: $stage',
    ];
    final tail = ' (${facts.join(', ')})';
    switch (phase) {
      case MediaSocketConnectPhase.rejected:
        return 'Media server rejected the connection: ${reason ?? 'rejected-before-connection-success'}$tail';
      case MediaSocketConnectPhase.timeout:
        return 'Timed out connecting to media socket$tail';
      case MediaSocketConnectPhase.afterOpen:
        return 'Media socket closed before the room was ready: ${transportError ?? 'unknown'}$tail';
      case MediaSocketConnectPhase.beforeOpen:
        return 'Error connecting to media socket: ${transportError ?? 'unknown'}$tail';
    }
  }

  /// A sentence suitable for an alert shown to the person joining.
  String get userMessage {
    if (phase == MediaSocketConnectPhase.rejected) {
      switch (reason) {
        case 'invalid-credentials':
          return 'The room did not accept these credentials. Check the room ID and your access, or rejoin the room.';
        case 'meeting-minutes-unavailable':
          return 'This room cannot start because its account has no meeting minutes left. Contact the room host.';
        case 'invalid-request':
          return 'The connection request was incomplete or invalid. Check the room details and try again.';
        case 'api-check-failed':
          return 'The media server could not verify this room right now. Please try again shortly.';
        default:
          return 'The media server closed the connection before the room was ready. Please try again.';
      }
    }
    if (online == false) {
      return 'You appear to be offline. Check your internet connection and try again.';
    }
    if (phase == MediaSocketConnectPhase.beforeOpen) {
      return 'Could not reach the media server. Check your network or firewall and try again.';
    }
    if (phase == MediaSocketConnectPhase.timeout) {
      return 'Connecting to the media server timed out. Please try again.';
    }
    return 'The media server closed the connection before the room was ready. Please try again.';
  }

  @override
  String toString() => 'MediaSocketConnectException: $message';
}

/// User-facing text for any connection error; [fallback] for errors that are not [MediaSocketConnectException].
String describeMediaSocketError(Object? error,
        {String fallback =
            'Unable to connect. Check your credentials and try again.'}) =>
    error is MediaSocketConnectException ? error.userMessage : fallback;

/// False only for rejections that cannot succeed on retry with the same credentials.
bool isRetryableMediaSocketError(Object? error) =>
    error is! MediaSocketConnectException || error.retryable;
