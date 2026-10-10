import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_sdk/sockets/socket_manager.dart';

void main() {
  group('MediaSocketConnectException', () {
    test('a credential rejection is final and explained', () {
      final error = MediaSocketConnectException(
        phase: MediaSocketConnectPhase.rejected,
        reason: 'invalid-credentials',
        stage: 'api-check-rejected',
        elapsedMs: 42,
      );
      expect(error.retryable, isFalse);
      expect(isRetryableMediaSocketError(error), isFalse);
      expect(error.message,
          startsWith('Media server rejected the connection: invalid-credentials'));
      expect(error.message, contains('stage: api-check-rejected'));
      expect(describeMediaSocketError(error), contains('did not accept these credentials'));
    });

    test('meeting minutes and invalid requests are final; api checks are not', () {
      for (final reason in ['meeting-minutes-unavailable', 'invalid-request']) {
        expect(
            MediaSocketConnectException(
                    phase: MediaSocketConnectPhase.rejected, reason: reason, elapsedMs: 1)
                .retryable,
            isFalse);
      }
      final transient = MediaSocketConnectException(
          phase: MediaSocketConnectPhase.rejected, reason: 'api-check-failed', elapsedMs: 1);
      expect(transient.retryable, isTrue);
      expect(transient.userMessage, contains('try again shortly'));
    });

    test('unknown reasons map to rejected-before-connection-success', () {
      expect(normalizeRejectionReason('brand-new'), 'rejected-before-connection-success');
      expect(normalizeRejectionReason(null), 'rejected-before-connection-success');
      expect(normalizeRejectionReason('invalid-credentials'), 'invalid-credentials');
    });

    test('transport failures carry phase, elapsed time and online state', () {
      final offline = MediaSocketConnectException(
        phase: MediaSocketConnectPhase.beforeOpen,
        elapsedMs: 15,
        online: false,
        transportError: 'websocket error',
      );
      expect(offline.message,
          'Error connecting to media socket: websocket error (phase: before-open, after 15 ms, online: false)');
      expect(offline.userMessage, contains('offline'));
      expect(offline.retryable, isTrue);
      expect(
          MediaSocketConnectException(phase: MediaSocketConnectPhase.timeout, elapsedMs: 12000)
              .userMessage,
          contains('timed out'));
    });

    test('other errors fall back to the caller text', () {
      expect(describeMediaSocketError(Exception('x'), fallback: 'fallback'), 'fallback');
      expect(isRetryableMediaSocketError(Exception('x')), isTrue);
    });
  });

  test('connectSocket reports an unreachable server as before-open', () async {
    try {
      await connectSocket(ConnectSocketOptions(
        apiUserName: 'account',
        apiToken: 'a' * 64,
        link: 'http://127.0.0.1:9',
      ));
      fail('expected a connection failure');
    } on MediaSocketConnectException catch (error) {
      expect(error.phase, MediaSocketConnectPhase.beforeOpen);
      expect(error.elapsedMs, greaterThanOrEqualTo(0));
      expect(error.link, 'http://127.0.0.1:9');
      expect(error.message, startsWith('Error connecting to media socket:'));
    }
  }, timeout: const Timeout(Duration(seconds: 30)));
}
