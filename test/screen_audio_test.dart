import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_sdk/consumers/screen_audio.dart';
import 'package:mediasfu_sdk/types/types.dart' show ResponseJoinRoom, Participant;
import 'package:socket_io_client/socket_io_client.dart' as io;

io.Socket _socket() => io.io(
      'http://localhost:1',
      io.OptionBuilder().disableAutoConnect().enableForceNew().setTransports(['websocket']).build(),
    );

void main() {
  setUp(() => MediasfuScreenAudio.canCaptureDisplayAudio = () => true);
  tearDown(() {
    MediasfuScreenAudio.enabled = true;
    MediasfuScreenAudio.mode = ScreenAudioMode.ask;
    MediasfuScreenAudio.prompt = null;
    MediasfuScreenAudio.canCaptureDisplayAudio = null;
  });

  test('join response carries the server screen-audio capability', () {
    expect(ResponseJoinRoom.fromJson({'supportsScreenAudio': true}).supportsScreenAudio, isTrue);
    expect(ResponseJoinRoom.fromJson({}).supportsScreenAudio, isFalse);
  });

  test('screen audio is requested only on web, with server support, when enabled', () {
    final socket = _socket();
    expect(MediasfuScreenAudio.shouldRequestAudio(socket, onWeb: true), isFalse);
    expect(MediasfuScreenAudio.displayAudioConstraint(socket, onWeb: true), isFalse);

    MediasfuScreenAudio.rememberSupport(socket, true);
    expect(MediasfuScreenAudio.shouldRequestAudio(socket, onWeb: true), isTrue);
    expect(MediasfuScreenAudio.shouldRequestAudio(socket, onWeb: false), isFalse);
    expect(
      MediasfuScreenAudio.displayAudioConstraint(socket, onWeb: true),
      {'echoCancellation': false, 'noiseSuppression': false, 'autoGainControl': false},
    );

    MediasfuScreenAudio.enabled = false;
    expect(MediasfuScreenAudio.shouldRequestAudio(socket, onWeb: true), isFalse);

    // Support is per producer socket.
    expect(MediasfuScreenAudio.isSupported(_socket()), isFalse);
    expect(MediasfuScreenAudio.isSupported(null), isFalse);
  });

  test('closing without a screen-audio producer is a no-op', () {
    final socket = _socket();
    expect(MediasfuScreenAudio.producerFor(socket), isNull);
    MediasfuScreenAudio.close(socket, notifyServer: true);
    expect(MediasfuScreenAudio.producerFor(socket), isNull);
  });

  test('the roster exposes the sharer screen-audio producer without a model change', () {
    final participant = Participant.fromMap({
      'name': 'alice',
      'audioID': 'mic-a',
      'videoID': '',
      'ScreenID': 'screen-video-1',
      'ScreenAudioID': 'screen-audio-1',
    });
    expect(participant.audioID, 'mic-a');
    expect(participant['ScreenAudioID'], 'screen-audio-1');
  });

  test('mode and browser capability gate the request', () async {
    final socket = _socket();
    MediasfuScreenAudio.rememberSupport(socket, true);
    expect(MediasfuScreenAudio.shouldRequestAudio(socket, onWeb: true), isTrue);
    MediasfuScreenAudio.canCaptureDisplayAudio = () => false; // e.g. Firefox, Safari
    expect(MediasfuScreenAudio.shouldRequestAudio(socket, onWeb: true), isFalse);
    expect(await MediasfuScreenAudio.resolveShareAudio(socket, null, onWeb: true), isFalse);
    MediasfuScreenAudio.canCaptureDisplayAudio = () => true;
    MediasfuScreenAudio.mode = ScreenAudioMode.never;
    expect(MediasfuScreenAudio.shouldRequestAudio(socket, onWeb: true), isFalse);
    MediasfuScreenAudio.mode = ScreenAudioMode.always;
    expect(await MediasfuScreenAudio.resolveShareAudio(socket, null, onWeb: true), isTrue);
  });

  testWidgets('ask mode shows the dialog and follows the answer', (tester) async {
    final socket = _socket();
    MediasfuScreenAudio.rememberSupport(socket, true);
    for (final entry in {'Screen + audio': true, 'Screen only': false, 'Cancel': null}.entries) {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      })));
      final pending = MediasfuScreenAudio.resolveShareAudio(socket, ctx, onWeb: true);
      await tester.pumpAndSettle();
      expect(find.text('Share audio too?'), findsOneWidget);
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(await pending, entry.value, reason: entry.key);
    }
  });

  test('listeners recognise screen audio by tag or roster and name its sharer', () {
    final alice = Participant.fromMap({
      'name': 'alice', 'audioID': 'mic-a', 'videoID': '', 'ScreenID': 'scr', 'ScreenOn': true, 'ScreenAudioID': 'sa-1',
    });
    final bob = Participant.fromMap({'name': 'bob', 'audioID': 'mic-b', 'videoID': ''});
    expect(MediasfuScreenAudio.isScreenAudioProducer('sa-1', [alice, bob]), isTrue);
    expect(MediasfuScreenAudio.isScreenAudioProducer('mic-a', [alice, bob]), isFalse);
    expect(MediasfuScreenAudio.isScreenAudioProducer('sa-2', [bob]), isFalse);
    MediasfuScreenAudio.markProducer('sa-2', 'audio');
    expect(MediasfuScreenAudio.isScreenAudioProducer('sa-2', [bob]), isFalse);
    MediasfuScreenAudio.markProducer('sa-2', 'screen-audio');
    expect(MediasfuScreenAudio.isScreenAudioProducer('sa-2', [bob]), isTrue);
    MediasfuScreenAudio.forgetProducer('sa-2');
    expect(MediasfuScreenAudio.isScreenAudioProducer('sa-2', [bob]), isFalse);
    expect(MediasfuScreenAudio.ownerName('sa-1', [alice, bob]), 'alice');
    expect(MediasfuScreenAudio.ownerName('other', [bob, alice]), 'alice');
  });

  test('the sharer toggle is a no-op without screen audio', () {
    expect(MediasfuScreenAudio.toggle(_socket()), isNull);
  });
}
