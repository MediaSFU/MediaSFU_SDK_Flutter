// ignore_for_file: empty_catches, non_constant_identifier_names
import '../../utils/image_utils.dart';
import 'package:flutter/material.dart';
import '../core/theme/mediasfu_theme.dart';
import '../core/theme/mediasfu_animations.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';

import '../../components/misc_components/prejoin_page.dart';
import '../translation_components/translation_settings_modal.dart'
    hide TranslationRoomConfig;

// import 'package:permission_handler/permission_handler.dart'; // handle permissions manually
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import 'package:flutter/services.dart'; // Import Services for platform-specific services
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

//initial values
import '../../methods/utils/initial_values.dart' show initialValuesState;

//import components for display (samples)
import '../../components/display_components/meeting_progress_timer.dart'
    show MeetingProgressTimerOptions, MeetingProgressTimerPositionOverride;
import '../display_components/modern_meeting_progress_timer.dart'
    show ModernMeetingProgressTimer;
import '../../components/display_components/participants_counter_badge.dart'
    show
        ParticipantsCounterBadge,
        ParticipantsCounterBadgeOptions,
        ParticipantsCounterBadgePositionOverride;
import '../../components/display_components/main_aspect_component.dart'
    show MainAspectComponent, MainAspectComponentOptions;
import '../../components/display_components/loading_modal.dart'
    show LoadingModalOptions;
import '../../components/display_components/control_buttons_component.dart'
    show ControlButtonsComponent, ControlButtonsComponentOptions;
import '../../components/display_components/control_buttons_alt_component.dart'
    show ControlButtonsAltComponent, ControlButtonsAltComponentOptions;
import '../../components/display_components/control_buttons_component_touch.dart'
    show ControlButtonsComponentTouchOptions, ButtonTouch;
import '../display_components/modern_control_buttons_component_touch.dart'
    show ModernControlButtonsComponentTouch;
import '../../components/display_components/other_grid_component.dart'
    show OtherGridComponent, OtherGridComponentOptions;
import '../../components/display_components/main_screen_component.dart'
    show MainScreenComponent, MainScreenComponentOptions;
import '../../components/display_components/main_grid_component.dart'
    show MainGridComponent, MainGridComponentOptions;
import '../../components/display_components/sub_aspect_component.dart'
    show SubAspectComponent, SubAspectComponentOptions;
import '../../components/display_components/main_container_component.dart'
    show MainContainerComponent, MainContainerComponentOptions;
import '../../components/display_components/alert_component.dart'
    show AlertComponentOptions;
import '../../components/menu_components/menu_modal.dart' show MenuModalOptions;
import '../../components/recording_components/recording_modal.dart'
    show RecordingModalOptions;
import '../../components/requests_components/requests_modal.dart'
    show RequestsModalOptions;
import '../../components/waiting_components/waiting_modal.dart'
    show WaitingRoomModalOptions;
import '../../components/display_settings_components/display_settings_modal.dart'
    show DisplaySettingsModalOptions;
import '../../components/event_settings_components/event_settings_modal.dart'
    show EventSettingsModalOptions;
import '../../components/co_host_components/co_host_modal.dart'
    show CoHostModalOptions;
import '../../components/participants_components/participants_modal.dart'
    show ParticipantsModalOptions;
import '../../components/message_components/messages_modal.dart'
    show MessagesModalOptions;
import '../../components/media_settings_components/media_settings_modal.dart'
    show MediaSettingsModalOptions;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../../components/exit_components/confirm_exit_modal.dart'
    show ConfirmExitModalOptions;
import '../../components/misc_components/confirm_here_modal.dart'
    show ConfirmHereModalOptions;
import '../../components/misc_components/share_event_modal.dart'
    show ShareEventModalOptions;
import '../misc_components/modern_share_event_modal.dart'
    show ModernShareEventModal;
import '../../components/misc_components/welcome_page.dart'
    show WelcomePageOptions;

import '../../components/polls_components/poll_modal.dart'
    show PollModalOptions;
import '../../components/breakout_components/breakout_rooms_modal.dart'
    show BreakoutRoomsModalOptions;
import '../permissions_components/modern_permissions_modal.dart'
    show ModernPermissionsModal, ModernPermissionsModalOptions;
import '../panelists_components/modern_panelists_modal.dart'
    show ModernPanelistsModal, ModernPanelistsModalOptions;

// Whiteboard components
import '../../components/whiteboard_components/whiteboard.dart'
    show Whiteboard, WhiteboardOptions;
import '../../components/whiteboard_components/whiteboard_shape.dart'
    show WhiteboardShape;
import '../../components/whiteboard_components/configure_whiteboard_modal.dart'
    show ConfigureWhiteboardModalOptions;
import '../../components/whiteboard_components/screenboard_modal.dart'
    show ScreenboardModal, ScreenboardModalOptions, ScreenboardModalParameters;
import '../../components/whiteboard_components/screenboard.dart'
    show Screenboard, ScreenboardOptions;

// Background components
import '../../components/background_components/background_modal.dart'
    show BackgroundModalOptions, BackgroundModalParameters;
import '../background_components/modern_background_modal.dart'
    show ModernBackgroundModal;
import '../../components/background_components/virtual_background_types.dart'
    show VirtualBackground, BackgroundType;
import '../../components/background_components/background_processor_service.dart'
    show BackgroundProcessorService;
import '../../components/background_components/native_virtual_background.dart'
    show NativeVirtualBackground;
import '../../components/background_components/screen_wake_lock.dart'
    show ScreenWakeLock;

// Pagination and display of media (samples)
import '../../components/display_components/pagination.dart'
    show PaginationOptions;
import '../display_components/modern_pagination.dart' show ModernPagination;
import '../../components/display_components/flexible_grid.dart'
    show FlexibleGridOptions;
import '../../components/display_components/flexible_video.dart'
    show FlexibleVideoOptions;
import '../../components/display_components/audio_grid.dart'
    show AudioGrid, AudioGridOptions;
import '../display_components/modern_flexible_grid.dart'
    show ModernFlexibleGrid;
import '../display_components/modern_flexible_video.dart'
    show ModernFlexibleVideo;

// Modern UI Components
import '../display_components/modern_loading_modal.dart'
    show ModernLoadingModal;
import '../display_components/modern_alert_component.dart'
    show ModernAlertComponent;
import '../core/theme/mediasfu_colors.dart' show MediasfuColors;

// import '../utils/modern_mini_audio_player.dart';
import '../menu_components/modern_menu_modal.dart' show ModernMenuModal;
import '../recording_components/modern_recording_modal.dart'
    show ModernRecordingModal;
import '../participants_components/modern_participants_modal.dart'
    show ModernParticipantsModal;
import '../message_components/modern_messages_modal.dart'
    show ModernMessagesModal;
import '../media_settings_components/modern_media_settings_modal.dart'
    show ModernMediaSettingsModal;
import '../display_settings_components/modern_display_settings_modal.dart'
    show ModernDisplaySettingsModal;
import '../event_settings_components/modern_event_settings_modal.dart'
    show ModernEventSettingsModal;
import '../requests_components/modern_requests_modal.dart'
    show ModernRequestsModal;
import '../waiting_components/modern_waiting_modal.dart'
    show ModernWaitingRoomModal;
import '../exit_components/modern_confirm_exit_modal.dart'
    show ModernConfirmExitModal;
import '../misc_components/modern_confirm_here_modal.dart'
    show ModernConfirmHereModal;
import '../misc_components/modern_prejoin_page.dart' show ModernPreJoinPage;
import '../misc_components/modern_welcome_page.dart' show ModernWelcomePage;
import '../polls_components/modern_poll_modal.dart' show ModernPollModal;
import '../co_host_components/modern_co_host_modal.dart' show ModernCoHostModal;
import '../breakout_components/modern_breakout_rooms_modal.dart'
    show ModernBreakoutRoomsModal;
import '../whiteboard_components/modern_configure_whiteboard_modal.dart'
    show ModernConfigureWhiteboardModal;
// import '../utils/modern_mini_audio_player.dart'; // For future builder integration

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
import '../../methods/whiteboard_methods/launch_configure_whiteboard.dart'
    show launchConfigureWhiteboard, LaunchConfigureWhiteboardOptions;

import '../../methods/recording_methods/stop_recording.dart'
    show stopRecording, StopRecordingOptions;
import '../../methods/recording_methods/update_recording.dart'
    show updateRecording, UpdateRecordingOptions;

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
import '../../methods/stream_methods/switch_video_alt.dart'
    show switchVideoAlt, SwitchVideoAltOptions;
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
    show
        prepopulateUserMedia,
        PrepopulateUserMediaOptions,
        PrepopulateUserMediaType;
import '../../consumers/get_videos.dart' show getVideos;
import '../../consumers/re_port.dart' show rePort;
import '../../consumers/trigger.dart' show trigger;
import '../../consumers/consumer_resume.dart'
    show consumerResume, ConsumerResumeType;
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
import '../../consumers/add_videos_grid.dart'
    show addVideosGrid, AddVideosGridType;
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
import '../../methods/utils/mini_audio_player/mini_audio_player.dart'
    show MiniAudioPlayer, MiniAudioPlayerOptions, MiniAudioPlayerType;
import '../../consumers/signal_new_consumer_transport.dart'
    show signalNewConsumerTransport, SignalNewConsumerTransportOptions;
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
import '../../methods/utils/get_media_devices_list.dart'
    show getMediaDevicesList;
import '../../methods/utils/get_participant_media.dart'
    show getParticipantMedia;
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
import '../../producers/socket_receive_methods/permission_receive_methods.dart'
    show
        permissionUpdated,
        permissionConfigUpdated,
        PermissionUpdatedOptions,
        PermissionConfigUpdatedOptions,
        PermissionUpdatedData,
        PermissionConfigUpdatedData;
import '../../methods/permissions_methods/update_permission_config.dart'
    show PermissionConfig;
import '../../producers/socket_receive_methods/panelist_receive_methods.dart'
    show
        panelistsUpdated,
        panelistFocusChanged,
        controlMedia,
        addedAsPanelist,
        removedFromPanelists,
        PanelistsUpdatedOptions,
        PanelistFocusChangedOptions,
        ControlMediaOptions,
        AddedAsPanelistOptions,
        RemovedFromPanelistsOptions,
        PanelistsUpdatedData,
        PanelistFocusChangedData,
        ControlMediaData,
        AddedAsPanelistData,
        RemovedFromPanelistsData;

import '../../producers/socket_receive_methods/translation_receive_methods.dart'
    show
        translationRoomConfig,
        translationConfigUpdated,
        translationLanguageSet,
        translationSubscribed,
        translationUnsubscribed,
        translationProducerReady,
        translationProducerClosed,
        translationChannelsAvailable,
        translationSpeakerOutputChanged,
        translationMemberState,
        translationError,
        translationTranscript,
        TranslationRoomConfig,
        TranslationRoomConfigData,
        TranslationRoomConfigOptions,
        TranslationConfigUpdatedData,
        TranslationConfigUpdatedOptions,
        TranslationLanguageSetData,
        TranslationLanguageSetOptions,
        TranslationSubscribedOptions,
        TranslationUnsubscribedOptions,
        TranslationProducerReadyOptions,
        TranslationProducerClosedOptions,
        TranslationChannelsAvailableOptions,
        TranslationSpeakerOutputChangedOptions,
        TranslationMemberStateData,
        TranslationMemberStateOptions,
        TranslationErrorData,
        TranslationErrorOptions,
        TranslationTranscriptOptions,
        TranslationSubscribedData,
        TranslationUnsubscribedData,
        TranslationProducerReadyData,
        TranslationProducerClosedData,
        TranslationChannelsAvailableData,
        TranslationSpeakerOutputChangedData,
        TranslationTranscriptData;

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
        ListenerTranslationPreferences,
        MainSpecs,
        MeetingRoomParams,
        TranslationMeta,
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
        CreateRoomOnMediaSFUType,
        LiveSubtitle;
import '../../methods/utils/create_response_join_room.dart'
    show createResponseJoinRoom, CreateResponseJoinRoomOptions;
import '../../methods/utils/mediasfu_parameters.dart' show MediasfuParameters;
import '../../types/custom_builders.dart'
    show
        VideoCardType,
        AudioCardType,
        MiniCardType,
        CustomComponentType,
        CustomWorkspaceBuilder;
import '../../types/ui_overrides.dart'
    show
        ContainerStyleOptions,
        DefaultComponentBuilder,
        MediasfuUICustomOverrides,
        withFunctionOverride,
        withOverride;

/// Enum to track which content is displayed in the desktop sidebar
enum SidebarContent {
  none,
  menu,
  participants,
  messages,
  requests,
  waiting,
  coHost,
  mediaSettings,
  displaySettings,
  eventSettings,
  recording,
  polls,
  breakoutRooms,
  shareEvent,
  configureWhiteboard,
  background,
  permissions,
  panelists,
  translation,
}

class ModernMediasfuGenericOptions {
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

  // Custom builders for display components
  VideoCardType? customVideoCard;
  AudioCardType? customAudioCard;
  MiniCardType? customMiniCard;

  // Custom component widget - allows complete replacement of the MediaSFU interface
  CustomComponentType? customComponent;
  ContainerStyleOptions? containerStyle;
  MediasfuUICustomOverrides? uiOverrides;

  /// Whether to use fixed link (stagerooms.mediasfu.com) instead of dynamic URL selection
  /// When true, always connects to stagerooms.mediasfu.com
  /// When false, URL is selected based on meeting ID prefix (d=demos, s=sandbox, p=production)
  bool? useFixedLink;

  /// App key for Flutter app authentication in socket handshake (X-App-Key)
  /// Used when connecting to local backend via localLink
  String? localAppKey;

  /// API username for backend authentication in socket handshake
  /// Used when connecting to local backend via localLink
  String? localApiUserName;

  /// API key for backend authentication in socket handshake
  /// Used when connecting to local backend via localLink
  String? localApiKey;

  /// Sub-username for organization/team member identification
  /// Used for subuser accounts within an organization
  String? localSubUserName;

  /// Initial meeting ID to pre-fill in the prejoin page
  /// Used for deep links like /meeting/:roomId
  String? initialMeetingId;

  /// Whether the user can use personal translation (billed to their account)
  /// When true and the room doesn't support translation, a personal translation
  /// request is automatically sent to the server
  bool canUsePersonalTranslation;

  /// Username for personal translation billing
  /// Required when canUsePersonalTranslation is true
  String? personalTranslationUsername;

  /// User's voice clones from their account, passed to the translation modal.
  /// Each clone is a map with keys: id, voiceId, name, provider, isDefault.
  List<Map<String, dynamic>>? userVoiceClones;

  /// When true, keeps the urn:3gpp:video-orientation RTP header extension
  /// so recorded video has correct orientation metadata.
  bool optimizeVideoRecord;

  /// Optional callback for navigating back from the prejoin/setup page.
  /// When provided, the setup page back button will call this instead of
  /// using Navigator.maybePop. Useful for apps using GoRouter or custom routing.
  VoidCallback? onBack;

  ModernMediasfuGenericOptions({
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
    this.customVideoCard,
    this.customAudioCard,
    this.customMiniCard,
    this.customComponent,
    this.containerStyle,
    this.uiOverrides,
    this.useFixedLink,
    this.localAppKey,
    this.localApiUserName,
    this.localApiKey,
    this.localSubUserName,
    this.initialMeetingId,
    this.canUsePersonalTranslation = false,
    this.personalTranslationUsername,
    this.userVoiceClones,
    this.optimizeVideoRecord = false,
    this.onBack,
    CustomWorkspaceBuilder? customWorkspaceBuilder,
  }) {
    applyCustomWorkspaceBuilder(customWorkspaceBuilder);
  }

  CustomComponentType? get customWorkspaceBuilder => customComponent;

  void applyCustomWorkspaceBuilder(CustomWorkspaceBuilder? builder) {
    if (builder != null) {
      customComponent = builder;
    }
  }
}

/// `MediasfuGeneric` - A generic widget for initializing and managing Mediasfu functionalities.
///
/// ### Parameters:
/// - `options` (`ModernMediasfuGenericOptions`): Configuration options for setting up the widget.
///
/// ### Example Usage:
/// ```dart
/// MediasfuGeneric(
///   options: ModernMediasfuGenericOptions(
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

class ModernMediasfuGeneric extends StatefulWidget {
  final ModernMediasfuGenericOptions options;

  const ModernMediasfuGeneric({
    super.key,
    required this.options,
  });

  @override
  _ModernMediasfuGenericState createState() => _ModernMediasfuGenericState();
}

class _ModernMediasfuGenericState extends State<ModernMediasfuGeneric> {
  bool validated = false;

  Map<String, dynamic> initialValues = initialValuesState;
  late MediasfuUICustomOverrides _uiOverrides;
  late ContainerStyleOptions _containerStyle;
  late ConsumerResumeType _consumerResumeHandler;
  late AddVideosGridType _addVideosGridHandler;
  late PrepopulateUserMediaType _prepopulateUserMediaHandler;
  late MiniAudioPlayerType _miniAudioPlayerHandler;
  late DefaultComponentBuilder<MainContainerComponentOptions>
      _mainContainerBuilder;
  late DefaultComponentBuilder<MainAspectComponentOptions> _mainAspectBuilder;
  late DefaultComponentBuilder<MainScreenComponentOptions> _mainScreenBuilder;
  late DefaultComponentBuilder<MainGridComponentOptions> _mainGridBuilder;
  late DefaultComponentBuilder<SubAspectComponentOptions> _subAspectBuilder;
  late DefaultComponentBuilder<OtherGridComponentOptions> _otherGridBuilder;
  late DefaultComponentBuilder<FlexibleGridOptions> _flexibleGridBuilder;
  late DefaultComponentBuilder<FlexibleGridOptions> _flexibleGridAltBuilder;
  late DefaultComponentBuilder<FlexibleVideoOptions> _flexibleVideoBuilder;
  late DefaultComponentBuilder<AudioGridOptions> _audioGridBuilder;
  late DefaultComponentBuilder<PaginationOptions> _paginationBuilder;
  late DefaultComponentBuilder<ControlButtonsComponentOptions>
      _controlButtonsBuilder;
  late DefaultComponentBuilder<ControlButtonsComponentTouchOptions>
      _controlButtonsTouchBuilder;
  late DefaultComponentBuilder<MeetingProgressTimerOptions>
      _meetingProgressTimerBuilder;
  late DefaultComponentBuilder<MenuModalOptions> _menuModalBuilder;
  late DefaultComponentBuilder<DisplaySettingsModalOptions>
      _displaySettingsModalBuilder;
  late DefaultComponentBuilder<MediaSettingsModalOptions>
      _mediaSettingsModalBuilder;
  late DefaultComponentBuilder<EventSettingsModalOptions>
      _eventSettingsModalBuilder;
  late DefaultComponentBuilder<RequestsModalOptions> _requestsModalBuilder;
  late DefaultComponentBuilder<WaitingRoomModalOptions>
      _waitingRoomModalBuilder;
  late DefaultComponentBuilder<ShareEventModalOptions> _shareEventModalBuilder;
  late DefaultComponentBuilder<RecordingModalOptions> _recordingModalBuilder;
  late DefaultComponentBuilder<CoHostModalOptions> _coHostModalBuilder;
  late DefaultComponentBuilder<ParticipantsModalOptions>
      _participantsModalBuilder;
  late DefaultComponentBuilder<MessagesModalOptions> _messagesModalBuilder;
  late DefaultComponentBuilder<PollModalOptions> _pollModalBuilder;
  late DefaultComponentBuilder<BreakoutRoomsModalOptions>
      _breakoutRoomsModalBuilder;
  late DefaultComponentBuilder<ConfigureWhiteboardModalOptions>
      _configureWhiteboardModalBuilder;
  late DefaultComponentBuilder<ScreenboardModalOptions>
      _screenboardModalBuilder;
  late DefaultComponentBuilder<WhiteboardOptions> _whiteboardBuilder;
  late DefaultComponentBuilder<ScreenboardOptions> _screenboardBuilder;
  late DefaultComponentBuilder<BackgroundModalOptions> _backgroundModalBuilder;
  late DefaultComponentBuilder<ConfirmExitModalOptions>
      _confirmExitModalBuilder;
  late DefaultComponentBuilder<AlertComponentOptions> _alertBuilder;
  late DefaultComponentBuilder<ConfirmHereModalOptions>
      _confirmHereModalBuilder;
  late DefaultComponentBuilder<LoadingModalOptions> _loadingModalBuilder;
  late DefaultComponentBuilder<PreJoinPageOptions> _preJoinPageBuilder;
  late DefaultComponentBuilder<WelcomePageOptions> _welcomePageBuilder;

