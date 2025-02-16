// lib/methods.dart
library;

export 'package:mediasfu_sdk/methods/utils/initial_values.dart'
    show initialValuesState;
export 'package:mediasfu_sdk/methods/utils/sleep.dart' show sleep;
//import methods for control (samples)
export 'package:mediasfu_sdk/methods/menu_methods/launch_menu_modal.dart'
    show launchMenuModal;
export 'package:mediasfu_sdk/methods/recording_methods/launch_recording.dart'
    show launchRecording;
export 'package:mediasfu_sdk/methods/recording_methods/start_recording.dart'
    show startRecording;
export 'package:mediasfu_sdk/methods/recording_methods/confirm_recording.dart'
    show confirmRecording;
export 'package:mediasfu_sdk/methods/waiting_methods/launch_waiting.dart'
    show launchWaiting;
export 'package:mediasfu_sdk/methods/co_host_methods/launch_co_host.dart'
    show launchCoHost;
export 'package:mediasfu_sdk/methods/media_settings_methods/launch_media_settings.dart'
    show launchMediaSettings;
export 'package:mediasfu_sdk/methods/display_settings_methods/launch_display_settings.dart'
    show launchDisplaySettings;
export 'package:mediasfu_sdk/methods/settings_methods/launch_settings.dart'
    show launchSettings;
export 'package:mediasfu_sdk/methods/requests_methods/launch_requests.dart'
    show launchRequests;
export 'package:mediasfu_sdk/methods/participants_methods/launch_participants.dart'
    show launchParticipants;
export 'package:mediasfu_sdk/methods/message_methods/launch_messages.dart'
    show launchMessages;
export 'package:mediasfu_sdk/methods/exit_methods/launch_confirm_exit.dart'
    show launchConfirmExit;
export 'package:mediasfu_sdk/methods/polls_methods/launch_poll.dart'
    show launchPoll;
export 'package:mediasfu_sdk/methods/breakout_rooms_methods/launch_breakout_rooms.dart'
    show launchBreakoutRooms;
export 'package:mediasfu_sdk/methods/stream_methods/switch_video_alt.dart'
    show switchVideoAlt;
export 'package:mediasfu_sdk/methods/stream_methods/click_video.dart'
    show clickVideo;
export 'package:mediasfu_sdk/methods/stream_methods/click_audio.dart'
    show clickAudio;
export 'package:mediasfu_sdk/methods/stream_methods/click_screen_share.dart'
    show clickScreenShare;
export 'package:mediasfu_sdk/methods/utils/format_number.dart'
    show formatNumber;
export 'package:mediasfu_sdk/consumers/connect_ips.dart' show connectIps;
export 'package:mediasfu_sdk/consumers/connect_local_ips.dart'
    show connectLocalIps;
export 'package:mediasfu_sdk/methods/polls_methods/poll_updated.dart'
    show pollUpdated;
export 'package:mediasfu_sdk/methods/polls_methods/handle_create_poll.dart'
    show handleCreatePoll;
export 'package:mediasfu_sdk/methods/polls_methods/handle_vote_poll.dart'
    show handleVotePoll;
export 'package:mediasfu_sdk/methods/polls_methods/handle_end_poll.dart'
    show handleEndPoll;
export 'package:mediasfu_sdk/methods/breakout_rooms_methods/breakout_room_updated.dart'
    show breakoutRoomUpdated;

export 'package:mediasfu_sdk/methods/utils/meeting_timer/start_meeting_progress_timer.dart'
    show startMeetingProgressTimer;
export 'package:mediasfu_sdk/methods/recording_methods/update_recording.dart'
    show updateRecording;
export 'package:mediasfu_sdk/methods/recording_methods/stop_recording.dart'
    show stopRecording;

// Seed Data for Testing
export 'package:mediasfu_sdk/methods/utils/generate_random_participants.dart'
    show generateRandomParticipants;
export 'package:mediasfu_sdk/methods/utils/generate_random_messages.dart'
    show generateRandomMessages;
export 'package:mediasfu_sdk/methods/utils/generate_random_request_list.dart'
    show generateRandomRequestList;
export 'package:mediasfu_sdk/methods/utils/generate_random_waiting_room_list.dart'
    show generateRandomWaitingRoomList;
export 'package:mediasfu_sdk/methods/utils/generate_random_polls.dart'
    show generateRandomPolls;

//new utils
//export 'package:mediasfu_sdk/methods/utils/create_join_room.dart' show createJoinRoom;
export 'package:mediasfu_sdk/methods/utils/check_limits_and_make_request.dart'
    show checkLimitsAndMakeRequest;
export 'package:mediasfu_sdk/methods/utils/join_room_on_media_sfu.dart'
    show joinRoomOnMediaSFU;
export 'package:mediasfu_sdk/methods/utils/create_room_on_media_sfu.dart'
    show createRoomOnMediaSFU;
