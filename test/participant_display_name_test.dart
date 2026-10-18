import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_sdk/producers/socket_receive_methods/person_joined.dart';
import 'package:mediasfu_sdk/types/types.dart' show Participant, Stream;

/// Rooms store a readable displayName next to the 2-10 character member name; labels and notices should use it,
/// while `name` stays the identity used for matching.
void main() {
  Map<String, dynamic> member(Map<String, dynamic> extra) =>
      {'audioID': '', 'videoID': '', 'name': 'Asha748', ...extra};

  test('label is the display name when the roster carries one', () {
    final p = Participant.fromMap(member({'displayName': 'Asha Test'}));
    expect(p.name, 'Asha748');
    expect(p.displayName, 'Asha Test');
    expect(p.label, 'Asha Test');
    expect(p.toMap()['displayName'], 'Asha Test');
  });

  test('label falls back to the member name', () {
    expect(Participant.fromMap(member({})).label, 'Asha748');
    expect(Participant.fromMap(member({'displayName': '  '})).label, 'Asha748');
  });

  test('the join notice uses the display name when known', () {
    final messages = <String>[];
    void showAlert({required String message, required String type, required int duration}) => messages.add(message);
    personJoined(PersonJoinedOptions(name: 'Asha748', displayName: 'Asha Test', showAlert: showAlert));
    personJoined(PersonJoinedOptions(name: 'Ravi512', showAlert: showAlert));
    expect(messages, ['Asha Test has joined the event.', 'Ravi512 has joined the event.']);
  });

  test('grid entries copied from a participant keep the display name (mini card labels)', () {
    final p = Participant.fromMap(member({'displayName': 'Dr Ravi Rao', 'name': 'DrRao497'}));
    final s = Stream.fromMap(p.toMap());
    expect(s.name, 'DrRao497');
    expect(s.label, 'Dr Ravi Rao');
    expect(Stream.fromMap({'producerId': '', 'name': 'Ravi512'}).label, 'Ravi512');
  });
}