  void _hydrateUiOverrides() {
    _uiOverrides =
        widget.options.uiOverrides ?? const MediasfuUICustomOverrides.empty();
    _containerStyle =
        widget.options.containerStyle ?? const ContainerStyleOptions();
    _consumerResumeHandler = withFunctionOverride<ConsumerResumeType>(
      base: consumerResume,
      override: _uiOverrides.consumerResume,
    );
    _addVideosGridHandler = withFunctionOverride<AddVideosGridType>(
      base: addVideosGrid,
      override: _uiOverrides.addVideosGrid,
    );
    _prepopulateUserMediaHandler =
        withFunctionOverride<PrepopulateUserMediaType>(
      base: prepopulateUserMedia,
      override: _uiOverrides.prepopulateUserMedia,
    );
    final miniAudioPlayerBuilder = withOverride<MiniAudioPlayerOptions>(
      override: _uiOverrides.miniAudioPlayer,
      baseBuilder: (context, options) => MiniAudioPlayer(options: options),
    );
    _miniAudioPlayerHandler = (options) => Builder(
          builder: (context) => miniAudioPlayerBuilder(context, options),
        );
    _mainContainerBuilder = withOverride<MainContainerComponentOptions>(
      override: _uiOverrides.mainContainer,
      baseBuilder: (context, options) =>
          MainContainerComponent(options: options),
    );
    _mainAspectBuilder = withOverride<MainAspectComponentOptions>(
      override: _uiOverrides.mainAspect,
      baseBuilder: (context, options) => MainAspectComponent(options: options),
    );
    _mainScreenBuilder = withOverride<MainScreenComponentOptions>(
      override: _uiOverrides.mainScreen,
      baseBuilder: (context, options) => MainScreenComponent(options: options),
    );
    _mainGridBuilder = withOverride<MainGridComponentOptions>(
      override: _uiOverrides.mainGrid,
      baseBuilder: (context, options) => MainGridComponent(options: options),
    );
    _subAspectBuilder = withOverride<SubAspectComponentOptions>(
      override: _uiOverrides.subAspect,
      baseBuilder: (context, options) => SubAspectComponent(options: options),
    );
    _otherGridBuilder = withOverride<OtherGridComponentOptions>(
      override: _uiOverrides.otherGrid,
      baseBuilder: (context, options) => OtherGridComponent(options: options),
    );
    _flexibleGridBuilder = withOverride<FlexibleGridOptions>(
      override: _uiOverrides.flexibleGrid,
      baseBuilder: (context, options) => ModernFlexibleGrid(
        options: options,
        isDarkMode: isDarkMode.value,
      ),
    );
    _flexibleGridAltBuilder = withOverride<FlexibleGridOptions>(
      override: _uiOverrides.flexibleGridAlt,
      baseBuilder: (context, options) => ModernFlexibleGrid(
        options: options,
        isDarkMode: isDarkMode.value,
      ),
    );
    _flexibleVideoBuilder = withOverride<FlexibleVideoOptions>(
      override: _uiOverrides.flexibleVideo,
      baseBuilder: (context, options) => ModernFlexibleVideo(
        options: options,
        isDarkMode: isDarkMode.value,
      ),
    );
    _audioGridBuilder = withOverride<AudioGridOptions>(
      override: _uiOverrides.audioGrid,
      baseBuilder: (context, options) => AudioGrid(options: options),
    );
    _paginationBuilder = withOverride<PaginationOptions>(
      override: _uiOverrides.pagination,
      baseBuilder: (context, options) => ModernPagination(
        options: options,
        // isDarkMode now comes from options.isDarkMode for reactivity
      ),
    );
    _controlButtonsBuilder = withOverride<ControlButtonsComponentOptions>(
      override: _uiOverrides.controlButtons,
      baseBuilder: (context, options) =>
          ControlButtonsComponent(options: options),
    );
    _controlButtonsTouchBuilder =
        withOverride<ControlButtonsComponentTouchOptions>(
      override: _uiOverrides.controlButtonsTouch,
      baseBuilder: (context, options) =>
          ModernControlButtonsComponentTouch(options: options),
    );
    _meetingProgressTimerBuilder = withOverride<MeetingProgressTimerOptions>(
      override: _uiOverrides.meetingProgressTimer,
      baseBuilder: (context, options) => ModernMeetingProgressTimer(
        options: options,
        useGlassmorphism: true,
        showIcon: true,
        showPulse: false, // Disabled - pulse effect on recording state
        animateOnChange: false, // Disabled - was causing blink every second
        recordingState: options.initialBackgroundColor == Colors.red
            ? 'red'
            : options.initialBackgroundColor == Colors.yellow
                ? 'yellow'
                : 'green',
      ),
    );
    _menuModalBuilder = withOverride<MenuModalOptions>(
      override: _uiOverrides.menuModal,
      baseBuilder: (context, options) => ModernMenuModal(options: options),
    );
    _displaySettingsModalBuilder = withOverride<DisplaySettingsModalOptions>(
      override: _uiOverrides.displaySettingsModal,
      baseBuilder: (context, options) =>
          ModernDisplaySettingsModal(options: options),
    );
    _mediaSettingsModalBuilder = withOverride<MediaSettingsModalOptions>(
      override: _uiOverrides.mediaSettingsModal,
      baseBuilder: (context, options) =>
          ModernMediaSettingsModal(options: options),
    );
    _eventSettingsModalBuilder = withOverride<EventSettingsModalOptions>(
      override: _uiOverrides.eventSettingsModal,
      baseBuilder: (context, options) =>
          ModernEventSettingsModal(options: options),
    );
    _requestsModalBuilder = withOverride<RequestsModalOptions>(
      override: _uiOverrides.requestsModal,
      baseBuilder: (context, options) => ModernRequestsModal(options: options),
    );
    _waitingRoomModalBuilder = withOverride<WaitingRoomModalOptions>(
      override: _uiOverrides.waitingRoomModal,
      baseBuilder: (context, options) =>
          ModernWaitingRoomModal(options: options),
    );
    _shareEventModalBuilder = withOverride<ShareEventModalOptions>(
      override: _uiOverrides.shareEventModal,
      baseBuilder: (context, options) =>
          ModernShareEventModal(options: options),
    );
    _recordingModalBuilder = withOverride<RecordingModalOptions>(
      override: _uiOverrides.recordingModal,
      baseBuilder: (context, options) => ModernRecordingModal(options: options),
    );
    _coHostModalBuilder = withOverride<CoHostModalOptions>(
      override: _uiOverrides.coHostModal,
      baseBuilder: (context, options) => ModernCoHostModal(options: options),
    );
    _participantsModalBuilder = withOverride<ParticipantsModalOptions>(
      override: _uiOverrides.participantsModal,
      baseBuilder: (context, options) =>
          ModernParticipantsModal(options: options),
    );
    _messagesModalBuilder = withOverride<MessagesModalOptions>(
      override: _uiOverrides.messagesModal,
      baseBuilder: (context, options) => ModernMessagesModal(options: options),
    );
    _pollModalBuilder = withOverride<PollModalOptions>(
      override: _uiOverrides.pollModal,
      baseBuilder: (context, options) => ModernPollModal(options: options),
    );
    _breakoutRoomsModalBuilder = withOverride<BreakoutRoomsModalOptions>(
      override: _uiOverrides.breakoutRoomsModal,
      baseBuilder: (context, options) =>
          ModernBreakoutRoomsModal(options: options),
    );
    _configureWhiteboardModalBuilder =
        withOverride<ConfigureWhiteboardModalOptions>(
      override: _uiOverrides.configureWhiteboardModal,
      baseBuilder: (context, options) =>
          ModernConfigureWhiteboardModal(options: options),
    );
    _screenboardModalBuilder = withOverride<ScreenboardModalOptions>(
      override: _uiOverrides.screenboardModal,
      baseBuilder: (context, options) => ScreenboardModal(options: options),
    );
    _whiteboardBuilder = withOverride<WhiteboardOptions>(
      override: _uiOverrides.whiteboard,
      baseBuilder: (context, options) => Whiteboard(options: options),
    );
    _screenboardBuilder = withOverride<ScreenboardOptions>(
      override: _uiOverrides.screenboard,
      baseBuilder: (context, options) => Screenboard(options: options),
    );
    _backgroundModalBuilder = withOverride<BackgroundModalOptions>(
      override: _uiOverrides.backgroundModal,
      baseBuilder: (context, options) =>
          ModernBackgroundModal(options: options),
    );
    _confirmExitModalBuilder = withOverride<ConfirmExitModalOptions>(
      override: _uiOverrides.confirmExitModal,
      baseBuilder: (context, options) =>
          ModernConfirmExitModal(options: options),
    );
    _alertBuilder = withOverride<AlertComponentOptions>(
      override: _uiOverrides.alert,
      baseBuilder: (context, options) => ModernAlertComponent(options: options),
    );
    _confirmHereModalBuilder = withOverride<ConfirmHereModalOptions>(
      override: _uiOverrides.confirmHereModal,
      baseBuilder: (context, options) =>
          ModernConfirmHereModal(options: options),
    );
    _loadingModalBuilder = withOverride<LoadingModalOptions>(
      override: _uiOverrides.loadingModal,
      baseBuilder: (context, options) => ModernLoadingModal(options: options),
    );
    _preJoinPageBuilder = withOverride<PreJoinPageOptions>(
      override: _uiOverrides.preJoinPage,
      baseBuilder: (context, options) => ModernPreJoinPage(options: options),
    );
    _welcomePageBuilder = withOverride<WelcomePageOptions>(
      override: _uiOverrides.welcomePage,
      baseBuilder: (context, options) => ModernWelcomePage(options: options),
    );
  }

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

      Future.delayed(const Duration(milliseconds: 1000), () {
        updateValidated(false);
        updateIsLoadingModalVisible(false);
        showAlert(
          message:
              "Failed to join the room. Please check your connection and try again.",
          type: "danger",
          duration: 3000,
        );
      });

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
        final mediaQuery = MediaQuery.of(context);
        final safeAreaInsets = mediaQuery.padding;
        // Use available height after safe area is subtracted
        final availableHeight =
            mediaQuery.size.height - safeAreaInsets.top - safeAreaInsets.bottom;

        // Adaptively set the control height for specific screen sizes
        //compute the fraction that give max of 40px to 3 decimal places
        final fraction = (40 / availableHeight).toStringAsFixed(3);
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

  // Theme state - dark mode by default for modern UI
  final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(true);

  void updateIsDarkMode(bool value) {
    isDarkMode.value = value;
    mediasfuParameters.isDarkModeValue = value;

    // Refresh grid to update MiniCard/VideoCard theme colors
    if (validated) {
      try {
        onScreenChanges(
          OnScreenChangesOptions(
            changed: true,
            parameters: mediasfuParameters,
          ),
        );
      } catch (_) {}
      try {
        _prepopulateUserMediaHandler(
          PrepopulateUserMediaOptions(
            name: hostLabel.value,
            parameters: mediasfuParameters,
          ),
        );
      } catch (_) {}
    }
  }

  // Meeting active state - for responsive updates
  final ValueNotifier<bool> isMeetingActive = ValueNotifier<bool>(false);

  void updateIsMeetingActive(bool value) {
    isMeetingActive.value = value;
  }

  // Desktop sidebar state - tracks which content is shown in the persistent sidebar
  final ValueNotifier<SidebarContent> activeSidebarContent =
      ValueNotifier<SidebarContent>(SidebarContent.none);

  // Sidebar navigation stack - for back navigation from sub-content to menu
  final ValueNotifier<List<SidebarContent>> sidebarNavigationStack =
      ValueNotifier<List<SidebarContent>>([]);

  void updateActiveSidebarContent(SidebarContent content,
      {bool pushToStack = false}) {
    // Toggle off if same content is selected
    if (activeSidebarContent.value == content) {
      activeSidebarContent.value = SidebarContent.none;
      sidebarNavigationStack.value = [];
    } else {
      // If pushing to stack (navigating from menu to sub-content), save current
      if (pushToStack && activeSidebarContent.value != SidebarContent.none) {
        sidebarNavigationStack.value = [
          ...sidebarNavigationStack.value,
          activeSidebarContent.value
        ];
      } else if (!pushToStack) {
        // Direct navigation - clear stack
        sidebarNavigationStack.value = [];
      }
      activeSidebarContent.value = content;
    }
  }

  /// Navigate back in sidebar stack (return to previous content like menu)
  void sidebarNavigateBack() {
    if (sidebarNavigationStack.value.isNotEmpty) {
      final stack = [...sidebarNavigationStack.value];
      final previousContent = stack.removeLast();
      sidebarNavigationStack.value = stack;
      activeSidebarContent.value = previousContent;
    } else {
      activeSidebarContent.value = SidebarContent.none;
    }
  }

  /// Close sidebar completely and clear navigation stack
  void closeSidebar() {
    activeSidebarContent.value = SidebarContent.none;
    sidebarNavigationStack.value = [];
  }

  /// Check if we should use desktop sidebar layout
  bool get shouldUseSidebar {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final isWide = mediaQuery.size.width >= 1200;
    return isLandscape && isWide;
  }

  /// Check if button labels should be shown (screens >= 576px width)
  bool get shouldShowButtonLabels {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width >= 576;
  }

  /// Calculate sidebar width based on screen size
  /// Returns 0 if sidebar should not be shown or is not visible
  double getSidebarWidth(double screenWidth) {
    if (!shouldUseSidebar ||
        activeSidebarContent.value == SidebarContent.none) {
      return 0;
    }
    final calculatedWidth = screenWidth * 0.20;
    if (calculatedWidth < 280) return 280;
    if (calculatedWidth > 420) return 420;
    return calculatedWidth;
  }

  /// Get effective content width accounting for sidebar
  double getEffectiveContentWidth(double screenWidth) {
    return screenWidth - getSidebarWidth(screenWidth);
  }

  // Smart launch wrappers - show in sidebar on desktop, modal on mobile
  // These functions call the original launch functions which may contain
  // additional logic (permissions, validations, etc.) and then either
  // show in sidebar (desktop) or modal (mobile/tablet)

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

  // Translation state
  String mySpokenLanguage = 'en';
  bool mySpokenLanguageEnabled = false;
  String? myDefaultOutputLanguage;
  ListenerTranslationPreferences listenerTranslationPreferences =
      ListenerTranslationPreferences(perSpeaker: {});
  Map<String, TranslationMeta> translationProducerMap = {};
  Map<String, dynamic> speakerTranslationStates = {};
  Map<String, String> listenerTranslationOverrides = {};
  Map<String, Map<String, dynamic>> availableTranslationChannels = {};
  List<TranslationTranscriptData> transcripts = [];
  Set<String> activeTranslationProducerIds = {};
  final Set<String> translationFirstRenderForced =
      {}; // Track speakers whose translation audio has been "nudged" (first transcript re-render)
  Set<String> translationSubscriptions = {};
  TranslationRoomConfig? translationConfig;
  final ValueNotifier<bool> translationSupported = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPersonalTranslation = ValueNotifier<bool>(false);

  // Live Subtitles on Video Cards
  /// Whether to show subtitles on participant video cards
  final ValueNotifier<bool> showSubtitlesOnCards = ValueNotifier<bool>(false);

  /// Per-speaker live subtitle data: Map<speakerId, LiveSubtitle>
  final ValueNotifier<Map<String, LiveSubtitle>> liveSubtitles =
      ValueNotifier<Map<String, LiveSubtitle>>({});

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
  final ValueNotifier<String> meetingDisplayType = ValueNotifier('all');
  final ValueNotifier<bool> meetingVideoOptimized = ValueNotifier(false);
  final ValueNotifier<EventType> eventType = ValueNotifier(EventType.webinar);
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
  final ValueNotifier<bool> isSpeakerphoneOn = ValueNotifier(false);
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
  double mainHeightWidth = 67;
  final ValueNotifier<double> prevMainHeightWidth = ValueNotifier(67);
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
  final ValueNotifier<List<Widget>> translationStreams = ValueNotifier([]);
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
  final ValueNotifier<bool> selfViewForceFull = ValueNotifier(false);
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
  ValueNotifier<VirtualBackground?> selectedBackground =
      ValueNotifier<VirtualBackground?>(null);

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
  ValueNotifier<List<WhiteboardShape>> shapes =
      ValueNotifier<List<WhiteboardShape>>([]);
  ValueNotifier<bool> useImageBackground = ValueNotifier<bool>(true);
  ValueNotifier<List<WhiteboardShape>> redoStack =
      ValueNotifier<List<WhiteboardShape>>([]);
  ValueNotifier<List<String>> undoStack = ValueNotifier<List<String>>([]);
  ValueNotifier<MediaStream?> canvasStream = ValueNotifier<MediaStream?>(null);
  ValueNotifier<GlobalKey?> canvasWhiteboard = ValueNotifier<GlobalKey?>(null);

// Screenboard-related variables
  ValueNotifier<dynamic> canvasScreenboard = ValueNotifier<dynamic>(null);
  ValueNotifier<MediaStream?> processedScreenStream =
      ValueNotifier<MediaStream?>(null);
  ValueNotifier<bool> annotateScreenStream =
      ValueNotifier<bool>(false); // Annotate screen stream as boolean
  ValueNotifier<dynamic> mainScreenCanvas = ValueNotifier<dynamic>(null);
  ValueNotifier<bool> isScreenboardModalVisible = ValueNotifier<bool>(false);

  // Permissions-related variables
  ValueNotifier<bool> isPermissionsModalVisible = ValueNotifier<bool>(false);
  ValueNotifier<PermissionConfig?> permissionConfig =
      ValueNotifier<PermissionConfig?>(null);

  // Panelists-related variables
  ValueNotifier<bool> isPanelistsModalVisible = ValueNotifier<bool>(false);
  ValueNotifier<List<Participant>> panelists =
      ValueNotifier<List<Participant>>([]);
  ValueNotifier<bool> panelistFocusChangedValue = ValueNotifier<bool>(false);
  ValueNotifier<bool> panelistsFocused = ValueNotifier<bool>(false);
  ValueNotifier<bool> muteOthersMic = ValueNotifier<bool>(false);
  ValueNotifier<bool> muteOthersCamera = ValueNotifier<bool>(false);

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
  final ValueNotifier<bool> isTranslationSettingsModalVisible =
      ValueNotifier(false);
  // totalReqWait variable and update method
  final ValueNotifier<int> totalReqWait = ValueNotifier(0);
  // Other Modals
  final ValueNotifier<bool> isParticipantsModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isMessagesModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isConfirmExitModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> isConfirmHereModalVisible = ValueNotifier(false);
  bool _suppressConfirmHere =
      false; // Session-level suppress for "Are you still here?" modal
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

  // Translation update methods
  void updateListenerTranslationPreferences(
      ListenerTranslationPreferences value) {
    if (!mounted) return;
    setState(() {
      listenerTranslationPreferences = value;
      mediasfuParameters.listenerTranslationPreferences = value;
    });
  }

  void updateListenerTranslationOverrides(Map<String, String> value) {
    if (!mounted) return;
    setState(() {
      listenerTranslationOverrides = value;
      mediasfuParameters.listenerTranslationOverrides = value;
    });
  }

  void updateTranslationProducerMap(Map<String, TranslationMeta> value) {
    if (!mounted) return;
    setState(() {
      translationProducerMap = value;
      mediasfuParameters.translationProducerMap = value;
    });
  }

  void updateSpeakerTranslationStates(Map<String, dynamic> value) {
    if (!mounted) return;
    setState(() {
      speakerTranslationStates = value;
      mediasfuParameters.speakerTranslationStates = value;
    });
  }

  void updateTranslationConfig(TranslationRoomConfig? value) {
    if (!mounted) return;
    setState(() {
      translationConfig = value;
      // Also update translationSupported state based on config
      translationSupported.value = value?.supportTranslation == true;
    });
  }

  void updateMySpokenLanguage(String value) {
    if (!mounted) return;
    setState(() {
      mySpokenLanguage = value;
    });
  }

  void updateMySpokenLanguageEnabled(bool value) {
    if (!mounted) return;
    setState(() {
      mySpokenLanguageEnabled = value;
    });
  }

  void updateMyDefaultOutputLanguage(String value) {
    if (!mounted) return;
    setState(() {
      myDefaultOutputLanguage = value;
    });
  }

  void updateTranslationSupported(bool value) {
    if (!mounted) return;
    translationSupported.value = value;
  }

  // Live Subtitle update methods
  void updateShowSubtitlesOnCards(bool value) {
    if (!mounted) return;
    showSubtitlesOnCards.value = value;
  }

  void updateLiveSubtitles(Map<String, LiveSubtitle> value) {
    if (!mounted) return;
    liveSubtitles.value = value;
  }

  /// Updates or adds a live subtitle for a specific speaker
  void updateLiveSubtitleForSpeaker(String speakerId, LiveSubtitle subtitle) {
    if (!mounted) return;
    final updated = Map<String, LiveSubtitle>.from(liveSubtitles.value);
    updated[speakerId] = subtitle;
    liveSubtitles.value = updated;
  }

  /// Removes expired subtitles from the map
  void cleanupExpiredSubtitles() {
    if (!mounted) return;
    final now = DateTime.now();
    final updated = Map<String, LiveSubtitle>.from(liveSubtitles.value);
    updated.removeWhere((_, subtitle) => now.isAfter(subtitle.expiresAt));
    if (updated.length != liveSubtitles.value.length) {
      liveSubtitles.value = updated;
    }
  }

  void updateAvailableTranslationChannels(
      String speakerId, List<String> languages, String originalProducerId) {
    if (!mounted) return;
    setState(() {
      availableTranslationChannels[speakerId] = {
        'languages': languages,
        'originalProducerId': originalProducerId,
      };
    });
  }

  Future<void> startConsumingTranslation(String producerId, String speakerId,
      String language, String originalProducerId) async {
    // Track this producer ID as a translation producer so consumerResume can identify it
    activeTranslationProducerIds.add(producerId);

    // Get the target socket (main socket for now)
    final targetSocket = socket.value;
    if (targetSocket == null) {
      return;
    }

    // Signal new consumer transport
    try {
      await signalNewConsumerTransport(
        SignalNewConsumerTransportOptions(
          remoteProducerId: producerId,
          islevel: islevel.value,
          nsock: targetSocket,
          parameters: mediasfuParameters,
        ),
      );

      // Pause original producer if we have it
      if (originalProducerId.isNotEmpty) {
        await pauseOriginalProducer(originalProducerId, speakerId);
      }
    } catch (_) {}
  }

  Future<void> stopConsumingTranslation(
      String speakerId, String language) async {
    // Find and close the consumer for this speaker/language combination
    String? producerIdToClose;
    String? originalProducerId;

    for (final entry in translationProducerMap.entries) {
      final meta = entry.value;
      if (meta.speakerId == speakerId &&
          meta.language.toLowerCase() == language.toLowerCase()) {
        producerIdToClose = entry.key;
        originalProducerId = meta.originalProducerId;
        break;
      }
    }

    if (producerIdToClose != null) {
      await stopConsumingTranslationById(producerIdToClose);

      if (originalProducerId != null) {
        await resumeOriginalProducer(originalProducerId, speakerId);
      }
    }
  }

  Future<void> stopConsumingTranslationById(String producerId) async {
    // Find and close the consumer transport for this producer
    final transportIndex = consumerTransports.value.indexWhere(
      (t) => t.producerId == producerId,
    );

    if (transportIndex != -1) {
      final transport = consumerTransports.value[transportIndex];

      // Close consumer on server
      transport.socket_.emit('consumer-close', {
        'serverConsumerId': transport.serverConsumerTransportId,
      });

      // Close consumer locally
      transport.consumer.close();

      // Remove from tracking
      activeTranslationProducerIds.remove(producerId);

      // Remove from consumer transports
      final updatedTransports =
          List<TransportType>.from(consumerTransports.value);
      updatedTransports.removeAt(transportIndex);
      updateConsumerTransports(updatedTransports);

      // Remove from consumingTransports
      final updatedConsuming = List<String>.from(consumingTransports.value);
      updatedConsuming.remove(producerId);
      updateConsumingTransports(updatedConsuming);
    }

    // Remove translation stream widget from UI
    removeTranslationStream(producerId);

    // Remove from translationProducerMap
    if (mounted) {
      setState(() {
        translationProducerMap.remove(producerId);
      });
    }
  }

  void updateSpeakerTranslationState(
      String speakerId, String? outputLanguage, String originalProducerId) {
    if (!mounted) return;
    setState(() {
      speakerTranslationStates[speakerId] = {
        'outputLanguage': outputLanguage,
        'originalProducerId': originalProducerId,
      };
    });
  }

  Future<void> pauseOriginalProducer(
      String originalProducerId, String speakerId) async {
    // Find the consumer transport for the original producer
    final transportIndex = consumerTransports.value.indexWhere(
      (t) => t.producerId == originalProducerId,
    );

    if (transportIndex != -1) {
      final transport = consumerTransports.value[transportIndex];
      try {
        transport.consumer.pause();

        // Notify server to stop sending original audio data
        transport.socket_.emit('consumer-pause', {
          'serverConsumerId': transport.consumer.id,
        });
      } catch (_) {}
    }
  }

  Future<void> resumeOriginalProducer(
      String originalProducerId, String speakerId) async {
    // Find the consumer transport for the original producer
    final transportIndex = consumerTransports.value.indexWhere(
      (t) => t.producerId == originalProducerId,
    );

    if (transportIndex != -1) {
      final transport = consumerTransports.value[transportIndex];
      try {
        transport.consumer.resume();
      } catch (_) {}
    }
  }

  Future<void> stopConsumingTranslationForSpeaker(String speakerId) async {
    // Find all translation producers for this speaker and close them
    final producersToClose = <String>[];
    for (final entry in translationProducerMap.entries) {
      if (entry.value.speakerId == speakerId) {
        producersToClose.add(entry.key);
      }
    }

    for (final producerId in producersToClose) {
      await stopConsumingTranslationById(producerId);
    }
  }

  void updateListenPreferencesWrapper(
      Map<String, String> Function(Map<String, String>) updater) {
    final currentMap = listenerTranslationPreferences.perSpeaker;
    final newMap = updater(currentMap);
    updateListenerTranslationPreferences(ListenerTranslationPreferences(
        perSpeaker: newMap,
        globalLanguage: listenerTranslationPreferences.globalLanguage));
  }

