import 'dart:async';

/// Send-side serialisation.
///
/// The media server keeps one producer transport per socket. When two media actions (microphone and camera turned on
/// together, a rejoin while a toggle is in flight) each ask for a send transport, the second `createWebRtcTransport`
/// replaces the first on the server: both client transports then send `transport-connect` to the same server
/// transport, the second fails ("connect() already called") and the device's uplink goes silent. Likewise two
/// concurrent produces of the same source create two producers where the server accepts one.
///
/// These helpers make later callers wait for the creation in flight and skip a produce that is already under way.
class SendTransportGuard {
  SendTransportGuard._();

  // Keyed by the socket object: one creation per socket, released as soon as it settles.
  static final Expando<Future<void>> _creations = Expando<Future<void>>('sendTransportCreation');

  // Keyed by transport, then by source (mic, camera, screen): when the produce started.
  static final Expando<Map<String, DateTime>> _produces = Expando<Map<String, DateTime>>('sendTransportProduce');

  /// A produce that has not reported its producer within this time is treated as failed.
  static const Duration produceTimeout = Duration(seconds: 10);

  /// The send-transport creation in flight for this socket, if any.
  static Future<void>? pendingCreation(Object? socket) => socket == null ? null : _creations[socket];

  /// Runs [create] as the only send-transport creation for this socket until it settles.
  static Future<void> trackCreation(Object? socket, Future<void> Function() create) {
    if (socket == null) return create();
    final running = create();
    _creations[socket] = running;
    void release() {
      if (identical(_creations[socket], running)) _creations[socket] = null;
    }

    running.then((_) => release(), onError: (_) => release());
    return running;
  }

  /// Claims a produce of [source] on [transport]. Returns false while the same produce is already in flight, so the
  /// caller skips its own produce instead of creating a second producer.
  static bool beginProduce(Object? transport, String source, {DateTime? now}) {
    if (transport == null) return true;
    final current = now ?? DateTime.now();
    final bySource = _produces[transport] ??= <String, DateTime>{};
    final started = bySource[source];
    if (started != null && current.difference(started) < produceTimeout) return false;
    bySource[source] = current;
    return true;
  }

  /// Releases the claim once the producer for [source] exists (or the produce failed).
  static void finishProduce(Object? transport, String? source) {
    if (transport == null || source == null) return;
    _produces[transport]?.remove(source);
  }
}
