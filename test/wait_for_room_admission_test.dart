import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mediasfu_sdk/methods/utils/create_join_room.dart';
import 'package:mediasfu_sdk/methods/utils/join_room_on_media_sfu.dart';
import 'package:mediasfu_sdk/methods/utils/wait_for_room_admission.dart';
import 'package:mediasfu_sdk/types/types.dart' show JoinMediaSFURoomOptions;
import 'package:shared_preferences/shared_preferences.dart';

final secret = 'a' * 64;
final apiKey = 'b' * 64;

MockClient scripted(List<http.Response> answers, List<Map<String, dynamic>> bodies) => MockClient((request) async {
      bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
      if (answers.isEmpty) throw StateError('no more answers');
      return answers.removeAt(0);
    });

http.Response json(int code, Object body) => http.Response(jsonEncode(body), code);

Future<WaitingRoomAdmission> run(MockClient client) => waitForRoomAdmission(
      roomName: 's123abc',
      userName: 'guest1',
      secret: secret,
      apiUserName: 'acct123',
      apiKey: apiKey,
      endpoint: 'https://x/v1/rooms/',
      client: client,
      sleep: (_) async {},
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('polls waitStatus until admitted', () async {
    final bodies = <Map<String, dynamic>>[];
    final result = await run(scripted([
      json(200, {'status': 'waiting', 'waiting': true, 'success': true}),
      json(504, {'code': 'wait-status-timeout'}),
      json(200, {'status': 'admitted', 'roomName': 's123abc', 'secret': secret, 'link': 'https://sp00901.mediasfu.com'}),
    ], bodies));
    expect(result.status, WaitingRoomStatus.admitted);
    expect(result.link, 'https://sp00901.mediasfu.com');
    expect(bodies.first, {'action': 'waitStatus', 'meetingID': 's123abc', 'userName': 'guest1', 'secret': secret});
  });

  test('declined, ended and an older server stop waiting', () async {
    expect((await run(scripted([json(403, {'status': 'declined'})], []))).error, waitingRoomDeclinedMessage);
    expect((await run(scripted([json(410, {'status': 'ended'})], []))).status, WaitingRoomStatus.ended);
    expect((await run(scripted([json(400, {'error': 'action must be'})], []))).error, waitingRoomUnsupportedMessage);
  });

  test('times out', () async {
    var t = DateTime(2026, 10, 14);
    final answers = List.generate(50, (_) => json(200, {'status': 'waiting'}));
    final result = await waitForRoomAdmission(
      roomName: 's123abc', userName: 'guest1', secret: secret, apiUserName: 'acct123', apiKey: apiKey,
      endpoint: 'https://x/v1/rooms/', client: scripted(answers, []),
      timeout: const Duration(seconds: 10),
      now: () => t,
      sleep: (d) async => t = t.add(d),
    );
    expect(result.status, WaitingRoomStatus.timeout);
  });

  test('listeners see waiting then the outcome', () async {
    final seen = <WaitingRoomStatus>[];
    void listener(WaitingRoomStatus s, String _) => seen.add(s);
    addWaitingRoomListener(listener);
    await run(scripted([json(403, {'status': 'declined'})], []));
    removeWaitingRoomListener(listener);
    expect(seen, [WaitingRoomStatus.waiting, WaitingRoomStatus.declined]);
  });

  test('joinRoomOnMediaSFU waits for admission and returns a normal join', () async {
    final answers = [
      json(200, {'waiting': true, 'roomName': 's123abc', 'userName': 'guest1', 'secret': secret, 'link': null, 'publicURL': null, 'success': true, 'message': 'Waiting for the host to let you in'}),
      json(200, {'status': 'admitted', 'roomName': 's123abc', 'secret': secret, 'link': 'https://sp00901.mediasfu.com', 'publicURL': 'u'}),
    ];
    final result = await http.runWithClient(
      () => joinRoomOnMediaSFU(JoinMediaSFUOptions(
        payload: JoinMediaSFURoomOptions(action: 'join', meetingID: 's123abc', userName: 'guest1'),
        apiUserName: 'acct123',
        apiKey: apiKey,
      )),
      () => scripted(answers, []),
    );
    expect(result.success, isTrue);
    final joined = result.data as CreateJoinRoomResponse;
    expect(joined.link, 'https://sp00901.mediasfu.com');
    expect(joined.secret, secret);
  }, timeout: const Timeout(Duration(seconds: 30)));
}
