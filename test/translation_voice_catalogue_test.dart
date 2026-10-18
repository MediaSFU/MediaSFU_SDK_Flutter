import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mediasfu_sdk/methods/utils/translation_languages.dart';
import 'package:mediasfu_sdk/components_modern/translation_components/translation_settings_modal.dart'
    as modal;

class FakeVoiceSocket extends io.Socket {
  FakeVoiceSocket()
    : super(
        io.io('http://127.0.0.1:9', <String, dynamic>{
          'autoConnect': false,
          'forceNew': true,
        }).io,
        '/',
        {'autoConnect': false},
      );
  final requests = <Map<String, dynamic>>[];
  final acknowledgements = <Function>[];
  final sent = <Map<String, dynamic>>[];
  bool throwOnEmit = false;
  @override
  void emitWithAck(
    String event,
    dynamic data, {
    Function? ack,
    bool binary = false,
  }) {
    if (throwOnEmit) throw StateError('private-provider-detail');
    sent.add({'event': event, 'data': data});
    if (event == 'translation:getVoices') {
      requests.add(Map<String, dynamic>.from(data as Map));
      if (ack != null) acknowledgements.add(ack);
    } else if (event == 'translation:getLanguages') {
      ack?.call({'languages': []});
    }
  }
}

Map<String, dynamic> catalogue([String id = 'stock']) => {
  'schemaVersion': 1,
  'provider': 'fish',
  'language': 'zh',
  'model': 's2.1-pro',
  'status': 'available',
  'truncated': true,
  'voices': {
    'neutral': [
      {'id': id, 'name': 'Stock voice'},
    ],
  },
};

modal.TranslationSettingsModalOptions options(
  FakeVoiceSocket socket,
  String room, {
  String model = 'first',
}) => modal.TranslationSettingsModalOptions(
  isVisible: true,
  onClose: () {},
  member: 'VoiceTest',
  islevel: '2',
  participants: [],
  listenerTranslationPreferences: null,
  listenerTranslationOverrides: {},
  translationProducerMap: {},
  speakerTranslationStates: {},
  updateListenerTranslationPreferences: (_) {},
  updateListenerTranslationOverrides: (_) {},
  updateTranslationProducerMap: (_) {},
  updateSpeakerTranslationStates: (_) {},
  socket: socket,
  roomName: room,
  mySpokenLanguage: 'fr',
  mySpokenLanguageEnabled: true,
  myDefaultOutputLanguage: 'zh',
  translationConfig: modal.TranslationRoomConfig.fromMap({
    'supportTranslation': true,
    'translationVoiceConfig': {
      'ttsNickName': 'FriendlyNickname',
      'ttsParams': {'model': model},
    },
  }),
);

Widget screen(FakeVoiceSocket socket, String room, {String model = 'first'}) =>
    MaterialApp(
      home: Scaffold(
        body: modal.TranslationSettingsModal(
          key: const ValueKey('voice-modal'),
          options: options(socket, room, model: model),
          enableGlassmorphism: false,
          enableGlow: false,
        ),
      ),
    );

