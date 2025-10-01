// ignore_for_file: non_constant_identifier_names
import 'package:flutter_webrtc/flutter_webrtc.dart' as flutter_webrtc;

import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../producers/socket_receive_methods/room_record_params.dart';
import 'package:socket_io_client/socket_io_client.dart';

export '../consumers/socket_receive_methods/join_consume_room.dart';
export '../consumers/socket_receive_methods/producer_closed.dart';
export '../consumers/socket_receive_methods/new_pipe_producer.dart';

// //consumers
export '../consumers/add_videos_grid.dart';
export '../consumers/auto_adjust.dart';
export '../consumers/calculate_rows_and_columns.dart';
export '../consumers/change_vids.dart';
export '../consumers/check_grid.dart';
export '../consumers/check_permission.dart';
export '../consumers/check_screen_share.dart';
export '../consumers/close_and_resize.dart';
export '../consumers/compare_active_names.dart';
export '../consumers/compare_screen_states.dart';
export '../consumers/connect_ips.dart';
export '../consumers/connect_local_ips.dart';
export '../consumers/connect_recv_transport.dart';
export '../consumers/connect_send_transport.dart';
export '../consumers/connect_send_transport_audio.dart';
export '../consumers/connect_send_transport_screen.dart';
export '../consumers/connect_send_transport_video.dart';
export '../consumers/consumer_resume.dart';
export '../consumers/control_media.dart';
export '../consumers/create_send_transport.dart';
export '../consumers/disconnect_send_transport_audio.dart';
export '../consumers/disconnect_send_transport_video.dart';
export '../consumers/disconnect_send_transport_screen.dart';
export '../consumers/disp_streams.dart';
export '../consumers/generate_page_content.dart';
export '../consumers/get_estimate.dart';
export '../consumers/get_piped_producers_alt.dart';
export '../consumers/get_producers_piped.dart';
export '../consumers/get_videos.dart';
export '../consumers/mix_streams.dart';
export '../consumers/on_screen_changes.dart';
export '../consumers/prepopulate_user_media.dart';
export '../consumers/process_consumer_transports.dart';
export '../consumers/process_consumer_transports_audio.dart';
export '../consumers/readjust.dart';
export '../consumers/receive_all_piped_transports.dart';
export '../consumers/reorder_streams.dart';
export '../consumers/re_port.dart';
export '../consumers/request_screen_share.dart';
export '../consumers/resume_pause_audio_streams.dart';
export '../consumers/resume_pause_streams.dart';
export '../consumers/resume_send_transport_audio.dart';
export '../consumers/re_update_inter.dart';
export '../consumers/signal_new_consumer_transport.dart';
export '../consumers/start_share_screen.dart';
export '../consumers/stop_share_screen.dart';
export '../consumers/stream_success_audio.dart';
export '../consumers/stream_success_audio_switch.dart';
export '../consumers/stream_success_screen.dart';
export '../consumers/stream_success_video.dart';
export '../consumers/switch_user_audio.dart';
export '../consumers/switch_user_video.dart';
export '../consumers/switch_user_video_alt.dart';
export '../consumers/trigger.dart';
export '../consumers/update_mini_cards_grid.dart';
export '../consumers/update_participant_audio_decibels.dart';

// Methods Utils

// Breakout Rooms Methods
export '../methods/breakout_rooms_methods/launch_breakout_rooms.dart';
export '../methods/breakout_rooms_methods/breakout_room_updated.dart';

// Co-Host Methods
export '../methods/co_host_methods/launch_co_host.dart';
export '../methods/co_host_methods/modify_co_host_settings.dart';

// Display Settings Methods
export '../methods/display_settings_methods/launch_display_settings.dart';
export '../methods/display_settings_methods/modify_display_settings.dart';

// Exit Methods
export '../methods/exit_methods/launch_confirm_exit.dart';
export '../methods/exit_methods/confirm_exit.dart';

// Media Settings Methods
export '../methods/media_settings_methods/launch_media_settings.dart';

// Menu Methods
export '../methods/menu_methods/launch_menu_modal.dart';

// Message Methods
export '../methods/message_methods/launch_messages.dart';
export '../methods/message_methods/send_message.dart';

// Participants Methods
export '../methods/participants_methods/launch_participants.dart';
export '../methods/participants_methods/message_participants.dart';
export '../methods/participants_methods/mute_participants.dart';
export '../methods/participants_methods/remove_participants.dart';

// Polls Methods
export '../methods/polls_methods/handle_create_poll.dart';
export '../methods/polls_methods/handle_end_poll.dart';
export '../methods/polls_methods/handle_vote_poll.dart';
export '../methods/polls_methods/launch_poll.dart';
export '../methods/polls_methods/poll_updated.dart';

// Recording Methods
export '../methods/recording_methods/check_pause_state.dart';
export '../methods/recording_methods/check_resume_state.dart';
export '../methods/recording_methods/confirm_recording.dart';
export '../methods/recording_methods/launch_recording.dart';
export '../methods/recording_methods/record_pause_timer.dart';
export '../methods/recording_methods/record_resume_timer.dart';
export '../methods/recording_methods/record_start_timer.dart';
export '../methods/recording_methods/record_update_timer.dart';
export '../methods/recording_methods/start_recording.dart';
export '../methods/recording_methods/stop_recording.dart'
    hide UpdateBooleanState;
export '../methods/recording_methods/update_recording.dart'
    hide UpdateBooleanState;

// Requests Methods
export '../methods/requests_methods/launch_requests.dart';
export '../methods/requests_methods/respond_to_requests.dart';

// Settings Methods
export '../methods/settings_methods/launch_settings.dart';
export '../methods/settings_methods/modify_settings.dart'
    hide UpdateIsSettingsModalVisible;

// Stream Methods
export '../methods/stream_methods/click_audio.dart';
export '../methods/stream_methods/click_chat.dart';
export '../methods/stream_methods/click_screen_share.dart';
export '../methods/stream_methods/click_video.dart';
export '../methods/stream_methods/switch_audio.dart';
export '../methods/stream_methods/switch_video.dart';
export '../methods/stream_methods/switch_video_alt.dart';

// Meeting Timer Utils
export '../methods/utils/meeting_timer/start_meeting_progress_timer.dart';

// Mini Audio Player Utils
export '../methods/utils/mini_audio_player/mini_audio_player.dart';

// Other Utils
export '../methods/utils/format_number.dart';
export '../methods/utils/get_media_devices_list.dart';
export '../methods/utils/get_participant_media.dart';
export '../methods/utils/generate_random_messages.dart';
export '../methods/utils/generate_random_participants.dart';
export '../methods/utils/generate_random_polls.dart';
export '../methods/utils/generate_random_request_list.dart';
export '../methods/utils/generate_random_waiting_room_list.dart';
export '../methods/utils/get_modal_position.dart';
export '../methods/utils/get_overlay_position.dart';
export '../methods/utils/sleep.dart';
export '../methods/utils/validate_alphanumeric.dart';

// Waiting Methods
export '../methods/waiting_methods/launch_waiting.dart';
export '../methods/waiting_methods/respond_to_waiting.dart';

// Producer Client Emits
export '../producer_client/producer_client_emits/create_device_client.dart';
export '../producer_client/producer_client_emits/join_room_client.dart';
export '../producer_client/producer_client_emits/update_room_parameters_client.dart'
    hide
        UpdateItemPageLimit,
        UpdateAddForBasic,
        UpdateMeetingDisplayType,
        UpdateMainHeightWidth;

// Producers Emits
export '../producers/producer_emits/join_con_room.dart'
    hide validateAlphanumeric;
export '../producers/producer_emits/join_room.dart';

// Producers Socket Receive Methods
export '../producers/socket_receive_methods/all_members.dart'
    hide UpdateParticipants, UpdateParticipantsAll;
export '../producers/socket_receive_methods/all_members_rest.dart'
    hide
        UpdateParticipants,
        UpdateParticipantsAll,
        UpdateBoolean,
        UpdateCoHost,
        UpdateRequestList,
        UpdateIPs,
        UpdateCoHostResponsibility,
        UpdateSetting,
        UpdateSockets;
export '../producers/socket_receive_methods/all_waiting_room_members.dart';
export '../producers/socket_receive_methods/ban_participant.dart';
export '../producers/socket_receive_methods/control_media_host.dart';
export '../producers/socket_receive_methods/disconnect.dart';
export '../producers/socket_receive_methods/disconnect_user_self.dart';
export '../producers/socket_receive_methods/get_domains.dart';
export '../producers/socket_receive_methods/host_request_response.dart';
export '../producers/socket_receive_methods/meeting_ended.dart';
export '../producers/socket_receive_methods/meeting_still_there.dart';
export '../producers/socket_receive_methods/meeting_time_remaining.dart';
export '../producers/socket_receive_methods/participant_requested.dart';
export '../producers/socket_receive_methods/person_joined.dart';
export '../producers/socket_receive_methods/producer_media_closed.dart';
export '../producers/socket_receive_methods/producer_media_paused.dart';
export '../producers/socket_receive_methods/producer_media_resumed.dart';
export '../producers/socket_receive_methods/re_initiate_recording.dart';
export '../producers/socket_receive_methods/receive_message.dart';
export '../producers/socket_receive_methods/recording_notice.dart';
export '../producers/socket_receive_methods/room_record_params.dart';
export '../producers/socket_receive_methods/screen_producer_id.dart';
export '../producers/socket_receive_methods/start_records.dart';
export '../producers/socket_receive_methods/stopped_recording.dart';
export '../producers/socket_receive_methods/time_left_recording.dart';
export '../producers/socket_receive_methods/update_consuming_domains.dart';
export '../producers/socket_receive_methods/update_media_settings.dart';
export '../producers/socket_receive_methods/updated_co_host.dart';
export '../producers/socket_receive_methods/user_waiting.dart';
export '../sockets/socket_manager.dart';

// Components
export '../components/breakout_components/breakout_rooms_modal.dart';
export '../components/co_host_components/co_host_modal.dart';
export '../components/display_components/alert_component.dart';
export '../components/display_components/audio_card.dart';
export '../components/display_components/audio_grid.dart';
export '../components/display_components/card_video_display.dart';
export '../components/display_components/control_buttons_component.dart';
export '../components/display_components/control_buttons_alt_component.dart';
export '../components/display_components/control_buttons_component_touch.dart';
export '../components/display_components/flexible_grid.dart';
export '../components/display_components/flexible_video.dart';
export '../components/display_components/loading_modal.dart';
export '../components/display_components/main_aspect_component.dart';
export '../components/display_components/main_container_component.dart';
export '../components/display_components/main_grid_component.dart';
export '../components/display_components/main_screen_component.dart';
export '../components/display_components/meeting_progress_timer.dart';
export '../components/display_components/mini_audio.dart';
export '../components/display_components/mini_card.dart';
export '../components/display_components/other_grid_component.dart';
export '../components/display_components/pagination.dart';
export '../components/display_components/sub_aspect_component.dart';
export '../components/display_components/video_card.dart';
export '../components/display_settings_components/display_settings_modal.dart';
export '../components/event_settings_components/event_settings_modal.dart';
export '../components/exit_components/confirm_exit_modal.dart';
export '../components/media_settings_components/media_settings_modal.dart';
export '../components/menu_components/menu_modal.dart';
export '../components/message_components/messages_modal.dart';
export '../components/misc_components/confirm_here_modal.dart';
export '../components/misc_components/prejoin_page.dart';
export '../components/misc_components/share_event_modal.dart';
export '../components/misc_components/welcome_page.dart';
export '../components/participants_components/participants_modal.dart';
export '../components/polls_components/poll_modal.dart';
export '../components/recording_components/recording_modal.dart';
export '../components/requests_components/requests_modal.dart';
export '../components/waiting_components/waiting_modal.dart';
export '../components/menu_components/custom_buttons.dart';

