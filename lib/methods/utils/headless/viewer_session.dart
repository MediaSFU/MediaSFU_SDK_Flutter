import 'dart:async';

enum ViewerSessionPhase {
  idle,
  joining,
  watching,
  requested,
  approved,
  left,
  error,
}

class ViewerSessionIdentity {
  final String viewerId;
  final String roomName;
  final String? playbackUrl;
  final String? protocol;
  final String? token;
  final Map<String, dynamic> metadata;

  const ViewerSessionIdentity({
    required this.viewerId,
    required this.roomName,
    this.playbackUrl,
    this.protocol,
    this.token,
    this.metadata = const {},
  });

  ViewerSessionIdentity copyWith({String? playbackUrl}) =>
      ViewerSessionIdentity(
        viewerId: viewerId,
        roomName: roomName,
        playbackUrl: playbackUrl ?? this.playbackUrl,
        protocol: protocol,
        token: token,
        metadata: metadata,
      );
}

class ViewerSessionStatus {
  final bool approved;
  final bool pending;
  final String reason;
  final String? playbackUrl;

  const ViewerSessionStatus({
    required this.approved,
    this.pending = false,
    this.reason = '',
    this.playbackUrl,
  });
}

typedef JoinViewerSession = Future<ViewerSessionIdentity> Function(
  String roomName,
  String? displayName,
);
typedef HeartbeatViewerSession = Future<void> Function(
    ViewerSessionIdentity session);
typedef RequestViewerPromotion = Future<void> Function(
    ViewerSessionIdentity session);
typedef PollViewerSession = Future<ViewerSessionStatus> Function(
    ViewerSessionIdentity session);
typedef LeaveViewerSession = Future<void> Function(
    ViewerSessionIdentity session);

class ViewerSessionProvider {
  final JoinViewerSession join;
  final HeartbeatViewerSession? heartbeat;
  final RequestViewerPromotion? requestPromotion;
  final PollViewerSession? poll;
  final LeaveViewerSession? leave;

  const ViewerSessionProvider({
    required this.join,
    this.heartbeat,
    this.requestPromotion,
    this.poll,
    this.leave,
  });
}

class ViewerSessionSnapshot {
  final ViewerSessionPhase phase;
  final ViewerSessionIdentity? session;
  final ViewerSessionStatus? status;
  final String error;
  final bool canRequestPromotion;

  const ViewerSessionSnapshot({
    required this.phase,
    required this.session,
    required this.status,
    required this.error,
    required this.canRequestPromotion,
  });

  ViewerSessionSnapshot copyWith({
    ViewerSessionPhase? phase,
    ViewerSessionIdentity? session,
    ViewerSessionStatus? status,
    String? error,
  }) =>
      ViewerSessionSnapshot(
        phase: phase ?? this.phase,
        session: session ?? this.session,
        status: status ?? this.status,
        error: error ?? this.error,
        canRequestPromotion: canRequestPromotion,
      );
}

class ViewerSessionHandle {
  static const _minimumInterval = Duration(seconds: 1);

  final ViewerSessionProvider provider;
  final String roomName;
  final String? displayName;
  final Duration pollInterval;
  final Duration heartbeatInterval;
  final void Function(ViewerSessionSnapshot)? onChange;

  late ViewerSessionSnapshot _snapshot;
  Timer? _pollTimer;
  Timer? _heartbeatTimer;
  bool _stopped = false;
  bool _polling = false;
  bool _heartbeating = false;

  ViewerSessionHandle({
    required this.provider,
    required this.roomName,
    this.displayName,
    this.pollInterval = const Duration(seconds: 5),
    this.heartbeatInterval = const Duration(seconds: 30),
    this.onChange,
  }) {
    _snapshot = ViewerSessionSnapshot(
      phase: ViewerSessionPhase.idle,
      session: null,
      status: null,
      error: '',
      canRequestPromotion: provider.requestPromotion != null,
    );
  }

  ViewerSessionSnapshot get snapshot => _snapshot;

  void _emit(ViewerSessionSnapshot next) {
    _snapshot = next;
    try {
      onChange?.call(_snapshot);
    } catch (_) {
      // An observer must never break viewer-session lifecycle.
    }
  }

  Duration _bounded(Duration value) =>
      value < _minimumInterval ? _minimumInterval : value;

