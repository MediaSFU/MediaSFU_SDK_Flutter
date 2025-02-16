// ignore_for_file: empty_catches, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../misc_components/prejoin_page.dart';
// import 'package:permission_handler/permission_handler.dart'; // handle permissions manually
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import 'package:flutter/services.dart'; // Import Services for platform-specific services
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

//initial values
import '../../methods/utils/initial_values.dart' show initialValuesState;

//import components for display (samples)
import '../display_components/meeting_progress_timer.dart'
    show MeetingProgressTimer, MeetingProgressTimerOptions;
import '../display_components/main_aspect_component.dart'
    show MainAspectComponent, MainAspectComponentOptions;
import '../display_components/loading_modal.dart'
    show LoadingModal, LoadingModalOptions;
import '../display_components/control_buttons_component.dart'
    show ControlButtonsComponent, ControlButtonsComponentOptions;
import '../display_components/control_buttons_alt_component.dart'
    show ControlButtonsAltComponent, ControlButtonsAltComponentOptions;
import '../display_components/other_grid_component.dart'
    show OtherGridComponent, OtherGridComponentOptions;
import '../display_components/main_screen_component.dart'
    show MainScreenComponent, MainScreenComponentOptions;
import '../display_components/main_grid_component.dart'
    show MainGridComponent, MainGridComponentOptions;
import '../display_components/sub_aspect_component.dart'
    show SubAspectComponent, SubAspectComponentOptions;
import '../display_components/main_container_component.dart'
    show MainContainerComponent, MainContainerComponentOptions;
import '../display_components/alert_component.dart'
    show AlertComponent, AlertComponentOptions;
import '../menu_components/menu_modal.dart' show MenuModal, MenuModalOptions;
import '../recording_components/recording_modal.dart'
    show RecordingModal, RecordingModalOptions;
import '../requests_components/requests_modal.dart'
    show RequestsModal, RequestsModalOptions;
import '../waiting_components/waiting_modal.dart'
    show WaitingRoomModal, WaitingRoomModalOptions;
import '../display_settings_components/display_settings_modal.dart'
    show DisplaySettingsModal, DisplaySettingsModalOptions;
import '../event_settings_components/event_settings_modal.dart'
    show EventSettingsModal, EventSettingsModalOptions;
import '../co_host_components/co_host_modal.dart'
    show CoHostModal, CoHostModalOptions;
import '../participants_components/participants_modal.dart'
    show ParticipantsModal, ParticipantsModalOptions;
import '../message_components/messages_modal.dart'
    show MessagesModal, MessagesModalOptions;
import '../media_settings_components/media_settings_modal.dart'
    show MediaSettingsModal, MediaSettingsModalOptions;
import '../exit_components/confirm_exit_modal.dart'
    show ConfirmExitModal, ConfirmExitModalOptions;
import '../misc_components/confirm_here_modal.dart'
    show ConfirmHereModal, ConfirmHereModalOptions;
import '../misc_components/share_event_modal.dart'
    show ShareEventModal, ShareEventModalOptions;
import '../misc_components/welcome_page.dart'
    show WelcomePage, WelcomePageOptions;

import '../polls_components/poll_modal.dart' show PollModal, PollModalOptions;
import '../breakout_components/breakout_rooms_modal.dart'
    show BreakoutRoomsModal, BreakoutRoomsModalOptions;

// Pagination and display of media (samples)
import '../display_components/pagination.dart'
    show Pagination, PaginationOptions;
import '../display_components/flexible_grid.dart'
    show FlexibleGrid, FlexibleGridOptions;
import '../display_components/flexible_video.dart'
    show FlexibleVideo, FlexibleVideoOptions;
import '../display_components/audio_grid.dart' show AudioGrid, AudioGridOptions;

// Import methods for control (samples)
import '../../methods/menu_methods/launch_menu_modal.dart'
    show launchMenuModal, LaunchMenuModalOptions;
import '../../methods/recording_methods/launch_recording.dart'
    show launchRecording, LaunchRecordingOptions;
import '../../methods/recording_methods/start_recording.dart'
    show startRecording;
import '../../methods/recording_methods/confirm_recording.dart'
    show confirmRecording;
import '../../methods/waiting_methods/launch_waiting.dart'
    show launchWaiting, LaunchWaitingOptions;
import '../../methods/co_host_methods/launch_co_host.dart'
    show launchCoHost, LaunchCoHostOptions;
import '../../methods/media_settings_methods/launch_media_settings.dart'
    show launchMediaSettings, LaunchMediaSettingsOptions;
import '../../methods/display_settings_methods/launch_display_settings.dart'
    show launchDisplaySettings, LaunchDisplaySettingsOptions;
import '../../methods/settings_methods/launch_settings.dart'
    show launchSettings, LaunchSettingsOptions;
import '../../methods/requests_methods/launch_requests.dart'
    show launchRequests, LaunchRequestsOptions;
import '../../methods/participants_methods/launch_participants.dart'
    show launchParticipants, LaunchParticipantsOptions;
import '../../methods/message_methods/launch_messages.dart'
    show launchMessages, LaunchMessagesOptions;
import '../../methods/exit_methods/launch_confirm_exit.dart'
    show launchConfirmExit, LaunchConfirmExitOptions;

import '../../methods/polls_methods/launch_poll.dart'
    show launchPoll, LaunchPollOptions;
import '../../methods/breakout_rooms_methods/launch_breakout_rooms.dart'
    show launchBreakoutRooms, LaunchBreakoutRoomsOptions;

// Mediasfu functions -- examples
import '../../sockets/socket_manager.dart'
    show connectSocket, connectLocalSocket;
import '../../methods/utils/join_room_on_media_sfu.dart'
    show joinRoomOnMediaSFU;
import '../../methods/utils/create_room_on_media_sfu.dart'
    show createRoomOnMediaSFU;
import '../../producer_client/producer_client_emits/join_room_client.dart'
    show joinRoomClient, JoinRoomClientOptions;
import '../../producers/producer_emits/join_local_room.dart'
    show joinLocalRoom, JoinLocalRoomOptions;
import '../../producer_client/producer_client_emits/update_room_parameters_client.dart'
    show updateRoomParametersClient, UpdateRoomParametersClientOptions;
import '../../producer_client/producer_client_emits/create_device_client.dart'
    show createDeviceClient, CreateDeviceClientOptions;

// Stream methods
import '../../methods/stream_methods/switch_video_alt.dart' show switchVideoAlt;
import '../../methods/stream_methods/click_video.dart'
    show clickVideo, ClickVideoOptions;
import '../../methods/stream_methods/click_audio.dart'
    show clickAudio, ClickAudioOptions;
import '../../methods/stream_methods/click_screen_share.dart'
    show clickScreenShare, ClickScreenShareOptions;

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
import '../../consumers/prepopulate_user_media.dart'
    show prepopulateUserMedia, PrepopulateUserMediaOptions;
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
import '../../consumers/on_screen_changes.dart'
    show onScreenChanges, OnScreenChangesOptions;
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
import '../../consumers/receive_room_messages.dart'
    show receiveRoomMessages, ReceiveRoomMessagesOptions;
import '../../methods/utils/format_number.dart' show formatNumber;
import '../../consumers/connect_ips.dart' show connectIps;
import '../../consumers/connect_local_ips.dart' show connectLocalIps;

import '../../methods/polls_methods/poll_updated.dart'
    show pollUpdated, PollUpdatedOptions;
import '../../methods/polls_methods/handle_create_poll.dart'
    show handleCreatePoll;
import '../../methods/polls_methods/handle_vote_poll.dart' show handleVotePoll;
import '../../methods/polls_methods/handle_end_poll.dart' show handleEndPoll;

import '../../methods/breakout_rooms_methods/breakout_room_updated.dart'
    show breakoutRoomUpdated, BreakoutRoomUpdatedOptions;

// Mediasfu functions
import '../../methods/utils/meeting_timer/start_meeting_progress_timer.dart'
    show startMeetingProgressTimer, StartMeetingProgressTimerOptions;
import '../../methods/recording_methods/update_recording.dart'
    show updateRecording, UpdateRecordingOptions;
import '../../methods/recording_methods/stop_recording.dart'
    show stopRecording, StopRecordingOptions;

import '../../producers/socket_receive_methods/user_waiting.dart'
    show userWaiting, UserWaitingOptions;
import '../../producers/socket_receive_methods/person_joined.dart'
    show personJoined, PersonJoinedOptions;
import '../../producers/socket_receive_methods/all_waiting_room_members.dart'
    show allWaitingRoomMembers, AllWaitingRoomMembersOptions;
import '../../producers/socket_receive_methods/room_record_params.dart'
    show roomRecordParams, RoomRecordParamsOptions;
import '../../producers/socket_receive_methods/ban_participant.dart'
    show banParticipant, BanParticipantOptions;
import '../../producers/socket_receive_methods/updated_co_host.dart'
    show updatedCoHost, UpdatedCoHostOptions;
import '../../producers/socket_receive_methods/participant_requested.dart'
    show participantRequested, ParticipantRequestedOptions;
import '../../producers/socket_receive_methods/screen_producer_id.dart'
    show screenProducerId, ScreenProducerIdOptions;
import '../../producers/socket_receive_methods/update_media_settings.dart'
    show updateMediaSettings, UpdateMediaSettingsOptions;
import '../../producers/socket_receive_methods/producer_media_paused.dart'
    show producerMediaPaused, ProducerMediaPausedOptions;
import '../../producers/socket_receive_methods/producer_media_resumed.dart'
    show producerMediaResumed, ProducerMediaResumedOptions;
import '../../producers/socket_receive_methods/producer_media_closed.dart'
    show producerMediaClosed, ProducerMediaClosedOptions;
import '../../producers/socket_receive_methods/control_media_host.dart'
    show controlMediaHost, ControlMediaHostOptions;
import '../../producers/socket_receive_methods/meeting_ended.dart'
    show meetingEnded, MeetingEndedOptions;
import '../../producers/socket_receive_methods/disconnect_user_self.dart'
    show disconnectUserSelf, DisconnectUserSelfOptions;
import '../../producers/socket_receive_methods/receive_message.dart'
    show receiveMessage, ReceiveMessageOptions;
import '../../producers/socket_receive_methods/meeting_time_remaining.dart'
    show meetingTimeRemaining, MeetingTimeRemainingOptions;
import '../../producers/socket_receive_methods/meeting_still_there.dart'
    show meetingStillThere, MeetingStillThereOptions;
import '../../producers/socket_receive_methods/start_records.dart'
    show startRecords, StartRecordsOptions;
import '../../producers/socket_receive_methods/re_initiate_recording.dart'
    show reInitiateRecording, ReInitiateRecordingOptions;
import '../../producers/socket_receive_methods/get_domains.dart'
    show getDomains;
import '../../producers/socket_receive_methods/update_consuming_domains.dart'
    show updateConsumingDomains, UpdateConsumingDomainsOptions;
import '../../producers/socket_receive_methods/recording_notice.dart'
    show recordingNotice, RecordingNoticeOptions;
import '../../producers/socket_receive_methods/time_left_recording.dart'
    show timeLeftRecording, TimeLeftRecordingOptions;
import '../../producers/socket_receive_methods/stopped_recording.dart'
    show stoppedRecording, StoppedRecordingOptions;
import '../../producers/socket_receive_methods/host_request_response.dart'
    show hostRequestResponse, HostRequestResponseOptions;
import '../../producers/socket_receive_methods/all_members.dart'
    show allMembers, AllMembersOptions;
import '../../producers/socket_receive_methods/all_members_rest.dart'
    show allMembersRest, AllMembersRestOptions;
import '../../producers/socket_receive_methods/disconnect.dart'
    show disconnect, DisconnectOptions;

import '../../consumers/resume_pause_audio_streams.dart'
    show resumePauseAudioStreams;
import '../../consumers/process_consumer_transports_audio.dart'
    show processConsumerTransportsAudio;

import '../../types/types.dart'
    show
        AllMembersData,
        AllMembersRestData,
        AltButton,
        AudioDecibels,
        BreakoutParticipant,
        BreakoutRoomUpdatedData,
        CoHostResponsibility,
        ComponentSizes,
        ConsumeSocket,
        ControlButton,
        CustomButton,
        DimensionConstraints,
        DispSpecs,
        EventType,
        GridSizes,
        MainSpecs,
        MeetingRoomParams,
        Message,
        Participant,
        Poll,
        PollUpdatedData,
        PreJoinPageType,
        ProducerOptionsType,
        ReceiveAllPipedTransportsOptions,
        ReceiveAllPipedTransportsType,
        RecordParameters,
        Request,
        RequestResponse,
        ResponseJoinLocalRoom,
        ResponseJoinRoom,
        ScreenState,
        SeedData,
        Settings,
        Stream,
        TransportType,
        UpdateConsumingDomainsData,
        UserRecordingParams,
        VidCons,
        WaitingRoomParticipant,
        WhiteboardUser,
        CreateMediaSFURoomOptions,
        JoinMediaSFURoomOptions,
        JoinRoomOnMediaSFUType,
        CreateRoomOnMediaSFUType;
import '../../methods/utils/create_response_join_room.dart'
    show createResponseJoinRoom, CreateResponseJoinRoomOptions;
import '../../methods/utils/mediasfu_parameters.dart' show MediasfuParameters;

class MediasfuConferenceOptions {
  PreJoinPageType? preJoinPageWidget;
  String? localLink;
  bool? connectMediaSFU;
  Credentials? credentials;
  bool? useLocalUIMode;
  SeedData? seedData;
  bool? useSeed;
  String? imgSrc;
  MediasfuParameters? sourceParameters;
  Function(MediasfuParameters?)? updateSourceParameters;
  bool? returnUI;
  CreateMediaSFURoomOptions? noUIPreJoinOptionsCreate;
  JoinMediaSFURoomOptions? noUIPreJoinOptionsJoin;
  JoinRoomOnMediaSFUType? joinMediaSFURoom;
  CreateRoomOnMediaSFUType? createMediaSFURoom;

  MediasfuConferenceOptions({
    this.preJoinPageWidget,
    this.localLink = '',
    this.connectMediaSFU = true,
    this.credentials,
    this.useLocalUIMode,
    this.seedData,
    this.useSeed,
    this.imgSrc,
    this.sourceParameters,
    this.updateSourceParameters,
    this.returnUI = true,
    this.noUIPreJoinOptionsCreate,
    this.noUIPreJoinOptionsJoin,
    this.joinMediaSFURoom = joinRoomOnMediaSFU,
    this.createMediaSFURoom = createRoomOnMediaSFU,
  });
}

/// `MediasfuConference` - A generic widget for initializing and managing Mediasfu functionalities.
///
/// ### Parameters:
/// - `options` (`MediasfuConferenceOptions`): Configuration options for setting up the widget.
///
/// ### Example Usage:
/// ```dart
/// MediasfuConference(
///   options: MediasfuConferenceOptions(
///     preJoinPageWidget: PreJoinPage(),
///     localLink: 'https://your-local-link.com',
///     connectMediaSFU: true,
///     credentials: myCredentials,
///     useLocalUIMode: true,
///     seedData: mySeedData,
///     useSeed: false,
///     imgSrc: "https://example.com/image.png",
///     sourceParameters: myMediasfuParameters,
///     updateSourceParameters: myUpdateSourceParameters,
///     returnUI: true,
///     noUIPreJoinOptionsCreate: myCreateOptions,
///     noUIPreJoinOptionsJoin: myJoinOptions,
///     joinRoomOnMediaSFUType: JoinRoomOnMediaSFUType.join,
///     createRoomOnMediaSFUType: CreateRoomOnMediaSFUType.create,
///   ),
/// );
/// ```

class MediasfuConference extends StatefulWidget {
  final MediasfuConferenceOptions options;

  const MediasfuConference({
    super.key,
    required this.options,
  });

  @override
  _MediasfuConferenceState createState() => _MediasfuConferenceState();
}

class _MediasfuConferenceState extends State<MediasfuConference> {
  bool validated = false;

  Map<String, dynamic> initialValues = initialValuesState;