//mediasfu components
export '../components/mediasfu_components/mediasfu_conference.dart';
export '../components/mediasfu_components/mediasfu_broadcast.dart';
export '../components/mediasfu_components/mediasfu_chat.dart';
export '../components/mediasfu_components/mediasfu_generic.dart';
export '../components/mediasfu_components/mediasfu_webinar.dart';

export '../methods/utils/create_join_room.dart';
export '../methods/utils/check_limits_and_make_request.dart';
export '../methods/utils/join_room_on_media_sfu.dart';
export '../methods/utils/create_room_on_media_sfu.dart';

export '../methods/utils/mediasfu_parameters.dart';

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

class Participant {
  String? id;
  String audioID;
  String videoID;
  String? ScreenID;
  bool? ScreenOn;
  String? islevel;
  bool? isAdmin;
  bool? isHost; // support for Community Edition
  String name;
  bool? muted;
  bool? isBanned;
  bool? isSuspended;
  bool? useBoard;
  int? breakRoom;
  bool? videoOn;
  bool? audioOn;
  // Map to hold dynamic properties
  final Map<String, dynamic> _extraProperties = {};

  Participant({
    this.id,
    required this.audioID,
    required this.videoID,
    this.ScreenID,
    this.ScreenOn,
    this.islevel,
    this.isAdmin,
    this.isHost,
    required this.name,
    this.muted,
    this.isBanned,
    this.isSuspended,
    this.useBoard,
    this.breakRoom,
    this.videoOn,
    this.audioOn,
  });

  // Operator to access properties like a dictionary
  dynamic operator [](String key) => _extraProperties[key];
  void operator []=(String key, dynamic value) => _extraProperties[key] = value;

  // Factory constructor to create an instance from a Map
  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      id: map['id'] as String?,
      audioID: map['audioID'] as String,
      videoID: map['videoID'] as String,
      ScreenID: map['ScreenID'] as String?,
      ScreenOn: map['ScreenOn'] as bool?,
      islevel: map['islevel'] as String?,
      isAdmin: map['isAdmin'] != null ? map['isAdmin'] as bool? : false,
      isHost: map['isHost'] as bool?,
      name: map['name'] as String,
      muted: map['muted'] as bool?,
      isBanned: map['isBanned'] as bool?,
      isSuspended:
          map['isSuspended'] != null ? map['isSuspended'] as bool? : false,
      useBoard: map['useBoard'] as bool?,
      breakRoom: map['breakRoom'] as int?,
      videoOn: map['videoOn'] as bool?,
      audioOn: map['audioOn'] as bool?,
    ).._extraProperties.addAll(
        map
          ..removeWhere((key, _) => [
                'id',
                'audioID',
                'videoID',
                'ScreenID',
                'ScreenOn',
                'islevel',
                'isAdmin',
                'isHost',
                'name',
                'muted',
                'isBanned',
                'isSuspended',
                'useBoard',
                'breakRoom',
                'videoOn',
                'audioOn'
              ].contains(key)),
      );
  }

  // Convert Participant to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'audioID': audioID,
      'videoID': videoID,
      'ScreenID': ScreenID,
      'ScreenOn': ScreenOn,
      'islevel': islevel,
      'isAdmin': isAdmin,
      'isHost': isHost,
      'name': name,
      'muted': muted,
      'isBanned': isBanned,
      'isSuspended': isSuspended,
      'useBoard': useBoard,
      'breakRoom': breakRoom,
      'videoOn': videoOn,
      'audioOn': audioOn,
      ..._extraProperties,
    };
  }
}

class Stream {
  String? id;
  final String producerId;
  bool? muted;
  MediaStream? stream;
  Socket? socket_;
  String? name;
  String? audioID;
  String? videoID;
  final Map<String, dynamic> _extraProperties = {};

  Stream({
    this.id,
    required this.producerId,
    this.muted,
    this.stream,
    this.socket_,
    this.name,
    this.audioID,
    this.videoID,
  });

  dynamic operator [](String key) => _extraProperties[key];
  void operator []=(String key, dynamic value) => _extraProperties[key] = value;

  // Factory constructor to create an instance from a Map
  factory Stream.fromMap(Map<String, dynamic> map) {
    return Stream(
      id: map['id'] as String?,
      producerId: map['producerId'] as String? ?? '',
      muted: map['muted'] as bool?,
      stream: map['stream']
          as MediaStream?, // Ensure correct type or handle if conversion is needed
      socket_: map['socket_']
          as Socket?, // Ensure correct type or handle if conversion is needed
      name: map['name'] as String?,
      audioID: map['audioID'] as String?,
      videoID: map['videoID'] as String?,
    ).._extraProperties.addAll(map);
  }

  // Convert Stream to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producerId': producerId,
      'muted': muted,
      'stream': stream,
      'socket_': socket_,
      'name': name,
      'audioID': audioID,
      'videoID': videoID,
      ..._extraProperties,
    };
  }

  // Check if a key exists in either predefined properties or _extraProperties
  bool containsKey(String key) {
    const predefinedKeys = [
      'id',
      'producerId',
      'muted',
      'stream',
      'socket_',
      'name',
      'audioID',
      'videoID'
    ];

    return predefinedKeys.contains(key) || _extraProperties.containsKey(key);
  }
}

class Request {
  final String id;
  final String icon;
  String? name;
  String? username;
  final Map<String, dynamic> _extraProperties = {};

  Request({
    required this.id,
    required this.icon,
    this.name,
    this.username,
  });

  dynamic operator [](String key) => _extraProperties[key];
  void operator []=(String key, dynamic value) => _extraProperties[key] = value;

  // Factory constructor to create an instance from a Map
  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
      id: map['id'] as String,
      icon: map['icon'] as String,
      name: map['name'] as String?,
      username: map['username'] as String?,
    ).._extraProperties.addAll(map);
  }

  // Convert Request to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'icon': icon,
      'name': name,
      'username': username,
      ..._extraProperties,
    };
  }
}

class RequestResponse {
  final String id;
  String? icon;
  String? name;
  String? username;
  String? action;
  String? type;
  // Map to hold dynamic properties
  final Map<String, dynamic> _extraProperties = {};

  RequestResponse({
    required this.id,
    this.icon,
    this.name,
    this.username,
    this.action,
    this.type,
  });

  // Operator to access properties like a dictionary
  dynamic operator [](String key) => _extraProperties[key];
  void operator []=(String key, dynamic value) => _extraProperties[key] = value;

  // Factory constructor to create an instance from a Map
  factory RequestResponse.fromMap(Map<String, dynamic> map) {
    return RequestResponse(
      id: map['id'] as String,
      icon: map['icon'] as String?,
      name: map['name'] as String?,
      username: map['username'] as String?,
      action: map['action'] as String?,
      type: map['type'] as String?,
    ).._extraProperties.addAll(map);
  }

  // Convert RequestResponse to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'icon': icon,
      'name': name,
      'username': username,
      'action': action,
      'type': type,
      ..._extraProperties,
    };
  }
}

class TransportType {
  final String producerId;
  final Consumer consumer;
  final Socket socket_;
  final String serverConsumerTransportId;
  final Transport consumerTransport;
  // Map to hold dynamic properties
  final Map<String, dynamic> _extraProperties = {};

  TransportType({
    required this.producerId,
    required this.consumer,
    required this.socket_,
    required this.serverConsumerTransportId,
    required this.consumerTransport,
  });

  // Operator to access properties like a dictionary
  dynamic operator [](String key) => _extraProperties[key];
  void operator []=(String key, dynamic value) => _extraProperties[key] = value;

  // Factory constructor to create an instance from a Map
  factory TransportType.fromMap(Map<String, dynamic> map) {
    return TransportType(
      producerId: map['producerId'] as String,
      consumer:
          map['consumer'] as Consumer, // Ensure Consumer parsing if needed
      socket_: map['socket_'] as Socket, // Ensure Socket parsing if needed
      serverConsumerTransportId: map['serverConsumerTransportId'] as String,
      consumerTransport: map['consumerTransport']
          as Transport, // Ensure Transport parsing if needed
    ).._extraProperties.addAll(map);
  }

  // Convert TransportType to a Map
  Map<String, dynamic> toMap() {
    return {
      'producerId': producerId,
      'consumer': consumer,
      'socket_': socket_,
      'serverConsumerTransportId': serverConsumerTransportId,
      'consumerTransport': consumerTransport,
      ..._extraProperties,
    };
  }
}

class ScreenState {
  String? mainScreenPerson;
  String? mainScreenProducerId;
  final bool mainScreenFilled;
  final bool adminOnMainScreen;

  ScreenState({
    this.mainScreenPerson,
    this.mainScreenProducerId,
    required this.mainScreenFilled,
    required this.adminOnMainScreen,
  });

  // Factory constructor to create an instance from a Map
  factory ScreenState.fromMap(Map<String, dynamic> map) {
    return ScreenState(
      mainScreenPerson: map['mainScreenPerson'] as String?,
      mainScreenProducerId: map['mainScreenProducerId'] as String?,
      mainScreenFilled: map['mainScreenFilled'] as bool,
      adminOnMainScreen: map['adminOnMainScreen'] as bool,
    );
  }

  // Convert ScreenState to a Map
  Map<String, dynamic> toMap() {
    return {
      'mainScreenPerson': mainScreenPerson,
      'mainScreenProducerId': mainScreenProducerId,
      'mainScreenFilled': mainScreenFilled,
      'adminOnMainScreen': adminOnMainScreen,
    };
  }
}

class GridSizes {
  int? gridWidth;
  int? gridHeight;
  int? altGridWidth;
  int? altGridHeight;

  GridSizes({
    this.gridWidth,
    this.gridHeight,
    this.altGridWidth,
    this.altGridHeight,
  });

  // Factory constructor to create GridSizes from a map
  factory GridSizes.fromMap(Map<String, int?> map) {
    return GridSizes(
      gridWidth: map['gridWidth'],
      gridHeight: map['gridHeight'],
      altGridWidth: map['altGridWidth'],
      altGridHeight: map['altGridHeight'],
    );
  }

  // Convert GridSizes to a Map
  Map<String, int?> toMap() {
    return {
      'gridWidth': gridWidth,
      'gridHeight': gridHeight,
      'altGridWidth': altGridWidth,
      'altGridHeight': altGridHeight,
    };
  }
}

class ComponentSizes {
  final double mainWidth;
  final double mainHeight;
  final double otherWidth;
  final double otherHeight;

  ComponentSizes({
    required this.mainWidth,
    required this.mainHeight,
    required this.otherWidth,
    required this.otherHeight,
  });