void main() {
  test('server-discovered providers never get invented Deepgram voices', () {
    for (final provider in ['fish', 'sarvam', 'xai', 'playht', 'unknown']) {
      expect(getDefaultVoice('zh', provider: provider), isNull);
      expect(
        getAvailableVoices('zh', provider: provider).values.expand((v) => v),
        isEmpty,
      );
    }
    expect(
      TTSProvider.values.map((v) => v.name),
      containsAll(['fish', 'sarvam', 'xai']),
    );
  });
  test(
    'authoritative provider, neutral identity and model/status metadata',
    () {
      final response = parseVoiceCatalogue(catalogue(), 'zh');
      expect(response.provider, 'fish');
      expect(response.voices['neutral']!.single.id, 'stock');
      expect(response.voices['neutral']!.single.gender, VoiceGender.neutral);
      expect(response.voices['neutral']!.single.provider, 'fish');
      expect(response.model, 's2.1-pro');
      expect(response.status, 'available');
      expect(response.truncated, isTrue);
    },
  );
  test(
    'legacy string IDs preserved, malformed IDs skipped, duplicates removed',
    () {
      final response = parseVoiceCatalogue({
        'provider': 'azure',
        'voices': {
          'male': [
            'fr-FR-HenriNeural',
            null,
            {},
            {'id': 12},
          ],
          'neutral': ['fr-FR-HenriNeural'],
        },
      }, 'fr');
      expect(response.voices['male']!.single.id, 'fr-FR-HenriNeural');
      expect(response.voices['neutral'], isEmpty);
    },
  );
  test(
    'invalid replies and provider errors never fall back or export raw errors',
    () {
      for (final raw in [
        null,
        [],
        {'voices': {}},
        {'provider': 'fish', 'voices': 2},
        {...catalogue(), 'error': 'private-provider-detail'},
        {
          ...catalogue(),
          'error': {'message': 'private-provider-detail'},
        },
        {...catalogue(), 'schemaVersion': 2},
      ]) {
        final response = parseVoiceCatalogue(raw, 'zh');
        expect(response.voices.values.expand((v) => v), isEmpty);
        expect(response.status, 'unavailable');
        expect(response.error, isNot(contains('private-provider-detail')));
      }
    },
  );
  test(
    'request includes joined room and late duplicate acknowledgement is ignored',
    () async {
      final socket = FakeVoiceSocket();
      final future = fetchVoicesViaSocket(
        socket,
        'FriendlyNickname',
        'zh',
        roomName: 'fixture',
      );
      expect(socket.requests.single['roomName'], 'fixture');
      expect(socket.requests.single['language'], 'zh');
      socket.acknowledgements.single(catalogue());
      final response = await future;
      socket.acknowledgements.single({'provider': 'deepgram', 'voices': {}});
      expect(response.provider, 'fish');
      socket.dispose();
    },
  );
  test('timeout and synchronous emit failure return empty results', () async {
    final socket = FakeVoiceSocket();
    final response = await fetchVoicesViaSocket(
      socket,
      'fish',
      'zh',
      roomName: 'fixture',
      requestTimeout: const Duration(milliseconds: 1),
    );
    socket.acknowledgements.single(catalogue());
    expect(response.provider, isEmpty);
    expect(response.voices.values.expand((v) => v), isEmpty);
    socket.throwOnEmit = true;
    final failure = await fetchVoicesViaSocket(
      socket,
      'fish',
      'zh',
      roomName: 'fixture',
    );
    expect(failure.status, 'unavailable');
    expect(failure.error, isNot(contains('private-provider-detail')));
    socket.dispose();
  });
  testWidgets(
    'actual picker displays neutral entries beyond six and submits exact ID/provider',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      final socket = FakeVoiceSocket();
      await tester.pumpWidget(screen(socket, 'fixture'));
      expect(socket.requests.single['roomName'], 'fixture');
      expect(socket.requests.single['language'], 'zh');
      socket.acknowledgements.single({
        ...catalogue(),
        'voices': {
          'neutral': [
            for (var i = 0; i < 9; i++) {'id': 'stock$i', 'name': 'Voice $i'},
          ],
        },
      });
      await tester.pump(const Duration(milliseconds: 300));
      await tester.ensureVisible(find.text('⚙️ Advanced'));
      await tester.tap(find.text('⚙️ Advanced'));
      await tester.pump();
      expect(find.text('Neutral / unspecified voices'), findsOneWidget);
      expect(find.text('Voice 8'), findsOneWidget);
      await tester.ensureVisible(find.text('Voice 8'));
      await tester.tap(find.text('Voice 8'));
      await tester.pump();
      await tester.ensureVisible(find.text('Apply Changes'));
      await tester.tap(find.text('Apply Changes'));
      await tester.pump();
      final request = socket.sent.lastWhere(
        (r) => r['event'] == 'translation:setMyLanguage',
      );
      expect(request['data']['voiceConfig'], {
        'voiceId': 'stock8',
        'ttsProvider': 'fish',
      });
      await tester.pumpWidget(const SizedBox());
      socket.dispose();
      await tester.binding.setSurfaceSize(null);
    },
  );
  testWidgets(
    'room changes invalidate selection and reject previous-room responses',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      final socket = FakeVoiceSocket();
      await tester.pumpWidget(screen(socket, 'fixture'));
      await tester.pumpWidget(screen(socket, 'nextroom'));
      expect(socket.requests.length, 2);
      socket.acknowledgements[0](catalogue('stale'));
      socket.acknowledgements[1](catalogue('current'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.ensureVisible(find.text('⚙️ Advanced'));
      await tester.tap(find.text('⚙️ Advanced'));
      await tester.pump();
      expect(find.text('Stock voice'), findsOneWidget);
      await tester.tap(find.text('Stock voice'));
      await tester.ensureVisible(find.text('Apply Changes'));
      await tester.tap(find.text('Apply Changes'));
      await tester.pump();
      final request = socket.sent.lastWhere(
        (r) => r['event'] == 'translation:setMyLanguage',
      );
      expect(request['data']['roomName'], 'nextroom');
      expect(request['data']['voiceConfig']['voiceId'], 'current');
      await tester.pumpWidget(const SizedBox());
      socket.dispose();
      await tester.binding.setSurfaceSize(null);
    },
  );
  testWidgets(
    'semantic config stability avoids refetch; model change clears selected ID',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      final socket = FakeVoiceSocket();
      await tester.pumpWidget(screen(socket, 'fixture'));
      socket.acknowledgements[0](catalogue('old'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.ensureVisible(find.text('⚙️ Advanced'));
      await tester.tap(find.text('⚙️ Advanced'));
      await tester.pump();
      await tester.tap(find.text('Stock voice'));
      await tester.pumpWidget(screen(socket, 'fixture'));
      expect(socket.requests.length, 1);
      await tester.pumpWidget(screen(socket, 'fixture', model: 'changed'));
      expect(socket.requests.length, 2);
      await tester.ensureVisible(find.text('Apply Changes'));
      await tester.tap(find.text('Apply Changes'));
      await tester.pump();
      final request = socket.sent.lastWhere(
        (r) => r['event'] == 'translation:setMyLanguage',
      );
      expect(request['data']['voiceConfig'].containsKey('voiceId'), isFalse);
      socket.acknowledgements[1](catalogue('new'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      socket.dispose();
      await tester.binding.setSurfaceSize(null);
    },
  );
}
