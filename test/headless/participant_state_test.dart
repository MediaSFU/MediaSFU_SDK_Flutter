import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_sdk/methods/utils/headless/participant_state.dart';
import 'package:mediasfu_sdk/types/types.dart' show Participant, Stream;

class _Params implements ParticipantStateParameters {
  @override
  final List<Participant> participants;
  @override
  final List<Stream> allVideoStreams;
  @override
  final List<Stream> allAudioStreams;
  @override
  final String member;

  _Params({
    required this.participants,
    this.allVideoStreams = const [],
    this.allAudioStreams = const [],
    this.member = 'Ama',
  });
}

Participant _participant(
  String name, {
  String islevel = '1',
  String videoID = '',
  String audioID = '',
  String? id,
}) => Participant(
  name: name,
  islevel: islevel,
  videoID: videoID,
  audioID: audioID,
  id: id,
  muted: false,
);

void main() {
  group('participant media state', () {
    test('a participant id is never a producer id', () {
      // The membership id must not be matched against producerId — doing so is
      // why hand-rolled rosters report everyone as camera-off.
      final params = _Params(
        participants: [
          _participant('Kofi', id: 'member-1', videoID: 'kofi-video-producer'),
        ],
        allVideoStreams: [
          Stream(producerId: 'kofi-video-producer', stream: null),
        ],
      );
      final state = listParticipantMediaStates(params).single;
      expect(state.videoProducerId, 'kofi-video-producer');
      // No MediaStream attached yet, so not publishing.
      expect(state.cameraOn, isFalse);
    });

    test("'none' and short ids mean not publishing", () {
      final params = _Params(
        participants: [
          _participant('Kofi', videoID: 'none', audioID: ''),
        ],
      );
      final state = listParticipantMediaStates(params).single;
      expect(state.cameraOn, isFalse);
      expect(state.micOn, isFalse);
      expect(state.videoProducerId, isEmpty);
      expect(state.audioProducerId, isEmpty);
    });

    test('audio publishing follows the participant audio producer id', () {
      final params = _Params(
        participants: [
          _participant('Kofi', audioID: 'kofi-audio-producer'),
        ],
        allAudioStreams: [
          Stream(producerId: 'kofi-audio-producer', stream: null),
        ],
      );

      final state = listParticipantMediaStates(params).single;
      expect(state.audioProducerId, 'kofi-audio-producer');
      expect(state.micOn, isFalse);
    });

    test('host and self are identified without extra lookups', () {
      final params = _Params(
        member: 'Ama',
        participants: [
          _participant('Ama', islevel: '2'),
          _participant('Kofi'),
        ],
      );
      final states = listParticipantMediaStates(params);
      expect(states.first.isHost, isTrue);
      expect(states.first.isSelf, isTrue);
      expect(states.last.isHost, isFalse);
      expect(states.last.isSelf, isFalse);
      expect(getRoomHost(params)?.name, 'Ama');
    });

    test('roster order is preserved so tiles do not reshuffle', () {
      final params = _Params(
        participants: [
          _participant('A'),
          _participant('B'),
          _participant('C'),
        ],
      );
      expect(
        listParticipantMediaStates(params).map((s) => s.name).toList(),
        ['A', 'B', 'C'],
      );
    });
  });
}