  // Factory constructor to create ComponentSizes from a map
  factory ComponentSizes.fromMap(Map<String, double> map) {
    return ComponentSizes(
      mainWidth: map['mainWidth']!,
      mainHeight: map['mainHeight']!,
      otherWidth: map['otherWidth']!,
      otherHeight: map['otherHeight']!,
    );
  }

  // Convert ComponentSizes to a Map
  Map<String, double> toMap() {
    return {
      'mainWidth': mainWidth,
      'mainHeight': mainHeight,
      'otherWidth': otherWidth,
      'otherHeight': otherHeight,
    };
  }
}

class AudioDecibels {
  final String name;
  double averageLoudness;

  AudioDecibels({
    required this.name,
    required this.averageLoudness,
  });
}

class ShowAlertOptions {
  final String message;
  final String type; // 'success' or 'danger'
  int? duration;

  ShowAlertOptions({
    required this.message,
    required this.type,
    this.duration,
  });

  // Factory constructor to create ShowAlertOptions from a map
  factory ShowAlertOptions.fromMap(Map<String, dynamic> map) {
    return ShowAlertOptions(
      message: map['message'] as String,
      type: map['type'] as String,
      duration: map['duration'] as int?,
    );
  }

  // Convert ShowAlertOptions to a Map
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'type': type,
      'duration': duration,
    };
  }
}

class CoHostResponsibility {
  final String name;
  bool value;
  bool dedicated;

  CoHostResponsibility({
    required this.name,
    required this.value,
    required this.dedicated,
  });

  // Factory constructor to create CoHostResponsibility from a map
  factory CoHostResponsibility.fromMap(Map<String, dynamic> map) {
    return CoHostResponsibility(
      name: map['name'] as String,
      value: map['value'] as bool,
      dedicated: map['dedicated'] as bool,
    );
  }

  // Convert CoHostResponsibility to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'dedicated': dedicated,
    };
  }
}

class DimensionConstraints {
  int? ideal;
  int? max;
  int? min;

  DimensionConstraints({this.ideal, this.max, this.min});

  // Factory constructor to create DimensionConstraints from an integer or a map
  factory DimensionConstraints.from(dynamic value) {
    if (value is int) {
      return DimensionConstraints(
          ideal: value); // If it's a number, use it as `ideal`
    } else if (value is Map<String, int?>) {
      return DimensionConstraints(
        ideal: value['ideal'],
        max: value['max'],
        min: value['min'],
      );
    }
    throw ArgumentError('Invalid value for DimensionConstraints');
  }

  // Convert DimensionConstraints to a Map
  Map<String, int?> toMap() {
    return {
      'ideal': ideal,
      'max': max,
      'min': min,
    };
  }
}

class VidCons {
  DimensionConstraints width;
  DimensionConstraints height;

  VidCons({required this.width, required this.height});

  factory VidCons.fromMap(Map<String, dynamic> map) {
    return VidCons(
      width: DimensionConstraints.from(map['width']),
      height: DimensionConstraints.from(map['height']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'width': width.toMap(),
      'height': height.toMap(),
    };
  }
}

class Settings {
  List<String> settings;

  Settings({
    required this.settings,
  });

  // Factory constructor to create Settings from a map
  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      settings: List<String>.from(map['settings'] as List),
    );
  }

  // Create Settings from a list of strings
  factory Settings.fromList(List<dynamic> list) {
    return Settings(
      settings: List<String>.from(list),
    );
  }

  // Convert Settings to a Map
  Map<String, dynamic> toMap() {
    return {
      'settings': settings,
    };
  }
}

class Message {
  final String sender;
  final List<String> receivers;
  final String message;
  final String timestamp;
  final bool group;

  Message({
    required this.sender,
    required this.receivers,
    required this.message,
    required this.timestamp,
    required this.group,
  });

  // Factory constructor to create an instance from a Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      sender: map['sender'] != null ? map['sender'] as String : '',
      receivers: map['receivers'] != null &&
              map['receivers'] is List &&
              map['receivers'].isNotEmpty &&
              map['receivers'][0] != null
          ? List<String>.from(map['receivers'] as List)
          : [],
      message: map['message'] as String,
      timestamp: map['timestamp'] as String,
      group: map['group'] as bool,
    );
  }

  // Convert Message to a Map
  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'receivers': receivers,
      'message': message,
      'timestamp': timestamp,
      'group': group,
    };
  }
}

class MainSpecs {
  final String mediaOptions;
  final String audioOptions;
  final String videoOptions;
  final String videoType;
  final bool videoOptimized;
  final String recordingDisplayType; // 'video' | 'media' | 'all'
  final bool addHLS;

  MainSpecs({
    required this.mediaOptions,
    required this.audioOptions,
    required this.videoOptions,
    required this.videoType,
    required this.videoOptimized,
    required this.recordingDisplayType,
    required this.addHLS,
  });

  // Factory constructor to create an instance from a Map
  factory MainSpecs.fromMap(Map<String, dynamic> map) {
    return MainSpecs(
      mediaOptions: map['mediaOptions'] as String,
      audioOptions: map['audioOptions'] as String,
      videoOptions: map['videoOptions'] as String,
      videoType: map['videoType'] as String,
      videoOptimized: map['videoOptimized'] as bool,
      recordingDisplayType: map['recordingDisplayType'] as String,
      addHLS: map['addHLS'] as bool,
    );
  }

  // Convert MainSpecs to a Map
  Map<String, dynamic> toMap() {
    return {
      'mediaOptions': mediaOptions,
      'audioOptions': audioOptions,
      'videoOptions': videoOptions,
      'videoType': videoType,
      'videoOptimized': videoOptimized,
      'recordingDisplayType': recordingDisplayType,
      'addHLS': addHLS,
    };
  }
}

class DispSpecs {
  final bool nameTags;
  final String backgroundColor;
  final String nameTagsColor;
  final String orientationVideo;

  DispSpecs({
    required this.nameTags,
    required this.backgroundColor,
    required this.nameTagsColor,
    required this.orientationVideo,
  });

  // Factory constructor to create an instance from a Map
  factory DispSpecs.fromMap(Map<String, dynamic> map) {
    return DispSpecs(
      nameTags: map['nameTags'] as bool,
      backgroundColor: map['backgroundColor'] as String,
      nameTagsColor: map['nameTagsColor'] as String,
      orientationVideo: map['orientationVideo'] as String,
    );
  }

  // Convert DispSpecs to a Map
  Map<String, dynamic> toMap() {
    return {
      'nameTags': nameTags,
      'backgroundColor': backgroundColor,
      'nameTagsColor': nameTagsColor,
      'orientationVideo': orientationVideo,
    };
  }
}

class TextSpecs {
  final bool addText;
  String? customText;
  String? customTextPosition;
  String? customTextColor;

  TextSpecs({
    required this.addText,
    this.customText,
    this.customTextPosition,
    this.customTextColor,
  });

  // Factory constructor to create an instance from a Map
  factory TextSpecs.fromMap(Map<String, dynamic> map) {
    return TextSpecs(
      addText: map['addText'] as bool,
      customText: map['customText'] as String?,
      customTextPosition: map['customTextPosition'] as String?,
      customTextColor: map['customTextColor'] as String?,
    );
  }

  // Convert TextSpecs to a Map
  Map<String, dynamic> toMap() {
    return {
      'addText': addText,
      'customText': customText,
      'customTextPosition': customTextPosition,
      'customTextColor': customTextColor,
    };
  }
}

class UserRecordingParams {
  final MainSpecs mainSpecs;
  final DispSpecs dispSpecs;
  TextSpecs? textSpecs;

  UserRecordingParams({
    required this.mainSpecs,
    required this.dispSpecs,
    this.textSpecs,
  });

  // Factory constructor to create an instance from a Map
  factory UserRecordingParams.fromMap(Map<String, dynamic> map) {
    return UserRecordingParams(
      mainSpecs: MainSpecs.fromMap(map['mainSpecs']),
      dispSpecs: DispSpecs.fromMap(map['dispSpecs']),
      textSpecs:
          map['textSpecs'] != null ? TextSpecs.fromMap(map['textSpecs']) : null,
    );
  }

  // Convert UserRecordingParams to a Map
  Map<String, dynamic> toMap() {
    return {
      'mainSpecs': mainSpecs.toMap(),
      'dispSpecs': dispSpecs.toMap(),
      'textSpecs': textSpecs?.toMap(),
    };
  }
}

class AltDomains {
  Map<String, String> altDomains;

  AltDomains({
    required this.altDomains,
  });

  // Factory constructor to create an instance from a Map
  factory AltDomains.fromMap(Map<String, String> map) {
    return AltDomains(
      altDomains: map,
    );
  }

  // Convert AltDomains to a Map
  Map<String, String> toMap() {
    return altDomains;
  }
}

typedef RequestPermissionAudioType = Future<bool> Function();
typedef RequestPermissionCameraType = Future<bool> Function();

enum ControlsPosition { topLeft, topRight, bottomLeft, bottomRight }

enum InfoPosition { topLeft, topRight, bottomLeft, bottomRight }

class Poll {
  String? id;
  String question;
  String? type;
  List<String> options;
  List<int>? votes;
  String? status;
  Map<String, int>? voters;

  Poll({
    this.id,
    required this.question,
    this.type,
    required this.options,
    this.votes,
    this.status,
    this.voters,
  });

  // Factory constructor to create an instance from a Map
  factory Poll.fromMap(Map<String, dynamic> map) {
    return Poll(
      id: map['id'] != null ? map['id'] as String : '',
      question: map['question'] as String,
      type: map['type'] as String,
      options: List<String>.from(map['options'] as List),
      votes: map['votes'] == null
          ? []
          : (map['votes'] as List)
              .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
              .toList(),
      status: map['status'] != null ? map['status'] as String : 'inactive',
      voters: map['voters'] == null
          ? {}
          : Map<String, int>.fromEntries(
              (map['voters'] as Map).entries.map((e) {
                final key = e.key.toString();
                final value = e.value is int
                    ? e.value
                    : int.tryParse(e.value.toString()) ?? 0;
                return MapEntry(key, value);
              }),
            ),
    );
  }

  // Convert Poll to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'type': type,
      'options': options,
      'votes': votes,
      'status': status,
      'voters': voters,
    };
  }
}

class WaitingRoomParticipant {
  final String name;
  final String id;

  WaitingRoomParticipant({
    required this.name,
    required this.id,
  });

  // Factory constructor to create an instance from a Map
  factory WaitingRoomParticipant.fromMap(Map<String, dynamic> map) {
    return WaitingRoomParticipant(
      name: map['name'] as String,
      id: map['id'] as String,
    );
  }

  // Convert WaitingRoomParticipant to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
    };
  }
}

