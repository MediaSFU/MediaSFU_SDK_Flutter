// ignore_for_file: empty_catches, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
// import 'package:permission_handler/permission_handler.dart'; // handle permissions manually
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import 'package:flutter/services.dart'; // Import Services for platform-specific services
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

//initial values
import '../../methods/utils/initial_values.dart' show initialValuesState;

//import components for display (samples)
import '../display_components/meeting_progress_timer.dart'
    show MeetingProgressTimer;
import '../display_components/main_aspect_component.dart'
    show MainAspectComponent;
import '../display_components/loading_modal.dart' show LoadingModal;
import '../display_components/control_buttons_component.dart'
    show ControlButtonsComponent;
import '../display_components/control_buttons_alt_component.dart'
    show ControlButtonsAltComponent;
import '../display_components/control_buttons_component_touch.dart'
    show ControlButtonsComponentTouch;
import '../display_components/other_grid_component.dart'
    show OtherGridComponent;
import '../display_components/main_screen_component.dart'
    show MainScreenComponent;
import '../display_components/main_grid_component.dart' show MainGridComponent;
import '../display_components/sub_aspect_component.dart'
    show SubAspectComponent;
import '../display_components/main_container_component.dart'
    show MainContainerComponent;
import '../display_components/alert_component.dart' show AlertComponent;
import '../menu_components/menu_modal.dart' show MenuModal;
import '../recording_components/recording_modal.dart' show RecordingModal;
import '../requests_components/requests_modal.dart' show RequestsModal;
import '../waiting_components/waiting_modal.dart' show WaitingRoomModal;
import '../display_settings_components/display_settings_modal.dart'
    show DisplaySettingsModal;
import '../event_settings_components/event_settings_modal.dart'
    show EventSettingsModal;
import '../co_host_components/co_host_modal.dart' show CoHostModal;
import '../participants_components/participants_modal.dart'
    show ParticipantsModal;
import '../message_components/messages_modal.dart' show MessagesModal;
import '../media_settings_components/media_settings_modal.dart'
    show MediaSettingsModal;
import '../exit_components/confirm_exit_modal.dart' show ConfirmExitModal;
import '../misc_components/confirm_here_modal.dart' show ConfirmHereModal;
import '../misc_components/share_event_modal.dart' show ShareEventModal;
import '../misc_components/welcome_page.dart' show WelcomePage;

import '../polls_components/poll_modal.dart' show PollModal;
import '../breakout_components/breakout_rooms_modal.dart'
    show BreakoutRoomsModal;

// Pagination and display of media (samples)
import '../display_components/pagination.dart' show Pagination;
import '../display_components/flexible_grid.dart' show FlexibleGrid;
import '../display_components/flexible_video.dart' show FlexibleVideo;
import '../display_components/audio_grid.dart' show AudioGrid;

// Import methods for control (samples)
import '../../methods/menu_methods/launch_menu_modal.dart' show launchMenuModal;
import '../../methods/recording_methods/launch_recording.dart'
    show launchRecording;
import '../../methods/recording_methods/start_recording.dart'
    show startRecording;
import '../../methods/recording_methods/confirm_recording.dart'
    show confirmRecording;
import '../../methods/waiting_methods/launch_waiting.dart' show launchWaiting;
import '../../methods/co_host_methods/launch_co_host.dart' show launchCoHost;
import '../../methods/media_settings_methods/launch_media_settings.dart'
    show launchMediaSettings;
import '../../methods/display_settings_methods/launch_display_settings.dart'
    show launchDisplaySettings;
import '../../methods/settings_methods/launch_settings.dart'
    show launchSettings;
import '../../methods/requests_methods/launch_requests.dart'
    show launchRequests;
import '../../methods/participants_methods/launch_participants.dart'
    show launchParticipants;
import '../../methods/message_methods/launch_messages.dart' show launchMessages;
import '../../methods/exit_methods/launch_confirm_exit.dart'
    show launchConfirmExit;

import '../../methods/polls_methods/launch_poll.dart' show launchPoll;
import '../../methods/breakout_rooms_methods/launch_breakout_rooms.dart'
    show launchBreakoutRooms;

// Mediasfu functions -- examples
import '../../sockets/socket_manager.dart' show connectSocket;
import '../../producer_client/producer_client_emits/join_room_client.dart'
    show joinRoomClient;
import '../../producer_client/producer_client_emits/update_room_parameters_client.dart'
    show updateRoomParametersClient;
import '../../producer_client/producer_client_emits/create_device_client.dart'
    show createDeviceClient;

// Stream methods
import '../../methods/stream_methods/switch_video_alt.dart' show switchVideoAlt;
import '../../methods/stream_methods/click_video.dart' show clickVideo;
import '../../methods/stream_methods/click_audio.dart' show clickAudio;
import '../../methods/stream_methods/click_screen_share.dart'
    show clickScreenShare;

// Consumer functions
import '../../consumers/stream_success_video.dart' show streamSuccessVideo;
import '../../consumers/stream_success_audio.dart' show streamSuccessAudio;
import '../../consumers/stream_success_screen.dart' show streamSuccessScreen;
import '../../consumers/stream_success_audio_switch.dart'
    show streamSuccessAudioSwitch;
import '../../consumers/check_permission.dart' show checkPermission;

import '../../consumers/update_mini_cards_grid.dart' show updateMiniCardsGrid;
import '../../consumers/mix_streams.dart' show mixStreams;
import '../../consumers/disp_streams.dart' show dispStreams;
import '../../consumers/stop_share_screen.dart' show stopShareScreen;
import '../../consumers/check_screen_share.dart' show checkScreenShare;
import '../../consumers/start_share_screen.dart' show startShareScreen;
import '../../consumers/request_screen_share.dart' show requestScreenShare;
import '../../consumers/reorder_streams.dart' show reorderStreams;
import '../../consumers/prepopulate_user_media.dart' show prepopulateUserMedia;
import '../../consumers/get_videos.dart' show getVideos;
import '../../consumers/re_port.dart' show rePort;
import '../../consumers/trigger.dart' show trigger;
import '../../consumers/consumer_resume.dart' show consumerResume;
import '../../consumers/connect_send_transport_audio.dart'
    show connectSendTransportAudio;
import '../../consumers/connect_send_transport_video.dart'
    show connectSendTransportVideo;
import '../../consumers/connect_send_transport_screen.dart'
    show connectSendTransportScreen;
import '../../consumers/process_consumer_transports.dart'
    show processConsumerTransports;
import '../../consumers/resume_pause_streams.dart' show resumePauseStreams;
import '../../consumers/readjust.dart' show readjust;
import '../../consumers/check_grid.dart' show checkGrid;
import '../../consumers/get_estimate.dart' show getEstimate;
import '../../consumers/calculate_rows_and_columns.dart'
    show calculateRowsAndColumns;
import '../../consumers/add_videos_grid.dart' show addVideosGrid;
import '../../consumers/on_screen_changes.dart' show onScreenChanges;
import '../../methods/utils/sleep.dart' show sleep;
import '../../consumers/change_vids.dart' show changeVids;
import '../../consumers/compare_active_names.dart' show compareActiveNames;
import '../../consumers/compare_screen_states.dart' show compareScreenStates;
import '../../consumers/create_send_transport.dart' show createSendTransport;
import '../../consumers/resume_send_transport_audio.dart'
    show resumeSendTransportAudio;
import '../../consumers/receive_all_piped_transports.dart'
    show receiveAllPipedTransports;
import '../../consumers/disconnect_send_transport_video.dart'
    show disconnectSendTransportVideo;
import '../../consumers/disconnect_send_transport_audio.dart'
    show disconnectSendTransportAudio;
import '../../consumers/disconnect_send_transport_screen.dart'
    show disconnectSendTransportScreen;
import '../../consumers/connect_send_transport.dart' show connectSendTransport;
import '../../consumers/get_piped_producers_alt.dart' show getPipedProducersAlt;
import '../../consumers/signal_new_consumer_transport.dart'
    show signalNewConsumerTransport;
import '../../consumers/connect_recv_transport.dart' show connectRecvTransport;
import '../../consumers/re_update_inter.dart' show reUpdateInter;
import '../../consumers/update_participant_audio_decibels.dart'
    show updateParticipantAudioDecibels;
import '../../consumers/close_and_resize.dart' show closeAndResize;
import '../../consumers/auto_adjust.dart' show autoAdjust;
import '../../consumers/switch_user_video_alt.dart' show switchUserVideoAlt;
import '../../consumers/switch_user_video.dart' show switchUserVideo;
import '../../consumers/switch_user_audio.dart' show switchUserAudio;
import '../../consumers/receive_room_messages.dart' show receiveRoomMessages;
import '../../methods/utils/format_number.dart' show formatNumber;
import '../../consumers/connect_ips.dart' show connectIps;

import '../../methods/polls_methods/poll_updated.dart' show pollUpdated;
import '../../methods/polls_methods/handle_create_poll.dart'
    show handleCreatePoll;
import '../../methods/polls_methods/handle_vote_poll.dart' show handleVotePoll;
import '../../methods/polls_methods/handle_end_poll.dart' show handleEndPoll;

import '../../methods/breakout_rooms_methods/breakout_room_updated.dart'
    show breakoutRoomUpdated;

// Mediasfu functions
import '../../methods/utils/meeting_timer/start_meeting_progress_timer.dart'
    show startMeetingProgressTimer;
import '../../methods/recording_methods/update_recording.dart'
    show updateRecording;
import '../../methods/recording_methods/stop_recording.dart' show stopRecording;

import '../../producers/socket_receive_methods/user_waiting.dart'
    show userWaiting;
import '../../producers/socket_receive_methods/person_joined.dart'
    show personJoined;
import '../../producers/socket_receive_methods/all_waiting_room_members.dart'
    show allWaitingRoomMembers;
import '../../producers/socket_receive_methods/room_record_params.dart'
    show roomRecordParams;
import '../../producers/socket_receive_methods/ban_participant.dart'
    show banParticipant;
import '../../producers/socket_receive_methods/updated_co_host.dart'
    show updatedCoHost;
import '../../producers/socket_receive_methods/participant_requested.dart'
    show participantRequested;
import '../../producers/socket_receive_methods/screen_producer_id.dart'
    show screenProducerId;
import '../../producers/socket_receive_methods/update_media_settings.dart'
    show updateMediaSettings;
import '../../producers/socket_receive_methods/producer_media_paused.dart'
    show producerMediaPaused;
import '../../producers/socket_receive_methods/producer_media_resumed.dart'
    show producerMediaResumed;
import '../../producers/socket_receive_methods/producer_media_closed.dart'
    show producerMediaClosed;
import '../../producers/socket_receive_methods/control_media_host.dart'
    show controlMediaHost;
import '../../producers/socket_receive_methods/meeting_ended.dart'
    show meetingEnded;
import '../../producers/socket_receive_methods/disconnect_user_self.dart'
    show disconnectUserSelf;
import '../../producers/socket_receive_methods/receive_message.dart'
    show receiveMessage;
import '../../producers/socket_receive_methods/meeting_time_remaining.dart'
    show meetingTimeRemaining;
import '../../producers/socket_receive_methods/meeting_still_there.dart'
    show meetingStillThere;
import '../../producers/socket_receive_methods/start_records.dart'
    show startRecords;
import '../../producers/socket_receive_methods/re_initiate_recording.dart'
    show reInitiateRecording;
import '../../producers/socket_receive_methods/get_domains.dart'
    show getDomains;
import '../../producers/socket_receive_methods/update_consuming_domains.dart'
    show updateConsumingDomains;
import '../../producers/socket_receive_methods/recording_notice.dart'
    show RecordingNotice;
import '../../producers/socket_receive_methods/time_left_recording.dart'
    show timeLeftRecording;
import '../../producers/socket_receive_methods/stopped_recording.dart'
    show stoppedRecording;
import '../../producers/socket_receive_methods/host_request_response.dart'
    show hostRequestResponse;
import '../../producers/socket_receive_methods/all_members.dart'
    show allMembers;
import '../../producers/socket_receive_methods/all_members_rest.dart'
    show allMembersRest;
import '../../producers/socket_receive_methods/disconnect.dart' show disconnect;

import '../../consumers/resume_pause_audio_streams.dart'
    show resumePauseAudioStreams;
import '../../consumers/process_consumer_transports_audio.dart'
    show processConsumerTransportsAudio;

class MediasfuGeneric extends StatefulWidget {
  final Widget Function({
    required Map<String, dynamic> credentials,
    required Map<String, dynamic> parameters,
  })? PrejoinPage;
  final Map<String, dynamic> credentials;
  final bool useLocalUIMode;
  final Map<String, dynamic> seedData;
  final bool useSeed;