  Future<ResponseJoinRoom> joinRoom(
      {required io.Socket? socket,
      required String roomName,
      required String islevel,
      String? member,
      String? sec,
      required String apiUserName}) async {
    try {
      // Emit the joinRoom event to the server using the provided socket
      ResponseJoinRoom data = await joinRoomClient(JoinRoomClientOptions(
          socket: socket,
          roomName: roomName,
          islevel: islevel,
          member: member!,
          sec: sec!,
          apiUserName: apiUserName));
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

  void onParticipantsFilterChange(String value) {
    // Filter the participants list based on the value
    if (value.isNotEmpty) {
      List<Participant> filteredParts = participants.value.where((participant) {
        return participant.name.toLowerCase().contains(value.toLowerCase());
      }).toList();
      filteredParticipants.value = filteredParts;
      participantsCounter.value = filteredParts.length;
    } else {
      filteredParticipants.value = participants.value;
      participantsCounter.value = participants.value.length;
    }
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

  void onWaitingRoomFilterChange(String value) {
    // Filter the waiting room list based on the value
    if (value.isNotEmpty) {
      final filteredList = waitingRoomList.value.where((room) =>
          room.name.toString().toLowerCase().contains(value.toLowerCase()));
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

  void _updateControlHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((eventType.value == EventType.webinar ||
          eventType.value == EventType.conference)) {
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

  void _updateRecordState() {
    if (recordStarted.value && !recordStopped.value) {
      if (!recordPaused.value) {
        if (!mounted) return;
        setState(() {
          recordState = 'red';
        });
      } else {
        if (!mounted) return;
        setState(() {
          recordState = 'yellow';
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        recordState = 'green';
      });
    }
  }

  String checkOrientation() {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? 'portrait'
        : 'landscape';
  }

  // Update states (variables) to initial values
  ValueNotifier<io.Socket?> socket = ValueNotifier<io.Socket?>(null);
  ValueNotifier<io.Socket?> localSocket = ValueNotifier<io.Socket?>(null);
  ValueNotifier<ResponseJoinRoom?> roomData =
      ValueNotifier<ResponseJoinRoom?>(ResponseJoinRoom());
  ValueNotifier<Device?> device = ValueNotifier<Device?>(null);

  ValueNotifier<String> apiKey = ValueNotifier<String>('');
  ValueNotifier<String> apiUserName = ValueNotifier<String>('');
  ValueNotifier<String> apiToken = ValueNotifier<String>('');
  ValueNotifier<String> link =
      ValueNotifier<String>(''); // Link to the media server

  // Room Details
  final ValueNotifier<String> roomName = ValueNotifier('');
  final ValueNotifier<String> member = ValueNotifier('');
  final ValueNotifier<String> adminPasscode =
      ValueNotifier(''); // Admin passcode
  final ValueNotifier<String> islevel = ValueNotifier("0");
  final ValueNotifier<String> coHost = ValueNotifier("No coHost");
  final ValueNotifier<List<CoHostResponsibility>> coHostResponsibility =
      ValueNotifier([
    CoHostResponsibility(name: 'participants', value: false, dedicated: false),
    CoHostResponsibility(name: 'media', value: false, dedicated: false),
    CoHostResponsibility(name: 'waiting', value: false, dedicated: false),
    CoHostResponsibility(name: 'chat', value: false, dedicated: false),
  ]);
  final ValueNotifier<bool> youAreCoHost = ValueNotifier(false);
  final ValueNotifier<bool> youAreHost = ValueNotifier(false);
  final ValueNotifier<bool> confirmedToRecord = ValueNotifier(false);
  final ValueNotifier<String> meetingDisplayType = ValueNotifier('media');
  final ValueNotifier<bool> meetingVideoOptimized = ValueNotifier(false);
  final ValueNotifier<EventType> eventType =
      ValueNotifier(EventType.conference);
  final ValueNotifier<List<Participant>> participants =
      ValueNotifier(<Participant>[]);
  final ValueNotifier<List<Participant>> filteredParticipants =
      ValueNotifier(<Participant>[]);
  ValueNotifier<int> participantsCounter = ValueNotifier<int>(0);
  ValueNotifier<String> participantsFilter = ValueNotifier<String>('');
  ValueNotifier<List<ConsumeSocket>> consumeSockets =
      ValueNotifier<List<ConsumeSocket>>([]);
  ValueNotifier<RtpCapabilities?> rtpCapabilities =
      ValueNotifier<RtpCapabilities?>(null);
  ValueNotifier<List<String>> roomRecvIPs = ValueNotifier<List<String>>([]);
  ValueNotifier<MeetingRoomParams?> meetingRoomParams =
      ValueNotifier<MeetingRoomParams?>(null);
  ValueNotifier<int> itemPageLimit = ValueNotifier<int>(4);
  ValueNotifier<bool> audioOnlyRoom = ValueNotifier<bool>(false);
  ValueNotifier<bool> addForBasic = ValueNotifier<bool>(false);
  ValueNotifier<int> screenPageLimit = ValueNotifier<int>(4);
  ValueNotifier<bool> shareScreenStarted = ValueNotifier<bool>(false);
  ValueNotifier<bool> shared = ValueNotifier<bool>(false);
  ValueNotifier<String> targetOrientation = ValueNotifier<String>('landscape');
  ValueNotifier<String> targetResolution = ValueNotifier<String>('sd');
  ValueNotifier<String> targetResolutionHost =
      ValueNotifier<String>('sd'); // Host resolution
  ValueNotifier<VidCons> vidCons = ValueNotifier<VidCons>(VidCons(
      width: DimensionConstraints(ideal: 640),
      height: DimensionConstraints(ideal: 480)));
  ValueNotifier<int> frameRate = ValueNotifier<int>(5);
  ValueNotifier<ProducerOptionsType?> hParams =
      ValueNotifier<ProducerOptionsType?>(null);
  ValueNotifier<ProducerOptionsType?> vParams =
      ValueNotifier<ProducerOptionsType?>(null);
  ValueNotifier<ProducerOptionsType?> screenParams =
      ValueNotifier<ProducerOptionsType?>(null);
  ValueNotifier<ProducerOptionsType?> aParams =
      ValueNotifier<ProducerOptionsType?>(null);

  // Recording Details
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
  // User Recording Parameters
  final ValueNotifier<UserRecordingParams> userRecordingParams =
      ValueNotifier<UserRecordingParams>(
    UserRecordingParams(
      mainSpecs: MainSpecs(
        mediaOptions: 'video',
        audioOptions: 'all',
        videoOptions: 'all',
        videoType: 'fullDisplay',
        videoOptimized: false,
        recordingDisplayType: 'media',
        addHLS: false,
      ),
      dispSpecs: DispSpecs(
        nameTags: true,
        backgroundColor: '#000000',
        nameTagsColor: '#ffffff',
        orientationVideo: 'portrait',
      ),
    ),
  );

// Recording States
  ValueNotifier<bool> canRecord = ValueNotifier<bool>(false);
  ValueNotifier<bool> startReport = ValueNotifier<bool>(false);
  ValueNotifier<bool> endReport = ValueNotifier<bool>(false);
  ValueNotifier<dynamic> recordTimerInterval = ValueNotifier<dynamic>(null);
  ValueNotifier<int?> recordStartTime = ValueNotifier<int?>(0);
  ValueNotifier<int> recordElapsedTime = ValueNotifier<int>(0);
  ValueNotifier<bool> isTimerRunning = ValueNotifier<bool>(false);
  ValueNotifier<bool> canPauseResume = ValueNotifier<bool>(false);
  ValueNotifier<int> recordChangeSeconds = ValueNotifier<int>(15000);
  ValueNotifier<int> pauseLimit = ValueNotifier<int>(0);
  ValueNotifier<int> pauseRecordCount = ValueNotifier<int>(0);
  ValueNotifier<bool> canLaunchRecord = ValueNotifier<bool>(true);
  ValueNotifier<bool> stopLaunchRecord = ValueNotifier<bool>(false);
  ValueNotifier<List<Participant>> participantsAll =
      ValueNotifier<List<Participant>>([]);

  final ValueNotifier<bool> firstAll = ValueNotifier(false);
  final ValueNotifier<bool> updateMainWindow = ValueNotifier(false);
  final ValueNotifier<bool> firstRound = ValueNotifier(false);
  final ValueNotifier<bool> landScaped = ValueNotifier(false);
  final ValueNotifier<bool> lockScreen = ValueNotifier(false);
  final ValueNotifier<String> screenId = ValueNotifier('');
  final ValueNotifier<List<Stream>> allVideoStreams = ValueNotifier([]);
  final ValueNotifier<List<Stream>> newLimitedStreams = ValueNotifier([]);
  final ValueNotifier<List<String>> newLimitedStreamsIDs = ValueNotifier([]);
  final ValueNotifier<List<String>> activeSounds = ValueNotifier([]);
  final ValueNotifier<String> screenShareIDStream = ValueNotifier('');
  final ValueNotifier<String> screenShareNameStream = ValueNotifier('');
  final ValueNotifier<String> adminIDStream = ValueNotifier('');
  final ValueNotifier<String> adminNameStream = ValueNotifier('');
  final ValueNotifier<List<Stream>> youYouStream = ValueNotifier([]);
  final ValueNotifier<List<String>> youYouStreamIDs = ValueNotifier([]);
  final ValueNotifier<MediaStream?> localStream = ValueNotifier(null);
  final ValueNotifier<bool> recordStarted = ValueNotifier(false);
  final ValueNotifier<bool> recordResumed = ValueNotifier(false);
  final ValueNotifier<bool> recordPaused = ValueNotifier(false);
  final ValueNotifier<bool> recordStopped = ValueNotifier(false);
  final ValueNotifier<bool> adminRestrictSetting = ValueNotifier(false);
  final ValueNotifier<String> videoRequestState = ValueNotifier('none');
  final ValueNotifier<int?> videoRequestTime = ValueNotifier(null);
  final ValueNotifier<bool> videoAction = ValueNotifier(false);
  final ValueNotifier<MediaStream?> localStreamVideo = ValueNotifier(null);
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
  final ValueNotifier<int?> audioRequestTime = ValueNotifier(null);
  final ValueNotifier<int?> screenRequestTime = ValueNotifier(null);
  final ValueNotifier<int?> chatRequestTime = ValueNotifier(null);
  final ValueNotifier<int> updateRequestIntervalSeconds = ValueNotifier(240);
  final ValueNotifier<List<String>> oldSoundIds = ValueNotifier([]);
  final ValueNotifier<String> hostLabel = ValueNotifier('Host');
  final ValueNotifier<bool> mainScreenFilled = ValueNotifier(false);
  final ValueNotifier<MediaStream?> localStreamScreen = ValueNotifier(null);
  final ValueNotifier<bool> screenAlreadyOn = ValueNotifier(false);
  final ValueNotifier<bool> chatAlreadyOn = ValueNotifier(false);
  final ValueNotifier<String> redirectURL = ValueNotifier('');
  final ValueNotifier<List<Stream>> oldAllStreams = ValueNotifier([]);
  final ValueNotifier<String> adminVidID = ValueNotifier('');
  final ValueNotifier<List<Stream>> streamNames = ValueNotifier([]);
  final ValueNotifier<List<Stream>> nonAlVideoStreams = ValueNotifier([]);
  final ValueNotifier<bool> sortAudioLoudness = ValueNotifier(false);
  final ValueNotifier<List<AudioDecibels>> audioDecibels = ValueNotifier([]);
  final ValueNotifier<List<Stream>> mixedAlVideoStreams = ValueNotifier([]);
  final ValueNotifier<List<Stream>> nonAlVideoStreamsMuted = ValueNotifier([]);
  final ValueNotifier<List<List<Stream>>> paginatedStreams = ValueNotifier([]);
  final ValueNotifier<MediaStream?> localStreamAudio = ValueNotifier(null);
  final ValueNotifier<String> defAudioID = ValueNotifier('');
  final ValueNotifier<String> userDefaultAudioInputDevice = ValueNotifier('');
  final ValueNotifier<String> userDefaultAudioOutputDevice = ValueNotifier('');
  final ValueNotifier<String> prevAudioInputDevice = ValueNotifier('');
  final ValueNotifier<String> prevVideoInputDevice = ValueNotifier('');
  final ValueNotifier<bool> audioPaused = ValueNotifier(false);
  final ValueNotifier<String> mainScreenPerson = ValueNotifier('');
  final ValueNotifier<bool> adminOnMainScreen = ValueNotifier(false);
  final ValueNotifier<List<ScreenState>> screenStates = ValueNotifier([
    ScreenState(
      mainScreenPerson: null,
      mainScreenProducerId: null,
      mainScreenFilled: false,
      adminOnMainScreen: false,
    ),
  ]);
  final ValueNotifier<List<ScreenState>> prevScreenStates = ValueNotifier([
    ScreenState(
      mainScreenPerson: null,
      mainScreenProducerId: null,
      mainScreenFilled: false,
      adminOnMainScreen: false,
    ),
  ]);
  final ValueNotifier<dynamic> updateDateState = ValueNotifier(null);
  final ValueNotifier<dynamic> lastUpdate = ValueNotifier(null);
  final ValueNotifier<int> nForReadjustRecord = ValueNotifier(0);
  final ValueNotifier<int> fixedPageLimit = ValueNotifier(4);
  final ValueNotifier<bool> removeAltGrid = ValueNotifier(false);
  final ValueNotifier<int> nForReadjust = ValueNotifier(0);
  final ValueNotifier<int> reorderInterval = ValueNotifier(30000);
  final ValueNotifier<int> fastReorderInterval = ValueNotifier(10000);
  final ValueNotifier<int> lastReorderTime = ValueNotifier(0);
  final ValueNotifier<List<Stream>> audStreamNames = ValueNotifier([]);
  final ValueNotifier<int> currentUserPage = ValueNotifier(0);
  double mainHeightWidth = 0;
  final ValueNotifier<double> prevMainHeightWidth = ValueNotifier(0);
  final ValueNotifier<bool> prevDoPaginate = ValueNotifier(false);
  final ValueNotifier<bool> doPaginate = ValueNotifier(false);
  final ValueNotifier<bool> shareEnded = ValueNotifier(false);
  final ValueNotifier<List<Stream>> lStreams = ValueNotifier([]);
  final ValueNotifier<List<Stream>> chatRefStreams = ValueNotifier([]);
  final ValueNotifier<double> controlHeight = ValueNotifier(0.06);
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
  final ValueNotifier<List<Stream>> currentStreams = ValueNotifier([]);
  final ValueNotifier<bool> showMiniView = ValueNotifier(false);
  final ValueNotifier<MediaStream?> nStream = ValueNotifier(null);
  final ValueNotifier<bool> deferReceive = ValueNotifier(false);
  final ValueNotifier<List<Stream>> allAudioStreams = ValueNotifier([]);
  final ValueNotifier<List<Stream>> remoteScreenStream = ValueNotifier([]);
  final ValueNotifier<Producer?> screenProducer = ValueNotifier(null);
  final ValueNotifier<Producer?>? localScreenProducer = ValueNotifier(null);
  final ValueNotifier<bool> gotAllVids = ValueNotifier(false);
  final ValueNotifier<double> paginationHeightWidth = ValueNotifier(40);
  final ValueNotifier<String> paginationDirection = ValueNotifier('horizontal');
  final ValueNotifier<GridSizes> gridSizes = ValueNotifier(
    GridSizes(
      gridWidth: 0,
      gridHeight: 0,
      altGridWidth: 0,
      altGridHeight: 0,
    ),
  );
  final ValueNotifier<bool> screenForceFullDisplay = ValueNotifier(false);
  final ValueNotifier<List<Widget>> mainGridStream = ValueNotifier([]);
  List<List<Widget>> otherGridStreams = [[], []];
  final ValueNotifier<List<Widget>> audioOnlyStreams = ValueNotifier([]);
  final ValueNotifier<List<MediaDeviceInfo>> videoInputs = ValueNotifier([]);
  final ValueNotifier<List<MediaDeviceInfo>> audioInputs = ValueNotifier([]);
  final ValueNotifier<String> meetingProgressTime = ValueNotifier('00:00:00');
  final ValueNotifier<int> meetingElapsedTime = ValueNotifier(0);
  final ValueNotifier<List<Participant>> refParticipants = ValueNotifier([]);

  // Messages
  final ValueNotifier<List<Message>> messages = ValueNotifier([]);
  final ValueNotifier<bool> startDirectMessage = ValueNotifier(false);
  final ValueNotifier<Participant?> directMessageDetails = ValueNotifier(null);
  final ValueNotifier<bool> showMessagesBadge = ValueNotifier(false);

  // Event settings related variables
  final ValueNotifier<String> audioSetting = ValueNotifier('allow');
  final ValueNotifier<String> videoSetting = ValueNotifier('allow');
  final ValueNotifier<String> screenshareSetting = ValueNotifier('allow');
  final ValueNotifier<String> chatSetting = ValueNotifier('allow');

  // Display settings related variables
  final ValueNotifier<bool> autoWave = ValueNotifier(true);
  final ValueNotifier<bool> forceFullDisplay = ValueNotifier(true);
  final ValueNotifier<bool> prevForceFullDisplay = ValueNotifier(false);
  final ValueNotifier<String> prevMeetingDisplayType = ValueNotifier('video');

  // Waiting room
  final ValueNotifier<String> waitingRoomFilter = ValueNotifier('');
  final ValueNotifier<List<WaitingRoomParticipant>> waitingRoomList =
      ValueNotifier([]);
  final ValueNotifier<int> waitingRoomCounter = ValueNotifier(0);
  final ValueNotifier<List<WaitingRoomParticipant>> filteredWaitingRoomList =
      ValueNotifier([]);

  // Requests
  final ValueNotifier<String> requestFilter = ValueNotifier('');
  final ValueNotifier<List<Request>> requestList = ValueNotifier([]);
  final ValueNotifier<int> requestCounter = ValueNotifier(0);
  final ValueNotifier<List<Request>> filteredRequestList = ValueNotifier([]);

  //transports related variables
  final ValueNotifier<bool> transportCreated = ValueNotifier(false);
  final ValueNotifier<bool>? localTransportCreated = ValueNotifier(false);
  final ValueNotifier<bool> transportCreatedVideo = ValueNotifier(false);
  final ValueNotifier<bool> transportCreatedAudio = ValueNotifier(false);
  final ValueNotifier<bool> transportCreatedScreen = ValueNotifier(false);
  final ValueNotifier<Transport?> producerTransport = ValueNotifier(null);
  final ValueNotifier<Transport?>? localProducerTransport = ValueNotifier(null);
  final ValueNotifier<Producer?> videoProducer = ValueNotifier(null);
  final ValueNotifier<Producer?>? localVideoProducer = ValueNotifier(null);
  final ValueNotifier<ProducerOptionsType?> params = ValueNotifier(null);
  final ValueNotifier<ProducerOptionsType?> videoParams = ValueNotifier(null);
  final ValueNotifier<ProducerOptionsType?> audioParams = ValueNotifier(null);
  final ValueNotifier<Producer?> audioProducer = ValueNotifier(null);
  final ValueNotifier<double> audioLevel = ValueNotifier(0.0);
  final ValueNotifier<Producer?>? localAudioProducer = ValueNotifier(null);
  final ValueNotifier<List<TransportType>> consumerTransports =
      ValueNotifier([]);
  final ValueNotifier<List<String>> consumingTransports = ValueNotifier([]);

  final ValueNotifier<List<Poll>> polls = ValueNotifier([]);
  final ValueNotifier<Poll?> poll = ValueNotifier(null);
  final ValueNotifier<bool> isPollModalVisible = ValueNotifier(false);

  // Breakout rooms related variables
  final ValueNotifier<List<List<BreakoutParticipant>>> breakoutRooms =
      ValueNotifier([]);
  final ValueNotifier<int> currentRoomIndex = ValueNotifier(0);
  final ValueNotifier<bool> canStartBreakout = ValueNotifier(false);
  final ValueNotifier<bool> breakOutRoomStarted = ValueNotifier(false);
  final ValueNotifier<bool> breakOutRoomEnded = ValueNotifier(false);
  final ValueNotifier<int> hostNewRoom = ValueNotifier(-1);
  final ValueNotifier<List<BreakoutParticipant>> limitedBreakRoom =
      ValueNotifier([]);
  final ValueNotifier<int> mainRoomsLength = ValueNotifier(0);
  final ValueNotifier<int> memberRoom = ValueNotifier(-1);
  final ValueNotifier<bool> isBreakoutRoomsModalVisible = ValueNotifier(false);

  final ValueNotifier<bool> isPortrait = ValueNotifier<bool>(true);

  // Not implemented
  // Background-related variables
  ValueNotifier<String?> customImage = ValueNotifier<String?>(null);
  ValueNotifier<String?> selectedImage = ValueNotifier<String?>(null);
  ValueNotifier<MediaStream?> segmentVideo = ValueNotifier<MediaStream?>(null);
  ValueNotifier<dynamic> selfieSegmentation = ValueNotifier<dynamic>(null);
  ValueNotifier<bool> pauseSegmentation = ValueNotifier<bool>(false);
  ValueNotifier<MediaStream?> processedStream =
      ValueNotifier<MediaStream?>(null);
  ValueNotifier<bool> keepBackground = ValueNotifier<bool>(false);
  ValueNotifier<bool> backgroundHasChanged = ValueNotifier<bool>(false);
  ValueNotifier<MediaStream?> virtualStream = ValueNotifier<MediaStream?>(null);
  ValueNotifier<dynamic> mainCanvas = ValueNotifier<dynamic>(null);
  ValueNotifier<bool> prevKeepBackground = ValueNotifier<bool>(false);
  ValueNotifier<bool> appliedBackground = ValueNotifier<bool>(false);
  ValueNotifier<bool> isBackgroundModalVisible = ValueNotifier<bool>(false);
  ValueNotifier<bool> autoClickBackground = ValueNotifier<bool>(false);

// Whiteboard-related variables
  ValueNotifier<List<WhiteboardUser>> whiteboardUsers =
      ValueNotifier<List<WhiteboardUser>>([]);
  ValueNotifier<int?> currentWhiteboardIndex = ValueNotifier<int?>(null);
  ValueNotifier<bool> canStartWhiteboard = ValueNotifier<bool>(false);
  ValueNotifier<bool> whiteboardStarted = ValueNotifier<bool>(false);
  ValueNotifier<bool> whiteboardEnded = ValueNotifier<bool>(false);
  ValueNotifier<int> whiteboardLimit = ValueNotifier<int>(0);
  ValueNotifier<bool> isWhiteboardModalVisible = ValueNotifier<bool>(false);
  ValueNotifier<bool> isConfigureWhiteboardModalVisible =
      ValueNotifier<bool>(false);
  ValueNotifier<List<dynamic>> shapes = ValueNotifier<List<dynamic>>([]);
  ValueNotifier<bool> useImageBackground = ValueNotifier<bool>(true);
  ValueNotifier<List<dynamic>> redoStack = ValueNotifier<List<dynamic>>([]);
  ValueNotifier<List<String>> undoStack = ValueNotifier<List<String>>([]);
  ValueNotifier<MediaStream?> canvasStream = ValueNotifier<MediaStream?>(null);
  ValueNotifier<dynamic> canvasWhiteboard = ValueNotifier<dynamic>(null);

// Screenboard-related variables
  ValueNotifier<dynamic> canvasScreenboard = ValueNotifier<dynamic>(null);
  ValueNotifier<MediaStream?> processedScreenStream =
      ValueNotifier<MediaStream?>(null);
  ValueNotifier<bool> annotateScreenStream =
      ValueNotifier<bool>(false); // Annotate screen stream as boolean
  ValueNotifier<dynamic> mainScreenCanvas = ValueNotifier<dynamic>(null);
  ValueNotifier<bool> isScreenboardModalVisible = ValueNotifier<bool>(false);

  // showAlert modal
  final ValueNotifier<bool> alertVisible = ValueNotifier(false);
  final ValueNotifier<String> alertMessage = ValueNotifier('');
  final ValueNotifier<String> alertType = ValueNotifier('info');
  final ValueNotifier<int> alertDuration = ValueNotifier(3000);

  // Progress Timer
  final ValueNotifier<bool> progressTimerVisible = ValueNotifier(true);
  final ValueNotifier<int> progressTimerValue = ValueNotifier(0);
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
  // totalReqWait variable and update method
  final ValueNotifier<int> totalReqWait = ValueNotifier(0);
  // Other Modals
  final ValueNotifier<bool> isParticipantsModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isMessagesModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isConfirmExitModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isConfirmHereModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isShareEventModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isLoadingModalVisible = ValueNotifier(false);

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

  // Media related variables
  final ValueNotifier<bool> videoAlreadyOn = ValueNotifier(false);
  final ValueNotifier<bool> audioAlreadyOn = ValueNotifier(false);

  // Permissions related variables
  final ValueNotifier<bool> hasCameraPermission = ValueNotifier(false);
  final ValueNotifier<bool> hasAudioPermission = ValueNotifier(false);
  final ValueNotifier<ComponentSizes> componentSizes = ValueNotifier(
      ComponentSizes(
          mainHeight: 0, otherHeight: 0, mainWidth: 0, otherWidth: 0));

  // Update functionss
  void updateSocket(io.Socket? value) {
    socket.value = value;
    mediasfuParameters.socket = value;
    updateSpecificState(widget.options.sourceParameters, 'socket', value);
  }

  void updateLocalSocket(io.Socket? value) {
    if (!mounted) return;
    setState(() {
      localSocket.value = value;
      mediasfuParameters.localSocket = value;
      updateSpecificState(
          widget.options.sourceParameters, 'localSocket', value);
    });
  }

  void updateDevice(Device? value) {
    device.value = value;
    mediasfuParameters.device = value;
    updateSpecificState(widget.options.sourceParameters, 'device', value);
  }

  void updateRoomData(ResponseJoinRoom? value) {
    roomData.value = value;
    mediasfuParameters.roomData = value!;
    updateSpecificState(widget.options.sourceParameters, 'roomData', value);
  }

  void updateValidated(bool value) {
    if (!mounted) return;
    setState(() {
      validated = value;
      mediasfuParameters.validated = value;
      updateSpecificState(widget.options.sourceParameters, 'validated', value);
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

  void updateMember(String value) {
    if (value.contains("_")) {
      updateIslevel(value.split("_")[1]);
      value = value.split("_")[0];
    }

    member.value = value;
    mediasfuParameters.member = value;
    updateSpecificState(widget.options.sourceParameters, 'member', value);
  }

  void updateYouAreCoHost(bool value) {
    if (!mounted) return;
    setState(() {
      youAreCoHost.value = value;
      mediasfuParameters.youAreCoHost = value;
      updateSpecificState(
          widget.options.sourceParameters, 'youAreCoHost', value);
    });
  }

  void updateYouAreHost(bool value) {
    youAreHost.value = value;
    mediasfuParameters.youAreHost = value;
    updateSpecificState(widget.options.sourceParameters, 'youAreHost', value);
  }

  void updateConfirmedToRecord(bool value) {
    confirmedToRecord.value = value;
    mediasfuParameters.confirmedToRecord = value;
    updateSpecificState(
        widget.options.sourceParameters, 'confirmedToRecord', value);
  }

  void updateMeetingDisplayType(String value) {
    if (!mounted) return;
    setState(() {
      meetingDisplayType.value = value;
      mediasfuParameters.meetingDisplayType = value;
      updateSpecificState(
          widget.options.sourceParameters, 'meetingDisplayType', value);
    });
  }

  void updateMeetingVideoOptimized(bool value) {
    if (!mounted) return;
    setState(() {
      meetingVideoOptimized.value = value;
      mediasfuParameters.meetingVideoOptimized = value;
      updateSpecificState(
          widget.options.sourceParameters, 'meetingVideoOptimized', value);
    });
  }

  void updateEventType(EventType value) {
    if (!mounted) return;
    setState(() {
      eventType.value = value;
      mediasfuParameters.eventType = value;
      updateSpecificState(widget.options.sourceParameters, 'eventType', value);
    });
    if (value == EventType.chat) {
      updateMeetingDisplayType('all');
    }
  }

  void updateParticipants(List<Participant> value) {
    participants.value = value;
    mediasfuParameters.participants = value;
    updateSpecificState(widget.options.sourceParameters, 'participants', value);
    filteredParticipants.value = List.from(value);
    mediasfuParameters.filteredParticipants = List.from(value);
    updateSpecificState(widget.options.sourceParameters, 'filteredParticipants',
        List.from(value));
    participantsCounter.value = value.length;
    mediasfuParameters.participantsCounter = value.length;
    updateSpecificState(
        widget.options.sourceParameters, 'participantsCounter', value.length);
  }

  void updateFilteredParticipants(List<Participant> value) {
    filteredParticipants.value = value;
    mediasfuParameters.filteredParticipants = value;
    updateSpecificState(
        widget.options.sourceParameters, 'filteredParticipants', value);
  }

  void updateParticipantsCounter(int value) {
    participantsCounter.value = value;
    mediasfuParameters.participantsCounter = value;
    updateSpecificState(
        widget.options.sourceParameters, 'participantsCounter', value);
  }

  void updateParticipantsFilter(String value) {
    participantsFilter.value = value;
    mediasfuParameters.participantsFilter = value;
    updateSpecificState(
        widget.options.sourceParameters, 'participantsFilter', value);
  }

  void updateRoomName(String value) {
    roomName.value = value;
    mediasfuParameters.roomName = value;
    updateSpecificState(widget.options.sourceParameters, 'roomName', value);
  }

  void updateAdminPasscode(String value) {
    adminPasscode.value = value;
    mediasfuParameters.adminPasscode = value;
    updateSpecificState(
        widget.options.sourceParameters, 'adminPasscode', value);
  }

  void updateIslevel(String value) {
    if (!mounted) return;
    setState(() {
      islevel.value = value;
      mediasfuParameters.islevel = value;
      updateSpecificState(widget.options.sourceParameters, 'islevel', value);
    });
  }

  void updateCoHost(String value) {
    coHost.value = value;
    mediasfuParameters.coHost = value;
    updateSpecificState(widget.options.sourceParameters, 'coHost', value);
  }

  void updateCoHostResponsibility(List<CoHostResponsibility> value) {
    coHostResponsibility.value = value;
    mediasfuParameters.coHostResponsibility = value;
    updateSpecificState(
        widget.options.sourceParameters, 'coHostResponsibility', value);
  }

  void updateRecordingAudioPausesLimit(int value) {
    recordingAudioPausesLimit.value = value;
    mediasfuParameters.recordingAudioPausesLimit = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingAudioPausesLimit', value);
  }

  void updateRecordingAudioPausesCount(int value) {
    recordingAudioPausesCount.value = value;
    mediasfuParameters.recordingAudioPausesCount = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingAudioPausesCount', value);
  }

  void updateRecordingAudioSupport(bool value) {
    recordingAudioSupport.value = value;
    mediasfuParameters.recordingAudioSupport = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingAudioSupport', value);
  }

  void updateRecordingAudioPeopleLimit(int value) {
    recordingAudioPeopleLimit.value = value;
    mediasfuParameters.recordingAudioPeopleLimit = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingAudioPeopleLimit', value);
  }

  void updateRecordingAudioParticipantsTimeLimit(int value) {
    recordingAudioParticipantsTimeLimit.value = value;
    mediasfuParameters.recordingAudioParticipantsTimeLimit = value;
    updateSpecificState(widget.options.sourceParameters,
        'recordingAudioParticipantsTimeLimit', value);
  }

  void updateRecordingVideoPausesCount(int value) {
    recordingVideoPausesCount.value = value;
    mediasfuParameters.recordingVideoPausesCount = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingVideoPausesCount', value);
  }

  void updateRecordingVideoPausesLimit(int value) {
    recordingVideoPausesLimit.value = value;
    mediasfuParameters.recordingVideoPausesLimit = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingVideoPausesLimit', value);
  }

  void updateRecordingVideoSupport(bool value) {
    recordingVideoSupport.value = value;
    mediasfuParameters.recordingVideoSupport = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingVideoSupport', value);
  }

  void updateRecordingVideoPeopleLimit(int value) {
    recordingVideoPeopleLimit.value = value;
    mediasfuParameters.recordingVideoPeopleLimit = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingVideoPeopleLimit', value);
  }

  void updateRecordingVideoParticipantsTimeLimit(int value) {
    recordingVideoParticipantsTimeLimit.value = value;
    mediasfuParameters.recordingVideoParticipantsTimeLimit = value;
    updateSpecificState(widget.options.sourceParameters,
        'recordingVideoParticipantsTimeLimit', value);
  }

  void updateRecordingAllParticipantsSupport(bool value) {
    recordingAllParticipantsSupport.value = value;
    mediasfuParameters.recordingAllParticipantsSupport = value;
    updateSpecificState(widget.options.sourceParameters,
        'recordingAllParticipantsSupport', value);
  }

  void updateRecordingVideoParticipantsSupport(bool value) {
    recordingVideoParticipantsSupport.value = value;
    mediasfuParameters.recordingVideoParticipantsSupport = value;
    updateSpecificState(widget.options.sourceParameters,
        'recordingVideoParticipantsSupport', value);
  }

  void updateRecordingAllParticipantsFullRoomSupport(bool value) {
    recordingAllParticipantsFullRoomSupport.value = value;
    mediasfuParameters.recordingAllParticipantsFullRoomSupport = value;
    updateSpecificState(widget.options.sourceParameters,
        'recordingAllParticipantsFullRoomSupport', value);
  }

  void updateRecordingVideoParticipantsFullRoomSupport(bool value) {
    recordingVideoParticipantsFullRoomSupport.value = value;
    mediasfuParameters.recordingVideoParticipantsFullRoomSupport = value;
    updateSpecificState(widget.options.sourceParameters,
        'recordingVideoParticipantsFullRoomSupport', value);
  }

  void updateRecordingPreferredOrientation(String value) {
    recordingPreferredOrientation.value = value;
    mediasfuParameters.recordingPreferredOrientation = value;
    updateSpecificState(widget.options.sourceParameters,
        'recordingPreferredOrientation', value);
  }

  void updateRecordingSupportForOtherOrientation(bool value) {
    recordingSupportForOtherOrientation.value = value;
    mediasfuParameters.recordingSupportForOtherOrientation = value;
    updateSpecificState(widget.options.sourceParameters,
        'recordingSupportForOtherOrientation', value);
  }

  void updateRecordingMultiFormatsSupport(bool value) {
    recordingMultiFormatsSupport.value = value;
    mediasfuParameters.recordingMultiFormatsSupport = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingMultiFormatsSupport', value);
  }

  void updateUserRecordingParams(UserRecordingParams value) {
    userRecordingParams.value = value;
    mediasfuParameters.userRecordingParams = value;
    updateSpecificState(
        widget.options.sourceParameters, 'userRecordingParams', value);
  }

  void updateCanRecord(bool value) {
    canRecord.value = value;
    mediasfuParameters.canRecord = value;
    updateSpecificState(widget.options.sourceParameters, 'canRecord', value);
  }

  void updateStartReport(bool value) {
    startReport.value = value;
    mediasfuParameters.startReport = value;
    updateSpecificState(widget.options.sourceParameters, 'startReport', value);
  }

  void updateEndReport(bool value) {
    endReport.value = value;
    mediasfuParameters.endReport = value;
    updateSpecificState(widget.options.sourceParameters, 'endReport', value);
  }

  void updateRecordTimerInterval(dynamic value) {
    recordTimerInterval.value = value;
    mediasfuParameters.recordTimerInterval = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordTimerInterval', value);
  }

  void updateRecordStartTime(int? value) {
    recordStartTime.value = value;
    mediasfuParameters.recordStartTime = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordStartTime', value);
  }

  void updateRecordElapsedTime(int value) {
    recordElapsedTime.value = value;
    mediasfuParameters.recordElapsedTime = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordElapsedTime', value);
  }

  void updateIsTimerRunning(bool value) {
    isTimerRunning.value = value;
    mediasfuParameters.isTimerRunning = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isTimerRunning', value);
  }

  void updateCanPauseResume(bool value) {
    canPauseResume.value = value;
    mediasfuParameters.canPauseResume = value;
    updateSpecificState(
        widget.options.sourceParameters, 'canPauseResume', value);
  }

  void updateRecordChangeSeconds(int value) {
    recordChangeSeconds.value = value;
    mediasfuParameters.recordChangeSeconds = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordChangeSeconds', value);
  }

  void updatePauseLimit(int value) {
    pauseLimit.value = value;
    mediasfuParameters.pauseLimit = value;
    updateSpecificState(widget.options.sourceParameters, 'pauseLimit', value);
  }

  void updatePauseRecordCount(int value) {
    pauseRecordCount.value = value;
    mediasfuParameters.pauseRecordCount = value;
    updateSpecificState(
        widget.options.sourceParameters, 'pauseRecordCount', value);
  }

  void updateCanLaunchRecord(bool value) {
    canLaunchRecord.value = value;
    mediasfuParameters.canLaunchRecord = value;
    updateSpecificState(
        widget.options.sourceParameters, 'canLaunchRecord', value);
  }

  void updateStopLaunchRecord(bool value) {
    stopLaunchRecord.value = value;
    mediasfuParameters.stopLaunchRecord = value;
    updateSpecificState(
        widget.options.sourceParameters, 'stopLaunchRecord', value);
  }

  void updateParticipantsAll(List<Participant> value) {
    participantsAll.value = value;
    mediasfuParameters.participantsAll = value;
    updateSpecificState(
        widget.options.sourceParameters, 'participantsAll', value);
  }

  void updateConsumeSockets(List<ConsumeSocket> value) {
    consumeSockets.value = value;
    mediasfuParameters.consumeSockets = value;
    updateSpecificState(
        widget.options.sourceParameters, 'consumeSockets', value);
  }

  void updateRtpCapabilities(RtpCapabilities? value) {
    rtpCapabilities.value = value;
    mediasfuParameters.rtpCapabilities = value;
    updateSpecificState(
        widget.options.sourceParameters, 'rtpCapabilities', value);
  }

  void updateRoomRecvIPs(List<String> value) {
    roomRecvIPs.value = value;
    mediasfuParameters.roomRecvIPs = value;
    updateSpecificState(widget.options.sourceParameters, 'roomRecvIPs', value);
  }

  void updateMeetingRoomParams(MeetingRoomParams? value) {
    meetingRoomParams.value = value;
    mediasfuParameters.meetingRoomParams = value;
    updateSpecificState(
        widget.options.sourceParameters, 'meetingRoomParams', value);
  }

  void updateItemPageLimit(int value) {
    itemPageLimit.value = value;
    mediasfuParameters.itemPageLimit = value;
    updateSpecificState(
        widget.options.sourceParameters, 'itemPageLimit', value);
  }

  void updateAudioOnlyRoom(bool value) {
    audioOnlyRoom.value = value;
    mediasfuParameters.audioOnlyRoom = value;
    updateSpecificState(
        widget.options.sourceParameters, 'audioOnlyRoom', value);
  }

  void updateAddForBasic(bool value) {
    addForBasic.value = value;
    mediasfuParameters.addForBasic = value;
    updateSpecificState(widget.options.sourceParameters, 'addForBasic', value);
  }

  void updateScreenPageLimit(int value) {
    screenPageLimit.value = value;
    mediasfuParameters.screenPageLimit = value;
    updateSpecificState(
        widget.options.sourceParameters, 'screenPageLimit', value);
  }

  void updateShareScreenStarted(bool value) {
    shareScreenStarted.value = value;
    mediasfuParameters.shareScreenStarted = value;
    updateSpecificState(
        widget.options.sourceParameters, 'shareScreenStarted', value);
  }

  void updateShared(bool value) {
    if (!mounted) return;
    setState(() {
      shared.value = value;
      mediasfuParameters.shared = value;
    });
    updateSpecificState(widget.options.sourceParameters, 'shared', value);
  }

  void updateTargetOrientation(String value) {
    targetOrientation.value = value;
    mediasfuParameters.targetOrientation = value;
    updateSpecificState(
        widget.options.sourceParameters, 'targetOrientation', value);
  }

  void updateTargetResolution(String value) {
    targetResolution.value = value;
    mediasfuParameters.targetResolution = value;
    updateSpecificState(
        widget.options.sourceParameters, 'targetResolution', value);
  }

  void updateTargetResolutionHost(String value) {
    targetResolutionHost.value = value;
    mediasfuParameters.targetResolutionHost = value;
    updateSpecificState(
        widget.options.sourceParameters, 'targetResolutionHost', value);
  }

  void updateVidCons(VidCons value) {
    vidCons.value = value;
    mediasfuParameters.vidCons = value;
    updateSpecificState(widget.options.sourceParameters, 'vidCons', value);
  }

  void updateFrameRate(int value) {
    frameRate.value = value;
    mediasfuParameters.frameRate = value;
    updateSpecificState(widget.options.sourceParameters, 'frameRate', value);
  }

  void updateHParams(ProducerOptionsType? value) {
    hParams.value = value;
    mediasfuParameters.hParams = value;
    updateSpecificState(widget.options.sourceParameters, 'hParams', value);
  }

  void updateVParams(ProducerOptionsType? value) {
    vParams.value = value;
    mediasfuParameters.vParams = value;
    updateSpecificState(widget.options.sourceParameters, 'vParams', value);
  }

  void updateScreenParams(ProducerOptionsType? value) {
    screenParams.value = value;
    mediasfuParameters.screenParams = value;
    updateSpecificState(widget.options.sourceParameters, 'screenParams', value);
  }

  void updateAParams(ProducerOptionsType? value) {
    aParams.value = value;
    mediasfuParameters.aParams = value;
    updateSpecificState(widget.options.sourceParameters, 'aParams', value);
  }

  void updateFirstAll(bool value) {
    firstAll.value = value;
    mediasfuParameters.firstAll = value;
    updateSpecificState(widget.options.sourceParameters, 'firstAll', value);
  }

  void updateUpdateMainWindow(bool value) {
    updateMainWindow.value = value;
    mediasfuParameters.updateMainWindow = value;
    updateSpecificState(
        widget.options.sourceParameters, 'updateMainWindow', value);
  }

  void updateFirstRound(bool value) {
    firstRound.value = value;
    mediasfuParameters.firstRound = value;
    updateSpecificState(widget.options.sourceParameters, 'firstRound', value);
  }

  void updateLandScaped(bool value) {
    landScaped.value = value;
    mediasfuParameters.landScaped = value;
    updateSpecificState(widget.options.sourceParameters, 'landScaped', value);
  }

  void updateLockScreen(bool value) {
    lockScreen.value = value;
    mediasfuParameters.lockScreen = value;
    updateSpecificState(widget.options.sourceParameters, 'lockScreen', value);
  }

  void updateScreenId(String value) {
    screenId.value = value;
    mediasfuParameters.screenId = value;
    updateSpecificState(widget.options.sourceParameters, 'screenId', value);
  }

  void updateAllVideoStreams(List<Stream> value) {
    allVideoStreams.value = value;
    mediasfuParameters.allVideoStreams = value;
    updateSpecificState(
        widget.options.sourceParameters, 'allVideoStreams', value);
  }

  void updateNewLimitedStreams(List<Stream> value) {
    newLimitedStreams.value = value;
    mediasfuParameters.newLimitedStreams = value;
    updateSpecificState(
        widget.options.sourceParameters, 'newLimitedStreams', value);
  }

  void updateNewLimitedStreamsIDs(List<String> value) {
    newLimitedStreamsIDs.value = value;
    mediasfuParameters.newLimitedStreamsIDs = value;
    updateSpecificState(
        widget.options.sourceParameters, 'newLimitedStreamsIDs', value);
  }

  void updateActiveSounds(List<String> value) {
    activeSounds.value = value;
    mediasfuParameters.activeSounds = value;
    updateSpecificState(widget.options.sourceParameters, 'activeSounds', value);
  }

  void updateScreenShareIDStream(String value) {
    screenShareIDStream.value = value;
    mediasfuParameters.screenShareIDStream = value;
    updateSpecificState(
        widget.options.sourceParameters, 'screenShareIDStream', value);
  }

  void updateScreenShareNameStream(String value) {
    screenShareNameStream.value = value;
    mediasfuParameters.screenShareNameStream = value;
    updateSpecificState(
        widget.options.sourceParameters, 'screenShareNameStream', value);
  }

  void updateAdminIDStream(String value) {
    adminIDStream.value = value;
    mediasfuParameters.adminIDStream = value;
    updateSpecificState(
        widget.options.sourceParameters, 'adminIDStream', value);
  }

  void updateAdminNameStream(String value) {
    adminNameStream.value = value;
    mediasfuParameters.adminNameStream = value;
    updateSpecificState(
        widget.options.sourceParameters, 'adminNameStream', value);
  }

  void updateYouYouStream(List<Stream> value) {
    youYouStream.value = value;
    mediasfuParameters.youYouStream = value;
    updateSpecificState(widget.options.sourceParameters, 'youYouStream', value);
  }

  void updateYouYouStreamIDs(List<String> value) {
    youYouStreamIDs.value = value;
    mediasfuParameters.youYouStreamIDs = value;
    updateSpecificState(
        widget.options.sourceParameters, 'youYouStreamIDs', value);
  }

  void updateLocalStream(MediaStream? value) {
    localStream.value = value;
    mediasfuParameters.localStream = value;
    updateSpecificState(widget.options.sourceParameters, 'localStream', value);
  }

  void updateRecordStarted(bool value) {
    if (!mounted) return;
    setState(() {
      recordStarted.value = value;
      mediasfuParameters.recordStarted = value;
      updateSpecificState(
          widget.options.sourceParameters, 'recordStarted', value);
    });
    if (clearedToRecord.value == true &&
        clearedToResume.value == true &&
        recordStarted.value == true) {
      updateShowRecordButtons(true);
    }
  }

  void updateRecordResumed(bool value) {
    if (!mounted) return;
    setState(() {
      recordResumed.value = value;
      mediasfuParameters.recordResumed = value;
      updateSpecificState(
          widget.options.sourceParameters, 'recordResumed', value);
    });
  }

  void updateRecordPaused(bool value) {
    if (!mounted) return;
    setState(() {
      recordPaused.value = value;
      mediasfuParameters.recordPaused = value;
      updateSpecificState(
          widget.options.sourceParameters, 'recordPaused', value);
    });
  }

  void updateRecordStopped(bool value) {
    if (!mounted) return;
    setState(() {
      recordStopped.value = value;
      mediasfuParameters.recordStopped = value;
      updateSpecificState(
          widget.options.sourceParameters, 'recordStopped', value);
    });
  }

  void updateAdminRestrictSetting(bool value) {
    adminRestrictSetting.value = value;
    mediasfuParameters.adminRestrictSetting = value;
    updateSpecificState(
        widget.options.sourceParameters, 'adminRestrictSetting', value);
  }

  void updateVideoRequestState(String value) {
    videoRequestState.value = value;
    mediasfuParameters.videoRequestState = value;
    updateSpecificState(
        widget.options.sourceParameters, 'videoRequestState', value);
  }

  void updateVideoRequestTime(int? value) {
    videoRequestTime.value = value;
    mediasfuParameters.videoRequestTime = value;
    updateSpecificState(
        widget.options.sourceParameters, 'videoRequestTime', value);
  }

  void updateVideoAction(bool value) {
    videoAction.value = value;
    mediasfuParameters.videoAction = value;
    updateSpecificState(widget.options.sourceParameters, 'videoAction', value);
  }

  void updateLocalStreamVideo(MediaStream? value) {
    localStreamVideo.value = value;
    mediasfuParameters.localStreamVideo = value;
    updateSpecificState(
        widget.options.sourceParameters, 'localStreamVideo', value);
  }

  void updateUserDefaultVideoInputDevice(String value) {
    userDefaultVideoInputDevice.value = value;
    mediasfuParameters.userDefaultVideoInputDevice = value;
    updateSpecificState(
        widget.options.sourceParameters, 'userDefaultVideoInputDevice', value);
  }

  void updateCurrentFacingMode(String value) {
    currentFacingMode.value = value;
    mediasfuParameters.currentFacingMode = value;
    updateSpecificState(
        widget.options.sourceParameters, 'currentFacingMode', value);
  }

  void updatePrevFacingMode(String value) {
    prevFacingMode.value = value;
    mediasfuParameters.prevFacingMode = value;
    updateSpecificState(
        widget.options.sourceParameters, 'prevFacingMode', value);
  }

  void updateDefVideoID(String value) {
    defVideoID.value = value;
    mediasfuParameters.defVideoID = value;
    updateSpecificState(widget.options.sourceParameters, 'defVideoID', value);
  }

  void updateAllowed(bool value) {
    allowed.value = value;
    mediasfuParameters.allowed = value;
    updateSpecificState(widget.options.sourceParameters, 'allowed', value);
  }

  void updateDispActiveNames(List<String> value) {
    dispActiveNames.value = value;
    mediasfuParameters.dispActiveNames = value;
    updateSpecificState(
        widget.options.sourceParameters, 'dispActiveNames', value);
  }

  void updatePDispActiveNames(List<String> value) {
    pDispActiveNames.value = value;
    mediasfuParameters.pDispActiveNames = value;
    updateSpecificState(
        widget.options.sourceParameters, 'pDispActiveNames', value);
  }

  void updateActiveNames(List<String> value) {
    activeNames.value = value;
    mediasfuParameters.activeNames = value;
    updateSpecificState(widget.options.sourceParameters, 'activeNames', value);
  }

  void updatePrevActiveNames(List<String> value) {
    prevActiveNames.value = value;
    mediasfuParameters.prevActiveNames = value;
    updateSpecificState(
        widget.options.sourceParameters, 'prevActiveNames', value);
  }

  void updatePActiveNames(List<String> value) {
    pActiveNames.value = value;
    mediasfuParameters.pActiveNames = value;
    updateSpecificState(widget.options.sourceParameters, 'pActiveNames', value);
  }

  void updateMembersReceived(bool value) {
    membersReceived.value = value;
    mediasfuParameters.membersReceived = value;
    updateSpecificState(
        widget.options.sourceParameters, 'membersReceived', value);
  }

  void updateDeferScreenReceived(bool value) {
    deferScreenReceived.value = value;
    mediasfuParameters.deferScreenReceived = value;
    updateSpecificState(
        widget.options.sourceParameters, 'deferScreenReceived', value);
  }

  void updateHostFirstSwitch(bool value) {
    hostFirstSwitch.value = value;
    mediasfuParameters.hostFirstSwitch = value;
    updateSpecificState(
        widget.options.sourceParameters, 'hostFirstSwitch', value);
  }

  void updateMicAction(bool value) {
    micAction.value = value;
    mediasfuParameters.micAction = value;
    updateSpecificState(widget.options.sourceParameters, 'micAction', value);
  }

  void updateScreenAction(bool value) {
    screenAction.value = value;
    mediasfuParameters.screenAction = value;
    updateSpecificState(widget.options.sourceParameters, 'screenAction', value);
  }

  void updateChatAction(bool value) {
    chatAction.value = value;
    mediasfuParameters.chatAction = value;
    updateSpecificState(widget.options.sourceParameters, 'chatAction', value);
  }

  void updateAudioRequestState(String? value) {
    audioRequestState.value = value!;
    mediasfuParameters.audioRequestState = value;
    updateSpecificState(
        widget.options.sourceParameters, 'audioRequestState', value);
  }

  void updateScreenRequestState(String? value) {
    screenRequestState.value = value!;
    mediasfuParameters.screenRequestState = value;
    updateSpecificState(
        widget.options.sourceParameters, 'screenRequestState', value);
  }

  void updateChatRequestState(String? value) {
    chatRequestState.value = value!;
    mediasfuParameters.chatRequestState = value;
    updateSpecificState(
        widget.options.sourceParameters, 'chatRequestState', value);
  }

  void updateAudioRequestTime(int? value) {
    audioRequestTime.value = value;
    mediasfuParameters.audioRequestTime = value;
    updateSpecificState(
        widget.options.sourceParameters, 'audioRequestTime', value);
  }

  void updateScreenRequestTime(int? value) {
    screenRequestTime.value = value;
    mediasfuParameters.screenRequestTime = value;
    updateSpecificState(
        widget.options.sourceParameters, 'screenRequestTime', value);
  }

  void updateChatRequestTime(int? value) {
    chatRequestTime.value = value;
    mediasfuParameters.chatRequestTime = value;
    updateSpecificState(
        widget.options.sourceParameters, 'chatRequestTime', value);
  }

  void updateOldSoundIds(List<String> value) {
    oldSoundIds.value = value;
    mediasfuParameters.oldSoundIds = value;
    updateSpecificState(widget.options.sourceParameters, 'oldSoundIds', value);
  }

  void updateHostLabel(String value) {
    hostLabel.value = value;
    mediasfuParameters.hostLabel = value;
    updateSpecificState(widget.options.sourceParameters, 'hostLabel', value);
  }

  void updateMainScreenFilled(bool value) {
    mainScreenFilled.value = value;
    mediasfuParameters.mainScreenFilled = value;
    updateSpecificState(
        widget.options.sourceParameters, 'mainScreenFilled', value);
  }

  void updateLocalStreamScreen(dynamic value) {
    if (!mounted) return;
    setState(() {
      localStreamScreen.value = value;
      mediasfuParameters.localStreamScreen = value;
    });
    updateSpecificState(
        widget.options.sourceParameters, 'localStreamScreen', value);
  }

  void updateScreenAlreadyOn(bool value) {
    screenAlreadyOn.value = value;
    mediasfuParameters.screenAlreadyOn = value;
    updateSpecificState(
        widget.options.sourceParameters, 'screenAlreadyOn', value);
    if (!mounted) return;
    setState(() {
      screenShareActive = value;
    });
  }

  void updateChatAlreadyOn(bool value) {
    chatAlreadyOn.value = value;
    mediasfuParameters.chatAlreadyOn = value;
    updateSpecificState(
        widget.options.sourceParameters, 'chatAlreadyOn', value);
  }

  void updateRedirectURL(dynamic value) {
    redirectURL.value = value;
    mediasfuParameters.redirectURL = value;
    updateSpecificState(widget.options.sourceParameters, 'redirectURL', value);
  }

  void updateOldAllStreams(dynamic value) {
    oldAllStreams.value = value;
    mediasfuParameters.oldAllStreams = value;
    updateSpecificState(
        widget.options.sourceParameters, 'oldAllStreams', value);
  }

  void updateAdminVidID(String value) {
    adminVidID.value = value;
    mediasfuParameters.adminVidID = value;
    updateSpecificState(widget.options.sourceParameters, 'adminVidID', value);
  }

  void updateStreamNames(List<Stream> value) {
    streamNames.value = value;
    mediasfuParameters.streamNames = value;
    updateSpecificState(widget.options.sourceParameters, 'streamNames', value);
  }

  void updateNonAlVideoStreams(List<Stream> value) {
    nonAlVideoStreams.value = value;
    mediasfuParameters.nonAlVideoStreams = value;
    updateSpecificState(
        widget.options.sourceParameters, 'nonAlVideoStreams', value);
  }

  void updateSortAudioLoudness(bool value) {
    sortAudioLoudness.value = value;
    mediasfuParameters.sortAudioLoudness = value;
    updateSpecificState(
        widget.options.sourceParameters, 'sortAudioLoudness', value);
  }

  void updateAudioDecibels(List<AudioDecibels> value) {
    audioDecibels.value = value;
    mediasfuParameters.audioDecibels = value;
    updateSpecificState(
        widget.options.sourceParameters, 'audioDecibels', value);
  }

  void updateMixedAlVideoStreams(List<Stream> value) {
    mixedAlVideoStreams.value = value;
    mediasfuParameters.mixedAlVideoStreams = value;
    updateSpecificState(
        widget.options.sourceParameters, 'mixedAlVideoStreams', value);
  }

  void updateNonAlVideoStreamsMuted(List<Stream> value) {
    nonAlVideoStreamsMuted.value = value;
    mediasfuParameters.nonAlVideoStreamsMuted = value;
    updateSpecificState(
        widget.options.sourceParameters, 'nonAlVideoStreamsMuted', value);
  }

  void updatePaginatedStreams(List<List<Stream>> value) {
    paginatedStreams.value = value;
    mediasfuParameters.paginatedStreams = value;
    updateSpecificState(
        widget.options.sourceParameters, 'paginatedStreams', value);
  }

  void updateLocalStreamAudio(MediaStream? value) {
    localStreamAudio.value = value;
    mediasfuParameters.localStreamAudio = value;
    updateSpecificState(
        widget.options.sourceParameters, 'localStreamAudio', value);
  }

  void updateDefAudioID(String value) {
    defAudioID.value = value;
    mediasfuParameters.defAudioID = value;
    updateSpecificState(widget.options.sourceParameters, 'defAudioID', value);
  }

  void updateUserDefaultAudioInputDevice(String value) {
    userDefaultAudioInputDevice.value = value;
    mediasfuParameters.userDefaultAudioInputDevice = value;
    updateSpecificState(
        widget.options.sourceParameters, 'userDefaultAudioInputDevice', value);
  }

  void updateUserDefaultAudioOutputDevice(String value) {
    userDefaultAudioOutputDevice.value = value;
    mediasfuParameters.userDefaultAudioOutputDevice = value;
    updateSpecificState(
        widget.options.sourceParameters, 'userDefaultAudioOutputDevice', value);
  }

  void updatePrevAudioInputDevice(String value) {
    prevAudioInputDevice.value = value;
    mediasfuParameters.prevAudioInputDevice = value;
    updateSpecificState(
        widget.options.sourceParameters, 'prevAudioInputDevice', value);
  }

  void updatePrevVideoInputDevice(String value) {
    prevVideoInputDevice.value = value;
    mediasfuParameters.prevVideoInputDevice = value;
    updateSpecificState(
        widget.options.sourceParameters, 'prevVideoInputDevice', value);
  }

  void updateAudioPaused(bool value) {
    audioPaused.value = value;
    mediasfuParameters.audioPaused = value;
    updateSpecificState(widget.options.sourceParameters, 'audioPaused', value);
  }

  void updateMainScreenPerson(String value) {
    mainScreenPerson.value = value;
    mediasfuParameters.mainScreenPerson = value;
    updateSpecificState(
        widget.options.sourceParameters, 'mainScreenPerson', value);
  }

  void updateAdminOnMainScreen(bool value) {
    adminOnMainScreen.value = value;
    mediasfuParameters.adminOnMainScreen = value;
    updateSpecificState(
        widget.options.sourceParameters, 'adminOnMainScreen', value);
  }

  void updateScreenStates(List<ScreenState> value) {
    screenStates.value = value;
    mediasfuParameters.screenStates = value;
    updateSpecificState(widget.options.sourceParameters, 'screenStates', value);
  }

  void updatePrevScreenStates(List<ScreenState> value) {
    prevScreenStates.value = value;
    mediasfuParameters.prevScreenStates = value;
    updateSpecificState(
        widget.options.sourceParameters, 'prevScreenStates', value);
  }

  void updateUpdateDateState(dynamic value) {
    updateDateState.value = value;
    mediasfuParameters.updateDateState = value;
    updateSpecificState(
        widget.options.sourceParameters, 'updateDateState', value);
  }

  void updateLastUpdate(dynamic value) {
    lastUpdate.value = value;
    mediasfuParameters.lastUpdate = value;
    updateSpecificState(widget.options.sourceParameters, 'lastUpdate', value);
  }

  void updateNForReadjustRecord(int value) {
    nForReadjustRecord.value = value;
    mediasfuParameters.nForReadjustRecord = value;
    updateSpecificState(
        widget.options.sourceParameters, 'nForReadjustRecord', value);
  }

  void updateFixedPageLimit(int value) {
    fixedPageLimit.value = value;
    mediasfuParameters.fixedPageLimit = value;
    updateSpecificState(
        widget.options.sourceParameters, 'fixedPageLimit', value);
  }

  void updateRemoveAltGrid(bool value) {
    removeAltGrid.value = value;
    mediasfuParameters.removeAltGrid = value;
    updateSpecificState(
        widget.options.sourceParameters, 'removeAltGrid', value);
  }

  void updateNForReadjust(int value) {
    nForReadjust.value = value;
    mediasfuParameters.nForReadjust = value;
    updateSpecificState(widget.options.sourceParameters, 'nForReadjust', value);
  }

  void updateLastReorderTime(int value) {
    lastReorderTime.value = value;
    mediasfuParameters.lastReorderTime = value;
    updateSpecificState(
        widget.options.sourceParameters, 'lastReorderTime', value);
  }

  void updateAudStreamNames(List<Stream> value) {
    audStreamNames.value = value;
    mediasfuParameters.audStreamNames = value;
    updateSpecificState(
        widget.options.sourceParameters, 'audStreamNames', value);
  }

  void updateCurrentUserPage(int value) {
    currentUserPage.value = value;
    mediasfuParameters.currentUserPage = value;
    updateSpecificState(
        widget.options.sourceParameters, 'currentUserPage', value);
  }

  void updateMainHeightWidth(dynamic value) {
    bool doUpdate = value.floor() != mainHeightWidth.floor();
    if (!mounted) return;
    setState(() {
      mainHeightWidth = value.toDouble();
      mediasfuParameters.mainHeightWidth = value.toDouble();
      updateSpecificState(
          widget.options.sourceParameters, 'mainHeightWidth', value.toDouble());
    });

    if (doUpdate && validated) {
      try {
        onScreenChanges(
          OnScreenChangesOptions(
            changed: true,
            parameters: mediasfuParameters,
          ),
        );
      } catch (error) {}

      try {
        prepopulateUserMedia(
          PrepopulateUserMediaOptions(
            name: hostLabel.value,
            parameters: mediasfuParameters,
          ),
        );
      } catch (error) {}
    }
  }

  void updatePrevMainHeightWidth(dynamic value) {
    prevMainHeightWidth.value = value;
    mediasfuParameters.prevMainHeightWidth = value;
    updateSpecificState(
        widget.options.sourceParameters, 'prevMainHeightWidth', value);
  }

  void updatePrevDoPaginate(bool value) {
    if (value != prevDoPaginate.value) {
      prevDoPaginate.value = value;
      mediasfuParameters.prevDoPaginate = value;
      updateSpecificState(
          widget.options.sourceParameters, 'prevDoPaginate', value);
    }
  }

  void updateDoPaginate(bool value) {
    if (value != doPaginate.value) {
      if (!mounted) return;
      setState(() {
        doPaginate.value = value;
        mediasfuParameters.doPaginate = value;
        updateSpecificState(
            widget.options.sourceParameters, 'doPaginate', value);
      });
    }
  }

  void updateShareEnded(bool value) {
    shareEnded.value = value;
    mediasfuParameters.shareEnded = value;
    updateSpecificState(widget.options.sourceParameters, 'shareEnded', value);
  }

  void updateLStreams(dynamic value) {
    lStreams.value = value;
    mediasfuParameters.lStreams = value;
    updateSpecificState(widget.options.sourceParameters, 'lStreams', value);
  }

  void updateChatRefStreams(dynamic value) {
    chatRefStreams.value = value;
    mediasfuParameters.chatRefStreams = value;
    updateSpecificState(
        widget.options.sourceParameters, 'chatRefStreams', value);
  }

  void updateControlHeight(dynamic value) {
    if (!mounted) return;
    setState(() {
      controlHeight.value = value;
      mediasfuParameters.controlHeight = value;
      updateSpecificState(
          widget.options.sourceParameters, 'controlHeight', value);
    });
  }

  void updateIsWideScreen(bool value) {
    isWideScreen.value = value;
    mediasfuParameters.isWideScreen = value;
    updateSpecificState(widget.options.sourceParameters, 'isWideScreen', value);
  }

  void updateIsMediumScreen(bool value) {
    isMediumScreen.value = value;
    mediasfuParameters.isMediumScreen = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isMediumScreen', value);
  }

  void updateIsSmallScreen(bool value) {
    isSmallScreen.value = value;
    mediasfuParameters.isSmallScreen = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isSmallScreen', value);
  }

  void updateAddGrid(bool value) {
    addGrid.value = value;
    mediasfuParameters.addGrid = value;
    updateSpecificState(widget.options.sourceParameters, 'addGrid', value);
  }

  void updateAddAltGrid(bool value) {
    addAltGrid.value = value;
    mediasfuParameters.addAltGrid = value;
    updateSpecificState(widget.options.sourceParameters, 'addAltGrid', value);
  }

  void updateGridRows(int value) {
    gridRows.value = value;
    mediasfuParameters.gridRows = value;
    updateSpecificState(widget.options.sourceParameters, 'gridRows', value);
  }

  void updateGridCols(int value) {
    gridCols.value = value;
    mediasfuParameters.gridCols = value;
    updateSpecificState(widget.options.sourceParameters, 'gridCols', value);
  }

  void updateAltGridRows(int value) {
    altGridRows.value = value;
    mediasfuParameters.altGridRows = value;
    updateSpecificState(widget.options.sourceParameters, 'altGridRows', value);
  }

  void updateAltGridCols(int value) {
    altGridCols.value = value;
    mediasfuParameters.altGridCols = value;
    updateSpecificState(widget.options.sourceParameters, 'altGridCols', value);
  }

  void updateNumberPages(int value) {
    numberPages.value = value;
    mediasfuParameters.numberPages = value;
    updateSpecificState(widget.options.sourceParameters, 'numberPages', value);
  }

  void updateCurrentStreams(dynamic value) {
    currentStreams.value = value;
    mediasfuParameters.currentStreams = value;
    updateSpecificState(
        widget.options.sourceParameters, 'currentStreams', value);
  }

  void updateShowMiniView(bool value) {
    showMiniView.value = value;
    mediasfuParameters.showMiniView = value;
    updateSpecificState(widget.options.sourceParameters, 'showMiniView', value);
  }

  void updateNStream(dynamic value) {
    nStream.value = value;
    mediasfuParameters.nStream = value;
    updateSpecificState(widget.options.sourceParameters, 'nStream', value);
  }

  void updateDeferReceive(bool value) {
    deferReceive.value = value;
    mediasfuParameters.deferReceive = value;
    updateSpecificState(widget.options.sourceParameters, 'deferReceive', value);
  }

  void updateAllAudioStreams(dynamic value) {
    allAudioStreams.value = value;
    mediasfuParameters.allAudioStreams = value;
    updateSpecificState(
        widget.options.sourceParameters, 'allAudioStreams', value);
  }

  void updateRemoteScreenStream(dynamic value) {
    remoteScreenStream.value = value;
    mediasfuParameters.remoteScreenStream = value;
    updateSpecificState(
        widget.options.sourceParameters, 'remoteScreenStream', value);
  }

  void updateScreenProducer(dynamic value) {
    screenProducer.value = value;
    mediasfuParameters.screenProducer = value;
    updateSpecificState(
        widget.options.sourceParameters, 'screenProducer', value);
  }

  void updateLocalScreenProducer(dynamic value) {
    localScreenProducer!.value = value;
    mediasfuParameters.localScreenProducer = value;
    updateSpecificState(
        widget.options.sourceParameters, 'localScreenProducer', value);
  }

  void updateGotAllVids(bool value) {
    gotAllVids.value = value;
    mediasfuParameters.gotAllVids = value;
    updateSpecificState(widget.options.sourceParameters, 'gotAllVids', value);
  }

  void updatePaginationHeightWidth(dynamic value) {
    if (!mounted) return;
    setState(() {
      paginationHeightWidth.value = value;
      mediasfuParameters.paginationHeightWidth = value;
      updateSpecificState(
          widget.options.sourceParameters, 'paginationHeightWidth', value);
    });
  }

  void updatePaginationDirection(String value) {
    paginationDirection.value = value;
    mediasfuParameters.paginationDirection = value;
    updateSpecificState(
        widget.options.sourceParameters, 'paginationDirection', value);
  }

  void updateGridSizes(GridSizes value) {
    gridSizes.value = value;
    mediasfuParameters.gridSizes = value;
    updateSpecificState(widget.options.sourceParameters, 'gridSizes', value);
  }

  void updateScreenForceFullDisplay(bool value) {
    screenForceFullDisplay.value = value;
    mediasfuParameters.screenForceFullDisplay = value;
    updateSpecificState(
        widget.options.sourceParameters, 'screenForceFullDisplay', value);
  }

  void updateMainGridStream(dynamic value) {
    if (!mounted) return;
    setState(() {
      mainGridStream.value = value;
      mediasfuParameters.mainGridStream = value;
      updateSpecificState(
          widget.options.sourceParameters, 'mainGridStream', value);
    });
  }

  void updateOtherGridStreams(dynamic value) {
    if (!mounted) return;
    setState(() {
      otherGridStreams = value;
      mediasfuParameters.otherGridStreams = value;
      updateSpecificState(
          widget.options.sourceParameters, 'otherGridStreams', value);
    });
  }

  void updateAudioOnlyStreams(dynamic value) {
    audioOnlyStreams.value = value;
    mediasfuParameters.audioOnlyStreams = value;
    updateSpecificState(
        widget.options.sourceParameters, 'audioOnlyStreams', value);
  }

  void updateVideoInputs(dynamic value) {
    videoInputs.value = value;
    mediasfuParameters.videoInputs = value;
    updateSpecificState(widget.options.sourceParameters, 'videoInputs', value);
  }

  void updateAudioInputs(dynamic value) {
    audioInputs.value = value;
    mediasfuParameters.audioInputs = value;
    updateSpecificState(widget.options.sourceParameters, 'audioInputs', value);
  }

  void updateMeetingProgressTime(dynamic value) {
    meetingProgressTime.value = value;
    mediasfuParameters.meetingProgressTime = value;
    updateSpecificState(
        widget.options.sourceParameters, 'meetingProgressTime', value);
  }

  void updateMeetingElapsedTime(dynamic value) {
    meetingElapsedTime.value = value;
    mediasfuParameters.meetingElapsedTime = value;
    updateSpecificState(
        widget.options.sourceParameters, 'meetingElapsedTime', value);
  }

  void updateRefParticipants(List<Participant> value) {
    refParticipants.value = value;
    mediasfuParameters.refParticipants = value;
    updateSpecificState(
        widget.options.sourceParameters, 'refParticipants', value);
  }

  void updateMessages(List<Message> value) {
    messages.value = value;
    mediasfuParameters.messages = value;
    updateSpecificState(widget.options.sourceParameters, 'messages', value);
  }

  void updateStartDirectMessage(bool value) {
    startDirectMessage.value = value;
    mediasfuParameters.startDirectMessage = value;
    updateSpecificState(
        widget.options.sourceParameters, 'startDirectMessage', value);
  }

  void updateDirectMessageDetails(Participant? value) {
    directMessageDetails.value = value;
    mediasfuParameters.directMessageDetails = value;
    updateSpecificState(
        widget.options.sourceParameters, 'directMessageDetails', value);
  }

  void updateShowMessagesBadge(bool value) {
    if (!mounted) return;
    setState(() {
      showMessagesBadge.value = value;
      mediasfuParameters.showMessagesBadge = value;
      updateSpecificState(
          widget.options.sourceParameters, 'showMessagesBadge', value);
    });
  }

  void updateAudioSetting(String value) {
    audioSetting.value = value;
    mediasfuParameters.audioSetting = value;
    updateSpecificState(widget.options.sourceParameters, 'audioSetting', value);
  }

  void updateVideoSetting(String value) {
    videoSetting.value = value;
    mediasfuParameters.videoSetting = value;
    updateSpecificState(widget.options.sourceParameters, 'videoSetting', value);
  }

  void updateScreenshareSetting(String value) {
    screenshareSetting.value = value;
    mediasfuParameters.screenshareSetting = value;
    updateSpecificState(
        widget.options.sourceParameters, 'screenshareSetting', value);
  }

  void updateChatSetting(String value) {
    chatSetting.value = value;
    mediasfuParameters.chatSetting = value;
    updateSpecificState(widget.options.sourceParameters, 'chatSetting', value);
  }

  void updateAutoWave(bool value) {
    autoWave.value = value;
    mediasfuParameters.autoWave = value;
    updateSpecificState(widget.options.sourceParameters, 'autoWave', value);
  }

  void updateForceFullDisplay(bool value) {
    forceFullDisplay.value = value;
    mediasfuParameters.forceFullDisplay = value;
    updateSpecificState(
        widget.options.sourceParameters, 'forceFullDisplay', value);
  }

  void updatePrevForceFullDisplay(bool value) {
    prevForceFullDisplay.value = value;
    mediasfuParameters.prevForceFullDisplay = value;
    updateSpecificState(
        widget.options.sourceParameters, 'prevForceFullDisplay', value);
  }

  void updatePrevMeetingDisplayType(String value) {
    prevMeetingDisplayType.value = value;
    mediasfuParameters.prevMeetingDisplayType = value;
    updateSpecificState(
        widget.options.sourceParameters, 'prevMeetingDisplayType', value);
  }

  void updateWaitingRoomFilter(String value) {
    waitingRoomFilter.value = value;
    mediasfuParameters.waitingRoomFilter = value;
    updateSpecificState(
        widget.options.sourceParameters, 'waitingRoomFilter', value);
  }

  void updateWaitingRoomList(List<WaitingRoomParticipant> value) {
    waitingRoomList.value = value;
    mediasfuParameters.waitingRoomList = value;
    updateSpecificState(
        widget.options.sourceParameters, 'waitingRoomList', value);
    filteredWaitingRoomList.value = value;
    mediasfuParameters.filteredWaitingRoomList = value;
    updateSpecificState(
        widget.options.sourceParameters, 'filteredWaitingRoomList', value);
    waitingRoomCounter.value = value.length;
    mediasfuParameters.waitingRoomCounter = value.length;
    updateSpecificState(
        widget.options.sourceParameters, 'waitingRoomCounter', value.length);
  }

  void updateWaitingRoomCounter(int value) {
    waitingRoomCounter.value = value;
    mediasfuParameters.waitingRoomCounter = value;
    updateSpecificState(
        widget.options.sourceParameters, 'waitingRoomCounter', value);
  }

  void updateRequestFilter(String value) {
    requestFilter.value = value;
    mediasfuParameters.requestFilter = value;
    updateSpecificState(
        widget.options.sourceParameters, 'requestFilter', value);
  }

  void updateRequestList(List<Request> value) {
    requestList.value = value;
    mediasfuParameters.requestList = value;
    updateSpecificState(widget.options.sourceParameters, 'requestList', value);
    filteredRequestList.value = value;
    mediasfuParameters.filteredRequestList = value;
    updateSpecificState(
        widget.options.sourceParameters, 'filteredRequestList', value);
    requestCounter.value = value.length;
    mediasfuParameters.requestCounter = value.length;
    updateSpecificState(
        widget.options.sourceParameters, 'requestCounter', value.length);
  }

  void updateRequestCounter(int value) {
    requestCounter.value = value;
    mediasfuParameters.requestCounter = value;
    updateSpecificState(
        widget.options.sourceParameters, 'requestCounter', value);
  }

  void updateAlertVisible(bool value) {
    alertVisible.value = value;
    mediasfuParameters.alertVisible = value;
    updateSpecificState(widget.options.sourceParameters, 'alertVisible', value);
  }

  void updateAlertMessage(String value) {
    alertMessage.value = value;
    mediasfuParameters.alertMessage = value;
    updateSpecificState(widget.options.sourceParameters, 'alertMessage', value);
  }

  void updateAlertType(String value) {
    alertType.value = value;
    mediasfuParameters.alertType = value;
    updateSpecificState(widget.options.sourceParameters, 'alertType', value);
  }

  void updateAlertDuration(int value) {
    alertDuration.value = value;
    mediasfuParameters.alertDuration = value;
    updateSpecificState(
        widget.options.sourceParameters, 'alertDuration', value);
  }

  void updateProgressTimerVisible(bool value) {
    progressTimerVisible.value = value;
    mediasfuParameters.progressTimerVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'progressTimerVisible', value);
  }

  void updateProgressTimerValue(int value) {
    progressTimerValue.value = value;
    mediasfuParameters.progressTimerValue = value;
    updateSpecificState(
        widget.options.sourceParameters, 'progressTimerValue', value);
  }

  void updateTotalReqWait(int value) {
    if (!mounted) return;
    setState(() {
      totalReqWait.value = value;
      mediasfuParameters.totalReqWait = value;
      updateSpecificState(
          widget.options.sourceParameters, 'totalReqWait', value);
    });
  }

  void updateIsMenuModalVisible(bool value) {
    isMenuModalVisible.value = value;
    mediasfuParameters.isMenuModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isMenuModalVisible', value);
  }

  void updateIsRecordingModalVisible(bool value) {
    isRecordingModalVisible.value = value;
    mediasfuParameters.isRecordingModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isRecordingModalVisible', value);
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
    mediasfuParameters.isSettingsModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isSettingsModalVisible', value);
  }

  void updateIsRequestsModalVisible(bool value) {
    isRequestsModalVisible.value = value;
    mediasfuParameters.isRequestsModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isRequestsModalVisible', value);
  }

  void updateIsWaitingModalVisible(bool value) {
    isWaitingModalVisible.value = value;
    mediasfuParameters.isWaitingModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isWaitingModalVisible', value);
  }

  void updateIsCoHostModalVisible(bool value) {
    isCoHostModalVisible.value = value;
    mediasfuParameters.isCoHostModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isCoHostModalVisible', value);
  }

  void updateIsMediaSettingsModalVisible(bool value) {
    isMediaSettingsModalVisible.value = value;
    mediasfuParameters.isMediaSettingsModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isMediaSettingsModalVisible', value);
  }

  void updateIsDisplaySettingsModalVisible(bool value) {
    isDisplaySettingsModalVisible.value = value;
    mediasfuParameters.isDisplaySettingsModalVisible = value;
    updateSpecificState(widget.options.sourceParameters,
        'isDisplaySettingsModalVisible', value);
  }

  void updateIsParticipantsModalVisible(bool value) {
    isParticipantsModalVisible.value = value;
    mediasfuParameters.isParticipantsModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isParticipantsModalVisible', value);
  }

  void updateIsMessagesModalVisible(bool value) {
    isMessagesModalVisible.value = value;
    mediasfuParameters.isMessagesModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isMessagesModalVisible', value);
  }

  void updateIsConfirmExitModalVisible(bool value) {
    isConfirmExitModalVisible.value = value;
    mediasfuParameters.isConfirmExitModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isConfirmExitModalVisible', value);
  }

  void updateIsConfirmHereModalVisible(bool value) {
    isConfirmHereModalVisible.value = value;
    mediasfuParameters.isConfirmHereModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isConfirmHereModalVisible', value);
  }

  void updateIsShareEventModalVisible(bool value) {
    isShareEventModalVisible.value = value;
    mediasfuParameters.isShareEventModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isShareEventModalVisible', value);
  }

  void updateIsLoadingModalVisible(bool value) {
    isLoadingModalVisible.value = value;
    mediasfuParameters.isLoadingModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isLoadingModalVisible', value);
  }

  void updateRecordingMediaOptions(String value) {
    recordingMediaOptions.value = value;
    mediasfuParameters.recordingMediaOptions = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingMediaOptions', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
    // Assuming 'recordUIChanged' is not part of mediasfuParameters
  }

  void updateRecordingAudioOptions(String value) {
    recordingAudioOptions.value = value;
    mediasfuParameters.recordingAudioOptions = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingAudioOptions', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingVideoOptions(String value) {
    recordingVideoOptions.value = value;
    mediasfuParameters.recordingVideoOptions = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingVideoOptions', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingVideoType(String value) {
    recordingVideoType.value = value;
    mediasfuParameters.recordingVideoType = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingVideoType', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingVideoOptimized(bool value) {
    recordingVideoOptimized.value = value;
    mediasfuParameters.recordingVideoOptimized = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingVideoOptimized', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingDisplayType(String value) {
    recordingDisplayType.value = value;
    mediasfuParameters.recordingDisplayType = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingDisplayType', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingAddHLS(bool value) {
    recordingAddHLS.value = value;
    mediasfuParameters.recordingAddHLS = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingAddHLS', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingNameTags(bool value) {
    recordingNameTags.value = value;
    mediasfuParameters.recordingNameTags = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingNameTags', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingBackgroundColor(String value) {
    recordingBackgroundColor.value = value;
    mediasfuParameters.recordingBackgroundColor = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingBackgroundColor', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingNameTagsColor(String value) {
    recordingNameTagsColor.value = value;
    mediasfuParameters.recordingNameTagsColor = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingNameTagsColor', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingAddText(bool value) {
    recordingAddText.value = value;
    mediasfuParameters.recordingAddText = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingAddText', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingCustomText(String value) {
    recordingCustomText.value = value;
    mediasfuParameters.recordingCustomText = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingCustomText', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingCustomTextPosition(String value) {
    recordingCustomTextPosition.value = value;
    mediasfuParameters.recordingCustomTextPosition = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingCustomTextPosition', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingCustomTextColor(String value) {
    recordingCustomTextColor.value = value;
    mediasfuParameters.recordingCustomTextColor = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingCustomTextColor', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateRecordingOrientationVideo(String value) {
    recordingOrientationVideo.value = value;
    mediasfuParameters.recordingOrientationVideo = value;
    updateSpecificState(
        widget.options.sourceParameters, 'recordingOrientationVideo', value);

    clearedToRecord.value = false;
    mediasfuParameters.clearedToRecord = false;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', false);

    recordUIChanged.value = !recordUIChanged.value;
  }

  void updateClearedToResume(bool value) {
    clearedToResume.value = value;
    mediasfuParameters.clearedToResume = value;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToResume', value);
  }

  void updateClearedToRecord(bool value) {
    clearedToRecord.value = value;
    mediasfuParameters.clearedToRecord = value;
    updateSpecificState(
        widget.options.sourceParameters, 'clearedToRecord', value);
  }

  void updateRecordState(String value) {
    recordState = value;
    mediasfuParameters.recordState = value;
    updateSpecificState(widget.options.sourceParameters, 'recordState', value);
    _updateRecordState();
  }

  void updateShowRecordButtons(bool value) {
    if (!mounted) return;
    setState(() {
      showRecordButtons.value = value;
      mediasfuParameters.showRecordButtons = value;
      updateSpecificState(
          widget.options.sourceParameters, 'showRecordButtons', value);
    });
  }

  void updateRecordingProgressTime(String value) {
    if (!mounted) return;
    setState(() {
      recordingProgressTime.value = value;
      mediasfuParameters.recordingProgressTime = value;
      updateSpecificState(
          widget.options.sourceParameters, 'recordingProgressTime', value);
    });
  }

  void updateAudioSwitching(bool value) {
    audioSwitching.value = value;
    mediasfuParameters.audioSwitching = value;
    updateSpecificState(
        widget.options.sourceParameters, 'audioSwitching', value);
  }

  void updateVideoSwitching(bool value) {
    videoSwitching.value = value;
    mediasfuParameters.videoSwitching = value;
    updateSpecificState(
        widget.options.sourceParameters, 'videoSwitching', value);
  }

  void updateVideoAlreadyOn(bool value) {
    videoAlreadyOn.value = value;
    mediasfuParameters.videoAlreadyOn = value;
    updateSpecificState(
        widget.options.sourceParameters, 'videoAlreadyOn', value);

    if (!mounted) return;
    setState(() {
      videoActive = value;
    });
  }

  void updateAudioAlreadyOn(bool value) {
    audioAlreadyOn.value = value;
    mediasfuParameters.audioAlreadyOn = value;
    updateSpecificState(
        widget.options.sourceParameters, 'audioAlreadyOn', value);

    if (!mounted) return;
    setState(() {
      micActive = value;
    });
  }

  void updateComponentSizes(ComponentSizes sizes) {
    final doUpdate = sizes.mainHeight != componentSizes.value.mainHeight ||
        sizes.otherHeight != componentSizes.value.otherHeight ||
        sizes.mainWidth != componentSizes.value.mainWidth ||
        sizes.otherWidth != componentSizes.value.otherWidth;

    if (doUpdate && validated) {
      componentSizes.value = sizes;
      mediasfuParameters.componentSizes = sizes;
      updateSpecificState(
          widget.options.sourceParameters, 'componentSizes', sizes);

      try {
        _updateControlHeight();
      } catch (error) {}

      try {
        onScreenChanges(OnScreenChangesOptions(
          changed: true,
          parameters: mediasfuParameters,
        ));
      } catch (error) {}

      try {
        prepopulateUserMedia(PrepopulateUserMediaOptions(
          name: hostLabel.value,
          parameters: mediasfuParameters,
        ));
      } catch (error) {}
    }
  }

  void updateHasCameraPermission(bool value) {
    hasCameraPermission.value = value;
    mediasfuParameters.hasCameraPermission = value;
    updateSpecificState(
        widget.options.sourceParameters, 'hasCameraPermission', value);
  }

  void updateHasAudioPermission(bool value) {
    hasAudioPermission.value = value;
    mediasfuParameters.hasAudioPermission = value;
    updateSpecificState(
        widget.options.sourceParameters, 'hasAudioPermission', value);
  }

  void updateTransportCreated(bool value) {
    transportCreated.value = value;
    mediasfuParameters.transportCreated = value;
    updateSpecificState(
        widget.options.sourceParameters, 'transportCreated', value);
  }

  void updateLocalTransportCreated(bool value) {
    localTransportCreated!.value = value;
    mediasfuParameters.localTransportCreated = value;
    updateSpecificState(
        widget.options.sourceParameters, 'localTransportCreated', value);
  }

  void updateTransportCreatedVideo(bool value) {
    transportCreatedVideo.value = value;
    mediasfuParameters.transportCreatedVideo = value;
    updateSpecificState(
        widget.options.sourceParameters, 'transportCreatedVideo', value);
  }

  void updateTransportCreatedAudio(bool value) {
    transportCreatedAudio.value = value;
    mediasfuParameters.transportCreatedAudio = value;
    updateSpecificState(
        widget.options.sourceParameters, 'transportCreatedAudio', value);
  }

  void updateTransportCreatedScreen(bool value) {
    transportCreatedScreen.value = value;
    mediasfuParameters.transportCreatedScreen = value;
    updateSpecificState(
        widget.options.sourceParameters, 'transportCreatedScreen', value);
  }

  void updateProducerTransport(Transport? value) {
    producerTransport.value = value;
    mediasfuParameters.producerTransport = value;
    updateSpecificState(
        widget.options.sourceParameters, 'producerTransport', value);
  }

  void updateLocalProducerTransport(Transport? value) {
    localProducerTransport!.value = value;
    mediasfuParameters.localProducerTransport = value;
    updateSpecificState(
        widget.options.sourceParameters, 'localProducerTransport', value);
  }

  void updateVideoProducer(Producer? value) {
    videoProducer.value = value;
    mediasfuParameters.videoProducer = value;
    updateSpecificState(
        widget.options.sourceParameters, 'videoProducer', value);
  }

  void updateLocalVideoProducer(Producer? value) {
    localVideoProducer!.value = value;
    mediasfuParameters.localVideoProducer = value;
    updateSpecificState(
        widget.options.sourceParameters, 'localVideoProducer', value);
  }

  void updateParams(ProducerOptionsType? value) {
    params.value = value;
    mediasfuParameters.params = value;
    updateSpecificState(widget.options.sourceParameters, 'params', value);
  }

  void updateVideoParams(ProducerOptionsType? value) {
    videoParams.value = value;
    mediasfuParameters.videoParams = value;
    updateSpecificState(widget.options.sourceParameters, 'videoParams', value);
  }

  void updateAudioParams(ProducerOptionsType? value) {
    audioParams.value = value;
    mediasfuParameters.audioParams = value;
    updateSpecificState(widget.options.sourceParameters, 'audioParams', value);
  }

  void updateAudioProducer(Producer? value) {
    audioProducer.value = value;
    mediasfuParameters.audioProducer = value;
    updateSpecificState(
        widget.options.sourceParameters, 'audioProducer', value);
  }

  void updateAudioLevel(double? value) {
    audioLevel.value = value ?? 0.0;
    mediasfuParameters.audioLevel = value ?? 0.0;
    updateSpecificState(
        widget.options.sourceParameters, 'audioLevel', value ?? 0.0);
  }

  void updateLocalAudioProducer(Producer? value) {
    localAudioProducer!.value = value;
    mediasfuParameters.localAudioProducer = value;
    updateSpecificState(
        widget.options.sourceParameters, 'localAudioProducer', value);
  }

  void updateConsumerTransports(List<TransportType> value) {
    consumerTransports.value = value;
    mediasfuParameters.consumerTransports = value;
    updateSpecificState(
        widget.options.sourceParameters, 'consumerTransports', value);
  }

  void updateConsumingTransports(List<String> value) {
    consumingTransports.value = value;
    mediasfuParameters.consumingTransports = value;
    updateSpecificState(
        widget.options.sourceParameters, 'consumingTransports', value);
  }

  void updatePolls(List<Poll> value) {
    polls.value = value;
    mediasfuParameters.polls = value;
    updateSpecificState(widget.options.sourceParameters, 'polls', value);
  }

  void updatePoll(Poll? value) {
    poll.value = value;
    mediasfuParameters.poll = value;
    updateSpecificState(widget.options.sourceParameters, 'poll', value);
  }

  void updateIsPollModalVisible(bool value) {
    isPollModalVisible.value = value;
    mediasfuParameters.isPollModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isPollModalVisible', value);
  }

  void updateBreakoutRooms(List<List<BreakoutParticipant>> value) {
    breakoutRooms.value = value;
    mediasfuParameters.breakoutRooms = value;
    updateSpecificState(
        widget.options.sourceParameters, 'breakoutRooms', value);
  }

  void updateCurrentRoomIndex(int value) {
    currentRoomIndex.value = value;
    mediasfuParameters.currentRoomIndex = value;
    updateSpecificState(
        widget.options.sourceParameters, 'currentRoomIndex', value);
  }

  void updateCanStartBreakout(bool value) {
    canStartBreakout.value = value;
    mediasfuParameters.canStartBreakout = value;
    updateSpecificState(
        widget.options.sourceParameters, 'canStartBreakout', value);
  }

  void updateBreakOutRoomStarted(bool value) {
    breakOutRoomStarted.value = value;
    mediasfuParameters.breakOutRoomStarted = value;
    updateSpecificState(
        widget.options.sourceParameters, 'breakOutRoomStarted', value);
  }

  void updateBreakOutRoomEnded(bool value) {
    breakOutRoomEnded.value = value;
    mediasfuParameters.breakOutRoomEnded = value;
    updateSpecificState(
        widget.options.sourceParameters, 'breakOutRoomEnded', value);
  }

  void updateHostNewRoom(int value) {
    hostNewRoom.value = value;
    mediasfuParameters.hostNewRoom = value;
    updateSpecificState(widget.options.sourceParameters, 'hostNewRoom', value);
  }

  void updateLimitedBreakRoom(List<BreakoutParticipant> value) {
    limitedBreakRoom.value = value;
    mediasfuParameters.limitedBreakRoom = value;
    updateSpecificState(
        widget.options.sourceParameters, 'limitedBreakRoom', value);
  }

  void updateMainRoomsLength(int value) {
    mainRoomsLength.value = value;
    mediasfuParameters.mainRoomsLength = value;
    updateSpecificState(
        widget.options.sourceParameters, 'mainRoomsLength', value);
  }

  void updateMemberRoom(int value) {
    memberRoom.value = value;
    mediasfuParameters.memberRoom = value;
    updateSpecificState(widget.options.sourceParameters, 'memberRoom', value);
  }

  void updateIsBreakoutRoomsModalVisible(bool value) {
    isBreakoutRoomsModalVisible.value = value;
    mediasfuParameters.isBreakoutRoomsModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isBreakoutRoomsModalVisible', value);
  }

// Update functions
  void updateCustomImage(String? value) {
    customImage.value = value;
    mediasfuParameters.customImage = value;
    updateSpecificState(widget.options.sourceParameters, 'customImage', value);
  }

  void updateSelectedImage(String? value) {
    selectedImage.value = value;
    mediasfuParameters.selectedImage = value;
    updateSpecificState(
        widget.options.sourceParameters, 'selectedImage', value);
  }

  void updateSegmentVideo(MediaStream? value) {
    segmentVideo.value = value;
    mediasfuParameters.segmentVideo = value;
    updateSpecificState(widget.options.sourceParameters, 'segmentVideo', value);
  }

  void updateSelfieSegmentation(dynamic value) {
    selfieSegmentation.value = value;
    mediasfuParameters.selfieSegmentation = value;
    updateSpecificState(
        widget.options.sourceParameters, 'selfieSegmentation', value);
  }

  void updatePauseSegmentation(bool value) {
    pauseSegmentation.value = value;
    mediasfuParameters.pauseSegmentation = value;
    updateSpecificState(
        widget.options.sourceParameters, 'pauseSegmentation', value);
  }

  void updateProcessedStream(MediaStream? value) {
    processedStream.value = value;
    mediasfuParameters.processedStream = value;
    updateSpecificState(
        widget.options.sourceParameters, 'processedStream', value);
  }

  void updateKeepBackground(bool value) {
    keepBackground.value = value;
    mediasfuParameters.keepBackground = value;
    updateSpecificState(
        widget.options.sourceParameters, 'keepBackground', value);
  }

  void updateBackgroundHasChanged(bool value) {
    backgroundHasChanged.value = value;
    mediasfuParameters.backgroundHasChanged = value;
    updateSpecificState(
        widget.options.sourceParameters, 'backgroundHasChanged', value);
  }

  void updateVirtualStream(MediaStream? value) {
    virtualStream.value = value;
    mediasfuParameters.virtualStream = value;
    updateSpecificState(
        widget.options.sourceParameters, 'virtualStream', value);
  }

  void updateMainCanvas(dynamic value) {
    mainCanvas.value = value;
    mediasfuParameters.mainCanvas = value;
    updateSpecificState(widget.options.sourceParameters, 'mainCanvas', value);
  }

  void updatePrevKeepBackground(bool value) {
    prevKeepBackground.value = value;
    mediasfuParameters.prevKeepBackground = value;
    updateSpecificState(
        widget.options.sourceParameters, 'prevKeepBackground', value);
  }

  void updateAppliedBackground(bool value) {
    appliedBackground.value = value;
    mediasfuParameters.appliedBackground = value;
    updateSpecificState(
        widget.options.sourceParameters, 'appliedBackground', value);
  }

  void updateIsBackgroundModalVisible(bool value) {
    isBackgroundModalVisible.value = value;
    mediasfuParameters.isBackgroundModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isBackgroundModalVisible', value);
  }

  void updateAutoClickBackground(bool value) {
    autoClickBackground.value = value;
    mediasfuParameters.autoClickBackground = value;
    updateSpecificState(
        widget.options.sourceParameters, 'autoClickBackground', value);
  }

  void updateWhiteboardUsers(List<WhiteboardUser> value) {
    whiteboardUsers.value = value;
    mediasfuParameters.whiteboardUsers = value;
    updateSpecificState(
        widget.options.sourceParameters, 'whiteboardUsers', value);
  }

  void updateCurrentWhiteboardIndex(int? value) {
    currentWhiteboardIndex.value = value;
    mediasfuParameters.currentWhiteboardIndex = value;
    updateSpecificState(
        widget.options.sourceParameters, 'currentWhiteboardIndex', value);
  }

  void updateCanStartWhiteboard(bool value) {
    canStartWhiteboard.value = value;
    mediasfuParameters.canStartWhiteboard = value;
    updateSpecificState(
        widget.options.sourceParameters, 'canStartWhiteboard', value);
  }

  void updateWhiteboardStarted(bool value) {
    whiteboardStarted.value = value;
    mediasfuParameters.whiteboardStarted = value;
    updateSpecificState(
        widget.options.sourceParameters, 'whiteboardStarted', value);
  }

  void updateWhiteboardEnded(bool value) {
    whiteboardEnded.value = value;
    mediasfuParameters.whiteboardEnded = value;
    updateSpecificState(
        widget.options.sourceParameters, 'whiteboardEnded', value);
  }

  void updateWhiteboardLimit(int value) {
    whiteboardLimit.value = value;
    mediasfuParameters.whiteboardLimit = value;
    updateSpecificState(
        widget.options.sourceParameters, 'whiteboardLimit', value);
  }

  void updateIsWhiteboardModalVisible(bool value) {
    isWhiteboardModalVisible.value = value;
    mediasfuParameters.isWhiteboardModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isWhiteboardModalVisible', value);
  }

  void updateIsConfigureWhiteboardModalVisible(bool value) {
    isConfigureWhiteboardModalVisible.value = value;
    mediasfuParameters.isConfigureWhiteboardModalVisible = value;
    updateSpecificState(widget.options.sourceParameters,
        'isConfigureWhiteboardModalVisible', value);
  }

  void updateShapes(List<dynamic> value) {
    shapes.value = value;
    mediasfuParameters.shapes = value;
    updateSpecificState(widget.options.sourceParameters, 'shapes', value);
  }

  void updateUseImageBackground(bool value) {
    useImageBackground.value = value;
    mediasfuParameters.useImageBackground = value;
    updateSpecificState(
        widget.options.sourceParameters, 'useImageBackground', value);
  }

  void updateRedoStack(List<dynamic> value) {
    redoStack.value = value;
    mediasfuParameters.redoStack = value;
    updateSpecificState(widget.options.sourceParameters, 'redoStack', value);
  }

  void updateUndoStack(List<String> value) {
    undoStack.value = value;
    mediasfuParameters.undoStack = value;
    updateSpecificState(widget.options.sourceParameters, 'undoStack', value);
  }

  void updateCanvasStream(MediaStream? value) {
    canvasStream.value = value;
    mediasfuParameters.canvasStream = value;
    updateSpecificState(widget.options.sourceParameters, 'canvasStream', value);
  }

  void updateCanvasWhiteboard(dynamic value) {
    canvasWhiteboard.value = value;
    mediasfuParameters.canvasWhiteboard = value;
    updateSpecificState(
        widget.options.sourceParameters, 'canvasWhiteboard', value);
  }

  void updateCanvasScreenboard(dynamic value) {
    canvasScreenboard.value = value;
    mediasfuParameters.canvasScreenboard = value;
    updateSpecificState(
        widget.options.sourceParameters, 'canvasScreenboard', value);
  }

  void updateProcessedScreenStream(MediaStream? value) {
    processedScreenStream.value = value;
    mediasfuParameters.processedScreenStream = value;
    updateSpecificState(
        widget.options.sourceParameters, 'processedScreenStream', value);
  }

  void updateAnnotateScreenStream(bool value) {
    annotateScreenStream.value = value;
    mediasfuParameters.annotateScreenStream = value;
    updateSpecificState(
        widget.options.sourceParameters, 'annotateScreenStream', value);
  }

  void updateMainScreenCanvas(dynamic value) {
    mainScreenCanvas.value = value;
    mediasfuParameters.mainScreenCanvas = value;
    updateSpecificState(
        widget.options.sourceParameters, 'mainScreenCanvas', value);
  }

  void updateIsScreenboardModalVisible(bool value) {
    isScreenboardModalVisible.value = value;
    mediasfuParameters.isScreenboardModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isScreenboardModalVisible', value);
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

  // Record Buttons
  List<AltButton> recordButtons = [];

  // Initialize Record Buttons
  // The record buttons are displayed in the control bar

  void initializeRecordButtons() {
    recordButtons = [
      // Play/Pause Button
      AltButton(
        // name: Pause,
        icon: Icons.play_circle_filled,
        active: !recordPaused.value,
        onPress: () => updateRecording(UpdateRecordingOptions(
          parameters: mediasfuParameters,
        )),
        activeColor: Colors.black,
        inActiveColor: Colors.black,
        alternateIcon: Icons.pause_circle_filled,
        show: true,
      ),
      // Stop Button
      AltButton(
        // name: Stop,
        icon: Icons.stop_circle,
        active: false,
        onPress: () => stopRecording(
          StopRecordingOptions(
            parameters: mediasfuParameters,
          ),
        ),
        activeColor: Colors.green,
        inActiveColor: Colors.black,
        show: true,
      ),
      // Timer Display
      AltButton(
        customComponent: Container(
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
        show: true,
      ),
      // Status Button
      AltButton(
        // name: Status,
        icon: Icons.circle,
        active: false,
        onPress: () => (),
        activeColor: Colors.black,
        inActiveColor: recordPaused.value == false ? Colors.red : Colors.yellow,
        show: true,
      ),
      // Settings Button
      AltButton(
        // name: Settings,
        icon: Icons.settings,
        active: false,
        onPress: () => launchRecording(
          LaunchRecordingOptions(
              updateIsRecordingModalVisible: updateIsRecordingModalVisible,
              isRecordingModalVisible: isRecordingModalVisible.value,
              stopLaunchRecord: stopLaunchRecord.value,
              canLaunchRecord: canLaunchRecord.value,
              recordingAudioSupport: recordingAudioSupport.value,
              recordingVideoSupport: recordingVideoSupport.value,
              updateCanRecord: updateCanRecord,
              updateClearedToRecord: updateClearedToRecord,
              recordStarted: recordStarted.value,
              recordPaused: recordPaused.value,
              localUIMode: widget.options.useLocalUIMode == true),
        ),

        activeColor: Colors.green,
        inActiveColor: Colors.black,
        show: true,
      )
    ];
  }

  List<CustomButton> customMenuButtons = [];

  void initializeCustomMenuButtons() {
    customMenuButtons = [
      // Record Button
      CustomButton(
        icon: Icons.fiber_manual_record,
        text: 'Record',
        action: () {
          // Action for the Record button
          launchRecording(
            LaunchRecordingOptions(
                updateIsRecordingModalVisible: updateIsRecordingModalVisible,
                isRecordingModalVisible: isRecordingModalVisible.value,
                stopLaunchRecord: stopLaunchRecord.value,
                canLaunchRecord: canLaunchRecord.value,
                recordingAudioSupport: recordingAudioSupport.value,
                recordingVideoSupport: recordingVideoSupport.value,
                updateCanRecord: updateCanRecord,
                updateClearedToRecord: updateClearedToRecord,
                recordStarted: recordStarted.value,
                recordPaused: recordPaused.value,
                localUIMode: widget.options.useLocalUIMode == true),
          );
        },
        show: !showRecordButtons.value && islevel.value == '2',
      ),
      // Custom Record Buttons
      CustomButton(
        // You can define custom UI components directly in Flutter
        // In this case, you'll need to handle the custom UI rendering separately
        // You can replace this with a custom widget/component as needed
        customComponent: ControlButtonsAltComponent(
          options: ControlButtonsAltComponentOptions(
              buttons: recordButtons,
              direction: 'horizontal',
              showAspect: true,
              location: 'bottom',
              position: 'middle'),
        ),
        show: showRecordButtons.value && islevel.value == '2',
        action: () {},
      ),
      // Event Settings Button
      CustomButton(
        icon: Icons.settings,
        text: 'Event Settings',
        action: () {
          // Action for the Event Settings button
          launchSettings(
            LaunchSettingsOptions(
                updateIsSettingsModalVisible: updateIsSettingsModalVisible,
                isSettingsModalVisible: isSettingsModalVisible.value),
          );
        },
        show: islevel.value == '2',
      ),
      // Requests Button
      CustomButton(
        icon: Icons.group,
        text: 'Requests',
        action: () {
          // Action for the Requests button
          launchRequests(
            LaunchRequestsOptions(
              updateIsRequestsModalVisible: updateIsRequestsModalVisible,
              isRequestsModalVisible: isRequestsModalVisible.value,
            ),
          );
        },
        show: islevel.value == '2' ||
            (coHost.value == member.value &&
                coHostResponsibility.value
                    .any((item) => item.name == 'media' && item.value == true)),
      ),
      // Waiting Button
      CustomButton(
        icon: Icons.access_time,
        text: 'Waiting',
        action: () {
          // Action for the Waiting button
          launchWaiting(
            LaunchWaitingOptions(
              updateIsWaitingModalVisible: updateIsWaitingModalVisible,
              isWaitingModalVisible: isWaitingModalVisible.value,
            ),
          );
        },
        show: islevel.value == '2' ||
            (coHost.value == member.value &&
                coHostResponsibility.value.any(
                    (item) => item.name == 'waiting' && item.value == true)),
      ),
      // Co-host Button
      CustomButton(
        icon: Icons.person_add,
        text: 'Co-host',
        action: () {
          // Action for the Co-host button
          launchCoHost(
            LaunchCoHostOptions(
              updateIsCoHostModalVisible: updateIsCoHostModalVisible,
              isCoHostModalVisible: isCoHostModalVisible.value,
            ),
          );
        },
        show: islevel.value == '2',
      ),
      //Set Media Button
      CustomButton(
        icon: Icons.settings,
        text: 'Set Media',
        action: () {
          // Action for the Set Media button
          launchMediaSettings(
            LaunchMediaSettingsOptions(
              updateIsMediaSettingsModalVisible:
                  updateIsMediaSettingsModalVisible,
              isMediaSettingsModalVisible: isMediaSettingsModalVisible.value,
              audioInputs: audioInputs.value,
              videoInputs: videoInputs.value,
              updateAudioInputs: updateAudioInputs,
              updateVideoInputs: updateVideoInputs,
              videoAlreadyOn: videoAlreadyOn.value,
              audioAlreadyOn: audioAlreadyOn.value,
              onWeb: kIsWeb,
              updateIsLoadingModalVisible: updateIsLoadingModalVisible,
            ),
          );
        },
        show: true,
      ),
      // Display Button
      CustomButton(
        icon: Icons.desktop_windows,
        text: 'Display',
        action: () {
          // Action for the Display button
          launchDisplaySettings(LaunchDisplaySettingsOptions(
            updateIsDisplaySettingsModalVisible:
                updateIsDisplaySettingsModalVisible,
            isDisplaySettingsModalVisible: isDisplaySettingsModalVisible.value,
          ));
        },
        show: true,
      ),
      CustomButton(
        icon: Icons.poll,
        text: 'Poll',
        action: () {
          // Action for the Poll button
          launchPoll(
            LaunchPollOptions(
              updateIsPollModalVisible: updateIsPollModalVisible,
              isPollModalVisible: isPollModalVisible.value,
            ),
          );
        },
        show: true,
      ),
      // Breakout Rooms Button
      CustomButton(
        icon: Icons.group_outlined,
        text: 'Breakout Rooms',
        action: () {
          // Action for the Breakout Rooms button
          launchBreakoutRooms(
            LaunchBreakoutRoomsOptions(
              updateIsBreakoutRoomsModalVisible:
                  updateIsBreakoutRoomsModalVisible,
              isBreakoutRoomsModalVisible: isBreakoutRoomsModalVisible.value,
            ),
          );
        },
        show: islevel.value == '2',
      ),
    ];
  }

  // Control Buttons
  List<ControlButton> controlButtons = [];

  // Initialize Control Buttons
  // The control buttons are displayed in the control bar

  void initializeControlButtons() {
    controlButtons = [
      ControlButton(
        icon: Icons.mic_off_outlined,
        alternateIcon: Icons.mic_outlined,
        active: micActive,
        onPress: () =>
            clickAudio(ClickAudioOptions(parameters: mediasfuParameters)),
        activeColor: Colors.green,
        inActiveColor: Colors.red,
        disabled: audioSwitching.value,
      ),
      ControlButton(
        icon: Icons.videocam_off_outlined,
        alternateIcon: Icons.videocam_outlined,
        active: videoActive,
        onPress: () =>
            clickVideo(ClickVideoOptions(parameters: mediasfuParameters)),
        activeColor: Colors.green,
        inActiveColor: Colors.red,
        disabled: videoSwitching.value,
      ),
      ControlButton(
        icon: Icons.desktop_windows_outlined,
        alternateIcon: Icons.desktop_access_disabled,
        active: screenShareActive,
        onPress: () => clickScreenShare(
            ClickScreenShareOptions(parameters: mediasfuParameters)),
        activeColor: Colors.green,
        inActiveColor: Colors.red,
        disabled: false,
      ),
      ControlButton(
        icon: Icons.phone_outlined,
        active: endCallActive,
        onPress: () => launchConfirmExit(
          LaunchConfirmExitOptions(
            updateIsConfirmExitModalVisible: updateIsConfirmExitModalVisible,
            isConfirmExitModalVisible: isConfirmExitModalVisible.value,
          ),
        ),
        activeColor: Colors.green,
        inActiveColor: Colors.red,
        disabled: false,
      ),
      ControlButton(
        icon: Icons.group_outlined,
        active: participantsActive,
        onPress: () => launchParticipants(
          LaunchParticipantsOptions(
            updateIsParticipantsModalVisible: updateIsParticipantsModalVisible,
            isParticipantsModalVisible: isParticipantsModalVisible.value,
          ),
        ),
        activeColor: Colors.black,
        inActiveColor: Colors.black,
        disabled: false,
      ),
      ControlButton(
        customComponent: Stack(
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
        onPress: () => launchMenuModal(
          LaunchMenuModalOptions(
            updateIsMenuModalVisible: updateIsMenuModalVisible,
            isMenuModalVisible: isMenuModalVisible.value,
          ),
        ),
      ),
      ControlButton(
        customComponent: Stack(
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
        onPress: () => launchMessages(
          LaunchMessagesOptions(
            updateIsMessagesModalVisible: updateIsMessagesModalVisible,
            isMessagesModalVisible: isMessagesModalVisible.value,
          ),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    isPortrait.removeListener(_handleOrientationChange);
    super.dispose();
  }

  void _handleOrientationChange() {
    try {
      final mediaQuery = MediaQuery.of(context);
      final safeAreaInsets =
          mediaQuery.padding + mediaQuery.systemGestureInsets;

      final parentWidth = mediaQuery.size.width * mainHeightWidth;
      final showControls = (eventType.value == EventType.webinar) ||
          eventType.value == EventType.conference;
      final parentHeight = showControls
          ? mediaQuery.size.height * 1.0 - controlHeight.value
          : mediaQuery.size.height * safeAreaInsets.top;
      const doStack = true;

      bool isWideScreen = parentWidth > 768;

      if (!isWideScreen && parentWidth > 1.5 * parentHeight) {
        isWideScreen = true;
      }

      ComponentSizes computeDimensions() {
        if (doStack) {
          return isWideScreen
              ? ComponentSizes(
                  mainHeight: parentHeight,
                  otherHeight: parentHeight,
                  mainWidth: (mainHeightWidth / 100) * parentWidth,
                  otherWidth: ((100 - mainHeightWidth) / 100) * parentWidth,
                )
              : ComponentSizes(
                  mainHeight: (mainHeightWidth / 100) * parentHeight,
                  otherHeight: ((100 - mainHeightWidth) / 100) * parentHeight,
                  mainWidth: parentWidth,
                  otherWidth: parentWidth,
                );
        }
      }

      final dimensions = computeDimensions();

      // Update component sizes when parent dimensions, main size, or stacking mode changes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateComponentSizes(dimensions);
      });

      _updateControlHeight();
    } catch (_) {
      // do nothing
    }
  }

  Future<void> joinroom({
    required io.Socket? socket,
    required String roomName,
    required String islevel,
    required String member,
    required String sec,
    required String apiUserName,
    bool isLocal = false,
  }) async {
    // Join room and get data from server
    try {
      ResponseJoinRoom? data;

      if (!isLocal) {
        data = await joinRoom(
          socket: socket,
          roomName: roomName,
          islevel: islevel,
          member: member,
          sec: sec,
          apiUserName: apiUserName,
        );
      } else {
        ResponseJoinLocalRoom localData = await joinLocalRoom(
          JoinLocalRoomOptions(
            socket: socket,
            roomName: roomName,
            islevel: islevel,
            member: member,
            sec: sec,
            apiUserName: apiUserName,
            parameters: PreJoinPageParameters(
              imgSrc: widget.options.imgSrc ??
                  'https://mediasfu.com/images/logo192.png',
              showAlert: showAlert,
              updateIsLoadingModalVisible: updateIsLoadingModalVisible,
              connectSocket: connectSocket,
              connectLocalSocket: connectLocalSocket,
              updateSocket: updateSocket,
              updateLocalSocket: updateLocalSocket,
              updateValidated: updateValidated,
              updateApiUserName: updateApiUserName,
              updateApiToken: updateApiToken,
              updateLink: updateLink,
              updateRoomName: updateRoomName,
              updateMember: updateMember,
            ),
            checkConnect: widget.options.localLink!.isNotEmpty &&
                widget.options.connectMediaSFU == true &&
                !link.value.contains('mediasfu.com'),
            localLink: widget.options.localLink,
            joinMediaSFURoom: widget.options.joinMediaSFURoom!,
          ),
        );

        data = await createResponseJoinRoom(
          CreateResponseJoinRoomOptions(localRoom: localData),
        );
      }

      Future<void> updateAndComplete(ResponseJoinRoom data) async {
        // Update room parameters
        try {
          // Check if roomRecvIPs is not empty
          if (data.roomRecvIPs == null ||
              (data.roomRecvIPs != null && data.roomRecvIPs!.isEmpty)) {
            data.roomRecvIPs = ['none'];
            if (link.value.isNotEmpty &&
                link.value.contains('mediasfu.com') &&
                !isLocal) {
              updateMembersReceived(false);

              // Community Edition Only
              ReceiveAllPipedTransportsType receiveAllPipedTransports =
                  mediasfuParameters.receiveAllPipedTransports;

              // Initialize piped transports
              final optionsReceive = ReceiveAllPipedTransportsOptions(
                community: true,
                nsock: mediasfuParameters.socket!,
                parameters: mediasfuParameters,
              );
              await receiveAllPipedTransports(optionsReceive);
            }
          }

          updateRoomData(data);

          try {
            updateRoomParametersClient(
              options: UpdateRoomParametersClientOptions(
                parameters: mediasfuParameters,
              ),
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error updating room parameters: $error');
            }
          }

          if (data.isHost == true) {
            updateIslevel('2');
          } else {
            // Issue with isHost for local room
            if (islevel != '2') {
              updateIslevel('1');
            }
          }

          if (data.secureCode != null && data.secureCode != '') {
            updateAdminPasscode(data.secureCode!);
          }

          // Create device client
          if (data.rtpCapabilities != null) {
            try {
              Device? device_ = await createDeviceClient(
                options: CreateDeviceClientOptions(
                  rtpCapabilities: data.rtpCapabilities,
                ),
              );

              if (device_ != null) {
                updateDevice(device_);
              }
            } catch (error) {}
          }
        } catch (error) {
          if (kDebugMode) {
            print('Error in updateAndComplete: $error');
          }
        }
      }

      if (data.success == true) {
        if (link.value.isNotEmpty &&
            link.value.contains('mediasfu.com') &&
            isLocal) {
          roomData.value = data;
          return;
        } else if (link.value.isNotEmpty &&
            link.value.contains('mediasfu.com') &&
            !isLocal) {
          // Update roomData
          if (roomData.value != null &&
              roomData.value!.rtpCapabilities != null) {
            // Updating only the recording and meeting room parameters
            roomData.value!.recordingParams = data.recordingParams;
            roomData.value!.meetingRoomParams = data.meetingRoomParams;
          } else {
            roomData.value = data;
          }
        } else {
          // Update roomData
          roomData.value = data;
          if (!link.value.contains('mediasfu.com')) {
            roomData.value!.meetingRoomParams = data.meetingRoomParams;
          }
        }

        updateRoomData(roomData.value!);
        await updateAndComplete(roomData.value!);
      } else {
        if (link.value.isNotEmpty &&
            link.value.contains('mediasfu.com') &&
            !isLocal) {
          // Join local room
          if (roomData.value != null) {
            await updateAndComplete(roomData.value!);
          }
          return;
        }

        // Might be a wrong room name or room is full or other error; check reason in data object if available
        try {
          if (data.reason != null) {
            showAlert(
              message: data.reason!,
              type: 'danger',
              duration: 3000,
            );
          }
        } catch (error) {
          // Handle error if needed
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error joining room: $error');
      }
    }
  }

  Future<void> disconnectAllSockets(List<ConsumeSocket> consumeSockets) async {
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
          await clickVideo(
            ClickVideoOptions(
              parameters: mediasfuParameters,
            ),
          );
        }
      } catch (e) {}

      try {
        if (audioAlreadyOn.value) {
          clickAudio(
            ClickAudioOptions(
              parameters: mediasfuParameters,
            ),
          );
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

      updateStatesToInitialValues(mediasfuParameters, initialValues);
      updateMeetingProgressTime('00:00:00');
      updateMeetingElapsedTime(0);
      updateRecordingProgressTime('00:00:00');
      updateRecordElapsedTime(0);
      updateShowRecordButtons(false);
      // Delay before updating validated
      await Future.delayed(const Duration(milliseconds: 1000));
      updateValidated(false);
    }

    Future<io.Socket?> connectsocket(String apiUserName, String token,
        {bool skipSockets = false}) async {
      // Define socketDefault and socketAlt
      io.Socket? socketDefault = socket.value;
      io.Socket? socketAlt = (widget.options.connectMediaSFU! &&
              localSocket.value != null &&
              localSocket.value!.id != null)
          ? localSocket.value
          : socketDefault;

      if (socketDefault != null &&
          socketDefault.id != null &&
          socketDefault.id!.isNotEmpty) {
        if (!skipSockets) {
          socketDefault.on('disconnect', (_) async {
            // Handle disconnect event
            try {
              await closeAndReset();
            } catch (e) {}

            disconnect(
              DisconnectOptions(
                onWeb: kIsWeb,
                showAlert: showAlert,
                updateValidated: updateValidated,
                redirectURL: redirectURL.value,
              ),
            );
          });

          socketDefault.on('allMembers', (membersData) async {
            try {
              // Handle 'allMembers' event
              AllMembersData response = AllMembersData.fromJson(membersData);
              if (membersData != null) {
                await allMembers(
                  AllMembersOptions(
                    apiUserName: apiUserName,
                    apiKey:
                        "null", //not recommended - use apiToken instead. Use for testing/development only
                    apiToken: token,
                    members: response.members,
                    requests: response.requests,
                    coHost: response.coHost ?? coHost.value,
                    coHostRes: response.coHostResponsibilities,
                    parameters: mediasfuParameters,
                    consumeSockets: consumeSockets.value,
                  ),
                );
              }
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling allMembers event: $error');
              }
            }
          });

          socketDefault.on('allMembersRest', (membersData) async {
            // Handle 'allMembersRest' event
            try {
              AllMembersRestData response =
                  AllMembersRestData.fromJson(membersData);
              if (membersData != null) {
                await allMembersRest(AllMembersRestOptions(
                  apiUserName: apiUserName,
                  apiKey:
                      'null', //not recommended - use apiToken instead. Use for testing/development only
                  members: response.members,
                  apiToken: token,
                  settings: response.settings,
                  coHost: response.coHost ?? coHost.value,
                  coHostRes: response.coHostResponsibilities,
                  parameters: mediasfuParameters,
                  consumeSockets: consumeSockets.value,
                ));
              }
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling allMembersRest event: $error');
              }
            }
          });

          socketDefault.on('userWaiting', (data) async {
            try {
              // Handle 'userWaiting' event
              userWaiting(
                UserWaitingOptions(
                  name: data['name'],
                  showAlert: showAlert,
                  totalReqWait: totalReqWait.value,
                  updateTotalReqWait: updateTotalReqWait,
                ),
              );
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling userWaiting event: $error');
              }
            }
          });

          socketDefault.on('personJoined', (data) async {
            try {
              // Handle 'personJoined' event
              personJoined(
                PersonJoinedOptions(
                  name: data['name'],
                  showAlert: showAlert,
                ),
              );
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling personJoined event: $error');
              }
            }
          });

          socketDefault.on('allWaitingRoomMembers', (waitingData) async {
            try {
              List<WaitingRoomParticipant> waitingParticipants = [];
              if (waitingData['waitingParticipants'] != null ||
                  waitingData['waitingParticipantss'] != null) {
                dynamic waitingList = waitingData['waitingParticipants'] ??
                    waitingData['waitingParticipantss'] ??
                    waitingData['waitingParticipants'];
                // Convert waitingParticipants to a List of WaitingRoomParticipant objects
                waitingParticipants = (waitingList as List)
                    .map((item) => WaitingRoomParticipant.fromMap(item))
                    .toList();
              } else {
                waitingParticipants = waitingRoomList.value;
              }

              // Handle 'allWaitingRoomMembers' event
              allWaitingRoomMembers(
                AllWaitingRoomMembersOptions(
                  waitingParticipants: waitingParticipants,
                  updateWaitingRoomList: updateWaitingRoomList,
                  updateTotalReqWait: updateTotalReqWait,
                ),
              );
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling allWaitingRoomMembers event: $error');
              }
            }
          });

          socketDefault.on('ban', (data) async {
            // Handle 'ban' event
            try {
              banParticipant(
                BanParticipantOptions(
                  name: data['name'],
                  parameters: mediasfuParameters,
                ),
              );
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling ban event: $error');
              }
            }
          });

          socketDefault.on('updatedCoHost', (data) async {
            // Handle 'updatedCoHost' event
            try {
              List<CoHostResponsibility>? coHostResponsibilities = [];
              // Parse coHost responsibilities from incoming data
              if (data['coHostResponsibilities'] != null) {
                coHostResponsibilities =
                    (data['coHostResponsibilities'] as List<dynamic>)
                        .map((item) => CoHostResponsibility.fromMap(
                            item as Map<String, dynamic>))
                        .toList();
              } else {
                coHostResponsibilities = coHostResponsibility.value;
              }

              updatedCoHost(
                UpdatedCoHostOptions(
                  eventType: eventType.value,
                  islevel: islevel.value,
                  member: member.value,
                  youAreCoHost: youAreCoHost.value,
                  updateCoHost: updateCoHost,
                  updateCoHostResponsibility: updateCoHostResponsibility,
                  updateYouAreCoHost: updateYouAreCoHost,
                  coHost: data['coHost'] ?? coHost.value,
                  coHostResponsibility: coHostResponsibilities,
                  showAlert: showAlert,
                ),
              );
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling updatedCoHost event: $error');
              }
            }
          });

          socketDefault.on('participantRequested', (data) async {
            try {
              Request request = Request.fromMap(data['userRequest']);
              // Handle 'participantRequested' event
              participantRequested(
                ParticipantRequestedOptions(
                  userRequest: request,
                  requestList: requestList.value,
                  waitingRoomList: waitingRoomList.value,
                  updateRequestList: updateRequestList,
                  updateTotalReqWait: updateTotalReqWait,
                ),
              );
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling participantRequested event: $error');
              }
            }
          });

          socketDefault.on('screenProducerId', (data) async {
            // Handle 'screenProducerId' event
            try {
              screenProducerId(ScreenProducerIdOptions(
                producerId: data['producerId'],
                screenId: screenId.value,
                membersReceived: membersReceived.value,
                shareScreenStarted: shareScreenStarted.value,
                deferScreenReceived: deferScreenReceived.value,
                participants: participants.value,
                updateScreenId: updateScreenId,
                updateShareScreenStarted: updateShareScreenStarted,
                updateDeferScreenReceived: updateDeferScreenReceived,
              ));
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling screenProducerId event: $error');
              }
            }
          });

          socketDefault.on('updateMediaSettings', (data) async {
            // Handle 'updateMediaSettings' event
            try {
              Settings settings = Settings.fromList(data['settings']);
              updateMediaSettings(
                UpdateMediaSettingsOptions(
                  settings: settings,
                  updateAudioSetting: updateAudioSetting,
                  updateVideoSetting: updateVideoSetting,
                  updateScreenshareSetting: updateScreenshareSetting,
                  updateChatSetting: updateChatSetting,
                ),
              );
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling updateMediaSettings event: $error');
              }
            }
          });

          socketDefault.on('producer-media-paused', (data) async {
            // Handle 'producer-media-paused' event
            try {
              await producerMediaPaused(
                ProducerMediaPausedOptions(
                  producerId: data['producerId'],
                  kind: data['kind'],
                  name: data['name'],
                  parameters: mediasfuParameters,
                ),
              );
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling producer-media-paused event: $error');
              }
            }
          });

          socketDefault.on('producer-media-resumed', (data) async {
            // Handle 'producer-media-resumed' event
            try {
              await producerMediaResumed(
                ProducerMediaResumedOptions(
                    kind: data['kind'],
                    name: data['name'],
                    parameters: mediasfuParameters),
              );
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling producer-media-resumed event: $error');
              }
            }
          });

          socketDefault.on('producer-media-closed', (data) async {
            // Handle 'producer-media-closed' event
            try {
              await producerMediaClosed(
                ProducerMediaClosedOptions(
                  producerId: data['producerId'],
                  kind: data['kind'],
                  parameters: mediasfuParameters,
                ),
              );
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling producer-media-closed event: $error');
              }
            }
          });

          socketDefault.on('controlMediaHost', (data) async {
            // Handle 'controlMediaHost' event
            try {
              controlMediaHost(ControlMediaHostOptions(
                type: data['type'],
                parameters: mediasfuParameters,
              ));
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling controlMediaHost event: $error');
              }
            }
          });

          socketDefault.on('meetingEnded', (_) async {
            // Handle 'meetingEnded' event
            try {
              await closeAndReset();
            } catch (e) {}

            await meetingEnded(
                options: MeetingEndedOptions(
              showAlert: showAlert,
              redirectURL: redirectURL.value,
              updateValidated: updateValidated,
              onWeb: kIsWeb,
              eventType: eventType.value,
            ));
          });

          socketDefault.on('disconnectUserSelf', (_) async {
            // Handle 'disconnectUserSelf' event
            try {
              await disconnectUserSelf(
                DisconnectUserSelfOptions(
                  socket: socketDefault,
                  member: member.value,
                  roomName: roomName.value,
                ),
              );
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling disconnectUserSelf event: $error');
              }
            }
          });

          socketDefault.on('receiveMessage', (data) async {
            // Handle 'receiveMessage' event
            try {
              Message message = Message.fromMap(data['message']);
              await receiveMessage(
                ReceiveMessageOptions(
                  message: message,
                  messages: messages.value,
                  participantsAll: participants.value,
                  member: member.value,
                  eventType: eventType.value,
                  islevel: islevel.value,
                  coHost: coHost.value,
                  updateMessages: updateMessages,
                  updateShowMessagesBadge: updateShowMessagesBadge,
                ),
              );
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling receiveMessage event: $error');
              }
            }
          });

          socketDefault.on('meetingTimeRemaining', (data) async {
            // Handle 'meetingTimeRemaining' event
            try {
              await meetingTimeRemaining(
                options: MeetingTimeRemainingOptions(
                    timeRemaining: data['timeRemaining'],
                    eventType: eventType.value,
                    showAlert: showAlert),
              );
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling meetingTimeRemaining event: $error');
              }
            }
          });

          socketDefault.on('meetingStillThere', (data) async {
            // Handle 'meetingStillThere' event
            try {
              await meetingStillThere(
                  options: MeetingStillThereOptions(
                updateIsConfirmHereModalVisible:
                    updateIsConfirmHereModalVisible,
              ));
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling meetingStillThere event: $error');
              }
            }
          });