class RecordParameters extends RecordParams {
  final int recordingAudioPausesLimit;
  final int recordingAudioPausesCount;
  final bool recordingAudioSupport;
  final int recordingAudioPeopleLimit;
  final int recordingAudioParticipantsTimeLimit;
  final int recordingVideoPausesCount;
  final int recordingVideoPausesLimit;
  final bool recordingVideoSupport;
  final int recordingVideoPeopleLimit;
  final int recordingVideoParticipantsTimeLimit;
  final bool recordingAllParticipantsSupport;
  final bool recordingVideoParticipantsSupport;
  final bool recordingAllParticipantsFullRoomSupport;
  final bool recordingVideoParticipantsFullRoomSupport;
  final String recordingPreferredOrientation;
  final bool recordingSupportForOtherOrientation;
  final bool recordingMultiFormatsSupport;

  RecordParameters({
    required this.recordingAudioPausesLimit,
    required this.recordingAudioPausesCount,
    required this.recordingAudioSupport,
    required this.recordingAudioPeopleLimit,
    required this.recordingAudioParticipantsTimeLimit,
    required this.recordingVideoPausesCount,
    required this.recordingVideoPausesLimit,
    required this.recordingVideoSupport,
    required this.recordingVideoPeopleLimit,
    required this.recordingVideoParticipantsTimeLimit,
    required this.recordingAllParticipantsSupport,
    required this.recordingVideoParticipantsSupport,
    required this.recordingAllParticipantsFullRoomSupport,
    required this.recordingVideoParticipantsFullRoomSupport,
    required this.recordingPreferredOrientation,
    required this.recordingSupportForOtherOrientation,
    required this.recordingMultiFormatsSupport,
  });

  /// Converts an instance of RecordParameters to a Map.
  Map<String, dynamic> toMap() {
    return {
      'recordingAudioPausesLimit': recordingAudioPausesLimit,
      'recordingAudioPausesCount': recordingAudioPausesCount,
      'recordingAudioSupport': recordingAudioSupport,
      'recordingAudioPeopleLimit': recordingAudioPeopleLimit,
      'recordingAudioParticipantsTimeLimit':
          recordingAudioParticipantsTimeLimit,
      'recordingVideoPausesCount': recordingVideoPausesCount,
      'recordingVideoPausesLimit': recordingVideoPausesLimit,
      'recordingVideoSupport': recordingVideoSupport,
      'recordingVideoPeopleLimit': recordingVideoPeopleLimit,
      'recordingVideoParticipantsTimeLimit':
          recordingVideoParticipantsTimeLimit,
      'recordingAllParticipantsSupport': recordingAllParticipantsSupport,
      'recordingVideoParticipantsSupport': recordingVideoParticipantsSupport,
      'recordingAllParticipantsFullRoomSupport':
          recordingAllParticipantsFullRoomSupport,
      'recordingVideoParticipantsFullRoomSupport':
          recordingVideoParticipantsFullRoomSupport,
      'recordingPreferredOrientation': recordingPreferredOrientation,
      'recordingSupportForOtherOrientation':
          recordingSupportForOtherOrientation,
      'recordingMultiFormatsSupport': recordingMultiFormatsSupport,
    };
  }

  /// Creates an instance of RecordParameters from a Map.
  factory RecordParameters.fromMap(Map<String, dynamic> map) {
    return RecordParameters(
      recordingAudioPausesLimit: map['recordingAudioPausesLimit'] as int,
      recordingAudioPausesCount: map['recordingAudioPausesCount'] as int,
      recordingAudioSupport: map['recordingAudioSupport'] as bool,
      recordingAudioPeopleLimit: map['recordingAudioPeopleLimit'] as int,
      recordingAudioParticipantsTimeLimit:
          map['recordingAudioParticipantsTimeLimit'] as int,
      recordingVideoPausesCount: map['recordingVideoPausesCount'] as int,
      recordingVideoPausesLimit: map['recordingVideoPausesLimit'] as int,
      recordingVideoSupport: map['recordingVideoSupport'] as bool,
      recordingVideoPeopleLimit: map['recordingVideoPeopleLimit'] as int,
      recordingVideoParticipantsTimeLimit:
          map['recordingVideoParticipantsTimeLimit'] as int,
      recordingAllParticipantsSupport:
          map['recordingAllParticipantsSupport'] as bool,
      recordingVideoParticipantsSupport:
          map['recordingVideoParticipantsSupport'] as bool,
      recordingAllParticipantsFullRoomSupport:
          map['recordingAllParticipantsFullRoomSupport'] as bool,
      recordingVideoParticipantsFullRoomSupport:
          map['recordingVideoParticipantsFullRoomSupport'] as bool,
      recordingPreferredOrientation:
          map['recordingPreferredOrientation'] as String,
      recordingSupportForOtherOrientation:
          map['recordingSupportForOtherOrientation'] as bool,
      recordingMultiFormatsSupport: map['recordingMultiFormatsSupport'] as bool,
    );
  }
}

class ModalPositionStyle {
  final String justifyContent;
  final String alignItems;

  ModalPositionStyle({
    required this.justifyContent,
    required this.alignItems,
  });
}

class OverlayPositionStyle {
  double? top;
  double? left;
  double? right;
  double? bottom;

  OverlayPositionStyle({
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  // Factory constructor to create an instance from a Map
  factory OverlayPositionStyle.fromMap(Map<String, double?> map) {
    return OverlayPositionStyle(
      top: map['top'],
      left: map['left'],
      right: map['right'],
      bottom: map['bottom'],
    );
  }

  // Convert OverlayPositionStyle to a Map
  Map<String, double?> toMap() {
    return {
      'top': top,
      'left': left,
      'right': right,
      'bottom': bottom,
    };
  }
}

enum EventType { conference, webinar, chat, broadcast, none }

class PollUpdatedData {
  List<Poll>? polls;
  final Poll poll;
  final String status;

  PollUpdatedData({
    this.polls,
    required this.poll,
    required this.status,
  });

  // Factory constructor to create an instance from a Map
  factory PollUpdatedData.fromMap(Map<String, dynamic> map) {
    return PollUpdatedData(
      polls: map['polls'] != null
          ? List<Poll>.from((map['polls'] as List).map((x) => Poll.fromMap(x)))
          : null,
      poll: Poll.fromMap(map['poll']),
      status: map['status'] as String,
    );
  }

  // Convert PollUpdatedData to a Map
  Map<String, dynamic> toMap() {
    return {
      'polls': polls?.map((x) => x.toMap()).toList(),
      'poll': poll.toMap(),
      'status': status,
    };
  }
}

class BreakoutParticipant {
  final String name;
  int? breakRoom;

  BreakoutParticipant({
    required this.name,
    this.breakRoom,
  });

  // Factory constructor to create an instance from a Map
  factory BreakoutParticipant.fromMap(Map<String, dynamic> map) {
    return BreakoutParticipant(
      name: map['name'] as String,
      breakRoom: map['breakRoom'] as int?,
    );
  }

  // Convert BreakoutParticipant to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'breakRoom': breakRoom,
    };
  }
}

class BreakoutRoomUpdatedData {
  bool? forHost;
  int? newRoom;
  List<Participant>? members;
  List<List<BreakoutParticipant>>? breakoutRooms;
  String? status;

  BreakoutRoomUpdatedData({
    this.forHost,
    this.newRoom,
    this.members,
    this.breakoutRooms,
    this.status,
  });

  // Factory constructor to create an instance from a Map
  factory BreakoutRoomUpdatedData.fromMap(Map<String, dynamic> map) {
    return BreakoutRoomUpdatedData(
      forHost: map['forHost'] as bool?,
      newRoom: map['newRoom'] as int?,
      members: map['members'] != null
          ? List<Participant>.from(
              (map['members'] as List).map((x) => Participant.fromMap(x)))
          : null,
      breakoutRooms: map['breakoutRooms'] != null
          ? List<List<BreakoutParticipant>>.from((map['breakoutRooms'] as List)
              .map((x) => List<BreakoutParticipant>.from(
                  (x as List).map((y) => BreakoutParticipant.fromMap(y)))))
          : null,
      status: map['status'] as String?,
    );
  }

  // Convert BreakoutRoomUpdatedData to a Map
  Map<String, dynamic> toMap() {
    return {
      'forHost': forHost,
      'newRoom': newRoom,
      'members': members?.map((x) => x.toMap()).toList(),
      'breakoutRooms':
          breakoutRooms?.map((x) => x.map((y) => y.toMap()).toList()).toList(),
      'status': status,
    };
  }
}

typedef ConsumeSocket = Map<String, Socket>;

class ProducerOptionsType {
  List<RtpEncodingParameters> encodings;
  ProducerCodecOptions? codecOptions;
  MediaStreamTrack? track;
  MediaStream? stream;
  RtpCodecCapability? codec;
  final Map<String, dynamic> _extraProperties = {};

  ProducerOptionsType({
    required this.encodings,
    this.codecOptions,
    this.track,
    this.stream,
    this.codec,
  });

  dynamic operator [](String key) => _extraProperties[key];
  void operator []=(String key, dynamic value) => _extraProperties[key] = value;

  // Factory method to create `ProducerOptionsType` from a Map
  factory ProducerOptionsType.fromMap(Map<String, dynamic> map) {
    final instance = ProducerOptionsType(
      encodings: (map['encodings'] as List).map((e) {
        return RtpEncodingParameters(
          rid: e['rid'] as String?,
          maxBitrate: e['maxBitrate'] as int?,
          minBitrate: e['minBitrate'] as int?,
          scalabilityMode: e['scalabilityMode'] as String?,
          scaleResolutionDownBy: e['scaleResolutionDownBy'] as double?,
          // Add other fields if necessary based on RtpEncodingParameters definition
        );
      }).toList(),
      codecOptions: map['codecOptions'] != null
          ? ProducerCodecOptions(
              // Initialize fields for ProducerCodecOptions here if necessary
              )
          : null,
      track: map['track'] as MediaStreamTrack?,
      stream: map['stream'] as MediaStream?,
      codec: map['codec'] as RtpCodecCapability?,
    );

    // Add extra properties excluding known fields
    instance._extraProperties.addAll(
      Map.from(map)
        ..removeWhere((key, _) => [
              'encodings',
              'codecOptions',
              'track',
              'stream',
              'codec'
            ].contains(key)),
    );

    return instance;
  }

  // Method to convert `ProducerOptionsType` to a Map
  Map<String, dynamic> toMap() {
    return {
      'encodings': encodings.map((e) {
        return {
          'rid': e.rid,
          'maxBitrate': e.maxBitrate,
          'minBitrate': e.minBitrate,
          'scalabilityMode': e.scalabilityMode,
          'scaleResolutionDownBy': e.scaleResolutionDownBy,
          // Add other fields if necessary based on RtpEncodingParameters definition
        };
      }).toList(),
      'codecOptions': codecOptions?.toMap(),
      'track': track,
      'stream': stream,
      'codec': codec,
      ..._extraProperties,
    };
  }
}

class WhiteboardUser {
  final String name;
  final bool useBoard;

  WhiteboardUser({
    required this.name,
    required this.useBoard,
  });

  // Factory constructor to create an instance from a Map
  factory WhiteboardUser.fromMap(Map<String, dynamic> map) {
    return WhiteboardUser(
      name: map['name'] as String,
      useBoard: map['useBoard'] as bool,
    );
  }

  // Convert WhiteboardUser to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'useBoard': useBoard,
    };
  }
}

class ShapePayload {
  final String type;
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final String color;
  final double thickness;
  final String lineType;
  final Map<String, dynamic> _extraProperties = {};

