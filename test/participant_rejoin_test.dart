import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mediasfu_sdk/methods/utils/rejoin_credential_store.dart';
import 'package:mediasfu_sdk/producers/socket_receive_methods/session_replaced.dart';
import 'package:mediasfu_sdk/producers/socket_receive_methods/disconnect.dart';

void main() {
  final secretA = 'b' * 64;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('credentials are kept per room and name, only for valid secrets', () async {
    await rememberRejoinCredential(roomName: 'Room123', userName: 'Guest01', secret: secretA, link: 'https://sp1.mediasfu.com');
    await rememberRejoinCredential(roomName: 'room999', userName: 'guest01', secret: 'not-a-secret');
    expect((await readRejoinCredential('room123', 'guest01'))?.secret, secretA);
    expect(await readRejoinCredential('room123', 'other'), isNull);
    expect(await readRejoinCredential('room999', 'guest01'), isNull);
    await forgetRejoinCredential('room123', 'guest01');
    expect(await readRejoinCredential('room123', 'guest01'), isNull);
  });

  test('credentials expire after 24 hours', () async {
    final old = DateTime.now().millisecondsSinceEpoch - 25 * 60 * 60 * 1000;
    SharedPreferences.setMockInitialValues({
      'mediasfu:rejoin:room123:guest01':
          '{"roomName":"room123","userName":"guest01","secret":"$secretA","storedAt":$old}',
    });
    expect(await readRejoinCredential('room123', 'guest01'), isNull);
  });

  test('session-replaced without a context alerts once and quiets the following disconnect', () async {
    final alerts = <String>[];
    void showAlert({required String message, required String type, required int duration}) => alerts.add(message);
    await sessionReplaced(SessionReplacedOptions(data: {'reason': 'joined-elsewhere'}, showAlert: showAlert));
    expect(wasSessionReplaced(), isTrue);
    expect(alerts, [sessionReplacedMessage]);
    disconnect(DisconnectOptions(onWeb: false, showAlert: showAlert));
    expect(alerts, [sessionReplacedMessage]);
  });
}
