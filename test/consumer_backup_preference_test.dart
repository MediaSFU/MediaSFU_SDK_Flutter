import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_sdk/consumers/consumer_backup_preference.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

io.Socket _socket() => io.io(
      'http://localhost:1',
      io.OptionBuilder().disableAutoConnect().enableForceNew().setTransports(['websocket']).build(),
    );

void main() {
  tearDown(MediasfuConsumerBackups.forgetAll);

  test('prefers a connected backup for streams announced by its busy parent', () {
    MediasfuConsumerBackups.remember({'sc00901': 'sc00902'});
    final backup = _socket()..connected = true;
    final parent = _socket()..connected = true;
    final sockets = [
      {'sc00901': parent},
      {'sc00902': backup},
    ];
    expect(MediasfuConsumerBackups.preferredBackup('sc00901', sockets), 'sc00902');
    expect(MediasfuConsumerBackups.delayFor('sc00901', sockets), MediasfuConsumerBackups.preferDelay);
    expect(MediasfuConsumerBackups.delayFor('sc00902', sockets), Duration.zero);
    expect(MediasfuConsumerBackups.delayFor('sc00903', sockets), Duration.zero);
  });

  test('falls back to today\'s behaviour without a connected backup', () {
    MediasfuConsumerBackups.remember({'sc00901': 'sc00902', 'x': 'x'});
    final parent = _socket()..connected = true;
    final backup = _socket()..connected = false;
    expect(MediasfuConsumerBackups.delayFor('sc00901', [{'sc00901': parent}]), Duration.zero);
    expect(MediasfuConsumerBackups.delayFor('sc00901', [{'sc00902': backup}]), Duration.zero);
    expect(MediasfuConsumerBackups.delayFor('x', [{'x': parent}]), Duration.zero);
    expect(MediasfuConsumerBackups.delayFor('sc00901', null), Duration.zero);
  });
}
