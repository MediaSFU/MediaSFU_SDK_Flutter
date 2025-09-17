// ignore_for_file: unused_local_variable

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../components/display_components/audio_card.dart' hide AudioCardType;
import '../components/display_components/mini_card.dart' hide MiniCardType;
import '../components/display_components/video_card.dart' hide VideoCardType;
import '../types/types.dart' show Participant, Stream, EventType, MediaStream;
import '../types/custom_builders.dart'
    show VideoCardType, AudioCardType, MiniCardType;

/// Parameters for the prepopulateUserMedia function, implementing multiple interfaces
/// to support flexible and detailed media grid configurations for participants.
abstract class PrepopulateUserMediaParameters
    implements AudioCardParameters, VideoCardParameters {
  // Basic properties as abstract getters
  List<Participant> get participants;
  List<Stream> get allVideoStreams; // (Stream | Participant)[]
  String get islevel;
  String get member;
  bool get shared;
  bool get shareScreenStarted;
  EventType get eventType;
  String? get screenId;
  bool get forceFullDisplay;
  bool get updateMainWindow;
  bool get mainScreenFilled;
  bool get adminOnMainScreen;
  String get mainScreenPerson;
  bool get videoAlreadyOn;
  bool get audioAlreadyOn;
  List<Stream> get oldAllStreams; // (Stream | Participant)[]
  String Function() get checkOrientation;
  bool get screenForceFullDisplay;
  MediaStream? get localStreamScreen;
  List<Stream> get remoteScreenStream;
  MediaStream? get localStreamVideo;
  double get mainHeightWidth;
  bool get isWideScreen;
  bool get localUIMode;
  bool get whiteboardStarted;
  bool get whiteboardEnded;
  MediaStream? get virtualStream;
  bool get keepBackground;
  bool get annotateScreenStream;

  // Custom builder functions
  VideoCardType? get customVideoCard;
  AudioCardType? get customAudioCard;
  MiniCardType? get customMiniCard;

  // Update functions as abstract getters
  void Function(String) get updateMainScreenPerson;
  void Function(bool) get updateMainScreenFilled;
  void Function(bool) get updateAdminOnMainScreen;
  void Function(double) get updateMainHeightWidth;
  void Function(bool) get updateScreenForceFullDisplay;
  void Function(bool) get updateUpdateMainWindow;
  void Function(List<Widget>) get updateMainGridStream;

  // Mediasfu functions as an abstract getter
  PrepopulateUserMediaParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

/// Configuration options for the `prepopulateUserMedia` function.
/// This function populates the main media grid with video, audio, or mini-cards
/// based on the media activity of the participant.
/// It dynamically updates the main media grid based on the `EventType` and participant settings.
/// The function returns a list of widgets representing the media display or an empty list for inactive states.
/// It also catches errors during the media card setup and provides debugging messages in development mode.
///
/// ### Parameters:
/// - [name]: The name of the participant.
/// - [parameters]: The `PrepopulateUserMediaParameters` containing participant details
///  and media settings, along with methods for dynamic state updates.
///
/// ### Returns:
/// - A list of widgets representing the media display, or an empty list for inactive states.
///
/// ### Example Usage:
/// ```dart
/// final options = PrepopulateUserMediaOptions(
///  name: 'Host',
/// parameters: mediaParameters,
/// );
///
/// await prepopulateUserMedia(options);
/// ```
class PrepopulateUserMediaOptions {
  final String name;
  final PrepopulateUserMediaParameters parameters;

  PrepopulateUserMediaOptions({
    required this.name,
    required this.parameters,
  });
}

typedef PrepopulateUserMediaType = Future<List<Widget>?> Function(
    PrepopulateUserMediaOptions options);

/// Populates the main media grid with video, audio, or mini-cards based on
/// the media activity of the participant.
///
/// Depending on the `EventType`, the function determines the primary display based
/// on parameters such as the host, shared screens, or active video streams, updating
/// the main media grid in real-time.
///
/// - **Audio Handling**: Adds an `AudioCard` if audio is active but no video.
/// - **Video Handling**: Adds a `VideoCard` when the participant’s video is active.
/// - **Screen Sharing**: Adjusts the display for shared screen or whiteboard sessions.
/// - **Mini Cards**: Adds a `MiniCard` for participants without active video/audio.
///
/// ### Parameters:
/// - [options]: The `PrepopulateUserMediaOptions` containing participant details
///   and media settings, along with methods for dynamic state updates.
///
/// ### Returns:
/// - A list of widgets representing the media display, or an empty list for inactive states.
///
/// ### Example Usage:
/// ```dart
/// final options = PrepopulateUserMediaOptions(
///   name: 'Host',
///   parameters: mediaParameters,
/// );
///
/// await prepopulateUserMedia(options);
/// ```
///
/// ### Error Handling:
/// Catches errors during the media card setup and provides debugging messages
/// in development mode for efficient troubleshooting.

Future<List<Widget>?> prepopulateUserMedia(
  PrepopulateUserMediaOptions options,
) async {
  // Destructure options
  String name = options.name;
  PrepopulateUserMediaParameters parameters = options.parameters;

  try {
    // Retrieve updated parameters
    parameters = parameters.getUpdatedAllParams();

    // Destructure parameters
    List<Participant> participants = parameters.participants;
    List<Stream> allVideoStreams = parameters.allVideoStreams;
    String islevel = parameters.islevel;
    String member = parameters.member;
    bool shared = parameters.shared;
    bool shareScreenStarted = parameters.shareScreenStarted;
    EventType eventType = parameters.eventType;
    String? screenId = parameters.screenId;
    bool forceFullDisplay = parameters.forceFullDisplay;
    bool updateMainWindow = parameters.updateMainWindow;
    bool mainScreenFilled = parameters.mainScreenFilled;
    bool adminOnMainScreen = parameters.adminOnMainScreen;
    String mainScreenPerson = parameters.mainScreenPerson;
    bool videoAlreadyOn = parameters.videoAlreadyOn;
    bool audioAlreadyOn = parameters.audioAlreadyOn;
    List<Stream> oldAllStreams = parameters.oldAllStreams;
    String Function() checkOrientation = parameters.checkOrientation;
    bool screenForceFullDisplay = parameters.screenForceFullDisplay;
    MediaStream? localStreamScreen = parameters.localStreamScreen;
    List<Stream> remoteScreenStream = parameters.remoteScreenStream;
    MediaStream? localStreamVideo = parameters.localStreamVideo;
    double mainHeightWidth = parameters.mainHeightWidth;
    bool isWideScreen = parameters.isWideScreen;
    bool localUIMode = parameters.localUIMode;
    bool whiteboardStarted = parameters.whiteboardStarted;
    bool whiteboardEnded = parameters.whiteboardEnded;
    MediaStream? virtualStream = parameters.virtualStream;
    bool keepBackground = parameters.keepBackground;
    bool annotateScreenStream = parameters.annotateScreenStream;

    // Update functions
    final void Function(String) updateMainScreenPerson =
        parameters.updateMainScreenPerson;
    final void Function(bool) updateMainScreenFilled =
        parameters.updateMainScreenFilled;
    final void Function(bool) updateAdminOnMainScreen =
        parameters.updateAdminOnMainScreen;
    final void Function(double) updateMainHeightWidth =
        parameters.updateMainHeightWidth;
    final void Function(bool) updateScreenForceFullDisplay =
        parameters.updateScreenForceFullDisplay;
    final void Function(bool) updateUpdateMainWindow =
        parameters.updateUpdateMainWindow;
    final void Function(List<Widget>) updateMainGridStream =
        parameters.updateMainGridStream;

    // If the event type is 'chat', return early
    if (eventType == EventType.chat) {
      return [];
    }

    // Initialize variables
    Participant? host;
    Stream? hostStream;
    List<Widget> newComponent = [];

    // Check if screen sharing is started or shared
    if (shareScreenStarted || shared) {
      // Handle main grid visibility based on the event type
      if (eventType == EventType.conference) {
        if (shared || shareScreenStarted) {
          if (mainHeightWidth == 0) {
            // Add the main grid if not present
            updateMainHeightWidth(84);
          }
        } else {
          // Remove the main grid if not shared or started
          updateMainHeightWidth(0);
        }
      }

      // Switch display to optimize for screen share
      screenForceFullDisplay = forceFullDisplay;
      updateScreenForceFullDisplay(screenForceFullDisplay);

      // Get the orientation and adjust forceFullDisplay
      String orientation = checkOrientation();
      if (orientation == "portrait" || !isWideScreen) {
        if (shareScreenStarted || shared) {
          screenForceFullDisplay = false;
          updateScreenForceFullDisplay(screenForceFullDisplay);
        }
      }

      // Check if the user is sharing the screen
      if (shared) {
        // User is sharing
        host =
            Participant(name: member, audioID: '', videoID: '', videoOn: false);
        hostStream = Stream(
          producerId: member,
          stream: localStreamScreen,
        );

        // Update admin on the main screen
        adminOnMainScreen = islevel == '2';
        updateAdminOnMainScreen(adminOnMainScreen);

        // Update main screen person
        mainScreenPerson = host.name;
        updateMainScreenPerson(mainScreenPerson);
      } else {
        // Someone else is sharing
        host = participants.firstWhereOrNull(
          (participant) =>
              participant.ScreenID == screenId && participant.ScreenOn == true,
        );

        if (whiteboardStarted && !whiteboardEnded) {
          // Whiteboard is active
          host = Participant(
              name: "WhiteboardActive",
              islevel: "2",
              audioID: '',
              videoID: '',
              videoOn: false);
          hostStream = Stream(
            producerId: "WhiteboardActive",
          );
        }

        host ??= participants.firstWhereOrNull(
          (participant) => participant.ScreenOn == true,
        );

        // Check remoteScreenStream
        if (host != null &&
            host.name.isNotEmpty &&
            !(host.name.contains("WhiteboardActive"))) {
          if (remoteScreenStream.isEmpty) {
            hostStream = allVideoStreams.firstWhere(
              (stream) => stream.producerId == host!.ScreenID,
              orElse: () => Stream(
                producerId: 'none',
              ),
            );
          } else {
            hostStream = remoteScreenStream[0];
          }
        }

        // Update admin on the main screen
        adminOnMainScreen = (host?.islevel == "2");
        updateAdminOnMainScreen(adminOnMainScreen);

        // Update main screen person
        mainScreenPerson = host?.name ?? '';
        updateMainScreenPerson(mainScreenPerson);
      }
    } else {
      // Screen share not started
      if (eventType == EventType.conference) {
        // No main grid for conferences
        return [];
      }

      // Find the host with level '2'
      host = participants.firstWhere(
        (participant) => participant.islevel == '2',
        orElse: () =>
            Participant(name: member, audioID: '', videoID: '', videoOn: false),
      );

      // Update main screen person
      mainScreenPerson = host.name;
      updateMainScreenPerson(mainScreenPerson);
    }

    // If host is not null, check if host videoIsOn
    if (host != null) {
      // Populate the main screen with the host video
      if ((shareScreenStarted || shared) && hostStream != null) {
        forceFullDisplay = screenForceFullDisplay;
        if (whiteboardStarted && !whiteboardEnded) {
          // Whiteboard is active (additional logic if needed)
        } else {
          newComponent.add(
            parameters.customVideoCard != null
                ? parameters.customVideoCard!(
                    participant: host,
                    stream: hostStream,
                    width: double.infinity,
                    height: double.infinity,
                    showControls: false,
                    showInfo: true,
                    name: host.name,
                    doMirror: "false",
                    backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
                    parameters: parameters,
                  )
                : VideoCard(
                    options: VideoCardOptions(
                      videoStream: hostStream.stream,
                      remoteProducerId: host.ScreenID ?? host.name,
                      eventType: eventType,
                      forceFullDisplay: forceFullDisplay,
                      participant: host,
                      backgroundColor:
                          const Color.fromRGBO(217, 227, 234, 0.99),
                      showControls: false,
                      showInfo: true,
                      name: host.name,
                      doMirror: false,
                      parameters: parameters,
                    ),
                  ),
          );
        }

        updateMainGridStream(newComponent);

        mainScreenFilled = true;
        updateMainScreenFilled(mainScreenFilled);
        adminOnMainScreen = host.islevel == "2";
        updateAdminOnMainScreen(adminOnMainScreen);
        mainScreenPerson = host.name;
        updateMainScreenPerson(mainScreenPerson);

        return newComponent;
      }
      // Check if video is already on or not
      if ((islevel != '2' && !host.videoOn!) ||
          (islevel == '2' && (!host.videoOn! || !videoAlreadyOn)) ||
          localUIMode == true) {
        // Video is off
        if (islevel == '2' && videoAlreadyOn) {
          // Admin's video is on
          newComponent.add(
            parameters.customVideoCard != null
                ? parameters.customVideoCard!(
                    participant: host,
                    stream: Stream(
                        stream: localStreamVideo, producerId: host.videoID),
                    width: double.infinity,
                    height: double.infinity,
                    showControls: false,
                    showInfo: true,
                    name: host.name,
                    doMirror: "true",
                    backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
                    parameters: parameters,
                  )
                : VideoCard(
                    options: VideoCardOptions(
                    videoStream: localStreamVideo,
                    remoteProducerId: host.videoID,
                    eventType: eventType,
                    forceFullDisplay: forceFullDisplay,
                    participant: host,
                    backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
                    showControls: false,
                    showInfo: true,
                    name: host.name,
                    doMirror: true,
                    parameters: parameters,
                  )),
          );

          updateMainGridStream(newComponent);

          mainScreenFilled = true;
          updateMainScreenFilled(mainScreenFilled);
          adminOnMainScreen = true;
          updateAdminOnMainScreen(adminOnMainScreen);
          mainScreenPerson = host.name;
          updateMainScreenPerson(mainScreenPerson);
        } else {
          // Video is off and not admin
          bool audOn = false;

          if (islevel == '2' && audioAlreadyOn) {
            audOn = true;
          } else {
            if (host.name.isNotEmpty && islevel != '2') {
              audOn = !(host.muted ?? true);
            }
          }

          if (audOn) {
            // Audio is on
            try {
              newComponent.add(
                parameters.customAudioCard != null
                    ? parameters.customAudioCard!(
                        name: host.name,
                        barColor: false, // Assuming red color means active
                        textColor: const Color.fromARGB(255, 17, 16, 16),
                        imageSource: '', // No image property in Participant
                        roundedImage: 50.0,
                        imageStyle: Colors.transparent,
                        parameters: parameters,
                      )
                    : AudioCard(
                        options: AudioCardOptions(
                        name: host.name,
                        barColor: const Color.fromARGB(255, 229, 20, 20),
                        textColor: const Color.fromARGB(255, 17, 16, 16),
                        customStyle: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        controlsPosition: 'topLeft',
                        infoPosition: 'topRight',
                        roundedImage: true,
                        parameters: parameters,
                        participant: host,
                        showControls: islevel != '2',
                        backgroundColor: Colors.transparent,
                      )),
              );

              updateMainGridStream(newComponent);
            } catch (error) {
              // Handle audio card creation error
              if (kDebugMode) {
                print('Error creating AudioCard: $error');
              }
            }

            mainScreenFilled = true;
            updateMainScreenFilled(mainScreenFilled);
            adminOnMainScreen = islevel == '2';
            updateAdminOnMainScreen(adminOnMainScreen);
            mainScreenPerson = host.name;
            updateMainScreenPerson(mainScreenPerson);
          } else {
            // Audio is off
            try {
              newComponent.add(
                parameters.customMiniCard != null
                    ? parameters.customMiniCard!(
                        initials: name,
                        fontSize: "20",
                        name: host.name,
                        showVideoIcon: false,
                        showAudioIcon: false,
                        imageSource: '',
                        roundedImage: 50.0,
                        imageStyle: Colors.transparent,
                        parameters: parameters,
                      )
                    : MiniCard(
                        options: MiniCardOptions(
                            initials: name,
                            fontSize: 20,
                            customStyle: const BoxDecoration(
                              color: Colors.transparent,
                            )),
                      ),
              );

              updateMainGridStream(newComponent);
            } catch (error) {
              // Handle mini card creation error
              if (kDebugMode) {
                print('Error creating MiniCard: $error');
              }
            }

            mainScreenFilled = false;
            updateMainScreenFilled(mainScreenFilled);
            adminOnMainScreen = islevel == '2';
            updateAdminOnMainScreen(adminOnMainScreen);
            mainScreenPerson = host.name;
            updateMainScreenPerson(mainScreenPerson);
          }
        }
      } else {
        // Video is on
        if (shareScreenStarted || shared) {
          // Screen share is on
          try {
            newComponent.add(
              parameters.customVideoCard != null
                  ? parameters.customVideoCard!(
                      participant: host,
                      stream: hostStream!,
                      width: double.infinity,
                      height: double.infinity,
                      showControls: false,
                      showInfo: true,
                      name: host.name,
                      doMirror: "false",
                      backgroundColor:
                          const Color.fromRGBO(217, 227, 234, 0.99),
                      parameters: parameters,
                    )
                  : VideoCard(
                      options: VideoCardOptions(
                      videoStream: hostStream!.stream,
                      remoteProducerId: host.ScreenID ?? host.name,
                      eventType: eventType,
                      forceFullDisplay: forceFullDisplay,
                      participant: host,
                      backgroundColor:
                          const Color.fromRGBO(217, 227, 234, 0.99),
                      showControls: false,
                      showInfo: true,
                      name: host.name,
                      doMirror: false,
                      parameters: parameters,
                    )),
            );

            updateMainGridStream(newComponent);

            mainScreenFilled = true;
            updateMainScreenFilled(mainScreenFilled);
            adminOnMainScreen = host.islevel == '2';
            updateAdminOnMainScreen(adminOnMainScreen);
            mainScreenPerson = host.name;
            updateMainScreenPerson(mainScreenPerson);
          } catch (error) {
            // Handle video card creation error
            if (kDebugMode) {
              print('Error creating VideoCard: $error');
            }
          }
        } else {
          // Screen share is off
          if (islevel == '2') {
            hostStream = keepBackground && virtualStream != null
                ? Stream(producerId: 'virtual', stream: virtualStream)
                : Stream(
                    producerId: host.videoID,
                    stream: localStreamVideo,
                  );
            hostStream = hostStream;
          } else {
            var streame = oldAllStreams.firstWhere(
              (streame) => streame.producerId == host!.videoID,
              orElse: () => Stream(
                producerId: 'none',
              ),
            );
            hostStream = Stream(
              producerId: host.videoID,
              stream: streame.stream,
            );
          }

          try {
            if (hostStream.stream != null) {
              newComponent.add(
                parameters.customVideoCard != null
                    ? parameters.customVideoCard!(
                        participant: host,
                        stream: hostStream,
                        width: double.infinity,
                        height: double.infinity,
                        showControls: false,
                        showInfo: true,
                        name: host.name,
                        doMirror: member == host.name ? "true" : "false",
                        backgroundColor:
                            const Color.fromRGBO(217, 227, 234, 0.99),
                        parameters: parameters,
                      )
                    : VideoCard(
                        options: VideoCardOptions(
                        videoStream: hostStream.stream,
                        remoteProducerId: host.videoID,
                        eventType: eventType,
                        forceFullDisplay: forceFullDisplay,
                        participant: host,
                        backgroundColor:
                            const Color.fromRGBO(217, 227, 234, 0.99),
                        showControls: false,
                        showInfo: true,
                        name: host.name,
                        doMirror: member == host.name,
                        parameters: parameters,
                      )),
              );

              updateMainGridStream(newComponent);
              mainScreenFilled = true;
              adminOnMainScreen = host.islevel == '2';
              mainScreenPerson = host.name;
            } else {
              newComponent.add(
                parameters.customMiniCard != null
                    ? parameters.customMiniCard!(
                        initials: name,
                        fontSize: "20",
                        name: host.name,
                        showVideoIcon: false,
                        showAudioIcon: false,
                        imageSource: '',
                        roundedImage: 50.0,
                        imageStyle: Colors.transparent,
                        parameters: parameters,
                      )
                    : MiniCard(
                        options: MiniCardOptions(
                            initials: name,
                            fontSize: 20,
                            customStyle: const BoxDecoration(
                              color: Colors.transparent,
                            )),
                      ),
              );

              updateMainGridStream(newComponent);
              mainScreenFilled = false;
              adminOnMainScreen = islevel == '2';
              mainScreenPerson = host.name;
            }

            updateMainScreenFilled(mainScreenFilled);
            updateAdminOnMainScreen(adminOnMainScreen);
            updateMainScreenPerson(mainScreenPerson);
          } catch (error) {
            // Handle video card creation error
            if (kDebugMode) {
              print('Error creating VideoCard or MiniCard: $error');
            }
          }
        }
      }
    } else {
      // Host is null, add a mini card
      try {
        newComponent.add(
          parameters.customMiniCard != null
              ? parameters.customMiniCard!(
                  initials: name,
                  fontSize: "20",
                  name: name,
                  showVideoIcon: false,
                  showAudioIcon: false,
                  imageSource: '',
                  roundedImage: 50.0,
                  imageStyle: Colors.transparent,
                  parameters: parameters,
                )
              : MiniCard(
                  options: MiniCardOptions(
                      initials: name,
                      fontSize: 20,
                      customStyle: const BoxDecoration(
                        color: Colors.transparent,
                      )),
                ),
        );

        updateMainGridStream(newComponent);

        mainScreenFilled = false;
        adminOnMainScreen = false;
        mainScreenPerson = '';
        updateMainScreenFilled(mainScreenFilled);
        updateAdminOnMainScreen(adminOnMainScreen);
        updateMainScreenPerson(mainScreenPerson);
      } catch (error) {
        // Handle mini card creation error
      }
    }

    // Update main window status
    updateUpdateMainWindow(false);

    return newComponent;
  } catch (error) {
    // Handle errors during the process of preparing and populating the main screen
    if (kDebugMode) {
      print('Error preparing and populating the main screen: $error');
    }

    // Optionally, rethrow the error or return an empty list
    return [];
  }
}
