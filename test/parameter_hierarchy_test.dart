import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'room parameter hierarchy preserves contracts with bounded traversal',
    () {
      final graph = <String, List<String>>{};
      final declarations = RegExp(
        r'^(?:abstract\s+)?(?:interface\s+)?class\s+(\w+)([^\{;]*)\{',
        multiLine: true,
      );
      for (final file in Directory(
        'lib',
      ).listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        for (final match in declarations.allMatches(file.readAsStringSync())) {
          final header = match.group(2)!;
          if (!match.group(1)!.endsWith('Parameters')) continue;
          graph[match.group(1)!] = header
              .replaceAll(RegExp(r'\b(extends|implements|with)\b'), ',')
              .split(',')
              .map((name) => name.trim())
              .where((name) => name.isNotEmpty)
              .toList();
        }
      }
      final interfaces = <String>{};
      int visit(String name, Set<String> ancestors) {
        expect(
          ancestors,
          isNot(contains(name)),
          reason: 'Inheritance cycle at $name',
        );
        var visits = 1;
        for (final parent in graph[name] ?? <String>[]) {
          interfaces.add(parent);
          visits += visit(parent, {...ancestors, name});
        }
        return visits;
      }

      final visits = visit('MediasfuParameters', {});
      expect(
        interfaces,
        containsAll(<String>[
          'AddVideosGridParameters',
          'AdvancedPanelComponentParameters',
          'AllMembersParameters',
          'AllMembersRestParameters',
          'AudioCardParameters',
          'AudioDecibelCheckParameters',
          'BackgroundModalParameters',
          'BanParticipantParameters',
          'BreakoutRoomUpdatedParameters',
          'BreakoutRoomsModalParameters',
          'CaptureCanvasStreamParameters',
          'ChangeVidsParameters',
          'CheckScreenShareParameters',
          'ClickAudioParameters',
          'ClickScreenShareParameters',
          'ClickVideoParameters',
          'CloseAndResizeParameters',
          'CompareActiveNamesParameters',
          'CompareScreenStatesParameters',
          'ConfigureWhiteboardModalParameters',
          'ConfirmRecordingParameters',
          'ConnectIpsParameters',
          'ConnectLocalIpsParameters',
          'ConnectRecvTransportParameters',
          'ConnectSendTransportAudioParameters',
          'ConnectSendTransportParameters',
          'ConnectSendTransportScreenParameters',
          'ConnectSendTransportVideoParameters',
          'ConsumerResumeParameters',
          'ControlMediaHostParameters',
          'CreateSendTransportParameters',
          'DisconnectSendTransportAudioParameters',
          'DisconnectSendTransportScreenParameters',
          'DisconnectSendTransportVideoParameters',
          'DispStreamsParameters',
          'DisplaySettingsModalParameters',
          'GeneratePageContentParameters',
          'GetDomainsParameters',
          'GetEstimateParameters',
          'GetParticipantMediaParameters',
          'GetPipedProducersAltParameters',
          'JoinConsumeRoomParameters',
          'MediaPermissionsParameters',
          'MediaSettingsModalParameters',
          'MediaStreamsParameters',
          'MiniAudioPlayerParameters',
          'ModerationParameters',
          'ModifyDisplaySettingsParameters',
          'NewPipeProducerParameters',
          'OnScreenChangesParameters',
          'PaginationParameters',
          'ParticipantStateParameters',
          'ParticipantsModalParameters',
          'PrepopulateUserMediaParameters',
          'ProcessConsumerTransportsAudioParameters',
          'ProcessConsumerTransportsParameters',
          'ProducerClosedParameters',
          'ProducerMediaClosedParameters',
          'ProducerMediaPausedParameters',
          'ProducerMediaResumedParameters',
          'RePortParameters',
          'ReUpdateInterParameters',
          'ReadjustParameters',
          'ReceiveAllPipedTransportsParameters',
          'RecordResumeTimerParameters',
          'RecordStartTimerParameters',
          'RecordingModalParameters',
          'RecordingNoticeParameters',
          'ReorderStreamsParameters',
          'RequestScreenShareParameters',
          'RequestsModalParameters',
          'ResumePauseAudioStreamsParameters',
          'ResumePauseStreamsParameters',
          'ResumeSendTransportAudioParameters',
          'RoomActionsParameters',
          'RoomReadinessParameters',
          'RoomRecordParamsParameters',
          'ScreenboardModalParameters',
          'ScreenboardParameters',
          'SignalNewConsumerTransportParameters',
          'StandardPanelComponentParameters',
          'StartConsumingTranslationParameters',
          'StartMeetingProgressTimerParameters',
          'StartRecordingParameters',
          'StartShareScreenParameters',
          'StopRecordingParameters',
          'StopShareScreenParameters',
          'StreamSuccessAudioParameters',
          'StreamSuccessAudioSwitchParameters',
          'StreamSuccessScreenParameters',
          'StreamSuccessVideoParameters',
          'SwitchAudioParameters',
          'SwitchUserAudioParameters',
          'SwitchUserVideoAltParameters',
          'SwitchUserVideoParameters',
          'SwitchVideoAltParameters',
          'SwitchVideoParameters',
          'TriggerParameters',
          'UpdateConsumingDomainsParameters',
          'UpdateMiniCardsGridParameters',
          'UpdateRecordingParameters',
          'UpdateRoomParametersClientParameters',
          'VideoCardParameters',
          'WaitingRoomModalParameters',
          'WhiteboardParameters',
        ]),
      );
      // Repeated diamond paths amplify VM class-hierarchy work in debug/JIT.
      expect(visits, lessThan(1000));
    },
  );
}