  const MediasfuGeneric({
    super.key,
    this.PrejoinPage,
    this.credentials = const {},
    this.useLocalUIMode = false,
    this.seedData = const {},
    this.useSeed = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MediasfuGenericState createState() => _MediasfuGenericState();
}

class _MediasfuGenericState extends State<MediasfuGeneric> {
  bool validated = false;

  Map<String, dynamic> initialValues = initialValuesState;
  void updateStatesToInitialValues() async {
    // Update states (variables) to initial values

    Map<String, dynamic> updateFunctions = getAllParams();
    for (String key in initialValues.keys) {
      try {
        String updateFunctionName =
            'update${key[0].toUpperCase()}${key.substring(1)}';
        Function updateFunction = updateFunctions[updateFunctionName];

        await updateFunction(initialValues[key]);
      } catch (error) {}
    }
  }

  // Update states (variables) to initial values
  ValueNotifier<io.Socket?> socket =
      ValueNotifier<io.Socket?>(null); // Socket for the media server
  ValueNotifier<dynamic> roomData = ValueNotifier<dynamic>(null);
  ValueNotifier<dynamic> device = ValueNotifier<dynamic>(null);

  ValueNotifier<String> apiKey = ValueNotifier<String>(''); // API key
  ValueNotifier<String> apiUserName = ValueNotifier<String>(''); // API username
  ValueNotifier<String> apiToken = ValueNotifier<String>(''); // API token
  ValueNotifier<String> link =
      ValueNotifier<String>(''); // Link to the media server

  void updateSocket(dynamic value) {
    socket.value = value;
  }

  void updateDevice(dynamic value) {
    device.value = value;
  }

  void updateRoomData(dynamic value) {
    roomData.value = value;
  }

  void updateValidated(bool value) {
    setState(() {
      validated = value;
    });

    if (validated) {
      joinAndUpdate().then((value) => null);
    }
  }

  void updateApiKey(String value) {
    apiKey.value = value;
  }

  void updateApiUserName(String value) {
    apiUserName.value = value;
  }

  void updateApiToken(String value) {
    apiToken.value = value;
  }

  void updateLink(String value) {
    link.value = value;
  }

  Future<dynamic> joinRoom(
      {required io.Socket socket,
      required String roomName,
      required String islevel,
      dynamic member,
      dynamic sec,
      required String apiUserName}) async {
    try {
      // Emit the joinRoom event to the server using the provided socket
      dynamic data = await joinRoomClient(
          socket: socket,
          roomName: roomName,
          islevel: islevel,
          member: member,
          sec: sec,
          apiUserName: apiUserName);
      return data;
    } catch (error) {
      // Handle and log errors during the joinRoom process
      if (kDebugMode) {
        print('Error joining room: $error');
      }

      // throw new Exception('Failed to join the room. Please check your connection and try again.');
      throw 'Failed to join the room. Please check your connection and try again.';
    }
  }

  // Room Details
  final ValueNotifier<String> roomName = ValueNotifier(''); // Room name
  final ValueNotifier<String> member = ValueNotifier(''); // Member name
  final ValueNotifier<String> adminPasscode =
      ValueNotifier(''); // Admin passcode
  final ValueNotifier<String> islevel = ValueNotifier("0"); // Level
  final ValueNotifier<String> coHost = ValueNotifier("No coHost"); // Co-host
  final ValueNotifier<List<dynamic>> coHostResponsibility = ValueNotifier([
    {'name': 'participants', 'value': false, 'dedicated': false},
    {'name': 'media', 'value': false, 'dedicated': false},
    {'name': 'waiting', 'value': false, 'dedicated': false},
    {'name': 'chat', 'value': false, 'dedicated': false},
  ]);
  final ValueNotifier<bool> youAreCoHost = ValueNotifier(false);
  final ValueNotifier<bool> youAreHost = ValueNotifier(false);
  final ValueNotifier<bool> confirmedToRecord = ValueNotifier(false);
  final ValueNotifier<String> meetingDisplayType = ValueNotifier('media');
  final ValueNotifier<bool> meetingVideoOptimized = ValueNotifier(false);
  final ValueNotifier<String> eventType = ValueNotifier('webinar');
  final ValueNotifier<List<dynamic>> participants = ValueNotifier(<dynamic>[]);
  final ValueNotifier<List<dynamic>> filteredParticipants =
      ValueNotifier(<dynamic>[]);
  final ValueNotifier<int> participantsCounter = ValueNotifier(0);
  final ValueNotifier<String> participantsFilter = ValueNotifier('');
  final ValueNotifier<List<Map<String, io.Socket>>> consumeSockets =
      ValueNotifier(<Map<String, io.Socket>>[]);
  final ValueNotifier<dynamic> rtpCapabilities = ValueNotifier(null);
  final ValueNotifier<List<dynamic>> roomRecvIPs = ValueNotifier(<dynamic>[]);
  final ValueNotifier<dynamic> meetingRoomParams = ValueNotifier(null);
  final ValueNotifier<int> itemPageLimit = ValueNotifier(4);
  final ValueNotifier<bool> audioOnlyRoom = ValueNotifier(false);
  final ValueNotifier<bool> addForBasic = ValueNotifier(false);
  final ValueNotifier<int> screenPageLimit = ValueNotifier(4);
  final ValueNotifier<bool> shareScreenStarted = ValueNotifier(false);
  final ValueNotifier<bool> shared = ValueNotifier(false);
  final ValueNotifier<String> targetOrientation = ValueNotifier('landscape');
  final ValueNotifier<Map<String, dynamic>> vidCons =
      ValueNotifier(<String, dynamic>{});
  final ValueNotifier<int> frameRate = ValueNotifier(5);
  final ValueNotifier<dynamic> hParams = ValueNotifier(null);
  final ValueNotifier<dynamic> vParams = ValueNotifier(null);
  final ValueNotifier<dynamic> screenParams = ValueNotifier(null);
  final ValueNotifier<dynamic> aParams = ValueNotifier(null);
  final ValueNotifier<int> recordingAudioPausesLimit = ValueNotifier(0);
  final ValueNotifier<int> recordingAudioPausesCount = ValueNotifier(0);
  final ValueNotifier<bool> recordingAudioSupport = ValueNotifier(false);
  final ValueNotifier<int> recordingAudioPeopleLimit = ValueNotifier(0);
  final ValueNotifier<int> recordingAudioParticipantsTimeLimit =
      ValueNotifier(0);
  final ValueNotifier<int> recordingVideoPausesCount = ValueNotifier(0);
  final ValueNotifier<int> recordingVideoPausesLimit = ValueNotifier(0);
  final ValueNotifier<bool> recordingVideoSupport = ValueNotifier(false);
  final ValueNotifier<int> recordingVideoPeopleLimit = ValueNotifier(0);
  final ValueNotifier<int> recordingVideoParticipantsTimeLimit =
      ValueNotifier(0);
  final ValueNotifier<bool> recordingAllParticipantsSupport =
      ValueNotifier(false);
  final ValueNotifier<bool> recordingVideoParticipantsSupport =
      ValueNotifier(false);
  final ValueNotifier<bool> recordingAllParticipantsFullRoomSupport =
      ValueNotifier(false);
  final ValueNotifier<bool> recordingVideoParticipantsFullRoomSupport =
      ValueNotifier(false);
  final ValueNotifier<String> recordingPreferredOrientation =
      ValueNotifier('landscape');
  final ValueNotifier<bool> recordingSupportForOtherOrientation =
      ValueNotifier(false);
  final ValueNotifier<bool> recordingMultiFormatsSupport = ValueNotifier(false);
  final ValueNotifier<Map<String, dynamic>> userRecordingParams =
      ValueNotifier({
    'mainSpecs': {
      'mediaOptions': 'video',
      'audioOptions': 'all',
      'videoOptions': 'all',
      'videoType': 'fullDisplay',
      'videoOptimized': false,
      'recordingDisplayType': 'media',
      'addHLS': false,
    },
    'dispSpecs': {
      'nameTags': true,
      'backgroundColor': '#000000',
      'nameTagsColor': '#ffffff',
      'orientationVideo': 'portrait',
    },
  });
  final ValueNotifier<bool> canRecord = ValueNotifier(false);
  final ValueNotifier<bool> startReport = ValueNotifier(false);
  final ValueNotifier<bool> endReport = ValueNotifier(false);
  final ValueNotifier<dynamic> recordTimerInterval = ValueNotifier(null);
  final ValueNotifier<dynamic> recordStartTime = ValueNotifier(null);
  final ValueNotifier<int> recordElapsedTime = ValueNotifier(0);
  final ValueNotifier<bool> isTimerRunning = ValueNotifier(false);
  final ValueNotifier<bool> canPauseResume = ValueNotifier(false);
  final ValueNotifier<int> recordChangeSeconds = ValueNotifier(15000);
  final ValueNotifier<int> pauseLimit = ValueNotifier(0);
  final ValueNotifier<int> pauseRecordCount = ValueNotifier(0);
  final ValueNotifier<bool> canLaunchRecord = ValueNotifier(true);
  final ValueNotifier<bool> stopLaunchRecord = ValueNotifier(false);
  final ValueNotifier<List<dynamic>> participantsAll =
      ValueNotifier(<dynamic>[]);

  // Update functions
  void updateMember(String value) {
    member.value = value;
  }

  void updateYouAreCoHost(bool value) {
    setState(() {
      youAreCoHost.value = value;
    });
  }

  void updateYouAreHost(bool value) {
    youAreHost.value = value;
  }

  void updateConfirmedToRecord(bool value) {
    confirmedToRecord.value = value;
  }

  void updateMeetingDisplayType(String value) {
    setState(() {
      meetingDisplayType.value = value;
    });
  }

  void updateMeetingVideoOptimized(bool value) {
    setState(() {
      meetingVideoOptimized.value = value;
    });
  }

  void updateEventType(String value) {
    setState(() {
      eventType.value = value;
    });
    if (value == 'chat') {
      updateMeetingDisplayType('all');
    }
  }

  void updateParticipants(List<dynamic> value) {
    participants.value = value;
    filteredParticipants.value = value;
    participantsCounter.value = value.length;
  }

  void updateFilteredParticipants(List<dynamic> value) {
    filteredParticipants.value = value;
  }

  void updateParticipantsCounter(int value) {
    participantsCounter.value = value;
  }

  void updateParticipantsFilter(String value) {
    participantsFilter.value = value;
  }

  void onParticipantsFilterChange(String value) {
    // Filter the participants list based on the value
    if (value.isNotEmpty) {
      List<dynamic> filteredParts = participants.value.where((participant) {
        return participant['name'].toLowerCase().contains(value.toLowerCase());
      }).toList();
      filteredParticipants.value = filteredParts;
      participantsCounter.value = filteredParts.length;
    } else {
      filteredParticipants.value = participants.value;
      participantsCounter.value = participants.value.length;
    }
  }

  void updateRoomName(String value) {
    roomName.value = value;
  }

  void updateAdminPasscode(String value) {
    adminPasscode.value = value;
  }

  void updateIslevel(String value) {
    setState(() {
      islevel.value = value;
    });
  }

  void updateCoHost(String value) {
    coHost.value = value;
  }

  void updateCoHostResponsibility(List<dynamic> value) {
    coHostResponsibility.value = value;
  }

  void updateRecordingAudioPausesLimit(int value) {
    recordingAudioPausesLimit.value = value;
  }

  void updateRecordingAudioPausesCount(int value) {
    recordingAudioPausesCount.value = value;
  }

  void updateRecordingAudioSupport(bool value) {
    recordingAudioSupport.value = value;
  }

  void updateRecordingAudioPeopleLimit(int value) {
    recordingAudioPeopleLimit.value = value;
  }

  void updateRecordingAudioParticipantsTimeLimit(int value) {
    recordingAudioParticipantsTimeLimit.value = value;
  }

  void updateRecordingVideoPausesCount(int value) {
    recordingVideoPausesCount.value = value;
  }

  void updateRecordingVideoPausesLimit(int value) {
    recordingVideoPausesLimit.value = value;
  }

  void updateRecordingVideoSupport(bool value) {
    recordingVideoSupport.value = value;
  }

  void updateRecordingVideoPeopleLimit(int value) {
    recordingVideoPeopleLimit.value = value;
  }

  void updateRecordingVideoParticipantsTimeLimit(int value) {
    recordingVideoParticipantsTimeLimit.value = value;
  }

  void updateRecordingAllParticipantsSupport(bool value) {
    recordingAllParticipantsSupport.value = value;
  }

  void updateRecordingVideoParticipantsSupport(bool value) {
    recordingVideoParticipantsSupport.value = value;
  }

  void updateRecordingAllParticipantsFullRoomSupport(bool value) {
    recordingAllParticipantsFullRoomSupport.value = value;
  }

  void updateRecordingVideoParticipantsFullRoomSupport(bool value) {
    recordingVideoParticipantsFullRoomSupport.value = value;
  }

  void updateRecordingPreferredOrientation(String value) {
    recordingPreferredOrientation.value = value;
  }

  void updateRecordingSupportForOtherOrientation(bool value) {
    recordingSupportForOtherOrientation.value = value;
  }

  void updateRecordingMultiFormatsSupport(bool value) {
    recordingMultiFormatsSupport.value = value;
  }

  void updateUserRecordingParams(dynamic value) {
    userRecordingParams.value = value;
  }

  void updateCanRecord(bool value) {
    canRecord.value = value;
  }

  void updateStartReport(bool value) {
    startReport.value = value;
  }

  void updateEndReport(bool value) {
    endReport.value = value;
  }

  void updateRecordTimerInterval(dynamic value) {
    recordTimerInterval.value = value;
  }

  void updateRecordStartTime(dynamic value) {
    recordStartTime.value = value;
  }

  void updateRecordElapsedTime(int value) {
    recordElapsedTime.value = value;
  }

  void updateIsTimerRunning(bool value) {
    isTimerRunning.value = value;
  }

  void updateCanPauseResume(bool value) {
    canPauseResume.value = value;
  }

  void updateRecordChangeSeconds(int value) {
    recordChangeSeconds.value = value;
  }

  void updatePauseLimit(int value) {
    pauseLimit.value = value;
  }

  void updatePauseRecordCount(int value) {
    pauseRecordCount.value = value;
  }

  void updateCanLaunchRecord(bool value) {
    canLaunchRecord.value = value;
  }

  void updateStopLaunchRecord(bool value) {
    stopLaunchRecord.value = value;
  }

  void updateParticipantsAll(List<dynamic> value) {
    participantsAll.value = value;
  }

  void updateConsumeSockets(List<Map<String, io.Socket>> value) {
    consumeSockets.value = value;
  }

  void updateRtpCapabilities(dynamic value) {
    rtpCapabilities.value = value;
  }

  void updateRoomRecvIPs(List<dynamic> value) {
    roomRecvIPs.value = value;
  }

  void updateMeetingRoomParams(dynamic value) {
    meetingRoomParams.value = value;
  }

  void updateItemPageLimit(int value) {
    itemPageLimit.value = value;
  }

  void updateAudioOnlyRoom(bool value) {
    audioOnlyRoom.value = value;
  }

  void updateAddForBasic(bool value) {
    addForBasic.value = value;
  }

  void updateScreenPageLimit(int value) {
    screenPageLimit.value = value;
  }

  void updateShareScreenStarted(bool value) {
    shareScreenStarted.value = value;
  }

  void updateShared(bool value) {
    shared.value = value;
  }

  void updateTargetOrientation(String value) {
    targetOrientation.value = value;
  }

  void updateVidCons(Map<String, dynamic> value) {
    vidCons.value = value;
  }

  void updateFrameRate(int value) {
    frameRate.value = value;
  }

  void updateHParams(dynamic value) {
    hParams.value = value;
  }

  void updateVParams(dynamic value) {
    vParams.value = value;
  }

  void updateScreenParams(dynamic value) {
    screenParams.value = value;
  }

  void updateAParams(dynamic value) {
    aParams.value = value;
  }

  final ValueNotifier<bool> firstAll = ValueNotifier(false);
  final ValueNotifier<bool> updateMainWindow = ValueNotifier(false);
  final ValueNotifier<bool> firstRound = ValueNotifier(false);
  final ValueNotifier<bool> landScaped = ValueNotifier(false);
  final ValueNotifier<bool> lockScreen = ValueNotifier(false);
  final ValueNotifier<String> screenId = ValueNotifier('');
  final ValueNotifier<List<dynamic>> allVideoStreams = ValueNotifier([]);
  final ValueNotifier<List<dynamic>> newLimitedStreams = ValueNotifier([]);
  final ValueNotifier<List<dynamic>> newLimitedStreamsIDs = ValueNotifier([]);
  final ValueNotifier<List<dynamic>> activeSounds = ValueNotifier([]);
  final ValueNotifier<String> screenShareIDStream = ValueNotifier('');
  final ValueNotifier<String> screenShareNameStream = ValueNotifier('');
  final ValueNotifier<String> adminIDStream = ValueNotifier('');
  final ValueNotifier<String> adminNameStream = ValueNotifier('');
  final ValueNotifier<dynamic> youYouStream = ValueNotifier(null);
  final ValueNotifier<List<String>> youYouStreamIDs = ValueNotifier([]);
  final ValueNotifier<dynamic> localStream = ValueNotifier(null);
  final ValueNotifier<bool> recordStarted = ValueNotifier(false);
  final ValueNotifier<bool> recordResumed = ValueNotifier(false);
  final ValueNotifier<bool> recordPaused = ValueNotifier(false);
  final ValueNotifier<bool> recordStopped = ValueNotifier(false);
  final ValueNotifier<bool> adminRestrictSetting = ValueNotifier(false);
  final ValueNotifier<String> videoRequestState = ValueNotifier('none');
  final ValueNotifier<DateTime?> videoRequestTime = ValueNotifier(null);
  final ValueNotifier<bool> videoAction = ValueNotifier(false);
  final ValueNotifier<dynamic> localStreamVideo = ValueNotifier(null);
  final ValueNotifier<String> userDefaultVideoInputDevice = ValueNotifier('');
  final ValueNotifier<String> currentFacingMode = ValueNotifier('user');
  final ValueNotifier<String> prevFacingMode = ValueNotifier('user');
  final ValueNotifier<String> defVideoID = ValueNotifier('');
  final ValueNotifier<bool> allowed = ValueNotifier(false);
  final ValueNotifier<List<String>> dispActiveNames = ValueNotifier([]);
  final ValueNotifier<List<String>> pDispActiveNames = ValueNotifier([]);
  final ValueNotifier<List<String>> activeNames = ValueNotifier([]);
  final ValueNotifier<List<String>> prevActiveNames = ValueNotifier([]);
  final ValueNotifier<List<String>> pActiveNames = ValueNotifier([]);
  final ValueNotifier<bool> membersReceived = ValueNotifier(false);
  final ValueNotifier<bool> deferScreenReceived = ValueNotifier(false);
  final ValueNotifier<bool> hostFirstSwitch = ValueNotifier(false);
  final ValueNotifier<bool> micAction = ValueNotifier(false);
  final ValueNotifier<bool> screenAction = ValueNotifier(false);
  final ValueNotifier<bool> chatAction = ValueNotifier(false);
  final ValueNotifier<String> audioRequestState = ValueNotifier('none');
  final ValueNotifier<String> screenRequestState = ValueNotifier('none');
  final ValueNotifier<String> chatRequestState = ValueNotifier('none');
  final ValueNotifier<DateTime?> audioRequestTime = ValueNotifier(null);
  final ValueNotifier<DateTime?> screenRequestTime = ValueNotifier(null);
  final ValueNotifier<DateTime?> chatRequestTime = ValueNotifier(null);
  final ValueNotifier<int> updateRequestIntervalSeconds = ValueNotifier(240);
  final ValueNotifier<List<String>> oldSoundIds = ValueNotifier([]);
  final ValueNotifier<String> hostLabel = ValueNotifier('Host');
  final ValueNotifier<bool> mainScreenFilled = ValueNotifier(false);
  final ValueNotifier<dynamic> localStreamScreen = ValueNotifier(null);
  final ValueNotifier<bool> screenAlreadyOn = ValueNotifier(false);
  final ValueNotifier<bool> chatAlreadyOn = ValueNotifier(false);
  final ValueNotifier<String> redirectURL = ValueNotifier('');
  final ValueNotifier<List<dynamic>> oldAllStreams = ValueNotifier([]);
  final ValueNotifier<String> adminVidID = ValueNotifier('');
  final ValueNotifier<List<dynamic>> streamNames = ValueNotifier([]);
  final ValueNotifier<List<dynamic>> nonAlVideoStreams = ValueNotifier([]);
  final ValueNotifier<bool> sortAudioLoudness = ValueNotifier(false);
  final ValueNotifier<List<dynamic>> audioDecibels = ValueNotifier([]);
  final ValueNotifier<List<dynamic>> mixedAlVideoStreams = ValueNotifier([]);
  final ValueNotifier<List<dynamic>> nonAlVideoStreamsMuted = ValueNotifier([]);
  final ValueNotifier<List<dynamic>> paginatedStreams = ValueNotifier([]);
  final ValueNotifier<dynamic> localStreamAudio = ValueNotifier(null);
  final ValueNotifier<String> defAudioID = ValueNotifier('');
  final ValueNotifier<String> userDefaultAudioInputDevice = ValueNotifier('');
  final ValueNotifier<String> userDefaultAudioOutputDevice = ValueNotifier('');
  final ValueNotifier<String> prevAudioInputDevice = ValueNotifier('');
  final ValueNotifier<String> prevVideoInputDevice = ValueNotifier('');
  final ValueNotifier<bool> audioPaused = ValueNotifier(false);
  final ValueNotifier<String> mainScreenPerson = ValueNotifier('');
  final ValueNotifier<bool> adminOnMainScreen = ValueNotifier(false);
  final ValueNotifier<List<Map<String, dynamic>>> screenStates = ValueNotifier([
    {
      'mainScreenPerson': null,
      'mainScreenProducerId': null,
      'mainScreenFilled': false,
      'adminOnMainScreen': false
    }
  ]);
  final ValueNotifier<List<Map<String, dynamic>>> prevScreenStates =
      ValueNotifier([
    {
      'mainScreenPerson': null,
      'mainScreenProducerId': null,
      'mainScreenFilled': false,
      'adminOnMainScreen': false
    }
  ]);
  final ValueNotifier<dynamic> updateDateState = ValueNotifier(null);
  final ValueNotifier<dynamic> lastUpdate = ValueNotifier(null);
  final ValueNotifier<int> nForReadjustRecord = ValueNotifier(0);
  final ValueNotifier<int> fixedPageLimit = ValueNotifier(4);
  final ValueNotifier<bool> removeAltGrid = ValueNotifier(false);
  final ValueNotifier<int> nForReadjust = ValueNotifier(0);
  final ValueNotifier<int> reOrderInterval = ValueNotifier(30000);
  final ValueNotifier<int> fastReOrderInterval = ValueNotifier(10000);
  final ValueNotifier<int> lastReOrderTime = ValueNotifier(0);
  final ValueNotifier<List<dynamic>> audStreamNames = ValueNotifier([]);
  final ValueNotifier<int> currentUserPage = ValueNotifier(0);
  double mainHeightWidth = 67;
  final ValueNotifier<double> prevMainHeightWidth = ValueNotifier(67);
  final ValueNotifier<bool> prevDoPaginate = ValueNotifier(false);
  final ValueNotifier<bool> doPaginate = ValueNotifier(false);
  final ValueNotifier<bool> shareEnded = ValueNotifier(false);
  final ValueNotifier<List<dynamic>> lStreams = ValueNotifier([]);
  final ValueNotifier<List<dynamic>> chatRefStreams = ValueNotifier([]);
  final ValueNotifier<double> controlHeight = ValueNotifier(0.06);
  // double controlHeight = 0.06;
  final ValueNotifier<bool> isWideScreen = ValueNotifier(false);
  final ValueNotifier<bool> isMediumScreen = ValueNotifier(false);
  final ValueNotifier<bool> isSmallScreen = ValueNotifier(false);
  final ValueNotifier<bool> addGrid = ValueNotifier(false);
  final ValueNotifier<bool> addAltGrid = ValueNotifier(false);
  final ValueNotifier<int> gridRows = ValueNotifier(0);
  final ValueNotifier<int> gridCols = ValueNotifier(0);
  final ValueNotifier<int> altGridRows = ValueNotifier(0);
  final ValueNotifier<int> altGridCols = ValueNotifier(0);
  final ValueNotifier<int> numberPages = ValueNotifier(0);
  final ValueNotifier<List<dynamic>> currentStreams = ValueNotifier([]);
  final ValueNotifier<bool> showMiniView = ValueNotifier(false);
  final ValueNotifier<dynamic> nStream = ValueNotifier(null);
  final ValueNotifier<bool> deferReceive = ValueNotifier(false);
  final ValueNotifier<List<dynamic>> allAudioStreams = ValueNotifier([]);
  final ValueNotifier<List<dynamic>> remoteScreenStream = ValueNotifier([]);
  final ValueNotifier<dynamic> screenProducer = ValueNotifier(null);
  final ValueNotifier<bool> gotAllVids = ValueNotifier(false);
  final ValueNotifier<int> paginationHeightWidth = ValueNotifier(40);
  final ValueNotifier<String> paginationDirection = ValueNotifier('horizontal');
  final ValueNotifier<Map<String, int>> gridSizes = ValueNotifier(
      {'gridWidth': 0, 'gridHeight': 0, 'altGridWidth': 0, 'altGridHeight': 0});
  final ValueNotifier<bool> screenForceFullDisplay = ValueNotifier(false);
  List<Widget> mainGridStream = [];
  List<List<Widget>> otherGridStreams = [[], []];
  final ValueNotifier<List<Widget>> audioOnlyStreams = ValueNotifier([]);
  final ValueNotifier<List<MediaDeviceInfo>> videoInputs = ValueNotifier([]);
  final ValueNotifier<List<MediaDeviceInfo>> audioInputs = ValueNotifier([]);
  final ValueNotifier<String> meetingProgressTime = ValueNotifier('00:00:00');
  final ValueNotifier<int> meetingElapsedTime = ValueNotifier(0);
  final ValueNotifier<List<dynamic>> refParticipants = ValueNotifier([]);

  void updateFirstAll(bool value) {
    firstAll.value = value;
  }

  void updateUpdateMainWindow(bool value) {
    updateMainWindow.value = value;
  }

  void updateFirstRound(bool value) {
    firstRound.value = value;
  }

  void updateLandScaped(bool value) {
    landScaped.value = value;
  }

  void updateLockScreen(bool value) {
    lockScreen.value = value;
  }

  void updateScreenId(String value) {
    screenId.value = value;
  }

  void updateAllVideoStreams(List<dynamic> value) {
    allVideoStreams.value = value;
  }

  void updateNewLimitedStreams(List<dynamic> value) {
    newLimitedStreams.value = value;
  }

  void updateNewLimitedStreamsIDs(List<String> value) {
    newLimitedStreamsIDs.value = value;
  }

  void updateActiveSounds(List<String> value) {
    activeSounds.value = value;
  }

  void updateScreenShareIDStream(String value) {
    screenShareIDStream.value = value;
  }

  void updateScreenShareNameStream(String value) {
    screenShareNameStream.value = value;
  }

  void updateAdminIDStream(String value) {
    adminIDStream.value = value;
  }

  void updateAdminNameStream(String value) {
    adminNameStream.value = value;
  }

  void updateYouYouStream(value) {
    youYouStream.value = value;
  }

  void updateYouYouStreamIDs(List<String> value) {
    youYouStreamIDs.value = value;
  }

  void updateLocalStream(value) {
    localStream.value = value;
  }

  void updateRecordStarted(bool value) {
    setState(() {
      recordStarted.value = value;
    });
  }

  void updateRecordResumed(bool value) {
    setState(() {
      recordResumed.value = value;
    });
  }

  void updateRecordPaused(bool value) {
    setState(() {
      recordPaused.value = value;
    });
  }

  void updateRecordStopped(bool value) {
    setState(() {
      recordStopped.value = value;
    });
  }

  void updateAdminRestrictSetting(bool value) {
    adminRestrictSetting.value = value;
  }

  void updateVideoRequestState(String value) {
    videoRequestState.value = value;
  }

  void updateVideoRequestTime(DateTime value) {
    videoRequestTime.value = value;
  }

  void updateVideoAction(bool value) {
    videoAction.value = value;
  }

  void updateLocalStreamVideo(value) {
    localStreamVideo.value = value;
  }

  void updateUserDefaultVideoInputDevice(String value) {
    userDefaultVideoInputDevice.value = value;
  }

  void updateCurrentFacingMode(String value) {
    currentFacingMode.value = value;
  }

  void updatePrevFacingMode(String value) {
    prevFacingMode.value = value;
  }

  void updateDefVideoID(String value) {
    defVideoID.value = value;
  }

  void updateAllowed(bool value) {
    allowed.value = value;
  }

  void updateDispActiveNames(List<String> value) {
    dispActiveNames.value = value;
  }

  void updatePDispActiveNames(List<String> value) {
    pDispActiveNames.value = value;
  }

  void updateActiveNames(List<String> value) {
    activeNames.value = value;
  }

  void updatePrevActiveNames(List<String> value) {
    prevActiveNames.value = value;
  }

  void updatePActiveNames(List<String> value) {
    pActiveNames.value = value;
  }

  void updateMembersReceived(bool value) {
    membersReceived.value = value;
  }

  void updateDeferScreenReceived(bool value) {
    deferScreenReceived.value = value;
  }

  void updateHostFirstSwitch(bool value) {
    hostFirstSwitch.value = value;
  }

  void updateMicAction(bool value) {
    micAction.value = value;
  }

  void updateScreenAction(bool value) {
    screenAction.value = value;
  }

  void updateChatAction(bool value) {
    chatAction.value = value;
  }

  void updateAudioRequestState(String value) {
    audioRequestState.value = value;
  }

  void updateScreenRequestState(String value) {
    screenRequestState.value = value;
  }

  void updateChatRequestState(String value) {
    chatRequestState.value = value;
  }

  void updateAudioRequestTime(DateTime value) {
    audioRequestTime.value = value;
  }

  void updateScreenRequestTime(DateTime value) {
    screenRequestTime.value = value;
  }

  void updateChatRequestTime(DateTime value) {
    chatRequestTime.value = value;
  }

  void updateOldSoundIds(List<String> value) {
    oldSoundIds.value = value;
  }

  void updateHostLabel(String value) {
    hostLabel.value = value;
  }

  void updateMainScreenFilled(bool value) {
    mainScreenFilled.value = value;
  }

  void updateLocalStreamScreen(value) {
    localStreamScreen.value = value;
  }

  void updateScreenAlreadyOn(bool value) {
    screenAlreadyOn.value = value;
    setState(() {
      screenShareActive = value;
    });
  }

  void updateChatAlreadyOn(bool value) {
    chatAlreadyOn.value = value;
  }

  void updateRedirectURL(value) {
    redirectURL.value = value;
  }

  void updateOldAllStreams(value) {
    oldAllStreams.value = value;
  }

  void updateAdminVidID(String value) {
    adminVidID.value = value;
  }

  void updateStreamNames(List<dynamic> value) {
    streamNames.value = value;
  }

  void updateNonAlVideoStreams(value) {
    nonAlVideoStreams.value = value;
  }

  void updateSortAudioLoudness(bool value) {
    sortAudioLoudness.value = value;
  }

  void updateAudioDecibels(value) {
    audioDecibels.value = value;
  }

  void updateMixedAlVideoStreams(value) {
    mixedAlVideoStreams.value = value;
  }

  void updateNonAlVideoStreamsMuted(value) {
    nonAlVideoStreamsMuted.value = value;
  }

  void updatePaginatedStreams(value) {
    paginatedStreams.value = value;
  }

  void updateLocalStreamAudio(value) {
    localStreamAudio.value = value;
  }

  void updateDefAudioID(String value) {
    defAudioID.value = value;
  }

  void updateUserDefaultAudioInputDevice(String value) {
    userDefaultAudioInputDevice.value = value;
  }

  void updateUserDefaultAudioOutputDevice(String value) {
    userDefaultAudioOutputDevice.value = value;
  }

  void updatePrevAudioInputDevice(String value) {
    prevAudioInputDevice.value = value;
  }

  void updatePrevVideoInputDevice(String value) {
    prevVideoInputDevice.value = value;
  }

  void updateAudioPaused(bool value) {
    audioPaused.value = value;
  }

  void updateMainScreenPerson(String value) {
    mainScreenPerson.value = value;
  }

  void updateAdminOnMainScreen(bool value) {
    adminOnMainScreen.value = value;
  }

  void updateScreenStates(List<Map<String, dynamic>> value) {
    screenStates.value = value;
  }

  void updatePrevScreenStates(List<Map<String, dynamic>> value) {
    prevScreenStates.value = value;
  }

  void updateUpdateDateState(value) {
    updateDateState.value = value;
  }

  void updateLastUpdate(value) {
    lastUpdate.value = value;
  }

  void updateNForReadjustRecord(int value) {
    nForReadjustRecord.value = value;
  }

  void updateFixedPageLimit(int value) {
    fixedPageLimit.value = value;
  }

  void updateRemoveAltGrid(bool value) {
    removeAltGrid.value = value;
  }

  void updateNForReadjust(int value) {
    nForReadjust.value = value;
  }

  void updateLastReOrderTime(int value) {
    lastReOrderTime.value = value;
  }

  void updateAudStreamNames(value) {
    audStreamNames.value = value;
  }

  void updateCurrentUserPage(int value) {
    currentUserPage.value = value;
  }

  void updateMainHeightWidth(value) {
    bool doUpdate = value.floor() != mainHeightWidth.floor();
    setState(() {
      mainHeightWidth = value.toDouble();
    });

    if (doUpdate && validated) {
      try {
        onScreenChanges(
            changed: true,
            parameters: {...getAllParams(), ...mediaSFUFunctions()});
      } catch (error) {}

      try {
        prepopulateUserMedia(
            name: hostLabel.value,
            parameters: {...getAllParams(), ...mediaSFUFunctions()});
      } catch (error) {}
    }
  }

  void updatePrevMainHeightWidth(value) {
    prevMainHeightWidth.value = value;
  }

  void updatePrevDoPaginate(bool value) {
    if (value != prevDoPaginate.value) {
      prevDoPaginate.value = value;
    }
  }

  void updateDoPaginate(bool value) {
    if (value != doPaginate.value) {
      // doPaginate.value = value;
      setState(() {
        doPaginate.value = value;
      });
    }
  }

  void updateShareEnded(bool value) {
    shareEnded.value = value;
  }

  void updateLStreams(value) {
    lStreams.value = value;
  }

  void updateChatRefStreams(value) {
    chatRefStreams.value = value;
  }

  void _updateControlHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((eventType.value == 'webinar' || eventType.value == 'conference')) {
        // Handle landscape orientation for webinar and conference event types
        final minValue = MediaQuery.of(context).size.height;

        // Adaptively set the control height for specific screen sizes
        //compute the fraction that give max of 40px to 3 decimal places
        final fraction = (40 / minValue).toStringAsFixed(3);
        if (controlHeight.value != double.parse(fraction)) {
          updateControlHeight(double.parse(fraction));
        }
      } else {
        if (controlHeight.value != 0.0) {
          updateControlHeight(0.0);
        }
      }
    });
  }

  void updateControlHeight(value) {
    setState(() {
      controlHeight.value = value;
    });
  }

  void updateIsWideScreen(bool value) {
    isWideScreen.value = value;
  }

  void updateIsMediumScreen(bool value) {
    isMediumScreen.value = value;
  }

  void updateIsSmallScreen(bool value) {
    isSmallScreen.value = value;
  }

  void updateAddGrid(bool value) {
    addGrid.value = value;
  }

  void updateAddAltGrid(bool value) {
    addAltGrid.value = value;
  }

  void updateGridRows(int value) {
    gridRows.value = value;
  }

  void updateGridCols(int value) {
    gridCols.value = value;
  }

  void updateAltGridRows(int value) {
    altGridRows.value = value;
  }

  void updateAltGridCols(int value) {
    altGridCols.value = value;
  }

  void updateNumberPages(int value) {
    numberPages.value = value;
  }

  void updateCurrentStreams(value) {
    currentStreams.value = value;
  }

  void updateShowMiniView(bool value) {
    showMiniView.value = value;
  }

  void updateNStream(value) {
    nStream.value = value;
  }

  void updateDeferReceive(bool value) {
    deferReceive.value = value;
  }

  void updateAllAudioStreams(value) {
    allAudioStreams.value = value;
  }

  void updateRemoteScreenStream(value) {
    remoteScreenStream.value = value;
  }

  void updateScreenProducer(value) {
    screenProducer.value = value;
  }

  void updateGotAllVids(bool value) {
    gotAllVids.value = value;
  }

  void updatePaginationHeightWidth(value) {
    setState(() {
      paginationHeightWidth.value = value;
    });
  }

  void updatePaginationDirection(String value) {
    paginationDirection.value = value;
  }

  void updateGridSizes(Map<String, int> value) {
    gridSizes.value = value;
  }

  void updateScreenForceFullDisplay(bool value) {
    screenForceFullDisplay.value = value;
  }

  void updateMainGridStream(value) {
    setState(() {
      mainGridStream = value;
    });
  }

  void updateOtherGridStreams(value) {
    setState(() {
      otherGridStreams = value;
    });
  }

  void updateAudioOnlyStreams(value) {
    audioOnlyStreams.value = value;
  }

  void updateVideoInputs(value) {
    videoInputs.value = value;
  }

  void updateAudioInputs(value) {
    audioInputs.value = value;
  }

  void updateMeetingProgressTime(value) {
    meetingProgressTime.value = value;
  }

  void updateMeetingElapsedTime(value) {
    meetingElapsedTime.value = value;
  }

  void updateRefParticipants(List<dynamic> value) {
    refParticipants.value = value;
  }

  // Messages
  final ValueNotifier<List<dynamic>> messages = ValueNotifier([]);
  final ValueNotifier<bool> startDirectMessage = ValueNotifier(false);
  final ValueNotifier<Map<String, dynamic>> directMessageDetails =
      ValueNotifier({});
  final ValueNotifier<bool> showMessagesBadge = ValueNotifier(false);

  // Event settings related variables
  final ValueNotifier<String> audioSetting = ValueNotifier('allow');
  final ValueNotifier<String> videoSetting = ValueNotifier('allow');
  final ValueNotifier<String> screenshareSetting = ValueNotifier('allow');
  final ValueNotifier<String> chatSetting = ValueNotifier('allow');

  // Display settings related variables
  final ValueNotifier<String> displayOption = ValueNotifier('media');
  final ValueNotifier<bool> autoWave = ValueNotifier(true);
  final ValueNotifier<bool> forceFullDisplay = ValueNotifier(true);
  final ValueNotifier<bool> prevForceFullDisplay = ValueNotifier(false);
  final ValueNotifier<String> prevMeetingDisplayType = ValueNotifier('video');

  // Waiting room
  final ValueNotifier<String> waitingRoomFilter = ValueNotifier('');
  final ValueNotifier<List<dynamic>> waitingRoomList = ValueNotifier([]);
  final ValueNotifier<int> waitingRoomCounter = ValueNotifier(0);
  final ValueNotifier<List<dynamic>> filteredWaitingRoomList =
      ValueNotifier([]);

  // Requests
  final ValueNotifier<String> requestFilter = ValueNotifier('');
  final ValueNotifier<List<dynamic>> requestList = ValueNotifier([]);
  final ValueNotifier<int> requestCounter = ValueNotifier(0);
  final ValueNotifier<List<dynamic>> filteredRequestList = ValueNotifier([]);

  // Update methods
  void updateMessages(List<dynamic> value) {
    messages.value = value;
  }

  void updateStartDirectMessage(bool value) {
    startDirectMessage.value = value;
  }

  void updateDirectMessageDetails(Map<String, dynamic> value) {
    directMessageDetails.value = value;
  }

  void updateShowMessagesBadge(bool value) {
    setState(() {
      showMessagesBadge.value = value;
    });
  }

  void updateAudioSetting(String value) {
    audioSetting.value = value;
  }

  void updateVideoSetting(String value) {
    videoSetting.value = value;
  }

  void updateScreenshareSetting(String value) {
    screenshareSetting.value = value;
  }

  void updateChatSetting(String value) {
    chatSetting.value = value;
  }

  void updateDisplayOption(String value) {
    displayOption.value = value;
  }

  void updateAutoWave(bool value) {
    autoWave.value = value;
  }

  void updateForceFullDisplay(bool value) {
    forceFullDisplay.value = value;
  }

  void updatePrevForceFullDisplay(bool value) {
    prevForceFullDisplay.value = value;
  }

  void updatePrevMeetingDisplayType(String value) {
    prevMeetingDisplayType.value = value;
  }

  void updateWaitingRoomFilter(String value) {
    waitingRoomFilter.value = value;
  }

  void updateWaitingRoomList(List<dynamic> value) {
    waitingRoomList.value = value;
    filteredWaitingRoomList.value = value;
    waitingRoomCounter.value = value.length;
  }

  void updateWaitingRoomCounter(int value) {
    waitingRoomCounter.value = value;
  }

  void updateRequestFilter(String value) {
    requestFilter.value = value;
  }

  void updateRequestList(List<dynamic> value) {
    requestList.value = value;
    filteredRequestList.value = value;
    requestCounter.value = value.length;
  }

  void updateRequestCounter(int value) {
    requestCounter.value = value;
  }

  void onWaitingRoomFilterChange(String value) {
    // Filter the waiting room list based on the value
    if (value.isNotEmpty) {
      final filteredList = waitingRoomList.value.where((room) =>
          room['name'].toString().toLowerCase().contains(value.toLowerCase()));
      filteredWaitingRoomList.value = filteredList.toList();
      waitingRoomCounter.value = filteredList.length;
    } else {
      filteredWaitingRoomList.value = waitingRoomList.value;
      waitingRoomCounter.value = waitingRoomList.value.length;
    }
  }

  void onRequestFilterChange(String value) {
    // Filter the request list based on the value
    if (value.isNotEmpty) {
      final filteredList = requestList.value.where((request) => request['name']
          .toString()
          .toLowerCase()
          .contains(value.toLowerCase()));
      filteredRequestList.value = filteredList.toList();
      requestCounter.value = filteredList.length;
    } else {
      filteredRequestList.value = requestList.value;
      requestCounter.value = requestList.value.length;
    }
  }

  // showAlert modal
  final ValueNotifier<bool> alertVisible = ValueNotifier(false);
  final ValueNotifier<String> alertMessage = ValueNotifier('');
  final ValueNotifier<String> alertType = ValueNotifier('info');
  final ValueNotifier<int> alertDuration = ValueNotifier(3000);

  void updateAlertVisible(bool value) {
    alertVisible.value = value;
  }

  void updateAlertMessage(String value) {
    alertMessage.value = value;
  }

  void updateAlertType(String value) {
    alertType.value = value;
  }

  void updateAlertDuration(int value) {
    alertDuration.value = value;
  }

  // Progress Timer
  final ValueNotifier<bool> progressTimerVisible = ValueNotifier(true);
  final ValueNotifier<int> progressTimerValue = ValueNotifier(0);

  void updateProgressTimerVisible(bool value) {
    progressTimerVisible.value = value;
  }

  void updateProgressTimerValue(int value) {
    progressTimerValue.value = value;
  }

  // Menu modals
  final ValueNotifier<bool> isMenuModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isRecordingModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isSettingsModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isRequestsModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isWaitingModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isCoHostModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isMediaSettingsModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isDisplaySettingsModalVisible =
      ValueNotifier(false);

  // onRequestClose method
  void onRequestClose() {
    updateIsRequestsModalVisible(false);
  }

  // totalReqWait variable and update method
  final ValueNotifier<int> totalReqWait = ValueNotifier(0);

  void updateTotalReqWait(int value) {
    setState(() {
      totalReqWait.value = value;
    });
  }

  // Update methods for menu modals
  void updateIsMenuModalVisible(bool value) {
    isMenuModalVisible.value = value;
  }

  void updateIsRecordingModalVisible(bool value) {
    isRecordingModalVisible.value = value;
    if (value) {
      updateConfirmedToRecord(false);
    } else {
      if (clearedToRecord.value == true &&
          clearedToResume.value == true &&
          recordStarted.value == true) {
        updateShowRecordButtons(true);
      }
    }
  }

  void updateIsSettingsModalVisible(bool value) {
    isSettingsModalVisible.value = value;
  }

  void updateIsRequestsModalVisible(bool value) {
    isRequestsModalVisible.value = value;
  }

  void updateIsWaitingModalVisible(bool value) {
    isWaitingModalVisible.value = value;
  }

  void updateIsCoHostModalVisible(bool value) {
    isCoHostModalVisible.value = value;
  }

  void updateIsMediaSettingsModalVisible(bool value) {
    isMediaSettingsModalVisible.value = value;
  }

  void updateIsDisplaySettingsModalVisible(bool value) {
    isDisplaySettingsModalVisible.value = value;
  }

  // Other Modals
  final ValueNotifier<bool> isParticipantsModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isMessagesModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isConfirmExitModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isConfirmHereModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isShareEventModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isLoadingModalVisible = ValueNotifier(false);

  void updateIsParticipantsModalVisible(bool value) {
    isParticipantsModalVisible.value = value;
  }

  void updateIsMessagesModalVisible(bool value) {
    isMessagesModalVisible.value = value;
  }

  void updateIsConfirmExitModalVisible(bool value) {
    isConfirmExitModalVisible.value = value;
  }

  void updateIsConfirmHereModalVisible(bool value) {
    isConfirmHereModalVisible.value = value;
  }

  void updateIsShareEventModalVisible(bool value) {
    isShareEventModalVisible.value = value;
  }

  void updateIsLoadingModalVisible(bool value) {
    isLoadingModalVisible.value = value;
  }

  // Recording related variables
  final ValueNotifier<String> recordingMediaOptions = ValueNotifier('video');
  final ValueNotifier<String> recordingAudioOptions = ValueNotifier('all');
  final ValueNotifier<String> recordingVideoOptions = ValueNotifier('all');
  final ValueNotifier<String> recordingVideoType = ValueNotifier('fullDisplay');
  final ValueNotifier<bool> recordingVideoOptimized = ValueNotifier(false);
  final ValueNotifier<String> recordingDisplayType = ValueNotifier('media');
  final ValueNotifier<bool> recordingAddHLS = ValueNotifier(true);
  final ValueNotifier<bool> recordingNameTags = ValueNotifier(true);
  final ValueNotifier<String> recordingBackgroundColor =
      ValueNotifier('#83c0e9');
  final ValueNotifier<String> recordingNameTagsColor = ValueNotifier('#ffffff');
  final ValueNotifier<bool> recordingAddText = ValueNotifier(false);
  final ValueNotifier<String> recordingCustomText = ValueNotifier('Add Text');
  final ValueNotifier<String> recordingCustomTextPosition =
      ValueNotifier('top');
  final ValueNotifier<String> recordingCustomTextColor =
      ValueNotifier('#ffffff');
  final ValueNotifier<String> recordingOrientationVideo =
      ValueNotifier('landscape');
  final ValueNotifier<bool> clearedToResume = ValueNotifier(true);
  final ValueNotifier<bool> clearedToRecord = ValueNotifier(true);
  // final ValueNotifier<String> recordState = ValueNotifier('green');
  String recordState = 'green';
  final ValueNotifier<bool> showRecordButtons = ValueNotifier(false);
  final ValueNotifier<String> recordingProgressTime = ValueNotifier('00:00:00');
  final ValueNotifier<bool> audioSwitching = ValueNotifier(false);
  final ValueNotifier<bool> videoSwitching = ValueNotifier(false);

  // Update methods for recording options
  final ValueNotifier<bool> recordUIChanged = ValueNotifier(false);

  void updateRecordingMediaOptions(String value) {
    recordingMediaOptions.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingAudioOptions(String value) {
    recordingAudioOptions.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingVideoOptions(String value) {
    recordingVideoOptions.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingVideoType(String value) {
    recordingVideoType.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingVideoOptimized(bool value) {
    recordingVideoOptimized.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingDisplayType(String value) {
    recordingDisplayType.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingAddHLS(bool value) {
    recordingAddHLS.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingNameTags(bool value) {
    recordingNameTags.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingBackgroundColor(String value) {
    recordingBackgroundColor.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingNameTagsColor(String value) {
    recordingNameTagsColor.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingAddText(bool value) {
    recordingAddText.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingCustomText(String value) {
    recordingCustomText.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingCustomTextPosition(String value) {
    recordingCustomTextPosition.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingCustomTextColor(String value) {
    recordingCustomTextColor.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingOrientationVideo(String value) {
    recordingOrientationVideo.value = value;
    clearedToRecord.value = false;
    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateClearedToResume(bool value) {
    clearedToResume.value = value;
  }

  void updateClearedToRecord(bool value) {
    clearedToRecord.value = value;
  }

  void _updateRecordState() {
    if (recordStarted.value && !recordStopped.value) {
      if (!recordPaused.value) {
        setState(() {
          recordState = 'red';
        });
      } else {
        setState(() {
          recordState = 'yellow';
        });
      }
    } else {
      setState(() {
        recordState = 'green';
      });
    }
  }

  void updateRecordState(String value) {
    recordState = value;
    _updateRecordState();
  }

  void updateShowRecordButtons(bool value) {
    setState(() {
      showRecordButtons.value = value;
    });
  }

  void updateRecordingProgressTime(String value) {
    setState(() {
      recordingProgressTime.value = value;
    });
  }

  void updateAudioSwitching(bool value) {
    audioSwitching.value = value;
  }

  void updateVideoSwitching(bool value) {
    videoSwitching.value = value;
  }

  // Media related variables
  final ValueNotifier<bool> videoAlreadyOn = ValueNotifier(false);
  final ValueNotifier<bool> audioAlreadyOn = ValueNotifier(false);

  final ValueNotifier<Map<String, double>> componentSizes = ValueNotifier({
    'mainHeight': 0,
    'otherHeight': 0,
    'mainWidth': 0,
    'otherWidth': 0,
  });

  void updateVideoAlreadyOn(bool value) {
    videoAlreadyOn.value = value;

    setState(() {
      videoActive = value;
    });
  }

  void updateAudioAlreadyOn(bool value) {
    audioAlreadyOn.value = value;

    setState(() {
      micActive = value;
    });
  }

  void updateComponentSizes(Map<String, double> sizes) {
    // Check if the component sizes have changed
    final doUpdate =
        sizes['mainHeight'] != componentSizes.value['mainHeight'] ||
            sizes['otherHeight'] != componentSizes.value['otherHeight'] ||
            sizes['mainWidth'] != componentSizes.value['mainWidth'] ||
            sizes['otherWidth'] != componentSizes.value['otherWidth'];

    if (doUpdate && validated) {
      componentSizes.value = sizes;
      try {
        _updateControlHeight();
      } catch (error) {}

      try {
        onScreenChanges(
            changed: true,
            parameters: {...getAllParams(), ...mediaSFUFunctions()});
      } catch (error) {}

      try {
        prepopulateUserMedia(
            name: hostLabel.value,
            parameters: {...getAllParams(), ...mediaSFUFunctions()});
      } catch (error) {}
    }
  }

  // Permissions related variables
  final ValueNotifier<bool> hasCameraPermission = ValueNotifier(false);
  final ValueNotifier<bool> hasAudioPermission = ValueNotifier(false);

  void updateHasCameraPermission(bool value) {
    hasCameraPermission.value = value;
  }

  void updateHasAudioPermission(bool value) {
    hasAudioPermission.value = value;
  }

  Future<bool> requestPermissionCamera() async {
    return true;
    // final status = await Permission.camera.request();
    // if (status == PermissionStatus.granted) {
    //   hasCameraPermission.value = true;
    //   return true;
    // } else {
    //   return false;
    // }
  }

  Future<bool> requestPermissionAudio() async {
    return true;
    // final status = await Permission.microphone.request();
    // if (status == PermissionStatus.granted) {
    //   hasAudioPermission.value = true;
    //   return true;
    // } else {
    //   return false;
    // }
  }

  //transports related variables
  final ValueNotifier<bool> transportCreated = ValueNotifier(false);
  final ValueNotifier<bool> transportCreatedVideo = ValueNotifier(false);
  final ValueNotifier<bool> transportCreatedAudio = ValueNotifier(false);
  final ValueNotifier<bool> transportCreatedScreen = ValueNotifier(false);
  final ValueNotifier<dynamic> producerTransport = ValueNotifier(null);
  final ValueNotifier<dynamic> videoProducer = ValueNotifier(null);
  final ValueNotifier<dynamic> params = ValueNotifier(null);
  final ValueNotifier<dynamic> videoParams = ValueNotifier(null);
  final ValueNotifier<dynamic> audioParams = ValueNotifier(null);
  final ValueNotifier<dynamic> audioProducer = ValueNotifier(null);
  final ValueNotifier<List<dynamic>> consumerTransports = ValueNotifier([]);
  final ValueNotifier<List<dynamic>> consumingTransports = ValueNotifier([]);

  final ValueNotifier<List<dynamic>> polls = ValueNotifier([]);
  final ValueNotifier<Map<String, dynamic>?> poll = ValueNotifier(null);
  final ValueNotifier<bool> isPollModalVisible = ValueNotifier(false);

  // Update functions
  void updateTransportCreated(bool value) {
    transportCreated.value = value;
  }

  void updateTransportCreatedVideo(bool value) {
    transportCreatedVideo.value = value;
  }

  void updateTransportCreatedAudio(bool value) {
    transportCreatedAudio.value = value;
  }

  void updateTransportCreatedScreen(bool value) {
    transportCreatedScreen.value = value;
  }

  void updateProducerTransport(dynamic value) {
    producerTransport.value = value;
  }

  void updateVideoProducer(dynamic value) {
    videoProducer.value = value;
  }

  void updateParams(dynamic value) {
    params.value = value;
  }

  void updateVideoParams(dynamic value) {
    videoParams.value = value;
  }

  void updateAudioParams(dynamic value) {
    audioParams.value = value;
  }

  void updateAudioProducer(dynamic value) {
    audioProducer.value = value;
  }

  void updateConsumerTransports(List<dynamic> value) {
    consumerTransports.value = value;
  }

  void updateConsumingTransports(List<dynamic> value) {
    consumingTransports.value = value;
  }

  void updatePolls(List<dynamic> value) {
    polls.value = value;
  }

  void updatePoll(Map<String, dynamic>? value) {
    poll.value = value;
  }

  void updateIsPollModalVisible(bool value) {
    isPollModalVisible.value = value;
  }

// Breakout rooms related variables
  final ValueNotifier<List<dynamic>> breakoutRooms = ValueNotifier([]);
  final ValueNotifier<int> currentRoomIndex = ValueNotifier(0);
  final ValueNotifier<bool> canStartBreakout = ValueNotifier(false);
  final ValueNotifier<bool> breakOutRoomStarted = ValueNotifier(false);
  final ValueNotifier<bool> breakOutRoomEnded = ValueNotifier(false);
  final ValueNotifier<int> hostNewRoom = ValueNotifier(-1);
  final ValueNotifier<List<dynamic>> limitedBreakRoom = ValueNotifier([]);
  final ValueNotifier<int> mainRoomsLength = ValueNotifier(0);
  final ValueNotifier<int> memberRoom = ValueNotifier(-1);
  final ValueNotifier<bool> isBreakoutRoomsModalVisible = ValueNotifier(false);

  void updateBreakoutRooms(List<dynamic> value) {
    breakoutRooms.value = value;
  }

  void updateCurrentRoomIndex(int value) {
    currentRoomIndex.value = value;
  }

  void updateCanStartBreakout(bool value) {
    canStartBreakout.value = value;
  }

  void updateBreakOutRoomStarted(bool value) {
    breakOutRoomStarted.value = value;
  }

  void updateBreakOutRoomEnded(bool value) {
    breakOutRoomEnded.value = value;
  }

  void updateHostNewRoom(int value) {
    hostNewRoom.value = value;
  }

  void updateLimitedBreakRoom(List<dynamic> value) {
    limitedBreakRoom.value = value;
  }

  void updateMainRoomsLength(int value) {
    mainRoomsLength.value = value;
  }

  void updateMemberRoom(int value) {
    memberRoom.value = value;
  }

  void updateIsBreakoutRoomsModalVisible(bool value) {
    isBreakoutRoomsModalVisible.value = value;
  }

  String checkOrientation() {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? 'portrait'
        : 'landscape';
  }

  final ValueNotifier<bool> isPortrait = ValueNotifier<bool>(true);

  Map<String, dynamic> getUpdatedAllParams() {
    return {
      ...getAllParams(),
      ...mediaSFUFunctions(),
    };
  }

  Map<String, dynamic> mediaSFUFunctions() {
    return {
      'updateMiniCardsGrid': updateMiniCardsGrid,
      'mixStreams': mixStreams,
      'dispStreams': dispStreams,
      'stopShareScreen': stopShareScreen,
      'checkScreenShare': checkScreenShare,
      'startShareScreen': startShareScreen,
      'requestScreenShare': requestScreenShare,
      'reorderStreams': reorderStreams,
      'prepopulateUserMedia': prepopulateUserMedia,
      'getVideos': getVideos,
      'rePort': rePort,
      'trigger': trigger,
      'consumerResume': consumerResume,
      'connectSendTransport': connectSendTransport,
      'connectSendTransportAudio': connectSendTransportAudio,
      'connectSendTransportVideo': connectSendTransportVideo,
      'connectSendTransportScreen': connectSendTransportScreen,
      'processConsumerTransports': processConsumerTransports,
      'resumePauseStreams': resumePauseStreams,
      'readjust': readjust,
      'checkGrid': checkGrid,
      'getEstimate': getEstimate,
      'calculateRowsAndColumns': calculateRowsAndColumns,
      'addVideosGrid': addVideosGrid,
      'onScreenChanges': onScreenChanges,
      'sleep': sleep,
      'changeVids': changeVids,
      'compareActiveNames': compareActiveNames,
      'compareScreenStates': compareScreenStates,
      'createSendTransport': createSendTransport,
      'resumeSendTransportAudio': resumeSendTransportAudio,
      'receiveAllPipedTransports': receiveAllPipedTransports,
      'disconnectSendTransportVideo': disconnectSendTransportVideo,
      'disconnectSendTransportAudio': disconnectSendTransportAudio,
      'disconnectSendTransportScreen': disconnectSendTransportScreen,
      'getPipedProducersAlt': getPipedProducersAlt,
      'signalNewConsumerTransport': signalNewConsumerTransport,
      'connectRecvTransport': connectRecvTransport,
      'reUpdateInter': reUpdateInter,
      'updateParticipantAudioDecibels': updateParticipantAudioDecibels,
      'closeAndResize': closeAndResize,
      'autoAdjust': autoAdjust,
      'switchUserVideoAlt': switchUserVideoAlt,
      'switchUserVideo': switchUserVideo,
      'switchUserAudio': switchUserAudio,
      'getDomains': getDomains,
      'formatNumber': formatNumber,
      'connectIps': connectIps,
      'createDeviceClient': createDeviceClient,
      'handleCreatePoll': handleCreatePoll,
      'handleVotePoll': handleVotePoll,
      'handleEndPoll': handleEndPoll,
      'resumePauseAudioStreams': resumePauseAudioStreams,
      'processConsumerTransportsAudio': processConsumerTransportsAudio,
    };
  }

  Map<String, dynamic> getAllParams() {
    return {
      'localUIMode': widget.useSeed,

      // Room Details
      'roomName': roomName.value,
      'member': member.value,
      'adminPasscode': adminPasscode.value,
      'youAreCoHost': youAreCoHost.value,
      'youAreHost': youAreHost.value,
      'islevel': islevel.value,
      'confirmedToRecord': confirmedToRecord.value,
      'meetingDisplayType': meetingDisplayType.value,
      'meetingVideoOptimized': meetingVideoOptimized.value,
      'eventType': eventType.value,
      'participants': participants.value,
      'filteredParticipants': filteredParticipants.value,
      'participantsCounter': participantsCounter.value,
      'participantsFilter': participantsFilter.value,

      // More room details - media
      'consumeSockets': consumeSockets.value,
      'rtpCapabilities': rtpCapabilities.value,
      'roomRecvIPs': roomRecvIPs.value,
      'meetingRoomParams': meetingRoomParams.value,
      'itemPageLimit': itemPageLimit.value,
      'audioOnlyRoom': audioOnlyRoom.value,
      'addForBasic': addForBasic.value,
      'screenPageLimit': screenPageLimit.value,
      'shareScreenStarted': shareScreenStarted.value,
      'shared': shared.value,
      'targetOrientation': targetOrientation.value,
      'vidCons': vidCons.value,
      'frameRate': frameRate.value,
      'hParams': hParams.value,
      'vParams': vParams.value,
      'screenParams': screenParams.value,
      'aParams': aParams.value,

      // More room details - recording
      'recordingAudioPausesLimit': recordingAudioPausesLimit.value,
      'recordingAudioPausesCount': recordingAudioPausesCount.value,
      'recordingAudioSupport': recordingAudioSupport.value,
      'recordingAudioPeopleLimit': recordingAudioPeopleLimit.value,
      'recordingAudioParticipantsTimeLimit':
          recordingAudioParticipantsTimeLimit.value,
      'recordingVideoPausesCount': recordingVideoPausesCount.value,
      'recordingVideoPausesLimit': recordingVideoPausesLimit.value,
      'recordingVideoSupport': recordingVideoSupport.value,
      'recordingVideoPeopleLimit': recordingVideoPeopleLimit.value,
      'recordingVideoParticipantsTimeLimit':
          recordingVideoParticipantsTimeLimit.value,
      'recordingAllParticipantsSupport': recordingAllParticipantsSupport.value,
      'recordingVideoParticipantsSupport':
          recordingVideoParticipantsSupport.value,
      'recordingAllParticipantsFullRoomSupport':
          recordingAllParticipantsFullRoomSupport.value,
      'recordingVideoParticipantsFullRoomSupport':
          recordingVideoParticipantsFullRoomSupport.value,
      'recordingPreferredOrientation': recordingPreferredOrientation.value,
      'recordingSupportForOtherOrientation':
          recordingSupportForOtherOrientation.value,
      'recordingMultiFormatsSupport': recordingMultiFormatsSupport.value,
      'userRecordingParams': userRecordingParams.value,
      'canRecord': canRecord.value,
      'startReport': startReport.value,
      'endReport': endReport.value,
      'recordStartTime': recordStartTime.value,
      'recordElapsedTime': recordElapsedTime.value,
      'isTimerRunning': isTimerRunning.value,
      'canPauseResume': canPauseResume.value,
      'recordChangeSeconds': recordChangeSeconds.value,
      'pauseLimit': pauseLimit.value,
      'pauseRecordCount': pauseRecordCount.value,
      'canLaunchRecord': canLaunchRecord.value,
      'stopLaunchRecord': stopLaunchRecord.value,
      'participantsAll': participantsAll.value,
      'firstAll': firstAll.value,
      'updateMainWindow': updateMainWindow.value,
      'firstRound': firstRound.value,
      'landScaped': landScaped.value,
      'lockScreen': lockScreen.value,
      'screenId': screenId.value,
      'allVideoStreams': allVideoStreams.value,
      'newLimitedStreams': newLimitedStreams.value,
      'newLimitedStreamsIDs': newLimitedStreamsIDs.value,
      'activeSounds': activeSounds.value,
      'screenShareIDStream': screenShareIDStream.value,
      'screenShareNameStream': screenShareNameStream.value,
      'adminIDStream': adminIDStream.value,
      'adminNameStream': adminNameStream.value,
      'youYouStream': youYouStream.value,
      'youYouStreamIDs': youYouStreamIDs.value,
      'localStream': localStream.value,
      'recordStarted': recordStarted.value,
      'recordResumed': recordResumed.value,
      'recordPaused': recordPaused.value,
      'recordStopped': recordStopped.value,
      'adminRestrictSetting': adminRestrictSetting.value,
      'videoRequestState': videoRequestState.value,
      'videoRequestTime': videoRequestTime.value,
      'videoAction': videoAction.value,
      'localStreamVideo': localStreamVideo.value,
      'userDefaultVideoInputDevice': userDefaultVideoInputDevice.value,
      'currentFacingMode': currentFacingMode.value,
      'prevFacingMode': prevFacingMode.value,
      'defVideoID': defVideoID.value,
      'allowed': allowed.value,
      'dispActiveNames': dispActiveNames.value,
      'pDispActiveNames': pDispActiveNames.value,
      'activeNames': activeNames.value,
      'prevActiveNames': prevActiveNames.value,
      'pActiveNames': pActiveNames.value,
      'membersReceived': membersReceived.value,
      'deferScreenReceived': deferScreenReceived.value,
      'hostFirstSwitch': hostFirstSwitch.value,
      'micAction': micAction.value,
      'screenAction': screenAction.value,
      'chatAction': chatAction.value,
      'audioRequestState': audioRequestState.value,
      'screenRequestState': screenRequestState.value,
      'chatRequestState': chatRequestState.value,
      'audioRequestTime': audioRequestTime.value,
      'screenRequestTime': screenRequestTime.value,
      'chatRequestTime': chatRequestTime.value,
      'updateRequestIntervalSeconds': updateRequestIntervalSeconds.value,
      'oldSoundIds': oldSoundIds.value,
      'hostLabel': hostLabel.value,
      'mainScreenFilled': mainScreenFilled.value,
      'localStreamScreen': localStreamScreen.value,
      'screenAlreadyOn': screenAlreadyOn.value,
      'chatAlreadyOn': chatAlreadyOn.value,
      'redirectURL': redirectURL.value,
      'oldAllStreams': oldAllStreams.value,
      'adminVidID': adminVidID.value,
      'streamNames': streamNames.value,
      'nonAlVideoStreams': nonAlVideoStreams.value,
      'sortAudioLoudness': sortAudioLoudness.value,
      'audioDecibels': audioDecibels.value,
      'mixedAlVideoStreams': mixedAlVideoStreams.value,
      'nonAlVideoStreamsMuted': nonAlVideoStreamsMuted.value,
      'paginatedStreams': paginatedStreams.value,
      'localStreamAudio': localStreamAudio.value,
      'defAudioID': defAudioID.value,
      'userDefaultAudioInputDevice': userDefaultAudioInputDevice.value,
      'userDefaultAudioOutputDevice': userDefaultAudioOutputDevice.value,
      'prevAudioInputDevice': prevAudioInputDevice.value,
      'prevVideoInputDevice': prevVideoInputDevice.value,
      'audioPaused': audioPaused.value,
      'mainScreenPerson': mainScreenPerson.value,
      'adminOnMainScreen': adminOnMainScreen.value,
      'screenStates': screenStates.value,
      'prevScreenStates': prevScreenStates.value,
      'updateDateState': updateDateState.value,
      'lastUpdate': lastUpdate.value,
      'nForReadjustRecord': nForReadjustRecord.value,
      'fixedPageLimit': fixedPageLimit.value,
      'removeAltGrid': removeAltGrid.value,
      'nForReadjust': nForReadjust.value,
      'lastReOrderTime': lastReOrderTime.value,
      'reOrderInterval': reOrderInterval.value,
      'fastReOrderInterval': fastReOrderInterval.value,
      'audStreamNames': audStreamNames.value,
      'currentUserPage': currentUserPage.value,
      'mainHeightWidth': mainHeightWidth,
      'prevMainHeightWidth': prevMainHeightWidth.value,
      'prevDoPaginate': prevDoPaginate.value,
      'doPaginate': doPaginate.value,
      'shareEnded': shareEnded.value,
      'lStreams': lStreams.value,
      'chatRefStreams': chatRefStreams.value,
      'controlHeight': controlHeight.value,
      'isWideScreen': isWideScreen.value,
      'isMediumScreen': isMediumScreen.value,
      'isSmallScreen': isSmallScreen.value,
      'addGrid': addGrid.value,
      'addAltGrid': addAltGrid.value,
      'gridRows': gridRows.value,
      'gridCols': gridCols.value,
      'altGridRows': altGridRows.value,
      'altGridCols': altGridCols.value,
      'numberPages': numberPages.value,
      'currentStreams': currentStreams.value,
      'showMiniView': showMiniView.value,
      'nStream': nStream.value,
      'deferReceive': deferReceive.value,
      'allAudioStreams': allAudioStreams.value,
      'screenProducer': screenProducer.value,
      'remoteScreenStream': remoteScreenStream.value,
      'gotAllVids': gotAllVids.value,
      'paginationHeightWidth': paginationHeightWidth.value,
      'paginationDirection': paginationDirection.value,
      'gridSizes': gridSizes.value,
      'screenForceFullDisplay': screenForceFullDisplay.value,
      'mainGridStream': mainGridStream,
      'otherGridStreams': otherGridStreams,
      'audioOnlyStreams': audioOnlyStreams.value,
      'videoInputs': videoInputs.value,
      'audioInputs': audioInputs.value,
      'meetingProgressTime': meetingProgressTime.value,
      'meetingElapsedTime': meetingElapsedTime.value,
      'refParticipants': refParticipants.value,

      'messages': messages.value,
      'startDirectMessage': startDirectMessage.value,
      'directMessageDetails': directMessageDetails.value,
      'coHost': coHost.value,
      'coHostResponsibility': coHostResponsibility.value,
      'audioSetting': audioSetting.value,
      'videoSetting': videoSetting.value,
      'screenshareSetting': screenshareSetting.value,
      'chatSetting': chatSetting.value,
      'autoWave': autoWave.value,
      'forceFullDisplay': forceFullDisplay.value,
      'prevForceFullDisplay': prevForceFullDisplay.value,
      'prevMeetingDisplayType': prevMeetingDisplayType.value,
      'waitingRoomFilter': waitingRoomFilter.value,
      'waitingRoomList': waitingRoomList.value,
      'waitingRoomCounter': waitingRoomCounter.value,
      'filteredWaitingRoomList': filteredWaitingRoomList.value,
      'requestFilter': requestFilter.value,
      'requestList': requestList.value,
      'requestCounter': requestCounter.value,
      'filteredRequestList': filteredRequestList.value,
      'totalReqWait': totalReqWait.value,
      'alertVisible': alertVisible.value,
      'alertMessage': alertMessage.value,
      'alertType': alertType.value,
      'alertDuration': alertDuration.value,
      'progressTimerVisible': progressTimerVisible.value,
      'progressTimerValue': progressTimerValue.value,
      'isMenuModalVisible': isMenuModalVisible.value,
      'isRecordingModalVisible': isRecordingModalVisible.value,
      'isSettingsModalVisible': isSettingsModalVisible.value,
      'isRequestsModalVisible': isRequestsModalVisible.value,
      'isWaitingModalVisible': isWaitingModalVisible.value,
      'isCoHostModalVisible': isCoHostModalVisible.value,
      'isMediaSettingsModalVisible': isMediaSettingsModalVisible.value,
      'isDisplaySettingsModalVisible': isDisplaySettingsModalVisible.value,
      'isParticipantsModalVisible': isParticipantsModalVisible.value,
      'isMessagesModalVisible': isMessagesModalVisible.value,
      'isConfirmExitModalVisible': isConfirmExitModalVisible.value,
      'isConfirmHereModalVisible': isConfirmHereModalVisible.value,
      'isLoadingModalVisible': isLoadingModalVisible.value,

      // Recording Options
      'recordingMediaOptions': recordingMediaOptions.value,
      'recordingAudioOptions': recordingAudioOptions.value,
      'recordingVideoOptions': recordingVideoOptions.value,
      'recordingVideoType': recordingVideoType.value,
      'recordingVideoOptimized': recordingVideoOptimized.value,
      'recordingDisplayType': recordingDisplayType.value,
      'recordingAddHLS': recordingAddHLS.value,
      'recordingAddText': recordingAddText.value,
      'recordingCustomText': recordingCustomText.value,
      'recordingCustomTextPosition': recordingCustomTextPosition.value,
      'recordingCustomTextColor': recordingCustomTextColor.value,
      'recordingNameTags': recordingNameTags.value,
      'recordingBackgroundColor': recordingBackgroundColor.value,
      'recordingNameTagsColor': recordingNameTagsColor.value,
      'recordingOrientationVideo': recordingOrientationVideo.value,
      'clearedToResume': clearedToResume.value,
      'clearedToRecord': clearedToRecord.value,
      'recordState': recordState,
      'showRecordButtons': showRecordButtons.value,
      'recordingProgressTime': recordingProgressTime.value,
      'audioSwitching': audioSwitching.value,
      'videoSwitching': videoSwitching.value,
      'videoAlreadyOn': videoAlreadyOn.value,
      'audioAlreadyOn': audioAlreadyOn.value,
      'componentSizes': componentSizes.value,
      'hasCameraPermission': hasCameraPermission.value,
      'hasAudioPermission': hasAudioPermission.value,
      'transportCreated': transportCreated.value,
      'transportCreatedVideo': transportCreatedVideo.value,
      'transportCreatedAudio': transportCreatedAudio.value,
      'transportCreatedScreen': transportCreatedScreen.value,
      'producerTransport': producerTransport.value,
      'videoProducer': videoProducer.value,
      'params': params.value,
      'videoParams': videoParams.value,
      'audioParams': audioParams.value,
      'audioProducer': audioProducer.value,
      'consumerTransports': consumerTransports.value,
      'consumingTransports': consumingTransports.value,
      // Polls
      'polls': polls.value,
      'poll': poll.value,
      'isPollModalVisible': isPollModalVisible.value,

      // Breakout rooms
      'breakoutRooms': breakoutRooms.value,
      'currentRoomIndex': currentRoomIndex.value,
      'canStartBreakout': canStartBreakout.value,
      'breakOutRoomStarted': breakOutRoomStarted.value,
      'breakOutRoomEnded': breakOutRoomEnded.value,
      'hostNewRoom': hostNewRoom.value,
      'limitedBreakRoom': limitedBreakRoom.value,
      'mainRoomsLength': mainRoomsLength.value,
      'memberRoom': memberRoom.value,
      'isBreakoutRoomsModalVisible': isBreakoutRoomsModalVisible.value,

      'validated': validated,
      'device': device.value,
      'socket': socket.value,

      // Update functions for Room Details
      'updateRoomName': updateRoomName,
      'updateMember': updateMember,
      'updateAdminPasscode': updateAdminPasscode,
      'updateYouAreCoHost': updateYouAreCoHost,
      'updateYouAreHost': updateYouAreHost,
      'updateIslevel': updateIslevel,
      'updateCoHost': updateCoHost,
      'updateCoHostResponsibility': updateCoHostResponsibility,
      'updateConfirmedToRecord': updateConfirmedToRecord,
      'updateMeetingDisplayType': updateMeetingDisplayType,
      'updateMeetingVideoOptimized': updateMeetingVideoOptimized,
      'updateEventType': updateEventType,
      'updateParticipants': updateParticipants,
      'updateParticipantsCounter': updateParticipantsCounter,
      'updateParticipantsFilter': updateParticipantsFilter,

      // Update functions for more room details - media
      'updateConsumeSockets': updateConsumeSockets,
      'updateRtpCapabilities': updateRtpCapabilities,
      'updateRoomRecvIPs': updateRoomRecvIPs,
      'updateMeetingRoomParams': updateMeetingRoomParams,
      'updateItemPageLimit': updateItemPageLimit,
      'updateAudioOnlyRoom': updateAudioOnlyRoom,
      'updateAddForBasic': updateAddForBasic,
      'updateScreenPageLimit': updateScreenPageLimit,
      'updateShareScreenStarted': updateShareScreenStarted,
      'updateShared': updateShared,
      'updateTargetOrientation': updateTargetOrientation,
      'updateVidCons': updateVidCons,
      'updateFrameRate': updateFrameRate,
      'updateHParams': updateHParams,
      'updateVParams': updateVParams,
      'updateScreenParams': updateScreenParams,
      'updateAParams': updateAParams,

      // Update functions for more room details - recording
      'updateRecordingAudioPausesLimit': updateRecordingAudioPausesLimit,
      'updateRecordingAudioPausesCount': updateRecordingAudioPausesCount,
      'updateRecordingAudioSupport': updateRecordingAudioSupport,
      'updateRecordingAudioPeopleLimit': updateRecordingAudioPeopleLimit,
      'updateRecordingAudioParticipantsTimeLimit':
          updateRecordingAudioParticipantsTimeLimit,
      'updateRecordingVideoPausesCount': updateRecordingVideoPausesCount,
      'updateRecordingVideoPausesLimit': updateRecordingVideoPausesLimit,
      'updateRecordingVideoSupport': updateRecordingVideoSupport,
      'updateRecordingVideoPeopleLimit': updateRecordingVideoPeopleLimit,
      'updateRecordingVideoParticipantsTimeLimit':
          updateRecordingVideoParticipantsTimeLimit,
      'updateRecordingAllParticipantsSupport':
          updateRecordingAllParticipantsSupport,
      'updateRecordingVideoParticipantsSupport':
          updateRecordingVideoParticipantsSupport,
      'updateRecordingAllParticipantsFullRoomSupport':
          updateRecordingAllParticipantsFullRoomSupport,
      'updateRecordingVideoParticipantsFullRoomSupport':
          updateRecordingVideoParticipantsFullRoomSupport,
      'updateRecordingPreferredOrientation':
          updateRecordingPreferredOrientation,
      'updateRecordingSupportForOtherOrientation':
          updateRecordingSupportForOtherOrientation,
      'updateRecordingMultiFormatsSupport': updateRecordingMultiFormatsSupport,

      // Update functions for user recording params
      'updateUserRecordingParams': updateUserRecordingParams,
      'updateCanRecord': updateCanRecord,
      'updateStartReport': updateStartReport,
      'updateEndReport': updateEndReport,
      'updateRecordTimerInterval': updateRecordTimerInterval,
      'updateRecordStartTime': updateRecordStartTime,
      'updateRecordElapsedTime': updateRecordElapsedTime,
      'updateIsTimerRunning': updateIsTimerRunning,
      'updateCanPauseResume': updateCanPauseResume,
      'updateRecordChangeSeconds': updateRecordChangeSeconds,
      'updatePauseLimit': updatePauseLimit,
      'updatePauseRecordCount': updatePauseRecordCount,
      'updateCanLaunchRecord': updateCanLaunchRecord,
      'updateStopLaunchRecord': updateStopLaunchRecord,

      // Update function for participants all
      'updateParticipantsAll': updateParticipantsAll,

      'updateFirstAll': updateFirstAll,
      'updateUpdateMainWindow': updateUpdateMainWindow,
      'updateFirstRound': updateFirstRound,
      'updateLandScaped': updateLandScaped,
      'updateLockScreen': updateLockScreen,
      'updateScreenId': updateScreenId,
      'updateAllVideoStreams': updateAllVideoStreams,
      'updateNewLimitedStreams': updateNewLimitedStreams,
      'updateNewLimitedStreamsIDs': updateNewLimitedStreamsIDs,
      'updateActiveSounds': updateActiveSounds,
      'updateScreenShareIDStream': updateScreenShareIDStream,
      'updateScreenShareNameStream': updateScreenShareNameStream,
      'updateAdminIDStream': updateAdminIDStream,
      'updateAdminNameStream': updateAdminNameStream,
      'updateYouYouStream': updateYouYouStream,
      'updateYouYouStreamIDs': updateYouYouStreamIDs,
      'updateLocalStream': updateLocalStream,
      'updateRecordStarted': updateRecordStarted,
      'updateRecordResumed': updateRecordResumed,
      'updateRecordPaused': updateRecordPaused,
      'updateRecordStopped': updateRecordStopped,
      'updateAdminRestrictSetting': updateAdminRestrictSetting,
      'updateVideoRequestState': updateVideoRequestState,
      'updateVideoRequestTime': updateVideoRequestTime,
      'updateVideoAction': updateVideoAction,
      'updateLocalStreamVideo': updateLocalStreamVideo,
      'updateUserDefaultVideoInputDevice': updateUserDefaultVideoInputDevice,
      'updateCurrentFacingMode': updateCurrentFacingMode,
      'updateRefParticipants': updateRefParticipants,
      'updateDefVideoID': updateDefVideoID,
      'updateAllowed': updateAllowed,
      'updateDispActiveNames': updateDispActiveNames,
      'updatePDispActiveNames': updatePDispActiveNames,
      'updateActiveNames': updateActiveNames,
      'updatePrevActiveNames': updatePrevActiveNames,
      'updatePActiveNames': updatePActiveNames,
      'updateMembersReceived': updateMembersReceived,
      'updateDeferScreenReceived': updateDeferScreenReceived,
      'updateHostFirstSwitch': updateHostFirstSwitch,
      'updateMicAction': updateMicAction,
      'updateScreenAction': updateScreenAction,
      'updateChatAction': updateChatAction,
      'updateAudioRequestState': updateAudioRequestState,
      'updateScreenRequestState': updateScreenRequestState,
      'updateChatRequestState': updateChatRequestState,
      'updateAudioRequestTime': updateAudioRequestTime,
      'updateScreenRequestTime': updateScreenRequestTime,
      'updateChatRequestTime': updateChatRequestTime,
      'updateOldSoundIds': updateOldSoundIds,
      'updateHostLabel': updateHostLabel,
      'updateMainScreenFilled': updateMainScreenFilled,
      'updateLocalStreamScreen': updateLocalStreamScreen,
      'updateScreenAlreadyOn': updateScreenAlreadyOn,
      'updateChatAlreadyOn': updateChatAlreadyOn,
      'updateRedirectURL': updateRedirectURL,
      'updateOldAllStreams': updateOldAllStreams,
      'updateAdminVidID': updateAdminVidID,
      'updateStreamNames': updateStreamNames,
      'updateNonAlVideoStreams': updateNonAlVideoStreams,
      'updateSortAudioLoudness': updateSortAudioLoudness,
      'updateAudioDecibels': updateAudioDecibels,
      'updateMixedAlVideoStreams': updateMixedAlVideoStreams,
      'updateNonAlVideoStreamsMuted': updateNonAlVideoStreamsMuted,
      'updatePaginatedStreams': updatePaginatedStreams,
      'updateLocalStreamAudio': updateLocalStreamAudio,
      'updateDefAudioID': updateDefAudioID,
      'updateUserDefaultAudioInputDevice': updateUserDefaultAudioInputDevice,
      'updateUserDefaultAudioOutputDevice': updateUserDefaultAudioOutputDevice,
      'updatePrevAudioInputDevice': updatePrevAudioInputDevice,
      'updatePrevVideoInputDevice': updatePrevVideoInputDevice,
      'updateAudioPaused': updateAudioPaused,
      'updateMainScreenPerson': updateMainScreenPerson,
      'updateAdminOnMainScreen': updateAdminOnMainScreen,
      'updateScreenStates': updateScreenStates,
      'updatePrevScreenStates': updatePrevScreenStates,
      'updateUpdateDateState': updateUpdateDateState,
      'updateLastUpdate': updateLastUpdate,
      'updateNForReadjustRecord': updateNForReadjustRecord,
      'updateFixedPageLimit': updateFixedPageLimit,
      'updateRemoveAltGrid': updateRemoveAltGrid,
      'updateNForReadjust': updateNForReadjust,
      'updateLastReOrderTime': updateLastReOrderTime,
      'updateAudStreamNames': updateAudStreamNames,
      'updateCurrentUserPage': updateCurrentUserPage,
      'updatePrevFacingMode': updatePrevFacingMode,
      'updateMainHeightWidth': updateMainHeightWidth,
      'updatePrevMainHeightWidth': updatePrevMainHeightWidth,
      'updatePrevDoPaginate': updatePrevDoPaginate,
      'updateDoPaginate': updateDoPaginate,
      'updateShareEnded': updateShareEnded,
      'updateLStreams': updateLStreams,
      'updateChatRefStreams': updateChatRefStreams,
      'updateControlHeight': updateControlHeight,
      'updateIsWideScreen': updateIsWideScreen,
      'updateIsMediumScreen': updateIsMediumScreen,
      'updateIsSmallScreen': updateIsSmallScreen,
      'updateAddGrid': updateAddGrid,
      'updateAddAltGrid': updateAddAltGrid,
      'updateGridRows': updateGridRows,
      'updateGridCols': updateGridCols,
      'updateAltGridRows': updateAltGridRows,
      'updateAltGridCols': updateAltGridCols,
      'updateNumberPages': updateNumberPages,
      'updateCurrentStreams': updateCurrentStreams,
      'updateShowMiniView': updateShowMiniView,
      'updateNStream': updateNStream,
      'updateDeferReceive': updateDeferReceive,
      'updateAllAudioStreams': updateAllAudioStreams,
      'updateRemoteScreenStream': updateRemoteScreenStream,
      'updateScreenProducer': updateScreenProducer,
      'updateGotAllVids': updateGotAllVids,
      'updatePaginationHeightWidth': updatePaginationHeightWidth,
      'updatePaginationDirection': updatePaginationDirection,
      'updateGridSizes': updateGridSizes,
      'updateScreenForceFullDisplay': updateScreenForceFullDisplay,
      'updateMainGridStream': updateMainGridStream,
      'updateOtherGridStreams': updateOtherGridStreams,
      'updateAudioOnlyStreams': updateAudioOnlyStreams,
      'updateVideoInputs': updateVideoInputs,
      'updateAudioInputs': updateAudioInputs,
      'updateMeetingProgressTime': updateMeetingProgressTime,
      'updateMeetingElapsedTime': updateMeetingElapsedTime,

      // Update functions for messages
      'updateMessages': updateMessages,
      'updateStartDirectMessage': updateStartDirectMessage,
      'updateDirectMessageDetails': updateDirectMessageDetails,
      'updateShowMessagesBadge': updateShowMessagesBadge,

      // Event settings
      'updateAudioSetting': updateAudioSetting,
      'updateVideoSetting': updateVideoSetting,
      'updateScreenshareSetting': updateScreenshareSetting,
      'updateChatSetting': updateChatSetting,

      // Display settings
      'updateDisplayOption': updateDisplayOption,
      'updateAutoWave': updateAutoWave,
      'updateForceFullDisplay': updateForceFullDisplay,
      'updatePrevForceFullDisplay': updatePrevForceFullDisplay,
      'updatePrevMeetingDisplayType': updatePrevMeetingDisplayType,

      // Waiting room
      'updateWaitingRoomFilter': updateWaitingRoomFilter,
      'updateWaitingRoomList': updateWaitingRoomList,
      'updateWaitingRoomCounter': updateWaitingRoomCounter,

      // Requests
      'updateRequestFilter': updateRequestFilter,
      'updateRequestList': updateRequestList,
      'updateRequestCounter': updateRequestCounter,

      // Total requests and waiting room
      'updateTotalReqWait': updateTotalReqWait,

      // Show Alert modal
      'updateIsMenuModalVisible': updateIsMenuModalVisible,
      'updateIsRecordingModalVisible': updateIsRecordingModalVisible,
      'updateIsSettingsModalVisible': updateIsSettingsModalVisible,
      'updateIsRequestsModalVisible': updateIsRequestsModalVisible,
      'updateIsWaitingModalVisible': updateIsWaitingModalVisible,
      'updateIsCoHostModalVisible': updateIsCoHostModalVisible,
      'updateIsMediaSettingsModalVisible': updateIsMediaSettingsModalVisible,
      'updateIsDisplaySettingsModalVisible':
          updateIsDisplaySettingsModalVisible,

      // Other Modals
      'updateIsParticipantsModalVisible': updateIsParticipantsModalVisible,
      'updateIsMessagesModalVisible': updateIsMessagesModalVisible,
      'updateIsConfirmExitModalVisible': updateIsConfirmExitModalVisible,
      'updateIsConfirmHereModalVisible': updateIsConfirmHereModalVisible,
      'updateIsLoadingModalVisible': updateIsLoadingModalVisible,

      // Recording Options
      'updateRecordingMediaOptions': updateRecordingMediaOptions,
      'updateRecordingAudioOptions': updateRecordingAudioOptions,
      'updateRecordingVideoOptions': updateRecordingVideoOptions,
      'updateRecordingVideoType': updateRecordingVideoType,
      'updateRecordingVideoOptimized': updateRecordingVideoOptimized,
      'updateRecordingDisplayType': updateRecordingDisplayType,
      'updateRecordingAddHLS': updateRecordingAddHLS,
      'updateRecordingAddText': updateRecordingAddText,
      'updateRecordingCustomText': updateRecordingCustomText,
      'updateRecordingCustomTextPosition': updateRecordingCustomTextPosition,
      'updateRecordingCustomTextColor': updateRecordingCustomTextColor,
      'updateRecordingNameTags': updateRecordingNameTags,
      'updateRecordingBackgroundColor': updateRecordingBackgroundColor,
      'updateRecordingNameTagsColor': updateRecordingNameTagsColor,
      'updateRecordingOrientationVideo': updateRecordingOrientationVideo,
      'updateClearedToResume': updateClearedToResume,
      'updateClearedToRecord': updateClearedToRecord,
      'updateRecordState': updateRecordState,
      'updateShowRecordButtons': updateShowRecordButtons,
      'updateRecordingProgressTime': updateRecordingProgressTime,
      'updateAudioSwitching': updateAudioSwitching,
      'updateVideoSwitching': updateVideoSwitching,

      // Media states
      'updateVideoAlreadyOn': updateVideoAlreadyOn,
      'updateAudioAlreadyOn': updateAudioAlreadyOn,
      'updateComponentSizes': updateComponentSizes,

      // Permissions
      'updateHasCameraPermission': updateHasCameraPermission,
      'updateHasAudioPermission': updateHasAudioPermission,

      // Transports
      'updateTransportCreated': updateTransportCreated,
      'updateTransportCreatedVideo': updateTransportCreatedVideo,
      'updateTransportCreatedAudio': updateTransportCreatedAudio,
      'updateTransportCreatedScreen': updateTransportCreatedScreen,
      'updateProducerTransport': updateProducerTransport,
      'updateVideoProducer': updateVideoProducer,
      'updateParams': updateParams,
      'updateVideoParams': updateVideoParams,
      'updateAudioParams': updateAudioParams,
      'updateAudioProducer': updateAudioProducer,
      'updateConsumerTransports': updateConsumerTransports,
      'updateConsumingTransports': updateConsumingTransports,

      //polls
      'updatePolls': updatePolls,
      'updatePoll': updatePoll,
      'updateIsPollModalVisible': updateIsPollModalVisible,

      //breakout rooms
      'updateBreakoutRooms': updateBreakoutRooms,
      'updateCurrentRoomIndex': updateCurrentRoomIndex,
      'updateCanStartBreakout': updateCanStartBreakout,
      'updateBreakOutRoomStarted': updateBreakOutRoomStarted,
      'updateBreakOutRoomEnded': updateBreakOutRoomEnded,
      'updateHostNewRoom': updateHostNewRoom,
      'updateLimitedBreakRoom': updateLimitedBreakRoom,
      'updateMainRoomsLength': updateMainRoomsLength,
      'updateMemberRoom': updateMemberRoom,
      'updateIsBreakoutRoomsModalVisible': updateIsBreakoutRoomsModalVisible,

      'checkOrientation': checkOrientation,

      'updateDevice': updateDevice,
      'updateSocket': updateSocket,
      'updateValidated': updateValidated,

      'showAlert': showAlert,
      'getUpdatedAllParams': getUpdatedAllParams,
    };
  }

  /// Show an alert message.
  void showAlert({
    required String message,
    required String type,
    required int duration,
  }) {
    // Show an alert message, type is 'danger', 'success', duration is in milliseconds
    updateAlertMessage(message);
    updateAlertType(type);
    updateAlertDuration(duration);
    updateAlertVisible(true);
  }

  bool micActive = false;
  bool videoActive = false;
  bool screenShareActive = false;
  bool endCallActive = false;
  bool participantsActive = false;
  bool menuActive = false;
  bool commentsActive = false;

  List<Map<String, dynamic>> recordButton = [];

  void initializeRecordButton() {
    recordButton = [
      // Record Button
      {
        'icon': Icons.fiber_manual_record,
        'active': false,
        'text': 'Record',
        'onPress': () {
          // Action for the Record button
          launchRecording(
            parameters: getAllParams(),
          );
        },
        'activeColor': const Color.fromARGB(255, 244, 3, 3),
        'inActiveColor': const Color.fromARGB(255, 251, 9, 9),
        'show': true,
      },
    ];
  }

  // Record Buttons
  List<Map<String, dynamic>> recordButtons = [];

  // Initialize Record Buttons
  // The record buttons are displayed in the control bar

  void initializeRecordButtons() {
    recordButtons = [
      // Play/Pause Button
      {
        // name: 'Pause',
        'icon': Icons.play_circle_filled,
        'active': !recordPaused.value,
        'onPress': () => updateRecording(
            parameters: {...getAllParams(), ...mediaSFUFunctions()}),
        'activeColor': Colors.black,
        'inActiveColor': Colors.black,
        'alternateIcon': Icons.pause_circle_filled,
        'show': true,
      },
      // Stop Button
      {
        // name: 'Stop',
        'icon': Icons.stop_circle,
        'active': false,
        'onPress': () => stopRecording(
            parameters: {...getAllParams(), ...mediaSFUFunctions()}),
        'activeColor': Colors.green,
        'inActiveColor': Colors.black,
        'show': true,
      },
      // Timer Display
      {
        'customComponent': Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(0),
          margin: const EdgeInsets.all(2),
          child: Text(
            recordingProgressTime.value,
            style: const TextStyle(
              color: Colors.black,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        'show': true,
      },
      // Status Button
      {
        // name: 'Status',
        'icon': Icons.circle,
        'active': false,
        'onPress': () => (),
        'activeColor': Colors.black,
        'inActiveColor':
            recordPaused.value == false ? Colors.red : Colors.yellow,
        'show': true,
      },
      // Settings Button
      {
        // name: 'Settings',
        'icon': Icons.settings,
        'active': false,
        'onPress': () => launchRecording(parameters: {...getAllParams()}),
        'activeColor': Colors.green,
        'inActiveColor': Colors.black,
        'show': true,
      },
    ];
  }

  List<Map<String, dynamic>> customMenuButtons = [];

  void initializeCustomMenuButtons() {
    customMenuButtons = [
      // Record Button
      {
        'icon': Icons.fiber_manual_record,
        'text': 'Record',
        'action': () {
          // Action for the Record button
          launchRecording(
            parameters: getAllParams(),
          );
        },
        'show': !showRecordButtons.value && islevel.value == '2',
      },
      // Custom Record Buttons
      {
        // You can define custom UI components directly in Flutter
        // In this case, you'll need to handle the custom UI rendering separately
        // You can replace this with a custom widget/component as needed
        'customComponent': ControlButtonsAltComponent(
            buttons: recordButtons,
            direction: 'horizontal',
            showAspect: true,
            location: 'bottom',
            position: 'middle'),
        'show': showRecordButtons.value && islevel.value == '2',
        'action': () {},
      },
      // Event Settings Button
      {
        'icon': Icons.settings,
        'text': 'Event Settings',
        'modalId': 'settingsModal',
        'action': () {
          // Action for the Event Settings button
          launchSettings(
            updateIsSettingsModalVisible: updateIsSettingsModalVisible,
            isSettingsModalVisible: isSettingsModalVisible.value,
          );
        },
        'show': islevel.value == '2',
      },
      // Requests Button
      {
        'icon': Icons.group,
        'text': 'Requests',
        'modalId': 'requestsModal',
        'action': () {
          // Action for the Requests button
          launchRequests(parameters: {
            'updateIsRequestsModalVisible': updateIsRequestsModalVisible,
            'isRequestsModalVisible': isRequestsModalVisible.value,
          });
        },
        'show': islevel.value == '2' ||
            (coHost.value == member.value &&
                coHostResponsibility.value.any((item) =>
                    item['name'] == 'media' && item['value'] == true)),
      },
      // Waiting Button
      {
        'icon': Icons.access_time,
        'text': 'Waiting',
        'modalId': 'waitingRoomModal',
        'action': () {
          // Action for the Waiting button
          launchWaiting(
              updateIsWaitingModalVisible: updateIsWaitingModalVisible,
              isWaitingModalVisible: isWaitingModalVisible.value);
        },
        'show': islevel.value == '2' ||
            (coHost.value == member.value &&
                coHostResponsibility.value.any((item) =>
                    item['name'] == 'waiting' && item['value'] == true)),
      },
      // Co-host Button
      {
        'icon': Icons.person_add,
        'text': 'Co-host',
        'modalId': 'cohostModal',
        'action': () {
          // Action for the Co-host button
          launchCoHost(parameters: {
            'updateIsCoHostModalVisible': updateIsCoHostModalVisible,
            'isCoHostModalVisible': isCoHostModalVisible.value,
          });
        },
        'show': islevel.value == '2',
      },
      //Set Media Button
      {
        'icon': Icons.settings,
        'text': 'Set Media',
        'modalId': 'mediaSettingsModal',
        'action': () {
          // Action for the Set Media button
          launchMediaSettings(parameters: {
            ...getAllParams(),
            ...mediaSFUFunctions(),
            'onWeb': kIsWeb,
            'device': device.value,
            'socket': socket.value,
            'showAlert': showAlert,
            'checkPermission': checkPermission,
            'streamSuccessVideo': streamSuccessVideo,
            'hasCameraPermission': hasCameraPermission.value,
            'requestPermissionCamera': requestPermissionCamera,
            'checkMediaPermission': !kIsWeb,
            'streamSuccessAudioSwitch': streamSuccessAudioSwitch,
            'hasAudioPermission': hasAudioPermission.value,
            'requestPermissionAudio': requestPermissionAudio,
            'streamSuccessAudio': streamSuccessAudio,
          });
        },
        'show': true,
      },
      // Display Button
      {
        'icon': Icons.desktop_windows,
        'text': 'Display',
        'modalId': 'displaySettingsModal',
        'action': () {
          // Action for the Display button
          launchDisplaySettings(
            updateIsDisplaySettingsModalVisible:
                updateIsDisplaySettingsModalVisible,
            isDisplaySettingsModalVisible: isDisplaySettingsModalVisible.value,
          );
        },
        'show': true,
      },
      {
        'icon': Icons.poll,
        'text': 'Poll',
        'modalId': 'pollModal',
        'action': () {
          // Action for the Poll button
          launchPoll(parameters: {
            'updateIsPollModalVisible': updateIsPollModalVisible,
            'isPollModalVisible': isPollModalVisible.value,
          });
        },
        'show': true,
      },

      {
        'icon': Icons.group_outlined,
        'text': 'Breakout Rooms',
        'modalId': 'breakoutRoomsModal',
        'action': () {
          // Action for the Breakout Rooms button
          launchBreakoutRooms(parameters: {
            'updateIsBreakoutRoomsModalVisible':
                updateIsBreakoutRoomsModalVisible,
            'isBreakoutRoomsModalVisible': isBreakoutRoomsModalVisible.value,
          });
        },
        'show': islevel.value == '2',
      },
    ];
  }

  //Control Buttons Broadcast Events
  List<Map<String, dynamic>> controlBroadcastButtons = [];

  // Initialize Control Buttons Broadcast Events

  void initializeControlBroadcastButtons() {
    controlBroadcastButtons = [
      // Users button
      {
        'icon': Icons.group_outlined,
        'active': participantsActive,
        'onPress': () => launchParticipants(
              updateIsParticipantsModalVisible:
                  updateIsParticipantsModalVisible,
              isParticipantsModalVisible: isParticipantsModalVisible.value,
            ),
        'activeColor': Colors.black,
        'inActiveColor': Colors.black,
        'show': true,
      },

      // Share button
      {
        'icon': Icons.share,
        'alternateIcon': Icons.share,
        'active': true,
        'onPress': () =>
            updateIsShareEventModalVisible(!isShareEventModalVisible.value),
        'activeColor': Colors.black,
        'inActiveColor': Colors.black,
        'show': true,
      },
      // Custom component
      {
        'customComponent': Stack(
          children: [
            // Your icon
            const Icon(
              Icons.comment,
              size: 20,
              color: Colors.black,
            ),
            // Conditionally render a badge
            if (showMessagesBadge.value)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: const Text(
                    '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        'onPress': () => launchMessages(
              updateIsMessagesModalVisible: updateIsMessagesModalVisible,
              isMessagesModalVisible: isMessagesModalVisible.value,
            ),
        'show': true,
      },

      // Switch camera button
      {
        'icon': Icons.sync,
        'alternateIcon': Icons.sync,
        'active': true,
        'onPress': () => switchVideoAlt(
              parameters: {
                ...getAllParams(),
                ...mediaSFUFunctions(),
                // Others
                'onWeb': kIsWeb,
                'device': device.value,
                'socket': socket.value,
                'showAlert': showAlert,
                'checkPermission': checkPermission,
                'streamSuccessVideo': streamSuccessVideo,
                'hasCameraPermission': hasCameraPermission.value,
                'requestPermissionCamera': requestPermissionCamera,
                'checkMediaPermission': !kIsWeb,
              },
            ),
        'activeColor': Colors.black,
        'inActiveColor': Colors.black,
        'show': islevel.value == '2',
      },
      // Video button
      {
        'icon': Icons.video_call,
        'alternateIcon': Icons.video_call,
        'active': videoActive,
        'onPress': () => clickVideo(
              parameters: {
                ...getAllParams(),
                ...mediaSFUFunctions(),
                // Others
                'onWeb': kIsWeb,
                'device': device.value,
                'socket': socket.value,
                'showAlert': showAlert,
                'checkPermission': checkPermission,
                'streamSuccessVideo': streamSuccessVideo,
                'hasCameraPermission': hasCameraPermission.value,
                'requestPermissionCamera': requestPermissionCamera,
                'checkMediaPermission': !kIsWeb,
              },
            ),
        'activeColor': Colors.green,
        'inActiveColor': Colors.red,
        'show': islevel.value == '2',
      },
      // Microphone button
      {
        'icon': Icons.mic,
        'alternateIcon': Icons.mic,
        'active': micActive,
        'onPress': () => clickAudio(
              parameters: {
                ...getAllParams(),
                ...mediaSFUFunctions(),
                // Others
                'onWeb': kIsWeb,
                'device': device.value,
                'socket': socket.value,
                'showAlert': showAlert,
                'checkPermission': checkPermission,
                'streamSuccessAudio': streamSuccessAudio,
                'hasAudioPermission': hasAudioPermission.value,
                'requestPermissionAudio': requestPermissionAudio,
                'checkMediaPermission': !kIsWeb,
              },
            ),
        'activeColor': Colors.green,
        'inActiveColor': Colors.red,
        'show': islevel.value == '2',
      },
      {
        'customComponent': Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.bar_chart, size: 20, color: Colors.black),
              const SizedBox(width: 5),
              Text(
                participantsCounter.value.toString(),
                style: const TextStyle(
                  backgroundColor: Colors.transparent,
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        'show': true,
      },
      // End call button
      {
        'icon': Icons.call_end,
        'active': endCallActive,
        'onPress': () => launchConfirmExit(
              updateIsConfirmExitModalVisible: updateIsConfirmExitModalVisible,
              isConfirmExitModalVisible: isConfirmExitModalVisible.value,
            ),
        'activeColor': Colors.green,
        'inActiveColor': Colors.red,
        'show': true,
      },
    ];
  }

  // Control Buttons Chat Events
  List<Map<String, dynamic>> controlChatButtons = [];

  // Initialize Control Buttons Chat Events

  void initializeControlChatButtons() {
    controlChatButtons = [
      // Share button
      {
        'icon': Icons.share,
        'alternateIcon': Icons.share,
        'active': true,
        'onPress': () =>
            updateIsShareEventModalVisible(!isShareEventModalVisible.value),
        'activeColor': Colors.black,
        'inActiveColor': Colors.black,
        'show': true,
      },
      // Custom component
      {
        'customComponent': Stack(
          children: [
            // Your icon
            const Icon(
              Icons.comment,
              size: 20,
              color: Colors.black,
            ),
            // Conditionally render a badge
            if (showMessagesBadge.value)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: const Text(
                    '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        'onPress': () => launchMessages(
              updateIsMessagesModalVisible: updateIsMessagesModalVisible,
              isMessagesModalVisible: isMessagesModalVisible.value,
            ),
        'show': true,
      },

      // Switch camera button
      {
        'icon': Icons.sync,
        'alternateIcon': Icons.sync,
        'active': true,
        'onPress': () => switchVideoAlt(
              parameters: {
                ...getAllParams(),
                ...mediaSFUFunctions(),
                // Others
                'onWeb': kIsWeb,
                'device': device.value,
                'socket': socket.value,
                'showAlert': showAlert,
                'checkPermission': checkPermission,
                'streamSuccessVideo': streamSuccessVideo,
                'hasCameraPermission': hasCameraPermission.value,
                'requestPermissionCamera': requestPermissionCamera,
                'checkMediaPermission': !kIsWeb,
              },
            ),
        'activeColor': Colors.black,
        'inActiveColor': Colors.black,
        'show': true,
      },
      // Video button
      {
        'icon': Icons.video_call,
        'alternateIcon': Icons.video_call,
        'active': videoActive,
        'onPress': () => clickVideo(
              parameters: {
                ...getAllParams(),
                ...mediaSFUFunctions(),
                // Others
                'onWeb': kIsWeb,
                'device': device.value,
                'socket': socket.value,
                'showAlert': showAlert,
                'checkPermission': checkPermission,
                'streamSuccessVideo': streamSuccessVideo,
                'hasCameraPermission': hasCameraPermission.value,
                'requestPermissionCamera': requestPermissionCamera,
                'checkMediaPermission': !kIsWeb,
              },
            ),
        'activeColor': Colors.green,
        'inActiveColor': Colors.red,
        'show': true,
      },
      // Microphone button
      {
        'icon': Icons.mic,
        'alternateIcon': Icons.mic,
        'active': micActive,
        'onPress': () => clickAudio(
              parameters: {
                ...getAllParams(),
                ...mediaSFUFunctions(),
                // Others
                'onWeb': kIsWeb,
                'device': device.value,
                'socket': socket.value,
                'showAlert': showAlert,
                'checkPermission': checkPermission,
                'streamSuccessAudio': streamSuccessAudio,
                'hasAudioPermission': hasAudioPermission.value,
                'requestPermissionAudio': requestPermissionAudio,
                'checkMediaPermission': !kIsWeb,
              },
            ),
        'activeColor': Colors.green,
        'inActiveColor': Colors.red,
        'show': true,
      },
      // End call button
      {
        'icon': Icons.call_end,
        'active': endCallActive,
        'onPress': () => launchConfirmExit(
              updateIsConfirmExitModalVisible: updateIsConfirmExitModalVisible,
              isConfirmExitModalVisible: isConfirmExitModalVisible.value,
            ),
        'activeColor': Colors.green,
        'inActiveColor': Colors.red,
        'show': true,
      },
    ];
  }

  // Control Buttons
  List<Map<String, dynamic>> controlButtons = [];

  // Initialize Control Buttons
  // The control buttons are displayed in the control bar

  void initializeControlButtons() {
    controlButtons = [
      {
        'icon': Icons.mic_off_outlined,
        'alternateIcon': Icons.mic_outlined,
        'active': micActive,
        'onPress': () => clickAudio(
              parameters: {
                ...getAllParams(),
                ...mediaSFUFunctions(),
                'onWeb': kIsWeb,
                'device': device.value,
                'socket': socket.value,
                'showAlert': showAlert,
                'checkPermission': checkPermission,
                'streamSuccessAudio': streamSuccessAudio,
                'hasAudioPermission': hasAudioPermission.value,
                'requestPermissionAudio': requestPermissionAudio,
                'checkMediaPermission': !kIsWeb,
              },
            ),
        'activeColor': Colors.green,
        'inActiveColor': Colors.red,
        'disabled': audioSwitching.value,
      },
      {
        'icon': Icons.videocam_off_outlined,
        'alternateIcon': Icons.videocam_outlined,
        'active': videoActive,
        'onPress': () => clickVideo(
              parameters: {
                ...getAllParams(),
                ...mediaSFUFunctions(),
                'onWeb': kIsWeb,
                'device': device.value,
                'socket': socket.value,
                'showAlert': showAlert,
                'checkPermission': checkPermission,
                'streamSuccessVideo': streamSuccessVideo,
                'hasCameraPermission': hasCameraPermission.value,
                'requestPermissionCamera': requestPermissionCamera,
                'checkMediaPermission': !kIsWeb,
              },
            ),
        'activeColor': Colors.green,
        'inActiveColor': Colors.red,
        'disabled': videoSwitching.value,
      },
      {
        'icon': Icons.desktop_windows_outlined,
        'alternateIconComponent': const Icon(Icons.desktop_access_disabled,
            size: 20, color: Colors.red),
        'active': screenShareActive,
        'onPress': () => clickScreenShare(
              parameters: {
                ...getAllParams(),
                ...mediaSFUFunctions(),
                'device': device.value,
                'streamSuccessScreen': streamSuccessScreen,
                'onWeb': kIsWeb,
                'checkPermission': checkPermission,
              },
            ),
        'activeColor': Colors.green,
        'inActiveColor': Colors.red,
        'disabled': false,
      },
      {
        'icon': Icons.phone_outlined,
        'active': endCallActive,
        'onPress': () => launchConfirmExit(
              updateIsConfirmExitModalVisible: updateIsConfirmExitModalVisible,
              isConfirmExitModalVisible: isConfirmExitModalVisible.value,
            ),
        'activeColor': Colors.green,
        'inActiveColor': Colors.red,
        'disabled': false,
      },
      {
        'icon': Icons.group_outlined,
        'active': participantsActive,
        'onPress': () => launchParticipants(
              updateIsParticipantsModalVisible:
                  updateIsParticipantsModalVisible,
              isParticipantsModalVisible: isParticipantsModalVisible.value,
            ),
        'activeColor': Colors.black,
        'inActiveColor': Colors.black,
        'disabled': false,
      },
      {
        'customComponent': Stack(
          children: [
            const Icon(Icons.menu, size: 20, color: Colors.black),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: Text(
                  totalReqWait.value.toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        'onPress': () => launchMenuModal(
              updateIsMenuModalVisible: updateIsMenuModalVisible,
              isMenuModalVisible: isMenuModalVisible.value,
            ),
      },
      {
        'customComponent': Stack(
          children: [
            const Icon(Icons.chat_bubble_outline,
                size: 20, color: Colors.black),
            if (showMessagesBadge.value)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                  child: const Text(
                    '*',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        'onPress': () => launchMessages(
              updateIsMessagesModalVisible: updateIsMessagesModalVisible,
              isMessagesModalVisible: isMessagesModalVisible.value,
            ),
      },
    ];
  }

  @override
  void dispose() {
    isPortrait.removeListener(_handleOrientationChange);
    super.dispose();
  }

  Map<String, double> computeDimensionsMethod(
    BuildContext context, {
    double containerWidthFraction = 1,
    double containerHeightFraction = 1,
    required double mainSize,
    bool doStack = true,
    required double defaultFraction,
  }) {
    final EdgeInsets safeAreaInsets = MediaQuery.of(context).padding +
        MediaQuery.of(context).systemGestureInsets;
    double parentWidth =
        (MediaQuery.of(context).size.width) * containerWidthFraction;
    double parentHeight =
        (MediaQuery.of(context).size.height - safeAreaInsets.top) *
            containerHeightFraction *
            defaultFraction;
    bool isWideScreen = parentWidth > 768;

    if (doStack) {
      return isWideScreen
          ? {
              'mainHeight': (parentHeight).floorToDouble(),
              'otherHeight': (parentHeight).floorToDouble(),
              'mainWidth': ((mainSize / 100) * parentWidth).floorToDouble(),
              'otherWidth':
                  (((100 - mainSize) / 100) * parentWidth).floorToDouble(),
            }
          : {
              'mainHeight': (((mainSize / 100) * parentHeight)).floorToDouble(),
              'otherHeight':
                  ((((100 - mainSize) / 100) * parentHeight)).floorToDouble(),
              'mainWidth': parentWidth.floorToDouble(),
              'otherWidth': parentWidth.floorToDouble(),
            };
    } else {
      return {
        'mainHeight': parentHeight.floorToDouble(),
        'otherHeight': parentHeight.floorToDouble(),
        'mainWidth': parentWidth.floorToDouble(),
        'otherWidth': parentWidth.floorToDouble(),
      };
    }
  }

  void _handleOrientationChange() {
    _updateControlHeight();
  }

  Future<void> joinroom({
    required io.Socket socket,
    required String roomName,
    required String islevel,
    required String member,
    required String sec,
    required String apiUserName,
  }) async {
    // Join room and get data from server
    try {
      var data = await joinRoom(
          socket: socket,
          roomName: roomName,
          islevel: islevel,
          member: member,
          sec: sec,
          apiUserName: apiUserName);

      if (kDebugMode) {
        print('data: ${data['success']} $roomName');
      }

      if (data != null && data['success'] == true) {
        // Update roomData
        roomData.value = data;

        // Update room parameters
        try {
          updateRoomParametersClient(
            parameters: {
              ...getAllParams(),
              ...mediaSFUFunctions(),
              'data': data,
            },
          );
        } catch (error) {
          if (kDebugMode) {
            // print('Error updating room parameters: $error');
          }
        }

        // Update islevel
        updateIslevel(data['isHost'] ? '2' : '1');

        // Update admin passcode
        if (data['secureCode'] != null && data['secureCode'] != '') {
          updateAdminPasscode(data['secureCode']);
        }

        // Create device client
        if (data['rtpCapabilities'] != null) {
          try {
            Device device_ = await createDeviceClient(
              rtpCapabilities: data['rtpCapabilities'],
            );

            updateDevice(device_);
          } catch (error) {}
        }
      } else {
        // Handle error cases
        updateValidated(false);
        if (data != null && data['reason'] != null) {
          showAlert(
            message: data['reason'],
            type: 'danger',
            duration: 3000,
          );
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error joining producing room: $error');
      }
    }
  }

  Future<void> disconnectAllSockets(
      List<Map<String, io.Socket>> consumeSockets) async {
    for (final socketMap in consumeSockets) {
      final ip = socketMap.keys.first;
      final socket = socketMap[ip];
      try {
        socket!.disconnect();
        socket.close();
      } catch (error) {
        if (kDebugMode) {
          // print('Error disconnecting socket with IP: $ip: $error');
        }
      }
    }
  }

  Future<void> joinAndUpdate() async {
    Future<void> closeAndReset() async {
      // Close and clean up all sockets, modals, and reset all states to initial values
      try {
        updateIsMessagesModalVisible(false);
        updateIsParticipantsModalVisible(false);
        updateIsWaitingModalVisible(false);
        updateIsRequestsModalVisible(false);
        updateIsCoHostModalVisible(false);
        updateIsSettingsModalVisible(false);
        updateIsDisplaySettingsModalVisible(false);
        updateIsMediaSettingsModalVisible(false);
        updateIsMenuModalVisible(false);
        updateIsShareEventModalVisible(false);
        updateIsConfirmExitModalVisible(false);
        updateIsPollModalVisible(false);
        updateIsBreakoutRoomsModalVisible(false);
      } catch (e) {}

      try {
        if (videoAlreadyOn.value) {
          await clickVideo(parameters: {
            ...getAllParams(),
            ...mediaSFUFunctions(),
            'onWeb': kIsWeb,
            'device': device.value,
            'socket': socket.value,
            'showAlert': showAlert,
            'checkPermission': checkPermission,
            'streamSuccessVideo': streamSuccessVideo,
            'hasCameraPermission': hasCameraPermission.value,
            'requestPermissionCamera': requestPermissionCamera,
            'checkMediaPermission': !kIsWeb,
          });
        }
      } catch (e) {}

      try {
        if (audioAlreadyOn.value) {
          clickAudio(parameters: {
            ...getAllParams(),
            ...mediaSFUFunctions(),
            'onWeb': kIsWeb,
            'device': device.value,
            'socket': socket.value,
            'showAlert': showAlert,
            'checkPermission': checkPermission,
            'streamSuccessAudio': streamSuccessAudio,
            'hasAudioPermission': hasAudioPermission.value,
            'requestPermissionAudio': requestPermissionAudio,
            'checkMediaPermission': !kIsWeb,
          });
        }
      } catch (e) {}

      try {
        if (localStream.value != null) {
          // Create a copy of the list of tracks
          List<MediaStreamTrack> tracksCopy =
              List.from(localStream.value!.getTracks());

          // Iterate over the copy and stop each track from the original list
          for (var track in tracksCopy) {
            track.stop();
          }
        }
      } catch (e) {}

      try {
        await disconnectAllSockets(consumeSockets.value);
      } catch (e) {}

      updateStatesToInitialValues();
      updateMeetingProgressTime('00:00:00');
      updateMeetingElapsedTime(0);
      updateRecordingProgressTime('00:00:00');
      updateRecordElapsedTime(0);
      updateShowRecordButtons(false);
      // Delay before updating validated
      await Future.delayed(const Duration(milliseconds: 1000));
      updateValidated(false);
    }

    Future<io.Socket> connectsocket(
      String apiUserName,
      String apiKey,
      String apiToken,
      String link,
    ) async {
      if (socket.value!.id != null && socket.value!.id!.isNotEmpty) {
        socket.value!.on('disconnect', (_) async {
          // Handle disconnect event
          try {
            await closeAndReset();
          } catch (e) {}

          disconnect(parameters: {
            'showAlert': showAlert,
            'redirectURL': redirectURL.value,
            'onWeb': kIsWeb,
            'updateValidated': updateValidated,
          });
        });

        socket.value!.on('allMembers', (membersData) async {
          try {
            // Handle 'allMembers' event
            if (membersData != null) {
              await allMembers(
                apiUserName: apiUserName,
                apiKey:
                    "null", //not recommended - use apiToken instead. Use for testing/development only
                apiToken: apiToken,
                members: membersData['members'],
                requestss: membersData['requests'] ?? requestList.value,
                coHoste: membersData['coHost'] ?? coHost.value,
                coHostRes: membersData['coHostResponsibilities'] ??
                    coHostResponsibility.value,
                parameters: {...getAllParams(), ...mediaSFUFunctions()},
                consumeSockets: consumeSockets.value,
              );
            }
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling allMembers event: $error');
            }
          }
        });

        socket.value!.on('allMembersRest', (membersData) async {
          // Handle 'allMembersRest' event
          try {
            if (membersData != null) {
              await allMembersRest(
                apiUserName: apiUserName,
                apiKey:
                    'null', //not recommended - use apiToken instead. Use for testing/development only
                members: membersData['members'],
                apiToken: apiToken,
                settings: membersData['settings'],
                coHoste: membersData['coHost'] ?? coHost.value,
                coHostRes: membersData['coHostResponsibilities'] ??
                    coHostResponsibility.value,
                parameters: {...getAllParams(), ...mediaSFUFunctions()},
                consumeSockets: consumeSockets.value,
              );
            }
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling allMembersRest event: $error');
            }
          }
        });

        socket.value!.on('userWaiting', (data) async {
          try {
            // Handle 'userWaiting' event
            userWaiting(
              name: data['name'],
              parameters: {...getAllParams(), ...mediaSFUFunctions()},
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling userWaiting event: $error');
            }
          }
        });

        socket.value!.on('personJoined', (data) async {
          try {
            // Handle 'personJoined' event
            personJoined(
              name: data['name'],
              parameters: {...getAllParams(), ...mediaSFUFunctions()},
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling personJoined event: $error');
            }
          }
        });

        socket.value!.on('allWaitingRoomMembers', (waitingData) async {
          try {
            // Handle 'allWaitingRoomMembers' event
            allWaitingRoomMembers(
              waitingParticipants: waitingData['waitingParticipants'] ??
                  waitingData['waitingParticipantss'] ??
                  waitingRoomList.value,
              parameters: {...getAllParams(), ...mediaSFUFunctions()},
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling allWaitingRoomMembers event: $error');
            }
          }
        });

        socket.value!.on('roomRecordParams', (data) async {
          try {
            // Handle 'roomRecordParams' event
            roomRecordParams(
              recordParams: data['recordParams'],
              parameters: {...getAllParams(), ...mediaSFUFunctions()},
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling roomRecordParams event: $error');
            }
          }
        });

        socket.value!.on('ban', (data) async {
          // Handle 'ban' event
          try {
            banParticipant(
              name: data['name'],
              parameters: {...getAllParams(), ...mediaSFUFunctions()},
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling ban event: $error');
            }
          }
        });

        socket.value!.on('updatedCoHost', (data) async {
          // Handle 'updatedCoHost' event
          try {
            updatedCoHost(
              coHost: data['coHost'] ?? data['coHoste'] ?? coHost.value,
              coHostResponsibility: data['coHostResponsibilities'] ??
                  data['coHostRes'] ??
                  coHostResponsibility.value,
              parameters: {...getAllParams(), ...mediaSFUFunctions()},
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling updatedCoHost event: $error');
            }
          }
        });

        socket.value!.on('participantRequested', (data) async {
          try {
            // Handle 'participantRequested' event
            participantRequested(
              userRequest: data['userRequest'],
              parameters: {...getAllParams(), ...mediaSFUFunctions()},
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling participantRequested event: $error');
            }
          }
        });

        socket.value!.on('screenProducerId', (data) async {
          // Handle 'screenProducerId' event
          try {
            screenProducerId(
              producerId: data['producerId'],
              parameters: {...getAllParams(), ...mediaSFUFunctions()},
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling screenProducerId event: $error');
            }
          }
        });

        socket.value!.on('updateMediaSettings', (data) async {
          // Handle 'updateMediaSettings' event
          try {
            updateMediaSettings(
              settings: data['settings'],
              parameters: {...getAllParams(), ...mediaSFUFunctions()},
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling updateMediaSettings event: $error');
            }
          }
        });

        socket.value!.on('producer-media-paused', (data) async {
          // Handle 'producer-media-paused' event
          try {
            await producerMediaPaused(
              producerId: data['producerId'],
              kind: data['kind'],
              name: data['name'],
              parameters: {...getAllParams(), ...mediaSFUFunctions()},
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling producer-media-paused event: $error');
            }
          }
        });

        socket.value!.on('producer-media-resumed', (data) async {
          // Handle 'producer-media-resumed' event
          try {
            await producerMediaResumed(
              kind: data['kind'],
              name: data['name'],
              parameters: {...getAllParams(), ...mediaSFUFunctions()},
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling producer-media-resumed event: $error');
            }
          }
        });

        socket.value!.on('producer-media-closed', (data) async {
          // Handle 'producer-media-closed' event
          try {
            await producerMediaClosed(
              producerId: data['producerId'],
              kind: data['kind'],
              parameters: {...getAllParams(), ...mediaSFUFunctions()},
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling producer-media-closed event: $error');
            }
          }
        });

        socket.value!.on('controlMediaHost', (data) async {
          // Handle 'controlMediaHost' event
          try {
            controlMediaHost(
              type: data['type'],
              parameters: {...getAllParams(), ...mediaSFUFunctions()},
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling controlMediaHost event: $error');
            }
          }
        });

        socket.value!.on('meetingEnded', (_) async {
          // Handle 'meetingEnded' event
          try {
            await closeAndReset();
          } catch (e) {}

          await meetingEnded(parameters: {
            'showAlert': showAlert,
            'redirectURL': redirectURL.value,
            'onWeb': kIsWeb,
            'eventType': eventType.value,
            'updateValidated': updateValidated,
          });
        });

        socket.value!.on('disconnectUserSelf', (_) async {
          // Handle 'disconnectUserSelf' event
          try {
            await disconnectUserSelf(parameters: {
              'socket': socket.value,
              'member': member.value,
              'roomName': roomName.value,
            });
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling disconnectUserSelf event: $error');
            }
          }
        });

        socket.value!.on('receiveMessage', (data) async {
          // Handle 'receiveMessage' event
          try {
            await receiveMessage(
              message: data['message'],
              parameters: {...getAllParams(), ...mediaSFUFunctions()},
              messages: messages.value,
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling receiveMessage event: $error');
            }
          }
        });

        socket.value!.on('meetingTimeRemaining', (data) async {
          // Handle 'meetingTimeRemaining' event
          try {
            await meetingTimeRemaining(
              timeRemaining: data['timeRemaining'],
              parameters: {
                'eventType': eventType.value,
                'showAlert': showAlert
              },
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling meetingTimeRemaining event: $error');
            }
          }
        });

        socket.value!.on('meetingStillThere', (data) async {
          // Handle 'meetingStillThere' event
          try {
            await meetingStillThere(
                timeRemaining: data['timeRemaining'],
                parameters: {
                  'updateIsConfirmHereModalVisible':
                      updateIsConfirmHereModalVisible,
                  'isConfirmHereModalVisible': isConfirmHereModalVisible.value
                });
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling meetingStillThere event: $error');
            }
          }
        });

        socket.value!.on('startRecords', (_) async {
          // Handle 'startRecords' event
          try {
            startRecords(
              parameters: {
                'roomName': roomName.value,
                'member': member.value,
                'socket': socket.value,
              },
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling startRecords event: $error');
            }
          }
        });

        socket.value!.on('reInitiateRecording', (_) async {
          // Handle 'reInitiateRecording' event
          try {
            reInitiateRecording(parameters: {
              'roomName': roomName.value,
              'member': member.value,
              'socket': socket.value,
              'adminRestrictSetting': adminRestrictSetting.value,
            });
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling reInitiateRecording event: $error');
            }
          }
        });

        socket.value!.on('updateConsumingDomains', (data) async {
          // Handle 'updateConsumingDomains' event
          try {
            updateConsumingDomains(
                domains: data['domains'],
                altDomains: data['alt_domains'],
                parameters: {
                  ...getAllParams(),
                  ...mediaSFUFunctions(),
                  'apiUserName': apiUserName,
                  'apiKey':
                      null, //not recommended - use apiToken instead. Use for testing/development only
                  'apiToken': apiToken,
                });
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling updateConsumingDomains event: $error');
            }
          }
        });

        socket.value!.on('RecordingNotice', (data) async {
          // Handle 'RecordingNotice' event
          try {
            await RecordingNotice(
              state: data['state'],
              userRecordingParam: (data.containsKey('userRecordingParam') &&
                      (data['userRecordingParam'] != null &&
                          data['userRecordingParam'].isNotEmpty))
                  ? data['userRecordingParam']
                  : userRecordingParams.value,
              pauseCount:
                  data.containsKey('pauseCount') ? data['pauseCount'] ?? 0 : 0,
              timeDone:
                  data.containsKey('timeDone') ? data['timeDone'] ?? 0 : 0,
              parameters: {
                ...getAllParams(),
                ...mediaSFUFunctions(),
              },
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling RecordingNotice event: $error');
            }
          }
        });

        socket.value!.on('timeLeftRecording', (data) async {
          // Handle 'timeLeftRecording' event
          try {
            timeLeftRecording(
              timeLeft: data['timeLeft'],
              showAlert: showAlert,
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling timeLeftRecording event: $error');
            }
          }
        });

        socket.value!.on('stoppedRecording', (data) async {
          // Handle 'stoppedRecording' event
          try {
            stoppedRecording(
                state: data['state'],
                reason: data['reason'],
                parameters: {'showAlert': showAlert});
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling stoppedRecording event: $error');
            }
          }
        });

        socket.value!.on('hostRequestResponse', (data) async {
          // Handle 'hostRequestResponse' event
          try {
            hostRequestResponse(
                requestResponse: data['requestResponse'],
                parameters: {
                  ...getAllParams(),
                  ...mediaSFUFunctions(),
                });
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling hostRequestResponse event: $error');
            }
          }
        });

        socket.value!.on('pollUpdated', (data) async {
          try {
            await pollUpdated(
              data: data,
              parameters: {
                ...getAllParams(),
                ...mediaSFUFunctions(),
              },
            );
          } catch (error) {
            if (kDebugMode) {
              print('Error handling pollUpdated event: $error');
            }
          }
        });

        socket.value!.on('breakoutRoomUpdated', (data) async {
          try {
            await breakoutRoomUpdated(
              data: data,
              parameters: {
                ...getAllParams(),
                ...mediaSFUFunctions(),
              },
            );
          } catch (error) {
            if (kDebugMode) {
              print('Error handling breakoutRoomUpdated event: $error');
            }
          }
        });

        await joinroom(
          socket: socket.value!,
          roomName: roomName.value,
          islevel: islevel.value,
          member: member.value,
          sec: apiToken,
          apiUserName: apiUserName,
        );

        await receiveRoomMessages(socket: socket.value!, parameters: {
          'roomName': roomName.value,
          'messages': messages.value,
          'updateMessages': updateMessages,
        });

        prepopulateUserMedia(
            name: hostLabel.value,
            parameters: {...getAllParams(), ...mediaSFUFunctions()});

        return socket.value!;
      } else {
        return socket.value!;
      }
    }

    if (validated) {
      updateAllVideoStreams([
        {
          'producerId': 'youyou',
          'stream': null,
          'id': 'youyou',
          'name': 'youyou'
        }
      ]);

      updateStreamNames([
        {'id': 'youyou', 'name': 'youyou'}
      ]);

      Future<void> connectAndAddSocketMethods() async {
        socket.value = await connectsocket(
          apiUserName.value,
          '',
          apiToken.value,
          link.value,
        );
      }

      try {
        if (!widget.useLocalUIMode) {
          updateIsLoadingModalVisible(true);
          connectAndAddSocketMethods().then((_) {
            startMeetingProgressTimer(
                startTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                parameters: {
                  ...getAllParams(),
                  ...mediaSFUFunctions(),
                });
            updateIsLoadingModalVisible(false);
          }).catchError((error, stackTrace) {
            updateIsLoadingModalVisible(false);
            if (kDebugMode) {
              // print('error in startMeetingProgressTimer: $error');
            }
          });
        } else {
          updateIsLoadingModalVisible(false);
          io.Socket socket_ = io.io("https://example.com", <String, dynamic>{
            'transports': ['websocket'],
          });
          updateSocket(socket_);
        }
      } catch (error) {
        if (kDebugMode) {
          // print('error in connectAndAddSocketMethods: $error');
        }
        updateIsLoadingModalVisible(false);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // If using seed data, generate random participants and messages
    if (widget.useSeed) {
      try {
        updateMember(widget.seedData['member']!);
        updateParticipants(widget.seedData['participants']!);
        updateParticipantsCounter(widget.seedData['participants']!.length);
        updateFilteredParticipants(widget.seedData['participants']!);
        updateMessages(widget.seedData['messages']!);
        updateEventType(widget.seedData['eventType']!);
        updateRequestList(widget.seedData['requests']!);
        updateWaitingRoomList(widget.seedData['waitingList']!);
        updateWaitingRoomCounter(widget.seedData['waitingList']!.length);
      } catch (error) {
        if (kDebugMode) {
          print('Error setting seed data: $error');
        }
      }
    }

    if (widget.useLocalUIMode) {
      updateValidated(true);
    }

    isPortrait.addListener(_handleOrientationChange);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Top: true adjusts for iOS status bar, ignores for other platforms
      top: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Makes status bar transparent
          statusBarIconBrightness:
              Brightness.light, // Sets status bar icons to light color
        ),
        child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            // Check if the device is in landscape mode
            isPortrait.value = orientation == Orientation.portrait;
            return Scaffold(
              body: _buildRoomInterface(),
              resizeToAvoidBottomInset: false,
            );
          },
        ),
      ),
    );
  }

  Widget buildEventRoom(BuildContext context) {
    initializeRecordButton();
    initializeControlButtons();
    initializeControlChatButtons();
    initializeControlBroadcastButtons();

    return validated
        ? MainContainerComponent(
            backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
            children: [
              MainAspectComponent(
                backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
                updateIsWideScreen: updateIsWideScreen,
                updateIsMediumScreen: updateIsMediumScreen,
                updateIsSmallScreen: updateIsSmallScreen,
                defaultFraction: 1 - controlHeight.value,
                showControls: eventType.value == 'webinar' ||
                    eventType.value == 'conference',
                children: [
                  ValueListenableBuilder<Map<String, double>>(
                      valueListenable: componentSizes,
                      builder: (context, componentSizes, child) {
                        return MainScreenComponent(
                          doStack: true,
                          mainSize: mainHeightWidth,
                          updateComponentSizes: updateComponentSizes,
                          defaultFraction: 1 - controlHeight.value,
                          showControls: eventType.value == 'webinar' ||
                              eventType.value == 'conference',
                          children: [
                            ValueListenableBuilder<Map<String, int>>(
                              valueListenable: gridSizes,
                              builder: (context, gridSizes, child) {
                                return MainGridComponent(
                                  height: componentSizes['mainHeight'] ?? 0,
                                  width: componentSizes['mainWidth'] ?? 0,
                                  backgroundColor:
                                      const Color.fromRGBO(217, 227, 234, 0.99),
                                  mainSize: mainHeightWidth,
                                  showAspect: mainHeightWidth > 0,
                                  timeBackgroundColor: recordState == 'green'
                                      ? Colors.green
                                      : recordState == 'yellow'
                                          ? Colors.yellow
                                          : Colors.red,
                                  meetingProgressTime:
                                      meetingProgressTime.value,
                                  showTimer: true,
                                  children: [
                                    FlexibleVideo(
                                      backgroundColor: const Color.fromRGBO(
                                          217, 227, 234, 0.99),
                                      customWidth:
                                          componentSizes['mainWidth'] ?? 0,
                                      customHeight:
                                          componentSizes['mainHeight'] ?? 0,
                                      rows: 1,
                                      columns: 1,
                                      componentsToRender: mainGridStream,
                                      showAspect: mainGridStream.isNotEmpty,
                                    ),
                                    ControlButtonsComponentTouch(
                                      buttons: controlBroadcastButtons,
                                      direction: 'vertical',
                                      showAspect:
                                          eventType.value == 'broadcast',
                                      location: 'bottom',
                                      position: 'right',
                                    ),
                                    ControlButtonsComponentTouch(
                                      buttons: recordButton,
                                      direction: 'horizontal',
                                      showAspect:
                                          eventType.value == 'broadcast' &&
                                              !showRecordButtons.value &&
                                              islevel.value == '2',
                                      location: 'bottom',
                                      position: 'middle',
                                    ),
                                    ControlButtonsComponentTouch(
                                      buttons: recordButtons,
                                      direction: 'horizontal',
                                      showAspect:
                                          eventType.value == 'broadcast' &&
                                              showRecordButtons.value &&
                                              islevel.value == '2',
                                      location: 'bottom',
                                      position: 'middle',
                                    ),
                                    ValueListenableBuilder<String>(
                                        valueListenable: meetingProgressTime,
                                        builder: (context, meetingProgressTime,
                                            child) {
                                          return MeetingProgressTimer(
                                            meetingProgressTime:
                                                meetingProgressTime,
                                            initialBackgroundColor:
                                                recordState == 'green'
                                                    ? Colors.green
                                                    : recordState == 'yellow'
                                                        ? Colors.yellow
                                                        : Colors.red,
                                            showTimer: true,
                                          );
                                        }),
                                  ],
                                );
                              },
                            ),
                            ValueListenableBuilder<Map<String, int>>(
                                valueListenable: gridSizes,
                                builder: (context, gridSizes, child) {
                                  return OtherGridComponent(
                                    height: componentSizes['otherHeight'] ?? 0,
                                    width: componentSizes['otherWidth'] ?? 0,
                                    backgroundColor: const Color.fromRGBO(
                                        217, 227, 234, 0.99),
                                    showAspect:
                                        mainHeightWidth == 100 ? false : true,
                                    timeBackgroundColor: recordState == 'green'
                                        ? Colors.green
                                        : recordState == 'yellow'
                                            ? Colors.yellow
                                            : Colors.red,
                                    showTimer:
                                        mainHeightWidth == 0 ? true : false,
                                    meetingProgressTime:
                                        meetingProgressTime.value,
                                    children: [
                                      AudioGrid(
                                        componentsToRender:
                                            audioOnlyStreams.value,
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                          top: doPaginate.value
                                              ? paginationDirection.value ==
                                                      'horizontal'
                                                  ? paginationHeightWidth.value
                                                      .toDouble()
                                                  : 0
                                              : 0,
                                          left: doPaginate.value
                                              ? paginationDirection.value ==
                                                      'vertical'
                                                  ? paginationHeightWidth.value
                                                      .toDouble()
                                                  : 0
                                              : 0,
                                        ),
                                        child: FlexibleGrid(
                                          customWidth: gridSizes['gridWidth']
                                                  ?.toDouble() ??
                                              0,
                                          customHeight: gridSizes['gridHeight']
                                                  ?.toDouble() ??
                                              0,
                                          rows: gridRows.value,
                                          columns: gridCols.value,
                                          componentsToRender:
                                              otherGridStreams[0],
                                          backgroundColor: const Color.fromRGBO(
                                              217, 227, 234, 0.99),
                                          showAspect: addGrid.value &&
                                              otherGridStreams[0].isNotEmpty,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                          top: gridSizes['gridHeight']
                                                  ?.toDouble() ??
                                              0 +
                                                  (doPaginate.value
                                                      ? paginationDirection
                                                                  .value ==
                                                              'horizontal'
                                                          ? paginationHeightWidth
                                                              .value
                                                              .toDouble()
                                                          : 0
                                                      : 0),
                                          left: doPaginate.value
                                              ? paginationDirection.value ==
                                                      'vertical'
                                                  ? paginationHeightWidth.value
                                                      .toDouble()
                                                  : 0
                                              : 0,
                                        ),
                                        child: FlexibleGrid(
                                          customWidth: gridSizes['altGridWidth']
                                                  ?.toDouble() ??
                                              0,
                                          customHeight:
                                              gridSizes['altGridHeight']
                                                      ?.toDouble() ??
                                                  0,
                                          rows: altGridRows.value,
                                          columns: altGridCols.value,
                                          componentsToRender:
                                              otherGridStreams[1],
                                          backgroundColor: const Color.fromRGBO(
                                              217, 227, 234, 0.99),
                                          showAspect: addAltGrid.value &&
                                              otherGridStreams[1].isNotEmpty,
                                        ),
                                      ),
                                      ControlButtonsComponentTouch(
                                        buttons: controlChatButtons,
                                        position: "right",
                                        location: "bottom",
                                        direction: "vertical",
                                        showAspect: eventType.value == 'chat',
                                      ),
                                      ValueListenableBuilder<String>(
                                          valueListenable: meetingProgressTime,
                                          builder: (context,
                                              meetingProgressTime, child) {
                                            return MeetingProgressTimer(
                                              meetingProgressTime:
                                                  meetingProgressTime,
                                              initialBackgroundColor:
                                                  recordState == 'green'
                                                      ? Colors.green
                                                      : recordState == 'yellow'
                                                          ? Colors.yellow
                                                          : Colors.red,
                                              showTimer: mainHeightWidth == 0
                                                  ? true
                                                  : false,
                                            );
                                          }),
                                      Visibility(
                                        visible: doPaginate.value,
                                        child: SizedBox(
                                          width: paginationDirection.value ==
                                                  'horizontal'
                                              ? double.infinity
                                              : paginationHeightWidth.value
                                                  .toDouble(),
                                          height: paginationDirection.value ==
                                                  'horizontal'
                                              ? paginationHeightWidth.value
                                                  .toDouble()
                                              : double.infinity,
                                          child: Pagination(
                                            totalPages: numberPages.value,
                                            currentUserPage:
                                                currentUserPage.value,
                                            showAspect: doPaginate.value,
                                            paginationHeight:
                                                paginationHeightWidth.value
                                                    .toDouble(),
                                            direction:
                                                paginationDirection.value,
                                            parameters: {
                                              ...getAllParams(),
                                              ...mediaSFUFunctions()
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          ],
                        );
                      }),
                ],
              ),
              Visibility(
                visible: eventType.value == 'webinar' ||
                    eventType.value == 'conference',
                child: ValueListenableBuilder<double>(
                  valueListenable: controlHeight,
                  builder: (context, controlHeight, child) {
                    return SubAspectComponent(
                        backgroundColor:
                            const Color.fromRGBO(217, 227, 234, 0.99),
                        showControls: eventType.value == 'webinar' ||
                            eventType.value == 'conference',
                        defaultFractionSub: 40, //40 pixels
                        children: [
                          ControlButtonsComponent(
                            buttons: controlButtons,
                            buttonColor:
                                const Color.fromARGB(255, 234, 178, 178),
                            buttonBackgroundColor: const {
                              'default': Colors.transparent,
                              'pressed': Colors.transparent,
                            },
                            alignment: MainAxisAlignment.spaceBetween,
                            vertical: false, // Set to true for vertical layout
                          ),
                        ]);
                  },
                ),
              ),
            ],
          )
        : widget.PrejoinPage != null
            ? renderPrejoinPage() ?? renderWelcomePage()
            : renderWelcomePage();
  }

  Widget renderWelcomePage() {
    return WelcomePage(
      parameters: {
        'showAlert': showAlert,
        'isLoadingModalVisible': isLoadingModalVisible,
        'updateIsLoadingModalVisible': updateIsLoadingModalVisible,
        'onWeb': kIsWeb,
        'eventType': eventType.value,
        'connectSocket': connectSocket,
        'socket': socket.value,
        'updateSocket': updateSocket,
        'updateValidated': updateValidated,
        'updateApiUserName': updateApiUserName,
        'updateApiToken': updateApiToken,
        'updateLink': updateLink,
        'updateRoomName': updateRoomName,
        'updateMember': updateMember,
        'validated': validated,
      },
    );
  }

  Widget? renderPrejoinPage() {
    if (widget.PrejoinPage != null) {
      return widget.PrejoinPage!(
        parameters: {
          'showAlert': showAlert,
          'isLoadingModalVisible': isLoadingModalVisible,
          'updateIsLoadingModalVisible': updateIsLoadingModalVisible,
          'onWeb': kIsWeb,
          'eventType': eventType.value,
          'connectSocket': connectSocket,
          'socket': socket.value,
          'updateSocket': updateSocket,
          'updateValidated': updateValidated,
          'updateApiUserName': updateApiUserName,
          'updateApiToken': updateApiToken,
          'updateLink': updateLink,
          'updateRoomName': updateRoomName,
          'updateMember': updateMember,
          'validated': validated,
        },
        credentials: widget.credentials,
      );
    } else {
      return Container();
    }
  }

  Widget _buildRoomInterface() {
    return Stack(
      children: [
        buildEventRoom(context),

        _buildMenuModal(), // Add Menu Modal
        _buildDisplaySettingsModal(), // Add Display Settings Modal
        _buildDisplaySettingsModal(), // Add Display Settings Modal
        _buildMediaSettingsModal(), // Add Media Settings Modal
        _buildEventSettingsModal(), // Add Event Settings Modal
        _buildRequestsModal(), // Add Requests Modal
        _buildWaitingModal(), // Add Waiting Room Modal
        _buildShareEventModal(), // Add Share Event Modal
        _buildRecordingModal(), // Add Recording Modal
        _buildCoHostModal(), // Add Co-Host Modal
        _buildParticipantsModal(), // Add Participants Modal
        _buildMessagesModal(), // Add Messages Modal
        _buildPollModal(), // Add Polls Modal
        _buildBreakoutRoomsModal(), // Add Breakout Rooms Modal

        _buildConfirmExitModal(), // Add Confirm Exit Modal

        _buildAlertModal(), // Add Alert Modal
        _buildConfirmHereModal(), // Add Confirm Here Modal
        _buildLoadingModal(), // Add Loading Modal
      ],
    );
  }

  Widget _buildMenuModal() {
    initializeRecordButtons();
    initializeCustomMenuButtons();

    return ValueListenableBuilder<bool>(
      valueListenable: isMenuModalVisible,
      builder: (context, isMenuModalVisible, child) {
        return MenuModal(
          backgroundColor: const Color.fromRGBO(181, 233, 229, 0.97),
          isVisible: isMenuModalVisible,
          updateIsMenuModalVisible: updateIsMenuModalVisible,
          onClose: () => updateIsMenuModalVisible(false),
          customButtons: customMenuButtons,
          roomName: roomName.value,
          adminPasscode: adminPasscode.value,
          islevel: islevel.value,
        );
      },
    );
  }

  Widget _buildRecordingModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isRecordingModalVisible,
      builder: (context, isRecordingModalVisible, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: recordUIChanged,
          builder: (context, recordUIChanged, child) {
            return RecordingModal(
              backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
              isRecordingModalVisible: isRecordingModalVisible,
              onClose: () {
                updateIsRecordingModalVisible(false);
              },
              startRecording: startRecording,
              confirmRecording: confirmRecording,
              parameters: {
                ...getAllParams(),
                ...mediaSFUFunctions(),
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isRequestsModalVisible,
      builder: (context, isRequestsVisible, child) {
        return ValueListenableBuilder<List<dynamic>>(
          valueListenable: filteredRequestList,
          builder: (context, filteredRequestList, child) {
            return RequestsModal(
              backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
              isRequestsModalVisible: isRequestsVisible,
              onRequestClose: () {
                updateIsRequestsModalVisible(false);
              },
              requestCounter: requestCounter.value,
              onRequestFilterChange: onRequestFilterChange,
              updateRequestList: updateRequestList,
              requestList: filteredRequestList,
              roomName: roomName.value,
              socket: socket.value,
              parameters: {
                'updateRequestCounter': updateRequestCounter,
                'updateRequestFilter': updateRequestFilter,
                'updateRequestList': updateRequestList,
              },
            );
          },
        );
      },
    );
  }

  Widget _buildWaitingModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isWaitingModalVisible,
      builder: (context, isWaitingModalVisible, child) {
        return ValueListenableBuilder<List<dynamic>>(
          valueListenable: filteredWaitingRoomList,
          builder: (context, filteredWaitingRoomList, child) {
            return WaitingRoomModal(
              backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
              isWaitingModalVisible: isWaitingModalVisible,
              onWaitingRoomClose: () {
                updateIsWaitingModalVisible(false);
              },
              waitingRoomCounter: waitingRoomCounter.value,
              onWaitingRoomFilterChange: onWaitingRoomFilterChange,
              waitingRoomList: filteredWaitingRoomList,
              updateWaitingList: updateWaitingRoomList,
              roomName: roomName.value,
              socket: socket.value,
              parameters: {
                'updateWaitingRoomCounter': updateWaitingRoomCounter,
                'updateWaitingRoomFilter': updateWaitingRoomFilter,
                'updateWaitingRoomList': updateWaitingRoomList,
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDisplaySettingsModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isDisplaySettingsModalVisible,
      builder: (context, isDisplaySettingsVisible, child) {
        return DisplaySettingsModal(
          backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
          isDisplaySettingsModalVisible: isDisplaySettingsVisible,
          onDisplaySettingsClose: () {
            updateIsDisplaySettingsModalVisible(false);
          },
          parameters: {
            ...getAllParams(),
            ...mediaSFUFunctions(),
          },
        );
      },
    );
  }

  Widget _buildEventSettingsModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isSettingsModalVisible,
      builder: (context, isSettingsVisible, child) {
        return EventSettingsModal(
          backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
          isEventSettingsModalVisible: isSettingsVisible,
          onEventSettingsClose: () {
            updateIsSettingsModalVisible(false);
          },
          parameters: {
            ...getAllParams(),
            ...mediaSFUFunctions(),
          },
        );
      },
    );
  }

  Widget _buildCoHostModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isCoHostModalVisible,
      builder: (context, isCoHostVisible, child) {
        return CoHostModal(
          isCoHostModalVisible: isCoHostVisible,
          onCoHostClose: () {
            updateIsCoHostModalVisible(false);
          },
          currentCohost: coHost.value,
          participants: participants.value,
          coHostResponsibility: coHostResponsibility.value,
          parameters: {
            'updateCoHost': updateCoHost,
            'updateCoHostResponsibility': updateCoHostResponsibility,
            'updateIsCoHostModalVisible': updateIsCoHostModalVisible,
            'showAlert': showAlert,
            'coHost': coHost.value,
            'coHostResponsibility': coHostResponsibility.value,
            'roomName': roomName.value,
            'member': member.value,
            'socket': socket.value,
          },
        );
      },
    );
  }

  Widget _buildParticipantsModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isParticipantsModalVisible,
      builder: (context, isParticipantsVisible, child) {
        return ValueListenableBuilder<List<dynamic>>(
          valueListenable: filteredParticipants,
          builder: (context, filteredParticipants, child) {
            return ParticipantsModal(
              backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
              isParticipantsModalVisible: isParticipantsVisible,
              onParticipantsClose: () {
                updateIsParticipantsModalVisible(false);
              },
              participantsCounter: participantsCounter.value,
              onParticipantsFilterChange: onParticipantsFilterChange,
              parameters: {
                'updateParticipants': updateParticipants,
                'updateIsParticipantsModalVisible':
                    updateIsParticipantsModalVisible,
                'updateDirectMessageDetails': updateDirectMessageDetails,
                'updateStartDirectMessage': updateStartDirectMessage,
                'updateIsMessagesModalVisible': updateIsMessagesModalVisible,
                'showAlert': showAlert,
                'participants': filteredParticipants,
                'roomName': roomName.value,
                'islevel': islevel.value,
                'member': member.value,
                'coHostResponsibility': coHostResponsibility.value,
                'coHost': coHost.value,
                'eventType': eventType.value,
                'startDirectMessage': startDirectMessage.value,
                'directMessageDetails': directMessageDetails.value,
                'socket': socket.value,
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMessagesModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isMessagesModalVisible,
      builder: (context, isMessagesVisible, child) {
        return ValueListenableBuilder<List<dynamic>>(
          valueListenable: messages,
          builder: (context, messages, child) {
            return MessagesModal(
              backgroundColor: eventType.value == 'webinar' ||
                      eventType.value == 'conference'
                  ? const Color(0xFFF5F5F5)
                  : const Color.fromRGBO(255, 255, 255, 0.25),
              isMessagesModalVisible: isMessagesVisible,
              onMessagesClose: () {
                updateIsMessagesModalVisible(false);
              },
              messages: messages,
              parameters: {
                'updateIsMessagesModalVisible': updateIsMessagesModalVisible,
                'participantsAll': participantsAll.value,
                'youAreHost': youAreHost.value,
                'eventType': eventType.value,
                'chatSetting': chatSetting.value,
                'member': member.value,
                'islevel': islevel.value,
                'coHostResponsibility': coHostResponsibility.value,
                'coHost': coHost.value,
                'showAlert': showAlert,
                'startDirectMessage': startDirectMessage.value,
                'updateStartDirectMessage': updateStartDirectMessage,
                'directMessageDetails': directMessageDetails.value,
                'updateDirectMessageDetails': updateDirectMessageDetails,
                'socket': socket.value,
                'roomName': roomName.value,
                'youAreCoHost': youAreCoHost.value
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMediaSettingsModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isMediaSettingsModalVisible,
      builder: (context, isMediaSettingsVisible, child) {
        return MediaSettingsModal(
          backgroundColor: const Color.fromARGB(247, 210, 219, 218),
          isMediaSettingsModalVisible: isMediaSettingsVisible,
          onMediaSettingsClose: () {
            updateIsMediaSettingsModalVisible(false);
          },
          parameters: {
            ...getAllParams(),
            ...mediaSFUFunctions(),
            'onWeb': kIsWeb,
            'device': device.value,
            'socket': socket.value,
            'showAlert': showAlert,
            'checkPermission': checkPermission,
            'streamSuccessVideo': streamSuccessVideo,
            'hasCameraPermission': hasCameraPermission.value,
            'requestPermissionCamera': requestPermissionCamera,
            'checkMediaPermission': !kIsWeb,
            'streamSuccessAudioSwitch': streamSuccessAudioSwitch,
            'hasAudioPermission': hasAudioPermission.value,
            'requestPermissionAudio': requestPermissionAudio,
            'streamSuccessAudio': streamSuccessAudio,
          },
        );
      },
    );
  }

  Widget _buildConfirmExitModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isConfirmExitModalVisible,
      builder: (context, isConfirmExitVisible, child) {
        return ConfirmExitModal(
          isConfirmExitModalVisible: isConfirmExitVisible,
          onConfirmExitClose: () {
            updateIsConfirmExitModalVisible(false);
          },
          parameters: {
            'islevel': islevel.value,
            'updateIsConfirmExitModalVisible': updateIsConfirmExitModalVisible,
            'isConfirmExitModalVisible': isConfirmExitModalVisible,
            'showAlert': showAlert,
            'roomName': roomName.value,
            'member': member.value,
            'socket': socket.value,
          },
        );
      },
    );
  }

  Widget _buildConfirmHereModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isConfirmHereModalVisible,
      builder: (context, isConfirmHereModalVisible, child) {
        return ConfirmHereModal(
          backgroundColor: const Color.fromRGBO(181, 233, 229, 0.97),
          isConfirmHereModalVisible: isConfirmHereModalVisible,
          // updateIsConfirmHereModalVisible: updateIsConfirmHereModalVisible,
          onConfirmHereClose: () {
            updateIsConfirmHereModalVisible(false);
          },
          parameters: {
            'updateIsConfirmHereModalVisible': updateIsConfirmHereModalVisible,
            'isConfirmHereModalVisible': isConfirmHereModalVisible,
            'showAlert': showAlert,
            'roomName': roomName.value,
            'socket': socket.value,
            'member': member.value,
          },
        );
      },
    );
  }

  Widget _buildShareEventModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isShareEventModalVisible,
      builder: (context, isShareEventModalVisible, child) {
        return ShareEventModal(
          isShareEventModalVisible: isShareEventModalVisible,
          // updateIsShareEventModalVisible: updateIsShareEventModalVisible,
          onShareEventClose: () {
            updateIsShareEventModalVisible(false);
          },
          onCopyMeetingId: () {},
          onCopyMeetingPasscode: () {},
          onCopyShareLink: () {},
          roomName: roomName.value,
          islevel: islevel.value,
          adminPasscode: adminPasscode.value,
        );
      },
    );
  }

  Widget _buildPollModal() {
    return ValueListenableBuilder<bool>(
        valueListenable: isPollModalVisible,
        builder: (context, isPollVisible, child) {
          if (!isPollVisible) {
            return const SizedBox.shrink();
          }
          return ValueListenableBuilder<List<dynamic>>(
            valueListenable: polls,
            builder: (context, polls, child) {
              return PollModal(
                isPollModalVisible: isPollVisible,
                onClose: () {
                  updateIsPollModalVisible(false);
                },
                parameters: {
                  ...getAllParams(),
                  ...mediaSFUFunctions(),
                  'socket': socket.value,
                  'showAlert': showAlert,
                },
              );
            },
          );
        });
  }

  Widget _buildBreakoutRoomsModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isBreakoutRoomsModalVisible,
      builder: (context, isBreakoutRoomsVisible, child) {
        if (!isBreakoutRoomsVisible) {
          return const SizedBox
              .shrink(); // Return an empty widget if the modal is not visible
        }
        return ValueListenableBuilder<List<dynamic>>(
          valueListenable: breakoutRooms,
          builder: (context, breakoutRooms, child) {
            return ValueListenableBuilder<List<dynamic>>(
              valueListenable: filteredParticipants,
              builder: (context, filteredParticipants, child) {
                return BreakoutRoomsModal(
                  backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
                  isVisible: isBreakoutRoomsVisible,
                  onBreakoutRoomsClose: () {
                    updateIsBreakoutRoomsModalVisible(false);
                  },
                  parameters: {
                    ...getAllParams(),
                    ...mediaSFUFunctions(),
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAlertModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: alertVisible,
      builder: (context, isVisible, child) {
        if (!isVisible) {
          return const SizedBox(); // or return null or empty container based on your requirement
        }
        return AlertComponent(
          visible: isVisible,
          message: alertMessage.value,
          type: alertType.value,
          duration: alertDuration.value,
          onHide: () {
            updateAlertVisible(false);
          },
          textColor: const Color(0xFFFFFFFF),
        );
      },
    );
  }

  Widget _buildLoadingModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoadingModalVisible,
      builder: (context, isLoadingModalVisible, child) {
        return LoadingModal(
          isVisible: isLoadingModalVisible,
          backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
          displayColor: Colors.black,
        );
      },
    );
  }
}