          socketDefault.on('updateConsumingDomains', (data) async {
            // Handle 'updateConsumingDomains' event
            try {
              UpdateConsumingDomainsData updateConsumingDomainsData =
                  UpdateConsumingDomainsData.fromJson(data);

              updateConsumingDomains(UpdateConsumingDomainsOptions(
                domains: updateConsumingDomainsData.domains,
                altDomains: updateConsumingDomainsData.altDomains,
                apiUserName: apiUserName,
                apiToken: token,
                apiKey: "",
                parameters: mediasfuParameters,
              ));
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling updateConsumingDomains event: $error');
              }
            }
          });

          socketDefault.on('hostRequestResponse', (data) async {
            // Handle 'hostRequestResponse' event
            try {
              RequestResponse requestResponse =
                  RequestResponse.fromMap(data['requestResponse']);
              hostRequestResponse(
                HostRequestResponseOptions(
                  requestResponse: requestResponse,
                  showAlert: showAlert,
                  requestList: requestList.value,
                  updateRequestList: updateRequestList,
                  updateMicAction: updateMicAction,
                  updateVideoAction: updateVideoAction,
                  updateScreenAction: updateScreenAction,
                  updateChatAction: updateChatAction,
                  updateAudioRequestState: updateAudioRequestState,
                  updateVideoRequestState: updateVideoRequestState,
                  updateScreenRequestState: updateScreenRequestState,
                  updateChatRequestState: updateChatRequestState,
                  updateAudioRequestTime: updateAudioRequestTime,
                  updateVideoRequestTime: updateVideoRequestTime,
                  updateScreenRequestTime: updateScreenRequestTime,
                  updateChatRequestTime: updateChatRequestTime,
                  updateRequestIntervalSeconds:
                      updateRequestIntervalSeconds.value,
                ),
              );
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling hostRequestResponse event: $error');
              }
            }
          });

          socketDefault.on('pollUpdated', (data) async {
            try {
              PollUpdatedData pollUpdatedData = PollUpdatedData.fromMap(data);

              await pollUpdated(PollUpdatedOptions(
                data: pollUpdatedData,
                polls: polls.value,
                poll: poll.value,
                member: member.value,
                islevel: islevel.value,
                showAlert: showAlert,
                updatePolls: updatePolls,
                updatePoll: updatePoll,
                updateIsPollModalVisible: updateIsPollModalVisible,
              ));
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling pollUpdated event: $error');
              }
            }
          });

          socketDefault.on('breakoutRoomUpdated', (data) async {
            try {
              BreakoutRoomUpdatedData breakoutRoomUpdatedData =
                  BreakoutRoomUpdatedData.fromMap(data);

              await breakoutRoomUpdated(BreakoutRoomUpdatedOptions(
                data: breakoutRoomUpdatedData,
                parameters: mediasfuParameters,
              ));
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling breakoutRoomUpdated event: $error');
              }
            }
          });
        }

        if (skipSockets) {
          // Remove specific event listeners from socketDefault and socketAlt
          List<String> events = [
            'roomRecordParams',
            'startRecords',
            'reInitiateRecording',
            'RecordingNotice',
            'timeLeftRecording',
            'stoppedRecording',
          ];
          for (var event in events) {
            socketDefault.off(event);
            socketAlt?.off(event);
          }
        }

        socketAlt!.on('roomRecordParams', (data) async {
          try {
            RecordParameters roomRecordParameters =
                RecordParameters.fromMap(data);
            // Handle 'roomRecordParams' event
            roomRecordParams(
              RoomRecordParamsOptions(
                  recordParams: roomRecordParameters,
                  parameters: mediasfuParameters),
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling roomRecordParams event: $error');
            }
          }
        });

        socketAlt.on('startRecords', (_) async {
          // Handle 'startRecords' event
          try {
            startRecords(
              StartRecordsOptions(
                roomName: roomName.value,
                member: member.value,
                socket: socketAlt,
              ),
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling startRecords event: $error');
            }
          }
        });

        socketAlt.on('reInitiateRecording', (_) async {
          // Handle 'reInitiateRecording' event
          try {
            reInitiateRecording(
              ReInitiateRecordingOptions(
                roomName: roomName.value,
                member: member.value,
                socket: socketAlt,
                adminRestrictSetting: adminRestrictSetting.value,
              ),
            );
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling reInitiateRecording event: $error');
            }
          }
        });

        socketAlt.on('RecordingNotice', (data) async {
          // Handle 'RecordingNotice' event
          try {
            UserRecordingParams? userRecording;
            if (data.containsKey('userRecordingParam') &&
                (data['userRecordingParam'] != null &&
                    data['userRecordingParam'].isNotEmpty)) {
              userRecording =
                  UserRecordingParams.fromMap(data['userRecordingParam']);
            } else {
              userRecording = userRecordingParams.value;
            }

            await recordingNotice(RecordingNoticeOptions(
              state: data['state'],
              userRecordingParam: userRecording,
              pauseCount: data['pauseCount'] ?? 0,
              timeDone: data['timeDone'] ?? 0,
              parameters: mediasfuParameters,
            ));
          } catch (error) {
            if (kDebugMode) {
              //print('Error handling RecordingNotice event: $error');
            }
          }
        });

        socketAlt.on('timeLeftRecording', (data) async {
          // Handle 'timeLeftRecording' event
          try {
            timeLeftRecording(TimeLeftRecordingOptions(
              timeLeft: data['timeLeft'],
              showAlert: showAlert,
            ));
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling timeLeftRecording event: $error');
            }
          }
        });

        socketAlt.on('stoppedRecording', (data) async {
          // Handle 'stoppedRecording' event
          try {
            stoppedRecording(StoppedRecordingOptions(
                state: data['state'],
                reason: data['reason'],
                showAlert: showAlert));
          } catch (error) {
            if (kDebugMode) {
              // print('Error handling stoppedRecording event: $error');
            }
          }
        });

        if (widget.options.localLink!.isNotEmpty && !skipSockets) {
          await joinroom(
            socket: socketDefault,
            roomName: roomName.value,
            islevel: islevel.value,
            member: member.value,
            sec: token,
            apiUserName: apiUserName,
            isLocal: true,
          );
        }

        // Check if localSocket has changed
        bool localChanged = false;
        localChanged =
            localSocket.value != null && localSocket.value!.id != socketAlt.id;

        if (!skipSockets && localChanged) {
          // Re-call connectsocket with skipSockets = true
          await connectsocket(apiUserName, token, skipSockets: true);
          await Future.delayed(const Duration(milliseconds: 1000));
          updateIsLoadingModalVisible(false);
          return socketDefault;
        } else {
          if (link.value.isNotEmpty && link.value.contains('mediasfu.com')) {
            // Token might be different for local room
            String token = apiToken.value;
            await joinroom(
              socket: (widget.options.connectMediaSFU! && socketAlt.id != null)
                  ? socketAlt
                  : socketDefault,
              roomName: roomName.value,
              islevel: islevel.value,
              member: member.value,
              sec: token,
              apiUserName: apiUserName,
            );
          }

          await receiveRoomMessages(ReceiveRoomMessagesOptions(
            socket: socketDefault,
            roomName: roomName.value,
            updateMessages: updateMessages,
          ));

          if (!skipSockets) {
            prepopulateUserMedia(
              PrepopulateUserMediaOptions(
                name: hostLabel.value,
                parameters: mediasfuParameters,
              ),
            );
          }
          return socketDefault;
        }
      } else {
        return socket.value!;
      }
    }

    if (validated) {
      updateAllVideoStreams(
          [Stream(id: 'youyou', name: 'youyou', producerId: 'youyou')]);

      updateStreamNames([
        Stream(
          id: 'youyou',
          name: 'youyou',
          producerId: 'youyou',
        )
      ]);

      Future<void> connectAndAddSocketMethods() async {
        socket.value = await connectsocket(
          apiUserName.value,
          apiToken.value,
        );
      }

      try {
        if (widget.options.useLocalUIMode != true) {
          updateIsLoadingModalVisible(true);
          connectAndAddSocketMethods().then((_) {
            startMeetingProgressTimer(
                options: StartMeetingProgressTimerOptions(
              startTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              parameters: mediasfuParameters,
            ));
            updateIsLoadingModalVisible(false);
          }).catchError((error, stackTrace) {
            updateIsLoadingModalVisible(false);
            if (kDebugMode) {
              // print('error in startMeetingProgressTimer: $error');
            }
          });
        } else {
          updateIsLoadingModalVisible(false);
          io.Socket? socket_ = io.io("https://example.com", <String, dynamic>{
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

  late MediasfuParameters mediasfuParameters;

  @override
  void initState() {
    super.initState();
    mediasfuParameters = MediasfuParameters(
        updateMiniCardsGrid: updateMiniCardsGrid,
        mixStreams: mixStreams,
        dispStreams: dispStreams,
        stopShareScreen: stopShareScreen,
        checkScreenShare: checkScreenShare,
        startShareScreen: startShareScreen,
        requestScreenShare: requestScreenShare,
        reorderStreams: reorderStreams,
        prepopulateUserMedia: prepopulateUserMedia,
        getVideos: getVideos,
        rePort: rePort,
        trigger: trigger,
        consumerResume: consumerResume,
        connectSendTransport: connectSendTransport,
        connectSendTransportAudio: connectSendTransportAudio,
        connectSendTransportVideo: connectSendTransportVideo,
        connectSendTransportScreen: connectSendTransportScreen,
        processConsumerTransports: processConsumerTransports,
        resumePauseStreams: resumePauseStreams,
        readjust: readjust,
        checkGrid: checkGrid,
        getEstimate: getEstimate,
        calculateRowsAndColumns: calculateRowsAndColumns,
        addVideosGrid: addVideosGrid,
        onScreenChanges: onScreenChanges,
        sleep: sleep,
        changeVids: changeVids,
        compareActiveNames: compareActiveNames,
        compareScreenStates: compareScreenStates,
        createSendTransport: createSendTransport,
        resumeSendTransportAudio: resumeSendTransportAudio,
        receiveAllPipedTransports: receiveAllPipedTransports,
        disconnectSendTransportVideo: disconnectSendTransportVideo,
        disconnectSendTransportAudio: disconnectSendTransportAudio,
        disconnectSendTransportScreen: disconnectSendTransportScreen,
        getPipedProducersAlt: getPipedProducersAlt,
        signalNewConsumerTransport: signalNewConsumerTransport,
        connectRecvTransport: connectRecvTransport,
        reUpdateInter: reUpdateInter,
        updateParticipantAudioDecibels: updateParticipantAudioDecibels,
        closeAndResize: closeAndResize,
        autoAdjust: autoAdjust,
        switchUserVideoAlt: switchUserVideoAlt,
        switchUserVideo: switchUserVideo,
        switchUserAudio: switchUserAudio,
        getDomains: getDomains,
        formatNumber: formatNumber,
        connectIps: connectIps,
        connectLocalIps: connectLocalIps,
        createDeviceClient: createDeviceClient,
        handleCreatePoll: handleCreatePoll,
        handleVotePoll: handleVotePoll,
        handleEndPoll: handleEndPoll,
        resumePauseAudioStreams: resumePauseAudioStreams,
        processConsumerTransportsAudio: processConsumerTransportsAudio,
        checkPermission: checkPermission,
        streamSuccessVideo: streamSuccessVideo,
        streamSuccessAudio: streamSuccessAudio,
        streamSuccessScreen: streamSuccessScreen,
        streamSuccessAudioSwitch: streamSuccessAudioSwitch,
        clickVideo: clickVideo,
        clickAudio: clickAudio,
        clickScreenShare: clickScreenShare,
        switchVideoAlt: switchVideoAlt,
        requestPermissionCamera: requestPermissionCamera,
        requestPermissionAudio: requestPermissionAudio,
        localUIMode: widget.options.useLocalUIMode == true,

        // Room Details
        roomName: roomName.value,
        member: member.value,
        adminPasscode: adminPasscode.value,
        youAreCoHost: youAreCoHost.value,
        youAreHost: youAreHost.value,
        islevel: islevel.value,
        confirmedToRecord: confirmedToRecord.value,
        meetingDisplayType: meetingDisplayType.value,
        meetingVideoOptimized: meetingVideoOptimized.value,
        eventType: eventType.value,
        participants: participants.value,
        filteredParticipants: filteredParticipants.value,
        participantsCounter: participantsCounter.value,
        participantsFilter: participantsFilter.value,

        // More room details - media
        consumeSockets: consumeSockets.value,
        rtpCapabilities: rtpCapabilities.value,
        roomRecvIPs: roomRecvIPs.value,
        meetingRoomParams: meetingRoomParams.value,
        itemPageLimit: itemPageLimit.value,
        audioOnlyRoom: audioOnlyRoom.value,
        addForBasic: addForBasic.value,
        screenPageLimit: screenPageLimit.value,
        shareScreenStarted: shareScreenStarted.value,
        shared: shared.value,
        targetOrientation: targetOrientation.value,
        targetResolution: targetResolution.value,
        targetResolutionHost: targetResolutionHost.value,
        vidCons: vidCons.value,
        frameRate: frameRate.value,
        hParams: hParams.value,
        vParams: vParams.value,
        screenParams: screenParams.value,
        aParams: aParams.value,

        // More room details - recording
        recordingAudioPausesLimit: recordingAudioPausesLimit.value,
        recordingAudioPausesCount: recordingAudioPausesCount.value,
        recordingAudioSupport: recordingAudioSupport.value,
        recordingAudioPeopleLimit: recordingAudioPeopleLimit.value,
        recordingAudioParticipantsTimeLimit:
            recordingAudioParticipantsTimeLimit.value,
        recordingVideoPausesCount: recordingVideoPausesCount.value,
        recordingVideoPausesLimit: recordingVideoPausesLimit.value,
        recordingVideoSupport: recordingVideoSupport.value,
        recordingVideoPeopleLimit: recordingVideoPeopleLimit.value,
        recordingVideoParticipantsTimeLimit:
            recordingVideoParticipantsTimeLimit.value,
        recordingAllParticipantsSupport: recordingAllParticipantsSupport.value,
        recordingVideoParticipantsSupport:
            recordingVideoParticipantsSupport.value,
        recordingAllParticipantsFullRoomSupport:
            recordingAllParticipantsFullRoomSupport.value,
        recordingVideoParticipantsFullRoomSupport:
            recordingVideoParticipantsFullRoomSupport.value,
        recordingPreferredOrientation: recordingPreferredOrientation.value,
        recordingSupportForOtherOrientation:
            recordingSupportForOtherOrientation.value,
        recordingMultiFormatsSupport: recordingMultiFormatsSupport.value,
        userRecordingParams: userRecordingParams.value,
        canRecord: canRecord.value,
        startReport: startReport.value,
        endReport: endReport.value,
        recordTimerInterval: recordTimerInterval.value,
        recordStartTime: recordStartTime.value,
        recordElapsedTime: recordElapsedTime.value,
        isTimerRunning: isTimerRunning.value,
        canPauseResume: canPauseResume.value,
        recordChangeSeconds: recordChangeSeconds.value,
        pauseLimit: pauseLimit.value,
        pauseRecordCount: pauseRecordCount.value,
        canLaunchRecord: canLaunchRecord.value,
        stopLaunchRecord: stopLaunchRecord.value,
        participantsAll: participantsAll.value,
        firstAll: firstAll.value,
        updateMainWindow: updateMainWindow.value,
        firstRound: firstRound.value,
        landScaped: landScaped.value,
        lockScreen: lockScreen.value,
        screenId: screenId.value,
        allVideoStreams: allVideoStreams.value,
        newLimitedStreams: newLimitedStreams.value,
        newLimitedStreamsIDs: newLimitedStreamsIDs.value,
        activeSounds: activeSounds.value,
        screenShareIDStream: screenShareIDStream.value,
        screenShareNameStream: screenShareNameStream.value,
        adminIDStream: adminIDStream.value,
        adminNameStream: adminNameStream.value,
        youYouStream: youYouStream.value,
        youYouStreamIDs: youYouStreamIDs.value,
        localStream: localStream.value,
        recordStarted: recordStarted.value,
        recordResumed: recordResumed.value,
        recordPaused: recordPaused.value,
        recordStopped: recordStopped.value,
        adminRestrictSetting: adminRestrictSetting.value,
        videoRequestState: videoRequestState.value,
        videoRequestTime: videoRequestTime.value,
        videoAction: videoAction.value,
        localStreamVideo: localStreamVideo.value,
        userDefaultVideoInputDevice: userDefaultVideoInputDevice.value,
        currentFacingMode: currentFacingMode.value,
        prevFacingMode: prevFacingMode.value,
        defVideoID: defVideoID.value,
        allowed: allowed.value,
        dispActiveNames: dispActiveNames.value,
        pDispActiveNames: pDispActiveNames.value,
        activeNames: activeNames.value,
        prevActiveNames: prevActiveNames.value,
        pActiveNames: pActiveNames.value,
        membersReceived: membersReceived.value,
        deferScreenReceived: deferScreenReceived.value,
        hostFirstSwitch: hostFirstSwitch.value,
        micAction: micAction.value,
        screenAction: screenAction.value,
        chatAction: chatAction.value,
        audioRequestState: audioRequestState.value,
        screenRequestState: screenRequestState.value,
        chatRequestState: chatRequestState.value,
        audioRequestTime: audioRequestTime.value,
        screenRequestTime: screenRequestTime.value,
        chatRequestTime: chatRequestTime.value,
        updateRequestIntervalSeconds: updateRequestIntervalSeconds.value,
        oldSoundIds: oldSoundIds.value,
        hostLabel: hostLabel.value,
        mainScreenFilled: mainScreenFilled.value,
        localStreamScreen: localStreamScreen.value,
        screenAlreadyOn: screenAlreadyOn.value,
        chatAlreadyOn: chatAlreadyOn.value,
        redirectURL: redirectURL.value,
        oldAllStreams: oldAllStreams.value,
        adminVidID: adminVidID.value,
        streamNames: streamNames.value,
        nonAlVideoStreams: nonAlVideoStreams.value,
        sortAudioLoudness: sortAudioLoudness.value,
        audioDecibels: audioDecibels.value,
        mixedAlVideoStreams: mixedAlVideoStreams.value,
        nonAlVideoStreamsMuted: nonAlVideoStreamsMuted.value,
        paginatedStreams: paginatedStreams.value,
        localStreamAudio: localStreamAudio.value,
        defAudioID: defAudioID.value,
        userDefaultAudioInputDevice: userDefaultAudioInputDevice.value,
        userDefaultAudioOutputDevice: userDefaultAudioOutputDevice.value,
        prevAudioInputDevice: prevAudioInputDevice.value,
        prevVideoInputDevice: prevVideoInputDevice.value,
        audioPaused: audioPaused.value,
        mainScreenPerson: mainScreenPerson.value,
        adminOnMainScreen: adminOnMainScreen.value,
        screenStates: screenStates.value,
        prevScreenStates: prevScreenStates.value,
        updateDateState: updateDateState.value,
        lastUpdate: lastUpdate.value,
        nForReadjustRecord: nForReadjustRecord.value,
        fixedPageLimit: fixedPageLimit.value,
        removeAltGrid: removeAltGrid.value,
        nForReadjust: nForReadjust.value,
        lastReorderTime: lastReorderTime.value,
        reorderInterval: reorderInterval.value,
        fastReorderInterval: fastReorderInterval.value,
        audStreamNames: audStreamNames.value,
        currentUserPage: currentUserPage.value,
        mainHeightWidth: mainHeightWidth,
        prevMainHeightWidth: prevMainHeightWidth.value,
        prevDoPaginate: prevDoPaginate.value,
        doPaginate: doPaginate.value,
        shareEnded: shareEnded.value,
        lStreams: lStreams.value,
        chatRefStreams: chatRefStreams.value,
        controlHeight: controlHeight.value,
        isWideScreen: isWideScreen.value,
        isMediumScreen: isMediumScreen.value,
        isSmallScreen: isSmallScreen.value,
        addGrid: addGrid.value,
        addAltGrid: addAltGrid.value,
        gridRows: gridRows.value,
        gridCols: gridCols.value,
        altGridRows: altGridRows.value,
        altGridCols: altGridCols.value,
        numberPages: numberPages.value,
        currentStreams: currentStreams.value,
        showMiniView: showMiniView.value,
        nStream: nStream.value,
        deferReceive: deferReceive.value,
        allAudioStreams: allAudioStreams.value,
        screenProducer: screenProducer.value,
        localScreenProducer: localScreenProducer!.value,
        remoteScreenStream: remoteScreenStream.value,
        gotAllVids: gotAllVids.value,
        paginationHeightWidth: paginationHeightWidth.value,
        paginationDirection: paginationDirection.value,
        gridSizes: gridSizes.value,
        screenForceFullDisplay: screenForceFullDisplay.value,
        mainGridStream: mainGridStream.value,
        otherGridStreams: otherGridStreams,
        audioOnlyStreams: audioOnlyStreams.value,
        videoInputs: videoInputs.value,
        audioInputs: audioInputs.value,
        meetingProgressTime: meetingProgressTime.value,
        meetingElapsedTime: meetingElapsedTime.value,
        refParticipants: refParticipants.value,
        messages: messages.value,
        startDirectMessage: startDirectMessage.value,
        directMessageDetails: directMessageDetails.value,
        showMessagesBadge: showMessagesBadge.value,
        coHost: coHost.value,
        coHostResponsibility: coHostResponsibility.value,
        audioSetting: audioSetting.value,
        videoSetting: videoSetting.value,
        screenshareSetting: screenshareSetting.value,
        chatSetting: chatSetting.value,
        autoWave: autoWave.value,
        forceFullDisplay: forceFullDisplay.value,
        prevForceFullDisplay: prevForceFullDisplay.value,
        prevMeetingDisplayType: prevMeetingDisplayType.value,
        waitingRoomFilter: waitingRoomFilter.value,
        waitingRoomList: waitingRoomList.value,
        waitingRoomCounter: waitingRoomCounter.value,
        filteredWaitingRoomList: filteredWaitingRoomList.value,
        requestFilter: requestFilter.value,
        requestList: requestList.value,
        requestCounter: requestCounter.value,
        filteredRequestList: filteredRequestList.value,
        totalReqWait: totalReqWait.value,
        alertVisible: alertVisible.value,
        alertMessage: alertMessage.value,
        alertType: alertType.value,
        alertDuration: alertDuration.value,
        progressTimerVisible: progressTimerVisible.value,
        progressTimerValue: progressTimerValue.value,
        isMenuModalVisible: isMenuModalVisible.value,
        isRecordingModalVisible: isRecordingModalVisible.value,
        isSettingsModalVisible: isSettingsModalVisible.value,
        isRequestsModalVisible: isRequestsModalVisible.value,
        isWaitingModalVisible: isWaitingModalVisible.value,
        isCoHostModalVisible: isCoHostModalVisible.value,
        isMediaSettingsModalVisible: isMediaSettingsModalVisible.value,
        isDisplaySettingsModalVisible: isDisplaySettingsModalVisible.value,
        isParticipantsModalVisible: isParticipantsModalVisible.value,
        isMessagesModalVisible: isMessagesModalVisible.value,
        isConfirmExitModalVisible: isConfirmExitModalVisible.value,
        isConfirmHereModalVisible: isConfirmHereModalVisible.value,
        isShareEventModalVisible: isShareEventModalVisible.value,
        isLoadingModalVisible: isLoadingModalVisible.value,

        // Recording Options
        recordingMediaOptions: recordingMediaOptions.value,
        recordingAudioOptions: recordingAudioOptions.value,
        recordingVideoOptions: recordingVideoOptions.value,
        recordingVideoType: recordingVideoType.value,
        recordingVideoOptimized: recordingVideoOptimized.value,
        recordingDisplayType: recordingDisplayType.value,
        recordingAddHLS: recordingAddHLS.value,
        recordingAddText: recordingAddText.value,
        recordingCustomText: recordingCustomText.value,
        recordingCustomTextPosition: recordingCustomTextPosition.value,
        recordingCustomTextColor: recordingCustomTextColor.value,
        recordingNameTags: recordingNameTags.value,
        recordingBackgroundColor: recordingBackgroundColor.value,
        recordingNameTagsColor: recordingNameTagsColor.value,
        recordingOrientationVideo: recordingOrientationVideo.value,
        clearedToResume: clearedToResume.value,
        clearedToRecord: clearedToRecord.value,
        recordState: recordState,
        showRecordButtons: showRecordButtons.value,
        recordingProgressTime: recordingProgressTime.value,
        audioSwitching: audioSwitching.value,
        videoSwitching: videoSwitching.value,
        videoAlreadyOn: videoAlreadyOn.value,
        audioAlreadyOn: audioAlreadyOn.value,
        componentSizes: componentSizes.value,
        hasCameraPermission: hasCameraPermission.value,
        hasAudioPermission: hasAudioPermission.value,
        transportCreated: transportCreated.value,
        localTransportCreated: localTransportCreated!.value,
        transportCreatedVideo: transportCreatedVideo.value,
        transportCreatedAudio: transportCreatedAudio.value,
        transportCreatedScreen: transportCreatedScreen.value,
        producerTransport: producerTransport.value,
        localProducerTransport: localProducerTransport!.value,
        videoProducer: videoProducer.value,
        localVideoProducer: localVideoProducer!.value,
        params: params.value,
        videoParams: videoParams.value,
        audioParams: audioParams.value,
        audioProducer: audioProducer.value,
        audioLevel: audioLevel.value,
        localAudioProducer: localAudioProducer!.value,
        consumerTransports: consumerTransports.value,
        consumingTransports: consumingTransports.value,
        // Polls
        polls: polls.value,
        poll: poll.value,
        isPollModalVisible: isPollModalVisible.value,

        // Breakout rooms
        breakoutRooms: breakoutRooms.value,
        currentRoomIndex: currentRoomIndex.value,
        canStartBreakout: canStartBreakout.value,
        breakOutRoomStarted: breakOutRoomStarted.value,
        breakOutRoomEnded: breakOutRoomEnded.value,
        hostNewRoom: hostNewRoom.value,
        limitedBreakRoom: limitedBreakRoom.value,
        mainRoomsLength: mainRoomsLength.value,
        memberRoom: memberRoom.value,
        isBreakoutRoomsModalVisible: isBreakoutRoomsModalVisible.value,
        validated: validated,
        device: device.value,
        socket: socket.value,
        localSocket: localSocket.value,
        checkMediaPermission: !kIsWeb,
        onWeb: kIsWeb,

        // Update functions for Room Details
        updateRoomName: updateRoomName,
        updateMember: updateMember,
        updateAdminPasscode: updateAdminPasscode,
        updateYouAreCoHost: updateYouAreCoHost,
        updateYouAreHost: updateYouAreHost,
        updateIslevel: updateIslevel,
        updateCoHost: updateCoHost,
        updateCoHostResponsibility: updateCoHostResponsibility,
        updateConfirmedToRecord: updateConfirmedToRecord,
        updateMeetingDisplayType: updateMeetingDisplayType,
        updateMeetingVideoOptimized: updateMeetingVideoOptimized,
        updateEventType: updateEventType,
        updateParticipants: updateParticipants,
        updateParticipantsCounter: updateParticipantsCounter,
        updateParticipantsFilter: updateParticipantsFilter,

        // Update functions for more room details - media
        updateConsumeSockets: updateConsumeSockets,
        updateRtpCapabilities: updateRtpCapabilities,
        updateRoomRecvIPs: updateRoomRecvIPs,
        updateMeetingRoomParams: updateMeetingRoomParams,
        updateItemPageLimit: updateItemPageLimit,
        updateAudioOnlyRoom: updateAudioOnlyRoom,
        updateAddForBasic: updateAddForBasic,
        updateScreenPageLimit: updateScreenPageLimit,
        updateShareScreenStarted: updateShareScreenStarted,
        updateShared: updateShared,
        updateTargetOrientation: updateTargetOrientation,
        updateTargetResolution: updateTargetResolution,
        updateTargetResolutionHost: updateTargetResolutionHost,
        updateVidCons: updateVidCons,
        updateFrameRate: updateFrameRate,
        updateHParams: updateHParams,
        updateVParams: updateVParams,
        updateScreenParams: updateScreenParams,
        updateAParams: updateAParams,

        // Update functions for more room details - recording
        updateRecordingAudioPausesLimit: updateRecordingAudioPausesLimit,
        updateRecordingAudioPausesCount: updateRecordingAudioPausesCount,
        updateRecordingAudioSupport: updateRecordingAudioSupport,
        updateRecordingAudioPeopleLimit: updateRecordingAudioPeopleLimit,
        updateRecordingAudioParticipantsTimeLimit:
            updateRecordingAudioParticipantsTimeLimit,
        updateRecordingVideoPausesCount: updateRecordingVideoPausesCount,
        updateRecordingVideoPausesLimit: updateRecordingVideoPausesLimit,
        updateRecordingVideoSupport: updateRecordingVideoSupport,
        updateRecordingVideoPeopleLimit: updateRecordingVideoPeopleLimit,
        updateRecordingVideoParticipantsTimeLimit:
            updateRecordingVideoParticipantsTimeLimit,
        updateRecordingAllParticipantsSupport:
            updateRecordingAllParticipantsSupport,
        updateRecordingVideoParticipantsSupport:
            updateRecordingVideoParticipantsSupport,
        updateRecordingAllParticipantsFullRoomSupport:
            updateRecordingAllParticipantsFullRoomSupport,
        updateRecordingVideoParticipantsFullRoomSupport:
            updateRecordingVideoParticipantsFullRoomSupport,
        updateRecordingPreferredOrientation:
            updateRecordingPreferredOrientation,
        updateRecordingSupportForOtherOrientation:
            updateRecordingSupportForOtherOrientation,
        updateRecordingMultiFormatsSupport: updateRecordingMultiFormatsSupport,

        // Update functions for user recording params
        updateUserRecordingParams: updateUserRecordingParams,
        updateCanRecord: updateCanRecord,
        updateStartReport: updateStartReport,
        updateEndReport: updateEndReport,
        updateRecordTimerInterval: updateRecordTimerInterval,
        updateRecordStartTime: updateRecordStartTime,
        updateRecordElapsedTime: updateRecordElapsedTime,
        updateIsTimerRunning: updateIsTimerRunning,
        updateCanPauseResume: updateCanPauseResume,
        updateRecordChangeSeconds: updateRecordChangeSeconds,
        updatePauseLimit: updatePauseLimit,
        updatePauseRecordCount: updatePauseRecordCount,
        updateCanLaunchRecord: updateCanLaunchRecord,
        updateStopLaunchRecord: updateStopLaunchRecord,

        // Update function for participants all
        updateParticipantsAll: updateParticipantsAll,
        updateFirstAll: updateFirstAll,
        updateUpdateMainWindow: updateUpdateMainWindow,
        updateFirstRound: updateFirstRound,
        updateLandScaped: updateLandScaped,
        updateLockScreen: updateLockScreen,
        updateScreenId: updateScreenId,
        updateAllVideoStreams: updateAllVideoStreams,
        updateNewLimitedStreams: updateNewLimitedStreams,
        updateNewLimitedStreamsIDs: updateNewLimitedStreamsIDs,
        updateActiveSounds: updateActiveSounds,
        updateScreenShareIDStream: updateScreenShareIDStream,
        updateScreenShareNameStream: updateScreenShareNameStream,
        updateAdminIDStream: updateAdminIDStream,
        updateAdminNameStream: updateAdminNameStream,
        updateYouYouStream: updateYouYouStream,
        updateYouYouStreamIDs: updateYouYouStreamIDs,
        updateLocalStream: updateLocalStream,
        updateRecordStarted: updateRecordStarted,
        updateRecordResumed: updateRecordResumed,
        updateRecordPaused: updateRecordPaused,
        updateRecordStopped: updateRecordStopped,
        updateAdminRestrictSetting: updateAdminRestrictSetting,
        updateVideoRequestState: updateVideoRequestState,
        updateVideoRequestTime: updateVideoRequestTime,
        updateVideoAction: updateVideoAction,
        updateLocalStreamVideo: updateLocalStreamVideo,
        updateUserDefaultVideoInputDevice: updateUserDefaultVideoInputDevice,
        updateCurrentFacingMode: updateCurrentFacingMode,
        updateRefParticipants: updateRefParticipants,
        updateDefVideoID: updateDefVideoID,
        updateAllowed: updateAllowed,
        updateDispActiveNames: updateDispActiveNames,
        updatePDispActiveNames: updatePDispActiveNames,
        updateActiveNames: updateActiveNames,
        updatePrevActiveNames: updatePrevActiveNames,
        updatePActiveNames: updatePActiveNames,
        updateMembersReceived: updateMembersReceived,
        updateDeferScreenReceived: updateDeferScreenReceived,
        updateHostFirstSwitch: updateHostFirstSwitch,
        updateMicAction: updateMicAction,
        updateScreenAction: updateScreenAction,
        updateChatAction: updateChatAction,
        updateAudioRequestState: updateAudioRequestState,
        updateScreenRequestState: updateScreenRequestState,
        updateChatRequestState: updateChatRequestState,
        updateAudioRequestTime: updateAudioRequestTime,
        updateScreenRequestTime: updateScreenRequestTime,
        updateChatRequestTime: updateChatRequestTime,
        updateOldSoundIds: updateOldSoundIds,
        updateHostLabel: updateHostLabel,
        updateMainScreenFilled: updateMainScreenFilled,
        updateLocalStreamScreen: updateLocalStreamScreen,
        updateScreenAlreadyOn: updateScreenAlreadyOn,
        updateChatAlreadyOn: updateChatAlreadyOn,
        updateRedirectURL: updateRedirectURL,
        updateOldAllStreams: updateOldAllStreams,
        updateAdminVidID: updateAdminVidID,
        updateStreamNames: updateStreamNames,
        updateNonAlVideoStreams: updateNonAlVideoStreams,
        updateSortAudioLoudness: updateSortAudioLoudness,
        updateAudioDecibels: updateAudioDecibels,
        updateMixedAlVideoStreams: updateMixedAlVideoStreams,
        updateNonAlVideoStreamsMuted: updateNonAlVideoStreamsMuted,
        updatePaginatedStreams: updatePaginatedStreams,
        updateLocalStreamAudio: updateLocalStreamAudio,
        updateDefAudioID: updateDefAudioID,
        updateUserDefaultAudioInputDevice: updateUserDefaultAudioInputDevice,
        updateUserDefaultAudioOutputDevice: updateUserDefaultAudioOutputDevice,
        updatePrevAudioInputDevice: updatePrevAudioInputDevice,
        updatePrevVideoInputDevice: updatePrevVideoInputDevice,
        updateAudioPaused: updateAudioPaused,
        updateMainScreenPerson: updateMainScreenPerson,
        updateAdminOnMainScreen: updateAdminOnMainScreen,
        updateScreenStates: updateScreenStates,
        updatePrevScreenStates: updatePrevScreenStates,
        updateUpdateDateState: updateUpdateDateState,
        updateLastUpdate: updateLastUpdate,
        updateNForReadjustRecord: updateNForReadjustRecord,
        updateFixedPageLimit: updateFixedPageLimit,
        updateRemoveAltGrid: updateRemoveAltGrid,
        updateNForReadjust: updateNForReadjust,
        updateLastReorderTime: updateLastReorderTime,
        updateAudStreamNames: updateAudStreamNames,
        updateCurrentUserPage: updateCurrentUserPage,
        updatePrevFacingMode: updatePrevFacingMode,
        updateMainHeightWidth: updateMainHeightWidth,
        updatePrevMainHeightWidth: updatePrevMainHeightWidth,
        updatePrevDoPaginate: updatePrevDoPaginate,
        updateDoPaginate: updateDoPaginate,
        updateShareEnded: updateShareEnded,
        updateLStreams: updateLStreams,
        updateChatRefStreams: updateChatRefStreams,
        updateControlHeight: updateControlHeight,
        updateIsWideScreen: updateIsWideScreen,
        updateIsMediumScreen: updateIsMediumScreen,
        updateIsSmallScreen: updateIsSmallScreen,
        updateAddGrid: updateAddGrid,
        updateAddAltGrid: updateAddAltGrid,
        updateGridRows: updateGridRows,
        updateGridCols: updateGridCols,
        updateAltGridRows: updateAltGridRows,
        updateAltGridCols: updateAltGridCols,
        updateNumberPages: updateNumberPages,
        updateCurrentStreams: updateCurrentStreams,
        updateShowMiniView: updateShowMiniView,
        updateNStream: updateNStream,
        updateDeferReceive: updateDeferReceive,
        updateAllAudioStreams: updateAllAudioStreams,
        updateRemoteScreenStream: updateRemoteScreenStream,
        updateScreenProducer: updateScreenProducer,
        updateLocalScreenProducer: updateLocalScreenProducer,
        updateGotAllVids: updateGotAllVids,
        updatePaginationHeightWidth: updatePaginationHeightWidth,
        updatePaginationDirection: updatePaginationDirection,
        updateGridSizes: updateGridSizes,
        updateScreenForceFullDisplay: updateScreenForceFullDisplay,
        updateMainGridStream: updateMainGridStream,
        updateOtherGridStreams: updateOtherGridStreams,
        updateAudioOnlyStreams: updateAudioOnlyStreams,
        updateVideoInputs: updateVideoInputs,
        updateAudioInputs: updateAudioInputs,
        updateMeetingProgressTime: updateMeetingProgressTime,
        updateMeetingElapsedTime: updateMeetingElapsedTime,

        // Update functions for messages
        updateMessages: updateMessages,
        updateStartDirectMessage: updateStartDirectMessage,
        updateDirectMessageDetails: updateDirectMessageDetails,
        updateShowMessagesBadge: updateShowMessagesBadge,

        // Event settings
        updateAudioSetting: updateAudioSetting,
        updateVideoSetting: updateVideoSetting,
        updateScreenshareSetting: updateScreenshareSetting,
        updateChatSetting: updateChatSetting,

        // Display settings
        updateAutoWave: updateAutoWave,
        updateForceFullDisplay: updateForceFullDisplay,
        updatePrevForceFullDisplay: updatePrevForceFullDisplay,
        updatePrevMeetingDisplayType: updatePrevMeetingDisplayType,

        // Waiting room
        updateWaitingRoomFilter: updateWaitingRoomFilter,
        updateWaitingRoomList: updateWaitingRoomList,
        updateWaitingRoomCounter: updateWaitingRoomCounter,

        // Requests
        updateRequestFilter: updateRequestFilter,
        updateRequestList: updateRequestList,
        updateRequestCounter: updateRequestCounter,

        // Total requests and waiting room
        updateTotalReqWait: updateTotalReqWait,

        // Show Alert modal
        updateIsMenuModalVisible: updateIsMenuModalVisible,
        updateIsRecordingModalVisible: updateIsRecordingModalVisible,
        updateIsSettingsModalVisible: updateIsSettingsModalVisible,
        updateIsRequestsModalVisible: updateIsRequestsModalVisible,
        updateIsWaitingModalVisible: updateIsWaitingModalVisible,
        updateIsCoHostModalVisible: updateIsCoHostModalVisible,
        updateIsMediaSettingsModalVisible: updateIsMediaSettingsModalVisible,
        updateIsDisplaySettingsModalVisible:
            updateIsDisplaySettingsModalVisible,

        // Other Modals
        updateIsParticipantsModalVisible: updateIsParticipantsModalVisible,
        updateIsMessagesModalVisible: updateIsMessagesModalVisible,
        updateIsConfirmExitModalVisible: updateIsConfirmExitModalVisible,
        updateIsConfirmHereModalVisible: updateIsConfirmHereModalVisible,
        updateIsLoadingModalVisible: updateIsLoadingModalVisible,

        // Recording Options
        updateRecordingMediaOptions: updateRecordingMediaOptions,
        updateRecordingAudioOptions: updateRecordingAudioOptions,
        updateRecordingVideoOptions: updateRecordingVideoOptions,
        updateRecordingVideoType: updateRecordingVideoType,
        updateRecordingVideoOptimized: updateRecordingVideoOptimized,
        updateRecordingDisplayType: updateRecordingDisplayType,
        updateRecordingAddHLS: updateRecordingAddHLS,
        updateRecordingAddText: updateRecordingAddText,
        updateRecordingCustomText: updateRecordingCustomText,
        updateRecordingCustomTextPosition: updateRecordingCustomTextPosition,
        updateRecordingCustomTextColor: updateRecordingCustomTextColor,
        updateRecordingNameTags: updateRecordingNameTags,
        updateRecordingBackgroundColor: updateRecordingBackgroundColor,
        updateRecordingNameTagsColor: updateRecordingNameTagsColor,
        updateRecordingOrientationVideo: updateRecordingOrientationVideo,
        updateClearedToResume: updateClearedToResume,
        updateClearedToRecord: updateClearedToRecord,
        updateRecordState: updateRecordState,
        updateShowRecordButtons: updateShowRecordButtons,
        updateRecordingProgressTime: updateRecordingProgressTime,
        updateAudioSwitching: updateAudioSwitching,
        updateVideoSwitching: updateVideoSwitching,

        // Media states
        updateVideoAlreadyOn: updateVideoAlreadyOn,
        updateAudioAlreadyOn: updateAudioAlreadyOn,
        updateComponentSizes: updateComponentSizes,

        // Permissions
        updateHasCameraPermission: updateHasCameraPermission,
        updateHasAudioPermission: updateHasAudioPermission,

        // Transports
        updateTransportCreated: updateTransportCreated,
        updateLocalTransportCreated: updateLocalTransportCreated,
        updateTransportCreatedVideo: updateTransportCreatedVideo,
        updateTransportCreatedAudio: updateTransportCreatedAudio,
        updateTransportCreatedScreen: updateTransportCreatedScreen,
        updateProducerTransport: updateProducerTransport,
        updateLocalProducerTransport: updateLocalProducerTransport,
        updateVideoProducer: updateVideoProducer,
        updateLocalVideoProducer: updateLocalVideoProducer,
        updateParams: updateParams,
        updateVideoParams: updateVideoParams,
        updateAudioParams: updateAudioParams,
        updateAudioProducer: updateAudioProducer,
        updateAudioLevel: updateAudioLevel,
        updateLocalAudioProducer: updateLocalAudioProducer,
        updateConsumerTransports: updateConsumerTransports,
        updateConsumingTransports: updateConsumingTransports,

        //polls
        updatePolls: updatePolls,
        updatePoll: updatePoll,
        updateIsPollModalVisible: updateIsPollModalVisible,

        //breakout rooms
        updateBreakoutRooms: updateBreakoutRooms,
        updateCurrentRoomIndex: updateCurrentRoomIndex,
        updateCanStartBreakout: updateCanStartBreakout,
        updateBreakOutRoomStarted: updateBreakOutRoomStarted,
        updateBreakOutRoomEnded: updateBreakOutRoomEnded,
        updateHostNewRoom: updateHostNewRoom,
        updateLimitedBreakRoom: updateLimitedBreakRoom,
        updateMainRoomsLength: updateMainRoomsLength,
        updateMemberRoom: updateMemberRoom,
        updateIsBreakoutRoomsModalVisible: updateIsBreakoutRoomsModalVisible,
        checkOrientation: checkOrientation,
        roomData: ResponseJoinRoom(),
        updateDevice: updateDevice,
        updateSocket: updateSocket,
        updateValidated: updateValidated,
        showAlert: showAlert,
        customImage: customImage.value,
        selectedImage: selectedImage.value,
        segmentVideo: segmentVideo.value,
        selfieSegmentation: selfieSegmentation.value,
        pauseSegmentation: pauseSegmentation.value,
        processedStream: processedStream.value,
        keepBackground: keepBackground.value,
        backgroundHasChanged: backgroundHasChanged.value,
        virtualStream: virtualStream.value,
        mainCanvas: mainCanvas.value,
        prevKeepBackground: prevKeepBackground.value,
        appliedBackground: appliedBackground.value,
        isBackgroundModalVisible: isBackgroundModalVisible.value,
        autoClickBackground: autoClickBackground.value,

        // Update functions
        updateCustomImage: updateCustomImage,
        updateSelectedImage: updateSelectedImage,
        updateSegmentVideo: updateSegmentVideo,
        updateSelfieSegmentation: updateSelfieSegmentation,
        updatePauseSegmentation: updatePauseSegmentation,
        updateProcessedStream: updateProcessedStream,
        updateKeepBackground: updateKeepBackground,
        updateBackgroundHasChanged: updateBackgroundHasChanged,
        updateVirtualStream: updateVirtualStream,
        updateMainCanvas: updateMainCanvas,
        updatePrevKeepBackground: updatePrevKeepBackground,
        updateAppliedBackground: updateAppliedBackground,
        updateIsBackgroundModalVisible: updateIsBackgroundModalVisible,
        updateAutoClickBackground: updateAutoClickBackground,

        // Whiteboard-related variables
        whiteboardUsers: whiteboardUsers.value,
        currentWhiteboardIndex: currentWhiteboardIndex.value,
        canStartWhiteboard: canStartWhiteboard.value,
        whiteboardStarted: whiteboardStarted.value,
        whiteboardEnded: whiteboardEnded.value,
        whiteboardLimit: whiteboardLimit.value,
        isWhiteboardModalVisible: isWhiteboardModalVisible.value,
        isConfigureWhiteboardModalVisible:
            isConfigureWhiteboardModalVisible.value,
        shapes: shapes.value,
        useImageBackground: useImageBackground.value,
        redoStack: redoStack.value,
        undoStack: undoStack.value,
        canvasStream: canvasStream.value,
        canvasWhiteboard: canvasWhiteboard.value,

        // Screenboard-related variables
        canvasScreenboard: canvasScreenboard.value,
        processedScreenStream: processedScreenStream.value,
        annotateScreenStream: annotateScreenStream.value,
        mainScreenCanvas: mainScreenCanvas.value,
        isScreenboardModalVisible: isScreenboardModalVisible.value,

        // Whiteboard update functions
        updateWhiteboardUsers: updateWhiteboardUsers,
        updateCurrentWhiteboardIndex: updateCurrentWhiteboardIndex,
        updateCanStartWhiteboard: updateCanStartWhiteboard,
        updateWhiteboardStarted: updateWhiteboardStarted,
        updateWhiteboardEnded: updateWhiteboardEnded,
        updateWhiteboardLimit: updateWhiteboardLimit,
        updateIsWhiteboardModalVisible: updateIsWhiteboardModalVisible,
        updateIsConfigureWhiteboardModalVisible:
            updateIsConfigureWhiteboardModalVisible,
        updateShapes: updateShapes,
        updateUseImageBackground: updateUseImageBackground,
        updateRedoStack: updateRedoStack,
        updateUndoStack: updateUndoStack,
        updateCanvasStream: updateCanvasStream,
        updateCanvasWhiteboard: updateCanvasWhiteboard,
        updateCanvasScreenboard: updateCanvasScreenboard,
        updateProcessedScreenStream: updateProcessedScreenStream,
        updateAnnotateScreenStream: updateAnnotateScreenStream,
        updateMainScreenCanvas: updateMainScreenCanvas,
        updateIsScreenboardModalVisible: updateIsScreenboardModalVisible,
        getUpdatedAllParams: () => mediasfuParameters);

    if (widget.options.returnUI != null && widget.options.returnUI == false) {
      try {
        widget.options.sourceParameters = mediasfuParameters;
      } catch (error) {
        if (kDebugMode) {
          print('Error setting source parameters: $error');
        }
      }
    }

    // If using seed data, generate random participants and message
    if (widget.options.useSeed == true && widget.options.seedData != null) {
      try {
        updateMember(widget.options.seedData!.member!);
        updateParticipants(widget.options.seedData!.participants!);
        updateParticipantsCounter(
            widget.options.seedData!.participants!.length);
        updateFilteredParticipants(widget.options.seedData!.participants!);
        updateMessages(widget.options.seedData!.messages!);
        updateRequestList(widget.options.seedData!.requests!);
        updateWaitingRoomList(widget.options.seedData!.waitingList!);
        updateWaitingRoomCounter(widget.options.seedData!.waitingList!.length);
      } catch (error) {
        if (kDebugMode) {
          print('Error setting seed data: $error');
        }
      }
    }

    if (widget.options.useLocalUIMode == true) {
      updateValidated(true);
    }

    isPortrait.addListener(_handleOrientationChange);
  }

  void updateStatesToInitialValues(MediasfuParameters mediasfuParameters,
      Map<String, dynamic> initialValues) async {
    for (String key in initialValues.keys) {
      try {
        String updateFunctionName =
            'update${key[0].toUpperCase()}${key.substring(1)}';
        if (mediasfuParameters.updateFunctions
            .containsKey(updateFunctionName)) {
          // Call the appropriate update function with the value from initialValues
          mediasfuParameters.updateFunctions[updateFunctionName]
              ?.call(initialValues[key]);
        }
      } catch (error) {
        if (kDebugMode) {
          // print('Error updating $key: $error');
        }
      }
    }
  }

  void updateSpecificState(
      MediasfuParameters? sourceParameters, String key, dynamic value) {
    // providing a blanket update function for all states
    // will modify later to provide specific update functions
    try {
      if (widget.options.updateSourceParameters != null) {
        widget.options.sourceParameters = mediasfuParameters;
        widget.options.updateSourceParameters!(mediasfuParameters);
      }
    } catch (error) {
      // if (kDebugMode) {
      //   print('Error updating $key: $error');
      // }
    }
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
    initializeControlButtons();

    return validated &&
            widget.options.returnUI != null &&
            widget.options.returnUI == true
        ? MainContainerComponent(
            options: MainContainerComponentOptions(
              backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
              children: [
                MainAspectComponent(
                  options: MainAspectComponentOptions(
                    backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
                    updateIsWideScreen: updateIsWideScreen,
                    updateIsMediumScreen: updateIsMediumScreen,
                    updateIsSmallScreen: updateIsSmallScreen,
                    defaultFraction: 1 - controlHeight.value,
                    showControls: eventType.value == EventType.webinar ||
                        eventType.value == EventType.conference,
                    children: [
                      ValueListenableBuilder<ComponentSizes>(
                          valueListenable: componentSizes,
                          builder: (context, componentSizes, child) {
                            return MainScreenComponent(
                              options: MainScreenComponentOptions(
                                doStack: true,
                                mainSize: mainHeightWidth,
                                updateComponentSizes: updateComponentSizes,
                                defaultFraction: 1 - controlHeight.value,
                                showControls:
                                    eventType.value == EventType.webinar ||
                                        eventType.value == EventType.conference,
                                children: [
                                  ValueListenableBuilder<GridSizes>(
                                    valueListenable: gridSizes,
                                    builder: (context, gridSizes, child) {
                                      return MainGridComponent(
                                        options: MainGridComponentOptions(
                                          height: componentSizes.mainHeight,
                                          width: componentSizes.mainWidth,
                                          backgroundColor: const Color.fromRGBO(
                                              217, 227, 234, 0.99),
                                          mainSize: mainHeightWidth,
                                          showAspect: mainHeightWidth > 0,
                                          timeBackgroundColor:
                                              recordState == 'green'
                                                  ? Colors.green
                                                  : recordState == 'yellow'
                                                      ? Colors.yellow
                                                      : Colors.red,
                                          meetingProgressTime:
                                              meetingProgressTime.value,
                                          showTimer: true,
                                          children: [
                                            FlexibleVideo(
                                                options: FlexibleVideoOptions(
                                              backgroundColor:
                                                  const Color.fromRGBO(
                                                      217, 227, 234, 0.99),
                                              customWidth:
                                                  componentSizes.mainWidth,
                                              customHeight:
                                                  componentSizes.mainHeight,
                                              rows: 1,
                                              columns: 1,
                                              componentsToRender:
                                                  mainGridStream.value,
                                              showAspect: mainGridStream
                                                  .value.isNotEmpty,
                                            )),
                                            ValueListenableBuilder<String>(
                                                valueListenable:
                                                    meetingProgressTime,
                                                builder: (context,
                                                    meetingProgressTime,
                                                    child) {
                                                  return MeetingProgressTimer(
                                                      options:
                                                          MeetingProgressTimerOptions(
                                                    meetingProgressTime:
                                                        meetingProgressTime,
                                                    initialBackgroundColor:
                                                        recordState == 'green'
                                                            ? Colors.green
                                                            : recordState ==
                                                                    'yellow'
                                                                ? Colors.yellow
                                                                : Colors.red,
                                                    showTimer: true,
                                                  ));
                                                }),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  ValueListenableBuilder<GridSizes>(
                                      valueListenable: gridSizes,
                                      builder: (context, gridSizes, child) {
                                        return OtherGridComponent(
                                          options: OtherGridComponentOptions(
                                            height: componentSizes.otherHeight,
                                            width: componentSizes.otherWidth,
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    217, 227, 234, 0.99),
                                            showAspect: mainHeightWidth == 100
                                                ? false
                                                : true,
                                            timeBackgroundColor:
                                                recordState == 'green'
                                                    ? Colors.green
                                                    : recordState == 'yellow'
                                                        ? Colors.yellow
                                                        : Colors.red,
                                            showTimer: mainHeightWidth == 0
                                                ? true
                                                : false,
                                            meetingProgressTime:
                                                meetingProgressTime.value,
                                            children: [
                                              AudioGrid(
                                                  options: AudioGridOptions(
                                                componentsToRender:
                                                    audioOnlyStreams.value,
                                              )),
                                              Container(
                                                padding: EdgeInsets.only(
                                                  top: doPaginate.value
                                                      ? paginationDirection
                                                                  .value ==
                                                              'horizontal'
                                                          ? paginationHeightWidth
                                                              .value
                                                              .toDouble()
                                                          : 0
                                                      : 0,
                                                  left: doPaginate.value
                                                      ? paginationDirection
                                                                  .value ==
                                                              'vertical'
                                                          ? paginationHeightWidth
                                                              .value
                                                              .toDouble()
                                                          : 0
                                                      : 0,
                                                ),
                                                child: FlexibleGrid(
                                                    options:
                                                        FlexibleGridOptions(
                                                  customWidth: gridSizes
                                                      .gridWidth
                                                      ?.toDouble(),
                                                  customHeight: gridSizes
                                                      .gridHeight
                                                      ?.toDouble(),
                                                  rows: gridRows.value,
                                                  columns: gridCols.value,
                                                  componentsToRender:
                                                      otherGridStreams[0],
                                                  backgroundColor:
                                                      const Color.fromRGBO(
                                                          217, 227, 234, 0.99),
                                                  showAspect: addGrid.value &&
                                                      otherGridStreams[0]
                                                          .isNotEmpty,
                                                )),
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                  top: gridSizes.gridHeight
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
                                                      ? paginationDirection
                                                                  .value ==
                                                              'vertical'
                                                          ? paginationHeightWidth
                                                              .value
                                                              .toDouble()
                                                          : 0
                                                      : 0,
                                                ),
                                                child: FlexibleGrid(
                                                    options:
                                                        FlexibleGridOptions(
                                                  customWidth: gridSizes
                                                          .altGridWidth
                                                          ?.toDouble() ??
                                                      0,
                                                  customHeight: gridSizes
                                                          .altGridHeight
                                                          ?.toDouble() ??
                                                      0,
                                                  rows: altGridRows.value,
                                                  columns: altGridCols.value,
                                                  componentsToRender:
                                                      otherGridStreams[1],
                                                  backgroundColor:
                                                      const Color.fromRGBO(
                                                          217, 227, 234, 0.99),
                                                  showAspect:
                                                      addAltGrid.value &&
                                                          otherGridStreams[1]
                                                              .isNotEmpty,
                                                )),
                                              ),
                                              ValueListenableBuilder<String>(
                                                  valueListenable:
                                                      meetingProgressTime,
                                                  builder: (context,
                                                      meetingProgressTime,
                                                      child) {
                                                    return MeetingProgressTimer(
                                                        options:
                                                            MeetingProgressTimerOptions(
                                                      meetingProgressTime:
                                                          meetingProgressTime,
                                                      initialBackgroundColor:
                                                          recordState == 'green'
                                                              ? Colors.green
                                                              : recordState ==
                                                                      'yellow'
                                                                  ? Colors
                                                                      .yellow
                                                                  : Colors.red,
                                                      showTimer:
                                                          mainHeightWidth == 0
                                                              ? true
                                                              : false,
                                                    ));
                                                  }),
                                              Visibility(
                                                visible: doPaginate.value,
                                                child: SizedBox(
                                                  width: paginationDirection
                                                              .value ==
                                                          'horizontal'
                                                      ? double.infinity
                                                      : paginationHeightWidth
                                                          .value
                                                          .toDouble(),
                                                  height: paginationDirection
                                                              .value ==
                                                          'horizontal'
                                                      ? paginationHeightWidth
                                                          .value
                                                          .toDouble()
                                                      : double.infinity,
                                                  child: Pagination(
                                                      options:
                                                          PaginationOptions(
                                                    totalPages:
                                                        numberPages.value,
                                                    currentUserPage:
                                                        currentUserPage.value,
                                                    showAspect:
                                                        doPaginate.value,
                                                    paginationHeight:
                                                        paginationHeightWidth
                                                            .value
                                                            .toDouble(),
                                                    direction:
                                                        paginationDirection
                                                            .value,
                                                    parameters:
                                                        mediasfuParameters,
                                                  )),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                ],
                              ),
                            );
                          }),
                    ],
                  ),
                ),
                Visibility(
                  visible: eventType.value == EventType.webinar ||
                      eventType.value == EventType.conference,
                  child: ValueListenableBuilder<double>(
                    valueListenable: controlHeight,
                    builder: (context, controlHeight, child) {
                      return SubAspectComponent(
                        options: SubAspectComponentOptions(
                            backgroundColor:
                                const Color.fromRGBO(217, 227, 234, 0.99),
                            showControls:
                                eventType.value == EventType.webinar ||
                                    eventType.value == EventType.conference,
                            defaultFractionSub: 40, //40 pixels
                            children: [
                              ControlButtonsComponent(
                                  options: ControlButtonsComponentOptions(
                                buttons: controlButtons,
                                buttonBackgroundColor: Colors.transparent,
                                alignment: MainAxisAlignment.spaceBetween,
                                vertical:
                                    false, // Set to true for vertical layout
                              )),
                            ]),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        : !validated
            ? (widget.options.credentials != null &&
                    widget.options.credentials!.apiKey.isNotEmpty
                ? renderpreJoinPageWidget() ?? renderWelcomePage()
                : renderWelcomePage())
            : const SizedBox();
  }

  Widget renderWelcomePage() {
    return WelcomePage(
      options: WelcomePageOptions(
        imgSrc:
            widget.options.imgSrc ?? 'https://mediasfu.com/images/logo192.png',
        updateIsLoadingModalVisible: updateIsLoadingModalVisible,
        updateValidated: updateValidated,
        updateApiUserName: updateApiUserName,
        updateApiToken: updateApiToken,
        updateLink: updateLink,
        updateRoomName: updateRoomName,
        updateMember: updateMember,
        showAlert: showAlert,
        connectSocket: connectSocket,
        updateSocket: updateSocket,
      ),
    );
  }

  Widget? renderpreJoinPageWidget() {
    return PreJoinPage(
      // return widget.options.preJoinPageWidget!(
      options: PreJoinPageOptions(
        parameters: PreJoinPageParameters(
          imgSrc: widget.options.imgSrc ??
              'https://mediasfu.com/images/logo192.png',
          updateIsLoadingModalVisible: updateIsLoadingModalVisible,
          updateValidated: updateValidated,
          updateApiUserName: updateApiUserName,
          updateApiToken: updateApiToken,
          updateLink: updateLink,
          updateRoomName: updateRoomName,
          updateMember: updateMember,
          showAlert: showAlert,
          connectSocket: connectSocket,
          connectLocalSocket: connectLocalSocket,
          updateSocket: updateSocket,
          updateLocalSocket: updateLocalSocket,
        ),
        localLink: widget.options.localLink,
        connectMediaSFU: widget.options.connectMediaSFU!,
        credentials: widget.options.credentials ??
            Credentials(apiUserName: '', apiKey: ''),
        customBuilder: widget.options.preJoinPageWidget,
        returnUI: widget.options.returnUI,
        noUIPreJoinOptionsCreate: widget.options.noUIPreJoinOptionsCreate,
        noUIPreJoinOptionsJoin: widget.options.noUIPreJoinOptionsJoin,
        joinMediaSFURoom: widget.options.joinMediaSFURoom,
        createMediaSFURoom: widget.options.createMediaSFURoom,
      ),
    );
  }

  Widget _buildRoomInterface() {
    return widget.options.returnUI != null && widget.options.returnUI == false
        ? Stack(
            children: [
              buildEventRoom(context),
            ],
          )
        : Stack(
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
            options: MenuModalOptions(
          backgroundColor: const Color.fromRGBO(181, 233, 229, 0.97),
          isVisible: isMenuModalVisible,
          onClose: () => updateIsMenuModalVisible(false),
          customButtons: customMenuButtons,
          roomName: roomName.value,
          adminPasscode: adminPasscode.value,
          islevel: islevel.value,
          eventType: eventType.value,
          localLink: widget.options.localLink,
        ));
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
              options: RecordingModalOptions(
                backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
                isRecordingModalVisible: isRecordingModalVisible,
                onClose: () {
                  updateIsRecordingModalVisible(false);
                },
                startRecording: startRecording,
                confirmRecording: confirmRecording,
                parameters: mediasfuParameters,
              ),
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
        return ValueListenableBuilder<List<Request>>(
          valueListenable: filteredRequestList,
          builder: (context, filteredRequestList, child) {
            return RequestsModal(
              options: RequestsModalOptions(
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
                parameters: mediasfuParameters,
              ),
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
        return ValueListenableBuilder<List<WaitingRoomParticipant>>(
          valueListenable: filteredWaitingRoomList,
          builder: (context, filteredWaitingRoomList, child) {
            return WaitingRoomModal(
              options: WaitingRoomModalOptions(
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
                parameters: mediasfuParameters,
              ),
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
            options: DisplaySettingsModalOptions(
          backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
          isVisible: isDisplaySettingsVisible,
          onClose: () {
            updateIsDisplaySettingsModalVisible(false);
          },
          parameters: mediasfuParameters,
        ));
      },
    );
  }

  Widget _buildEventSettingsModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isSettingsModalVisible,
      builder: (context, isSettingsVisible, child) {
        return EventSettingsModal(
            options: EventSettingsModalOptions(
          backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
          isVisible: isSettingsVisible,
          updateIsSettingsModalVisible: updateIsSettingsModalVisible,
          onClose: () {
            updateIsSettingsModalVisible(false);
          },
          audioSetting: audioSetting.value,
          videoSetting: videoSetting.value,
          screenshareSetting: screenshareSetting.value,
          chatSetting: chatSetting.value,
          updateAudioSetting: updateAudioSetting,
          updateVideoSetting: updateVideoSetting,
          updateScreenshareSetting: updateScreenshareSetting,
          updateChatSetting: updateChatSetting,
          roomName: roomName.value,
          socket: socket.value,
          showAlert: showAlert,
        ));
      },
    );
  }

  Widget _buildCoHostModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isCoHostModalVisible,
      builder: (context, isCoHostVisible, child) {
        return CoHostModal(
          options: CoHostModalOptions(
            isCoHostModalVisible: isCoHostVisible,
            onCoHostClose: () {
              updateIsCoHostModalVisible(false);
            },
            updateIsCoHostModalVisible: updateIsCoHostModalVisible,
            currentCohost: coHost.value,
            participants: participants.value,
            coHostResponsibility: coHostResponsibility.value,
            roomName: roomName.value,
            showAlert: showAlert,
            updateCoHostResponsibility: updateCoHostResponsibility,
            updateCoHost: updateCoHost,
            socket: socket.value,
          ),
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
              options: ParticipantsModalOptions(
                backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
                isParticipantsModalVisible: isParticipantsVisible,
                onParticipantsClose: () {
                  updateIsParticipantsModalVisible(false);
                },
                participantsCounter: participantsCounter.value,
                onParticipantsFilterChange: onParticipantsFilterChange,
                parameters: mediasfuParameters,
              ),
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
        return ValueListenableBuilder<List<Message>>(
          valueListenable: messages,
          builder: (context, messages, child) {
            return MessagesModal(
              options: MessagesModalOptions(
                backgroundColor: eventType.value == EventType.webinar ||
                        eventType.value == EventType.conference
                    ? const Color(0xFFF5F5F5)
                    : const Color.fromRGBO(255, 255, 255, 0.25),
                isMessagesModalVisible: isMessagesVisible,
                onMessagesClose: () {
                  updateIsMessagesModalVisible(false);
                },
                messages: messages,
                eventType: eventType.value,
                member: member.value,
                islevel: islevel.value,
                coHostResponsibility: coHostResponsibility.value,
                coHost: coHost.value,
                startDirectMessage: startDirectMessage.value,
                directMessageDetails: directMessageDetails.value,
                updateStartDirectMessage: updateStartDirectMessage,
                updateDirectMessageDetails: updateDirectMessageDetails,
                showAlert: showAlert,
                roomName: roomName.value,
                socket: socket.value,
                chatSetting: chatSetting.value,
              ),
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
          options: MediaSettingsModalOptions(
            backgroundColor: const Color.fromARGB(247, 210, 219, 218),
            isVisible: isMediaSettingsVisible,
            onClose: () {
              updateIsMediaSettingsModalVisible(false);
            },
            parameters: mediasfuParameters,
          ),
        );
      },
    );
  }

  Widget _buildConfirmExitModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isConfirmExitModalVisible,
      builder: (context, isConfirmExitVisible, child) {
        return ConfirmExitModal(
          options: ConfirmExitModalOptions(
            backgroundColor: const Color.fromRGBO(181, 233, 229, 0.97),
            isVisible: isConfirmExitVisible,
            onClose: () {
              updateIsConfirmExitModalVisible(false);
            },
            islevel: islevel.value,
            roomName: roomName.value,
            member: member.value,
            socket: socket.value,
          ),
        );
      },
    );
  }

  Widget _buildConfirmHereModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isConfirmHereModalVisible,
      builder: (context, isConfirmHereModalVisible, child) {
        return ConfirmHereModal(
          options: ConfirmHereModalOptions(
            backgroundColor: const Color.fromRGBO(181, 233, 229, 0.97),
            isConfirmHereModalVisible: isConfirmHereModalVisible,
            onConfirmHereClose: () {
              updateIsConfirmHereModalVisible(false);
            },
            roomName: roomName.value,
            socket: socket.value,
            member: member.value,
          ),
        );
      },
    );
  }

  Widget _buildShareEventModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isShareEventModalVisible,
      builder: (context, isShareEventModalVisible, child) {
        return ShareEventModal(
          options: ShareEventModalOptions(
            isShareEventModalVisible: isShareEventModalVisible,
            // updateIsShareEventModalVisible: updateIsShareEventModalVisible,
            onShareEventClose: () {
              updateIsShareEventModalVisible(false);
            },
            roomName: roomName.value,
            islevel: islevel.value,
            adminPasscode: adminPasscode.value,
            localLink: widget.options.localLink,
          ),
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
          return ValueListenableBuilder<List<Poll>>(
            valueListenable: polls,
            builder: (context, polls, child) {
              return PollModal(
                options: PollModalOptions(
                  isPollModalVisible: isPollVisible,
                  onClose: () {
                    updateIsPollModalVisible(false);
                  },
                  member: member.value,
                  islevel: islevel.value,
                  polls: polls,
                  poll: poll.value,
                  socket: socket.value,
                  roomName: roomName.value,
                  showAlert: showAlert,
                  updateIsPollModalVisible: updateIsPollModalVisible,
                  handleCreatePoll: handleCreatePoll,
                  handleEndPoll: handleEndPoll,
                  handleVotePoll: handleVotePoll,
                ),
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
                  options: BreakoutRoomsModalOptions(
                    backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
                    isVisible: isBreakoutRoomsVisible,
                    onBreakoutRoomsClose: () {
                      updateIsBreakoutRoomsModalVisible(false);
                    },
                    parameters: mediasfuParameters,
                  ),
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
          options: AlertComponentOptions(
            visible: isVisible,
            message: alertMessage.value,
            type: alertType.value,
            duration: alertDuration.value,
            onHide: () {
              updateAlertVisible(false);
            },
            textColor: const Color(0xFFFFFFFF),
          ),
        );
      },
    );
  }

  Widget _buildLoadingModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoadingModalVisible,
      builder: (context, isLoadingModalVisible, child) {
        return LoadingModal(
          options: LoadingModalOptions(
            isVisible: isLoadingModalVisible,
            backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
            displayColor: Colors.black,
          ),
        );
      },
    );
  }
}