  void updateTranscriptsWrapper(
      List<TranslationTranscriptData> Function(List<TranslationTranscriptData>)
          updater) {
    if (!mounted) return;
    setState(() {
      transcripts = updater(transcripts);
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

    // Close sidebar when validation fails (meeting ended, user disconnected, etc.)
    if (!value) {
      closeSidebar();
      updateIsMeetingActive(false);
      // Disable screen wake lock when leaving meeting
      ScreenWakeLock.disable().catchError((_) => false);
    } else {
      updateIsMeetingActive(true);
      // Enable screen wake lock to keep screen on during meeting
      ScreenWakeLock.enable().catchError((_) => false);
    }

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
      // if webinar and mainHeightWidth is 92, change to 67
      if (value == EventType.webinar && mainHeightWidth == 92) {
        mainHeightWidth = 67;
        updateComponentSizes(ComponentSizes(
            mainHeight: mainHeightWidth,
            otherHeight: componentSizes.value.otherHeight,
            mainWidth: mainHeightWidth,
            otherWidth: componentSizes.value.otherWidth));
      }
      // For conference mode without screen sharing, mainHeightWidth should be 0
      // so the participant grid fills the entire screen
      if (value == EventType.conference &&
          !shareScreenStarted.value &&
          !shared.value &&
          !(whiteboardStarted.value && !whiteboardEnded.value) &&
          mainHeightWidth != 0) {
        mainHeightWidth = 0;
        mediasfuParameters.mainHeightWidth = 0;
        updateSpecificState(
            widget.options.sourceParameters, 'mainHeightWidth', 0.0);
      }
    });
    if (value == EventType.chat ||
        value == EventType.conference ||
        value == EventType.webinar) {
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
    if (value || whiteboardStarted.value) {
      updateMainHeightWidth(84.0);
    }
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

  void updateIsSpeakerphoneOn(bool value) {
    isSpeakerphoneOn.value = value;
    mediasfuParameters.isSpeakerphoneOn = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isSpeakerphoneOn', value);
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
      // Recalculate component sizes when mainHeightWidth changes (immediate for responsiveness)
      _handleOrientationChange(immediate: true);

      try {
        onScreenChanges(
          OnScreenChangesOptions(
            changed: true,
            parameters: mediasfuParameters,
          ),
        );
      } catch (error) {}

      try {
        _prepopulateUserMediaHandler(
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

  void addTranslationStream(Widget stream) {
    final currentStreams = List<Widget>.from(translationStreams.value);
    currentStreams.add(stream);
    translationStreams.value = currentStreams;
  }

  void removeTranslationStream(String producerId) {
    final currentStreams = List<Widget>.from(translationStreams.value);
    currentStreams
        .removeWhere((widget) => widget.key == Key('translation-$producerId'));
    translationStreams.value = currentStreams;
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
    _prepopulateUserMediaHandler(
      PrepopulateUserMediaOptions(
        name: hostLabel.value,
        parameters: mediasfuParameters,
      ),
    );
  }

  void updatePrevForceFullDisplay(bool value) {
    prevForceFullDisplay.value = value;
    mediasfuParameters.prevForceFullDisplay = value;
    updateSpecificState(
        widget.options.sourceParameters, 'prevForceFullDisplay', value);
  }

  void updateSelfViewForceFull(bool value) {
    selfViewForceFull.value = value;
    mediasfuParameters.selfViewForceFull = value;
    updateSpecificState(
        widget.options.sourceParameters, 'selfViewForceFull', value);
    // Trigger screen refresh to apply the self-view display change
    onScreenChanges(OnScreenChangesOptions(
      changed: true,
      parameters: mediasfuParameters,
    ));
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
    // Route to sidebar on desktop, or sidebar modal on mobile
    if (value) {
      updateActiveSidebarContent(SidebarContent.menu);
      // Don't show floating modal when using sidebar (desktop or mobile)
      isMenuModalVisible.value = false;
    } else {
      // Closing - also close sidebar if showing menu
      if (activeSidebarContent.value == SidebarContent.menu) {
        closeSidebar();
      }
      isMenuModalVisible.value = false;
    }
    mediasfuParameters.isMenuModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isMenuModalVisible', value);
  }

  void updateIsRecordingModalVisible(bool value) {
    // Route to sidebar (desktop embedded or mobile modal)
    if (value) {
      final pushToStack = activeSidebarContent.value == SidebarContent.menu;
      updateActiveSidebarContent(SidebarContent.recording,
          pushToStack: pushToStack);
      isRecordingModalVisible.value = false;
    } else {
      if (activeSidebarContent.value == SidebarContent.recording) {
        sidebarNavigateBack();
      }
      isRecordingModalVisible.value = false;
      if (clearedToRecord.value == true &&
          clearedToResume.value == true &&
          recordStarted.value == true) {
        updateShowRecordButtons(true);
      }
    }
    mediasfuParameters.isRecordingModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isRecordingModalVisible', value);
    if (value) {
      updateConfirmedToRecord(false);
    }
  }

  void updateIsSettingsModalVisible(bool value) {
    // Route to sidebar (desktop embedded or mobile modal)
    if (value) {
      final pushToStack = activeSidebarContent.value == SidebarContent.menu;
      updateActiveSidebarContent(SidebarContent.eventSettings,
          pushToStack: pushToStack);
      isSettingsModalVisible.value = false;
    } else {
      if (activeSidebarContent.value == SidebarContent.eventSettings) {
        sidebarNavigateBack();
      }
      isSettingsModalVisible.value = false;
    }
    mediasfuParameters.isSettingsModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isSettingsModalVisible', value);
  }

  void updateIsRequestsModalVisible(bool value) {
    // Route to sidebar (desktop embedded or mobile modal)
    if (value) {
      final pushToStack = activeSidebarContent.value == SidebarContent.menu;
      updateActiveSidebarContent(SidebarContent.requests,
          pushToStack: pushToStack);
      isRequestsModalVisible.value = false;
    } else {
      if (activeSidebarContent.value == SidebarContent.requests) {
        sidebarNavigateBack();
      }
      isRequestsModalVisible.value = false;
    }
    mediasfuParameters.isRequestsModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isRequestsModalVisible', value);
  }

  void updateIsWaitingModalVisible(bool value) {
    // Route to sidebar (desktop embedded or mobile modal)
    if (value) {
      final pushToStack = activeSidebarContent.value == SidebarContent.menu;
      updateActiveSidebarContent(SidebarContent.waiting,
          pushToStack: pushToStack);
      isWaitingModalVisible.value = false;
    } else {
      if (activeSidebarContent.value == SidebarContent.waiting) {
        sidebarNavigateBack();
      }
      isWaitingModalVisible.value = false;
    }
    mediasfuParameters.isWaitingModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isWaitingModalVisible', value);
  }

  void updateIsCoHostModalVisible(bool value) {
    // Route to sidebar (desktop embedded or mobile modal)
    if (value) {
      final pushToStack = activeSidebarContent.value == SidebarContent.menu;
      updateActiveSidebarContent(SidebarContent.coHost,
          pushToStack: pushToStack);
      isCoHostModalVisible.value = false;
    } else {
      if (activeSidebarContent.value == SidebarContent.coHost) {
        sidebarNavigateBack();
      }
      isCoHostModalVisible.value = false;
    }
    mediasfuParameters.isCoHostModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isCoHostModalVisible', value);
  }

  void updateIsMediaSettingsModalVisible(bool value) {
    // Route to sidebar (desktop embedded or mobile modal)
    if (value) {
      final pushToStack = activeSidebarContent.value == SidebarContent.menu;
      updateActiveSidebarContent(SidebarContent.mediaSettings,
          pushToStack: pushToStack);
      isMediaSettingsModalVisible.value = false;
    } else {
      if (activeSidebarContent.value == SidebarContent.mediaSettings) {
        sidebarNavigateBack();
      }
      isMediaSettingsModalVisible.value = false;
    }
    mediasfuParameters.isMediaSettingsModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isMediaSettingsModalVisible', value);
  }

  void updateIsDisplaySettingsModalVisible(bool value) {
    // Route to sidebar (desktop embedded or mobile modal)
    if (value) {
      final pushToStack = activeSidebarContent.value == SidebarContent.menu;
      updateActiveSidebarContent(SidebarContent.displaySettings,
          pushToStack: pushToStack);
      isDisplaySettingsModalVisible.value = false;
    } else {
      if (activeSidebarContent.value == SidebarContent.displaySettings) {
        sidebarNavigateBack();
      }
      isDisplaySettingsModalVisible.value = false;
    }
    mediasfuParameters.isDisplaySettingsModalVisible = value;
    updateSpecificState(widget.options.sourceParameters,
        'isDisplaySettingsModalVisible', value);
  }

  void updateIsTranslationSettingsModalVisible(bool value) {
    isTranslationSettingsModalVisible.value = value;
  }

  void onShowTranslationSettings() {
    updateIsTranslationSettingsModalVisible(true);
  }

  void onCloseTranslationSettings() {
    updateIsTranslationSettingsModalVisible(false);
  }

  void updateIsParticipantsModalVisible(bool value) {
    // Route to sidebar (desktop embedded or mobile modal)
    if (value) {
      updateActiveSidebarContent(SidebarContent.participants);
      isParticipantsModalVisible.value = false;
    } else {
      if (activeSidebarContent.value == SidebarContent.participants) {
        closeSidebar();
      }
      isParticipantsModalVisible.value = false;
    }
    mediasfuParameters.isParticipantsModalVisible = value;
    updateSpecificState(
        widget.options.sourceParameters, 'isParticipantsModalVisible', value);
  }

  void updateIsMessagesModalVisible(bool value) {
    // Route to sidebar (desktop embedded or mobile modal)
    if (value) {
      updateActiveSidebarContent(SidebarContent.messages);
      isMessagesModalVisible.value = false;
    } else {
      if (activeSidebarContent.value == SidebarContent.messages) {
        closeSidebar();
      }
      isMessagesModalVisible.value = false;
    }
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
    // Route to sidebar (desktop embedded or mobile modal)
    if (value) {
      updateActiveSidebarContent(SidebarContent.shareEvent);
      isShareEventModalVisible.value = false;
    } else {
      if (activeSidebarContent.value == SidebarContent.shareEvent) {
        closeSidebar();
      }
      isShareEventModalVisible.value = false;
    }
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

    // Trigger prepopulate to update the video card mic indicator
    try {
      _prepopulateUserMediaHandler(PrepopulateUserMediaOptions(
        name: hostLabel.value,
        parameters: mediasfuParameters,
      ));
    } catch (error) {}
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
        _prepopulateUserMediaHandler(PrepopulateUserMediaOptions(
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
    // Route to sidebar (desktop embedded or mobile modal)
    if (value) {
      final pushToStack = activeSidebarContent.value == SidebarContent.menu;
      updateActiveSidebarContent(SidebarContent.polls,
          pushToStack: pushToStack);
      isPollModalVisible.value = false;
    } else {
      if (activeSidebarContent.value == SidebarContent.polls) {
        sidebarNavigateBack();
      }
      isPollModalVisible.value = false;
    }
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
    // Route to sidebar (desktop embedded or mobile modal)
    if (value) {
      final pushToStack = activeSidebarContent.value == SidebarContent.menu;
      updateActiveSidebarContent(SidebarContent.breakoutRooms,
          pushToStack: pushToStack);
      isBreakoutRoomsModalVisible.value = false;
    } else {
      if (activeSidebarContent.value == SidebarContent.breakoutRooms) {
        sidebarNavigateBack();
      }
      isBreakoutRoomsModalVisible.value = false;
    }
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

  void updateCustomVideoCard(VideoCardType? value) {
    mediasfuParameters.customVideoCard = value;
    updateSpecificState(
        widget.options.sourceParameters, 'customVideoCard', value);
  }

  void updateCustomAudioCard(AudioCardType? value) {
    mediasfuParameters.customAudioCard = value;
    updateSpecificState(
        widget.options.sourceParameters, 'customAudioCard', value);
  }

  void updateCustomMiniCard(MiniCardType? value) {
    mediasfuParameters.customMiniCard = value;
    updateSpecificState(
        widget.options.sourceParameters, 'customMiniCard', value);
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
    // Route to sidebar (desktop embedded or mobile modal)
    if (value) {
      updateActiveSidebarContent(SidebarContent.background);
      isBackgroundModalVisible.value = false;
    } else {
      if (activeSidebarContent.value == SidebarContent.background) {
        closeSidebar();
      }
      isBackgroundModalVisible.value = false;
    }
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

  void updateSelectedBackground(VirtualBackground? value) {
    selectedBackground.value = value;
    mediasfuParameters.selectedBackground = value;
    updateSpecificState(
        widget.options.sourceParameters, 'selectedBackground', value);
  }

  /// Handle virtual background application
  /// This is called when the user clicks "Apply" in the BackgroundModal
  /// Similar to the React saveBackground function
  ///
  /// React flow reference:
  /// ```javascript
  /// if (keepBackground && selectedImage && processedStream) {
  ///   virtualStream = processedStream;
  ///   videoParams = { track: virtualStream.getVideoTracks()[0] };
  ///   // Then reconnect transport with new video track
  /// }
  /// ```
  ///
  /// **NATIVE VIRTUAL BACKGROUND (Android):**
  /// On Android, we now use native frame processing via flutter_webrtc's
  /// LocalVideoTrack.ExternalVideoFrameProcessing. This allows:
  /// - LOCAL DISPLAY: Shows processed frames
  /// - REMOTE TRANSMISSION: Processed frames are sent to remote participants!
  ///
  /// **FALLBACK (iOS, Web, Desktop):**
  /// Uses BackgroundProcessorService for local display only.
  /// Remote viewers still see raw camera (Flutter limitation on these platforms).
  Future<void> handleBackgroundApply(VirtualBackground background) async {
    // Check for audio-only room (like React)
    if (audioOnlyRoom.value == true) {
      showAlert(
        message: 'You cannot use a background in an audio only event.',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    // Only proceed with changes if backgroundHasChanged is true
    final hasChanged = backgroundHasChanged.value == true;

    if (hasChanged) {
      // Check if video is already on (like React: if (videoAlreadyOn) { ... })
      if (videoAlreadyOn.value == true) {
        // Check if recording is active (like React)
        if (islevel.value == '2' &&
            (recordStarted.value == true || recordResumed.value == true)) {
          if (!(recordPaused.value == true || recordStopped.value == true)) {
            if (recordingMediaOptions.value == 'video') {
              showAlert(
                message:
                    'Please pause the recording before changing the background.',
                type: 'danger',
                duration: 3000,
              );
              return;
            }
          }
        }

        // Update the selected background
        updateSelectedBackground(background);

        // Try native processing first, fall back to local-only processing
        bool useNative = false;

        if (NativeVirtualBackground.isSupported) {
          useNative = await _applyNativeVirtualBackground(background);

          // If native VB succeeded, stop any fallback processor
          if (useNative) {
            try {
              await Future.delayed(const Duration(milliseconds: 100));
              final processorService = BackgroundProcessorService();
              await processorService.stop();
            } catch (_) {}
          }
        }

        if (!useNative) {
          await _applyLocalVirtualBackground(background);
        }

        // Call onScreenChanges to trigger UI update (like React)
        await onScreenChanges(OnScreenChangesOptions(
          changed: true,
          parameters: mediasfuParameters,
        ));
      }
    }

    // Update appliedBackground outside the if block (like React)
    if (keepBackground.value == true &&
        background.type != BackgroundType.none) {
      updateAppliedBackground(true);
    } else {
      updateAppliedBackground(false);
    }

    // Mark background has changed as false now that it's applied
    updateBackgroundHasChanged(false);

    // Show success message
    final isNative = NativeVirtualBackground.isSupported &&
        _nativeVirtualBackground?.isEnabled == true;
    if (background.type != BackgroundType.none) {
      final suffix = isNative ? '' : ' (Local view only)';
      showAlert(
        message: 'Virtual background "${background.name}" applied!$suffix',
        type: 'success',
        duration: 3000,
      );
    } else {
      showAlert(
        message: 'Virtual background removed',
        type: 'success',
        duration: 2000,
      );
    }

    // Close the modal
    updateIsBackgroundModalVisible(false);
  }

  /// Native virtual background instance
  NativeVirtualBackground? _nativeVirtualBackground;

  /// Apply virtual background using native frame processing.
  ///
  /// **Android/iOS/macOS:** Uses NativeVirtualBackground.
  /// Windows is not supported (libwebrtc has no PushFrame API).
  ///
  /// Returns true if native processing was successfully enabled.
  Future<bool> _applyNativeVirtualBackground(
      VirtualBackground background) async {
    try {
      _nativeVirtualBackground ??= NativeVirtualBackground();
      final native = _nativeVirtualBackground!;

      // Initialize if not already
      if (!native.isInitialized) {
        final initialized = await native.initialize();
        if (!initialized) {
          return false;
        }
      }

      if (background.type != BackgroundType.none &&
          keepBackground.value == true) {
        // Get the video track ID
        final videoTracks = localStreamVideo.value?.getVideoTracks();
        final trackId =
            videoTracks?.isNotEmpty == true ? videoTracks!.first.id : null;
        if (trackId == null) {
          return false;
        }

        // Get background image bytes
        final imageBytes = await background.getImageBytes();
        if (imageBytes == null) {
          return false;
        }

        // Enable native virtual background (loads ONNX model + sets BG image)
        final success = await native.enable(
          trackId: trackId,
          backgroundImage: imageBytes,
          confidence: 0.7,
        );

        if (!success) {
          return false;
        }

        updateAppliedBackground(true);
        return true;
      } else {
        // ----- Disable -----

        // Disable native virtual background
        await native.disable();
        updateAppliedBackground(false);
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  /// Apply virtual background using local-only processing (fallback).
  Future<void> _applyLocalVirtualBackground(
      VirtualBackground background) async {
    final processorService = BackgroundProcessorService();

    if (background.type != BackgroundType.none &&
        keepBackground.value == true) {
      // Start background processing for LOCAL display only
      // Note: Remote viewers will still see raw camera (Flutter limitation)
      try {
        await processorService.initialize();
        processorService.setBackground(background);
        if (localStreamVideo.value != null) {
          // Use vidCons dimensions so processing runs at the meeting's
          // resolution rather than the camera's native resolution.
          final vCons = vidCons.value;
          await processorService.start(
            localStreamVideo.value!,
            targetWidth: vCons.width.ideal,
            targetHeight: vCons.height.ideal,
          );
        }
      } catch (e) {
        // Ignore processor errors
      }

      // Update appliedBackground state
      updateAppliedBackground(true);
    } else {
      // Stop background processing
      await processorService.stop();
      processorService.setBackground(null);
      updateAppliedBackground(false);
    }
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
    if (value || screenShareActive) {
      updateMainHeightWidth(84.0);
    }
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
    // Route to sidebar (desktop embedded or mobile modal)
    if (value) {
      final pushToStack = activeSidebarContent.value == SidebarContent.menu;
      updateActiveSidebarContent(SidebarContent.configureWhiteboard,
          pushToStack: pushToStack);
      isConfigureWhiteboardModalVisible.value = false;
    } else {
      if (activeSidebarContent.value == SidebarContent.configureWhiteboard) {
        sidebarNavigateBack();
      }
      isConfigureWhiteboardModalVisible.value = false;
    }
    mediasfuParameters.isConfigureWhiteboardModalVisible = value;
    updateSpecificState(widget.options.sourceParameters,
        'isConfigureWhiteboardModalVisible', value);
  }

  void updateShapes(List<WhiteboardShape> value) {
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

  void updateRedoStack(List<WhiteboardShape> value) {
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

  void updateCanvasWhiteboard(GlobalKey? value) {
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

  // Permissions update methods
  void updateIsPermissionsModalVisible(bool value) {
    isPermissionsModalVisible.value = value;
  }

  void updatePermissionConfig(PermissionConfig? value) {
    permissionConfig.value = value;
    mediasfuParameters.permissionConfig = value;
    updateSpecificState(
        widget.options.sourceParameters, 'permissionConfig', value);
  }

  // Panelists update methods
  void updateIsPanelistsModalVisible(bool value) {
    isPanelistsModalVisible.value = value;
  }

  void updatePanelists(List<Participant> value) {
    panelists.value = value;
  }

  void updatePanelistFocusChanged(bool value) {
    panelistFocusChangedValue.value = value;
  }

  void updatePanelistsFocused(bool value) {
    panelistsFocused.value = value;
  }

  void updateMuteOthersMic(bool value) {
    muteOthersMic.value = value;
  }

  void updateMuteOthersCamera(bool value) {
    muteOthersCamera.value = value;
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

  List<ButtonTouch> recordButton = [];

  void initializeRecordButton() {
    recordButton = [
      // Record Button
      ButtonTouch(
        icon: Icons.fiber_manual_record,
        active: false,
        onPress: () {
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
        activeColor: const Color.fromARGB(255, 244, 3, 3),
        inActiveColor: const Color.fromARGB(255, 251, 9, 9),
        show: true,
        size: 30, // Increased for better visibility on larger screens
      ),
    ];
  }

  // Record Buttons
  List<AltButton> recordButtons = [];

  // Record Buttons Touch
  List<ButtonTouch> recordButtonsTouch = [];

  // Initialize Record Buttons
  // The record buttons are displayed in the control bar

  void initializeRecordButtons(bool isDarkModeVal) {
    recordButtons = [
      // Play/Pause Button
      AltButton(
        name: recordPaused.value ? 'Resume' : 'Pause',
        icon: Icons.play_circle_filled,
        active: !recordPaused.value,
        onPress: () => updateRecording(UpdateRecordingOptions(
          parameters: mediasfuParameters,
        )),
        activeColor:
            MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
        inActiveColor:
            MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
        alternateIcon: Icons.pause_circle_filled,
        show: true,
      ),
      // Stop Button
      AltButton(
        name: 'Stop',
        icon: Icons.stop_circle,
        active: false,
        onPress: () => stopRecording(
          StopRecordingOptions(
            parameters: mediasfuParameters,
          ),
        ),
        activeColor: MediasfuColors.success,
        inActiveColor:
            MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
        show: true,
      ),
      // Timer Display
      AltButton(
        name: 'Timer',
        customComponent: Tooltip(
          message: 'Recording duration',
          decoration: BoxDecoration(
            color: isDarkModeVal ? Colors.white : Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            color: isDarkModeVal ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(0),
            margin: const EdgeInsets.all(2),
            child: ValueListenableBuilder<String>(
              valueListenable: recordingProgressTime,
              builder: (context, value, child) {
                return Text(
                  value,
                  style: TextStyle(
                    color: MediasfuColors.controlTextColor(
                        darkMode: isDarkModeVal),
                    backgroundColor: Colors.transparent,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ),
        ),
        show: true,
      ),
      // Status Button
      AltButton(
        name: recordPaused.value ? 'Paused' : 'Recording',
        icon: Icons.circle,
        active: false,
        onPress: () => (),
        activeColor:
            MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
        inActiveColor: recordPaused.value == false
            ? MediasfuColors.danger
            : MediasfuColors.warning,
        show: true,
      ),
      // Settings Button
      AltButton(
        name: !recordPaused.value ? 'Settings - Pause to enable' : 'Settings',
        icon: Icons.settings,
        active: false,
        disabled: !recordPaused.value,
        onPress: () {
          if (!recordPaused.value) {
            showAlert(
              message: 'Please pause recording first to access settings',
              type: 'danger',
              duration: 3000,
            );
            return;
          }
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
        activeColor: MediasfuColors.success,
        inActiveColor: !recordPaused.value
            ? MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal)
                .withOpacity(0.4)
            : MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
        show: true,
      )
    ];
  }

  void initializeRecordButtonsTouch(bool isDarkModeVal) {
    recordButtonsTouch = [
      // Play/Pause Button
      ButtonTouch(
        name: recordPaused.value ? 'Resume' : 'Pause',
        semanticsLabel:
            recordPaused.value ? 'Resume recording' : 'Pause recording',
        icon: Icons.play_circle_filled,
        active: !recordPaused.value,
        onPress: () => updateRecording(UpdateRecordingOptions(
          parameters: mediasfuParameters,
        )),
        activeColor:
            MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
        inActiveColor:
            MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
        alternateIcon: Icons.pause_circle_filled,
        show: true,
      ),
      // Stop Button
      ButtonTouch(
        name: 'Stop',
        semanticsLabel: 'Stop recording',
        icon: Icons.stop_circle,
        active: false,
        onPress: () => stopRecording(
          StopRecordingOptions(
            parameters: mediasfuParameters,
          ),
        ),
        activeColor: MediasfuColors.success,
        inActiveColor:
            MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
        show: true,
      ),
      // Timer Display
      ButtonTouch(
        name: 'Timer',
        semanticsLabel: 'Recording duration',
        customComponent: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(0),
          margin: const EdgeInsets.all(2),
          child: ValueListenableBuilder<String>(
            valueListenable: recordingProgressTime,
            builder: (context, value, child) {
              return Text(
                value,
                style: TextStyle(
                  color:
                      MediasfuColors.controlTextColor(darkMode: isDarkModeVal),
                  backgroundColor: Colors.transparent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              );
            },
          ),
        ),
        show: true,
      ),
      // Status Button
      ButtonTouch(
        name: recordPaused.value ? 'Paused' : 'Recording',
        semanticsLabel: recordPaused.value
            ? 'Recording is paused'
            : 'Recording in progress',
        icon: Icons.circle,
        active: false,
        onPress: () => (),
        activeColor:
            MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
        inActiveColor: recordPaused.value == false
            ? MediasfuColors.danger
            : MediasfuColors.warning,
        show: true,
      ),
      // Settings Button
      ButtonTouch(
        name: !recordPaused.value ? 'Settings - Pause to enable' : 'Settings',
        semanticsLabel: recordPaused.value
            ? 'Open recording settings'
            : 'Pause recording to access settings',
        icon: Icons.settings,
        active: false,
        disabled: !recordPaused.value,
        onPress: () {
          if (!recordPaused.value) {
            showAlert(
              message: 'Please pause recording first to access settings',
              type: 'danger',
              duration: 3000,
            );
            return;
          }
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
        activeColor: MediasfuColors.success,
        inActiveColor: !recordPaused.value
            ? MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal)
                .withOpacity(0.4)
            : MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
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
              showAlert: showAlert,
              stopLaunchRecord: stopLaunchRecord.value,
              canLaunchRecord: canLaunchRecord.value,
              recordingAudioSupport: recordingAudioSupport.value,
              recordingVideoSupport: recordingVideoSupport.value,
              updateCanRecord: updateCanRecord,
              updateClearedToRecord: updateClearedToRecord,
              recordStarted: recordStarted.value,
              recordPaused: recordPaused.value,
              localUIMode: widget.options.useLocalUIMode == true,
            ),
          );
        },
        show: !showRecordButtons.value && islevel.value == '2',
      ),
      // Custom Record Buttons
      CustomButton(
        // You can define custom UI components directly in Flutter
        // In this case, you'll need to handle the custom UI rendering separately
        // You can replace this with a custom widget/component as needed
        customComponent: Container(
          decoration: BoxDecoration(
            color: isDarkMode.value
                ? Colors.black.withOpacity(0.35)
                : Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -4,
                right: 0,
                child: Text(
                  'Recording Controls',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode.value
                        ? Colors.white.withOpacity(0.6)
                        : Colors.black.withOpacity(0.5),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ControlButtonsAltComponent(
                  options: ControlButtonsAltComponentOptions(
                      buttons: recordButtons,
                      direction: 'horizontal',
                      showAspect: true,
                      location: 'bottom',
                      position: 'middle',
                      buttonBuilder: (context) {
                        // Rebuild the button content to exclude the text label
                        // but keep the icon and custom component logic
                        Widget buttonContent;

                        if (context.button.customComponent != null) {
                          buttonContent = context.button.customComponent!;
                        } else {
                          // Recreate the icon logic from ControlButtonsAltComponent
                          final bool isActive = context.button.active;
                          final Color activeColor =
                              context.button.activeColor ?? Colors.white;
                          final Color inActiveColor =
                              context.button.inActiveColor ?? Colors.grey;
                          final IconData? icon = isActive
                              ? (context.button.alternateIcon ??
                                  context.button.icon)
                              : context.button.icon;

                          buttonContent = Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 3),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? (context.button.pressedBackgroundColor ??
                                      Colors.grey)
                                  : (context.button.defaultBackgroundColor ??
                                      Colors.transparent),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Icon(
                              icon,
                              color: isActive ? activeColor : inActiveColor,
                              size: 24,
                            ),
                          );
                        }

                        return Tooltip(
                          message: context.button.name ?? '',
                          decoration: BoxDecoration(
                            color: isDarkMode.value
                                ? Colors.white
                                : Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: TextStyle(
                            color:
                                isDarkMode.value ? Colors.black : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          child: GestureDetector(
                            onTap: context.button.onPress,
                            child: buttonContent,
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
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
              isSettingsModalVisible: isSettingsModalVisible.value,
            ),
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
          launchDisplaySettings(
            LaunchDisplaySettingsOptions(
              updateIsDisplaySettingsModalVisible:
                  updateIsDisplaySettingsModalVisible,
              isDisplaySettingsModalVisible:
                  isDisplaySettingsModalVisible.value,
            ),
          );
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
      // Whiteboard Button
      CustomButton(
        icon: Icons.dashboard,
        text: 'Whiteboard',
        action: () {
          // Action for the Whiteboard button
          launchConfigureWhiteboard(
            LaunchConfigureWhiteboardOptions(
              updateIsConfigureWhiteboardModalVisible:
                  updateIsConfigureWhiteboardModalVisible,
              isConfigureWhiteboardModalVisible:
                  isConfigureWhiteboardModalVisible.value,
            ),
          );
        },
        show: islevel.value == '2',
      ),
      // Permissions Button
      CustomButton(
        icon: Icons.shield,
        text: 'Permissions',
        action: () {
          // Action for the Permissions button - use sidebar system
          updateActiveSidebarContent(SidebarContent.permissions,
              pushToStack: true);
        },
        show: islevel.value == '2',
      ),
      // Panelists Button
      CustomButton(
        icon: Icons.star,
        text: 'Panelists',
        action: () {
          // Action for the Panelists button - use sidebar system
          updateActiveSidebarContent(SidebarContent.panelists,
              pushToStack: true);
        },
        show: islevel.value == '2',
      ),
      // Translation Button
      CustomButton(
        icon: Icons.language,
        text: 'Translation',
        action: () {
          // Action for the Translation button - use sidebar system
          updateActiveSidebarContent(SidebarContent.translation,
              pushToStack: true);
        },
        show: translationSupported.value,
      ),
    ];
  }

  //Control Buttons Broadcast Events
  List<ButtonTouch> controlBroadcastButtons = [];

  // Initialize Control Buttons Broadcast Events

  void initializeControlBroadcastButtons(bool isDarkModeVal) {
    controlBroadcastButtons = [
      // Theme toggle button at top
      ButtonTouch(
        icon: Icons.light_mode,
        alternateIcon: Icons.dark_mode,
        active: isDarkModeVal,
        onPress: () => updateIsDarkMode(!isDarkMode.value),
        activeColor:
            MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
        inActiveColor:
            MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
        show: true,
        semanticsLabel:
            isDarkModeVal ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      ),

      // Users button
      ButtonTouch(
        icon: Icons.group_outlined,
        active: participantsActive,
        onPress: () => launchParticipants(
          LaunchParticipantsOptions(
            updateIsParticipantsModalVisible: updateIsParticipantsModalVisible,
            isParticipantsModalVisible: isParticipantsModalVisible.value,
          ),
        ),
        activeColor:
            MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
        inActiveColor:
            MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
        show: true,
        semanticsLabel: 'Participants',
      ),

      // Share button
      ButtonTouch(
        icon: Icons.share,
        alternateIcon: Icons.share,
        active: false,
        onPress: () =>
            updateIsShareEventModalVisible(!isShareEventModalVisible.value),
        activeColor:
            MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
        inActiveColor:
            MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
        show: true,
        semanticsLabel: 'Share',
      ),

      // Force Full Display button
      ButtonTouch(
        icon: forceFullDisplay.value ? Icons.compress : Icons.expand,
        active: forceFullDisplay.value,
        onPress: () => updateForceFullDisplay(!forceFullDisplay.value),
        activeColor:
            MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
        inActiveColor:
            MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
        show: islevel.value == '2' && videoActive,
        semanticsLabel:
            forceFullDisplay.value ? 'Exit Full Display' : 'Full Display',
      ),

      // Custom component - Messages with badge
      ButtonTouch(
        customComponent: Stack(
          children: [
            // Your icon - size 36 for better visibility on larger screens
            Icon(
              Icons.comment,
              size: 20,
              color:
                  MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
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
        onPress: () => launchMessages(
          LaunchMessagesOptions(
            updateIsMessagesModalVisible: updateIsMessagesModalVisible,
            isMessagesModalVisible: isMessagesModalVisible.value,
          ),
        ),
        show: true,
      ),

      // Switch camera button
      ButtonTouch(
        icon: Icons.sync,
        alternateIcon: Icons.sync,
        active: false,
        onPress: () => switchVideoAlt(
          SwitchVideoAltOptions(
            parameters: mediasfuParameters,
          ),
        ),
        activeColor:
            MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
        inActiveColor:
            MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
        show: islevel.value == '2',
        semanticsLabel: 'Switch Camera',
      ),
      // Video button
      ButtonTouch(
        icon: Icons.video_call,
        alternateIcon: Icons.video_call,
        active: videoActive,
        onPress: () => clickVideo(
          ClickVideoOptions(
            parameters: mediasfuParameters,
          ),
        ),
        activeColor: MediasfuColors.success,
        inActiveColor: MediasfuColors.danger,
        show: islevel.value == '2',
        semanticsLabel: videoActive ? 'Disable Video' : 'Enable Video',
      ),
      // Microphone button
      ButtonTouch(
        icon: Icons.mic,
        alternateIcon: Icons.mic,
        active: micActive,
        onPress: () => clickAudio(
          ClickAudioOptions(parameters: mediasfuParameters),
        ),
        activeColor: MediasfuColors.success,
        inActiveColor: MediasfuColors.danger,
        show: islevel.value == '2',
        semanticsLabel: micActive ? 'Mute Microphone' : 'Unmute Microphone',
      ),
      // End call button
      ButtonTouch(
        icon: Icons.call_end,
        active: endCallActive,
        onPress: () => launchConfirmExit(
          LaunchConfirmExitOptions(
            updateIsConfirmExitModalVisible: updateIsConfirmExitModalVisible,
            isConfirmExitModalVisible: isConfirmExitModalVisible.value,
          ),
        ),
        activeColor: MediasfuColors.success,
        inActiveColor: MediasfuColors.danger,
        show: true,
        semanticsLabel: 'Leave Meeting',
      ),
    ];
  }

  // Control Buttons Chat Events
  List<ButtonTouch> controlChatButtons = [];

  // Initialize Control Buttons Chat Events

  void initializeControlChatButtons(bool isDarkModeVal) {
    controlChatButtons = [
      // Share button
      ButtonTouch(
        icon: Icons.share,
        alternateIcon: Icons.share,
        active: false,
        onPress: () =>
            updateIsShareEventModalVisible(!isShareEventModalVisible.value),
        activeColor:
            MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
        inActiveColor:
            MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
        show: true,
      ),
      // Custom component - Messages with badge
      ButtonTouch(
        customComponent: Stack(
          children: [
            // Your icon - size 36 for better visibility on larger screens
            Icon(
              Icons.comment,
              size: 20,
              color:
                  MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
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
        onPress: () => launchMessages(
          LaunchMessagesOptions(
            updateIsMessagesModalVisible: updateIsMessagesModalVisible,
            isMessagesModalVisible: isMessagesModalVisible.value,
          ),
        ),
        show: true,
      ),

      // Switch camera button
      ButtonTouch(
        icon: Icons.sync,
        alternateIcon: Icons.sync,
        active: false,
        onPress: () => switchVideoAlt(
          SwitchVideoAltOptions(parameters: mediasfuParameters),
        ),
        activeColor:
            MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
        inActiveColor:
            MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
        show: true,
      ),
      // Video button
      ButtonTouch(
        icon: Icons.video_call,
        alternateIcon: Icons.video_call,
        active: videoActive,
        onPress: () => clickVideo(
          ClickVideoOptions(parameters: mediasfuParameters),
        ),
        activeColor: MediasfuColors.success,
        inActiveColor: MediasfuColors.danger,
        show: islevel.value == '2',
      ),
      // Microphone button
      ButtonTouch(
        icon: Icons.mic,
        alternateIcon: Icons.mic,
        active: micActive,
        onPress: () => clickAudio(
          ClickAudioOptions(parameters: mediasfuParameters),
        ),
        activeColor: MediasfuColors.success,
        inActiveColor: MediasfuColors.danger,
        show: true,
      ),
      ButtonTouch(
        icon: Icons.call_end,
        active: endCallActive,
        onPress: () => launchConfirmExit(
          LaunchConfirmExitOptions(
            updateIsConfirmExitModalVisible: updateIsConfirmExitModalVisible,
            isConfirmExitModalVisible: isConfirmExitModalVisible.value,
          ),
        ),
        activeColor: MediasfuColors.success,
        inActiveColor: MediasfuColors.danger,
        show: true,
      ),
    ];
  }

  // Control Buttons
  List<ControlButton> controlButtons = [];

  // Initialize Control Buttons
  // The control buttons are displayed in the control bar

  void initializeControlButtons(bool isDarkModeVal) {
    // On screens >= 576px width, show text labels with icons
    final showLabels = shouldShowButtonLabels;
    final textColor = MediasfuColors.themedText(darkMode: isDarkModeVal);

    controlButtons = [
      ControlButton(
        name: showLabels ? (micActive ? 'Mute' : 'Unmute') : null,
        semanticsLabel: micActive
            ? 'Mic is on, click to mute'
            : 'Mic is off, click to unmute',
        icon: Icons.mic_off_outlined,
        alternateIcon: Icons.mic_outlined,
        active: micActive,
        onPress: () =>
            clickAudio(ClickAudioOptions(parameters: mediasfuParameters)),
        activeColor: MediasfuColors.success,
        inActiveColor: MediasfuColors.danger,
        disabled: audioSwitching.value,
        color: textColor,
      ),
      ControlButton(
        name: showLabels ? (videoActive ? 'Stop Video' : 'Start Video') : null,
        semanticsLabel: videoActive
            ? 'Camera is on, click to turn off'
            : 'Camera is off, click to turn on',
        icon: Icons.videocam_off_outlined,
        alternateIcon: Icons.videocam_outlined,
        active: videoActive,
        onPress: () =>
            clickVideo(ClickVideoOptions(parameters: mediasfuParameters)),
        activeColor: MediasfuColors.success,
        inActiveColor: MediasfuColors.danger,
        disabled: videoSwitching.value,
        color: textColor,
      ),
      ControlButton(
        name: showLabels ? (screenShareActive ? 'Stop Share' : 'Share') : null,
        semanticsLabel: screenShareActive
            ? 'Screen sharing is on, click to stop'
            : 'Click to share your screen',
        icon: Icons.desktop_windows_outlined,
        alternateIcon: Icons.desktop_access_disabled,
        active: screenShareActive,
        onPress: () => clickScreenShare(ClickScreenShareOptions(
            parameters: mediasfuParameters, context: context)),
        activeColor: MediasfuColors.success,
        inActiveColor: MediasfuColors.danger,
        disabled: false,
        color: textColor,
      ),
      ControlButton(
        name: showLabels ? 'Leave' : null,
        semanticsLabel: 'Leave the meeting',
        icon: Icons.phone_outlined,
        active: endCallActive,
        onPress: () => launchConfirmExit(
          LaunchConfirmExitOptions(
            updateIsConfirmExitModalVisible: updateIsConfirmExitModalVisible,
            isConfirmExitModalVisible: isConfirmExitModalVisible.value,
          ),
        ),
        activeColor: MediasfuColors.success,
        inActiveColor: MediasfuColors.danger,
        disabled: false,
        color: textColor,
      ),
      ControlButton(
        name: showLabels ? 'People' : null,
        semanticsLabel: 'View participants',
        icon: Icons.group_outlined,
        active: participantsActive,
        onPress: () => launchParticipants(
          LaunchParticipantsOptions(
            updateIsParticipantsModalVisible: updateIsParticipantsModalVisible,
            isParticipantsModalVisible: isParticipantsModalVisible.value,
          ),
        ),
        activeColor:
            MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
        inActiveColor:
            MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
        disabled: false,
        color: textColor,
      ),
      ControlButton(
        semanticsLabel: 'Open menu',
        customComponent: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.menu,
                    size: 20,
                    color: MediasfuColors.themedIcon(darkMode: isDarkModeVal)),
                if (totalReqWait.value > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      child: Text(
                        totalReqWait.value.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            if (showLabels) ...[
              const SizedBox(width: 6),
              Text(
                'Menu',
                style: TextStyle(
                  color: MediasfuColors.themedText(darkMode: isDarkModeVal),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
        semanticsLabel: 'Open messages',
        customComponent: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 20,
                    color: MediasfuColors.themedIcon(darkMode: isDarkModeVal)),
                if (showMessagesBadge.value)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      child: const Text(
                        '*',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            if (showLabels) ...[
              const SizedBox(width: 6),
              Text(
                'Chat',
                style: TextStyle(
                  color: MediasfuColors.themedText(darkMode: isDarkModeVal),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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

    // Add additional buttons for large screens (desktop with sidebar)
    if (shouldUseSidebar) {
      // Recording button (for hosts/co-hosts)
      if (islevel.value == '2' ||
          (youAreCoHost.value &&
              coHostResponsibility.value
                  .any((r) => r.name == 'media' && r.value))) {
        if (recordStarted.value && !recordStopped.value) {
          controlButtons.add(
            ControlButton(
              customComponent: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          recordingProgressTime.value,
                          style: TextStyle(
                            color:
                                recordPaused.value ? Colors.yellow : Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            updateRecording(
                              UpdateRecordingOptions(
                                parameters: mediasfuParameters,
                              ),
                            );
                          },
                          child: Icon(
                            recordPaused.value ? Icons.play_arrow : Icons.pause,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            stopRecording(
                              StopRecordingOptions(
                                parameters: mediasfuParameters,
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.stop,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    if (showLabels)
                      const Text(
                        'Recording',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                  ],
                ),
              ),
              name: null,
              semanticsLabel: recordPaused.value
                  ? 'Resume recording'
                  : 'Pause/stop recording',
              onPress: () {
                updateActiveSidebarContent(SidebarContent.recording);
              },
              activeColor: MediasfuColors.danger,
              inActiveColor:
                  MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
              color: MediasfuColors.themedText(darkMode: isDarkModeVal),
            ),
          );
        } else {
          controlButtons.add(
            ControlButton(
              name: 'Record',
              semanticsLabel: 'Start recording',
              icon: Icons.fiber_manual_record_outlined,
              alternateIcon: Icons.fiber_manual_record,
              onPress: () {
                updateActiveSidebarContent(SidebarContent.recording);
              },
              activeColor: MediasfuColors.danger,
              inActiveColor:
                  MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
              color: MediasfuColors.themedText(darkMode: isDarkModeVal),
            ),
          );
        }
      }

      // Media Settings button
      controlButtons.add(
        ControlButton(
          name: 'Media',
          semanticsLabel: 'Media settings',
          icon: Icons.settings_input_component_outlined,
          onPress: () {
            updateActiveSidebarContent(SidebarContent.mediaSettings);
          },
          activeColor:
              MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
          inActiveColor:
              MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
          color: MediasfuColors.themedText(darkMode: isDarkModeVal),
        ),
      );

      // Display settings button
      controlButtons.add(
        ControlButton(
          name: 'Display',
          semanticsLabel: 'Display settings',
          icon: Icons.dashboard_customize_outlined,
          onPress: () {
            updateActiveSidebarContent(SidebarContent.displaySettings);
          },
          activeColor:
              MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
          inActiveColor:
              MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
          color: MediasfuColors.themedText(darkMode: isDarkModeVal),
        ),
      );

      // Requests button (for hosts/co-hosts with waiting room permissions)
      if (islevel.value == '2' ||
          (youAreCoHost.value &&
              coHostResponsibility.value
                  .any((r) => r.name == 'waiting' && r.value))) {
        controlButtons.add(
          ControlButton(
            name: 'Requests',
            semanticsLabel: 'View requests',
            customComponent: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.front_hand_outlined,
                        size: 16,
                        color:
                            MediasfuColors.themedIcon(darkMode: isDarkModeVal)),
                    if (requestCounter.value > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 3, vertical: 1),
                          child: Text(
                            requestCounter.value.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
                Text(
                  'Requests',
                  style: TextStyle(
                    color: MediasfuColors.themedText(darkMode: isDarkModeVal),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            onPress: () {
              updateActiveSidebarContent(SidebarContent.requests);
            },
            activeColor:
                MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
            inActiveColor:
                MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
          ),
        );
      }

      // Polls button (for hosts or when polls exist)
      if (islevel.value == '2' || polls.value.isNotEmpty) {
        controlButtons.add(
          ControlButton(
            name: 'Polls',
            semanticsLabel: 'View polls',
            icon: Icons.poll_outlined,
            onPress: () {
              updateActiveSidebarContent(SidebarContent.polls);
            },
            activeColor:
                MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
            inActiveColor:
                MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
            color: MediasfuColors.themedText(darkMode: isDarkModeVal),
          ),
        );
      }

      // Event Settings button (for hosts)
      if (islevel.value == '2') {
        controlButtons.add(
          ControlButton(
            name: 'Settings',
            semanticsLabel: 'Event settings',
            icon: Icons.tune_outlined,
            onPress: () {
              updateActiveSidebarContent(SidebarContent.eventSettings);
            },
            activeColor:
                MediasfuColors.controlButtonActive(darkMode: isDarkModeVal),
            inActiveColor:
                MediasfuColors.controlButtonInactive(darkMode: isDarkModeVal),
            color: MediasfuColors.themedText(darkMode: isDarkModeVal),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    isPortrait.removeListener(_handleOrientationChange);
    activeSidebarContent.removeListener(_handleSidebarVisibilityChange);

    // Safety net: clean up sockets if not already cleaned via closeAndReset
    try {
      if (socket.value != null) {
        socket.value!.clearListeners();
        socket.value!.disconnect();
        socket.value!.close();
        socket.value!.dispose();
      }
    } catch (_) {}
    try {
      if (localSocket.value != null) {
        localSocket.value!.clearListeners();
        localSocket.value!.disconnect();
        localSocket.value!.close();
        localSocket.value!.dispose();
      }
    } catch (_) {}
    try {
      for (final socketMap in consumeSockets.value) {
        final s = socketMap.values.first;
        s.clearListeners();
        s.disconnect();
        s.close();
        s.dispose();
      }
    } catch (_) {}

    super.dispose();
  }

  void _handleOrientationChange({bool immediate = false}) {
    try {
      final mediaQuery = MediaQuery.of(context);
      final safeAreaInsets = mediaQuery.padding;

      // Calculate available height after safe area is removed (since we're in SafeArea)
      final availableHeight =
          mediaQuery.size.height - safeAreaInsets.top - safeAreaInsets.bottom;

      // Account for sidebar width when calculating parent width
      final screenWidth = mediaQuery.size.width;
      final sidebarWidth = getSidebarWidth(screenWidth);
      final effectiveWidth = screenWidth - sidebarWidth;

      final parentWidth = effectiveWidth * mainHeightWidth;
      final showControls = (eventType.value == EventType.webinar) ||
          eventType.value == EventType.conference;
      final parentHeight = showControls
          ? availableHeight * 1.0 - controlHeight.value
          : availableHeight;
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
      if (immediate) {
        // Immediate update for responsive size changes
        updateComponentSizes(dimensions);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          updateComponentSizes(dimensions);
        });
      }

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
              imgSrc: widget.options.imgSrc ?? kDefaultMediaSFULogo,
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
              updateAudioPreference: updateUserDefaultAudioInputDevice,
              updateVideoPreference: updateUserDefaultVideoInputDevice,
              updateAudioOutputPreference: updateUserDefaultAudioOutputDevice,
              updateIsDarkMode: updateIsDarkMode,
              updateEventType: updateEventType,
              updateVirtualBackground: updateSelectedBackground,
              updateKeepBackground: (bool value) =>
                  keepBackground.value = value,
              updateAppliedBackground: (bool value) =>
                  appliedBackground.value = value,
              updateCurrentFacingMode: updateCurrentFacingMode,
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
                  optimizeVideoRecord: widget.options.optimizeVideoRecord,
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
        socket!.clearListeners();
        socket.disconnect();
        socket.close();
        socket.dispose();
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
        // Disable screen wake lock when leaving the meeting
        await ScreenWakeLock.disable();
      } catch (e) {}

      try {
        updateIsLoadingModalVisible(true);

        // Close sidebar if visible (Modern UI)
        closeSidebar();

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
        // Close whiteboard/screenboard modals
        updateIsWhiteboardModalVisible(false);
        updateIsConfigureWhiteboardModalVisible(false);
        updateIsScreenboardModalVisible(false);
        updateIsMeetingActive(false);
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

      // Stop and clean up additional streams
      try {
        if (localStreamVideo.value != null) {
          for (var track in localStreamVideo.value!.getTracks()) {
            track.stop();
          }
        }
        if (localStreamAudio.value != null) {
          for (var track in localStreamAudio.value!.getTracks()) {
            track.stop();
          }
        }
        if (localStreamScreen.value != null) {
          for (var track in localStreamScreen.value!.getTracks()) {
            track.stop();
          }
        }
      } catch (e) {}

      // Close all consumer transports
      try {
        for (var transport in consumerTransports.value) {
          try {
            transport.consumerTransport.close();
          } catch (e) {}
        }
        updateConsumerTransports([]);
        updateConsumingTransports([]);
      } catch (e) {}

      // Close producer transport
      try {
        producerTransport.value?.close();
        updateProducerTransport(null);
        localProducerTransport?.value?.close();
        updateLocalProducerTransport(null);
      } catch (e) {}

      // Reset producers
      try {
        videoProducer.value?.close();
        updateVideoProducer(null);
        audioProducer.value?.close();
        updateAudioProducer(null);
        screenProducer.value?.close();
        updateScreenProducer(null);
      } catch (e) {}

      try {
        await disconnectAllSockets(consumeSockets.value);
        updateConsumeSockets([]);
        updateRoomRecvIPs([]);
      } catch (e) {}

      // Disconnect and reset main socket and localSocket
      try {
        if (socket.value != null) {
          socket.value!.clearListeners();
          socket.value!.disconnect();
          socket.value!.close();
          socket.value!.dispose();
          updateSocket(null);
        }
      } catch (e) {}

      try {
        if (localSocket.value != null) {
          localSocket.value!.clearListeners();
          localSocket.value!.disconnect();
          localSocket.value!.close();
          localSocket.value!.dispose();
          updateLocalSocket(null);
        }
      } catch (e) {}

      // Reset translation states (not in initialValuesState)
      try {
        if (mounted) {
          setState(() {
            mySpokenLanguage = 'en';
            mySpokenLanguageEnabled = false;
            myDefaultOutputLanguage = null;
            listenerTranslationPreferences =
                ListenerTranslationPreferences(perSpeaker: {});
            translationProducerMap = {};
            speakerTranslationStates = {};
            listenerTranslationOverrides = {};
            availableTranslationChannels = {};
            transcripts = [];
            activeTranslationProducerIds = {};
            translationSubscriptions = {};
            translationConfig = null;
          });
        }
        translationSupported.value = false;
      } catch (e) {}

      // Reset sidebar navigation stack
      try {
        sidebarNavigationStack.value = [];
        activeSidebarContent.value = SidebarContent.none;
      } catch (e) {}

      // Reset main states through initialValues
      updateStatesToInitialValues(mediasfuParameters, initialValues);

      // Explicitly reset additional states not covered by initialValues
      updateMeetingProgressTime('00:00:00');
      updateMeetingElapsedTime(0);
      updateRecordingProgressTime('00:00:00');
      updateRecordElapsedTime(0);
      updateShowRecordButtons(false);

      // Reset grid-related states
      mainGridStream.value = [];
      otherGridStreams = [[], []];
      audioOnlyStreams.value = [];
      translationStreams.value = [];

      // Reset transport creation flags
      updateTransportCreated(false);
      updateLocalTransportCreated(false);
      updateTransportCreatedVideo(false);
      updateTransportCreatedAudio(false);
      updateTransportCreatedScreen(false);

      // Reset device
      updateDevice(null);
      updateRtpCapabilities(null);

      // Show loading overlay during cleanup transition
      updateIsLoadingModalVisible(true);

      // Delay before updating validated
      await Future.delayed(const Duration(milliseconds: 1000));
      updateValidated(false);
      updateIsLoadingModalVisible(false);
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

          // Translation events
          socketDefault.on('translation:roomConfig', (data) async {
            try {
              final configData = TranslationRoomConfigData.fromMap(
                  Map<String, dynamic>.from(data));
              await translationRoomConfig(TranslationRoomConfigOptions(
                data: configData,
                updateTranslationConfig: updateTranslationConfig,
                updateTranslationSupported: updateTranslationSupported,
              ));

              // If room doesn't support translation but user has personal translation eligibility,
              // automatically request personal translation from the server
              if (configData.config.supportTranslation != true &&
                  widget.options.canUsePersonalTranslation &&
                  widget.options.personalTranslationUsername != null &&
                  widget.options.personalTranslationUsername!.isNotEmpty) {
                socketDefault.emitWithAck('requestPersonalTranslation', {
                  'roomName': roomName.value,
                  'username': widget.options.personalTranslationUsername,
                }, ack: (response) {
                  if (response != null && response['success'] == true) {
                    // Request accepted
                  } else {
                    // Request denied
                  }
                });
              }
            } catch (_) {}
          });

          // Listen for personal translation config (per-joiner translation)
          socketDefault.on('personalTranslationConfig', (data) async {
            try {
              final configMap = Map<String, dynamic>.from(data);
              if (configMap['supportTranslation'] == true &&
                  configMap['translationConfig'] != null) {
                final personalConfig = TranslationRoomConfig.fromMap(
                    Map<String, dynamic>.from(configMap['translationConfig']));
                updateTranslationConfig(personalConfig);
                isPersonalTranslation.value =
                    configMap['isPersonalTranslation'] == true;
                showAlert(
                  message:
                      'Personal translation activated with your account credits',
                  type: 'success',
                  duration: 3000,
                );
              }
            } catch (_) {}
          });

          socketDefault.on('translation:configUpdated', (data) async {
            try {
              final configData = TranslationConfigUpdatedData.fromMap(
                  Map<String, dynamic>.from(data));
              await translationConfigUpdated(TranslationConfigUpdatedOptions(
                data: configData,
                updateTranslationConfig: updateTranslationConfig,
                showAlert: showAlert,
              ));
            } catch (_) {}
          });

          socketDefault.on('translation:languageSet', (data) async {
            try {
              final langData = TranslationLanguageSetData.fromMap(
                  Map<String, dynamic>.from(data));
              await translationLanguageSet(TranslationLanguageSetOptions(
                data: langData,
                updateMySpokenLanguage: updateMySpokenLanguage,
                updateMySpokenLanguageEnabled: updateMySpokenLanguageEnabled,
                showAlert: showAlert,
              ));
            } catch (_) {}
          });

          socketDefault.on('translation:memberState', (data) async {
            try {
              final stateData = TranslationMemberStateData.fromMap(
                  Map<String, dynamic>.from(data));
              await translationMemberState(TranslationMemberStateOptions(
                data: stateData,
              ));
            } catch (_) {}
          });

          socketDefault.on('translation:error', (data) async {
            try {
              final errorData =
                  TranslationErrorData.fromMap(Map<String, dynamic>.from(data));
              await translationError(TranslationErrorOptions(
                data: errorData,
                showAlert: showAlert,
              ));
            } catch (_) {}
          });

          socketDefault.on('translation:speakerDisabled', (data) async {
            try {
              final speakerId = data['speakerId'] as String?;
              if (speakerId == null) return;

              // Find the original producer for this speaker from translation state
              final speakerState = speakerTranslationStates[speakerId];
              final originalProducerId =
                  speakerState?['originalProducerId'] as String?;

              // Resume original audio
              if (originalProducerId != null) {
                await resumeOriginalProducer(originalProducerId, speakerId);

                // Clean up any translation producers for this speaker's original producer
                final meta = translationProducerMap[originalProducerId];
                if (meta != null) {
                  activeTranslationProducerIds.remove(meta.speakerId);
                }
              }

              // Clean up speaker translation state
              if (mounted) {
                setState(() {
                  speakerTranslationStates.remove(speakerId);
                  if (originalProducerId != null) {
                    translationProducerMap.remove(originalProducerId);
                  }
                });
              }
            } catch (_) {}
          });

          socketDefault.on('translation:subscribed', (data) async {
            final options = TranslationSubscribedOptions(
              data: TranslationSubscribedData.fromMap(
                  Map<String, dynamic>.from(data)),
              updateListenPreferences: updateListenPreferencesWrapper,
              startConsumingTranslation: startConsumingTranslation,
              showAlert: showAlert,
            );
            await translationSubscribed(options);

            // Manual update of translationProducerMap
            final subData = options.data;
            if (subData.producerId != null &&
                subData.originalProducerId != null) {
              if (mounted) {
                setState(() {
                  translationProducerMap[subData.producerId!] = TranslationMeta(
                    speakerId: subData.speakerId,
                    language: subData.language,
                    originalProducerId: subData.originalProducerId!,
                  );
                });
              }
            }
          });

          socketDefault.on('translation:unsubscribed', (data) async {
            await translationUnsubscribed(
              TranslationUnsubscribedOptions(
                data: TranslationUnsubscribedData.fromMap(
                    Map<String, dynamic>.from(data)),
                updateListenPreferences: updateListenPreferencesWrapper,
                stopConsumingTranslation: stopConsumingTranslation,
              ),
            );
          });

          socketDefault.on('translation:producerReady', (data) async {
            final options = TranslationProducerReadyOptions(
              data: TranslationProducerReadyData.fromMap(
                  Map<String, dynamic>.from(data)),
              showAlert: showAlert,
            );
            await translationProducerReady(options);

            // Manual update
            final readyData = options.data;
            if (mounted) {
              setState(() {
                translationProducerMap[readyData.producerId] = TranslationMeta(
                  speakerId: readyData.speakerId,
                  language: readyData.language,
                  originalProducerId: readyData.originalProducerId,
                );
              });
            }
          });

          socketDefault.on('translation:producerClosed', (data) async {
            final options = TranslationProducerClosedOptions(
              data: TranslationProducerClosedData.fromMap(
                  Map<String, dynamic>.from(data)),
              stopConsumingTranslation: stopConsumingTranslationById,
              showAlert: showAlert,
            );
            await translationProducerClosed(options);

            // Manual update
            final closedData = options.data;
            if (mounted) {
              // Resume original producer if we have it
              final meta = translationProducerMap[closedData.producerId];
              if (meta != null) {
                await resumeOriginalProducer(
                    meta.originalProducerId, meta.speakerId);
              }

              setState(() {
                translationProducerMap.remove(closedData.producerId);
              });
            }
          });

          socketDefault.on('translation:channelsAvailable', (data) async {
            await translationChannelsAvailable(
              TranslationChannelsAvailableOptions(
                data: TranslationChannelsAvailableData.fromMap(
                    Map<String, dynamic>.from(data)),
                updateAvailableTranslationChannels:
                    updateAvailableTranslationChannels,
              ),
            );
          });

          socketDefault.on('translation:speakerOutputChanged', (data) async {
            await translationSpeakerOutputChanged(
              TranslationSpeakerOutputChangedOptions(
                data: TranslationSpeakerOutputChangedData.fromMap(
                    Map<String, dynamic>.from(data)),
                updateSpeakerTranslationState: updateSpeakerTranslationState,
                pauseOriginalProducer: pauseOriginalProducer,
                resumeOriginalProducer: resumeOriginalProducer,
                stopConsumingTranslationForSpeaker:
                    stopConsumingTranslationForSpeaker,
                showAlert: showAlert,
              ),
            );
          });

          socketDefault.on('translation:transcript', (data) async {
            final transcriptData = TranslationTranscriptData.fromMap(
                Map<String, dynamic>.from(data));
            await translationTranscript(
              TranslationTranscriptOptions(
                data: transcriptData,
                updateTranscripts: updateTranscriptsWrapper,
              ),
            );

            // One-time forced re-render per speaker: when the first transcript
            // arrives it confirms the translation pipeline is active. Force a
            // re-notification of translationStreams to ensure the audio widget
            // is properly mounted and playing.
            if (transcriptData.speakerId.isNotEmpty &&
                !translationFirstRenderForced
                    .contains(transcriptData.speakerId)) {
              translationFirstRenderForced.add(transcriptData.speakerId);
              // Force ValueNotifier to re-notify listeners (new list reference)
              translationStreams.value =
                  List<Widget>.from(translationStreams.value);
            }

            // Update live subtitles if enabled
            if (showSubtitlesOnCards.value) {
              final subtitle = LiveSubtitle.create(
                text: transcriptData.translatedText.isNotEmpty
                    ? transcriptData.translatedText
                    : transcriptData.originalText,
                language: transcriptData.language,
                speakerId: transcriptData.speakerId,
                speakerName: transcriptData.speakerName,
              );
              // Store by BOTH speakerId AND speakerName to ensure matching
              updateLiveSubtitleForSpeaker(transcriptData.speakerId, subtitle);
              if (transcriptData.speakerName.isNotEmpty &&
                  transcriptData.speakerName != transcriptData.speakerId) {
                updateLiveSubtitleForSpeaker(
                    transcriptData.speakerName, subtitle);
              }

              // Schedule cleanup of expired subtitles
              Future.delayed(
                  Duration(
                      milliseconds: subtitle.expiresAt
                              .difference(DateTime.now())
                              .inMilliseconds +
                          100), () {
                cleanupExpiredSubtitles();
              });
            }
          });

          socketDefault.on('translation:listenerPreferencesUpdated',
              (data) async {
            if (data != null) {
              updateListenerTranslationPreferences(
                  ListenerTranslationPreferences.fromMap(data));
            }
          });

          socketDefault.on('allMembers', (membersData) async {
            try {
              // Handle 'allMembers' event
              AllMembersData response = AllMembersData.fromJson(membersData);
              if (membersData != null) {
                // IMMEDIATELY update speakerTranslationStates before consumers are created
                // This allows connectRecvTransport to check this state when creating audio consumers
                for (final participant in response.members) {
                  // Skip self
                  if (participant.name == member.value) continue;

                  // Check if this participant has translation enabled with an output language
                  final translationEnabled = participant['translationEnabled'];
                  final translationDefaultOutputLanguage =
                      participant['translationDefaultOutputLanguage'];
                  final translationOriginalProducerId =
                      participant['translationOriginalProducerId'];
                  final translationInputLanguage =
                      participant['translationInputLanguage'];

                  if (translationEnabled == true &&
                      translationDefaultOutputLanguage != null &&
                      translationOriginalProducerId != null) {
                    if (mounted) {
                      setState(() {
                        speakerTranslationStates[participant.name] = {
                          'speakerId': participant.name,
                          'speakerName': participant.name,
                          'inputLanguage': translationInputLanguage ?? 'en',
                          'outputLanguage': translationDefaultOutputLanguage,
                          'originalProducerId': translationOriginalProducerId,
                          'enabled': true,
                        };
                      });
                    }
                  }
                }

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

                // Fallback: After a delay to ensure consumers are set up,
                // pause original audio for speakers with active translations
                Future.delayed(const Duration(seconds: 2), () async {
                  try {
                    for (final participant in response.members) {
                      if (participant.name == member.value) continue;

                      final translationEnabled =
                          participant['translationEnabled'];
                      final translationDefaultOutputLanguage =
                          participant['translationDefaultOutputLanguage'];
                      final translationOriginalProducerId =
                          participant['translationOriginalProducerId'];

                      if (translationEnabled == true &&
                          translationDefaultOutputLanguage != null &&
                          translationOriginalProducerId != null) {
                        await pauseOriginalProducer(
                          translationOriginalProducerId as String,
                          participant.name,
                        );
                      }
                    }
                  } catch (_) {}
                });
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
            if (_suppressConfirmHere) return;
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

          // Permissions socket listeners
          socketDefault.on('permissionUpdated', (data) async {
            try {
              PermissionUpdatedData permissionData =
                  PermissionUpdatedData.fromMap(data);

              await permissionUpdated(PermissionUpdatedOptions(
                data: permissionData,
                showAlert: showAlert,
                updateIslevel: updateIslevel,
              ));
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling permissionUpdated event: $error');
              }
            }
          });

          socketDefault.on('permissionConfigUpdated', (data) async {
            try {
              PermissionConfigUpdatedData configData =
                  PermissionConfigUpdatedData.fromMap(data);

              await permissionConfigUpdated(PermissionConfigUpdatedOptions(
                data: configData,
                updatePermissionConfig: updatePermissionConfig,
              ));
            } catch (error) {
              if (kDebugMode) {
                //print('Error handling permissionConfigUpdated event: $error');
              }
            }
          });

          // Panelists socket listeners
          socketDefault.on('panelistsUpdated', (data) async {
            try {
              PanelistsUpdatedData panelistsData =
                  PanelistsUpdatedData.fromMap(data);

              await panelistsUpdated(PanelistsUpdatedOptions(
                data: panelistsData,
                updatePanelists: updatePanelists,
              ));
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling panelistsUpdated event: $error');
              }
            }
          });

          socketDefault.on('panelistFocusChanged', (data) async {
            try {
              PanelistFocusChangedData focusData =
                  PanelistFocusChangedData.fromMap(data);

              // Capture current values before update for comparison
              final currentFocused = panelistsFocused.value;
              final currentPanelistList =
                  List<Participant>.from(panelists.value);

              await panelistFocusChanged(PanelistFocusChangedOptions(
                data: focusData,
                updatePanelistsFocused: updatePanelistsFocused,
                updateMuteOthersMic: updateMuteOthersMic,
                updateMuteOthersCamera: updateMuteOthersCamera,
                updatePanelists: updatePanelists,
                // Pass current values for comparison
                currentPanelistsFocused: currentFocused,
                currentPanelists: currentPanelistList,
                // Trigger screen rerender if focus/panelists changed
                onScreenChanges: () async {
                  await onScreenChanges(OnScreenChangesOptions(
                    changed: true,
                    parameters: mediasfuParameters,
                  ));
                },
              ));
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling panelistFocusChanged event: $error');
              }
            }
          });

          socketDefault.on('controlMedia', (data) async {
            try {
              ControlMediaData controlData = ControlMediaData.fromMap(data);

              await controlMedia(ControlMediaOptions(
                data: controlData,
                showAlert: showAlert,
                clickAudio: () => clickAudio(
                    ClickAudioOptions(parameters: mediasfuParameters)),
                clickVideo: () => clickVideo(
                    ClickVideoOptions(parameters: mediasfuParameters)),
                audioAlreadyOn: audioAlreadyOn.value,
                videoAlreadyOn: videoAlreadyOn.value,
              ));
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling controlMedia event: $error');
              }
            }
          });

          socketDefault.on('addedAsPanelist', (data) async {
            try {
              AddedAsPanelistData panelistData =
                  AddedAsPanelistData.fromMap(data);

              await addedAsPanelist(AddedAsPanelistOptions(
                data: panelistData,
                showAlert: showAlert,
              ));
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling addedAsPanelist event: $error');
              }
            }
          });

          socketDefault.on('removedFromPanelists', (data) async {
            try {
              RemovedFromPanelistsData removedData =
                  RemovedFromPanelistsData.fromMap(data);

              await removedFromPanelists(RemovedFromPanelistsOptions(
                data: removedData,
                showAlert: showAlert,
              ));
            } catch (error) {
              if (kDebugMode) {
                // print('Error handling removedFromPanelists event: $error');
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
          await Future.delayed(const Duration(milliseconds: 1500));
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
            _prepopulateUserMediaHandler(
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
            Future.delayed(const Duration(milliseconds: 500));
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
    _hydrateUiOverrides();
    mediasfuParameters = MediasfuParameters(
        updateMiniCardsGrid: updateMiniCardsGrid,
        mixStreams: mixStreams,
        dispStreams: dispStreams,
        stopShareScreen: stopShareScreen,
        checkScreenShare: checkScreenShare,
        startShareScreen: startShareScreen,
        requestScreenShare: requestScreenShare,
        reorderStreams: reorderStreams,
        prepopulateUserMedia: _prepopulateUserMediaHandler,
        getVideos: getVideos,
        rePort: rePort,
        trigger: trigger,
        consumerResume: _consumerResumeHandler,
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
        addVideosGrid: _addVideosGridHandler,
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
        getMediaDevicesList: getMediaDevicesList,
        getParticipantMedia: getParticipantMedia,
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
        uiOverrides: _uiOverrides,
        containerStyle: _containerStyle,

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
        isSpeakerphoneOn: isSpeakerphoneOn.value,
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
        permissionConfig: permissionConfig.value,
        panelists: panelists.value,
        panelistFocusChanged: panelistFocusChangedValue.value,
        panellistFocused: panelistsFocused.value,
        muteOthersMic: muteOthersMic.value,
        muteOthersCamera: muteOthersCamera.value,
        autoWave: autoWave.value,
        forceFullDisplay: forceFullDisplay.value,
        prevForceFullDisplay: prevForceFullDisplay.value,
        selfViewForceFull: selfViewForceFull.value,
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
        updateIsSpeakerphoneOn: updateIsSpeakerphoneOn,
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
        updatePermissionConfig: updatePermissionConfig,
        updatePanelists: updatePanelists,
        updatePanelistFocusChanged: updatePanelistFocusChanged,
        updatePanelistsFocused: updatePanelistsFocused,
        updateMuteOthersMic: updateMuteOthersMic,
        updateMuteOthersCamera: updateMuteOthersCamera,

        // Display settings
        updateAutoWave: updateAutoWave,
        updateForceFullDisplay: updateForceFullDisplay,
        updatePrevForceFullDisplay: updatePrevForceFullDisplay,
        updateSelfViewForceFull: updateSelfViewForceFull,
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
        selectedBackground: selectedBackground.value,
        onBackgroundApply: handleBackgroundApply,

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
        updateSelectedBackground: updateSelectedBackground,

        // Theme support
        isDarkModeValue: isDarkMode.value,
        updateIsDarkModeValue: (val) => isDarkMode.value = val,

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

        // Custom builders
        customVideoCard: widget.options.customVideoCard,
        customAudioCard: widget.options.customAudioCard,
        customMiniCard: widget.options.customMiniCard,
        miniAudioPlayerComponent: _miniAudioPlayerHandler,

        // Custom builder update functions
        updateCustomVideoCard: updateCustomVideoCard,
        updateCustomAudioCard: updateCustomAudioCard,
        updateCustomMiniCard: updateCustomMiniCard,
        // Translation
        listenerTranslationPreferences: listenerTranslationPreferences,
        listenerTranslationOverrides: listenerTranslationOverrides,
        translationProducerMap: translationProducerMap,
        speakerTranslationStates: speakerTranslationStates,
        activeTranslationProducerIds: activeTranslationProducerIds,
        translationSubscriptions: translationSubscriptions,
        addTranslationStream: addTranslationStream,
        removeTranslationStream: removeTranslationStream,
        updateListenerTranslationPreferences:
            updateListenerTranslationPreferences,
        updateListenerTranslationOverrides: updateListenerTranslationOverrides,
        updateTranslationProducerMap: updateTranslationProducerMap,
        updateSpeakerTranslationStates: updateSpeakerTranslationStates,

        // Live subtitles
        showSubtitlesOnCards: showSubtitlesOnCards.value,
        showSubtitlesOnCardsNotifier: showSubtitlesOnCards,
        liveSubtitles: liveSubtitles,
        updateShowSubtitlesOnCards: updateShowSubtitlesOnCards,
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
        updateEventType(widget.options.seedData!.eventType!);
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
    // Listen for sidebar visibility changes to recalculate dimensions
    activeSidebarContent.addListener(_handleSidebarVisibilityChange);
  }

  /// Handle sidebar visibility changes - recalculate dimensions when sidebar opens/closes
  void _handleSidebarVisibilityChange() {
    // Trigger dimension recalculation when sidebar visibility changes
    _handleOrientationChange();
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
    // Get safe area padding for manual handling
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Makes status bar transparent
        statusBarIconBrightness:
            Brightness.light, // Sets status bar icons to light color
        statusBarBrightness:
            Brightness.dark, // iOS: dark background means light icons
      ),
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          // Check if the device is in landscape mode
          isPortrait.value = orientation == Orientation.portrait;
          return Scaffold(
            body: Column(
              children: [
                // Status bar / notch background overlay (all platforms)
                if (topPadding > 0)
                  Container(
                    height: topPadding,
                    color: Colors.black
                        .withOpacity(0.5), // Semi-transparent dark background
                  ),
                // Main content - takes remaining space
                Expanded(
                  child: _buildRoomInterface(),
                ),
              ],
            ),
            resizeToAvoidBottomInset: false,
          );
        },
      ),
    );
  }

  Widget buildEventRoom(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, isDarkModeVal, _) {
        // Initialize buttons inside the builder so they can use isDarkModeVal
        initializeRecordButton();
        initializeRecordButtons(isDarkModeVal);
        initializeControlButtons(isDarkModeVal);
        initializeControlChatButtons(isDarkModeVal);
        initializeControlBroadcastButtons(isDarkModeVal);

        return Theme(
          data: isDarkModeVal ? MediasfuTheme.dark() : MediasfuTheme.light(),
          child:
              validated &&
                      widget.options.returnUI != null &&
                      widget.options.returnUI == true
                  ? _mainContainerBuilder(
                      context,
                      MainContainerComponentOptions(
                        backgroundColor: _containerStyle.backgroundColor ??
                            MediasfuColors.themedSurface(
                                darkMode: isDarkModeVal),
                        containerWidthFraction:
                            _containerStyle.widthFraction ?? 1.0,
                        containerHeightFraction:
                            _containerStyle.heightFraction ?? 1.0,
                        margin: _containerStyle.margin,
                        padding: _containerStyle.padding,
                        decoration: _containerStyle.decoration,
                        alignment: _containerStyle.alignment,
                        clipBehavior: _containerStyle.clipBehavior,
                        children: [
                          _mainAspectBuilder(
                            context,
                            MainAspectComponentOptions(
                              backgroundColor: MediasfuColors.themedSurface(
                                  darkMode: isDarkModeVal),
                              updateIsWideScreen: updateIsWideScreen,
                              updateIsMediumScreen: updateIsMediumScreen,
                              updateIsSmallScreen: updateIsSmallScreen,
                              defaultFraction: 1 - controlHeight.value,
                              showControls:
                                  eventType.value == EventType.webinar ||
                                      eventType.value == EventType.conference,
                              children: [
                                // Listen to sidebar changes to recalculate containerWidthFraction
                                ValueListenableBuilder<SidebarContent>(
                                  valueListenable: activeSidebarContent,
                                  builder: (context, sidebarContent, _) {
                                    final isSidebarVisible =
                                        sidebarContent != SidebarContent.none;
                                    final screenWidth =
                                        MediaQuery.of(context).size.width;
                                    final sidebarWidth =
                                        getSidebarWidth(screenWidth);

                                    return Row(
                                      children: [
                                        // Main content area
                                        Expanded(
                                          child:
                                              ValueListenableBuilder<
                                                      ComponentSizes>(
                                                  valueListenable:
                                                      componentSizes,
                                                  builder: (context,
                                                      componentSizes, child) {
                                                    // Calculate containerWidthFraction to account for sidebar
                                                    final containerWidthFraction =
                                                        sidebarWidth > 0
                                                            ? (screenWidth -
                                                                    sidebarWidth) /
                                                                screenWidth
                                                            : 1.0;

                                                    return _mainScreenBuilder(
                                                      context,
                                                      MainScreenComponentOptions(
                                                        doStack: true,
                                                        mainSize:
                                                            mainHeightWidth,
                                                        updateComponentSizes:
                                                            updateComponentSizes,
                                                        containerWidthFraction:
                                                            containerWidthFraction,
                                                        defaultFraction: 1 -
                                                            controlHeight.value,
                                                        showControls: eventType
                                                                    .value ==
                                                                EventType
                                                                    .webinar ||
                                                            eventType.value ==
                                                                EventType
                                                                    .conference,
                                                        children: [
                                                          ValueListenableBuilder<
                                                              GridSizes>(
                                                            valueListenable:
                                                                gridSizes,
                                                            builder: (context,
                                                                gridSizes,
                                                                child) {
                                                              // Wrap in ValueListenableBuilder for meetingProgressTime to ensure timer updates
                                                              return ValueListenableBuilder<
                                                                  String>(
                                                                valueListenable:
                                                                    meetingProgressTime,
                                                                builder: (context,
                                                                    progressTime,
                                                                    _) {
                                                                  return _mainGridBuilder(
                                                                    context,
                                                                    MainGridComponentOptions(
                                                                      height: componentSizes
                                                                          .mainHeight,
                                                                      width: componentSizes
                                                                          .mainWidth,
                                                                      backgroundColor:
                                                                          MediasfuColors.themedSurface(
                                                                              darkMode: isDarkModeVal),
                                                                      mainSize:
                                                                          mainHeightWidth,
                                                                      showAspect:
                                                                          mainHeightWidth >
                                                                              0,
                                                                      timeBackgroundColor: recordState ==
                                                                              'green'
                                                                          ? Colors
                                                                              .green
                                                                          : recordState == 'yellow'
                                                                              ? Colors.yellow
                                                                              : Colors.red,
                                                                      meetingProgressTime:
                                                                          progressTime,
                                                                      showTimer:
                                                                          false,
                                                                      children: [
                                                                        ValueListenableBuilder<
                                                                            bool>(
                                                                          valueListenable:
                                                                              whiteboardStarted,
                                                                          builder: (context,
                                                                              wbStarted,
                                                                              _) {
                                                                            return ValueListenableBuilder<bool>(
                                                                              valueListenable: whiteboardEnded,
                                                                              builder: (context, wbEnded, _) {
                                                                                return _flexibleVideoBuilder(
                                                                                    context,
                                                                                    FlexibleVideoOptions(
                                                                                      backgroundColor: MediasfuColors.themedSurface(darkMode: isDarkModeVal),
                                                                                      customWidth: componentSizes.mainWidth,
                                                                                      customHeight: componentSizes.mainHeight,
                                                                                      rows: 1,
                                                                                      columns: 1,
                                                                                      componentsToRender: mainGridStream.value,
                                                                                      showAspect: mainGridStream.value.isNotEmpty && !(wbStarted && !wbEnded),
                                                                                      localStreamScreen: localStreamScreen.value,
                                                                                      annotateScreenStream: annotateScreenStream.value,
                                                                                      // Pass Screenboard as prop when shared
                                                                                      // Wrap in ValueListenableBuilder to rebuild when annotateScreenStream changes
                                                                                      screenboard: shared.value
                                                                                          ? ValueListenableBuilder<bool>(
                                                                                              valueListenable: annotateScreenStream,
                                                                                              builder: (context, annotateValue, _) {
                                                                                                return _screenboardBuilder(
                                                                                                  context,
                                                                                                  ScreenboardOptions(
                                                                                                    customWidth: componentSizes.mainWidth,
                                                                                                    customHeight: componentSizes.mainHeight,
                                                                                                    parameters: mediasfuParameters,
                                                                                                    showAspect: shared.value,
                                                                                                  ),
                                                                                                );
                                                                                              },
                                                                                            )
                                                                                          : null,
                                                                                    ));
                                                                              },
                                                                            );
                                                                          },
                                                                        ),
                                                                        // Whiteboard component - conditionally rendered
                                                                        ValueListenableBuilder<
                                                                            bool>(
                                                                          valueListenable:
                                                                              whiteboardStarted,
                                                                          builder: (context,
                                                                              wbStarted,
                                                                              _) {
                                                                            return ValueListenableBuilder<bool>(
                                                                              valueListenable: whiteboardEnded,
                                                                              builder: (context, wbEnded, _) {
                                                                                return _whiteboardBuilder(
                                                                                  context,
                                                                                  WhiteboardOptions(
                                                                                    customWidth: componentSizes.mainWidth,
                                                                                    customHeight: componentSizes.mainHeight,
                                                                                    parameters: mediasfuParameters,
                                                                                    showAspect: wbStarted && !wbEnded,
                                                                                  ),
                                                                                );
                                                                              },
                                                                            );
                                                                          },
                                                                        ),
                                                                        _controlButtonsTouchBuilder(
                                                                            context,
                                                                            ControlButtonsComponentTouchOptions(
                                                                              buttons: controlBroadcastButtons,
                                                                              direction: 'vertical',
                                                                              showAspect: eventType.value == EventType.broadcast,
                                                                              location: 'bottom',
                                                                              position: 'right',
                                                                            )),
                                                                        _controlButtonsTouchBuilder(
                                                                            context,
                                                                            ControlButtonsComponentTouchOptions(
                                                                              buttons: recordButton,
                                                                              direction: 'horizontal',
                                                                              showAspect: eventType.value == EventType.broadcast && !showRecordButtons.value && islevel.value == '2',
                                                                              location: 'bottom',
                                                                              position: 'middle',
                                                                            )),
                                                                        if (eventType.value ==
                                                                                EventType.broadcast &&
                                                                            showRecordButtons.value &&
                                                                            islevel.value == '2')
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.bottomCenter,
                                                                            child:
                                                                                Container(
                                                                              margin: const EdgeInsets.only(bottom: 10),
                                                                              decoration: BoxDecoration(
                                                                                color: isDarkMode.value ? Colors.black.withOpacity(0.35) : Colors.white.withOpacity(0.35),
                                                                                borderRadius: BorderRadius.circular(12),
                                                                              ),
                                                                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                                                              child: Stack(
                                                                                clipBehavior: Clip.none,
                                                                                children: [
                                                                                  Positioned(
                                                                                    top: -4,
                                                                                    right: 0,
                                                                                    child: Text(
                                                                                      'Recording Controls',
                                                                                      style: TextStyle(
                                                                                        fontSize: 9,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        color: isDarkMode.value ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.5),
                                                                                        letterSpacing: 0.5,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  SingleChildScrollView(
                                                                                    scrollDirection: Axis.horizontal,
                                                                                    child: ControlButtonsAltComponent(
                                                                                      options: ControlButtonsAltComponentOptions(
                                                                                        buttons: recordButtons,
                                                                                        direction: 'horizontal',
                                                                                        showAspect: true,
                                                                                        location: 'bottom',
                                                                                        position: 'center',
                                                                                        containerBuilder: (context) => context.child,
                                                                                        layoutBuilder: (context) => Row(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          children: context.buttons,
                                                                                        ),
                                                                                        buttonBuilder: (context) {
                                                                                          if (context.button.customComponent != null) {
                                                                                            return context.button.customComponent!;
                                                                                          }

                                                                                          final bool isActive = context.button.active;
                                                                                          final Color activeColor = context.button.activeColor ?? Colors.white;
                                                                                          final Color inActiveColor = context.button.inActiveColor ?? Colors.grey;
                                                                                          final IconData? icon = isActive ? (context.button.alternateIcon ?? context.button.icon) : context.button.icon;

                                                                                          final Widget buttonContent = Container(
                                                                                            padding: const EdgeInsets.all(5),
                                                                                            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                                                                            decoration: BoxDecoration(
                                                                                              color: isActive ? (context.button.pressedBackgroundColor ?? Colors.grey) : (context.button.defaultBackgroundColor ?? Colors.transparent),
                                                                                              borderRadius: BorderRadius.circular(5),
                                                                                            ),
                                                                                            child: Icon(
                                                                                              icon,
                                                                                              color: isActive ? activeColor : inActiveColor,
                                                                                              size: 24,
                                                                                            ),
                                                                                          );

                                                                                          return Tooltip(
                                                                                            message: context.button.name ?? '',
                                                                                            decoration: BoxDecoration(
                                                                                              color: isDarkMode.value ? Colors.white : Colors.black87,
                                                                                              borderRadius: BorderRadius.circular(8),
                                                                                            ),
                                                                                            textStyle: TextStyle(
                                                                                              color: isDarkMode.value ? Colors.black : Colors.white,
                                                                                              fontSize: 12,
                                                                                              fontWeight: FontWeight.w500,
                                                                                            ),
                                                                                            child: GestureDetector(
                                                                                              onTap: context.button.onPress,
                                                                                              child: buttonContent,
                                                                                            ),
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ValueListenableBuilder<
                                                                                String>(
                                                                            valueListenable:
                                                                                meetingProgressTime,
                                                                            builder: (context,
                                                                                meetingProgressTime,
                                                                                child) {
                                                                              return RepaintBoundary(
                                                                                child: _meetingProgressTimerBuilder(
                                                                                    context,
                                                                                    MeetingProgressTimerOptions(
                                                                                      meetingProgressTime: meetingProgressTime,
                                                                                      initialBackgroundColor: recordState == 'green'
                                                                                          ? Colors.green
                                                                                          : recordState == 'yellow'
                                                                                              ? Colors.yellow
                                                                                              : Colors.red,
                                                                                      showTimer: true,
                                                                                    )),
                                                                              );
                                                                            }),
                                                                        // Participants counter badge
                                                                        ValueListenableBuilder<
                                                                                int>(
                                                                            valueListenable:
                                                                                participantsCounter,
                                                                            builder: (context,
                                                                                count,
                                                                                child) {
                                                                              return ParticipantsCounterBadge(
                                                                                options: ParticipantsCounterBadgeOptions(
                                                                                  participantsCount: count,
                                                                                  position: 'bottomLeft',
                                                                                  positionOverride: const ParticipantsCounterBadgePositionOverride(
                                                                                    bottom: 12,
                                                                                    left: 12,
                                                                                  ),
                                                                                  showBadge: true,
                                                                                ),
                                                                              );
                                                                            }),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          ),
                                                          ValueListenableBuilder<
                                                                  GridSizes>(
                                                              valueListenable:
                                                                  gridSizes,
                                                              builder: (context,
                                                                  gridSizes,
                                                                  child) {
                                                                return _otherGridBuilder(
                                                                  context,
                                                                  OtherGridComponentOptions(
                                                                    height: componentSizes
                                                                        .otherHeight,
                                                                    width: componentSizes
                                                                        .otherWidth,
                                                                    backgroundColor:
                                                                        MediasfuColors.themedSurface(
                                                                            darkMode:
                                                                                isDarkModeVal),
                                                                    showAspect: mainHeightWidth ==
                                                                            100
                                                                        ? false
                                                                        : true,
                                                                    timeBackgroundColor: recordState ==
                                                                            'green'
                                                                        ? Colors
                                                                            .green
                                                                        : recordState ==
                                                                                'yellow'
                                                                            ? Colors.yellow
                                                                            : Colors.red,
                                                                    showTimer:
                                                                        false,
                                                                    meetingProgressTime:
                                                                        meetingProgressTime
                                                                            .value,
                                                                    children: [
                                                                      // Translation Streams (Hidden/Audio Only)
                                                                      ValueListenableBuilder<
                                                                          List<
                                                                              Widget>>(
                                                                        valueListenable:
                                                                            translationStreams,
                                                                        builder: (context,
                                                                            streams,
                                                                            _) {
                                                                          return Column(
                                                                            children:
                                                                                streams.map((s) => SizedBox(width: 0, height: 0, child: s)).toList(),
                                                                          );
                                                                        },
                                                                      ),
                                                                      _audioGridBuilder(
                                                                          context,
                                                                          AudioGridOptions(
                                                                            componentsToRender:
                                                                                audioOnlyStreams.value,
                                                                          )),
                                                                      // Position the grid below pagination (for horizontal) or to the right (for vertical)
                                                                      Positioned(
                                                                        top: doPaginate.value &&
                                                                                paginationDirection.value == 'horizontal'
                                                                            ? paginationHeightWidth.value.toDouble()
                                                                            : 0,
                                                                        left: doPaginate.value &&
                                                                                paginationDirection.value == 'vertical'
                                                                            ? paginationHeightWidth.value.toDouble()
                                                                            : 0,
                                                                        right:
                                                                            0,
                                                                        bottom:
                                                                            0,
                                                                        child: _flexibleGridBuilder(
                                                                            context,
                                                                            FlexibleGridOptions(
                                                                              customWidth: gridSizes.gridWidth?.toDouble(),
                                                                              customHeight: gridSizes.gridHeight?.toDouble(),
                                                                              rows: gridRows.value,
                                                                              columns: gridCols.value,
                                                                              componentsToRender: otherGridStreams[0],
                                                                              backgroundColor: MediasfuColors.themedSurface(darkMode: isDarkModeVal),
                                                                              showAspect: addGrid.value && otherGridStreams[0].isNotEmpty,
                                                                            )),
                                                                      ),
                                                                      // Position the alt grid below the main grid
                                                                      Positioned(
                                                                        top: (gridSizes.gridHeight?.toDouble() ??
                                                                                0) +
                                                                            (doPaginate.value && paginationDirection.value == 'horizontal'
                                                                                ? paginationHeightWidth.value.toDouble()
                                                                                : 0),
                                                                        left: doPaginate.value &&
                                                                                paginationDirection.value == 'vertical'
                                                                            ? paginationHeightWidth.value.toDouble()
                                                                            : 0,
                                                                        right:
                                                                            0,
                                                                        bottom:
                                                                            0,
                                                                        child: _flexibleGridAltBuilder(
                                                                            context,
                                                                            FlexibleGridOptions(
                                                                              customWidth: gridSizes.altGridWidth?.toDouble() ?? 0,
                                                                              customHeight: gridSizes.altGridHeight?.toDouble() ?? 0,
                                                                              rows: altGridRows.value,
                                                                              columns: altGridCols.value,
                                                                              componentsToRender: otherGridStreams[1],
                                                                              backgroundColor: MediasfuColors.themedSurface(darkMode: isDarkModeVal),
                                                                              showAspect: addAltGrid.value && otherGridStreams[1].isNotEmpty,
                                                                            )),
                                                                      ),
                                                                      _controlButtonsTouchBuilder(
                                                                          context,
                                                                          ControlButtonsComponentTouchOptions(
                                                                              buttons: controlChatButtons,
                                                                              position: "right",
                                                                              location: "bottom",
                                                                              direction: "vertical",
                                                                              showAspect: eventType.value == EventType.chat)),
                                                                      ValueListenableBuilder<
                                                                              String>(
                                                                          valueListenable:
                                                                              meetingProgressTime,
                                                                          builder: (context,
                                                                              meetingProgressTime,
                                                                              child) {
                                                                            final timerTopOffset = doPaginate.value && paginationDirection.value == 'horizontal'
                                                                                ? paginationHeightWidth.value.toDouble() + 4
                                                                                : 2.0;
                                                                            final timerLeftOffset = doPaginate.value && paginationDirection.value == 'vertical'
                                                                                ? paginationHeightWidth.value.toDouble() + 4
                                                                                : 2.0;
                                                                            return RepaintBoundary(
                                                                              child: _meetingProgressTimerBuilder(
                                                                                  context,
                                                                                  MeetingProgressTimerOptions(
                                                                                    meetingProgressTime: meetingProgressTime,
                                                                                    initialBackgroundColor: recordState == 'green'
                                                                                        ? Colors.green
                                                                                        : recordState == 'yellow'
                                                                                            ? Colors.yellow
                                                                                            : Colors.red,
                                                                                    showTimer: mainHeightWidth == 0 ? true : false,
                                                                                    position: 'topLeft',
                                                                                    positionOverride: MeetingProgressTimerPositionOverride(
                                                                                      top: timerTopOffset,
                                                                                      left: timerLeftOffset,
                                                                                    ),
                                                                                  )),
                                                                            );
                                                                          }),
                                                                      // Participants counter badge (other grid view)
                                                                      ValueListenableBuilder<
                                                                              int>(
                                                                          valueListenable:
                                                                              participantsCounter,
                                                                          builder: (context,
                                                                              count,
                                                                              child) {
                                                                            return ParticipantsCounterBadge(
                                                                              options: ParticipantsCounterBadgeOptions(
                                                                                participantsCount: count,
                                                                                position: 'bottomLeft',
                                                                                positionOverride: const ParticipantsCounterBadgePositionOverride(
                                                                                  bottom: 12,
                                                                                  left: 12,
                                                                                ),
                                                                                showBadge: mainHeightWidth == 0 ? true : false,
                                                                              ),
                                                                            );
                                                                          }),
                                                                      // Pagination positioned at top (horizontal) or left (vertical)
                                                                      Positioned(
                                                                        top: paginationDirection.value ==
                                                                                'horizontal'
                                                                            ? 0
                                                                            : null,
                                                                        left: paginationDirection.value ==
                                                                                'vertical'
                                                                            ? 0
                                                                            : 0,
                                                                        right: paginationDirection.value ==
                                                                                'horizontal'
                                                                            ? 0
                                                                            : null,
                                                                        bottom: paginationDirection.value ==
                                                                                'vertical'
                                                                            ? 0
                                                                            : null,
                                                                        child:
                                                                            Visibility(
                                                                          visible:
                                                                              doPaginate.value,
                                                                          child:
                                                                              SizedBox(
                                                                            width: paginationDirection.value == 'horizontal'
                                                                                ? null
                                                                                : paginationHeightWidth.value.toDouble(),
                                                                            height: paginationDirection.value == 'horizontal'
                                                                                ? paginationHeightWidth.value.toDouble()
                                                                                : null,
                                                                            child: _paginationBuilder(
                                                                                context,
                                                                                PaginationOptions(
                                                                                  totalPages: numberPages.value,
                                                                                  currentUserPage: currentUserPage.value,
                                                                                  showAspect: doPaginate.value,
                                                                                  paginationHeight: paginationHeightWidth.value.toDouble(),
                                                                                  direction: paginationDirection.value,
                                                                                  parameters: mediasfuParameters,
                                                                                  isDarkMode: isDarkModeVal,
                                                                                )),
                                                                          ),
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
                                        ),
                                        // Sidebar - always rendered but animates width from 0
                                        // This ensures main grid shrinks BEFORE sidebar appears
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          width: isSidebarVisible
                                              ? sidebarWidth
                                              : 0,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            color: isSidebarVisible
                                                ? MediasfuColors.themedSurface(
                                                    darkMode: isDarkModeVal,
                                                    elevation: 1)
                                                : Colors.transparent,
                                            border: isSidebarVisible
                                                ? Border(
                                                    left: BorderSide(
                                                      color: isDarkModeVal
                                                          ? Colors.white12
                                                          : Colors.black12,
                                                      width: 1,
                                                    ),
                                                  )
                                                : null,
                                            boxShadow: isSidebarVisible
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(-2, 0),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          // Use OverflowBox to allow child to maintain size during animation
                                          // The clipBehavior on parent will clip the overflow
                                          child: OverflowBox(
                                            alignment: Alignment.centerLeft,
                                            minWidth: sidebarWidth,
                                            maxWidth: sidebarWidth,
                                            child: isSidebarVisible
                                                ? _buildSidebarContent(
                                                    sidebarContent,
                                                    isDarkModeVal)
                                                : const SizedBox.shrink(),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: eventType.value == EventType.webinar ||
                                eventType.value == EventType.conference,
                            child: ValueListenableBuilder<double>(
                              valueListenable: controlHeight,
                              builder: (context, controlHeight, child) {
                                return _subAspectBuilder(
                                  context,
                                  SubAspectComponentOptions(
                                      backgroundColor:
                                          MediasfuColors.themedSurface(
                                              darkMode: isDarkModeVal),
                                      showControls: eventType.value ==
                                              EventType.webinar ||
                                          eventType.value ==
                                              EventType.conference,
                                      defaultFractionSub: 40, //40 pixels
                                      children: [
                                        _controlButtonsBuilder(
                                            context,
                                            ControlButtonsComponentOptions(
                                              buttons: controlButtons,
                                              buttonBackgroundColor:
                                                  Colors.transparent,
                                              buttonColor: isDarkModeVal
                                                  ? Colors.white
                                                  : Colors.black87,
                                              alignment: MainAxisAlignment
                                                  .spaceBetween,
                                              iconSize: 16,
                                              textStyle: TextStyle(
                                                fontSize: 10,
                                                color: isDarkModeVal
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                              buttonPadding:
                                                  const EdgeInsets.all(4),
                                              buttonMargin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2,
                                                      vertical: 2),
                                              vertical:
                                                  false, // Set to true for vertical layout
                                              buttonBuilder:
                                                  (buttonContext, child) {
                                                // Wrap each button with a tooltip
                                                final tooltipText =
                                                    buttonContext
                                                        .button.semanticsLabel;
                                                if (tooltipText != null &&
                                                    tooltipText.isNotEmpty) {
                                                  return Tooltip(
                                                    message: tooltipText,
                                                    preferBelow: false,
                                                    child: child,
                                                  );
                                                }
                                                return child;
                                              },
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
                      : const SizedBox(),
        );
      },
    );
  }

  Widget renderWelcomePage() {
    return _welcomePageBuilder(
      context,
      WelcomePageOptions(
        imgSrc: widget.options.imgSrc ?? kDefaultMediaSFULogo,
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
    return _preJoinPageBuilder(
      context,
      PreJoinPageOptions(
        // return widget.options.preJoinPageWidget!(
        parameters: PreJoinPageParameters(
          imgSrc: widget.options.imgSrc ?? kDefaultMediaSFULogo,
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
          updateAudioPreference: updateUserDefaultAudioInputDevice,
          updateVideoPreference: updateUserDefaultVideoInputDevice,
          updateAudioOutputPreference: updateUserDefaultAudioOutputDevice,
          updateIsDarkMode: updateIsDarkMode,
          updateEventType: updateEventType,
          updateVirtualBackground: updateSelectedBackground,
          updateKeepBackground: (bool value) => keepBackground.value = value,
          updateAppliedBackground: (bool value) =>
              appliedBackground.value = value,
          updateCurrentFacingMode: updateCurrentFacingMode,
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
        localAppKey: widget.options.localAppKey,
        localApiUserName: widget.options.localApiUserName,
        localApiKey: widget.options.localApiKey,
        localSubUserName: widget.options.localSubUserName,
        useFixedLink: widget.options.useFixedLink,
        initialMeetingId: widget.options.initialMeetingId,
        onBack: widget.options.onBack,
      ),
    );
  }

  Widget _buildRoomInterface() {
    // If a custom component is provided, use it instead of the default interface
    if (widget.options.customComponent != null) {
      return widget.options.customComponent!(parameters: mediasfuParameters);
    }

    if (widget.options.returnUI != null && widget.options.returnUI == false) {
      return Stack(
        children: [
          buildEventRoom(context),
        ],
      );
    }

    // Check if we should use desktop sidebar layout
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        final isWide = constraints.maxWidth >= 1200;
        final useSidebar = isLandscape && isWide;

        if (useSidebar) {
          // Desktop layout with persistent sidebar (sidebar is rendered inside MainAspect)
          return Stack(
            children: [
              buildEventRoom(context),
              // System modals that always overlay (confirm exit, alerts, loading)
              _buildConfirmExitModal(),
              _buildAlertModal(),
              _buildConfirmHereModal(),
              _buildLoadingModal(),
              _buildScreenboardModal(),
            ],
          );
        } else {
          // Mobile/tablet layout with overlay modals
          return Stack(
            children: [
              buildEventRoom(context),

              // Sidebar as modal for small screens (unified modal container)
              _buildSidebarModal(),

              // Individual modals only show when sidebar modal is NOT active
              _buildMenuModal(), // Add Menu Modal
              _buildDisplaySettingsModal(), // Add Display Settings Modal
              _buildTranslationSettingsModal(), // Add Translation Settings Modal
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
              _buildConfigureWhiteboardModal(), // Add Configure Whiteboard Modal
              _buildScreenboardModal(), // Add Screenboard Modal
              _buildBackgroundModal(), // Add Background Modal
              _buildPermissionsModal(), // Add Permissions Modal
              _buildPanelistsModal(), // Add Panelists Modal

              _buildConfirmExitModal(), // Add Confirm Exit Modal

              _buildAlertModal(), // Add Alert Modal
              _buildConfirmHereModal(), // Add Confirm Here Modal
              _buildLoadingModal(), // Add Loading Modal
            ],
          );
        }
      },
    );
  }

  /// Builds the content to display in the desktop sidebar based on active selection
  Widget _buildSidebarContent(SidebarContent content, bool isDarkModeVal) {
    // Wrap in a Column with constrained height to prevent overflow
    return ValueListenableBuilder<List<SidebarContent>>(
      valueListenable: sidebarNavigationStack,
      builder: (context, navStack, _) {
        final showBackButton = navStack.isNotEmpty;

        return Column(
          children: [
            // Back button row when navigating from menu to sub-content
            if (showBackButton)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: sidebarNavigateBack,
                  borderRadius: BorderRadius.circular(0),
                  splashColor: (isDarkModeVal
                          ? MediasfuColors.primaryDark
                          : MediasfuColors.primary)
                      .withOpacity(0.15),
                  highlightColor: (isDarkModeVal
                          ? MediasfuColors.primaryDark
                          : MediasfuColors.primary)
                      .withOpacity(0.08),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDarkModeVal
                          ? MediasfuColors.primaryDark.withOpacity(0.12)
                          : MediasfuColors.primary.withOpacity(0.06),
                      border: Border(
                        bottom: BorderSide(
                          color: isDarkModeVal
                              ? MediasfuColors.primaryDark.withOpacity(0.25)
                              : MediasfuColors.primary.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDarkModeVal
                                ? MediasfuColors.primaryDark.withOpacity(0.18)
                                : MediasfuColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: isDarkModeVal
                                ? MediasfuColors.primaryLightDark
                                : MediasfuColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Back to Menu',
                          style: TextStyle(
                            color: isDarkModeVal
                                ? MediasfuColors.primaryLightDark
                                : MediasfuColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.menu_rounded,
                          color: isDarkModeVal
                              ? MediasfuColors.primaryDark.withOpacity(0.5)
                              : MediasfuColors.primary.withOpacity(0.35),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Main sidebar content - expanded to fill remaining space
            Expanded(
              child: ClipRect(
                child: AnimatedSwitcher(
                  duration: MediasfuAnimations.normal,
                  switchInCurve: MediasfuAnimations.snappy,
                  switchOutCurve: MediasfuAnimations.accelerate,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<SidebarContent>(content),
                    child: _getSidebarWidget(content, isDarkModeVal),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Returns the widget to display in the sidebar based on content type
  Widget _getSidebarWidget(SidebarContent content, bool isDarkModeVal) {
    switch (content) {
      case SidebarContent.menu:
        return _buildMenuSidebarContent(isDarkModeVal);
      case SidebarContent.participants:
        return _buildParticipantsSidebarContent(isDarkModeVal);
      case SidebarContent.messages:
        return _buildMessagesSidebarContent(isDarkModeVal);
      case SidebarContent.requests:
        return _buildRequestsSidebarContent(isDarkModeVal);
      case SidebarContent.waiting:
        return _buildWaitingSidebarContent(isDarkModeVal);
      case SidebarContent.coHost:
        return _buildCoHostSidebarContent(isDarkModeVal);
      case SidebarContent.mediaSettings:
        return _buildMediaSettingsSidebarContent(isDarkModeVal);
      case SidebarContent.displaySettings:
        return _buildDisplaySettingsSidebarContent(isDarkModeVal);
      case SidebarContent.eventSettings:
        return _buildEventSettingsSidebarContent(isDarkModeVal);
      case SidebarContent.recording:
        return _buildRecordingSidebarContent(isDarkModeVal);
      case SidebarContent.polls:
        return _buildPollsSidebarContent(isDarkModeVal);
      case SidebarContent.breakoutRooms:
        return _buildBreakoutRoomsSidebarContent(isDarkModeVal);
      case SidebarContent.shareEvent:
        return _buildShareEventSidebarContent(isDarkModeVal);
      case SidebarContent.configureWhiteboard:
        return _buildConfigureWhiteboardSidebarContent(isDarkModeVal);
      case SidebarContent.background:
        return _buildBackgroundSidebarContent(isDarkModeVal);
      case SidebarContent.permissions:
        return _buildPermissionsSidebarContent(isDarkModeVal);
      case SidebarContent.panelists:
        return _buildPanelistsSidebarContent(isDarkModeVal);
      case SidebarContent.translation:
        return _buildTranslationSidebarContent(isDarkModeVal);
      case SidebarContent.none:
        return const SizedBox.shrink();
    }
  }

  /// Builds the sidebar as a slide-in modal for mobile/tablet screens
  /// This provides the same sidebar experience on smaller screens
  Widget _buildSidebarModal() {
    return ValueListenableBuilder<SidebarContent>(
      valueListenable: activeSidebarContent,
      builder: (context, sidebarContent, _) {
        // Don't show if no content or if using embedded sidebar
        if (sidebarContent == SidebarContent.none || shouldUseSidebar) {
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder<bool>(
          valueListenable: isDarkMode,
          builder: (context, isDarkModeVal, _) {
            final screenWidth = MediaQuery.of(context).size.width;
            // Modal width: 85% of screen width on mobile, max 400px
            final modalWidth = (screenWidth * 0.85).clamp(280.0, 400.0);

            return Stack(
              children: [
                // Backdrop - tap to close
                Positioned.fill(
                  child: GestureDetector(
                    onTap: closeSidebar,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ),
                // Sidebar panel - slides in from right with 5% vertical margin
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.05,
                  bottom: MediaQuery.of(context).size.height * 0.05,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: modalWidth,
                    decoration: BoxDecoration(
                      color: MediasfuColors.themedSurface(
                        darkMode: isDarkModeVal,
                        elevation: 2,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(-4, 0),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: SafeArea(
                        left: false,
                        child:
                            _buildSidebarContent(sidebarContent, isDarkModeVal),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMenuModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isMenuModalVisible,
      builder: (context, isMenuModalVisibleVal, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkMode,
          builder: (context, isDarkModeVal, child) {
            initializeRecordButtons(isDarkModeVal);
            initializeRecordButtonsTouch(isDarkModeVal);
            initializeCustomMenuButtons();

            final options = MenuModalOptions(
              backgroundColor:
                  MediasfuColors.themedSurface(darkMode: isDarkModeVal),
              isVisible: isMenuModalVisibleVal && !shouldUseSidebar,
              onClose: () => updateIsMenuModalVisible(false),
              customButtons: customMenuButtons,
              roomName: roomName.value,
              adminPasscode: adminPasscode.value,
              islevel: islevel.value,
              eventType: eventType.value,
              localLink: widget.options.localLink,
              isDarkMode: isDarkModeVal,
              onToggleTheme: updateIsDarkMode,
            );
            return _menuModalBuilder(context, options);
          },
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
            return ValueListenableBuilder<bool>(
              valueListenable: isDarkMode,
              builder: (context, isDarkModeVal, child) {
                final options = RecordingModalOptions(
                  backgroundColor:
                      MediasfuColors.themedSurface(darkMode: isDarkModeVal),
                  isRecordingModalVisible:
                      isRecordingModalVisible && !shouldUseSidebar,
                  onClose: () {
                    updateIsRecordingModalVisible(false);
                  },
                  startRecording: startRecording,
                  confirmRecording: confirmRecording,
                  parameters: mediasfuParameters,
                  isDarkMode: isDarkModeVal,
                  enableGlassmorphism: true,
                );
                return _recordingModalBuilder(context, options);
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
        return ValueListenableBuilder<List<Request>>(
          valueListenable: filteredRequestList,
          builder: (context, filteredRequestList, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: isDarkMode,
              builder: (context, isDarkModeVal, child) {
                final options = RequestsModalOptions(
                  backgroundColor:
                      MediasfuColors.themedSurface(darkMode: isDarkModeVal),
                  isRequestsModalVisible:
                      isRequestsVisible && !shouldUseSidebar,
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
                  isDarkMode: isDarkModeVal,
                  enableGlassmorphism: true,
                );
                return _requestsModalBuilder(context, options);
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
        return ValueListenableBuilder<List<WaitingRoomParticipant>>(
          valueListenable: filteredWaitingRoomList,
          builder: (context, filteredWaitingRoomList, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: isDarkMode,
              builder: (context, isDarkModeVal, child) {
                final options = WaitingRoomModalOptions(
                  backgroundColor:
                      MediasfuColors.themedSurface(darkMode: isDarkModeVal),
                  isWaitingModalVisible:
                      isWaitingModalVisible && !shouldUseSidebar,
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
                  isDarkMode: isDarkModeVal,
                  enableGlassmorphism: true,
                );
                return _waitingRoomModalBuilder(context, options);
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
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkMode,
          builder: (context, isDarkModeVal, child) {
            final options = DisplaySettingsModalOptions(
              isVisible: isDisplaySettingsVisible && !shouldUseSidebar,
              onClose: () {
                updateIsDisplaySettingsModalVisible(false);
              },
              parameters: mediasfuParameters,
              isDarkMode: isDarkModeVal,
              enableGlassmorphism: true,
            );
            return _displaySettingsModalBuilder(context, options);
          },
        );
      },
    );
  }

  Widget _buildTranslationSettingsModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isTranslationSettingsModalVisible,
      builder: (context, isTranslationVisible, child) {
        if (!isTranslationVisible) return const SizedBox.shrink();

        return ValueListenableBuilder<bool>(
          valueListenable: isDarkMode,
          builder: (context, isDarkModeVal, child) {
            return TranslationSettingsModal(
              isDarkMode: isDarkModeVal,
              options: TranslationSettingsModalOptions(
                isVisible: isTranslationVisible,
                onClose: onCloseTranslationSettings,
                member: member.value,
                islevel: islevel.value,
                participants: participants.value,
                listenerTranslationPreferences: listenerTranslationPreferences,
                listenerTranslationOverrides: listenerTranslationOverrides,
                translationProducerMap: translationProducerMap,
                speakerTranslationStates: speakerTranslationStates,
                translationSubscriptions: translationSubscriptions,
                updateListenerTranslationPreferences:
                    updateListenerTranslationPreferences,
                updateListenerTranslationOverrides:
                    updateListenerTranslationOverrides,
                updateTranslationProducerMap: updateTranslationProducerMap,
                updateSpeakerTranslationStates: updateSpeakerTranslationStates,
                roomName: roomName.value,
                socket: socket.value,
                showAlert: showAlert,
                audioProducerId: audioProducer.value?.id,
                mySpokenLanguage: mySpokenLanguage,
                mySpokenLanguageEnabled: mySpokenLanguageEnabled,
                myDefaultOutputLanguage: myDefaultOutputLanguage,
                myDefaultListenLanguage:
                    listenerTranslationPreferences.globalLanguage,
                listenPreferences: listenerTranslationPreferences.perSpeaker,
                updateMySpokenLanguage: updateMySpokenLanguage,
                updateMySpokenLanguageEnabled: updateMySpokenLanguageEnabled,
                updateMyDefaultOutputLanguage: updateMyDefaultOutputLanguage,
                updateMyDefaultListenLanguage: (String? lang) {
                  final newPrefs = ListenerTranslationPreferences(
                      perSpeaker: listenerTranslationPreferences.perSpeaker,
                      globalLanguage: lang);
                  updateListenerTranslationPreferences(newPrefs);
                },
                updateListenPreferences: (Map<String, String> prefs) {
                  final newPrefs = ListenerTranslationPreferences(
                      perSpeaker: prefs,
                      globalLanguage:
                          listenerTranslationPreferences.globalLanguage);
                  updateListenerTranslationPreferences(newPrefs);
                },
                showSubtitlesOnCards: showSubtitlesOnCards.value,
                updateShowSubtitlesOnCards: updateShowSubtitlesOnCards,
                isPersonalTranslation: isPersonalTranslation.value,
                userVoiceClones: widget.options.userVoiceClones,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventSettingsModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isSettingsModalVisible,
      builder: (context, isSettingsVisible, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkMode,
          builder: (context, isDarkModeVal, child) {
            final options = EventSettingsModalOptions(
              backgroundColor:
                  MediasfuColors.themedSurface(darkMode: isDarkModeVal),
              isVisible: isSettingsVisible && !shouldUseSidebar,
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
              isDarkMode: isDarkModeVal,
              enableGlassmorphism: true,
            );
            return _eventSettingsModalBuilder(context, options);
          },
        );
      },
    );
  }

  Widget _buildCoHostModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isCoHostModalVisible,
      builder: (context, isCoHostVisible, child) {
        final options = CoHostModalOptions(
          isCoHostModalVisible: isCoHostVisible && !shouldUseSidebar,
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
        );
        return _coHostModalBuilder(context, options);
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
            return ValueListenableBuilder<bool>(
              valueListenable: isDarkMode,
              builder: (context, isDarkModeVal, child) {
                final options = ParticipantsModalOptions(
                  backgroundColor:
                      MediasfuColors.themedSurface(darkMode: isDarkModeVal),
                  isParticipantsModalVisible:
                      isParticipantsVisible && !shouldUseSidebar,
                  onParticipantsClose: () {
                    updateIsParticipantsModalVisible(false);
                  },
                  participantsCounter: participantsCounter.value,
                  onParticipantsFilterChange: onParticipantsFilterChange,
                  parameters: mediasfuParameters,
                  isDarkMode: isDarkModeVal,
                );
                return _participantsModalBuilder(context, options);
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
        return ValueListenableBuilder<List<Message>>(
          valueListenable: messages,
          builder: (context, messages, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: isDarkMode,
              builder: (context, isDarkModeVal, child) {
                final options = MessagesModalOptions(
                  backgroundColor:
                      MediasfuColors.themedSurface(darkMode: isDarkModeVal),
                  isMessagesModalVisible:
                      isMessagesVisible && !shouldUseSidebar,
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
                  isDarkMode: isDarkModeVal,
                );
                return _messagesModalBuilder(context, options);
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
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkMode,
          builder: (context, isDarkModeVal, child) {
            final options = MediaSettingsModalOptions(
              backgroundColor:
                  MediasfuColors.themedSurface(darkMode: isDarkModeVal),
              isVisible: isMediaSettingsVisible && !shouldUseSidebar,
              onClose: () {
                updateIsMediaSettingsModalVisible(false);
              },
              parameters: mediasfuParameters,
              isDarkMode: isDarkModeVal,
              enableGlassmorphism: true,
            );
            return _mediaSettingsModalBuilder(context, options);
          },
        );
      },
    );
  }

  Widget _buildConfirmExitModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isConfirmExitModalVisible,
      builder: (context, isConfirmExitVisible, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkMode,
          builder: (context, isDarkModeVal, child) {
            final options = ConfirmExitModalOptions(
              backgroundColor:
                  MediasfuColors.themedSurface(darkMode: isDarkModeVal),
              isVisible: isConfirmExitVisible,
              onClose: () {
                updateIsConfirmExitModalVisible(false);
              },
              islevel: islevel.value,
              roomName: roomName.value,
              member: member.value,
              socket: socket.value,
            );
            return _confirmExitModalBuilder(context, options);
          },
        );
      },
    );
  }

  Widget _buildConfirmHereModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isConfirmHereModalVisible,
      builder: (context, isConfirmHereModalVisible, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkMode,
          builder: (context, isDarkModeVal, child) {
            final options = ConfirmHereModalOptions(
              backgroundColor:
                  MediasfuColors.themedSurface(darkMode: isDarkModeVal),
              isConfirmHereModalVisible: isConfirmHereModalVisible,
              onConfirmHereClose: () {
                updateIsConfirmHereModalVisible(false);
              },
              onSuppressConfirmHere: () {
                _suppressConfirmHere = true;
              },
              roomName: roomName.value,
              socket: socket.value,
              member: member.value,
            );
            return _confirmHereModalBuilder(context, options);
          },
        );
      },
    );
  }

  Widget _buildShareEventModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isShareEventModalVisible,
      builder: (context, isShareEventModalVisible, child) {
        final options = ShareEventModalOptions(
          isShareEventModalVisible:
              isShareEventModalVisible && !shouldUseSidebar,
          // updateIsShareEventModalVisible: updateIsShareEventModalVisible,
          onShareEventClose: () {
            updateIsShareEventModalVisible(false);
          },
          roomName: roomName.value,
          islevel: islevel.value,
          adminPasscode: adminPasscode.value,
          localLink: widget.options.localLink,
        );
        return _shareEventModalBuilder(context, options);
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
              return ValueListenableBuilder<bool>(
                valueListenable: isDarkMode,
                builder: (context, isDarkModeVal, child) {
                  final options = PollModalOptions(
                    isPollModalVisible: isPollVisible && !shouldUseSidebar,
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
                    isDarkMode: isDarkModeVal,
                    enableGlassmorphism: true,
                  );
                  return _pollModalBuilder(context, options);
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
                return ValueListenableBuilder<bool>(
                  valueListenable: isDarkMode,
                  builder: (context, isDarkModeVal, child) {
                    final options = BreakoutRoomsModalOptions(
                      backgroundColor:
                          MediasfuColors.themedSurface(darkMode: isDarkModeVal),
                      isVisible: isBreakoutRoomsVisible && !shouldUseSidebar,
                      onBreakoutRoomsClose: () {
                        updateIsBreakoutRoomsModalVisible(false);
                      },
                      parameters: mediasfuParameters,
                    );
                    return _breakoutRoomsModalBuilder(context, options);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildConfigureWhiteboardModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isConfigureWhiteboardModalVisible,
      builder: (context, isVisible, child) {
        if (!isVisible) {
          return const SizedBox.shrink();
        }
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkMode,
          builder: (context, isDarkModeVal, child) {
            final options = ConfigureWhiteboardModalOptions(
              backgroundColor:
                  MediasfuColors.themedSurface(darkMode: isDarkModeVal),
              isVisible: isVisible && !shouldUseSidebar,
              onClose: () {
                updateIsConfigureWhiteboardModalVisible(false);
              },
              parameters: mediasfuParameters,
              isDarkMode: isDarkModeVal,
              enableGlassmorphism: true,
            );
            return _configureWhiteboardModalBuilder(context, options);
          },
        );
      },
    );
  }

  Widget _buildScreenboardModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isScreenboardModalVisible,
      builder: (context, isVisible, child) {
        // IMPORTANT: Don't destroy the widget when not visible!
        // The annotation capture must persist even when modal is hidden.
        // React keeps the modal in DOM with display:none, we use Offstage.
        final options = ScreenboardModalOptions(
          isVisible: isVisible,
          onClose: () {
            updateIsScreenboardModalVisible(false);
          },
          parameters: mediasfuParameters as ScreenboardModalParameters,
        );
        // Use Offstage to hide without destroying - keeps capture running
        return Offstage(
          offstage: !isVisible,
          child: _screenboardModalBuilder(context, options),
        );
      },
    );
  }

  Widget _buildBackgroundModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isBackgroundModalVisible,
      builder: (context, isVisible, child) {
        if (!isVisible) {
          return const SizedBox.shrink();
        }
        // Get dark mode value - modern UI uses isDarkMode.value
        final isDark = isDarkMode.value;
        final options = BackgroundModalOptions(
          isVisible: isVisible && !shouldUseSidebar,
          onClose: () {
            updateIsBackgroundModalVisible(false);
          },
          parameters: mediasfuParameters as BackgroundModalParameters,
          backgroundColor:
              isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
          isDarkMode: isDark,
        );
        return _backgroundModalBuilder(context, options);
      },
    );
  }

  Widget _buildPermissionsModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isPermissionsModalVisible,
      builder: (context, isVisible, child) {
        // Use sidebar system instead of floating modal
        if (!isVisible || shouldUseSidebar) {
          return const SizedBox.shrink();
        }
        return ValueListenableBuilder<List<Participant>>(
          valueListenable: participants,
          builder: (context, participantsList, _) {
            final isDark = isDarkMode.value;
            final options = ModernPermissionsModalOptions(
              isPermissionsModalVisible: isVisible,
              onPermissionsClose: () {
                updateIsPermissionsModalVisible(false);
              },
              participants: participantsList,
              member: member.value,
              islevel: islevel.value,
              socket: socket.value,
              roomName: roomName.value,
              showAlert: showAlert,
              permissionConfig: permissionConfig.value,
              updatePermissionConfig: updatePermissionConfig,
              isDarkMode: isDark,
              enableGlassmorphism: true,
              renderMode: ModalRenderMode.modal,
              // Event settings for initial values when permissionConfig is not set
              audioSetting: audioSetting.value,
              videoSetting: videoSetting.value,
              screenshareSetting: screenshareSetting.value,
              chatSetting: chatSetting.value,
            );
            return ModernPermissionsModal(options: options);
          },
        );
      },
    );
  }

  Widget _buildPanelistsModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isPanelistsModalVisible,
      builder: (context, isVisible, child) {
        // Use sidebar system instead of floating modal
        if (!isVisible || shouldUseSidebar) {
          return const SizedBox.shrink();
        }
        return ValueListenableBuilder<List<Participant>>(
          valueListenable: participants,
          builder: (context, participantsList, _) {
            return ValueListenableBuilder<List<Participant>>(
              valueListenable: panelists,
              builder: (context, panelistsList, _) {
                final isDark = isDarkMode.value;
                final options = ModernPanelistsModalOptions(
                  isPanelistsModalVisible: isVisible,
                  onPanelistsClose: () {
                    updateIsPanelistsModalVisible(false);
                  },
                  participants: participantsList,
                  panelists: panelistsList,
                  member: member.value,
                  islevel: islevel.value,
                  socket: socket.value,
                  roomName: roomName.value,
                  showAlert: showAlert,
                  itemPageLimit: itemPageLimit.value,
                  panelistsFocused: panelistsFocused.value,
                  muteOthersMic: muteOthersMic.value,
                  muteOthersCamera: muteOthersCamera.value,
                  updatePanelists: updatePanelists,
                  updatePanelistsFocused: updatePanelistsFocused,
                  updateMuteOthersMic: updateMuteOthersMic,
                  updateMuteOthersCamera: updateMuteOthersCamera,
                  isDarkMode: isDark,
                  enableGlassmorphism: true,
                  renderMode: ModalRenderMode.modal,
                );
                return ModernPanelistsModal(options: options);
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
        final options = AlertComponentOptions(
          visible: isVisible,
          message: alertMessage.value,
          type: alertType.value,
          duration: alertDuration.value,
          onHide: () {
            updateAlertVisible(false);
          },
          textColor: const Color(0xFFFFFFFF),
          overlayAlignment: Alignment.center,
        );
        return _alertBuilder(context, options);
      },
    );
  }

  Widget _buildLoadingModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoadingModalVisible,
      builder: (context, isLoadingModalVisible, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkMode,
          builder: (context, isDarkModeVal, child) {
            final options = LoadingModalOptions(
              isVisible: isLoadingModalVisible,
              backgroundColor:
                  MediasfuColors.themedSurface(darkMode: isDarkModeVal),
              displayColor:
                  MediasfuColors.controlTextColor(darkMode: isDarkModeVal),
            );
            return _loadingModalBuilder(context, options);
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DESKTOP SIDEBAR CONTENT BUILDERS
  // These render modal content inline within the sidebar without overlay behavior
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMenuSidebarContent(bool isDarkModeVal) {
    initializeRecordButtons(isDarkModeVal);
    initializeRecordButtonsTouch(isDarkModeVal);
    initializeCustomMenuButtons();

    final options = MenuModalOptions(
      backgroundColor: Colors.transparent,
      isVisible: true,
      onClose: () => updateActiveSidebarContent(SidebarContent.none),
      customButtons: customMenuButtons,
      roomName: roomName.value,
      adminPasscode: adminPasscode.value,
      islevel: islevel.value,
      eventType: eventType.value,
      localLink: widget.options.localLink,
      isDarkMode: isDarkModeVal,
      onToggleTheme: updateIsDarkMode,
      renderMode: ModalRenderMode.sidebar,
    );
    return _menuModalBuilder(context, options);
  }

  Widget _buildParticipantsSidebarContent(bool isDarkModeVal) {
    return ValueListenableBuilder<List<Participant>>(
      valueListenable: filteredParticipants,
      builder: (context, participants, _) {
        return ValueListenableBuilder<int>(
          valueListenable: participantsCounter,
          builder: (context, counter, _) {
            final options = ParticipantsModalOptions(
              backgroundColor: Colors.transparent,
              isParticipantsModalVisible: true,
              onParticipantsClose: () =>
                  updateActiveSidebarContent(SidebarContent.none),
              participantsCounter: counter,
              onParticipantsFilterChange: onParticipantsFilterChange,
              parameters: mediasfuParameters,
              isDarkMode: isDarkModeVal,
              enableGlassmorphism: false,
              renderMode: ModalRenderMode.sidebar,
            );
            return _participantsModalBuilder(context, options);
          },
        );
      },
    );
  }

  Widget _buildMessagesSidebarContent(bool isDarkModeVal) {
    return ValueListenableBuilder<List<Message>>(
      valueListenable: messages,
      builder: (context, msgs, _) {
        final options = MessagesModalOptions(
          backgroundColor: Colors.transparent,
          isMessagesModalVisible: true,
          onMessagesClose: () =>
              updateActiveSidebarContent(SidebarContent.none),
          messages: msgs,
          eventType: eventType.value,
          member: member.value,
          islevel: islevel.value,
          coHostResponsibility: coHostResponsibility.value,
          coHost: coHost.value,
          startDirectMessage: startDirectMessage.value,
          directMessageDetails: directMessageDetails.value,
          updateStartDirectMessage: updateStartDirectMessage,
          updateDirectMessageDetails: updateDirectMessageDetails,
          roomName: roomName.value,
          socket: socket.value,
          chatSetting: chatSetting.value,
          showAlert: showAlert,
          isDarkMode: isDarkModeVal,
          enableGlassmorphism: false,
          renderMode: ModalRenderMode.sidebar,
        );
        return _messagesModalBuilder(context, options);
      },
    );
  }

  Widget _buildRequestsSidebarContent(bool isDarkModeVal) {
    return ValueListenableBuilder<List<Request>>(
      valueListenable: filteredRequestList,
      builder: (context, requests, _) {
        final options = RequestsModalOptions(
          backgroundColor: Colors.transparent,
          isRequestsModalVisible: true,
          onRequestClose: () => updateActiveSidebarContent(SidebarContent.none),
          requestCounter: requestCounter.value,
          onRequestFilterChange: onRequestFilterChange,
          updateRequestList: updateRequestList,
          requestList: requests,
          roomName: roomName.value,
          socket: socket.value,
          parameters: mediasfuParameters,
          isDarkMode: isDarkModeVal,
          enableGlassmorphism: false,
          renderMode: ModalRenderMode.sidebar,
        );
        return _requestsModalBuilder(context, options);
      },
    );
  }

  Widget _buildWaitingSidebarContent(bool isDarkModeVal) {
    return ValueListenableBuilder<List<WaitingRoomParticipant>>(
      valueListenable: waitingRoomList,
      builder: (context, waitingList, _) {
        return ValueListenableBuilder<int>(
          valueListenable: waitingRoomCounter,
          builder: (context, counter, _) {
            final options = WaitingRoomModalOptions(
              backgroundColor: Colors.transparent,
              isWaitingModalVisible: true,
              onWaitingRoomClose: () =>
                  updateActiveSidebarContent(SidebarContent.none),
              waitingRoomCounter: counter,
              onWaitingRoomFilterChange: onWaitingRoomFilterChange,
              waitingRoomList: waitingRoomList.value,
              updateWaitingList: updateWaitingRoomList,
              roomName: roomName.value,
              socket: socket.value,
              parameters: mediasfuParameters,
              isDarkMode: isDarkModeVal,
              enableGlassmorphism: false,
              renderMode: ModalRenderMode.sidebar,
            );
            return _waitingRoomModalBuilder(context, options);
          },
        );
      },
    );
  }

  Widget _buildCoHostSidebarContent(bool isDarkModeVal) {
    return ValueListenableBuilder<List<Participant>>(
      valueListenable: participants,
      builder: (context, participantsList, _) {
        final options = CoHostModalOptions(
          backgroundColor: Colors.transparent,
          isCoHostModalVisible: true,
          onCoHostClose: () => updateActiveSidebarContent(SidebarContent.none),
          currentCohost: coHost.value,
          participants: participantsList,
          coHostResponsibility: coHostResponsibility.value,
          roomName: roomName.value,
          showAlert: showAlert,
          updateCoHostResponsibility: updateCoHostResponsibility,
          updateCoHost: updateCoHost,
          updateIsCoHostModalVisible: updateIsCoHostModalVisible,
          socket: socket.value,
          renderMode: ModalRenderMode.sidebar,
        );
        return _coHostModalBuilder(context, options);
      },
    );
  }

  Widget _buildMediaSettingsSidebarContent(bool isDarkModeVal) {
    final options = MediaSettingsModalOptions(
      backgroundColor: Colors.transparent,
      isVisible: true,
      onClose: () => updateActiveSidebarContent(SidebarContent.none),
      parameters: mediasfuParameters,
      isDarkMode: isDarkModeVal,
      enableGlassmorphism: false,
      renderMode: ModalRenderMode.sidebar,
    );
    return _mediaSettingsModalBuilder(context, options);
  }

  Widget _buildDisplaySettingsSidebarContent(bool isDarkModeVal) {
    final options = DisplaySettingsModalOptions(
      backgroundColor: Colors.transparent,
      isVisible: true,
      onClose: () => updateActiveSidebarContent(SidebarContent.none),
      parameters: mediasfuParameters,
      isDarkMode: isDarkModeVal,
      enableGlassmorphism: false,
      renderMode: ModalRenderMode.sidebar,
    );
    return _displaySettingsModalBuilder(context, options);
  }

  Widget _buildEventSettingsSidebarContent(bool isDarkModeVal) {
    final options = EventSettingsModalOptions(
      backgroundColor: Colors.transparent,
      isVisible: true,
      onClose: () => updateActiveSidebarContent(SidebarContent.none),
      audioSetting: audioSetting.value,
      videoSetting: videoSetting.value,
      screenshareSetting: screenshareSetting.value,
      chatSetting: chatSetting.value,
      roomName: roomName.value,
      socket: socket.value,
      showAlert: showAlert,
      updateAudioSetting: updateAudioSetting,
      updateVideoSetting: updateVideoSetting,
      updateScreenshareSetting: updateScreenshareSetting,
      updateChatSetting: updateChatSetting,
      updateIsSettingsModalVisible: updateIsSettingsModalVisible,
      isDarkMode: isDarkModeVal,
      enableGlassmorphism: false,
      renderMode: ModalRenderMode.sidebar,
    );
    return _eventSettingsModalBuilder(context, options);
  }

  Widget _buildRecordingSidebarContent(bool isDarkModeVal) {
    return ValueListenableBuilder<bool>(
      valueListenable: recordUIChanged,
      builder: (context, _, __) {
        final options = RecordingModalOptions(
          backgroundColor: Colors.transparent,
          isRecordingModalVisible: true,
          onClose: () => updateActiveSidebarContent(SidebarContent.none),
          startRecording: startRecording,
          confirmRecording: confirmRecording,
          parameters: mediasfuParameters,
          isDarkMode: isDarkModeVal,
          enableGlassmorphism: false,
          renderMode: ModalRenderMode.sidebar,
        );
        return _recordingModalBuilder(context, options);
      },
    );
  }

  Widget _buildPollsSidebarContent(bool isDarkModeVal) {
    return ValueListenableBuilder<Poll?>(
      valueListenable: poll,
      builder: (context, pollVal, _) {
        final options = PollModalOptions(
          backgroundColor: Colors.transparent,
          isPollModalVisible: true,
          onClose: () => updateActiveSidebarContent(SidebarContent.none),
          member: member.value,
          islevel: islevel.value,
          polls: polls.value,
          poll: pollVal,
          socket: socket.value,
          roomName: roomName.value,
          showAlert: showAlert,
          updateIsPollModalVisible: updateIsPollModalVisible,
          handleCreatePoll: handleCreatePoll,
          handleEndPoll: handleEndPoll,
          handleVotePoll: handleVotePoll,
          isDarkMode: isDarkModeVal,
          enableGlassmorphism: false,
          renderMode: ModalRenderMode.sidebar,
        );
        return _pollModalBuilder(context, options);
      },
    );
  }

  Widget _buildBreakoutRoomsSidebarContent(bool isDarkModeVal) {
    final options = BreakoutRoomsModalOptions(
      backgroundColor: Colors.transparent,
      isVisible: true,
      onBreakoutRoomsClose: () =>
          updateActiveSidebarContent(SidebarContent.none),
      parameters: mediasfuParameters,
      renderMode: ModalRenderMode.sidebar,
    );
    return _breakoutRoomsModalBuilder(context, options);
  }

  Widget _buildShareEventSidebarContent(bool isDarkModeVal) {
    final options = ShareEventModalOptions(
      backgroundColor: Colors.transparent,
      isShareEventModalVisible: true,
      onShareEventClose: () => updateActiveSidebarContent(SidebarContent.none),
      roomName: roomName.value,
      adminPasscode: adminPasscode.value,
      islevel: islevel.value,
      eventType: eventType.value,
      localLink: widget.options.localLink,
      renderMode: ModalRenderMode.sidebar,
    );
    // Wrap in Theme to ensure correct brightness is detected in the modal
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: isDarkModeVal ? Brightness.dark : Brightness.light,
      ),
      child: _shareEventModalBuilder(context, options),
    );
  }

  Widget _buildConfigureWhiteboardSidebarContent(bool isDarkModeVal) {
    final options = ConfigureWhiteboardModalOptions(
      backgroundColor: Colors.transparent,
      isVisible: true,
      onClose: () => updateActiveSidebarContent(SidebarContent.none),
      parameters: mediasfuParameters,
      renderMode: ModalRenderMode.sidebar,
      isDarkMode: isDarkModeVal,
      enableGlassmorphism: false,
    );
    return _configureWhiteboardModalBuilder(context, options);
  }

  Widget _buildBackgroundSidebarContent(bool isDarkModeVal) {
    final options = BackgroundModalOptions(
      backgroundColor:
          isDarkModeVal ? const Color(0xFF1E1E1E) : Colors.transparent,
      isVisible: true,
      onClose: () => updateActiveSidebarContent(SidebarContent.none),
      parameters: mediasfuParameters,
      renderMode: ModalRenderMode.sidebar,
      isDarkMode: isDarkModeVal,
    );
    return _backgroundModalBuilder(context, options);
  }

  Widget _buildPermissionsSidebarContent(bool isDarkModeVal) {
    return ValueListenableBuilder<List<Participant>>(
      valueListenable: participants,
      builder: (context, participantsList, _) {
        final options = ModernPermissionsModalOptions(
          isPermissionsModalVisible: true,
          onPermissionsClose: () =>
              updateActiveSidebarContent(SidebarContent.none),
          participants: participantsList,
          member: member.value,
          islevel: islevel.value,
          socket: socket.value,
          roomName: roomName.value,
          showAlert: showAlert,
          permissionConfig: permissionConfig.value,
          updatePermissionConfig: updatePermissionConfig,
          isDarkMode: isDarkModeVal,
          enableGlassmorphism: false,
          renderMode: ModalRenderMode.sidebar,
          // Event settings for initial values when permissionConfig is not set
          audioSetting: audioSetting.value,
          videoSetting: videoSetting.value,
          screenshareSetting: screenshareSetting.value,
          chatSetting: chatSetting.value,
        );
        return ModernPermissionsModal(options: options);
      },
    );
  }

  Widget _buildPanelistsSidebarContent(bool isDarkModeVal) {
    return ValueListenableBuilder<List<Participant>>(
      valueListenable: participants,
      builder: (context, participantsList, _) {
        return ValueListenableBuilder<List<Participant>>(
          valueListenable: panelists,
          builder: (context, panelistsList, _) {
            final options = ModernPanelistsModalOptions(
              isPanelistsModalVisible: true,
              onPanelistsClose: () =>
                  updateActiveSidebarContent(SidebarContent.none),
              participants: participantsList,
              panelists: panelistsList,
              member: member.value,
              islevel: islevel.value,
              socket: socket.value,
              roomName: roomName.value,
              showAlert: showAlert,
              itemPageLimit: itemPageLimit.value,
              panelistsFocused: panelistsFocused.value,
              muteOthersMic: muteOthersMic.value,
              muteOthersCamera: muteOthersCamera.value,
              updatePanelists: updatePanelists,
              updatePanelistsFocused: updatePanelistsFocused,
              updateMuteOthersMic: updateMuteOthersMic,
              updateMuteOthersCamera: updateMuteOthersCamera,
              isDarkMode: isDarkModeVal,
              enableGlassmorphism: false,
              renderMode: ModalRenderMode.sidebar,
            );
            return ModernPanelistsModal(options: options);
          },
        );
      },
    );
  }

  Widget _buildTranslationSidebarContent(bool isDarkModeVal) {
    return TranslationSettingsModal(
      isDarkMode: isDarkModeVal,
      enableGlassmorphism: false,
      options: TranslationSettingsModalOptions(
        isVisible: true,
        renderMode: ModalRenderMode.sidebar,
        onClose: () => updateActiveSidebarContent(SidebarContent.none),
        member: member.value,
        islevel: islevel.value,
        participants: participants.value,
        listenerTranslationPreferences: listenerTranslationPreferences,
        listenerTranslationOverrides: listenerTranslationOverrides,
        translationProducerMap: translationProducerMap,
        speakerTranslationStates: speakerTranslationStates,
        translationSubscriptions: translationSubscriptions,
        updateListenerTranslationPreferences:
            updateListenerTranslationPreferences,
        updateListenerTranslationOverrides: updateListenerTranslationOverrides,
        updateTranslationProducerMap: updateTranslationProducerMap,
        updateSpeakerTranslationStates: updateSpeakerTranslationStates,
        roomName: roomName.value,
        socket: socket.value,
        showAlert: showAlert,
        audioProducerId: audioProducer.value?.id,
        mySpokenLanguage: mySpokenLanguage,
        mySpokenLanguageEnabled: mySpokenLanguageEnabled,
        myDefaultOutputLanguage: myDefaultOutputLanguage,
        myDefaultListenLanguage: listenerTranslationPreferences.globalLanguage,
        listenPreferences: listenerTranslationPreferences.perSpeaker,
        updateMySpokenLanguage: updateMySpokenLanguage,
        updateMySpokenLanguageEnabled: updateMySpokenLanguageEnabled,
        updateMyDefaultOutputLanguage: updateMyDefaultOutputLanguage,
        updateMyDefaultListenLanguage: (String? lang) {
          final newPrefs = ListenerTranslationPreferences(
              perSpeaker: listenerTranslationPreferences.perSpeaker,
              globalLanguage: lang);
          updateListenerTranslationPreferences(newPrefs);
        },
        updateListenPreferences: (Map<String, String> prefs) {
          final newPrefs = ListenerTranslationPreferences(
              perSpeaker: prefs,
              globalLanguage: listenerTranslationPreferences.globalLanguage);
          updateListenerTranslationPreferences(newPrefs);
        },
        showSubtitlesOnCards: showSubtitlesOnCards.value,
        updateShowSubtitlesOnCards: updateShowSubtitlesOnCards,
        isPersonalTranslation: isPersonalTranslation.value,
        userVoiceClones: widget.options.userVoiceClones,
      ),
    );
  }
}
