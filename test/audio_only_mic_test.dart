import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_sdk/methods/stream_methods/click_audio.dart';
import 'package:mediasfu_sdk/types/types.dart' show Participant;

/// Audio-only rooms (meetingRoomParams.mediaType 'audio' sets audioOnlyRoom) must still let people unmute.
/// clickAudio used to return early on audioOnlyRoom with the camera message, so nobody could ever speak.
///
/// There is no WebRTC platform in unit tests, so the microphone request itself fails; reaching that request (and its
/// "Allow access to your microphone" message) is the proof that the audio-only guard no longer stops the click.
class _Params implements ClickAudioParameters {
  _Params({this.islevel = '2', this.adminRestrictSetting = false});

  final List<String> alerts = [];

  @override
  final String islevel;
  @override
  final bool adminRestrictSetting;
  @override
  bool get audioOnlyRoom => true;
  @override
  bool get checkMediaPermission => false;
  @override
  bool get hasAudioPermission => true;
  @override
  bool get audioPaused => false;
  @override
  bool get audioAlreadyOn => false;
  @override
  bool get recordStarted => false;
  @override
  bool get recordResumed => false;
  @override
  bool get recordPaused => false;
  @override
  bool get recordStopped => false;
  @override
  String get recordingMediaOptions => 'video';
  @override
  bool get youAreCoHost => false;
  @override
  String? get audioRequestState => null;
  @override
  int? get audioRequestTime => null;
  @override
  String get member => 'Asha748';
  @override
  String get roomName => 'pmroom01';
  @override
  String get userDefaultAudioInputDevice => '';
  @override
  bool get micAction => false;
  @override
  String get audioSetting => 'allow';
  @override
  String get videoSetting => 'allow';
  @override
  String get screenshareSetting => 'allow';
  @override
  String get chatSetting => 'allow';
  @override
  int get updateRequestIntervalSeconds => 240;
  @override
  List<Participant> get participants => const [];
  @override
  bool get transportCreated => false;
  @override
  bool get transportCreatedAudio => false;
  @override
  bool get panellistFocused => false;
  @override
  bool get muteOthersMic => false;
  @override
  bool get muteOthersCamera => false;
  @override
  List<Participant> get panelists => const [];
  @override
  get showAlert => ({required String message, required String type, required int duration}) => alerts.add(message);
  @override
  get checkPermission => (options) async => 0;
  @override
  ClickAudioParameters Function() get getUpdatedAllParams => () => this;
  @override
  void Function(bool) get updateAudioAlreadyOn => (_) {};
  @override
  void Function(String?) get updateAudioRequestState => (_) {};
  @override
  void Function(bool) get updateAudioPaused => (_) {};
  @override
  get updateLocalStream => (_) {};
  @override
  void Function(List<Participant>) get updateParticipants => (_) {};
  @override
  void Function(bool) get updateTransportCreated => (_) {};
  @override
  void Function(bool) get updateTransportCreatedAudio => (_) {};
  @override
  void Function(bool) get updateMicAction => (_) {};
  @override
  get streamSuccessAudio => (options) async {};
  @override
  get disconnectSendTransportAudio => (options) async {};
  @override
  get requestPermissionAudio => () async => true;
  @override
  get resumeSendTransportAudio => ({required options}) async {};

  // Everything else (socket, streams, transport callbacks) is not reached before the microphone request.
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the host can unmute in an audio-only room', () async {
    final p = _Params();
    await clickAudio(ClickAudioOptions(parameters: p));
    expect(p.alerts.where((m) => m.toLowerCase().contains('camera')), isEmpty);
    expect(p.alerts, contains(startsWith('Allow access to your microphone')));
  });

  test('a participant with audio allowed reaches the microphone request too', () async {
    final p = _Params(islevel: '1');
    await clickAudio(ClickAudioOptions(parameters: p));
    expect(p.alerts.where((m) => m.toLowerCase().contains('camera')), isEmpty);
    expect(p.alerts, contains(startsWith('Allow access to your microphone')));
  });

  test('the host restriction still blocks the microphone', () async {
    final p = _Params(islevel: '1', adminRestrictSetting: true);
    await clickAudio(ClickAudioOptions(parameters: p));
    expect(p.alerts, contains(contains('Access denied by host')));
  });
}