  ShapePayload({
    required this.type,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.color,
    required this.thickness,
    required this.lineType,
  });

  dynamic operator [](String key) => _extraProperties[key];
  void operator []=(String key, dynamic value) => _extraProperties[key] = value;

  // Factory constructor to create an instance from a Map
  factory ShapePayload.fromMap(Map<String, dynamic> map) {
    return ShapePayload(
      type: map['type'] as String,
      x1: map['x1'] as double,
      y1: map['y1'] as double,
      x2: map['x2'] as double,
      y2: map['y2'] as double,
      color: map['color'] as String,
      thickness: map['thickness'] as double,
      lineType: map['lineType'] as String,
    ).._extraProperties.addAll(map);
  }

  // Convert ShapePayload to a Map
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'x1': x1,
      'y1': y1,
      'x2': x2,
      'y2': y2,
      'color': color,
      'thickness': thickness,
      'lineType': lineType,
      ..._extraProperties,
    };
  }
}

class Shapes {
  final String action;
  final ShapePayload payload;

  Shapes({
    required this.action,
    required this.payload,
  });

  // Factory constructor to create an instance from a Map
  factory Shapes.fromMap(Map<String, dynamic> map) {
    return Shapes(
      action: map['action'] as String,
      payload: ShapePayload.fromMap(map['payload']),
    );
  }

  // Convert Shapes to a Map
  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'payload': payload.toMap(),
    };
  }
}

class WhiteboardData {
  final List<Shapes> shapes;
  final List<Shapes> redoStack;
  final List<Shapes> undoStack;
  final bool useImageBackground;

  WhiteboardData({
    required this.shapes,
    required this.redoStack,
    required this.undoStack,
    required this.useImageBackground,
  });

  // Factory constructor to create an instance from a Map
  factory WhiteboardData.fromMap(Map<String, dynamic> map) {
    return WhiteboardData(
      shapes: List<Shapes>.from(
          (map['shapes'] as List).map((x) => Shapes.fromMap(x))),
      redoStack: List<Shapes>.from(
          (map['redoStack'] as List).map((x) => Shapes.fromMap(x))),
      undoStack: List<Shapes>.from(
          (map['undoStack'] as List).map((x) => Shapes.fromMap(x))),
      useImageBackground: map['useImageBackground'] as bool,
    );
  }

  // Convert WhiteboardData to a Map
  Map<String, dynamic> toMap() {
    return {
      'shapes': shapes.map((x) => x.toMap()).toList(),
      'redoStack': redoStack.map((x) => x.toMap()).toList(),
      'undoStack': undoStack.map((x) => x.toMap()).toList(),
      'useImageBackground': useImageBackground,
    };
  }
}

class SeedData {
  String? member;
  String? host;
  EventType? eventType;
  List<Participant>? participants;
  List<Message>? messages;
  List<Poll>? polls;
  List<List<BreakoutParticipant>>? breakoutRooms;
  List<Request>? requests;
  List<WaitingRoomParticipant>? waitingList;
  List<WhiteboardUser>? whiteboardUsers;

  SeedData({
    this.member,
    this.host,
    this.eventType,
    this.participants,
    this.messages,
    this.polls,
    this.breakoutRooms,
    this.requests,
    this.waitingList,
    this.whiteboardUsers,
  });

  // Factory constructor to create an instance from a Map
  factory SeedData.fromMap(Map<String, dynamic> map) {
    return SeedData(
      member: map['member'] as String?,
      host: map['host'] as String?,
      eventType: map['eventType'] != null
          ? EventType.values.firstWhere(
              (e) => e.toString().split('.').last == map['eventType'])
          : null,
      participants: map['participants'] != null
          ? List<Participant>.from(
              (map['participants'] as List).map((x) => Participant.fromMap(x)))
          : null,
      messages: map['messages'] != null
          ? List<Message>.from(
              (map['messages'] as List).map((x) => Message.fromMap(x)))
          : null,
      polls: map['polls'] != null
          ? List<Poll>.from((map['polls'] as List).map((x) => Poll.fromMap(x)))
          : null,
      breakoutRooms: map['breakoutRooms'] != null
          ? List<List<BreakoutParticipant>>.from((map['breakoutRooms'] as List)
              .map((x) => List<BreakoutParticipant>.from(
                  (x as List).map((y) => BreakoutParticipant.fromMap(y)))))
          : null,
      requests: map['requests'] != null
          ? List<Request>.from(
              (map['requests'] as List).map((x) => Request.fromMap(x)))
          : null,
      waitingList: map['waitingList'] != null
          ? List<WaitingRoomParticipant>.from((map['waitingList'] as List)
              .map((x) => WaitingRoomParticipant.fromMap(x)))
          : null,
      whiteboardUsers: map['whiteboardUsers'] != null
          ? List<WhiteboardUser>.from((map['whiteboardUsers'] as List)
              .map((x) => WhiteboardUser.fromMap(x)))
          : null,
    );
  }

  // Convert SeedData to a Map
  Map<String, dynamic> toMap() {
    return {
      'member': member,
      'host': host,
      'eventType': eventType?.toString().split('.').last,
      'participants': participants?.map((x) => x.toMap()).toList(),
      'messages': messages?.map((x) => x.toMap()).toList(),
      'polls': polls?.map((x) => x.toMap()).toList(),
      'breakoutRooms':
          breakoutRooms?.map((x) => x.map((y) => y.toMap()).toList()).toList(),
      'requests': requests?.map((x) => x.toMap()).toList(),
      'waitingList': waitingList?.map((x) => x.toMap()).toList(),
      'whiteboardUsers': whiteboardUsers?.map((x) => x.toMap()).toList(),
    };
  }
}

class MeetingRoomParams {
  final int itemPageLimit;
  final String mediaType; // 'audio' or 'video'
  final bool addCoHost;
  final String targetOrientation; // 'landscape', 'neutral', or 'portrait'
  final String targetOrientationHost; // 'landscape', 'neutral', or 'portrait'
  final String targetResolution; // 'qhd', 'fhd', 'hd', 'sd', or 'QnHD'
  final String targetResolutionHost; // 'qhd', 'fhd', 'hd', 'sd', or 'QnHD'
  dynamic type; // Room type
  final String audioSetting; // 'allow', 'approval', or 'disallow'
  final String videoSetting; // 'allow', 'approval', or 'disallow'
  final String screenshareSetting; // 'allow', 'approval', or 'disallow'
  final String chatSetting; // 'allow' or 'disallow'

  MeetingRoomParams({
    required this.itemPageLimit,
    required this.mediaType,
    required this.addCoHost,
    required this.targetOrientation,
    required this.targetOrientationHost,
    required this.targetResolution,
    required this.targetResolutionHost,
    required this.type,
    required this.audioSetting,
    required this.videoSetting,
    required this.screenshareSetting,
    required this.chatSetting,
  });

  // Factory constructor for JSON parsing
  factory MeetingRoomParams.fromJson(Map<String, dynamic> json) {
    return MeetingRoomParams(
      itemPageLimit: json['itemPageLimit'] as int,
      mediaType: json['mediaType'] as String,
      addCoHost: json['addCoHost'] as bool,
      targetOrientation: json['targetOrientation'] as String,
      targetOrientationHost: json['targetOrientationHost'] as String,
      targetResolution: json['targetResolution'] as String,
      targetResolutionHost: json['targetResolutionHost'] as String,
      type: json['type'], // Use dynamic typing directly
      audioSetting: json['audioSetting'] as String,
      videoSetting: json['videoSetting'] as String,
      screenshareSetting: json['screenshareSetting'] as String,
      chatSetting: json['chatSetting'] as String,
    );
  }

  // Convert MeetingRoomParams to a Map
  Map<String, dynamic> toMap() {
    return {
      'itemPageLimit': itemPageLimit,
      'mediaType': mediaType,
      'addCoHost': addCoHost,
      'targetOrientation': targetOrientation,
      'targetOrientationHost': targetOrientationHost,
      'targetResolution': targetResolution,
      'targetResolutionHost': targetResolutionHost,
      'type': type,
      'audioSetting': audioSetting,
      'videoSetting': videoSetting,
      'screenshareSetting': screenshareSetting,
      'chatSetting': chatSetting,
    };
  }
}

class RecordingParams {
  final int recordingAudioPausesLimit;
  final bool recordingAudioSupport;
  final int recordingAudioPeopleLimit;
  final int recordingAudioParticipantsTimeLimit;

  final int recordingVideoPausesLimit;
  final bool recordingVideoSupport;
  final int recordingVideoPeopleLimit;
  final int recordingVideoParticipantsTimeLimit;

  final bool recordingAllParticipantsSupport;
  final bool recordingVideoParticipantsSupport;
  final bool recordingAllParticipantsFullRoomSupport;
  final bool recordingVideoParticipantsFullRoomSupport;

  final String recordingPreferredOrientation; // 'landscape' or 'portrait'
  final bool recordingSupportForOtherOrientation;
  final bool recordingMultiFormatsSupport;
  final bool recordingHLSSupport;

  int? recordingAudioPausesCount;
  int? recordingVideoPausesCount;

  RecordingParams({
    required this.recordingAudioPausesLimit,
    required this.recordingAudioSupport,
    required this.recordingAudioPeopleLimit,
    required this.recordingAudioParticipantsTimeLimit,
    required this.recordingVideoPausesLimit,
    required this.recordingVideoSupport,
    required this.recordingVideoPeopleLimit,
    required this.recordingVideoParticipantsTimeLimit,
    required this.recordingAllParticipantsSupport,
    required this.recordingVideoParticipantsSupport,
    required this.recordingAllParticipantsFullRoomSupport,
    required this.recordingVideoParticipantsFullRoomSupport,
    required this.recordingPreferredOrientation,
    required this.recordingSupportForOtherOrientation,
    required this.recordingMultiFormatsSupport,
    required this.recordingHLSSupport,
    this.recordingAudioPausesCount,
    this.recordingVideoPausesCount,
  });

  // Factory constructor to parse JSON into a RecordingParams instance
  factory RecordingParams.fromJson(Map<String, dynamic> json) {
    return RecordingParams(
      recordingAudioPausesLimit: json['recordingAudioPausesLimit'] as int,
      recordingAudioSupport: json['recordingAudioSupport'] as bool,
      recordingAudioPeopleLimit: json['recordingAudioPeopleLimit'] as int,
      recordingAudioParticipantsTimeLimit:
          json['recordingAudioParticipantsTimeLimit'] as int,
      recordingVideoPausesLimit: json['recordingVideoPausesLimit'] as int,
      recordingVideoSupport: json['recordingVideoSupport'] as bool,
      recordingVideoPeopleLimit: json['recordingVideoPeopleLimit'] as int,
      recordingVideoParticipantsTimeLimit:
          json['recordingVideoParticipantsTimeLimit'] as int,
      recordingAllParticipantsSupport:
          json['recordingAllParticipantsSupport'] as bool,
      recordingVideoParticipantsSupport:
          json['recordingVideoParticipantsSupport'] as bool,
      recordingAllParticipantsFullRoomSupport:
          json['recordingAllParticipantsFullRoomSupport'] as bool,
      recordingVideoParticipantsFullRoomSupport:
          json['recordingVideoParticipantsFullRoomSupport'] as bool,
      recordingPreferredOrientation:
          json['recordingPreferredOrientation'] as String,
      recordingSupportForOtherOrientation:
          json['recordingSupportForOtherOrientation'] as bool,
      recordingMultiFormatsSupport:
          json['recordingMultiFormatsSupport'] as bool,
      recordingHLSSupport: json['recordingHLSSupport'] as bool,
      recordingAudioPausesCount: json['recordingAudioPausesCount'] as int?,
      recordingVideoPausesCount: json['recordingVideoPausesCount'] as int?,
    );
  }

