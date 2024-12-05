// mediasfu_parameters.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../../types/types.dart' hide MediaStream;

class MediasfuParameters
    implements
        OnScreenChangesParameters,
        PrepopulateUserMediaParameters,
        UpdateRecordingParameters,
        StopRecordingParameters,
        SwitchVideoAltParameters,
        ClickVideoParameters,
        ClickAudioParameters,
        ClickScreenShareParameters,
        UpdateRoomParametersClientParameters,
        AllMembersParameters,
        AllMembersRestParameters,
        RoomRecordParamsParameters,
        BanParticipantParameters,
        ProducerMediaPausedParameters,
        ProducerMediaResumedParameters,
        ProducerMediaClosedParameters,
        ControlMediaHostParameters,
        UpdateConsumingDomainsParameters,
        RecordingNoticeParameters,
        BreakoutRoomUpdatedParameters,
        StartMeetingProgressTimerParameters,
        PaginationParameters,
        RecordingModalParameters,
        DisplaySettingsModalParameters,
        MediaSettingsModalParameters,
        BreakoutRoomsModalParameters,
        WaitingRoomModalParameters,
        ParticipantsModalParameters,
        RequestsModalParameters {
  // ======== Parameters ========

  // ---------------------
  // General Settings
  // ---------------------
  bool localUIMode;
  String roomName;
  String member;
  String adminPasscode;
  String islevel;
  String coHost;
  List<CoHostResponsibility> coHostResponsibility;
  bool youAreCoHost;
  bool youAreHost;
  bool confirmedToRecord;
  String meetingDisplayType;
  bool meetingVideoOptimized;
  EventType eventType;
  List<Participant> participants;
  List<Participant> filteredParticipants;
  int participantsCounter;
  String participantsFilter;

  // ---------------------
  // Media Details
  // ---------------------
  List<ConsumeSocket> consumeSockets;
  RtpCapabilities? rtpCapabilities;
  List<String> roomRecvIPs;
  MeetingRoomParams? meetingRoomParams;
  int itemPageLimit;
  bool audioOnlyRoom;
  bool addForBasic;
  int screenPageLimit;
  bool shareScreenStarted;
  bool shared;
  String targetOrientation;
  String targetResolution;
  String targetResolutionHost;
  VidCons vidCons;
  int frameRate;
  ProducerOptionsType? hParams;
  ProducerOptionsType? vParams;
  ProducerOptionsType? screenParams;
  ProducerOptionsType? aParams;

  // ---------------------
  // Recording Details
  // ---------------------
  int recordingAudioPausesLimit;
  int recordingAudioPausesCount;
  bool recordingAudioSupport;
  int recordingAudioPeopleLimit;
  int recordingAudioParticipantsTimeLimit;
  int recordingVideoPausesCount;
  int recordingVideoPausesLimit;
  bool recordingVideoSupport;
  int recordingVideoPeopleLimit;
  int recordingVideoParticipantsTimeLimit;
  bool recordingAllParticipantsSupport;
  bool recordingVideoParticipantsSupport;
  bool recordingAllParticipantsFullRoomSupport;
  bool recordingVideoParticipantsFullRoomSupport;
  String recordingPreferredOrientation;
  bool recordingSupportForOtherOrientation;
  bool recordingMultiFormatsSupport;

  // ---------------------
  // User Recording Parameters
  // ---------------------
  UserRecordingParams userRecordingParams;
  bool canRecord;
  bool startReport;
  bool endReport;
  Timer? recordTimerInterval;
  int? recordStartTime;
  int recordElapsedTime;
  bool isTimerRunning;
  bool canPauseResume;
  int recordChangeSeconds;
  int pauseLimit;
  int pauseRecordCount;
  bool canLaunchRecord;
  bool stopLaunchRecord;
  List<Participant> participantsAll;

  // ---------------------
  // Additional Parameters
  // ---------------------
  bool firstAll;
  bool updateMainWindow;
  bool firstRound;
  bool landScaped;
  bool lockScreen;
  String screenId;
  List<Stream> allVideoStreams;
  List<Stream> newLimitedStreams;
  List<String> newLimitedStreamsIDs;
  List<String> activeSounds;
  String screenShareIDStream;
  String screenShareNameStream;
  String adminIDStream;
  String adminNameStream;
  List<Stream> youYouStream;
  List<String> youYouStreamIDs;
  MediaStream? localStream;
  bool recordStarted;
  bool recordResumed;
  bool recordPaused;
  bool recordStopped;
  bool adminRestrictSetting;
  String videoRequestState;
  int? videoRequestTime;
  bool videoAction;
  MediaStream? localStreamVideo;
  String userDefaultVideoInputDevice;
  String currentFacingMode;
  String prevFacingMode;
  String defVideoID;
  bool allowed;
  List<String> dispActiveNames;
  List<String> pDispActiveNames;
  List<String> activeNames;
  List<String> prevActiveNames;
  List<String> pActiveNames;
  bool membersReceived;
  bool deferScreenReceived;
  bool hostFirstSwitch;
  bool micAction;
  bool screenAction;
  bool chatAction;
  String audioRequestState;
  String screenRequestState;
  String chatRequestState;
  int? audioRequestTime;
  int? screenRequestTime;
  int? chatRequestTime;
  int updateRequestIntervalSeconds;
  List<String> oldSoundIds;
  String hostLabel;
  bool mainScreenFilled;
  MediaStream? localStreamScreen;
  bool screenAlreadyOn;
  bool chatAlreadyOn;
  String redirectURL;
  List<Stream> oldAllStreams;
  String adminVidID;
  List<Stream> streamNames;
  List<Stream> nonAlVideoStreams;
  bool sortAudioLoudness;
  List<AudioDecibels> audioDecibels;
  List<Stream> mixedAlVideoStreams;
  List<Stream> nonAlVideoStreamsMuted;
  List<List<Stream>> paginatedStreams;
  MediaStream? localStreamAudio;
  String defAudioID;
  String userDefaultAudioInputDevice;
  String userDefaultAudioOutputDevice;
  String prevAudioInputDevice;
  String prevVideoInputDevice;
  bool audioPaused;
  String mainScreenPerson;
  bool adminOnMainScreen;
  List<ScreenState> screenStates;
  List<ScreenState> prevScreenStates;
  int? updateDateState;
  int? lastUpdate;
  int nForReadjustRecord;
  int fixedPageLimit;
  bool removeAltGrid;
  int nForReadjust;
  int reorderInterval;
  int fastReorderInterval;
  int lastReorderTime;
  List<Stream> audStreamNames;
  int currentUserPage;
  double mainHeightWidth;
  double prevMainHeightWidth;
  bool prevDoPaginate;
  bool doPaginate;
  bool shareEnded;
  List<Stream> lStreams;
  List<Stream> chatRefStreams;
  double controlHeight;
  bool isWideScreen;
  bool isMediumScreen;
  bool isSmallScreen;
  bool addGrid;
  bool addAltGrid;
  int gridRows;
  int gridCols;
  int altGridRows;
  int altGridCols;
  int numberPages;
  List<Stream> currentStreams;
  bool showMiniView;
  MediaStream? nStream;
  bool deferReceive;
  List<Stream> allAudioStreams;
  List<Stream> remoteScreenStream;
  Producer? screenProducer;
  Producer? localScreenProducer;
  bool gotAllVids;
  double paginationHeightWidth;
  String paginationDirection;
  GridSizes gridSizes;
  bool screenForceFullDisplay;
  List<Widget> mainGridStream;
  List<List<Widget>> otherGridStreams;
  List<Widget> audioOnlyStreams;
  List<MediaDeviceInfo> videoInputs;
  List<MediaDeviceInfo> audioInputs;
  String meetingProgressTime;
  int meetingElapsedTime;
  List<Participant> refParticipants;

  // ---------------------
  // Messages
  // ---------------------
  List<Message> messages;
  bool startDirectMessage;
  Participant? directMessageDetails;
  bool showMessagesBadge;

  // ---------------------
  // Event Settings
  // ---------------------
  String audioSetting;
  String videoSetting;
  String screenshareSetting;
  String chatSetting;

  // ---------------------
  // Display Settings
  // ---------------------
  bool autoWave;
  bool forceFullDisplay;
  bool prevForceFullDisplay;
  String prevMeetingDisplayType;

  // ---------------------
  // Waiting Room
  // ---------------------
  String waitingRoomFilter;
  List<WaitingRoomParticipant> waitingRoomList;
  int waitingRoomCounter;
  List<WaitingRoomParticipant> filteredWaitingRoomList;

  // ---------------------
  // Requests
  // ---------------------
  String requestFilter;
  List<Request> requestList;
  int requestCounter;
  List<Request> filteredRequestList;

  // ---------------------
  // Total Requests and Waiting Room
  // ---------------------
  int totalReqWait;

  // ---------------------
  // Alerts and Modals
  // ---------------------
  bool alertVisible;
  String alertMessage;
  String alertType;
  int alertDuration;

  // ---------------------
  // Progress Timer
  // ---------------------
  bool progressTimerVisible;
  int progressTimerValue;

  // ---------------------
  // Menu Modals
  // ---------------------
  bool isMenuModalVisible;
  bool isRecordingModalVisible;
  bool isSettingsModalVisible;
  bool isRequestsModalVisible;
  bool isWaitingModalVisible;
  bool isCoHostModalVisible;
  bool isMediaSettingsModalVisible;
  bool isDisplaySettingsModalVisible;

  // ---------------------
  // Other Modals
  // ---------------------
  bool isParticipantsModalVisible;
  bool isMessagesModalVisible;
  bool isConfirmExitModalVisible;
  bool isConfirmHereModalVisible;
  bool isShareEventModalVisible;
  bool isLoadingModalVisible;

  // ---------------------
  // Recording Options
  // ---------------------
  String recordingMediaOptions;
  String recordingAudioOptions;
  String recordingVideoOptions;
  String recordingVideoType;
  bool recordingVideoOptimized;
  String recordingDisplayType;
  bool recordingAddHLS;
  bool recordingNameTags;
  String recordingBackgroundColor;
  String recordingNameTagsColor;
  bool recordingAddText;
  String recordingCustomText;
  String recordingCustomTextPosition;
  String recordingCustomTextColor;
  String recordingOrientationVideo;
  bool clearedToResume;
  bool clearedToRecord;
  String recordState;
  bool showRecordButtons;
  String recordingProgressTime;
  bool audioSwitching;
  bool videoSwitching;

  // ---------------------
  // Media States
  // ---------------------
  bool videoAlreadyOn;
  bool audioAlreadyOn;
  ComponentSizes componentSizes;

  // ---------------------
  // Permissions
  // ---------------------
  bool hasCameraPermission;
  bool hasAudioPermission;

  // ---------------------
  // Transports
  // ---------------------
  bool transportCreated;
  bool? localTransportCreated;
  bool transportCreatedVideo;
  bool transportCreatedAudio;
  bool transportCreatedScreen;
  Transport? producerTransport;
  Transport? localProducerTransport;
  Producer? videoProducer;
  Producer? localVideoProducer;
  ProducerOptionsType? params;
  ProducerOptionsType? videoParams;
  ProducerOptionsType? audioParams;
  Producer? audioProducer;
  Producer? localAudioProducer;
  List<TransportType> consumerTransports;
  List<String> consumingTransports;

  // ---------------------
  // Polls
  // ---------------------
  List<Poll> polls;
  Poll? poll;
  bool isPollModalVisible;

  // ---------------------
  // Breakout Rooms
  // ---------------------
  List<List<BreakoutParticipant>> breakoutRooms;
  int currentRoomIndex;
  bool canStartBreakout;
  bool breakOutRoomStarted;
  bool breakOutRoomEnded;
  int hostNewRoom;
  List<BreakoutParticipant> limitedBreakRoom;
  int mainRoomsLength;
  int memberRoom;
  bool isBreakoutRoomsModalVisible;

  // ---------------------
  bool validated;
  Device? device;
  Socket? socket;
  Socket? localSocket;
  bool checkMediaPermission;
  bool onWeb;

  // ======== Functions ========

  // General Update Functions
  void Function(String) updateRoomName;
  void Function(String) updateMember;
  void Function(String) updateAdminPasscode;
  void Function(bool) updateYouAreCoHost;
  void Function(bool) updateYouAreHost;
  void Function(String) updateIslevel;
  void Function(String) updateCoHost;
  void Function(List<CoHostResponsibility>) updateCoHostResponsibility;
  void Function(bool) updateConfirmedToRecord;
  void Function(String) updateMeetingDisplayType;
  void Function(bool) updateMeetingVideoOptimized;
  void Function(EventType) updateEventType;
  void Function(List<Participant>) updateParticipants;
  void Function(int) updateParticipantsCounter;
  void Function(String) updateParticipantsFilter;
  void Function(List<ConsumeSocket>) updateConsumeSockets;
  void Function(RtpCapabilities?) updateRtpCapabilities;
  void Function(List<String>) updateRoomRecvIPs;
  void Function(MeetingRoomParams?) updateMeetingRoomParams;
  void Function(int) updateItemPageLimit;
  void Function(bool) updateAudioOnlyRoom;
  void Function(bool) updateAddForBasic;
  void Function(int) updateScreenPageLimit;
  void Function(bool) updateShareScreenStarted;
  void Function(bool) updateShared;
  void Function(String) updateTargetOrientation;
  void Function(String) updateTargetResolution;
  void Function(String) updateTargetResolutionHost;
  void Function(VidCons) updateVidCons;
  void Function(int) updateFrameRate;
  void Function(ProducerOptionsType?) updateHParams;
  void Function(ProducerOptionsType?) updateVParams;
  void Function(ProducerOptionsType?) updateScreenParams;
  void Function(ProducerOptionsType?) updateAParams;
  void Function(int) updateRecordingAudioPausesLimit;
  void Function(int) updateRecordingAudioPausesCount;
  void Function(bool) updateRecordingAudioSupport;
  void Function(int) updateRecordingAudioPeopleLimit;
  void Function(int) updateRecordingAudioParticipantsTimeLimit;
  void Function(int) updateRecordingVideoPausesCount;
  void Function(int) updateRecordingVideoPausesLimit;
  void Function(bool) updateRecordingVideoSupport;
  void Function(int) updateRecordingVideoPeopleLimit;
  void Function(int) updateRecordingVideoParticipantsTimeLimit;
  void Function(bool) updateRecordingAllParticipantsSupport;
  void Function(bool) updateRecordingVideoParticipantsSupport;
  void Function(bool) updateRecordingAllParticipantsFullRoomSupport;
  void Function(bool) updateRecordingVideoParticipantsFullRoomSupport;
  void Function(String) updateRecordingPreferredOrientation;
  void Function(bool) updateRecordingSupportForOtherOrientation;
  void Function(bool) updateRecordingMultiFormatsSupport;
  void Function(UserRecordingParams) updateUserRecordingParams;
  void Function(bool) updateCanRecord;
  void Function(bool) updateStartReport;
  void Function(bool) updateEndReport;
  void Function(dynamic) updateRecordTimerInterval;
  void Function(int?) updateRecordStartTime;
  void Function(int) updateRecordElapsedTime;
  void Function(bool) updateIsTimerRunning;
  void Function(bool) updateCanPauseResume;
  void Function(int) updateRecordChangeSeconds;
  void Function(int) updatePauseLimit;
  void Function(int) updatePauseRecordCount;
  void Function(bool) updateCanLaunchRecord;
  void Function(bool) updateStopLaunchRecord;
  void Function(List<Participant>) updateParticipantsAll;
  void Function(bool) updateFirstAll;
  void Function(bool) updateUpdateMainWindow;
  void Function(bool) updateFirstRound;
  void Function(bool) updateLandScaped;
  void Function(bool) updateLockScreen;
  void Function(String) updateScreenId;
  void Function(List<Stream>) updateAllVideoStreams;
  void Function(List<Stream>) updateNewLimitedStreams;
  void Function(List<String>) updateNewLimitedStreamsIDs;
  void Function(List<String>) updateActiveSounds;
  void Function(String) updateScreenShareIDStream;
  void Function(String) updateScreenShareNameStream;
  void Function(String) updateAdminIDStream;
  void Function(String) updateAdminNameStream;
  void Function(List<Stream>) updateYouYouStream;
  void Function(List<String>) updateYouYouStreamIDs;
  void Function(MediaStream?) updateLocalStream;
  void Function(bool) updateRecordStarted;
  void Function(bool) updateRecordResumed;
  void Function(bool) updateRecordPaused;
  void Function(bool) updateRecordStopped;
  void Function(bool) updateAdminRestrictSetting;
  void Function(String) updateVideoRequestState;
  void Function(int?) updateVideoRequestTime;
  void Function(bool) updateVideoAction;
  void Function(MediaStream?) updateLocalStreamVideo;
  void Function(String) updateUserDefaultVideoInputDevice;
  void Function(String) updateCurrentFacingMode;
  void Function(String) updatePrevFacingMode;
  void Function(String) updateDefVideoID;
  void Function(bool) updateAllowed;
  void Function(List<String>) updateDispActiveNames;
  void Function(List<String>) updatePDispActiveNames;
  void Function(List<String>) updateActiveNames;
  void Function(List<String>) updatePrevActiveNames;
  void Function(List<String>) updatePActiveNames;
  void Function(bool) updateMembersReceived;
  void Function(bool) updateDeferScreenReceived;
  void Function(bool) updateHostFirstSwitch;
  void Function(bool) updateMicAction;
  void Function(bool) updateScreenAction;
  void Function(bool) updateChatAction;
  void Function(String?) updateAudioRequestState;
  void Function(String?) updateScreenRequestState;
  void Function(String?) updateChatRequestState;
  void Function(int?) updateAudioRequestTime;
  void Function(int?) updateScreenRequestTime;
  void Function(int?) updateChatRequestTime;
  void Function(List<String>) updateOldSoundIds;
  void Function(String) updateHostLabel;
  void Function(bool) updateMainScreenFilled;
  void Function(MediaStream?) updateLocalStreamScreen;
  void Function(bool) updateScreenAlreadyOn;
  void Function(bool) updateChatAlreadyOn;
  void Function(String) updateRedirectURL;
  void Function(List<Stream>) updateOldAllStreams;
  void Function(String) updateAdminVidID;
  void Function(List<Stream>) updateStreamNames;
  void Function(List<Stream>) updateNonAlVideoStreams;
  void Function(bool) updateSortAudioLoudness;
  void Function(List<AudioDecibels>) updateAudioDecibels;
  void Function(List<Stream>) updateMixedAlVideoStreams;
  void Function(List<Stream>) updateNonAlVideoStreamsMuted;
  void Function(List<List<Stream>>) updatePaginatedStreams;
  void Function(MediaStream?) updateLocalStreamAudio;
  void Function(String) updateDefAudioID;
  void Function(String) updateUserDefaultAudioInputDevice;
  void Function(String) updateUserDefaultAudioOutputDevice;
  void Function(String) updatePrevAudioInputDevice;
  void Function(String) updatePrevVideoInputDevice;
  void Function(bool) updateAudioPaused;
  void Function(String) updateMainScreenPerson;
  void Function(bool) updateAdminOnMainScreen;
  void Function(List<ScreenState>) updateScreenStates;
  void Function(List<ScreenState>) updatePrevScreenStates;
  void Function(dynamic) updateUpdateDateState;
  void Function(dynamic) updateLastUpdate;
  void Function(int) updateNForReadjustRecord;
  void Function(int) updateFixedPageLimit;
  void Function(bool) updateRemoveAltGrid;
  void Function(int) updateNForReadjust;
  void Function(int) updateLastReorderTime;
  void Function(List<Stream>) updateAudStreamNames;
  void Function(int) updateCurrentUserPage;
  void Function(double) updateMainHeightWidth;
  void Function(double) updatePrevMainHeightWidth;
  void Function(bool) updatePrevDoPaginate;
  void Function(bool) updateDoPaginate;
  void Function(bool) updateShareEnded;
  void Function(List<Stream>) updateLStreams;
  void Function(List<Stream>) updateChatRefStreams;
  void Function(double) updateControlHeight;
  void Function(bool) updateIsWideScreen;
  void Function(bool) updateIsMediumScreen;
  void Function(bool) updateIsSmallScreen;
  void Function(bool) updateAddGrid;
  void Function(bool) updateAddAltGrid;
  void Function(int) updateGridRows;
  void Function(int) updateGridCols;
  void Function(int) updateAltGridRows;
  void Function(int) updateAltGridCols;
  void Function(int) updateNumberPages;
  void Function(List<Stream>) updateCurrentStreams;
  void Function(bool) updateShowMiniView;
  void Function(MediaStream?) updateNStream;
  void Function(bool) updateDeferReceive;
  void Function(List<Stream>) updateAllAudioStreams;
  void Function(List<Stream>) updateRemoteScreenStream;
  void Function(Producer?) updateScreenProducer;
  void Function(Producer?)? updateLocalScreenProducer;
  void Function(bool) updateGotAllVids;
  void Function(int) updatePaginationHeightWidth;
  void Function(String) updatePaginationDirection;
  void Function(GridSizes) updateGridSizes;
  void Function(bool) updateScreenForceFullDisplay;
  void Function(List<Widget>) updateMainGridStream;
  void Function(List<List<Widget>>) updateOtherGridStreams;
  void Function(List<Widget>) updateAudioOnlyStreams;
  void Function(List<MediaDeviceInfo>) updateVideoInputs;
  void Function(List<MediaDeviceInfo>) updateAudioInputs;
  void Function(String) updateMeetingProgressTime;
  void Function(int) updateMeetingElapsedTime;
  void Function(List<Participant>) updateRefParticipants;
  void Function(List<Message>) updateMessages;
  void Function(bool) updateStartDirectMessage;
  void Function(Participant?) updateDirectMessageDetails;
  void Function(bool) updateShowMessagesBadge;
  void Function(String) updateAudioSetting;
  void Function(String) updateVideoSetting;
  void Function(String) updateScreenshareSetting;
  void Function(String) updateChatSetting;
  void Function(bool) updateAutoWave;
  void Function(bool) updateForceFullDisplay;
  void Function(bool) updatePrevForceFullDisplay;
  void Function(String) updatePrevMeetingDisplayType;
  void Function(String) updateWaitingRoomFilter;
  void Function(List<WaitingRoomParticipant>) updateWaitingRoomList;
  void Function(int) updateWaitingRoomCounter;
  void Function(String) updateRequestFilter;
  void Function(List<Request>) updateRequestList;
  void Function(int) updateRequestCounter;
  void Function(int) updateTotalReqWait;
  void Function(bool) updateIsMenuModalVisible;
  void Function(bool) updateIsRecordingModalVisible;
  void Function(bool) updateIsSettingsModalVisible;
  void Function(bool) updateIsRequestsModalVisible;
  void Function(bool) updateIsWaitingModalVisible;
  void Function(bool) updateIsCoHostModalVisible;
  void Function(bool) updateIsMediaSettingsModalVisible;
  void Function(bool) updateIsDisplaySettingsModalVisible;
  void Function(bool) updateIsParticipantsModalVisible;
  void Function(bool) updateIsMessagesModalVisible;
  void Function(bool) updateIsConfirmExitModalVisible;
  void Function(bool) updateIsConfirmHereModalVisible;
  void Function(bool) updateIsLoadingModalVisible;
  void Function(String) updateRecordingMediaOptions;
  void Function(String) updateRecordingAudioOptions;
  void Function(String) updateRecordingVideoOptions;
  void Function(String) updateRecordingVideoType;
  void Function(bool) updateRecordingVideoOptimized;
  void Function(String) updateRecordingDisplayType;
  void Function(bool) updateRecordingAddHLS;
  void Function(bool) updateRecordingNameTags;
  void Function(String) updateRecordingBackgroundColor;
  void Function(String) updateRecordingNameTagsColor;
  void Function(bool) updateRecordingAddText;
  void Function(String) updateRecordingCustomText;
  void Function(String) updateRecordingCustomTextPosition;
  void Function(String) updateRecordingCustomTextColor;
  void Function(String) updateRecordingOrientationVideo;
  void Function(bool) updateClearedToResume;
  void Function(bool) updateClearedToRecord;
  void Function(String) updateRecordState;
  void Function(bool) updateShowRecordButtons;
  void Function(String) updateRecordingProgressTime;
  void Function(bool) updateAudioSwitching;
  void Function(bool) updateVideoSwitching;
  void Function(bool) updateVideoAlreadyOn;
  void Function(bool) updateAudioAlreadyOn;
  void Function(ComponentSizes) updateComponentSizes;
  void Function(bool) updateHasCameraPermission;
  void Function(bool) updateHasAudioPermission;
  void Function(bool) updateTransportCreated;
  void Function(bool)? updateLocalTransportCreated;
  void Function(bool) updateTransportCreatedVideo;
  void Function(bool) updateTransportCreatedAudio;
  void Function(bool) updateTransportCreatedScreen;
  void Function(Transport?) updateProducerTransport;
  void Function(Transport?)? updateLocalProducerTransport;
  void Function(Producer?) updateVideoProducer;
  void Function(Producer?)? updateLocalVideoProducer;
  void Function(ProducerOptionsType?) updateParams;
  void Function(ProducerOptionsType?) updateVideoParams;
  void Function(ProducerOptionsType?) updateAudioParams;
  void Function(Producer?) updateAudioProducer;
  void Function(Producer?)? updateLocalAudioProducer;
  void Function(List<TransportType>) updateConsumerTransports;
  void Function(List<String>) updateConsumingTransports;
  void Function(List<Poll>) updatePolls;
  void Function(Poll?) updatePoll;
  void Function(bool) updateIsPollModalVisible;
  void Function(List<List<BreakoutParticipant>>) updateBreakoutRooms;
  void Function(int) updateCurrentRoomIndex;
  void Function(bool) updateCanStartBreakout;
  void Function(bool) updateBreakOutRoomStarted;
  void Function(bool) updateBreakOutRoomEnded;
  void Function(int) updateHostNewRoom;
  void Function(List<BreakoutParticipant>) updateLimitedBreakRoom;
  void Function(int) updateMainRoomsLength;
  void Function(int) updateMemberRoom;
  void Function(bool) updateIsBreakoutRoomsModalVisible;

  String Function() checkOrientation;
  void Function(Device?) updateDevice;
  void Function(Socket?) updateSocket;
  void Function(Socket?)? updateLocalSocket;
  void Function(bool) updateValidated;
  ShowAlert showAlert;
  ResponseJoinRoom roomData; // joinRoom response

  // Functions MediaSFU
  final UpdateMiniCardsGridType updateMiniCardsGrid;
  final MixStreamsType mixStreams;
  final DispStreamsType dispStreams;
  final StopShareScreenType stopShareScreen;
  final CheckScreenShareType checkScreenShare;
  final StartShareScreenType startShareScreen;
  final RequestScreenShareType requestScreenShare;
  final ReorderStreamsType reorderStreams;
  final PrepopulateUserMediaType prepopulateUserMedia;
  final GetVideosType getVideos;
  final RePortType rePort;
  final TriggerType trigger;
  final ConsumerResumeType consumerResume;
  final ConnectSendTransportType connectSendTransport;
  final ConnectSendTransportAudioType connectSendTransportAudio;
  final ConnectSendTransportVideoType connectSendTransportVideo;
  final ConnectSendTransportScreenType connectSendTransportScreen;
  final ProcessConsumerTransportsType processConsumerTransports;
  final ResumePauseStreamsType resumePauseStreams;
  final ReadjustType readjust;
  final CheckGridType checkGrid;
  final GetEstimateType getEstimate;
  final CalculateRowsAndColumnsType calculateRowsAndColumns;
  final AddVideosGridType addVideosGrid;
  final OnScreenChangesType onScreenChanges;
  final SleepType sleep;
  final ChangeVidsType changeVids;
  final CompareActiveNamesType compareActiveNames;
  final CompareScreenStatesType compareScreenStates;
  final CreateSendTransportType createSendTransport;
  final ResumeSendTransportAudioType resumeSendTransportAudio;
  final ReceiveAllPipedTransportsType receiveAllPipedTransports;
  final DisconnectSendTransportVideoType disconnectSendTransportVideo;
  final DisconnectSendTransportAudioType disconnectSendTransportAudio;
  final DisconnectSendTransportScreenType disconnectSendTransportScreen;
  final GetPipedProducersAltType getPipedProducersAlt;
  final SignalNewConsumerTransportType signalNewConsumerTransport;
  final ConnectRecvTransportType connectRecvTransport;
  final ReUpdateInterType reUpdateInter;
  final UpdateParticipantAudioDecibelsType updateParticipantAudioDecibels;
  final CloseAndResizeType closeAndResize;
  final AutoAdjustType autoAdjust;
  final SwitchUserVideoAltType switchUserVideoAlt;
  final SwitchUserVideoType switchUserVideo;
  final SwitchUserAudioType switchUserAudio;
  final GetDomainsType getDomains;
  final FormatNumberType formatNumber;
  final ConnectIpsType connectIps;
  ConnectLocalIpsType? connectLocalIps;
  final CreateDeviceClientType createDeviceClient;
  final HandleCreatePollType handleCreatePoll;
  final HandleVotePollType handleVotePoll;
  final HandleEndPollType handleEndPoll;
  final ResumePauseAudioStreamsType resumePauseAudioStreams;
  final ProcessConsumerTransportsAudioType processConsumerTransportsAudio;
  final CheckPermissionType checkPermission;
  final StreamSuccessVideoType streamSuccessVideo;
  final StreamSuccessAudioType streamSuccessAudio;
  final StreamSuccessScreenType streamSuccessScreen;
  final StreamSuccessAudioSwitchType streamSuccessAudioSwitch;
  final ClickVideoType clickVideo;
  final ClickAudioType clickAudio;
  final ClickScreenShareType clickScreenShare;
  final SwitchVideoAltType switchVideoAlt;
  final RequestPermissionCameraType requestPermissionCamera;
  final RequestPermissionAudioType requestPermissionAudio;

  // Background-related variables; Not Implemented Yet
  String? customImage;
  String? selectedImage;
  MediaStream? segmentVideo;
  dynamic selfieSegmentation;
  bool pauseSegmentation;
  MediaStream? processedStream;
  bool keepBackground;
  bool backgroundHasChanged;
  MediaStream? virtualStream;
  dynamic mainCanvas;
  bool prevKeepBackground;
  bool appliedBackground;
  bool isBackgroundModalVisible;
  bool autoClickBackground;

  // Update functions
  void Function(String?) updateCustomImage;
  void Function(String?) updateSelectedImage;
  void Function(MediaStream?) updateSegmentVideo;
  void Function(dynamic) updateSelfieSegmentation;
  void Function(bool) updatePauseSegmentation;
  void Function(MediaStream?) updateProcessedStream;
  void Function(bool) updateKeepBackground;
  void Function(bool) updateBackgroundHasChanged;
  void Function(MediaStream?) updateVirtualStream;
  void Function(dynamic) updateMainCanvas;
  void Function(bool) updatePrevKeepBackground;
  void Function(bool) updateAppliedBackground;
  void Function(bool) updateIsBackgroundModalVisible;
  void Function(bool) updateAutoClickBackground;

  // Whiteboard-related variables; Not Implemented Yet
  List<WhiteboardUser> whiteboardUsers;
  int? currentWhiteboardIndex;
  bool canStartWhiteboard;
  bool whiteboardStarted;
  bool whiteboardEnded;
  int whiteboardLimit;
  bool isWhiteboardModalVisible;
  bool isConfigureWhiteboardModalVisible;
  List<dynamic> shapes;
  bool useImageBackground;
  List<dynamic> redoStack;
  List<String> undoStack;
  MediaStream? canvasStream;
  dynamic canvasWhiteboard;

  // Screenboard-related variables; Not Implemented Yet
  dynamic canvasScreenboard;
  MediaStream? processedScreenStream;
  bool annotateScreenStream;
  dynamic mainScreenCanvas;
  bool isScreenboardModalVisible;

  // Update functions
  void Function(List<WhiteboardUser>) updateWhiteboardUsers;
  void Function(int?) updateCurrentWhiteboardIndex;
  void Function(bool) updateCanStartWhiteboard;
  void Function(bool) updateWhiteboardStarted;
  void Function(bool) updateWhiteboardEnded;
  void Function(int) updateWhiteboardLimit;
  void Function(bool) updateIsWhiteboardModalVisible;
  void Function(bool) updateIsConfigureWhiteboardModalVisible;
  void Function(List<dynamic>) updateShapes;
  void Function(bool) updateUseImageBackground;
  void Function(List<dynamic>) updateRedoStack;
  void Function(List<String>) updateUndoStack;
  void Function(MediaStream?) updateCanvasStream;
  void Function(dynamic) updateCanvasWhiteboard;
  void Function(dynamic) updateCanvasScreenboard;
  void Function(MediaStream?) updateProcessedScreenStream;
  void Function(bool) updateAnnotateScreenStream;
  void Function(dynamic) updateMainScreenCanvas;
  void Function(bool) updateIsScreenboardModalVisible;

  // Store property values in a map for dynamic access
  // final Map<String, dynamic> _parametersMap = {};

  // ======== Constructor ========
  MediasfuParameters({
    // ---------------------
    // General Settings Initialization
    // ---------------------
    required this.localUIMode,
    required this.roomName,
    required this.member,
    required this.adminPasscode,
    required this.islevel,
    required this.coHost,
    required this.coHostResponsibility,
    required this.youAreCoHost,
    required this.youAreHost,
    required this.confirmedToRecord,
    required this.meetingDisplayType,
    required this.meetingVideoOptimized,
    required this.eventType,
    required this.participants,
    required this.filteredParticipants,
    required this.participantsCounter,
    required this.participantsFilter,

    // ---------------------
    // Media Details Initialization
    // ---------------------
    required this.consumeSockets,
    this.rtpCapabilities,
    required this.roomRecvIPs,
    this.meetingRoomParams,
    required this.itemPageLimit,
    required this.audioOnlyRoom,
    required this.addForBasic,
    required this.screenPageLimit,
    required this.shareScreenStarted,
    required this.shared,
    required this.targetOrientation,
    required this.targetResolution,
    required this.targetResolutionHost,
    required this.vidCons,
    required this.frameRate,
    this.hParams,
    this.vParams,
    this.screenParams,
    this.aParams,

    // ---------------------
    // Recording Details Initialization
    // ---------------------
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

    // ---------------------
    // User Recording Parameters Initialization
    // ---------------------
    required this.userRecordingParams,
    required this.canRecord,
    required this.startReport,
    required this.endReport,
    this.recordTimerInterval,
    this.recordStartTime,
    required this.recordElapsedTime,
    required this.isTimerRunning,
    required this.canPauseResume,
    required this.recordChangeSeconds,
    required this.pauseLimit,
    required this.pauseRecordCount,
    required this.canLaunchRecord,
    required this.stopLaunchRecord,
    required this.participantsAll,

    // ---------------------
    // Additional Parameters Initialization
    // ---------------------
    required this.firstAll,
    required this.updateMainWindow,
    required this.firstRound,
    required this.landScaped,
    required this.lockScreen,
    required this.screenId,
    required this.allVideoStreams,
    required this.newLimitedStreams,
    required this.newLimitedStreamsIDs,
    required this.activeSounds,
    required this.screenShareIDStream,
    required this.screenShareNameStream,
    required this.adminIDStream,
    required this.adminNameStream,
    required this.youYouStream,
    required this.youYouStreamIDs,
    this.localStream,
    required this.recordStarted,
    required this.recordResumed,
    required this.recordPaused,
    required this.recordStopped,
    required this.adminRestrictSetting,
    required this.videoRequestState,
    this.videoRequestTime,
    required this.videoAction,
    this.localStreamVideo,
    required this.userDefaultVideoInputDevice,
    required this.currentFacingMode,
    required this.prevFacingMode,
    required this.defVideoID,
    required this.allowed,
    required this.dispActiveNames,
    required this.pDispActiveNames,
    required this.activeNames,
    required this.prevActiveNames,
    required this.pActiveNames,
    required this.membersReceived,
    required this.deferScreenReceived,
    required this.hostFirstSwitch,
    required this.micAction,
    required this.screenAction,
    required this.chatAction,
    required this.audioRequestState,
    required this.screenRequestState,
    required this.chatRequestState,
    this.audioRequestTime,
    this.screenRequestTime,
    this.chatRequestTime,
    required this.updateRequestIntervalSeconds,
    required this.oldSoundIds,
    required this.hostLabel,
    required this.mainScreenFilled,
    this.localStreamScreen,
    required this.screenAlreadyOn,
    required this.chatAlreadyOn,
    required this.redirectURL,
    required this.oldAllStreams,
    required this.adminVidID,
    required this.streamNames,
    required this.nonAlVideoStreams,
    required this.sortAudioLoudness,
    required this.audioDecibels,
    required this.mixedAlVideoStreams,
    required this.nonAlVideoStreamsMuted,
    required this.paginatedStreams,
    this.localStreamAudio,
    required this.defAudioID,
    required this.userDefaultAudioInputDevice,
    required this.userDefaultAudioOutputDevice,
    required this.prevAudioInputDevice,
    required this.prevVideoInputDevice,
    required this.audioPaused,
    required this.mainScreenPerson,
    required this.adminOnMainScreen,
    required this.screenStates,
    required this.prevScreenStates,
    this.updateDateState,
    this.lastUpdate,
    required this.nForReadjustRecord,
    required this.fixedPageLimit,
    required this.removeAltGrid,
    required this.nForReadjust,
    required this.reorderInterval,
    required this.fastReorderInterval,
    required this.lastReorderTime,
    required this.audStreamNames,
    required this.currentUserPage,
    required this.mainHeightWidth,
    required this.prevMainHeightWidth,
    required this.prevDoPaginate,
    required this.doPaginate,
    required this.shareEnded,
    required this.lStreams,
    required this.chatRefStreams,
    required this.controlHeight,
    required this.isWideScreen,
    required this.isMediumScreen,
    required this.isSmallScreen,
    required this.addGrid,
    required this.addAltGrid,
    required this.gridRows,
    required this.gridCols,
    required this.altGridRows,
    required this.altGridCols,
    required this.numberPages,
    required this.currentStreams,
    required this.showMiniView,
    this.nStream,
    required this.deferReceive,
    required this.allAudioStreams,
    required this.remoteScreenStream,
    this.screenProducer,
    this.localScreenProducer,
    required this.gotAllVids,
    required this.paginationHeightWidth,
    required this.paginationDirection,
    required this.gridSizes,
    required this.screenForceFullDisplay,
    required this.mainGridStream,
    required this.otherGridStreams,
    required this.audioOnlyStreams,
    required this.videoInputs,
    required this.audioInputs,
    required this.meetingProgressTime,
    required this.meetingElapsedTime,
    required this.refParticipants,

    // ---------------------
    // Messages Initialization
    // ---------------------
    required this.messages,
    required this.startDirectMessage,
    this.directMessageDetails,
    required this.showMessagesBadge,

    // ---------------------
    // Event Settings Initialization
    // ---------------------
    required this.audioSetting,
    required this.videoSetting,
    required this.screenshareSetting,
    required this.chatSetting,

    // ---------------------
    // Display Settings Initialization
    // ---------------------
    required this.autoWave,
    required this.forceFullDisplay,
    required this.prevForceFullDisplay,
    required this.prevMeetingDisplayType,

    // ---------------------
    // Waiting Room Initialization
    // ---------------------
    required this.waitingRoomFilter,
    required this.waitingRoomList,
    required this.waitingRoomCounter,
    required this.filteredWaitingRoomList,

    // ---------------------
    // Requests Initialization
    // ---------------------
    required this.requestFilter,
    required this.requestList,
    required this.requestCounter,
    required this.filteredRequestList,

    // ---------------------
    // Total Requests and Waiting Room Initialization
    // ---------------------
    required this.totalReqWait,

    // ---------------------
    // Alerts and Modals Initialization
    // ---------------------
    required this.alertVisible,
    required this.alertMessage,
    required this.alertType,
    required this.alertDuration,

    // ---------------------
    // Progress Timer Initialization
    // ---------------------
    required this.progressTimerVisible,
    required this.progressTimerValue,

    // ---------------------
    // Menu Modals Initialization
    // ---------------------
    required this.isMenuModalVisible,
    required this.isRecordingModalVisible,
    required this.isSettingsModalVisible,
    required this.isRequestsModalVisible,
    required this.isWaitingModalVisible,
    required this.isCoHostModalVisible,
    required this.isMediaSettingsModalVisible,
    required this.isDisplaySettingsModalVisible,

    // ---------------------
    // Other Modals Initialization
    // ---------------------
    required this.isParticipantsModalVisible,
    required this.isMessagesModalVisible,
    required this.isConfirmExitModalVisible,
    required this.isConfirmHereModalVisible,
    required this.isShareEventModalVisible,
    required this.isLoadingModalVisible,

    // ---------------------
    // Recording Options Initialization
    // ---------------------
    required this.recordingMediaOptions,
    required this.recordingAudioOptions,
    required this.recordingVideoOptions,
    required this.recordingVideoType,
    required this.recordingVideoOptimized,
    required this.recordingDisplayType,
    required this.recordingAddHLS,
    required this.recordingNameTags,
    required this.recordingBackgroundColor,
    required this.recordingNameTagsColor,
    required this.recordingAddText,
    required this.recordingCustomText,
    required this.recordingCustomTextPosition,
    required this.recordingCustomTextColor,
    required this.recordingOrientationVideo,
    required this.clearedToResume,
    required this.clearedToRecord,
    required this.recordState,
    required this.showRecordButtons,
    required this.recordingProgressTime,
    required this.audioSwitching,
    required this.videoSwitching,

    // ---------------------
    // Media States Initialization
    // ---------------------
    required this.videoAlreadyOn,
    required this.audioAlreadyOn,
    required this.componentSizes,

    // ---------------------
    // Permissions Initialization
    // ---------------------
    required this.hasCameraPermission,
    required this.hasAudioPermission,

    // ---------------------
    // Transports Initialization
    // ---------------------
    required this.transportCreated,
    this.localTransportCreated,
    required this.transportCreatedVideo,
    required this.transportCreatedAudio,
    required this.transportCreatedScreen,
    this.producerTransport,
    this.localProducerTransport,
    this.videoProducer,
    this.localVideoProducer,
    this.params,
    this.videoParams,
    this.audioParams,
    this.audioProducer,
    this.localAudioProducer,
    required this.consumerTransports,
    required this.consumingTransports,

    // ---------------------
    // Polls Initialization
    // ---------------------
    required this.polls,
    this.poll,
    required this.isPollModalVisible,

    // ---------------------
    // Breakout Rooms Initialization
    // ---------------------
    required this.breakoutRooms,
    required this.currentRoomIndex,
    required this.canStartBreakout,
    required this.breakOutRoomStarted,
    required this.breakOutRoomEnded,
    required this.hostNewRoom,
    required this.limitedBreakRoom,
    required this.mainRoomsLength,
    required this.memberRoom,
    required this.isBreakoutRoomsModalVisible,

    // Other Required variables
    required this.validated,
    this.device,
    this.socket,
    this.localSocket,
    required this.checkMediaPermission,
    required this.onWeb,
    required this.roomData,

    // ---------------------
    // Update Functions Initializa
    // Required general update functions
    required this.updateRoomName,
    required this.updateMember,
    required this.updateAdminPasscode,
    required this.updateYouAreCoHost,
    required this.updateYouAreHost,
    required this.updateIslevel,
    required this.updateCoHost,
    required this.updateCoHostResponsibility,
    required this.updateConfirmedToRecord,
    required this.updateMeetingDisplayType,
    required this.updateMeetingVideoOptimized,
    required this.updateEventType,
    required this.updateParticipants,
    required this.updateParticipantsCounter,
    required this.updateParticipantsFilter,
    required this.updateConsumeSockets,
    required this.updateRtpCapabilities,
    required this.updateRoomRecvIPs,
    required this.updateMeetingRoomParams,
    required this.updateItemPageLimit,
    required this.updateAudioOnlyRoom,
    required this.updateAddForBasic,
    required this.updateScreenPageLimit,
    required this.updateShareScreenStarted,
    required this.updateShared,
    required this.updateTargetOrientation,
    required this.updateTargetResolution,
    required this.updateTargetResolutionHost,
    required this.updateVidCons,
    required this.updateFrameRate,
    required this.updateHParams,
    required this.updateVParams,
    required this.updateScreenParams,
    required this.updateAParams,
    required this.updateRecordingAudioPausesLimit,
    required this.updateRecordingAudioPausesCount,
    required this.updateRecordingAudioSupport,
    required this.updateRecordingAudioPeopleLimit,
    required this.updateRecordingAudioParticipantsTimeLimit,
    required this.updateRecordingVideoPausesCount,
    required this.updateRecordingVideoPausesLimit,
    required this.updateRecordingVideoSupport,
    required this.updateRecordingVideoPeopleLimit,
    required this.updateRecordingVideoParticipantsTimeLimit,
    required this.updateRecordingAllParticipantsSupport,
    required this.updateRecordingVideoParticipantsSupport,
    required this.updateRecordingAllParticipantsFullRoomSupport,
    required this.updateRecordingVideoParticipantsFullRoomSupport,
    required this.updateRecordingPreferredOrientation,
    required this.updateRecordingSupportForOtherOrientation,
    required this.updateRecordingMultiFormatsSupport,
    required this.updateUserRecordingParams,
    required this.updateCanRecord,
    required this.updateStartReport,
    required this.updateEndReport,
    required this.updateRecordTimerInterval,
    required this.updateRecordStartTime,
    required this.updateRecordElapsedTime,
    required this.updateIsTimerRunning,
    required this.updateCanPauseResume,
    required this.updateRecordChangeSeconds,
    required this.updatePauseLimit,
    required this.updatePauseRecordCount,
    required this.updateCanLaunchRecord,
    required this.updateStopLaunchRecord,
    required this.updateParticipantsAll,
    required this.updateFirstAll,
    required this.updateUpdateMainWindow,
    required this.updateFirstRound,
    required this.updateLandScaped,
    required this.updateLockScreen,
    required this.updateScreenId,
    required this.updateAllVideoStreams,
    required this.updateNewLimitedStreams,
    required this.updateNewLimitedStreamsIDs,
    required this.updateActiveSounds,
    required this.updateScreenShareIDStream,
    required this.updateScreenShareNameStream,
    required this.updateAdminIDStream,
    required this.updateAdminNameStream,
    required this.updateYouYouStream,
    required this.updateYouYouStreamIDs,
    required this.updateLocalStream,
    required this.updateRecordStarted,
    required this.updateRecordResumed,
    required this.updateRecordPaused,
    required this.updateRecordStopped,
    required this.updateAdminRestrictSetting,
    required this.updateVideoRequestState,
    required this.updateVideoRequestTime,
    required this.updateVideoAction,
    required this.updateLocalStreamVideo,
    required this.updateUserDefaultVideoInputDevice,
    required this.updateCurrentFacingMode,
    required this.updatePrevFacingMode,
    required this.updateDefVideoID,
    required this.updateAllowed,
    required this.updateDispActiveNames,
    required this.updatePDispActiveNames,
    required this.updateActiveNames,
    required this.updatePrevActiveNames,
    required this.updatePActiveNames,
    required this.updateMembersReceived,
    required this.updateDeferScreenReceived,
    required this.updateHostFirstSwitch,
    required this.updateMicAction,
    required this.updateScreenAction,
    required this.updateChatAction,
    required this.updateAudioRequestState,
    required this.updateScreenRequestState,
    required this.updateChatRequestState,
    required this.updateAudioRequestTime,
    required this.updateScreenRequestTime,
    required this.updateChatRequestTime,
    required this.updateOldSoundIds,
    required this.updateHostLabel,
    required this.updateMainScreenFilled,
    required this.updateLocalStreamScreen,
    required this.updateScreenAlreadyOn,
    required this.updateChatAlreadyOn,
    required this.updateRedirectURL,
    required this.updateOldAllStreams,
    required this.updateAdminVidID,
    required this.updateStreamNames,
    required this.updateNonAlVideoStreams,
    required this.updateSortAudioLoudness,
    required this.updateAudioDecibels,
    required this.updateMixedAlVideoStreams,
    required this.updateNonAlVideoStreamsMuted,
    required this.updatePaginatedStreams,
    required this.updateLocalStreamAudio,
    required this.updateDefAudioID,
    required this.updateUserDefaultAudioInputDevice,
    required this.updateUserDefaultAudioOutputDevice,
    required this.updatePrevAudioInputDevice,
    required this.updatePrevVideoInputDevice,
    required this.updateAudioPaused,
    required this.updateMainScreenPerson,
    required this.updateAdminOnMainScreen,
    required this.updateScreenStates,
    required this.updatePrevScreenStates,
    required this.updateUpdateDateState,
    required this.updateLastUpdate,
    required this.updateNForReadjustRecord,
    required this.updateFixedPageLimit,
    required this.updateRemoveAltGrid,
    required this.updateNForReadjust,
    required this.updateLastReorderTime,
    required this.updateAudStreamNames,
    required this.updateCurrentUserPage,
    required this.updateMainHeightWidth,
    required this.updatePrevMainHeightWidth,
    required this.updatePrevDoPaginate,
    required this.updateDoPaginate,
    required this.updateShareEnded,
    required this.updateLStreams,
    required this.updateChatRefStreams,
    required this.updateControlHeight,
    required this.updateIsWideScreen,
    required this.updateIsMediumScreen,
    required this.updateIsSmallScreen,
    required this.updateAddGrid,
    required this.updateAddAltGrid,
    required this.updateGridRows,
    required this.updateGridCols,
    required this.updateAltGridRows,
    required this.updateAltGridCols,
    required this.updateNumberPages,
    required this.updateCurrentStreams,
    required this.updateShowMiniView,
    required this.updateNStream,
    required this.updateDeferReceive,
    required this.updateAllAudioStreams,
    required this.updateRemoteScreenStream,
    required this.updateScreenProducer,
    this.updateLocalScreenProducer,
    required this.updateGotAllVids,
    required this.updatePaginationHeightWidth,
    required this.updatePaginationDirection,
    required this.updateGridSizes,
    required this.updateScreenForceFullDisplay,
    required this.updateMainGridStream,
    required this.updateOtherGridStreams,
    required this.updateAudioOnlyStreams,
    required this.updateVideoInputs,
    required this.updateAudioInputs,
    required this.updateMeetingProgressTime,
    required this.updateMeetingElapsedTime,
    required this.updateRefParticipants,
    required this.updateMessages,
    required this.updateStartDirectMessage,
    required this.updateDirectMessageDetails,
    required this.updateShowMessagesBadge,
    required this.updateAudioSetting,
    required this.updateVideoSetting,
    required this.updateScreenshareSetting,
    required this.updateChatSetting,
    required this.updateAutoWave,
    required this.updateForceFullDisplay,
    required this.updatePrevForceFullDisplay,
    required this.updatePrevMeetingDisplayType,
    required this.updateWaitingRoomFilter,
    required this.updateWaitingRoomList,
    required this.updateWaitingRoomCounter,
    required this.updateRequestFilter,
    required this.updateRequestList,
    required this.updateRequestCounter,
    required this.updateTotalReqWait,
    required this.updateIsMenuModalVisible,
    required this.updateIsRecordingModalVisible,
    required this.updateIsSettingsModalVisible,
    required this.updateIsRequestsModalVisible,
    required this.updateIsWaitingModalVisible,
    required this.updateIsCoHostModalVisible,
    required this.updateIsMediaSettingsModalVisible,
    required this.updateIsDisplaySettingsModalVisible,
    required this.updateIsParticipantsModalVisible,
    required this.updateIsMessagesModalVisible,
    required this.updateIsConfirmExitModalVisible,
    required this.updateIsConfirmHereModalVisible,
    required this.updateIsLoadingModalVisible,
    required this.updateRecordingMediaOptions,
    required this.updateRecordingAudioOptions,
    required this.updateRecordingVideoOptions,
    required this.updateRecordingVideoType,
    required this.updateRecordingVideoOptimized,
    required this.updateRecordingDisplayType,
    required this.updateRecordingAddHLS,
    required this.updateRecordingNameTags,
    required this.updateRecordingBackgroundColor,
    required this.updateRecordingNameTagsColor,
    required this.updateRecordingAddText,
    required this.updateRecordingCustomText,
    required this.updateRecordingCustomTextPosition,
    required this.updateRecordingCustomTextColor,
    required this.updateRecordingOrientationVideo,
    required this.updateClearedToResume,
    required this.updateClearedToRecord,
    required this.updateRecordState,
    required this.updateShowRecordButtons,
    required this.updateRecordingProgressTime,
    required this.updateAudioSwitching,
    required this.updateVideoSwitching,
    required this.updateVideoAlreadyOn,
    required this.updateAudioAlreadyOn,
    required this.updateComponentSizes,
    required this.updateHasCameraPermission,
    required this.updateHasAudioPermission,
    required this.updateTransportCreated,
    this.updateLocalTransportCreated,
    required this.updateTransportCreatedVideo,
    required this.updateTransportCreatedAudio,
    required this.updateTransportCreatedScreen,
    required this.updateProducerTransport,
    this.updateLocalProducerTransport,
    required this.updateVideoProducer,
    this.updateLocalVideoProducer,
    required this.updateParams,
    required this.updateVideoParams,
    required this.updateAudioParams,
    required this.updateAudioProducer,
    this.updateLocalAudioProducer,
    required this.updateConsumerTransports,
    required this.updateConsumingTransports,
    required this.updatePolls,
    required this.updatePoll,
    required this.updateIsPollModalVisible,
    required this.updateBreakoutRooms,
    required this.updateCurrentRoomIndex,
    required this.updateCanStartBreakout,
    required this.updateBreakOutRoomStarted,
    required this.updateBreakOutRoomEnded,
    required this.updateHostNewRoom,
    required this.updateLimitedBreakRoom,
    required this.updateMainRoomsLength,
    required this.updateMemberRoom,
    required this.updateIsBreakoutRoomsModalVisible,
    required this.checkOrientation,
    required this.updateDevice,
    required this.updateSocket,
    this.updateLocalSocket,
    required this.updateValidated,
    required this.showAlert,

    // ---------------------
    // Functions Initialization
    // ---------------------
    required this.updateMiniCardsGrid,
    required this.mixStreams,
    required this.dispStreams,
    required this.stopShareScreen,
    required this.checkScreenShare,
    required this.startShareScreen,
    required this.requestScreenShare,
    required this.reorderStreams,
    required this.prepopulateUserMedia,
    required this.getVideos,
    required this.rePort,
    required this.trigger,
    required this.consumerResume,
    required this.connectSendTransport,
    required this.connectSendTransportAudio,
    required this.connectSendTransportVideo,
    required this.connectSendTransportScreen,
    required this.processConsumerTransports,
    required this.resumePauseStreams,
    required this.readjust,
    required this.checkGrid,
    required this.getEstimate,
    required this.calculateRowsAndColumns,
    required this.addVideosGrid,
    required this.onScreenChanges,
    required this.sleep,
    required this.changeVids,
    required this.compareActiveNames,
    required this.compareScreenStates,
    required this.createSendTransport,
    required this.resumeSendTransportAudio,
    required this.receiveAllPipedTransports,
    required this.disconnectSendTransportVideo,
    required this.disconnectSendTransportAudio,
    required this.disconnectSendTransportScreen,
    required this.getPipedProducersAlt,
    required this.signalNewConsumerTransport,
    required this.connectRecvTransport,
    required this.reUpdateInter,
    required this.updateParticipantAudioDecibels,
    required this.closeAndResize,
    required this.autoAdjust,
    required this.switchUserVideoAlt,
    required this.switchUserVideo,
    required this.switchUserAudio,
    required this.getDomains,
    required this.formatNumber,
    required this.connectIps,
    this.connectLocalIps,
    required this.createDeviceClient,
    required this.handleCreatePoll,
    required this.handleVotePoll,
    required this.handleEndPoll,
    required this.resumePauseAudioStreams,
    required this.processConsumerTransportsAudio,
    required this.checkPermission,
    required this.streamSuccessVideo,
    required this.streamSuccessAudio,
    required this.streamSuccessScreen,
    required this.streamSuccessAudioSwitch,
    required this.clickVideo,
    required this.clickAudio,
    required this.clickScreenShare,
    required this.switchVideoAlt,
    required this.requestPermissionCamera,
    required this.requestPermissionAudio,

    // --------------------- NOT IMPLEMENTED YET ---------------------
    // Background-related variables
    this.customImage,
    this.selectedImage,
    this.segmentVideo,
    required this.selfieSegmentation,
    required this.pauseSegmentation,
    this.processedStream,
    required this.keepBackground,
    required this.backgroundHasChanged,
    this.virtualStream,
    required this.mainCanvas,
    required this.prevKeepBackground,
    required this.appliedBackground,
    required this.isBackgroundModalVisible,
    required this.autoClickBackground,

    // Update functions
    required this.updateCustomImage,
    required this.updateSelectedImage,
    required this.updateSegmentVideo,
    required this.updateSelfieSegmentation,
    required this.updatePauseSegmentation,
    required this.updateProcessedStream,
    required this.updateKeepBackground,
    required this.updateBackgroundHasChanged,
    required this.updateVirtualStream,
    required this.updateMainCanvas,
    required this.updatePrevKeepBackground,
    required this.updateAppliedBackground,
    required this.updateIsBackgroundModalVisible,
    required this.updateAutoClickBackground,

    // Whiteboard-related variables
    required this.whiteboardUsers,
    this.currentWhiteboardIndex,
    required this.canStartWhiteboard,
    required this.whiteboardStarted,
    required this.whiteboardEnded,
    required this.whiteboardLimit,
    required this.isWhiteboardModalVisible,
    required this.isConfigureWhiteboardModalVisible,
    required this.shapes,
    required this.useImageBackground,
    required this.redoStack,
    required this.undoStack,
    this.canvasStream,
    required this.canvasWhiteboard,

    // Whiteboard update functions
    required this.updateWhiteboardUsers,
    required this.updateCurrentWhiteboardIndex,
    required this.updateCanStartWhiteboard,
    required this.updateWhiteboardStarted,
    required this.updateWhiteboardEnded,
    required this.updateWhiteboardLimit,
    required this.updateIsWhiteboardModalVisible,
    required this.updateIsConfigureWhiteboardModalVisible,
    required this.updateShapes,
    required this.updateUseImageBackground,
    required this.updateRedoStack,
    required this.updateUndoStack,
    required this.updateCanvasStream,
    required this.updateCanvasWhiteboard,

    // Screenboard-related variables
    required this.canvasScreenboard,
    this.processedScreenStream,
    required this.annotateScreenStream,
    required this.mainScreenCanvas,
    required this.isScreenboardModalVisible,

    // Screenboard update functions
    required this.updateCanvasScreenboard,
    required this.updateProcessedScreenStream,
    required this.updateAnnotateScreenStream,
    required this.updateMainScreenCanvas,
    required this.updateIsScreenboardModalVisible,
    required this.getUpdatedAllParams,
  });

  MediasfuParameters Function() getUpdatedAllParams;

  //Convert update functions to map

  Map<String, dynamic> get updateFunctions => {
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
        'updateTargetResolution': updateTargetResolution,
        'updateTargetResolutionHost': updateTargetResolutionHost,
        'updateVidCons': updateVidCons,
        'updateFrameRate': updateFrameRate,
        'updateHParams': updateHParams,
        'updateVParams': updateVParams,
        'updateScreenParams': updateScreenParams,
        'updateAParams': updateAParams,
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
        'updateRecordingMultiFormatsSupport':
            updateRecordingMultiFormatsSupport,
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
        'updatePrevFacingMode': updatePrevFacingMode,
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
        'updateUserDefaultAudioOutputDevice':
            updateUserDefaultAudioOutputDevice,
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
        'updateLastReorderTime': updateLastReorderTime,
        'updateAudStreamNames': updateAudStreamNames,
        'updateCurrentUserPage': updateCurrentUserPage,
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
        'updateLocalScreenProducer': updateLocalScreenProducer,
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
        'updateRefParticipants': updateRefParticipants,
        'updateMessages': updateMessages,
        'updateStartDirectMessage': updateStartDirectMessage,
        'updateDirectMessageDetails': updateDirectMessageDetails,
        'updateShowMessagesBadge': updateShowMessagesBadge,
        'updateAudioSetting': updateAudioSetting,
        'updateVideoSetting': updateVideoSetting,
        'updateScreenshareSetting': updateScreenshareSetting,
        'updateChatSetting': updateChatSetting,
        'updateAutoWave': updateAutoWave,
        'updateForceFullDisplay': updateForceFullDisplay,
        'updatePrevForceFullDisplay': updatePrevForceFullDisplay,
        'updatePrevMeetingDisplayType': updatePrevMeetingDisplayType,
        'updateWaitingRoomFilter': updateWaitingRoomFilter,
        'updateWaitingRoomList': updateWaitingRoomList,
        'updateWaitingRoomCounter': updateWaitingRoomCounter,
        'updateRequestFilter': updateRequestFilter,
        'updateRequestList': updateRequestList,
        'updateRequestCounter': updateRequestCounter,
        'updateTotalReqWait': updateTotalReqWait,
        'updateIsMenuModalVisible': updateIsMenuModalVisible,
        'updateIsRecordingModalVisible': updateIsRecordingModalVisible,
        'updateIsSettingsModalVisible': updateIsSettingsModalVisible,
        'updateIsRequestsModalVisible': updateIsRequestsModalVisible,
        'updateIsWaitingModalVisible': updateIsWaitingModalVisible,
        'updateIsCoHostModalVisible': updateIsCoHostModalVisible,
        'updateIsMediaSettingsModalVisible': updateIsMediaSettingsModalVisible,
        'updateIsDisplaySettingsModalVisible':
            updateIsDisplaySettingsModalVisible,
        'updateIsParticipantsModalVisible': updateIsParticipantsModalVisible,
        'updateIsMessagesModalVisible': updateIsMessagesModalVisible,
        'updateIsConfirmExitModalVisible': updateIsConfirmExitModalVisible,
        'updateIsConfirmHereModalVisible': updateIsConfirmHereModalVisible,
        'updateIsLoadingModalVisible': updateIsLoadingModalVisible,
        'updateRecordingMediaOptions': updateRecordingMediaOptions,
        'updateRecordingAudioOptions': updateRecordingAudioOptions,
        'updateRecordingVideoOptions': updateRecordingVideoOptions,
        'updateRecordingVideoType': updateRecordingVideoType,
        'updateRecordingVideoOptimized': updateRecordingVideoOptimized,
        'updateRecordingDisplayType': updateRecordingDisplayType,
        'updateRecordingAddHLS': updateRecordingAddHLS,
        'updateRecordingNameTags': updateRecordingNameTags,
        'updateRecordingBackgroundColor': updateRecordingBackgroundColor,
        'updateRecordingNameTagsColor': updateRecordingNameTagsColor,
        'updateRecordingAddText': updateRecordingAddText,
        'updateRecordingCustomText': updateRecordingCustomText,
        'updateRecordingCustomTextPosition': updateRecordingCustomTextPosition,
        'updateRecordingCustomTextColor': updateRecordingCustomTextColor,
        'updateRecordingOrientationVideo': updateRecordingOrientationVideo,
        'updateClearedToResume': updateClearedToResume,
        'updateClearedToRecord': updateClearedToRecord,
        'updateRecordState': updateRecordState,
        'updateShowRecordButtons': updateShowRecordButtons,
        'updateRecordingProgressTime': updateRecordingProgressTime,
        'updateAudioSwitching': updateAudioSwitching,
        'updateVideoSwitching': updateVideoSwitching,
        'updateVideoAlreadyOn': updateVideoAlreadyOn,
        'updateAudioAlreadyOn': updateAudioAlreadyOn,
        'updateComponentSizes': updateComponentSizes,
        'updateHasCameraPermission': updateHasCameraPermission,
        'updateHasAudioPermission': updateHasAudioPermission,
        'updateTransportCreated': updateTransportCreated,
        'updateLocalTransportCreated': updateLocalTransportCreated,
        'updateTransportCreatedVideo': updateTransportCreatedVideo,
        'updateTransportCreatedAudio': updateTransportCreatedAudio,
        'updateTransportCreatedScreen': updateTransportCreatedScreen,
        'updateProducerTransport': updateProducerTransport,
        'updateLocalProducerTransport': updateLocalProducerTransport,
        'updateVideoProducer': updateVideoProducer,
        'updateLocalVideoProducer': updateLocalVideoProducer,
        'updateParams': updateParams,
        'updateVideoParams': updateVideoParams,
        'updateAudioParams': updateAudioParams,
        'updateAudioProducer': updateAudioProducer,
        'updateLocalAudioProducer': updateLocalAudioProducer,
        'updateConsumerTransports': updateConsumerTransports,
        'updateConsumingTransports': updateConsumingTransports,
        'updatePolls': updatePolls,
        'updatePoll': updatePoll,
        'updateIsPollModalVisible': updateIsPollModalVisible,
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
        'updateDevice': updateDevice,
        'updateSocket': updateSocket,
        'updateLocalSocket': updateLocalSocket,
        'updateValidated': updateValidated
      };
}
