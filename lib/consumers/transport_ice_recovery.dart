import 'dart:async';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

// One recovery attempt sequence per transport, independent of duplicate events.
final Expando<Future<bool>> _pendingIceRecovery = Expando<Future<bool>>();

Future<bool> recoverTransportIce(Transport transport, io.Socket socket) {
  final pending = _pendingIceRecovery[transport];
  if (pending != null) return pending;
  final operation = _recover(transport, socket);
  _pendingIceRecovery[transport] = operation;
  operation.whenComplete(() => _pendingIceRecovery[transport] = null);
  return operation;
}

Future<bool> _recover(Transport transport, io.Socket socket) async {
  final socketId = socket.id;
  bool current() => !transport.closed && socket.connected && socket.id == socketId;
  // Brief network changes often recover without renegotiation. A true failed
  // state ends the grace immediately; duplicate events share this operation.
  final grace = DateTime.now().add(const Duration(seconds: 3));
  while (current() && transport.connectionState == 'disconnected' &&
      DateTime.now().isBefore(grace)) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  if (!current()) return false;
  if (transport.connectionState == 'connected') return true;
  for (var attempt = 0; attempt < 2 && current(); attempt++) {
    try {
      final ack = Completer<dynamic>();
      socket.emitWithAck('transport-restart-ice',
        {'transportId': transport.id},
        ack: (dynamic response) { if (!ack.isCompleted) ack.complete(response); });
      final response = await ack.future.timeout(const Duration(seconds: 8));
      if (!current()) return false;
      if (response is! Map || response['error'] != null || response['iceParameters'] is! Map) {
        throw StateError('ICE restart rejected');
      }
      transport.restartIce(IceParameters.fromMap(
        Map<String, dynamic>.from(response['iceParameters'] as Map)));
      // restartIce enqueues work and returns void in the Dart client.
      // Give that queue a turn before observing connection state.
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (current() && DateTime.now().isBefore(deadline)) {
        if (transport.connectionState == 'connected') return true;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    } catch (_) {
      if (!current()) return false;
    }
    if (attempt == 0 && current()) {
      await Future<void>.delayed(const Duration(milliseconds: 2100));
    }
  }
  return false;
}