  // Convert RecordingParams to a Map
  Map<String, dynamic> toMap() {
    return {
      'recordingAudioPausesLimit': recordingAudioPausesLimit,
      'recordingAudioSupport': recordingAudioSupport,
      'recordingAudioPeopleLimit': recordingAudioPeopleLimit,
      'recordingAudioParticipantsTimeLimit':
          recordingAudioParticipantsTimeLimit,
      'recordingVideoPausesLimit': recordingVideoPausesLimit,
      'recordingVideoSupport': recordingVideoSupport,
      'recordingVideoPeopleLimit': recordingVideoPeopleLimit,
      'recordingVideoParticipantsTimeLimit':
          recordingVideoParticipantsTimeLimit,
      'recordingAllParticipantsSupport': recordingAllParticipantsSupport,
      'recordingVideoParticipantsSupport': recordingVideoParticipantsSupport,
      'recordingAllParticipantsFullRoomSupport':
          recordingAllParticipantsFullRoomSupport,
      'recordingVideoParticipantsFullRoomSupport':
          recordingVideoParticipantsFullRoomSupport,
      'recordingPreferredOrientation': recordingPreferredOrientation,
      'recordingSupportForOtherOrientation':
          recordingSupportForOtherOrientation,
      'recordingMultiFormatsSupport': recordingMultiFormatsSupport,
      'recordingHLSSupport': recordingHLSSupport,
      'recordingAudioPausesCount': recordingAudioPausesCount,
      'recordingVideoPausesCount': recordingVideoPausesCount,
    };
  }
}

class CreateRoomOptions {
  final String action; // 'create' or 'join'
  final String meetingID;
  final int duration;
  final int capacity;
  final String userName;
  final int scheduledDate;
  final String secureCode;
  final EventType eventType;
  final bool recordOnly;
  final String eventStatus; // 'active' or 'inactive'
  final int startIndex;
  final int pageSize;
  final bool safeRoom;
  final bool autoStartSafeRoom;
  final String safeRoomAction; // 'warn', 'kick', or 'ban'
  final bool dataBuffer;
  final String bufferType; // 'images', 'audio', or 'all'
  final bool supportSIP; // Whether to support SIP
  final String directionSIP; // 'inbound', 'outbound', or 'both'
  final bool preferPCMA; // Whether to prefer PCMA codec for SIP

  CreateRoomOptions({
    required this.action,
    required this.meetingID,
    required this.duration,
    required this.capacity,
    required this.userName,
    required this.scheduledDate,
    required this.secureCode,
    required this.eventType,
    required this.recordOnly,
    required this.eventStatus,
    required this.startIndex,
    required this.pageSize,
    required this.safeRoom,
    required this.autoStartSafeRoom,
    required this.safeRoomAction,
    required this.dataBuffer,
    required this.bufferType,
    required this.supportSIP,
    required this.directionSIP,
    required this.preferPCMA,
  });

  // Convert CreateRoomOptions to a Map
  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'meetingID': meetingID,
      'duration': duration,
      'capacity': capacity,
      'userName': userName,
      'scheduledDate': scheduledDate,
      'secureCode': secureCode,
      'eventType': eventType.toString().split('.').last,
      'recordOnly': recordOnly,
      'eventStatus': eventStatus,
      'startIndex': startIndex,
      'pageSize': pageSize,
      'safeRoom': safeRoom,
      'autoStartSafeRoom': autoStartSafeRoom,
      'safeRoomAction': safeRoomAction,
      'dataBuffer': dataBuffer,
      'bufferType': bufferType,
      'supportSIP': supportSIP,
      'directionSIP': directionSIP,
      'preferPCMA': preferPCMA,
    };
  }

  // Factory constructor to create an instance from a Map
  factory CreateRoomOptions.fromMap(Map<String, dynamic> map) {
    return CreateRoomOptions(
      action: map['action'] as String,
      meetingID: map['meetingID'] as String,
      duration: map['duration'] as int,
      capacity: map['capacity'] as int,
      userName: map['userName'] as String,
      scheduledDate: map['scheduledDate'] as int,
      secureCode: map['secureCode'] as String,
      eventType: EventType.values
          .firstWhere((e) => e.toString().split('.').last == map['eventType']),
      recordOnly: map['recordOnly'] as bool,
      eventStatus: map['eventStatus'] as String,
      startIndex: map['startIndex'] as int,
      pageSize: map['pageSize'] as int,
      safeRoom: map['safeRoom'] as bool,
      autoStartSafeRoom: map['autoStartSafeRoom'] as bool,
      safeRoomAction: map['safeRoomAction'] as String,
      dataBuffer: map['dataBuffer'] as bool,
      bufferType: map['bufferType'] as String,
      supportSIP: map['supportSIP'] as bool,
      directionSIP: map['directionSIP'] as String,
      preferPCMA: map['preferPCMA'] as bool,
    );
  }
}

class CreateMediaSFURoomOptions {
  final String action; // 'create' action
  final int duration; // Duration of the meeting in minutes
  final int capacity; // Max number of participants allowed
  final String userName; // Username of the room host
  final int?
      scheduledDate; // Unix timestamp (in milliseconds) for the scheduled date
  final String? secureCode; // Secure code for the room host
  final EventType? eventType; // Type of event
  final MeetingRoomParams?
      meetingRoomParams; // Object containing parameters related to the meeting room
  final RecordingParams?
      recordingParams; // Object containing parameters related to recording
  bool? recordOnly; // Whether the room is for media production only (egress)
  bool? safeRoom; // Whether the room is a safe room
  bool? autoStartSafeRoom; // Automatically start the safe room feature
  String? safeRoomAction; // Action for the safe room
  bool? dataBuffer; // Whether to return data buffer
  String? bufferType; // Type of buffer data
  bool? supportSIP; // Whether to support SIP
  String? directionSIP; // Direction of SIP ('inbound', 'outbound', or 'both')
  bool? preferPCMA; // Whether to prefer PCMA codec for SIP

  CreateMediaSFURoomOptions({
    required this.action,
    required this.duration,
    required this.capacity,
    required this.userName,
    this.scheduledDate,
    this.secureCode,
    this.eventType,
    this.meetingRoomParams,
    this.recordingParams,
    this.recordOnly = false,
    this.safeRoom = false,
    this.autoStartSafeRoom = false,
    this.safeRoomAction = "kick",
    this.dataBuffer = false,
    this.bufferType = "all",
    this.supportSIP = false,
    this.directionSIP = "both",
    this.preferPCMA = false,
  });

  // Convert CreateMediaSFURoomOptions to a Map
  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'duration': duration,
      'capacity': capacity,
      'userName': userName,
      'scheduledDate': scheduledDate,
      'secureCode': secureCode,
      'eventType': eventType?.toString().split('.').last,
      'meetingRoomParams': meetingRoomParams?.toMap(),
      'recordingParams': recordingParams?.toMap(),
      'recordOnly': recordOnly,
      'safeRoom': safeRoom,
      'autoStartSafeRoom': autoStartSafeRoom,
      'safeRoomAction': safeRoomAction,
      'dataBuffer': dataBuffer,
      'bufferType': bufferType,
      'supportSIP': supportSIP,
      'directionSIP': directionSIP,
      'preferPCMA': preferPCMA,
    };
  }

  // Factory constructor to create an instance from a Map
  factory CreateMediaSFURoomOptions.fromMap(Map<String, dynamic> map) {
    return CreateMediaSFURoomOptions(
      action: map['action'] != null ? map['action'] as String : "",
      duration: map['duration'] != null ? map['duration'] as int : 0,
      capacity: map['capacity'] != null ? map['capacity'] as int : 0,
      userName: map['userName'] != null ? map['userName'] as String : "",
      scheduledDate:
          map['scheduledDate'] != null ? map['scheduledDate'] as int : null,
      secureCode: map['secureCode'] != null ? map['secureCode'] as String : "",
      eventType: map['eventType'] != null
          ? EventType.values.firstWhere(
              (e) => e.toString().split('.').last == map['eventType'])
          : null,
      meetingRoomParams: map['meetingRoomParams'] != null
          ? MeetingRoomParams.fromJson(map['meetingRoomParams'])
          : null,
      recordingParams: map['recordingParams'] != null
          ? RecordingParams.fromJson(map['recordingParams'])
          : null,
      recordOnly: map['recordOnly'] != null ? map['recordOnly'] as bool : false,
      safeRoom: map['safeRoom'] != null ? map['safeRoom'] as bool : false,
      autoStartSafeRoom: map['autoStartSafeRoom'] != null
          ? map['autoStartSafeRoom'] as bool
          : false,
      safeRoomAction:
          map['safeRoomAction'] != null ? map['safeRoomAction'] as String : "",
      dataBuffer: map['dataBuffer'] != null ? map['dataBuffer'] as bool : false,
      bufferType: map['bufferType'] != null ? map['bufferType'] as String : "",
      supportSIP: map['supportSIP'] != null ? map['supportSIP'] as bool : false,
      directionSIP: map['directionSIP'] != null ? map['directionSIP'] as String : "both",
      preferPCMA: map['preferPCMA'] != null ? map['preferPCMA'] as bool : false,
    );
  }
}

class JoinMediaSFURoomOptions {
  final String action; // 'join' action
  final String meetingID; // The meeting ID
  final String userName; // Username of the room host

  JoinMediaSFURoomOptions({
    required this.action,
    required this.meetingID,
    required this.userName,
  });

  // Convert JoinMediaSFURoomOptions to a Map
  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'meetingID': meetingID,
      'userName': userName,
    };
  }

  // Factory constructor to create an instance from a Map
  factory JoinMediaSFURoomOptions.fromMap(Map<String, dynamic> map) {
    return JoinMediaSFURoomOptions(
      action: map['action'] as String,
      meetingID: map['meetingID'] as String,
      userName: map['userName'] as String,
    );
  }
}

class ResponseJoinRoom {
  final RtpCapabilities? rtpCapabilities;
  final bool? success;
  List<String>? roomRecvIPs;
  MeetingRoomParams? meetingRoomParams;
  RecordingParams? recordingParams;
  final String? secureCode;
  final bool? recordOnly;
  final bool? isHost;
  final bool? safeRoom;
  final bool? autoStartSafeRoom;
  final bool? safeRoomStarted;
  final bool? safeRoomEnded;
  final String? reason;
  final bool? banned;
  final bool? suspended;
  final bool? noAdmin;