  void _clearTimers() {
    _pollTimer?.cancel();
    _heartbeatTimer?.cancel();
    _pollTimer = null;
    _heartbeatTimer = null;
  }

  void _startTimers() {
    _clearTimers();
    if (provider.poll != null) {
      _pollTimer = Timer.periodic(_bounded(pollInterval), (_) => _poll());
    }
    if (provider.heartbeat != null) {
      _heartbeatTimer =
          Timer.periodic(_bounded(heartbeatInterval), (_) => _heartbeat());
    }
  }

  Future<void> _poll() async {
    final session = _snapshot.session;
    if (_stopped || _polling || session == null || provider.poll == null)
      return;
    _polling = true;
    try {
      final status = await provider.poll!(session);
      if (_stopped) return;
      final refreshedSession = status.playbackUrl == null
          ? session
          : session.copyWith(playbackUrl: status.playbackUrl);
      _emit(_snapshot.copyWith(
        status: status,
        session: refreshedSession,
        phase: status.approved
            ? ViewerSessionPhase.approved
            : _snapshot.phase == ViewerSessionPhase.requested
                ? ViewerSessionPhase.requested
                : ViewerSessionPhase.watching,
      ));
      if (status.approved) _clearTimers();
    } catch (_) {
      // A transient poll failure does not end the viewer session.
    } finally {
      _polling = false;
    }
  }

  Future<void> _heartbeat() async {
    final session = _snapshot.session;
    if (_stopped ||
        _heartbeating ||
        session == null ||
        provider.heartbeat == null) return;
    _heartbeating = true;
    try {
      await provider.heartbeat!(session);
    } catch (_) {
      // Heartbeats are best-effort; polling remains authoritative.
    } finally {
      _heartbeating = false;
    }
  }

  Future<ViewerSessionSnapshot> start() async {
    if (!{
      ViewerSessionPhase.idle,
      ViewerSessionPhase.left,
      ViewerSessionPhase.error,
    }.contains(_snapshot.phase)) {
      return _snapshot;
    }
    _stopped = false;
    _emit(_snapshot.copyWith(phase: ViewerSessionPhase.joining, error: ''));
    try {
      final session = await provider.join(roomName, displayName);
      if (_stopped) return _snapshot;
      if (session.viewerId.isEmpty) {
        throw StateError('The viewer session provider returned no viewerId.');
      }
      _emit(_snapshot.copyWith(
        phase: ViewerSessionPhase.watching,
        session: session,
        error: '',
      ));
      _startTimers();
    } catch (error) {
      _emit(_snapshot.copyWith(
        phase: ViewerSessionPhase.error,
        error: error.toString(),
      ));
    }
    return _snapshot;
  }

  Future<ViewerSessionSnapshot> requestPromotion() async {
    final session = _snapshot.session;
    if (session == null) {
      _emit(_snapshot.copyWith(
          error: 'Start the viewer session before requesting the floor.'));
      return _snapshot;
    }
    if (provider.requestPromotion == null) {
      _emit(_snapshot.copyWith(
          error: 'This viewer session provider does not support promotion.'));
      return _snapshot;
    }
    try {
      await provider.requestPromotion!(session);
      _emit(_snapshot.copyWith(
        phase: ViewerSessionPhase.requested,
        error: '',
      ));
    } catch (error) {
      _emit(_snapshot.copyWith(error: error.toString()));
    }
    return _snapshot;
  }

  Future<void> stop() async {
    _stopped = true;
    _clearTimers();
    final session = _snapshot.session;
    _emit(_snapshot.copyWith(phase: ViewerSessionPhase.left));
    if (session != null && provider.leave != null) {
      try {
        await provider.leave!(session);
      } catch (_) {
        // Teardown is best-effort.
      }
    }
  }
}

ViewerSessionHandle createViewerSession({
  required ViewerSessionProvider provider,
  required String roomName,
  String? displayName,
  Duration pollInterval = const Duration(seconds: 5),
  Duration heartbeatInterval = const Duration(seconds: 30),
  void Function(ViewerSessionSnapshot)? onChange,
}) =>
    ViewerSessionHandle(
      provider: provider,
      roomName: roomName,
      displayName: displayName,
      pollInterval: pollInterval,
      heartbeatInterval: heartbeatInterval,
      onChange: onChange,
    );
