import 'package:flutter/material.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:socket_io_client/socket_io_client.dart'; // Import the intl package for date formatting

/// This map contains the initial values for the state in the application.
/// It includes various properties related to the meeting room, participants, recording, audio/video settings, and more.
final Map<String, dynamic> initialValuesState = {
  // Room properties
  'roomName': "", // The name of the room
  'member': '', // The member's name
  'adminPasscode': '', // The admin passcode
  'islevel': '0', // The level of the user
  'coHost': "", // The co-host's name
  'coHostResponsibility': [
    // The responsibilities of the co-host
    {'name': 'participants', 'value': false, 'dedicated': false},
    {'name': 'media', 'value': false, 'dedicated': false},
    {'name': 'waiting', 'value': false, 'dedicated': false},
    {'name': 'chat', 'value': false, 'dedicated': false},
  ],
  'youAreCoHost': false, // Indicates if the user is a co-host
  'youAreHost': false, // Indicates if the user is the host
  'confirmedToRecord': false, // Indicates if the recording is confirmed
  'meetingDisplayType': 'media', // The display type of the meeting
  'meetingVideoOptimized': false, // Indicates if the meeting video is optimized
  'eventType': 'webinar', // The type of the event
  'participants': [], // The list of participants
  'filteredParticipants': [], // The filtered list of participants
  'participantsCounter': 0, // The counter for participants
  'participantsFilter': '', // The filter for participants
  'consumeSockets': <Map<String, Socket>>[], // The consumed sockets
  'rtpCapabilities': {}, // The RTP capabilities
  'roomRecvIPs': [], // The received IPs in the room
  'meetingRoomParams': null, // The parameters of the meeting room
  'itemPageLimit': 4, // The limit of items per page
  'audioOnlyRoom': false, // Indicates if it's an audio-only room
  'addForBasic': false, // Indicates if it's added for basic
  'screenPageLimit': 4, // The limit of screens per page
  'shareScreenStarted': false, // Indicates if the screen sharing is started
  'shared': false, // Indicates if it's shared
  'targetOrientation': 'landscape', // The target orientation
  'vidCons': [], // The video consumers
  'frameRate': 5, // The frame rate
  'hParams': null, // The horizontal parameters
  'vParams': null, // The vertical parameters
  'screenParams': null, // The screen parameters
  'aParams': null, // The audio parameters
  'recordingAudioPausesLimit': 0, // The limit of audio recording pauses
  'recordingAudioPausesCount': 0, // The count of audio recording pauses
  'recordingAudioSupport': false, // Indicates if audio recording is supported
  'recordingAudioPeopleLimit': 0, // The limit of people for audio recording
  'recordingAudioParticipantsTimeLimit':
      0, // The time limit for audio recording per participant
  'recordingVideoPausesCount': 0, // The count of video recording pauses
  'recordingVideoPausesLimit': 0, // The limit of video recording pauses
  'recordingVideoSupport': false, // Indicates if video recording is supported
  'recordingVideoPeopleLimit': 0, // The limit of people for video recording
  'recordingVideoParticipantsTimeLimit':
      0, // The time limit for video recording per participant
  'recordingAllParticipantsSupport':
      false, // Indicates if recording all participants is supported
  'recordingVideoParticipantsSupport':
      false, // Indicates if recording video participants is supported
  'recordingAllParticipantsFullRoomSupport':
      false, // Indicates if recording all participants in a full room is supported
  'recordingVideoParticipantsFullRoomSupport':
      false, // Indicates if recording video participants in a full room is supported
  'recordingPreferredOrientation':
      'landscape', // The preferred orientation for recording
  'recordingSupportForOtherOrientation':
      false, // Indicates if recording supports other orientations
  'recordingMultiFormatsSupport':
      false, // Indicates if recording supports multiple formats
  'firstAll': false, // Indicates if it's the first all
  'updateMainWindow': false, // Indicates if the main window needs to be updated
  'firstRound': false, // Indicates if it's the first round
  'landScaped': false, // Indicates if it's landscaped
  'lockScreen': false, // Indicates if the screen is locked
  'screenId': '', // The ID of the screen
  'allVideoStreams': [], // The list of all video streams
  'newLimitedStreams': [], // The list of new limited streams
  'newLimitedStreamsIDs': <String>[], // The IDs of new limited streams
  'activeSounds': <String>[], // The list of active sounds
  'screenShareIDStream': '', // The ID of the screen share stream
  'screenShareNameStream': '', // The name of the screen share stream
  'adminIDStream': '', // The ID of the admin stream
  'adminNameStream': '', // The name of the admin stream
  'youYouStream': null, // The user's stream
  'youYouStreamIDs': <String>[], // The IDs of the user's stream
  'localStream': null, // The local stream
  'recordStarted': false, // Indicates if the recording is started
  'recordResumed': false, // Indicates if the recording is resumed
  'recordPaused': false, // Indicates if the recording is paused
  'recordStopped': false, // Indicates if the recording is stopped
  'adminRestrictSetting': false, // Indicates if the admin restricts the setting
  'videoRequestState': 'none', // The state of the video request
  'videoRequestTime':
      DateTime.fromMillisecondsSinceEpoch(0), // The time of the video request
  'localStreamVideo': null, // The local video stream
  'userDefaultVideoInputDevice':
      '', // The default video input device of the user
  'currentFacingMode': 'user', // The current facing mode of the camera
  'prevFacingMode': 'user', // The previous facing mode of the camera
  'defVideoID': '', // The default video ID
  'allowed': false, // Indicates if it's allowed
  'dispActiveNames': <String>[], // The names of the active displays
  'pDispActiveNames': <String>[], // The previous names of the active displays
  'activeNames': <String>[], // The active names
  'prevActiveNames': <String>[], // The previous active names
  'pActiveNames': <String>[], // The previous active names
  'membersReceived': false, // Indicates if the members are received
  'deferScreenReceived': false, // Indicates if the screen is deferred
  'hostFirstSwitch': false, // Indicates if the host switches first
  'micAction': false, // Indicates if there is a microphone action
  'screenAction': false, // Indicates if there is a screen action
  'chatAction': false, // Indicates if there is a chat action
  'audioRequestState': 'none', // The state of the audio request
  'screenRequestState': 'none', // The state of the screen request
  'chatRequestState': 'none', // The state of the chat request
  'audioRequestTime':
      DateTime.fromMillisecondsSinceEpoch(0), // The time of the audio request
  'screenRequestTime':
      DateTime.fromMillisecondsSinceEpoch(0), // The time of the screen request
  'chatRequestTime':
      DateTime.fromMillisecondsSinceEpoch(0), // The time of the chat request
  'updateRequestIntervalSeconds':
      240, // The interval for update requests in seconds
  'oldSoundIds': <String>[], // The IDs of old sounds
  'hostLabel': 'Host', // The label for the host
  'mainScreenFilled': false, // Indicates if the main screen is filled
  'localStreamScreen': null, // The local screen stream
  'screenAlreadyOn': false, // Indicates if the screen is already on
  'chatAlreadyOn': false, // Indicates if the chat is already on
  'redirectURL': '', // The redirect URL
  'oldAllStreams': [], // The list of old streams
  'adminVidID': '', // The ID of the admin video
  'streamNames': [], // The names of the streams
  'nonAlVideoStreams': [], // The non-al video streams
  'sortAudioLoudness': false, // Indicates if the audio is sorted by loudness
  'audioDecibels': [], // The audio decibels
  'mixedAlVideoStreams': [], // The mixed al video streams
  'nonAlVideoStreamsMuted': [], // The muted non-al video streams
  'paginatedStreams': [], // The paginated streams
  'localStreamAudio': null, // The local audio stream
  'defAudioID': '', // The default audio ID
  'userDefaultAudioInputDevice':
      '', // The default audio input device of the user
  'userDefaultAudioOutputDevice':
      '', // The default audio output device of the user
  'prevAudioInputDevice': '', // The previous audio input device
  'prevVideoInputDevice': '', // The previous video input device
  'audioPaused': false, // Indicates if the audio is paused
  'mainScreenPerson': null, // The person on the main screen
  'adminOnMainScreen': false, // Indicates if the admin is on the main screen
  'updateDateState': null, // The state of the update date
  'lastUpdate': null, // The last update
  'nForReadjustRecord': 0, // The number for readjusting the record
  'fixedPageLimit': 4, // The fixed limit for pages
  'removeAltGrid': false, // Indicates if the alternate grid is removed
  'nForReadjust': 0, // The number for readjusting
  'reOrderInterval': 30000, // The interval for reordering
  'fastReOrderInterval': 10000, // The interval for fast reordering
  'lastReOrderTime': 0, // The time of the last reorder
  'audStreamNames': [], // The names of the audio streams
  'currentUserPage': 0, // The current user page
  'isWideScreen': false, // Indicates if it's a wide screen
  'isMediumScreen': false, // Indicates if it's a medium screen
  'isSmallScreen': false, // Indicates if it's a small screen
  'addGrid': false, // Indicates if the grid is added
  'addAltGrid': false, // Indicates if the alternate grid is added
  'gridRows': 0, // The number of rows in the grid
  'gridCols': 0, // The number of columns in the grid
  'altGridRows': 0, // The number of rows in the alternate grid
  'altGridCols': 0, // The number of columns in the alternate grid
  'numberPages': 0, // The number of pages
  'currentStreams': [], // The current streams
  'showMiniView': false, // Indicates if the mini view is shown
  'nStream': null, // The stream number
  'deferReceive': false, // Indicates if the receive is deferred
  'allAudioStreams': [], // The list of all audio streams
  'remoteScreenStream': [], // The remote screen stream
  'screenProducer': null, // The screen producer
  'gotAllVids': false, // Indicates if all videos are received
  'paginationHeightWidth': 40, // The height and width of the pagination
  'paginationDirection': 'horizontal', // The direction of the pagination
  'screenForceFullDisplay':
      false, // Indicates if the screen forces full display
  'mainGridStream': <Widget>[], // The main grid stream
  'otherGridStreams': [<Widget>[], <Widget>[]], // The other grid streams
  'audioOnlyStreams': <Widget>[], // The audio-only streams
  'videoInputs': <MediaDeviceInfo>[], // The video input devices
  'audioInputs': <MediaDeviceInfo>[], // The audio input devices
  'meetingProgressTime': '00:00:00', // The progress time of the meeting
  'meetingElapsedTime': 0, // The elapsed time of the meeting
  'transportCreated': false, // Indicates if the transport is created
  'transportCreatedVideo': false, // Indicates if the video transport is created
  'transportCreatedAudio': false, // Indicates if the audio transport is created
  'transportCreatedScreen':
      false, // Indicates if the screen transport is created
  'producerTransport': null, // The producer transport
  'videoProducer': null, // The video producer
  'params': null, // The parameters
  'videoParams': null, // The video parameters
  'audioParams': null, // The audio parameters
  'audioProducer': null, // The audio producer
  'consumerTransports': [], // The consumer transports
  'consumingTransports': [], // The consuming transports
  'recordingMediaOptions': 'video', // The media options for recording
  'recordingAudioOptions': 'all', // The audio options for recording
  'recordingVideoOptions': 'all', // The video options for recording
  'recordingVideoType': 'fullDisplay', // The video type for recording
  'recordingVideoOptimized':
      false, // Indicates if the video recording is optimized
  'recordingDisplayType': 'media', // The display type for recording
  'recordingAddHLS': true, // Indicates if HLS is added for recording
  'recordingAddText': false, // Indicates if text is added for recording
  'recordingCustomText': 'add custom text', // The custom text for recording
  'recordingCustomTextPosition':
      'top', // The position of the custom text for recording
  'recordingCustomTextColor':
      '#ffffff', // The color of the custom text for recording
  'recordingNameTags': true, // Indicates if name tags are added for recording
  'recordingBackgroundColor': '#83c0e9', // The background color for recording
  'recordingNameTagsColor':
      '#ffffff', // The color of the name tags for recording
  'recordingOrientationVideo':
      'landscape', // The orientation of the video for recording
  'clearedToResume': true, // Indicates if it's cleared to resume
  'clearedToRecord': true, // Indicates if it's cleared to record
  'recordState': 'green', // The state of the record
  'showRecordButtons': false, // Indicates if the record buttons are shown
  'recordingProgressTime': '00:00:00', // The progress time of the recording
  'audioSwitching': false, // Indicates if audio switching is happening
  'videoSwitching': false, // Indicates if video switching is happening
  'videoAlreadyOn': false, // Indicates if the video is already on
  'audioAlreadyOn': false, // Indicates if the audio is already on
  'canLaunchRecord': true, // Indicates if recording can be launched
  'stopLaunchRecord':
      false, // Indicates if launching recording should be stopped
  'recordStartTime': null, // The start time of the recording
  'canRecord': false, // Indicates if recording is allowed
  'startReport': false, // Indicates if the report should start
  'endReport': false, // Indicates if the report should end
  'recordTimerInterval': 0, // The interval for the record timer
  'recordElapsedTime': 0, // The elapsed time of the record
  'isTimerRunning': false, // Indicates if the timer is running
  'canPauseResume': false, // Indicates if pausing/resuming is allowed
  'pauseLimit': 0, // The limit for pausing
  'pauseRecordCount': 0, // The count for pausing the record

  // Poll properties
  'polls': [], // The list of polls
  'poll': null, // The current poll

  // Breakout room properties
  'breakOutRoomStarted': false, // Indicates if the breakout room is started
  'breakOutRoomEnded': false, // Indicates if the breakout room is ended
  'breakOutRoomLimit': 0, // The limit of the breakout room
  'breakoutRooms': [], // The list of breakout rooms
  'currentRoomIndex': 0, // The current room index
  'canStartBreakout': false, // Indicates if the breakout can be started
  'hostNewRoom': -1, // The host for the new room
  'limitedBreakRoom': false, // Indicates if the breakout room is limited
  'mainRoomsLength': 0, // The length of the main rooms
  'memberRoom': null, // The member room
};