  ResponseJoinRoom({
    this.rtpCapabilities,
    this.success = false,
    this.roomRecvIPs,
    this.meetingRoomParams,
    this.recordingParams,
    this.secureCode,
    this.recordOnly,
    this.isHost,
    this.safeRoom,
    this.autoStartSafeRoom,
    this.safeRoomStarted,
    this.safeRoomEnded,
    this.reason,
    this.banned,
    this.suspended,
    this.noAdmin,
  });

  factory ResponseJoinRoom.fromJson(Map<String, dynamic> json) {
    return ResponseJoinRoom(
      rtpCapabilities: json['rtpCapabilities'] != null
          ? RtpCapabilities.fromMap(json['rtpCapabilities'])
          : null,
      success: json['success'] as bool?,
      roomRecvIPs: json['roomRecvIPs'] != null
          ? List<String>.from(json['roomRecvIPs'])
          : null,
      meetingRoomParams: json['meetingRoomParams'] != null
          ? MeetingRoomParams.fromJson(json['meetingRoomParams'])
          : null,
      recordingParams: json['recordingParams'] != null
          ? RecordingParams.fromJson(json['recordingParams'])
          : null,
      secureCode: json['secureCode'] as String?,
      recordOnly: json['recordOnly'] as bool?,
      isHost: json['isHost'] as bool?,
      safeRoom: json['safeRoom'] as bool?,
      autoStartSafeRoom: json['autoStartSafeRoom'] as bool?,
      safeRoomStarted: json['safeRoomStarted'] as bool?,
      safeRoomEnded: json['safeRoomEnded'] as bool?,
      reason: json['reason'] as String?,
      banned: json['banned'] as bool?,
      suspended: json['suspended'] as bool?,
      noAdmin: json['noAdmin'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rtpCapabilities': rtpCapabilities?.toMap(),
      'success': success,
      'roomRecvIPs': roomRecvIPs,
      'meetingRoomParams': meetingRoomParams?.toMap(),
      'recordingParams': recordingParams?.toMap(),
      'secureCode': secureCode,
      'recordOnly': recordOnly,
      'isHost': isHost,
      'safeRoom': safeRoom,
      'autoStartSafeRoom': autoStartSafeRoom,
      'safeRoomStarted': safeRoomStarted,
      'safeRoomEnded': safeRoomEnded,
      'reason': reason,
      'banned': banned,
      'suspended': suspended,
      'noAdmin': noAdmin,
    };
  }
}

class ResponseJoinLocalRoom {
  final RtpCapabilities?
      rtpCapabilities; // Object containing the RTP capabilities
  final bool? isHost; // Indicates whether the user joining the room is the host
  final bool? eventStarted; // Indicates whether the event has started
  final bool? isBanned; // Indicates whether the user is banned from the room
  final bool?
      hostNotJoined; // Indicates whether the host has not joined the room
  final MeetingRoomParams?
      eventRoomParams; // Parameters related to the meeting room
  final RecordingParams? recordingParams; // Parameters related to recording
  final String?
      secureCode; // Secure code (host password) associated with the host of the room
  final String? mediasfuURL; // Media SFU URL
  final String? apiKey; // API key
  final String? apiUserName; // API username
  final bool? allowRecord; // Indicates whether recording is allowed

  /// Constructor for initializing the ResponseJoinLocalRoom object.
  ResponseJoinLocalRoom({
    this.rtpCapabilities,
    this.isHost,
    this.eventStarted,
    this.isBanned,
    this.hostNotJoined,
    this.eventRoomParams,
    this.recordingParams,
    this.secureCode,
    this.mediasfuURL,
    this.apiKey,
    this.apiUserName,
    this.allowRecord,
  });

  /// Converts the object to a Map.
  Map<String, dynamic> toMap() {
    return {
      'rtpCapabilities': rtpCapabilities?.toMap(),
      'isHost': isHost,
      'eventStarted': eventStarted,
      'isBanned': isBanned,
      'hostNotJoined': hostNotJoined,
      'eventRoomParams': eventRoomParams?.toMap(),
      'recordingParams': recordingParams?.toMap(),
      'secureCode': secureCode,
      'mediasfuURL': mediasfuURL,
      'apiKey': apiKey,
      'apiUserName': apiUserName,
      'allowRecord': allowRecord,
    };
  }

  /// Creates a ResponseJoinLocalRoom object from a Map.
  factory ResponseJoinLocalRoom.fromJson(Map<String, dynamic> map) {
    return ResponseJoinLocalRoom(
      rtpCapabilities: map['rtpCapabilities'] != null
          ? RtpCapabilities.fromMap(map['rtpCapabilities'])
          : null,
      isHost: map['isHost'] as bool?,
      eventStarted: map['eventStarted'] as bool?,
      isBanned: map['isBanned'] as bool?,
      hostNotJoined: map['hostNotJoined'] as bool?,
      eventRoomParams: map['eventRoomParams'] != null
          ? MeetingRoomParams.fromJson(map['eventRoomParams'])
          : null,
      recordingParams: map['recordingParams'] != null
          ? RecordingParams.fromJson(map['recordingParams'])
          : null,
      secureCode: map['secureCode'] as String?,
      mediasfuURL: map['mediasfuURL'] as String?,
      apiKey: map['apiKey'] as String?,
      apiUserName: map['apiUserName'] as String?,
      allowRecord: map['allowRecord'] is String
          ? map['allowRecord'] == 'true'
          : map['allowRecord'] as bool?,
    );
  }
}

class AllMembersData {
  final List<Participant> members;
  final List<Request> requests;
  final String? coHost;
  final List<CoHostResponsibility> coHostResponsibilities;

  AllMembersData({
    required this.members,
    required this.requests,
    this.coHost,
    required this.coHostResponsibilities,
  });

  factory AllMembersData.fromJson(Map<String, dynamic> json) {
    return AllMembersData(
      members: List<Participant>.from(
          (json['members'] as List).map((x) => Participant.fromMap(x))),
      requests: List<Request>.from(
          (json['requests'] as List).map((x) => Request.fromMap(x))),
      coHost: json['coHost'] as String?,
      coHostResponsibilities: List<CoHostResponsibility>.from(
          (json['coHostResponsibilities'] as List)
              .map((x) => CoHostResponsibility.fromMap(x))),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'members': members.map((x) => x.toMap()).toList(),
      'requests': requests.map((x) => x.toMap()).toList(),
      'coHost': coHost,
      'coHostResponsibilities':
          coHostResponsibilities.map((x) => x.toMap()).toList(),
    };
  }
}

class AllMembersRestData {
  List<Participant> members;
  Settings settings;
  String? coHost;
  List<CoHostResponsibility> coHostResponsibilities;

  AllMembersRestData({
    required this.members,
    required this.settings,
    this.coHost,
    required this.coHostResponsibilities,
  });

  factory AllMembersRestData.fromJson(Map<String, dynamic> json) {
    return AllMembersRestData(
      members: List<Participant>.from(
          (json['members'] as List).map((x) => Participant.fromMap(x))),
      settings: Settings.fromList(json['settings']),
      coHost: json['coHost'] as String?,
      coHostResponsibilities: List<CoHostResponsibility>.from(
          (json['coHostResponsibilities'] as List)
              .map((x) => CoHostResponsibility.fromMap(x))),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'members': members.map((x) => x.toMap()).toList(),
      'settings': settings.toMap(),
      'coHost': coHost,
      'coHostResponsibilities':
          coHostResponsibilities.map((x) => x.toMap()).toList(),
    };
  }
}

class UserWaitingData {
  final String name;

  UserWaitingData({required this.name});

  factory UserWaitingData.fromJson(Map<String, dynamic> json) {
    return UserWaitingData(
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}

class AllWaitingRoomMembersData {
  final List<WaitingRoomParticipant>? waitingParticipants;
  final List<WaitingRoomParticipant>? waitingParticipantss;

  AllWaitingRoomMembersData({
    this.waitingParticipants,
    this.waitingParticipantss,
  });

  factory AllWaitingRoomMembersData.fromJson(Map<String, dynamic> json) {
    return AllWaitingRoomMembersData(
      waitingParticipants: json['waitingParticipants'] != null
          ? List<WaitingRoomParticipant>.from(
              (json['waitingParticipants'] as List)
                  .map((x) => WaitingRoomParticipant.fromMap(x)))
          : null,
      waitingParticipantss: json['waitingParticipantss'] != null
          ? List<WaitingRoomParticipant>.from(
              (json['waitingParticipantss'] as List)
                  .map((x) => WaitingRoomParticipant.fromMap(x)))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'waitingParticipants':
          waitingParticipants?.map((x) => x.toMap()).toList(),
      'waitingParticipantss':
          waitingParticipantss?.map((x) => x.toMap()).toList(),
    };
  }
}

class BanData {
  final String name;

  BanData({required this.name});

  factory BanData.fromJson(Map<String, dynamic> json) {
    return BanData(
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}

class UpdatedCoHostData {
  final String coHost;
  final List<CoHostResponsibility> coHostResponsibilities;

  UpdatedCoHostData({
    required this.coHost,
    required this.coHostResponsibilities,
  });

  factory UpdatedCoHostData.fromJson(Map<String, dynamic> json) {
    return UpdatedCoHostData(
      coHost: json['coHost'] as String,
      coHostResponsibilities: List<CoHostResponsibility>.from(
          (json['coHostResponsibilities'] as List)
              .map((x) => CoHostResponsibility.fromMap(x))),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coHost': coHost,
      'coHostResponsibilities':
          coHostResponsibilities.map((x) => x.toMap()).toList(),
    };
  }
}

class ParticipantRequestedData {
  final Request userRequest;

  ParticipantRequestedData({required this.userRequest});

  factory ParticipantRequestedData.fromJson(Map<String, dynamic> json) {
    return ParticipantRequestedData(
      userRequest: Request.fromMap(json['userRequest']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userRequest': userRequest.toMap(),
    };
  }
}

class ScreenProducerIdData {
  final String producerId;

  ScreenProducerIdData({required this.producerId});

  factory ScreenProducerIdData.fromJson(Map<String, dynamic> json) {
    return ScreenProducerIdData(
      producerId: json['producerId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'producerId': producerId,
    };
  }
}

class UpdateMediaSettingsData {
  final Settings settings;

  UpdateMediaSettingsData({required this.settings});

  factory UpdateMediaSettingsData.fromJson(Map<String, dynamic> json) {
    return UpdateMediaSettingsData(
      settings: Settings.fromMap(json['settings']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'settings': settings.toMap(),
    };
  }
}

class ProducerMediaPausedData {
  final String producerId;
  final String kind; // 'audio'
  final String name;

  ProducerMediaPausedData({
    required this.producerId,
    required this.kind,
    required this.name,
  });

  factory ProducerMediaPausedData.fromJson(Map<String, dynamic> json) {
    return ProducerMediaPausedData(
      producerId: json['producerId'] as String,
      kind: json['kind'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'producerId': producerId,
      'kind': kind,
      'name': name,
    };
  }
}

class ProducerMediaResumedData {
  final String kind; // 'audio'
  final String name;

  ProducerMediaResumedData({
    required this.kind,
    required this.name,
  });

  factory ProducerMediaResumedData.fromJson(Map<String, dynamic> json) {
    return ProducerMediaResumedData(
      kind: json['kind'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kind': kind,
      'name': name,
    };
  }
}

class ProducerMediaClosedData {
  final String producerId;
  final String kind; // 'audio', 'video', or 'screenshare'
  final String name;

  ProducerMediaClosedData({
    required this.producerId,
    required this.kind,
    required this.name,
  });

  factory ProducerMediaClosedData.fromJson(Map<String, dynamic> json) {
    return ProducerMediaClosedData(
      producerId: json['producerId'] as String,
      kind: json['kind'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'producerId': producerId,
      'kind': kind,
      'name': name,
    };
  }
}

class ControlMediaHostData {
  final String type; // 'all', 'audio', 'video', or 'screenshare'

  ControlMediaHostData({required this.type});

  factory ControlMediaHostData.fromJson(Map<String, dynamic> json) {
    return ControlMediaHostData(
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
    };
  }
}

class ReceiveMessageData {
  final Message message;

  ReceiveMessageData({required this.message});

  factory ReceiveMessageData.fromJson(Map<String, dynamic> json) {
    return ReceiveMessageData(
      message: Message.fromMap(json['message']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message.toMap(),
    };
  }
}

class MeetingTimeRemainingData {
  final int timeRemaining;

  MeetingTimeRemainingData({required this.timeRemaining});

  factory MeetingTimeRemainingData.fromJson(Map<String, dynamic> json) {
    return MeetingTimeRemainingData(
      timeRemaining: json['timeRemaining'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timeRemaining': timeRemaining,
    };
  }
}

class MeetingStillThereData {
  final int timeRemaining;

  MeetingStillThereData({required this.timeRemaining});

  factory MeetingStillThereData.fromJson(Map<String, dynamic> json) {
    return MeetingStillThereData(
      timeRemaining: json['timeRemaining'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timeRemaining': timeRemaining,
    };
  }
}

class UpdateConsumingDomainsData {
  final List<String> domains;
  final AltDomains altDomains;

  UpdateConsumingDomainsData({
    required this.domains,
    required this.altDomains,
  });

  factory UpdateConsumingDomainsData.fromJson(Map<String, dynamic> json) {
    return UpdateConsumingDomainsData(
      domains: List<String>.from(json['domains']),
      altDomains: AltDomains.fromMap(json['altDomains']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'domains': domains,
      'altDomains': altDomains.toMap(),
    };
  }
}

class RecordingNoticeData {
  final String state;
  final UserRecordingParams userRecordingParam;
  final int pauseCount;
  final int timeDone;

  RecordingNoticeData({
    required this.state,
    required this.userRecordingParam,
    required this.pauseCount,
    required this.timeDone,
  });

  factory RecordingNoticeData.fromJson(Map<String, dynamic> json) {
    return RecordingNoticeData(
      state: json['state'] as String,
      userRecordingParam:
          UserRecordingParams.fromMap(json['userRecordingParam']),
      pauseCount: json['pauseCount'] as int,
      timeDone: json['timeDone'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'state': state,
      'userRecordingParam': userRecordingParam.toMap(),
      'pauseCount': pauseCount,
      'timeDone': timeDone,
    };
  }
}

class TimeLeftRecordingData {
  final int timeLeft;

  TimeLeftRecordingData({required this.timeLeft});

  factory TimeLeftRecordingData.fromJson(Map<String, dynamic> json) {
    return TimeLeftRecordingData(
      timeLeft: json['timeLeft'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timeLeft': timeLeft,
    };
  }
}

class StoppedRecordingData {
  final String state;
  final String? reason;

  StoppedRecordingData({
    required this.state,
    this.reason,
  });

  factory StoppedRecordingData.fromJson(Map<String, dynamic> json) {
    return StoppedRecordingData(
      state: json['state'] as String,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'state': state,
      'reason': reason,
    };
  }
}

class HostRequestResponseData {
  final RequestResponse requestResponse;

  HostRequestResponseData({required this.requestResponse});

  factory HostRequestResponseData.fromJson(Map<String, dynamic> json) {
    return HostRequestResponseData(
      requestResponse: RequestResponse.fromMap(json['requestResponse']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestResponse': requestResponse.toMap(),
    };
  }
}

class SafeRoomNoticeData {
  final String state;

  SafeRoomNoticeData({required this.state});

  factory SafeRoomNoticeData.fromJson(Map<String, dynamic> json) {
    return SafeRoomNoticeData(
      state: json['state'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'state': state,
    };
  }
}

class UnSafeData {
  final int time;
  final ImageData evidence;

  UnSafeData({
    required this.time,
    required this.evidence,
  });

  factory UnSafeData.fromJson(Map<String, dynamic> json) {
    return UnSafeData(
      time: json['time'] as int,
      evidence: ImageData.fromJson(json['evidence']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'evidence': evidence.toMap(),
    };
  }
}

class UnsafeAlertData {
  final String name;

  UnsafeAlertData({required this.name});

  factory UnsafeAlertData.fromJson(Map<String, dynamic> json) {
    return UnsafeAlertData(
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}

class DataBufferNotice {
  final String state;

  DataBufferNotice({required this.state});

  factory DataBufferNotice.fromJson(Map<String, dynamic> json) {
    return DataBufferNotice(
      state: json['state'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'state': state,
    };
  }
}

class AudioData {
  final dynamic audioBuffer;

  AudioData({required this.audioBuffer});

  factory AudioData.fromJson(Map<String, dynamic> json) {
    return AudioData(
      audioBuffer: json['audioBuffer'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'audioBuffer': audioBuffer,
    };
  }
}

class ImageData {
  final dynamic jpegBuffer;

  ImageData({required this.jpegBuffer});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      jpegBuffer: ImageData.fromJson(json['jpegBuffer']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jpegBuffer': jpegBuffer.toMap(),
    };
  }
}

class WhiteboardUpdatedData {
  final String status; // 'started' or 'ended'
  final List<WhiteboardUser> whiteboardUsers;
  final List<Participant> members;
  final WhiteboardData whiteboardData;

  WhiteboardUpdatedData({
    required this.status,
    required this.whiteboardUsers,
    required this.members,
    required this.whiteboardData,
  });

  factory WhiteboardUpdatedData.fromJson(Map<String, dynamic> json) {
    return WhiteboardUpdatedData(
      status: json['status'] as String,
      whiteboardUsers: List<WhiteboardUser>.from(
          (json['whiteboardUsers'] as List)
              .map((x) => WhiteboardUser.fromMap(x))),
      members: List<Participant>.from(
          (json['members'] as List).map((x) => Participant.fromMap(x))),
      whiteboardData: WhiteboardData.fromMap(json['whiteboardData']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'whiteboardUsers': whiteboardUsers.map((x) => x.toMap()).toList(),
      'members': members.map((x) => x.toMap()).toList(),
      'whiteboardData': whiteboardData.toMap(),
    };
  }
}

class WhiteboardActionData {
  final String action;
  final ShapePayload payload;

  WhiteboardActionData({
    required this.action,
    required this.payload,
  });

  factory WhiteboardActionData.fromJson(Map<String, dynamic> json) {
    return WhiteboardActionData(
      action: json['action'] as String,
      payload: ShapePayload.fromMap(json['payload']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'payload': payload.toMap(),
    };
  }
}

class ConsumeResponse {
  final String id;
  final String producerId;
  final String kind;
  final RtpParameters rtpParameters;
  final String serverConsumerId;

  ConsumeResponse({
    required this.id,
    required this.producerId,
    required this.kind,
    required this.rtpParameters,
    required this.serverConsumerId,
  });

  // Factory method to create `ConsumeResponse` from a Map
  factory ConsumeResponse.fromMap(Map<String, dynamic> map) {
    return ConsumeResponse(
      id: map['id'] as String,
      producerId: map['producerId'] as String,
      kind: map['kind'] as String,
      rtpParameters:
          RtpParameters.fromMap(map['rtpParameters'] as Map<String, dynamic>),
      serverConsumerId: map['serverConsumerId'] as String,
    );
  }

  // Method to convert `ConsumeResponse` to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producerId': producerId,
      'kind': kind,
      'rtpParameters': rtpParameters.toMap(),
      'serverConsumerId': serverConsumerId,
    };
  }
}

class CreateWebRTCTransportResponse {
  final String id;
  final DtlsParameters dtlsParameters;
  final List<IceCandidate> iceCandidates;
  final IceParameters iceParameters;
  final String? error;

  CreateWebRTCTransportResponse({
    required this.id,
    required this.dtlsParameters,
    required this.iceCandidates,
    required this.iceParameters,
    this.error,
  });

  factory CreateWebRTCTransportResponse.fromMap(Map<String, dynamic> map) {
    return CreateWebRTCTransportResponse(
      id: map['id'] as String,
      dtlsParameters: DtlsParameters.fromMap(map['dtlsParameters']),
      iceCandidates: List<IceCandidate>.from(
          (map['iceCandidates'] as List).map((x) => IceCandidate.fromMap(x))),
      iceParameters: IceParameters.fromMap(map['iceParameters']),
      error: map['error'] as String?,
    );
  }

  factory CreateWebRTCTransportResponse.fromJson(Map<String, dynamic> json) {
    return CreateWebRTCTransportResponse(
      id: json['id'] as String,
      dtlsParameters: DtlsParameters.fromMap(json['dtlsParameters']),
      iceCandidates: List<IceCandidate>.from(
          (json['iceCandidates'] as List).map((x) => IceCandidate.fromMap(x))),
      iceParameters: IceParameters.fromMap(json['iceParameters']),
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dtlsParameters': dtlsParameters.toMap(),
      'iceCandidates': iceCandidates.map((x) => x.toMap()).toList(),
      'iceParameters': iceParameters,
      'error': error,
    };
  }
}

typedef MediaStream = flutter_webrtc.MediaStream;

// Whiteboard Methods
class LaunchConfigureWhiteboardOptions {
  // Map to hold dynamic properties
  final Map<String, dynamic> _extraProperties = {};

  LaunchConfigureWhiteboardOptions();

  // Operator to access properties like a dictionary
  dynamic operator [](String key) => _extraProperties[key];
  void operator []=(String key, dynamic value) => _extraProperties[key] = value;
}

typedef LaunchConfigureWhiteboardType = void Function(
    LaunchConfigureWhiteboardOptions options);

class CaptureCanvasStreamOptions {
  // Map to hold dynamic properties
  // final Map<String, dynamic> _extraProperties = {};

  CaptureCanvasStreamOptions();

  // Operator to access properties like a dictionary
  // dynamic operator [](String key) => _extraProperties[key];
  // void operator []=(String key, dynamic value) => _extraProperties[key] = value;
}

typedef CaptureCanvasStreamType = void Function(
    CaptureCanvasStreamOptions options);

abstract class CaptureCanvasStreamParameters {
  // dynamic operator [](String key);
}

// Background Methods
class LaunchBackgroundOptions {
  // Map to hold dynamic properties
  final Map<String, dynamic> _extraProperties = {};

  LaunchBackgroundOptions();

  // Operator to access properties like a dictionary
  dynamic operator [](String key) => _extraProperties[key];
  void operator []=(String key, dynamic value) => _extraProperties[key] = value;
}

typedef LaunchBackgroundType = void Function(LaunchBackgroundOptions options);
